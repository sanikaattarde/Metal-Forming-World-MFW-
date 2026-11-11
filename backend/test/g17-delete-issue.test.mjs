// Group G17: OP-30 deleteIssue through the emulators, and the deleted-issue record that OP-03 lists
// (FR-ADMIN-012, INV-14, INV-15, GS-Q45, DEC-033, MOD13-P1-T05). PROVISIONAL (OQ-21, OQ-11). Generated files
// only. Emulator only.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc } from 'firebase/firestore';
import { removeIssueRemains } from '../functions/dist/issueDeletion.js';
import { adminBackend, adminBucket, callFunction, clearAuthAccounts, newTestEnv, signUp, verifyEmail } from './helpers.mjs';

const NOW = new Date('2026-11-11T10:00:00Z');
// No file is seeded in the holding area: the upload trigger (OP-40) deletes any file there that no real job
// expects, so the test could not tell which step removed it. G10 covers the holding area.
const FILES = ['issues/i-del/1.pdf', 'issues/i-del/2.pdf', 'covers/i-del/v1'];
const KEPT = ['issues/i-keep/1.pdf', 'covers/i-keep/v1'];

let env;
let db;
let bucket;
let admin;
let reader;
let counter = 0;

before(async () => {
  env = await newTestEnv();
  db = adminBackend().db;
  bucket = adminBucket();
});

after(async () => {
  await env.cleanup();
});

const exists = async (path) => (await bucket.file(path).exists())[0];

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  await bucket.deleteFiles({ force: true }).catch(() => undefined);
  admin = await signUp('admin-a@example.test');
  reader = await signUp('reader@example.test');
  await verifyEmail(admin.uid);
  await db.doc(`admin_roles/${admin.uid}`).set({ user_id: admin.uid, is_active: true, granted_by: 'test-seed', granted_at: NOW });
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 1, version: 1, updated_at: NOW });

  for (const id of ['i-del', 'i-keep']) {
    await db.doc(`issues/${id}`).set({ issue_id: id, title: id === 'i-del' ? 'October 2026' : 'Kept', publication_state: 'unpublished', segment_ids: ['s1'], current_revision: 1 });
    await db.doc(`issues/${id}/files/1`).set({ issue_id: id, revision: 1, storage_path: `issues/${id}/1.pdf`, status: 'current' });
  }
  await db.doc('issues/i-del/files/2').set({ issue_id: 'i-del', revision: 2, storage_path: 'issues/i-del/2.pdf', status: 'superseded' });
  await db.doc('upload_jobs/job-del').set({ job_id: 'job-del', issue_id: 'i-del', status: 'pending' });
  await db.doc('upload_jobs/job-keep').set({ job_id: 'job-keep', issue_id: 'i-keep', status: 'accepted' });
  for (const path of [...FILES, ...KEPT]) await bucket.file(path).save('control-bytes', { resumable: false });
});

const remove = (over = {}, token = admin.idToken) =>
  callFunction('deleteIssue', { request_id: `request-${(counter += 1)}`, issue_id: 'i-del', confirmation: 'October 2026', ...over }, token);

const assertRefused = (reply, status, reason) => {
  assert.equal(reply.error?.status, status, reply.raw);
  if (reason) assert.equal(reply.error.details?.reason, reason, reply.raw);
};

const unchanged = async () => {
  assert.equal((await db.doc('issues/i-del').get()).exists, true);
  assert.equal((await db.doc('deleted_issues/i-del').get()).exists, false);
  for (const path of FILES) assert.equal(await exists(path), true, path);
};

test('G17 OP-30: an unpublished issue whose title is typed is deleted, with its files, cover and jobs', async () => {
  const reply = await remove();
  assert.equal(reply.status, 200, reply.raw);
  assert.deepEqual(reply.result, { issue_id: 'i-del', deleted: true });
  assert.equal((await db.doc('issues/i-del').get()).exists, false);
  assert.equal((await db.collection('issues/i-del/files').get()).size, 0);
  assert.equal((await db.doc('upload_jobs/job-del').get()).exists, false);
  for (const path of FILES) assert.equal(await exists(path), false, path);
});

