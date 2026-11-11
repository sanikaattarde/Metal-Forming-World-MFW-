// Group G18: the rate limits of MOD13-P1-T07 (SC-18, SEC-CHK-19, ST-18) through the emulators. The numbers are
// PLACEHOLDERS, so a test puts a counter at its limit instead of making that many calls. Emulator only.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import * as operations from '../functions/dist/index.js';
import { counterId, enforceRate, OPERATION_CLASSES, PLACEHOLDER_RATE_LIMITS, PLACEHOLDER_WINDOW_SECONDS, RATE_CLASSES } from '../functions/dist/rateLimits.js';
import { adminBackend, callFunction, clearAuthAccounts, newTestEnv, signUp, verifyEmail } from './helpers.mjs';

const NOW = new Date('2026-11-11T10:00:00Z');

let env;
let db;
let admin;
let reader;

before(async () => {
  env = await newTestEnv();
  db = adminBackend().db;
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  admin = await signUp('admin-a@example.test');
  reader = await signUp('reader@example.test');
  await verifyEmail(admin.uid);
  await verifyEmail(reader.uid);
  await db.doc(`admin_roles/${admin.uid}`).set({ user_id: admin.uid, is_active: true, granted_by: 'test-seed', granted_at: NOW });
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 1, version: 1, updated_at: NOW });
});

const counter = (rateClass, uid) => db.doc(`rate_limits/${counterId(rateClass, uid)}`);
const atLimit = (rateClass, uid, startedAgoMs = 1000) =>
  counter(rateClass, uid).set({ rate_class: rateClass, user_id: uid, window_start: Date.now() - startedAgoMs, count: PLACEHOLDER_RATE_LIMITS[rateClass] });

const assertLimited = (reply) => {
  assert.equal(reply.error?.status, 'RESOURCE_EXHAUSTED', reply.raw);
  assert.equal(reply.error.details.reason, 'RATE_LIMITED');
  const after = reply.error.details.retry_after_seconds;
  assert.ok(Number.isInteger(after) && after >= 1 && after <= PLACEHOLDER_WINDOW_SECONDS, String(after));
};

test('G18 every callable operation has a rate class, and every class has a limit', () => {
  const callables = Object.keys(operations).filter((name) => name !== 'onUploadFinalized');
  assert.deepEqual(callables.filter((name) => !(name in OPERATION_CLASSES)), []);
  assert.deepEqual(Object.keys(OPERATION_CLASSES).filter((name) => !callables.includes(name)), []);
  for (const rateClass of RATE_CLASSES) assert.ok(PLACEHOLDER_RATE_LIMITS[rateClass] > 0, rateClass);
});

test('G18 an admin write over the limit is RATE_LIMITED, and nothing is written', async () => {
  await atLimit('admin_write', admin.uid);
  assertLimited(await callFunction('saveCategory', { request_id: 'r1', name: 'New', display_order: 1 }, admin.idToken));
  assert.equal((await db.collection('categories').get()).size, 0);
});

test('G18 a notification send over the limit is RATE_LIMITED, and no send record is made', async () => {
  await atLimit('notification_send', admin.uid);
  assertLimited(await callFunction('sendNotification', { request_id: 'r1', category_id: 'c', title: 't', body: 'b', target_type: 'none' }, admin.idToken));
  assert.equal((await db.collection('notification_sends').get()).size, 0);
});

test('G18 the export over the limit is RATE_LIMITED', async () => {
  await atLimit('export', admin.uid);
  assertLimited(await callFunction('exportRegisteredUsers', {}, admin.idToken));
});

test('G18 a link request over the limit is RATE_LIMITED, and does not show whether the issue exists', async () => {
  await atLimit('issue_file', reader.uid);
  assertLimited(await callFunction('getIssueFile', { issue_id: 'i-none' }, reader.idToken));
  await db.doc('deleted_issues/i-gone').set({ issue_id: 'i-gone', deleted_at: NOW });
  assertLimited(await callFunction('getIssueFile', { issue_id: 'i-gone' }, reader.idToken));
});

test('G18 the reader writes and the role check are limited too', async () => {
  await atLimit('reader_write', reader.uid);
  assertLimited(await callFunction('saveProfile', { request_id: 'r1', profile: {} }, reader.idToken));
  assertLimited(await callFunction('requestAccountDeletion', { request_id: 'r1', confirm: true }, reader.idToken));
  assert.equal((await db.doc(`users/${reader.uid}`).get()).exists, false);
  await atLimit('role_check', reader.uid);
  assertLimited(await callFunction('getMyAdminRole', {}, reader.idToken));
});

test('G18 calls are counted per caller and class; another caller or class is not affected', async () => {
  await callFunction('listIssuesForAdmin', {}, admin.idToken);
  await callFunction('listIssuesForAdmin', {}, admin.idToken);
  assert.equal((await counter('admin_read', admin.uid).get()).get('count'), 2);
  await atLimit('admin_read', admin.uid);
  assert.equal((await callFunction('saveCategory', { request_id: 'r2', name: 'Other', display_order: 1 }, admin.idToken)).status, 200);
  assert.notEqual((await callFunction('getIssueFile', { issue_id: 'i-none' }, reader.idToken)).error?.status, 'RESOURCE_EXHAUSTED');
  assert.equal((await counter('issue_file', reader.uid).get()).get('count'), 1);
});

test('G18 a new window starts the count again', async () => {
  await atLimit('admin_read', admin.uid, PLACEHOLDER_WINDOW_SECONDS * 1000 + 1000);
  assert.equal((await callFunction('listIssuesForAdmin', {}, admin.idToken)).status, 200);
  assert.equal((await counter('admin_read', admin.uid).get()).get('count'), 1);
});

test('G18 a refused caller is refused by the gate first and writes no counter', async () => {
  assert.equal((await callFunction('listIssuesForAdmin', {}, reader.idToken)).error?.status, 'PERMISSION_DENIED');
  assert.equal((await counter('admin_read', reader.uid).get()).exists, false);
});

test('G18 two calls at the same moment cannot both pass the last place', async () => {
  await counter('export', admin.uid).set({ rate_class: 'export', user_id: admin.uid, window_start: Date.now(), count: PLACEHOLDER_RATE_LIMITS.export - 1 });
  const outcomes = await Promise.allSettled([enforceRate(db, admin.uid, 'exportRegisteredUsers'), enforceRate(db, admin.uid, 'exportRegisteredUsers')]);
  assert.deepEqual(outcomes.map((o) => o.status).sort(), ['fulfilled', 'rejected']);
  assert.equal(outcomes.find((o) => o.status === 'rejected').reason.details.reason, 'RATE_LIMITED');
});

test('G18 an operation with no class is refused, not let through', async () => {
  await assert.rejects(enforceRate(db, admin.uid, 'notAnOperation'), /no rate class/);
});

test('G18 OP-12 removes the counters with the account', async () => {
  await callFunction('getMyAdminRole', {}, reader.idToken);
  assert.equal((await counter('role_check', reader.uid).get()).exists, true);
  const reply = await callFunction('requestAccountDeletion', { request_id: 'r1', confirm: true }, reader.idToken);
  assert.equal(reply.status, 200, reply.raw);
  for (const rateClass of RATE_CLASSES) assert.equal((await counter(rateClass, reader.uid).get()).exists, false, rateClass);
});
