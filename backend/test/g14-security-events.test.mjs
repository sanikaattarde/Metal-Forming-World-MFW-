// Group G14: the server security events from the real operations (MOD02-P2-T03, SEC-CHK-10, SC-16), run in
// this process against the emulators so that their log lines can be read back. Emulator only.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { requestAccountDeletion } from '../functions/dist/accountDeletion.js';
import { saveCategory } from '../functions/dist/categories.js';
import { getMyAdminRole } from '../functions/dist/getMyAdminRole.js';
import { releaseIssueFile } from '../functions/dist/issueFile.js';
import { saveProfile } from '../functions/dist/saveProfile.js';
import { onUploadFinalized } from '../functions/dist/uploadFinalized.js';
import { adminBackend, adminBucket, clearAuthAccounts, disableAccount, newTestEnv, signUp, TRIGGER_BUCKET, verifyEmail } from './helpers.mjs';

let env;
let backend;
let db;
let admin;
let otherAdmin;
let reader;

const SECRET_LINK = 'https://secret.example.test/file?X-Goog-Signature=abc';

// The logger's lines for the run, parsed, with the raw text for checks of what is absent.
async function logOf(run) {
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
  const raw = chunks.join('');
  const lines = raw
    .split('\n')
    .filter((line) => line.includes('"message":"operation"'))
    .map((line) => JSON.parse(line));
  return { raw, events: lines.filter((line) => line.event).map(({ event, operation, caller, outcome, severity }) => ({ event, operation, caller, outcome, severity })) };
}

const callAs = (fn, uid, data) => fn.run({ auth: uid ? { uid, token: {} } : undefined, data, rawRequest: {} });

before(async () => {
  env = await newTestEnv();
  backend = adminBackend();
  db = backend.db;
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  admin = await signUp('admin@example.test');
  otherAdmin = await signUp('other-admin@example.test');
  reader = await signUp('reader@example.test');
  for (const account of [admin, otherAdmin, reader]) await verifyEmail(account.uid);
  for (const account of [admin, otherAdmin]) {
    await db.doc(`admin_roles/${account.uid}`).set({ user_id: account.uid, is_active: true, granted_by: 'test-seed', granted_at: new Date() });
  }
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 2, version: 1, updated_at: new Date() });
});

test('G14 a reader calling an admin operation is an access_refused warning, with no input in the log', async () => {
  const { raw, events } = await logOf(() => assert.rejects(callAs(saveCategory, reader.uid, { request_id: 'r1', name: 'Secret category name' })));
  assert.deepEqual(events, [{ event: 'access_refused', operation: 'saveCategory', caller: reader.uid, outcome: 'permission-denied', severity: 'WARNING' }]);
  assert.equal(raw.includes('Secret category name'), false);
  assert.equal(raw.includes('example.test'), false);
});

test('G14 a signed-out call is logged with no caller', async () => {
  const { events } = await logOf(() => assert.rejects(callAs(saveCategory, undefined, {})));
  assert.deepEqual(events, [{ event: 'access_refused', operation: 'saveCategory', caller: 'none', outcome: 'unauthenticated', severity: 'WARNING' }]);
});

test('G14 an admin whose email is no longer verified is refused and logged (OQ-20)', async () => {
  await verifyEmail(admin.uid, false);
  const { events } = await logOf(() => assert.rejects(callAs(saveCategory, admin.uid, { request_id: 'r1', name: 'A' })));
  assert.equal(events[0].outcome, 'EMAIL_NOT_VERIFIED');
});

test('G14 an admin\'s refused input is not a security event, and an allowed call logs nothing here', async () => {
  const bad = await logOf(() => assert.rejects(callAs(saveCategory, admin.uid, { request_id: 'r1' })));
  assert.deepEqual(bad.events, []);
  const good = await logOf(() => callAs(saveCategory, admin.uid, { request_id: 'r2', name: 'Presses', display_order: 1 }));
  assert.deepEqual(good.events, []);
});

test('G14 OP-14 and OP-10 log a closed account', async () => {
  await disableAccount(reader.uid);
  const role = await logOf(() => assert.rejects(callAs(getMyAdminRole, reader.uid, {})));
  assert.deepEqual(role.events.map((e) => [e.operation, e.outcome]), [['getMyAdminRole', 'ACCOUNT_CLOSED']]);
  const profile = await logOf(() => assert.rejects(callAs(saveProfile, reader.uid, { request_id: 'r1', profile: { full_name: 'Private Name' } })));
  assert.deepEqual(profile.events.map((e) => [e.operation, e.outcome]), [['saveProfile', 'ACCOUNT_CLOSED']]);
  assert.equal(profile.raw.includes('Private Name'), false);
});

test('G14 a file link given out is grant_issued, and the link is not in the log', async () => {
  await db.doc('config/private').set({ profile_gate_enabled: false, signed_url_lifetime: 600 });
  await db.doc('issues/i-pub').set({ issue_id: 'i-pub', publication_state: 'published', current_revision: 1 });
  await db.doc('issues/i-pub/files/1').set({ storage_path: 'issues/i-pub/1.pdf', status: 'current', size_bytes: 10, checksum_sha256: 'a'.repeat(64) });
  const issuer = { issue: async () => ({ url: SECRET_LINK, expiresAtMillis: 1 }) };
  const { raw, events } = await logOf(() => releaseIssueFile({ ...backend, issuer }, reader.uid, { issue_id: 'i-pub' }));
  assert.deepEqual(events, [{ event: 'grant_issued', operation: 'getIssueFile', caller: reader.uid, outcome: 'OK', severity: 'INFO' }]);
  assert.equal(raw.includes('secret.example'), false);
  assert.equal(raw.includes('issues/i-pub/1.pdf'), false);
});

test('G14 an admin deleting their account gives account_deleted and admin_removed', async () => {
  const { events } = await logOf(() => callAs(requestAccountDeletion, admin.uid, { request_id: 'r1', confirm: true }));
  assert.deepEqual(
    events.map((e) => [e.event, e.operation, e.caller, e.outcome]).sort(),
    [
      ['account_deleted', 'requestAccountDeletion', admin.uid, 'deleted'],
      ['admin_removed', 'requestAccountDeletion', admin.uid, 'removed'],
    ],
  );
});

test('G14 a reader deleting their account gives account_deleted only', async () => {
  const { events } = await logOf(() => callAs(requestAccountDeletion, reader.uid, { request_id: 'r1', confirm: true }));
  assert.deepEqual(events.map((e) => e.event), ['account_deleted']);
});

test('G14 a file in the holding area with no pending job is upload_rejected, and is deleted', async () => {
  const bucket = adminBucket();
  await bucket.file('holding/no-such-job').save(Buffer.from('%PDF-1.4 not really'), { resumable: false, contentType: 'application/pdf' });
  const { events } = await logOf(() =>
    onUploadFinalized.run({ data: { name: 'holding/no-such-job', size: '19', bucket: TRIGGER_BUCKET, timeCreated: new Date().toISOString() } }),
  );
  assert.deepEqual(events.map((e) => [e.event, e.outcome, e.severity]), [['upload_rejected', 'NO_PENDING_JOB', 'WARNING']]);
  const [exists] = await bucket.file('holding/no-such-job').exists();
  assert.equal(exists, false);
});