test('G17 the other issues keep everything', async () => {
  await remove();
  assert.equal((await db.doc('issues/i-keep').get()).exists, true);
  assert.equal((await db.doc('issues/i-keep/files/1').get()).exists, true);
  assert.equal((await db.doc('upload_jobs/job-keep').get()).exists, true);
  for (const path of KEPT) assert.equal(await exists(path), true, path);
});

test('G17 OP-03 DATA-013: the deleted-issue record holds the identifier and the time only, and anyone reads it', async () => {
  await remove();
  const record = await db.doc('deleted_issues/i-del').get();
  assert.deepEqual(Object.keys(record.data()).sort(), ['deleted_at', 'issue_id']);
  assert.equal(record.get('issue_id'), 'i-del');
  assert.doesNotMatch(JSON.stringify(record.data()), new RegExp(`${admin.uid}|October`));
  const visitor = env.unauthenticatedContext().firestore();
  const snap = await assertSucceeds(getDoc(doc(visitor, 'deleted_issues/i-del')));
  assert.equal(snap.get('issue_id'), 'i-del');
});

test('G17 a repeat of the same request returns the first result; a new request is GONE (INV-14)', async () => {
  const requestId = 'same-request';
  const first = await remove({ request_id: requestId });
  assert.deepEqual((await remove({ request_id: requestId })).result, first.result);
  assertRefused(await remove(), 'NOT_FOUND', 'GONE');
});

test('G17 INV-15: a published issue is NOT_UNPUBLISHED, and nothing changes', async () => {
  await db.doc('issues/i-del').update({ publication_state: 'published' });
  assertRefused(await remove(), 'FAILED_PRECONDITION', 'NOT_UNPUBLISHED');
  await unchanged();
});

for (const typed of ['october 2026', 'October', '', 'i-del']) {
  test(`G17 a confirmation of ${JSON.stringify(typed)} is CONFIRMATION_MISMATCH, and nothing changes`, async () => {
    assertRefused(await remove({ confirmation: typed }), 'FAILED_PRECONDITION', 'CONFIRMATION_MISMATCH');
    await unchanged();
  });
}

test('G17 spaces around the typed title do not count', async () => {
  assert.equal((await remove({ confirmation: '  October 2026 ' })).status, 200);
});

test('G17 a missing issue is NOT_FOUND', async () => {
  assertRefused(await remove({ issue_id: 'i-none' }), 'NOT_FOUND');
});

for (const [name, over, fields] of [
  ['no request identifier', { request_id: '' }, ['request_id']],
  ['an issue identifier that is a path', { issue_id: 'a/b' }, ['issue_id']],
  ['no confirmation', { confirmation: undefined }, ['confirmation']],
  ['an unknown field', { force: true }, ['force']],
]) {
  test(`G17 ${name} is INVALID_ARGUMENT`, async () => {
    const data = { request_id: 'r', issue_id: 'i-del', confirmation: 'October 2026', ...over };
    if (over.confirmation === undefined && 'confirmation' in over) delete data.confirmation;
    const reply = await callFunction('deleteIssue', data, admin.idToken);
    assertRefused(reply, 'INVALID_ARGUMENT');
    assert.deepEqual(reply.error.details.fields, fields);
    await unchanged();
  });
}

test('G17 a reader cannot delete, and a visitor must sign in', async () => {
  assertRefused(await remove({}, reader.idToken), 'PERMISSION_DENIED');
  assertRefused(await remove({}, null), 'UNAUTHENTICATED');
  await unchanged();
});

test('G17 the remains task is safe to run again on an issue already cleared', async () => {
  await remove();
  await removeIssueRemains({ db, bucket }, 'i-del');
  for (const path of KEPT) assert.equal(await exists(path), true, path);
});
