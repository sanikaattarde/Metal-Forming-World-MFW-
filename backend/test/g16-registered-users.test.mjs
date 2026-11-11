// Group G16: OP-31 listRegisteredUsers and OP-32 exportRegisteredUsers through the emulators (FR-USER-002,
// FR-USER-003, NFR-PRIV-004, PAC-03, SEC-CHK-12). PROVISIONAL (OQ-29, OQ-31, OQ-51). Synthetic accounts only.
// Emulator only.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { adminBackend, callFunction, clearAuthAccounts, newTestEnv, signUp, verifyEmail } from './helpers.mjs';

const NOW = new Date('2026-11-11T10:00:00Z');
const ROW_FIELDS = ['age_value', 'created_at', 'email', 'full_name', 'gender', 'industry_segment_id', 'job_title', 'user_id'];

let env;
let db;
let admin;
let readers;

before(async () => {
  env = await newTestEnv();
  db = adminBackend().db;
});

after(async () => {
  await env.cleanup();
});

const addReader = async (email, minutes, profile = {}, status = 'active') => {
  const account = await signUp(email);
  await db.doc(`users/${account.uid}`).set({ user_id: account.uid, status, created_at: new Date(NOW.getTime() + minutes * 60_000) });
  await db.doc(`users/${account.uid}/profile/current`).set({
    user_id: account.uid,
    full_name: `Name of ${email.split('@')[0]}`,
    age_value: 30 + minutes,
    gender: 'Prefer not to say',
    job_title: 'Engineer',
    industry_segment_id: 's1',
    ...profile,
  });
  return account;
};

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  admin = await signUp('admin-a@example.test');
  await verifyEmail(admin.uid);
  await db.doc(`admin_roles/${admin.uid}`).set({ user_id: admin.uid, is_active: true, granted_by: 'test-seed', granted_at: NOW });
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 1, version: 1, updated_at: NOW });
  await db.doc('segments/s1').set({ name: 'Forging' });
  readers = [await addReader('reader-1@example.test', 1), await addReader('reader-2@example.test', 2), await addReader('reader-3@example.test', 3)];
  await addReader('leaving@example.test', 4, {}, 'deleting');
});

const list = (data = {}, token = admin.idToken) => callFunction('listRegisteredUsers', data, token);
const exportCsv = (data = {}, token = admin.idToken) => callFunction('exportRegisteredUsers', data, token);

test('G16 OP-31: newest first, paged by a cursor, with the email from the provider and the profile fields only', async () => {
  const first = await list({ page_size: 2 });
  assert.equal(first.status, 200, first.raw);
  assert.deepEqual(first.result.items.map((row) => row.email), ['reader-3@example.test', 'reader-2@example.test']);
  assert.deepEqual(Object.keys(first.result.items[0]).sort(), ROW_FIELDS);
  assert.equal(first.result.items[0].full_name, 'Name of reader-3');
  assert.equal(first.result.items[0].age_value, 33);
  assert.equal(first.result.next_cursor, readers[1].uid);

  const second = await list({ page_size: 2, cursor: first.result.next_cursor });
  assert.deepEqual(second.result.items.map((row) => row.email), ['reader-1@example.test']);
  assert.equal(second.result.next_cursor, null);
});

test('G16 OP-31: an account being deleted is hidden, and is no cursor either', async () => {
  const all = (await list()).result.items.map((row) => row.email);
  assert.ok(!all.includes('leaving@example.test'));
  const leaving = (await db.collection('users').where('status', '==', 'deleting').get()).docs[0].id;
  assert.deepEqual((await list({ cursor: leaving })).error.details.fields, ['cursor']);
});

test('G16 OP-31: a missing profile field is null, not left out', async () => {
  await db.doc(`users/${readers[0].uid}/profile/current`).set({ user_id: readers[0].uid, full_name: 'Only a name' });
  const row = (await list()).result.items.find((item) => item.user_id === readers[0].uid);
  assert.deepEqual(Object.keys(row).sort(), ROW_FIELDS);
  assert.equal(row.job_title, null);
});

for (const [name, data, fields] of [
  ['a page size of 0', { page_size: 0 }, ['page_size']],
  ['a page size over the limit', { page_size: 101 }, ['page_size']],
  ['a cursor that is a path', { cursor: 'a/b' }, ['cursor']],
  ['an unknown field', { email: 'x' }, ['email']],
]) {
  test(`G16 OP-31: ${name} is INVALID_ARGUMENT`, async () => {
    const reply = await list(data);
    assert.equal(reply.error?.status, 'INVALID_ARGUMENT', reply.raw);
    assert.deepEqual(reply.error.details.fields, fields);
  });
}

test('G16 PAC-03: a reader cannot list or export, and a visitor must sign in', async () => {
  for (const call of [list, exportCsv]) {
    assert.equal((await call({}, readers[0].idToken)).error?.status, 'PERMISSION_DENIED');
    assert.equal((await call({}, null)).error?.status, 'UNAUTHENTICATED');
  }
});

test('G16 OP-32: the export has a header and one line per active reader, newest first, with the segment name', async () => {
  const reply = await exportCsv();
  assert.equal(reply.status, 200, reply.raw);
  assert.equal(reply.result.row_count, 3);
  assert.match(reply.result.file_name, /^registered-users-\d{4}-\d{2}-\d{2}\.csv$/);
  const lines = reply.result.csv.split('\r\n');
  assert.equal(lines[0], 'Email,Full name,Age,Gender,Occupation,Domain of work,Registered (GMT)');
  assert.deepEqual(lines.slice(1, 4).map((line) => line.split(',')[0]), ['reader-3@example.test', 'reader-2@example.test', 'reader-1@example.test']);
  assert.equal(lines[1].split(',')[5], 'Forging');
  assert.equal(lines.at(-1), '');
  assert.doesNotMatch(reply.result.csv, /leaving@example\.test/);
});

test('G16 SEC-CHK-12: formula cells from a reader\'s profile are neutralised in the export', async () => {
  await db.doc(`users/${readers[0].uid}/profile/current`).update({ full_name: '=HYPERLINK("https://evil.example.test","x")', job_title: '+cmd' });
  const csv = (await exportCsv()).result.csv;
  assert.match(csv, /"'=HYPERLINK\(""https:\/\/evil\.example\.test"",""x""\)"/);
  assert.match(csv, /,'\+cmd,/);
});

test('G16 OP-32: the export takes no input', async () => {
  const reply = await exportCsv({ columns: ['email'] });
  assert.equal(reply.error?.status, 'INVALID_ARGUMENT');
  assert.deepEqual(reply.error.details.fields, ['columns']);
});

test('G16 OP-32: nothing is stored by the export', async () => {
  const before = (await db.listCollections()).map((c) => c.id).sort();
  await exportCsv();
  assert.deepEqual((await db.listCollections()).map((c) => c.id).sort(), before);
});
