// A server log line that cannot carry a signed link or a token (SC-16,
// API_AND_BACKEND_CONTRACT.md section 2.8: the operation name, the caller's identifier and the outcome
// category). The full logging work is MOD02-P2-T03. This covers only what getIssueFile needs.
import * as logger from 'firebase-functions/logger';

const ALLOWED = new Set(['operation', 'caller', 'outcome']);

// A value that holds an address, or that is too long to be a name, an identifier or an outcome.
const MAX_VALUE_LENGTH = 128;
const LOOKS_LIKE_A_CREDENTIAL = /:\/\/|signature|token=|^ey[\w-]+\./i;

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

export function logOperation(input: Record<string, unknown>): void {
  const { fields, refused } = cleanLogFields(input);
  logger.info('operation', refused.length > 0 ? { ...fields, refused_fields: refused } : fields);
}
