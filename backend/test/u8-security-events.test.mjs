// Unit tests of the server security events (MOD02-P2-T03, SEC-CHK-10, SC-16): the closed event list, the
// line each outcome gives, and that no email address, link, token or input value reaches the log. No database.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { accountClosed, emailNotVerified, forbidden, invalidArgument, unauthenticated } from '../functions/dist/errors.js';
import {
  cleanLogFields,
  logOperation,
  logSecurityEvent,
  logSecurityRefusals,
  outcomeOf,
  SECURITY_EVENTS,
  securityEventFor,
} from '../functions/dist/safeLog.js';

// The logger's lines for the run, parsed. Each is one JSON object.
async function logLines(run) {
  const chunks = [];
  const out = process.stdout.write;
  const err = process.stderr.write;
  process.stdout.write = (chunk) => chunks.push(String(chunk)) > 0;
  process.stderr.write = (chunk) => chunks.push(String(chunk)) > 0;
  try {
    await run();
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
  return chunks
    .join('')
    .split('\n')
    .filter((line) => line.includes('"operation"'))
    .map((line) => JSON.parse(line));
}

test('U8 the event list is closed and named', () => {
  assert.deepEqual([...SECURITY_EVENTS], ['access_refused', 'check_failed', 'grant_issued', 'account_deleted', 'admin_removed', 'upload_rejected', 'rate_limited']);
});

for (const [operation, outcome, event] of [
  ['saveCategory', 'unauthenticated', 'access_refused'],
  ['saveCategory', 'permission-denied', 'access_refused'],
  ['saveIssue', 'ACCOUNT_CLOSED', 'access_refused'],
  ['getMyAdminRole', 'EMAIL_NOT_VERIFIED', 'access_refused'],
  ['saveProfile', 'internal', 'check_failed'],
  ['getIssueFile', 'OK', 'grant_issued'],
  ['requestAccountDeletion', 'deleted', 'account_deleted'],
  ['requestAccountDeletion', 'deleting', 'account_deleted'],
  ['onUploadFinalized', 'NOT_A_PDF', 'upload_rejected'],
  ['onUploadFinalized', 'NO_PENDING_JOB', 'upload_rejected'],
  ['onUploadFinalized', 'ACCEPTED', null],
  ['getIssueFile', 'ISSUE_NOT_AVAILABLE', null],
  ['saveCategory', 'invalid-argument', null],
  ['listWordPressPosts', 'OK', null],
  ['listWordPressPosts', 'SITE_UNAVAILABLE', null],
]) {
  test(`U8 ${operation} with ${outcome} is ${event ?? 'not a security event'}`, () => {
    assert.equal(securityEventFor(operation, outcome), event);
  });
}

test('U8 a refusal or failure is a warning; a grant, a deletion and an ordinary outcome are information', async () => {
  const lines = await logLines(async () => {
    logOperation({ operation: 'saveIssue', caller: 'uid-1', outcome: 'permission-denied' });
    logOperation({ operation: 'getIssueFile', caller: 'uid-1', outcome: 'OK' });
    logOperation({ operation: 'onUploadFinalized', caller: 'uid-1', outcome: 'ACCEPTED' });
  });
  assert.deepEqual(
    lines.map(({ severity, event, operation, caller, outcome }) => ({ severity, event, operation, caller, outcome })),
    [
      { severity: 'WARNING', event: 'access_refused', operation: 'saveIssue', caller: 'uid-1', outcome: 'permission-denied' },
      { severity: 'INFO', event: 'grant_issued', operation: 'getIssueFile', caller: 'uid-1', outcome: 'OK' },
      { severity: 'INFO', event: undefined, operation: 'onUploadFinalized', caller: 'uid-1', outcome: 'ACCEPTED' },
    ],
  );
});

test('U8 a caller cannot supply the event, and an email address is never logged', async () => {
  const lines = await logLines(async () => {
    logOperation({ operation: 'saveIssue', caller: 'reader@example.test', outcome: 'OK', event: 'grant_issued' });
  });
  assert.equal(lines.length, 1);
  assert.equal(lines[0].event, undefined);
  assert.deepEqual(lines[0].refused_fields, ['caller', 'event']);
  assert.equal(JSON.stringify(lines).includes('example.test'), false);
  assert.deepEqual(cleanLogFields({ outcome: 'someone@example.test' }).refused, ['outcome']);
});

test('U8 logSecurityEvent logs a listed event, and drops an unlisted one', async () => {
  const lines = await logLines(async () => {
    logSecurityEvent('admin_removed', { operation: 'requestAccountDeletion', caller: 'uid-2', outcome: 'removed' });
    logSecurityEvent('made_up', { operation: 'x', caller: 'uid-2', outcome: 'y' });
  });
  assert.equal(lines[0].event, 'admin_removed');
  assert.equal(lines[0].severity, 'INFO');
  assert.equal(lines[1].event, undefined);
});

test('U8 the outcome of an error is its reason, else its code, else "internal" with no text', () => {
  assert.equal(outcomeOf(accountClosed()), 'ACCOUNT_CLOSED');
  assert.equal(outcomeOf(forbidden()), 'permission-denied');
  assert.equal(outcomeOf(new Error('https://secret.example.test/?token=abc')), 'internal');
});

test('U8 logSecurityRefusals logs a refused access, passes the error on, and logs nothing for bad input', async () => {
  const lines = await logLines(async () => {
    await assert.rejects(logSecurityRefusals('saveCategory', 'uid-3', async () => { throw emailNotVerified(); }), /verify/i);
    await assert.rejects(logSecurityRefusals('saveCategory', undefined, async () => { throw unauthenticated(); }));
    await assert.rejects(logSecurityRefusals('saveCategory', 'uid-3', async () => { throw invalidArgument(['name']); }));
    assert.equal(await logSecurityRefusals('saveCategory', 'uid-3', async () => 'done'), 'done');
  });
  assert.deepEqual(
    lines.map(({ event, caller, outcome }) => ({ event, caller, outcome })),
    [
      { event: 'access_refused', caller: 'uid-3', outcome: 'EMAIL_NOT_VERIFIED' },
      { event: 'access_refused', caller: 'none', outcome: 'unauthenticated' },
    ],
  );
});

test('U8 an unexpected error is logged as a failed check, without its text, and passed on unchanged', async () => {
  const secret = new Error('https://secret.example.test/link?signature=abc');
  let thrown;
  const lines = await logLines(async () => {
    thrown = await logSecurityRefusals('saveProfile', 'uid-4', async () => { throw secret; }).catch((error) => error);
  });
  assert.equal(thrown, secret);
  assert.equal(lines[0].event, 'check_failed');
  assert.equal(lines[0].severity, 'WARNING');
  assert.equal(JSON.stringify(lines).includes('secret.example'), false);
});
