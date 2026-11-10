// Shared refusals, from the category-plus-reason scheme in
// API_AND_BACKEND_CONTRACT.md section 2.5, mapped as section 11 proposes. The reason code travels in
// the error details. A refusal never repeats a value from the caller (SC-16).
//
// Section 11 lists no callable code for CONFLICT, so `aborted` is PROPOSED.
import { HttpsError } from 'firebase-functions/v2/https';

export const unauthenticated = () => new HttpsError('unauthenticated', 'Sign-in is required.');

export const forbidden = () => new HttpsError('permission-denied', 'You do not have access to this.');

export const invalidArgument = (fields: string[]) =>
  new HttpsError('invalid-argument', 'One or more values are missing or not valid.', { fields });

export const notFound = () => new HttpsError('not-found', 'That record does not exist.');

export const gone = () =>
  new HttpsError('not-found', 'That record was permanently deleted.', { reason: 'GONE' });

export const staleRecord = () =>
  new HttpsError('aborted', 'The record has changed since it was opened.', { reason: 'STALE_RECORD' });

export const nameTaken = () =>
  new HttpsError('aborted', 'Another record already has that name.', { reason: 'NAME_TAKEN' });

export const inUse = () =>
  new HttpsError('failed-precondition', 'That record is in use.', { reason: 'IN_USE' });

export const noAcceptedFile = () =>
  new HttpsError('failed-precondition', 'That issue has no accepted file.', { reason: 'NO_ACCEPTED_FILE' });

export const accountClosed = () =>
  new HttpsError('failed-precondition', 'This account is closed.', { reason: 'ACCOUNT_CLOSED' });

export const emailNotVerified = () =>
  new HttpsError('failed-precondition', 'Verify your email address to continue.', { reason: 'EMAIL_NOT_VERIFIED' });

export const profileIncomplete = () =>
  new HttpsError('failed-precondition', 'Complete your profile to continue.', { reason: 'PROFILE_INCOMPLETE' });

export const issueNotAvailable = () =>
  new HttpsError('failed-precondition', 'That issue is not available.', { reason: 'ISSUE_NOT_AVAILABLE' });

export const noCurrentFile = () =>
  new HttpsError('failed-precondition', 'That issue has no file to open.', { reason: 'NO_CURRENT_FILE' });

export const alreadyDeleting = () =>
  new HttpsError('failed-precondition', 'This account is already being deleted.', { reason: 'ALREADY_DELETING' });

export const lastAdmin = () =>
  new HttpsError('failed-precondition', 'At least one active admin must remain.', { reason: 'LAST_ADMIN' });

export const notAnAdmin = () =>
  new HttpsError('failed-precondition', 'That account is not an active admin.', { reason: 'NOT_AN_ADMIN' });

// OP-24: the WordPress site could not be reached or read (API_AND_BACKEND_CONTRACT.md section 5.1).
export const siteUnavailable = () =>
  new HttpsError('unavailable', 'The news site could not be reached.', { reason: 'SITE_UNAVAILABLE' });

// The caller's authorisation could not be verified, or a needed record is unusable. Fail closed (SC-03).
export const cannotVerify = () =>
  new HttpsError('internal', 'The request could not be completed. Nothing was changed.');
