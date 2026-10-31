// SPIKE (DEC-003 OPEN, DEC-025 PROPOSED). OP-10 saveProfile, from API_AND_BACKEND_CONTRACT.md
// section 4.2. Local emulators only. The input shape (`profile`, `accepted_versions`) and the
// output shape are spike choices, because the contract does not fix them.
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { onCall } from 'firebase-functions/v2/https';
import { accountClosed, cannotVerify, invalidArgument, unauthenticated } from './errors.js';
import { checkProfile, ConfigError, consentId, parsePublicConfig, versionsMatch } from './profile.js';
import { isDocumentId, isObject } from './validation.js';

export const saveProfile = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw unauthenticated();

  const data: unknown = request.data;
  if (!isObject(data)) throw invalidArgument(['request_id', 'profile']);
  if (typeof data.request_id !== 'string' || data.request_id.trim().length === 0) {
    throw invalidArgument(['request_id']);
  }
  if (!isObject(data.profile)) throw invalidArgument(['profile']);
  const profileInput = data.profile;
  const acceptedVersions = data.accepted_versions;

  // The provider can disable an account, and the backend reads both (DATABASE_AND_DATA_MODEL.md section 5.2).
  const providerUser = await getAuth()
    .getUser(uid)
    .catch((error: { code?: string }) => {
      if (error.code === 'auth/user-not-found') return null;
      throw error;
    });
  if (!providerUser || providerUser.disabled) throw accountClosed();

  const db = getFirestore();
  const userRef = db.doc(`users/${uid}`);

  return db.runTransaction(async (tx) => {
    const userSnap = await tx.get(userRef);
    if (userSnap.exists && userSnap.get('status') !== 'active') throw accountClosed();

    const configSnap = await tx.get(db.doc('config/public'));
    let config;
    try {
      config = parsePublicConfig(configSnap.data());
    } catch (error) {
      if (!(error instanceof ConfigError)) throw error;
      logger.error('saveProfile refused: public configuration is not usable', { problem: error.message });
      throw cannotVerify();
    }

    const check = checkProfile(profileInput, config.requiredFields);
    const invalid = [...check.invalid];

    // On the first call the reader accepts the current versions. A later call may leave them out,
    // and whatever it sends must still be current (FR-PRIV-001; OQ-27 for how consent is recorded).
    const isFirstCall = !userSnap.exists;
    if (acceptedVersions === undefined) {
      if (isFirstCall) invalid.push('accepted_versions');
    } else if (!versionsMatch(acceptedVersions, config.policyVersions)) {
      invalid.push('accepted_versions');
    }

    // A server write checks its reference inside the transaction (INV-13).
    const segmentId = check.values.industry_segment_id;
    if (typeof segmentId === 'string') {
      const segmentSnap = isDocumentId(segmentId) ? await tx.get(db.collection('segments').doc(segmentId)) : null;
      if (!segmentSnap?.exists) invalid.push('industry_segment_id');
    }

    if (invalid.length > 0) throw invalidArgument(invalid.sort());

    const consents = [
      { type: 'privacy_policy', version: config.policyVersions.privacy_policy },
      { type: 'terms_of_use', version: config.policyVersions.terms_of_use },
    ].map((consent) => {
      const id = consentId(consent.type, consent.version);
      return { ...consent, id, ref: userRef.collection('consents').doc(id) };
    });
    const consentSnaps = acceptedVersions === undefined ? [] : await tx.getAll(...consents.map((c) => c.ref));

    const now = FieldValue.serverTimestamp();

    if (isFirstCall) {
      tx.set(userRef, { user_id: uid, status: 'active', created_at: now });
    }

    // The profile is replaced (OP-10). The email address is not copied (GS-Q5).
    tx.set(userRef.collection('profile').doc('current'), { ...check.values, user_id: uid, updated_at: now });

    // A consent record that already exists keeps its first acceptance time.
    consentSnaps.forEach((snap, index) => {
      if (snap.exists) return;
      const consent = consents[index];
      tx.set(consent.ref, {
        consent_id: consent.id,
        user_id: uid,
        document_type: consent.type,
        document_version: consent.version,
        accepted_at: now,
        method: 'registration_action',
      });
    });

    return check.missing.length === 0
      ? { profile_status: 'complete' }
      : { profile_status: 'incomplete', missing_fields: check.missing };
  });
});
