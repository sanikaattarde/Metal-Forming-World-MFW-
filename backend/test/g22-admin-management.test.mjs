// Group G22: OP-35 addAdmin, OP-37 removeAdmin, OP-38 listAdmins and OP-39 listAdminChanges (MOD12-P3-T02),
// switched off until OQ-58 (DEC-027). PROVISIONAL. Synthetic accounts only. Emulator only.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { changeAdminAs } from '../functions/dist/adminManagement.js';
import { adminBackend, callFunction, clearAuthAccounts, newTestEnv, signUp, verifyEmail } from './helpers.mjs';

const NOW = new Date('2026-11-12T10:00:00Z');
let env;
let db;
let adminAuth;
let admin;
let reader;
let counter = 0;

before(async () => {
  env = await newTestEnv();
  ({ db, auth: adminAuth } = adminBackend());
});

after(async () => {
  await env.cleanup();
});

const switchOn = (on = true) => db.doc('config/private').set({ admin_management_enabled: on }, { merge: true });

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

const call = (name, data = {}, token = admin.idToken) => callFunction(name, { request_id: `r-${(counter += 1)}`, ...data }, token);
const refusedWith = (reply, status, reason) => {
  assert.equal(reply.error?.status, status, reply.raw);
  if (reason) assert.equal(reply.error.details?.reason, reason, reply.raw);
};
const guardCount = async () => (await db.doc('admin_guard/current').get()).get('active_admin_count');

test('G22 switched off by default: every operation is FEATURE_OFF and nothing changes', async () => {
  for (const name of ['addAdmin', 'removeAdmin', 'listAdmins', 'listAdminChanges']) {
    refusedWith(await call(name, { target_email: 'reader@example.test', expected_state: 'not_admin', confirmation: 'x' }), 'FAILED_PRECONDITION', 'FEATURE_OFF');
  }
  assert.equal((await db.doc(`admin_roles/${reader.uid}`).get()).exists, false);
  assert.equal((await db.collection('admin_audit').get()).size, 0);
});

test('G22 OP-35: an admin adds a verified reader by address; the guard, the list and the change record follow', async () => {
  await switchOn();
  const reply = await call('addAdmin', { target_email: 'reader@example.test', expected_state: 'not_admin' });
  assert.equal(reply.status, 200, reply.raw);
  assert.deepEqual(reply.result, { user_id: reader.uid, email: 'reader@example.test', is_active: true });
  assert.equal((await db.doc(`admin_roles/${reader.uid}`).get()).get('granted_by'), admin.uid);
  assert.equal(await guardCount(), 2);

  const list = await call('listAdmins');
  assert.deepEqual(list.result.items.map((a) => a.email), ['admin-a@example.test', 'reader@example.test']);
  const changes = await call('listAdminChanges');
  assert.equal(changes.result.items.length, 1);
  assert.equal(changes.result.items[0].action, 'admin_add');
  assert.equal(changes.result.items[0].actor_user_id, admin.uid);
  // The change record holds identifiers and a time only (GS-Q44).
  const record = (await db.collection('admin_audit').get()).docs[0].data();
  assert.deepEqual(Object.keys(record).sort(), ['action', 'actor_user_id', 'event_id', 'occurred_at', 'recent_sign_in_checked', 'target_user_id']);
});

test('G22 a repeat of the same request returns the first result and writes once', async () => {
  await switchOn();
  const data = { request_id: 'same', target_email: 'reader@example.test', expected_state: 'not_admin' };
  const first = await callFunction('addAdmin', data, admin.idToken);
  const second = await callFunction('addAdmin', data, admin.idToken);
  assert.deepEqual(second.result, first.result);
  assert.equal(await guardCount(), 2);
  assert.equal((await db.collection('admin_audit').get()).size, 1);
});

test('G22 refusals: unverified, already an admin, a stale screen, an unknown address and a reader caller', async () => {
  await switchOn();
  const unverified = await signUp('new@example.test');
  refusedWith(await call('addAdmin', { target_user_id: unverified.uid, expected_state: 'not_admin' }), 'FAILED_PRECONDITION', 'TARGET_EMAIL_NOT_VERIFIED');
  refusedWith(await call('addAdmin', { target_user_id: admin.uid, expected_state: 'admin' }), 'FAILED_PRECONDITION', 'ALREADY_ADMIN');
  refusedWith(await call('addAdmin', { target_user_id: admin.uid, expected_state: 'not_admin' }), 'ABORTED', 'STALE_ADMIN_STATE');
  refusedWith(await call('addAdmin', { target_email: 'nobody@example.test', expected_state: 'not_admin' }), 'NOT_FOUND');
  refusedWith(await call('addAdmin', { target_email: 'admin-a@example.test', expected_state: 'not_admin' }, reader.idToken), 'PERMISSION_DENIED');
  refusedWith(await call('addAdmin', { expected_state: 'not_admin' }), 'INVALID_ARGUMENT');
  assert.equal(await guardCount(), 1);
  assert.equal((await db.collection('admin_audit').get()).size, 0);
});

test('G22 OP-37: removal needs the address typed; then the removed admin is refused at once (SEC-CHK-18)', async () => {
  await switchOn();
  await call('addAdmin', { target_email: 'reader@example.test', expected_state: 'not_admin' });
  refusedWith(await call('removeAdmin', { target_user_id: reader.uid, expected_state: 'admin', confirmation: 'someone@example.test' }), 'INVALID_ARGUMENT');
  const reply = await call('removeAdmin', { target_user_id: reader.uid, expected_state: 'admin', confirmation: ' Reader@Example.test ' });
  assert.equal(reply.status, 200, reply.raw);
  assert.equal(reply.result.is_active, false);
  assert.equal(await guardCount(), 1);
  assert.equal((await db.doc(`admin_roles/${reader.uid}`).get()).get('is_active'), false);
  refusedWith(await call('listAdmins', {}, reader.idToken), 'PERMISSION_DENIED');
  // INV-09: the removed admin's sessions were ended.
  const user = await adminAuth.getUser(reader.uid);
  assert.ok(user.tokensValidAfterTime, 'tokens revoked');
});

test('G22 INV-03: the last active admin cannot be removed', async () => {
  await switchOn();
  refusedWith(await call('removeAdmin', { target_user_id: admin.uid, expected_state: 'admin', confirmation: 'admin-a@example.test' }), 'FAILED_PRECONDITION', 'LAST_ADMIN');
  assert.equal(await guardCount(), 1);
});

test('G22 OQ-56: a sign-in older than the window is RECENT_SIGN_IN_REQUIRED', async () => {
  await switchOn();
  await assert.rejects(
    changeAdminAs({ db, auth: adminAuth, nowSeconds: () => 10_000 }, { uid: admin.uid, authTime: 1 }, { request_id: 'x', target_email: 'reader@example.test', expected_state: 'not_admin' }, false),
    (error) => error.details?.reason === 'RECENT_SIGN_IN_REQUIRED',
  );
  assert.equal(await guardCount(), 1);
});
