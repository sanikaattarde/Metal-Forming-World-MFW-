// The server log: one line per operation outcome that cannot carry a signed link, a token, an email
// address or an input value (SC-16, SEC-CHK-10; API_AND_BACKEND_CONTRACT.md section 2.8: the operation name,
// the caller's identifier and the outcome category). The caller's identifier is pseudonymous (finding E-9).
//
// Server security events (MOD02-P2-T03) are a closed list. A line that is one carries `event`, derived
// here from the operation and the outcome, never supplied by the caller, and is a warning when something
// was refused or failed.
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';

const ALLOWED = new Set(['operation', 'caller', 'outcome']);

// A value that holds an address, an email address, or that is too long to be a name, an identifier or
// an outcome.
const MAX_VALUE_LENGTH = 128;
const LOOKS_LIKE_A_CREDENTIAL = /:\/\/|signature|token=|^ey[\w-]+\.|@/i;

const isLoggable = (value: unknown): value is string =>
  typeof value === 'string' && value.length <= MAX_VALUE_LENGTH && !LOOKS_LIKE_A_CREDENTIAL.test(value);

export interface CleanedLog {
  fields: Record<string, string>;
  refused: string[]; // field names only, never the values
}

export function cleanLogFields(input: Record<string, unknown>): CleanedLog {
  const fields: Record<string, string> = {};
  const refused: string[] = [];
  for (const [name, value] of Object.entries(input)) {
    if (ALLOWED.has(name) && isLoggable(value)) fields[name] = value;
    else refused.push(name);
  }
  return { fields, refused: refused.sort() };
}

export const SECURITY_EVENTS = [
  'access_refused', // not signed in, not an admin, a closed account or an unverified email
  'check_failed', // a check could not be made, so the call was refused (SC-03)
  'grant_issued', // a signed link to an issue file was given out (OP-11)
  'account_deleted', // a reader deleted their account (OP-12)
  'admin_removed', // an admin left the count (INV-03)
  'upload_rejected', // a file in the holding area was refused and deleted (OP-40, SEC-CHK-07)
  'rate_limited', // a call over its class's limit was refused (SC-18, MOD13-P1-T07)
] as const;

export type SecurityEvent = (typeof SECURITY_EVENTS)[number];

const WARNINGS = new Set<SecurityEvent>(['access_refused', 'check_failed', 'upload_rejected', 'rate_limited']);
const ACCESS_REFUSALS = new Set(['unauthenticated', 'permission-denied', 'ACCOUNT_CLOSED', 'EMAIL_NOT_VERIFIED']);
const UPLOAD_REJECTIONS = new Set(['NOT_A_PDF', 'OVER_LIMIT', 'UPLOADER_NOT_AUTHORISED', 'ISSUE_NOT_FOUND', 'NO_PENDING_JOB']);

// Which security event an operation's outcome is, if any. Ordinary refusals of the input are not events.
export function securityEventFor(operation: string | undefined, outcome: string | undefined): SecurityEvent | null {
  if (outcome === undefined) return null;
  if (ACCESS_REFUSALS.has(outcome)) return 'access_refused';
  if (outcome === 'internal') return 'check_failed';
  if (operation === 'getIssueFile' && outcome === 'OK') return 'grant_issued';
  if (operation === 'requestAccountDeletion' && (outcome === 'deleted' || outcome === 'deleting')) return 'account_deleted';
  if (operation === 'onUploadFinalized' && UPLOAD_REJECTIONS.has(outcome)) return 'upload_rejected';
  return null;
}

function write(event: SecurityEvent | null, fields: Record<string, string>, refused: string[]): void {
  const line = { ...fields, ...(event ? { event } : {}), ...(refused.length > 0 ? { refused_fields: refused } : {}) };
  if (event !== null && WARNINGS.has(event)) logger.warn('operation', line);
  else logger.info('operation', line);
}

export function logOperation(input: Record<string, unknown>): void {
  const { fields, refused } = cleanLogFields(input);
  write(securityEventFor(fields.operation, fields.outcome), fields, refused);
}

// An event the outcome alone does not show, such as an admin leaving the count during a deletion.
export function logSecurityEvent(event: SecurityEvent, input: Record<string, unknown>): void {
  const { fields, refused } = cleanLogFields(input);
  write((SECURITY_EVENTS as readonly string[]).includes(event) ? event : null, fields, refused);
}

// The outcome category of an error: the reason when there is one, the code otherwise, and "internal" for
// anything that is not a refusal, whose text is never logged.
export function outcomeOf(error: unknown): string {
  if (!(error instanceof HttpsError)) return 'internal';
  const details = error.details as { reason?: unknown } | undefined;
  return typeof details?.reason === 'string' ? details.reason : error.code;
}

// Runs an operation and logs its refusal when the refusal is a security event (access refused, a check
// failed). Other refusals, about the input, are not logged.
export async function logSecurityRefusals<T>(operation: string, caller: string | undefined, run: () => Promise<T>): Promise<T> {
  try {
    return await run();
  } catch (error) {
    const outcome = outcomeOf(error);
    if (securityEventFor(operation, outcome) !== null) logOperation({ operation, caller: caller ?? 'none', outcome });
    throw error;
  }
}
