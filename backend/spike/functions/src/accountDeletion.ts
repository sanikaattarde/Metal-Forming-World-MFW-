// SPIKE (DEC-003 OPEN). PROVISIONAL (DEC-029, OQ-24). OP-12 requestAccountDeletion, from
// API_AND_BACKEND_CONTRACT.md section 4, on the working position of immediate deletion (GS-Q50, TD-19).
// OQ-24 (whether any record is kept) is OPEN, so nothing is kept. Not built: the app side (MOD03-P4-T01),
// the removal of topic subscriptions (OQ-55) and the schedule of the cleanup (OP-41).
import type { Auth } from 'firebase-admin/auth';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import type { Firestore } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { applyAdminRemoval, planAdminRemoval } from './admin.js';
import { alreadyDeleting, cannotVerify, invalidArgument, unauthenticated } from './errors.js';
import { logOperation } from './safeLog.js';
import { isNonEmptyText, isObject, unknownFields } from './validation.js';

const OPERATION = 'requestAccountDeletion';
const FIELDS = new Set(['request_id', 'confirm']);

// The reader's own records under users/{uid} (DATABASE_AND_DATA_MODEL.md section 13.3).
export const OWN_COLLECTIONS = ['profile', 'consents', 'bookmarks', 'favourites', 'notification_preferences'];

// Passed in, so that a test can make a step fail.
export interface DeletionBackend {
  db: Firestore;
  auth: Auth;
}

export type DeletionState = 'deleted' | 'deleting';

const ignoreMissingAccount = (error: { code?: string }) => {
  if (error.code !== 'auth/user-not-found') throw error;
};

// Every step can run again, so the cleanup repeats all of them whatever stopped a deletion (OP-41). The
// user record goes last, after the sign-in account, so that a deletion that stopped part-way can still be
// found by its status.
export async function eraseAccount({ db, auth }: DeletionBackend, uid: string): Promise<void> {
  const userRef = db.collection('users').doc(uid);

  // 1. End the sessions. A token already issued stays valid until it expires (10-deletion-notes.md).
  await auth.revokeRefreshTokens(uid).catch(ignoreMissingAccount);

  // 2. The reader's own records.
  for (const name of OWN_COLLECTIONS) await db.recursiveDelete(userRef.collection(name));

  // 3. The admin role record, removed with the account (section 13.3). The count was taken down when the
  // deletion was confirmed.
  await db.collection('admin_roles').doc(uid).delete();

  // 4. The sign-in account.
  await auth.deleteUser(uid).catch(ignoreMissingAccount);

  // 5. The user record, and anything else left under it.
  await db.recursiveDelete(userRef);
}

export async function requestDeletion(backend: DeletionBackend, uid: string | undefined, data: unknown): Promise<DeletionState> {
  if (!uid) throw unauthenticated();

  // The account is always the caller's own: the operation takes no account identifier.
  const input = isObject(data) ? data : {};
  const invalid = unknownFields(input, FIELDS);
  if (!isNonEmptyText(input.request_id)) invalid.push('request_id');
  // FR-PRIV-004 asks for a confirmation. The field's name is a spike choice.
  if (input.confirm !== true) invalid.push('confirm');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  const { db } = backend;
  const userRef = db.collection('users').doc(uid);
  await db.runTransaction(async (tx) => {
    const user = await tx.get(userRef);
    if (user.exists && user.get('status') === 'deleting') throw alreadyDeleting();

    // An active admin leaves the count in the same transaction, and the last one cannot leave (INV-03).
    const plan = await planAdminRemoval(tx, db, uid);
    const now = FieldValue.serverTimestamp();
    // A reader who never saved a profile has no record yet. One is written, so the cleanup can find it.
    tx.set(userRef, { user_id: uid, status: 'deleting', deletion_requested_at: now, ...(user.exists ? {} : { created_at: now }) }, { merge: true });
    if (plan) applyAdminRemoval(tx, plan);
  });

  try {
    await eraseAccount(backend, uid);
    return 'deleted';
  } catch {
    // The deletion has started and the account is closed. The cleanup finishes it (OP-41).
    return 'deleting';
  }
}

export const requestAccountDeletion = onCall(async (request) => {
  const uid = request.auth?.uid;
  const caller = uid ?? 'none';
  try {
    const state = await requestDeletion({ db: getFirestore(), auth: getAuth() }, uid, request.data);
    logOperation({ operation: OPERATION, caller, outcome: state });
    return { state };
  } catch (error) {
    if (error instanceof HttpsError) {
      const details = error.details as { reason?: string } | undefined;
      logOperation({ operation: OPERATION, caller, outcome: details?.reason ?? error.code });
      throw error;
    }
    logOperation({ operation: OPERATION, caller, outcome: 'internal' });
    throw cannotVerify();
  }
});
