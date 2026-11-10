// OP-11 getIssueFile, from API_AND_BACKEND_CONTRACT.md section 4.2 and
// section 8: check 0 and the six ordered checks, then a signed link from the grant issuer (DEC-020). Rate limiting
// (RATE_LIMITED) is not built (MOD13-P1-T07). The checks read only what they need, and write nothing.
import { getAuth } from 'firebase-admin/auth';
import type { Auth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import type { DocumentSnapshot, Firestore } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import {
  accountClosed,
  cannotVerify,
  emailNotVerified,
  gone,
  invalidArgument,
  issueNotAvailable,
  noCurrentFile,
  profileIncomplete,
  unauthenticated,
} from './errors.js';
import { grantIssuer } from './grantIssuer.js';
import type { GrantIssuer } from './grantIssuer.js';
import { isProfileComplete, parsePublicConfig } from './profile.js';
import { logOperation } from './safeLog.js';
import { isUsableLifetime, MAX_LINK_LIFETIME_SECONDS } from './signedLinks.js';
import { isDocumentId, isObject, unknownFields } from './validation.js';

const OPERATION = 'getIssueFile';
const FIELDS = new Set(['issue_id']);

// Passed in, so that a test can make a read or the issuer fail and check that the call is refused.
export interface IssueFileBackend {
  db: Firestore;
  auth: Auth;
  issuer: GrantIssuer;
}

export interface IssueFileGrant {
  url: string;
  expires_at: number; // milliseconds, UTC. The form is PROPOSED
  revision: number;
  size_bytes: number;
  checksum_sha256: string;
}

// Fails closed. Neither setting has a default here, because neither value is decided (BR-003, OQ-37).
// The unit of signed_url_lifetime is not stated anywhere. Seconds is PROPOSED. A lifetime over the
// ceiling is refused, so a wrong setting cannot make a long-lived link (SEC-CHK-03).
function parsePrivateConfig(snap: DocumentSnapshot) {
  const gate: unknown = snap.get('profile_gate_enabled');
  const lifetime: unknown = snap.get('signed_url_lifetime');
  if (typeof gate !== 'boolean') throw new Error('profile_gate_enabled is missing or malformed');
  if (!isUsableLifetime(lifetime)) {
    throw new Error(`signed_url_lifetime is missing, malformed or over ${MAX_LINK_LIFETIME_SECONDS} seconds`);
  }
  return { profileGateEnabled: gate, lifetimeSeconds: lifetime as number };
}

// A current revision without these facts is damaged, so it fails closed instead of releasing a file the
// app could not check (FR-READ-010).
function parseFileFacts(snap: DocumentSnapshot) {
  const storagePath: unknown = snap.get('storage_path');
  const sizeBytes: unknown = snap.get('size_bytes');
  const checksum: unknown = snap.get('checksum_sha256');
  if (typeof storagePath !== 'string' || storagePath.length === 0) throw new Error('storage_path is missing');
  if (!Number.isInteger(sizeBytes) || (sizeBytes as number) < 1) throw new Error('size_bytes is missing');
  if (typeof checksum !== 'string' || checksum.length === 0) throw new Error('checksum_sha256 is missing');
  return { storagePath, sizeBytes: sizeBytes as number, checksum };
}

async function runChecks({ db, auth, issuer }: IssueFileBackend, uid: string | undefined, data: unknown): Promise<IssueFileGrant> {
  const input = isObject(data) ? data : {};
  const issueId = isDocumentId(input.issue_id) ? input.issue_id : null;

  // 0. A deleted issue answers GONE to anyone, before sign-in. The list is public (GS-Q25).
  if (issueId !== null && (await db.collection('deleted_issues').doc(issueId).get()).exists) throw gone();

  // 1. The caller is signed in.
  if (!uid) throw unauthenticated();

  // OP-11 lists no INVALID_ARGUMENT. Its place here is PROPOSED (spike note 07).
  const invalid = unknownFields(input, FIELDS);
  if (issueId === null) invalid.push('issue_id');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  // 2. The account is active and not being deleted. A registered reader may have no account record yet,
  // because OP-10 creates it, so a missing record is not a closed account.
  const [providerUser, user] = await Promise.all([
    auth.getUser(uid).catch((error: { code?: string }) => {
      if (error.code === 'auth/user-not-found') return null;
      throw error;
    }),
    db.doc(`users/${uid}`).get(),
  ]);
  if (!providerUser || providerUser.disabled || (user.exists && user.get('status') !== 'active')) throw accountClosed();

  // 3. The email is verified. Read from the provider on this call, never from a token claim. Nothing
  // here depends on the sign-in method, so a Google account passes only if the provider reports it
  // verified. Whether that is the right rule is OQ-04, and only password accounts are tested.
  if (providerUser.emailVerified !== true) throw emailNotVerified();

  // 4. The profile is complete, only when the gate is on. Computed, not stored (INV-10).
  const config = parsePrivateConfig(await db.doc('config/private').get());
  if (config.profileGateEnabled) {
    const [publicConfig, profile] = await Promise.all([
      db.doc('config/public').get(),
      db.doc(`users/${uid}/profile/current`).get(),
    ]);
    if (!isProfileComplete(profile.data(), parsePublicConfig(publicConfig.data()).requiredFields)) throw profileIncomplete();
  }

  // 5. The issue exists and is published. The same answer for both, so it does not show which is true.
  const issue = await db.collection('issues').doc(issueId as string).get();
  if (!issue.exists || issue.get('publication_state') !== 'published') throw issueNotAvailable();

  // 6. A current file revision exists.
  const revision: unknown = issue.get('current_revision');
  const file = Number.isInteger(revision) ? await issue.ref.collection('files').doc(String(revision)).get() : null;
  if (!file?.exists || file.get('status') !== 'current') throw noCurrentFile();

  const facts = parseFileFacts(file);
  const link = await issuer.issue({ storagePath: facts.storagePath, lifetimeSeconds: config.lifetimeSeconds });

  // The storage path stays on the server (SC-07). A new link each call, and none of it is kept.
  return {
    url: link.url,
    expires_at: link.expiresAtMillis,
    revision: revision as number,
    size_bytes: facts.sizeBytes,
    checksum_sha256: facts.checksum,
  };
}

// An error from a dependency may carry a link or a path, so its text goes nowhere. Only the outcome is
// logged, and anything unexpected is refused (SC-03, SC-16).
export async function releaseIssueFile(backend: IssueFileBackend, uid: string | undefined, data: unknown): Promise<IssueFileGrant> {
  const caller = uid ?? 'none';
  try {
    const grant = await runChecks(backend, uid, data);
    logOperation({ operation: OPERATION, caller, outcome: 'OK' });
    return grant;
  } catch (error) {
    if (error instanceof HttpsError) {
      const details = error.details as { reason?: string } | undefined;
      logOperation({ operation: OPERATION, caller, outcome: details?.reason ?? error.code });
      throw error;
    }
    logOperation({ operation: OPERATION, caller, outcome: 'internal' });
    throw cannotVerify();
  }
}

export const getIssueFile = onCall((request) =>
  releaseIssueFile({ db: getFirestore(), auth: getAuth(), issuer: grantIssuer() }, request.auth?.uid, request.data),
);
