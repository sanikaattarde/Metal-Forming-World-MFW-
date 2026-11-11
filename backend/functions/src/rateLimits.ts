// Rate limits per class of operation (SC-18, SEC-CHK-19, API_AND_BACKEND_CONTRACT.md section 2.7, MOD13-P1-T07).
// The contract states a limit for each class and leaves the mechanism and the numbers OPEN (AOQ-10, GS-D17). This
// is the mechanism PROPOSED here: a counter per caller and class in a fixed window, kept in Firestore, so that it
// holds across function instances. App Check is not assumed (OQ-52). Every number below is a PLACEHOLDER for review,
// not a decided value.
//
// A call over its class's limit is refused with RATE_LIMITED (callable code resource-exhausted) and a retry-after
// in seconds, before anything else is read, so a refusal never shows whether the thing asked for exists. The
// counters hold a pseudonymous identifier and a count only, and are removed with the account (OP-12).
//
// Not covered here: sign-in, registration and password reset are limited by the identity provider itself, which
// is NOT VERIFIED (SC-21). Size limits are the per-operation checks: the upload size (CFG-05), the text lengths
// and the page sizes of each operation.
import type { Firestore } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { logSecurityEvent } from './safeLog.js';

// PLACEHOLDER. One window for every class.
export const PLACEHOLDER_WINDOW_SECONDS = 60;

// PLACEHOLDERS, proposed for review: calls per caller per window.
export const PLACEHOLDER_RATE_LIMITS = {
  reader_write: 20, // OP-10 saveProfile, OP-12 requestAccountDeletion
  issue_file: 30, // OP-11 getIssueFile: the cap on link requests per reader (an ASSUMPTION in SC-18)
  role_check: 60, // OP-14 getMyAdminRole, which any signed-in account may call
  admin_read: 300, // the admin lists
  admin_write: 120, // the admin changes and upload requests
  notification_send: 10, // OP-25, OP-26: each one reaches every reader who chose the category
  export: 5, // OP-32: a file of personal data
} as const;

export type RateClass = keyof typeof PLACEHOLDER_RATE_LIMITS;

export const RATE_CLASSES = Object.keys(PLACEHOLDER_RATE_LIMITS) as RateClass[];

// Every callable operation and its class. An operation with no class is refused (fail closed), and a test checks
// that each exported operation is here.
export const OPERATION_CLASSES: Record<string, RateClass> = {
  saveProfile: 'reader_write',
  requestAccountDeletion: 'reader_write',
  getIssueFile: 'issue_file',
  getMyAdminRole: 'role_check',
  listIssuesForAdmin: 'admin_read',
  listUploadJobs: 'admin_read',
  listWordPressPosts: 'admin_read',
  listNotificationSends: 'admin_read',
  listRegisteredUsers: 'admin_read',
  saveIssue: 'admin_write',
  publishIssue: 'admin_write',
  unpublishIssue: 'admin_write',
  deleteIssue: 'admin_write',
  saveCategory: 'admin_write',
  deleteCategory: 'admin_write',
  setNewsControl: 'admin_write',
  requestUpload: 'admin_write',
  sendNotification: 'notification_send',
  retryNotification: 'notification_send',
  exportRegisteredUsers: 'export',
};

export const counterId = (rateClass: RateClass, uid: string) => `${rateClass}__${uid}`;

export const rateLimited = (retryAfterSeconds: number) =>
  new HttpsError('resource-exhausted', 'Too many requests. Wait, then try again.', {
    reason: 'RATE_LIMITED',
    retry_after_seconds: retryAfterSeconds,
  });

// Counts one call by `uid` to `operation`, or refuses it. The count and the window are read and written in one
// transaction, so calls at the same moment cannot pass the limit together.
export async function enforceRate(db: Firestore, uid: string, operation: string, now: () => number = Date.now): Promise<void> {
  const rateClass = OPERATION_CLASSES[operation];
  if (!rateClass) throw new Error(`no rate class for ${operation}`);
  const limit = PLACEHOLDER_RATE_LIMITS[rateClass];
  const windowMs = PLACEHOLDER_WINDOW_SECONDS * 1000;
  const ref = db.collection('rate_limits').doc(counterId(rateClass, uid));

  const retryAfter = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const at = now();
    const start: unknown = snap.get('window_start');
    const count: unknown = snap.get('count');
    if (!snap.exists || typeof start !== 'number' || typeof count !== 'number' || at - start >= windowMs || at < start) {
      tx.set(ref, { rate_class: rateClass, user_id: uid, window_start: at, count: 1 });
      return null;
    }
    if (count >= limit) return Math.max(1, Math.ceil((start + windowMs - at) / 1000));
    tx.update(ref, { count: count + 1 });
    return null;
  });

  if (retryAfter !== null) {
    logSecurityEvent('rate_limited', { operation, caller: uid, outcome: 'RATE_LIMITED' });
    throw rateLimited(retryAfter);
  }
}

// The counters of an account, for its deletion (OP-12).
export async function removeCounters(db: Firestore, uid: string): Promise<void> {
  await Promise.all(RATE_CLASSES.map((rateClass) => db.collection('rate_limits').doc(counterId(rateClass, uid)).delete()));
}
