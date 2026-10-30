// SPIKE (DEC-003 OPEN, DEC-026 PROPOSED). Shared refusals, from the category-plus-reason scheme in
// API_AND_BACKEND_CONTRACT.md section 2.5, mapped as section 11 proposes. The reason code travels in
// the error details. A refusal never repeats a value from the caller (SC-16).
import { HttpsError } from 'firebase-functions/v2/https';

export const unauthenticated = () => new HttpsError('unauthenticated', 'Sign-in is required.');

export const forbidden = () => new HttpsError('permission-denied', 'You do not have access to this.');

export const accountClosed = () =>
  new HttpsError('failed-precondition', 'This account is closed.', { reason: 'ACCOUNT_CLOSED' });

export const lastAdmin = () =>
  new HttpsError('failed-precondition', 'At least one active admin must remain.', { reason: 'LAST_ADMIN' });

export const notAnAdmin = () =>
  new HttpsError('failed-precondition', 'That account is not an active admin.', { reason: 'NOT_AN_ADMIN' });

// The caller's authorisation could not be verified, or a needed record is unusable. Fail closed (SC-03).
export const cannotVerify = () =>
  new HttpsError('internal', 'The request could not be completed. Nothing was changed.');
