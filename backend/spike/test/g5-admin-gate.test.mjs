// SPIKE (DEC-003 OPEN, DEC-027 PROPOSED). Group G5: the admin gate, the last-admin guard and the
// count repair (INV-03, INV-08, SC-02 to SC-04, SC-10, SEC-CHK-06, SEC-CHK-18). Emulator only.
//
// A pass here is not a pass for the concurrency cases or for token handling. TECHNOLOGY_DECISIONS.md
// says "A pass on the emulators alone is not a pass for the concurrency cases", and the Functions
// emulator does not verify tokens (04-save-profile-notes.md, B-1). Both go on the re-run list.
//
// No privileged callable exists yet, so the gate is called directly here. OP-37 is not built (OQ-58).
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import {
  planAdminRemoval,
  readStanding,
  removeAdminRole,
  repairAdminCount,
  requireAdmin,
} from '../functions/dist/admin.js';
import {
  adminBackend,
  callFunction,
  clearAuthAccounts,
  deleteAccount,
  disableAccount,
  forgedToken,
  newTestEnv,
  signUp,
  verifyEmail,
} from './helpers.mjs';

let env;
let backend;
let db;

const makeAdmin = (uid, over = {}) =>
  db.doc(`admin_roles/${uid}`).set({
    user_id: uid,
    is_active: true,
    granted_by: 'test-seed',
    granted_at: new Date(),
    ...over,
  });

const setGuard = (count, version = 1) =>
  db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: count, version, updated_at: new Date() });

const readGuard = async () => (await db.doc('admin_guard/current').get()).data();
const readRole = async (uid) => (await db.doc(`admin_roles/${uid}`).get()).data();

const admins = async (count) => {
  const accounts = [];
  for (let i = 0; i < count; i += 1) {
    const account = await signUp(`admin-${i}@example.test`);
    await verifyEmail(account.uid);
    await makeAdmin(account.uid);
    accounts.push(account);
  }
  await setGuard(count);
  return accounts;
};

const refusedWith = (code, reason) => (error) => {
  assert.equal(error.code, code);
  if (reason) assert.equal(error.details?.reason, reason);
  return true;
};

const countActiveRoles = async () =>
  (await db.collection('admin_roles').where('is_active', '==', true).get()).size;

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
});

// ---- The gate (SC-02, INV-08) ----

test('G5 gate: an active admin passes', async () => {
  const [admin] = await admins(1);
  await requireAdmin(backend, admin.uid);
});

test('G5 gate: a reader with no role record is refused (FX-ADM-05, SEC-CHK-06)', async () => {
  const reader = await signUp('reader@example.test');
  await assert.rejects(requireAdmin(backend, reader.uid), refusedWith('permission-denied'));
});

test('G5 gate: a removed admin is refused on the next call (FX-ADM-08, SEC-CHK-18)', async () => {
  const [first, second] = await admins(2);
  await requireAdmin(backend, first.uid);
  await removeAdminRole(backend, first.uid);
  await assert.rejects(requireAdmin(backend, first.uid), refusedWith('permission-denied'));
  await requireAdmin(backend, second.uid);
});

test('G5 gate: a role record whose flag is not exactly true is refused', async () => {
  const reader = await signUp('reader@example.test');
  await makeAdmin(reader.uid, { is_active: 'true' });
  await assert.rejects(requireAdmin(backend, reader.uid), refusedWith('permission-denied'));
});

test('G5 gate: an admin whose account is marked deleting is refused', async () => {
  const [admin] = await admins(1);
  await db.doc(`users/${admin.uid}`).set({ user_id: admin.uid, status: 'deleting' });
  await assert.rejects(requireAdmin(backend, admin.uid), refusedWith('failed-precondition', 'ACCOUNT_CLOSED'));
});

test('G5 gate: an admin the provider has disabled is refused', async () => {
  const [admin] = await admins(1);
  await disableAccount(admin.uid);
  await assert.rejects(requireAdmin(backend, admin.uid), refusedWith('failed-precondition', 'ACCOUNT_CLOSED'));
});

test('G5 gate: an admin the provider no longer has is refused', async () => {
  const [admin] = await admins(1);
  await deleteAccount(admin.idToken);
  await assert.rejects(requireAdmin(backend, admin.uid), refusedWith('failed-precondition', 'ACCOUNT_CLOSED'));
});

test('G5 gate: an admin with no account record yet passes, because the role and the provider decide', async () => {
  const [admin] = await admins(1);
  assert.equal((await db.doc(`users/${admin.uid}`).get()).exists, false);
  await requireAdmin(backend, admin.uid);
});

// A failing read stands in for the database or the provider being unavailable (SC-03).
const failingDb = (failing) => ({
  ...backend,
  db: {
    collection: (name) => {
      const real = backend.db.collection(name);
      if (name !== failing) return real;
      return { doc: () => ({ get: () => Promise.reject(new Error('read failed')) }) };
    },
    doc: (path) =>
      path.startsWith(`${failing}/`)
        ? { get: () => Promise.reject(new Error('read failed')) }
        : backend.db.doc(path),
  },
});

for (const [label, failing] of [
  ['the role record', 'admin_roles'],
  ['the account record', 'users'],
]) {
  test(`G5 gate: ${label} cannot be read: refused, fail closed (SC-03)`, async () => {
    const [admin] = await admins(1);
    await assert.rejects(requireAdmin(failingDb(failing), admin.uid), refusedWith('internal'));
  });
}

test('G5 gate: the provider cannot be read: refused, fail closed (SC-03)', async () => {
  const [admin] = await admins(1);
  const brokenAuth = { getUser: () => Promise.reject(new Error('provider down')) };
  await assert.rejects(requireAdmin({ db, auth: brokenAuth }, admin.uid), refusedWith('internal'));
});

test('G5 gate: the refusal for a failed read does not leak the cause', async () => {
  const [admin] = await admins(1);
  await assert.rejects(requireAdmin(failingDb('admin_roles'), admin.uid), (error) => {
    assert.equal(String(error.message).includes('read failed'), false);
    return true;
  });
});

// ---- OP-14 getMyAdminRole, through the Functions emulator ----

test('G5 OP-14: no sign-in token is refused', async () => {
  const reply = await callFunction('getMyAdminRole', {}, null);
  assert.equal(reply.status, 401);
  assert.equal(reply.error.status, 'UNAUTHENTICATED');
});

test('G5 OP-14: a reader is told they are not an admin', async () => {
  const reader = await signUp('reader@example.test');
  const reply = await callFunction('getMyAdminRole', {}, reader.idToken);
  assert.deepEqual(reply.result, { is_admin: false, is_active: false, email_verified: false });
});

test('G5 OP-14: an active admin is told so', async () => {
  const [admin] = await admins(1);
  const reply = await callFunction('getMyAdminRole', {}, admin.idToken);
  assert.deepEqual(reply.result, { is_admin: true, is_active: true, email_verified: true });
});

test('G5 OP-14: a removed admin holding a token from before the removal is told the role is not active', async () => {
  const [first] = await admins(2);
  const before = await callFunction('getMyAdminRole', {}, first.idToken);
  assert.equal(before.result.is_active, true);
  await removeAdminRole(backend, first.uid);
  const after = await callFunction('getMyAdminRole', {}, first.idToken);
  assert.deepEqual(after.result, { is_admin: true, is_active: false, email_verified: true });
});

test('G5 OP-14: admin claims in the token give a reader nothing (SC-04)', async () => {
  const reader = await signUp('reader@example.test');
  const token = forgedToken(reader.uid, { admin: true, role: 'admin', is_admin: true, is_active: true });
  const reply = await callFunction('getMyAdminRole', {}, token);
  assert.deepEqual(reply.result, { is_admin: false, is_active: false, email_verified: false });
});

test('G5 OP-14: an account marked deleting is refused', async () => {
  const [admin] = await admins(1);
  await db.doc(`users/${admin.uid}`).set({ user_id: admin.uid, status: 'deleting' });
  const reply = await callFunction('getMyAdminRole', {}, admin.idToken);
  assert.equal(reply.error.status, 'FAILED_PRECONDITION');
  assert.equal(reply.error.details.reason, 'ACCOUNT_CLOSED');
});

test('G5 readStanding: reports the role and the account separately', async () => {
  const [admin] = await admins(1);
  assert.deepEqual(await readStanding(backend, admin.uid), { accountClosed: false, hasRole: true, roleActive: true, emailVerified: true });
});

// ---- A verified email (OQ-20 working position, B5) ----

test('G5 gate: an active admin whose email is not verified is refused with EMAIL_NOT_VERIFIED (OQ-20)', async () => {
  const [admin] = await admins(1);
  await verifyEmail(admin.uid, false);
  await assert.rejects(requireAdmin(backend, admin.uid), (error) => {
    assert.equal(error.code, 'failed-precondition');
    assert.equal(error.details?.reason, 'EMAIL_NOT_VERIFIED');
    return true;
  });
  await verifyEmail(admin.uid);
  await requireAdmin(backend, admin.uid);
});

test('G5 gate: a reader whose email is not verified gets FORBIDDEN, so the gate says nothing about the email', async () => {
  const reader = await signUp('reader@example.test');
  await assert.rejects(requireAdmin(backend, reader.uid), refusedWith('permission-denied'));
});

test('G5 gate: a closed account is refused as closed before the email is looked at', async () => {
  const [admin] = await admins(1);
  await verifyEmail(admin.uid, false);
  await db.doc(`users/${admin.uid}`).set({ user_id: admin.uid, status: 'deleting' });
  await assert.rejects(requireAdmin(backend, admin.uid), (error) => error.details?.reason === 'ACCOUNT_CLOSED');
});

test('G5 OP-14: an admin whose email is not verified is told so, and the role stays active', async () => {
  const [admin] = await admins(1);
  await verifyEmail(admin.uid, false);
  const reply = await callFunction('getMyAdminRole', {}, admin.idToken);
  assert.deepEqual(reply.result, { is_admin: true, is_active: true, email_verified: false });
});

// ---- The last-admin guard (INV-03, SC-10) ----

test('G5 guard: a removal keeps the record, sets revoked_at, lowers the count and raises the version', async () => {
  const [first] = await admins(2);
  await setGuard(2, 7);
  await removeAdminRole(backend, first.uid);

  const role = await readRole(first.uid);
  assert.equal(role.is_active, false);
  assert.ok(role.revoked_at, 'revoked_at is set');
  assert.equal(role.user_id, first.uid, 'the record is kept');

  const guard = await readGuard();
  assert.equal(guard.active_admin_count, 1);
  assert.equal(guard.version, 8);
});

test('G5 guard: the last admin cannot be removed, including by themself, and nothing changes', async () => {
  const [only] = await admins(1);
  await setGuard(1, 3);
  await assert.rejects(removeAdminRole(backend, only.uid), refusedWith('failed-precondition', 'LAST_ADMIN'));
  assert.equal((await readRole(only.uid)).is_active, true);
  assert.deepEqual([(await readGuard()).active_admin_count, (await readGuard()).version], [1, 3]);
});

test('G5 guard: removing an account with no role record is refused, and the count stays', async () => {
  await admins(2);
  const reader = await signUp('reader@example.test');
  await assert.rejects(removeAdminRole(backend, reader.uid), refusedWith('failed-precondition', 'NOT_AN_ADMIN'));
  assert.equal((await readGuard()).active_admin_count, 2);
});

test('G5 guard: removing an admin twice is refused the second time, and the count drops once', async () => {
  const [first] = await admins(3);
  await removeAdminRole(backend, first.uid);
  await assert.rejects(removeAdminRole(backend, first.uid), refusedWith('failed-precondition', 'NOT_AN_ADMIN'));
  assert.equal((await readGuard()).active_admin_count, 2);
});

for (const [label, prepare] of [
  ['missing', () => db.doc('admin_guard/current').delete()],
  ['with a count that is not a number', () => db.doc('admin_guard/current').set({ active_admin_count: 'two', version: 1 })],
  ['with no version', () => db.doc('admin_guard/current').set({ active_admin_count: 2 })],
]) {
  test(`G5 guard: a guard record ${label} refuses the removal, fail closed, and the role stays`, async () => {
    const [first] = await admins(2);
    await prepare();
    await assert.rejects(removeAdminRole(backend, first.uid), refusedWith('internal'));
    assert.equal((await readRole(first.uid)).is_active, true);
  });
}

test('G5 guard: for an account that is not an admin the plan is empty, so account deletion can go on (OP-12)', async () => {
  const reader = await signUp('reader@example.test');
  await admins(1);
  const plan = await db.runTransaction((tx) => planAdminRemoval(tx, db, reader.uid));
  assert.equal(plan, null);
});

// ---- Removals at the same moment. EMULATOR ONLY: not a pass for concurrency. ----

// Each round takes about three seconds on the emulator, because the two transactions conflict and retry.
const ROUNDS = Number(process.env.SPIKE_SAME_MOMENT_ROUNDS ?? 20);

const settle = async (calls) => {
  const results = await Promise.allSettled(calls);
  return {
    won: results.filter((r) => r.status === 'fulfilled').length,
    reasons: results.filter((r) => r.status === 'rejected').map((r) => r.reason?.details?.reason ?? r.reason?.code ?? String(r.reason)),
  };
};

test(`G5 at the same moment: two admins remove each other, ${ROUNDS} rounds. Exactly one wins, and the count stays at 1`, async () => {
  for (let round = 0; round < ROUNDS; round += 1) {
    await env.clearFirestore();
    await clearAuthAccounts();
    const [a, b] = await admins(2);
    const { won, reasons } = await settle([removeAdminRole(backend, a.uid), removeAdminRole(backend, b.uid)]);
    assert.equal(won, 1, `round ${round}: exactly one removal succeeds, got ${JSON.stringify(reasons)}`);
    assert.deepEqual(reasons, ['LAST_ADMIN'], `round ${round}`);
    assert.equal((await readGuard()).active_admin_count, 1, `round ${round}`);
    assert.equal(await countActiveRoles(), 1, `round ${round}`);
  }
});

test('G5 at the same moment: three removals with three admins. Two win, and one active admin remains', async () => {
  const accounts = await admins(3);
  const { won, reasons } = await settle(accounts.map((a) => removeAdminRole(backend, a.uid)));
  assert.equal(won, 2, JSON.stringify(reasons));
  assert.deepEqual(reasons, ['LAST_ADMIN']);
  assert.equal((await readGuard()).active_admin_count, 1);
  assert.equal(await countActiveRoles(), 1);
});

test('G5 at the same moment: the same admin removed twice, repeated. One wins, and the count drops once', async () => {
  for (let round = 0; round < Math.min(ROUNDS, 10); round += 1) {
    await env.clearFirestore();
    await clearAuthAccounts();
    const [first] = await admins(3);
    const { won, reasons } = await settle([removeAdminRole(backend, first.uid), removeAdminRole(backend, first.uid)]);
    assert.equal(won, 1, `round ${round}: ${JSON.stringify(reasons)}`);
    assert.deepEqual(reasons, ['NOT_AN_ADMIN'], `round ${round}`);
    assert.equal((await readGuard()).active_admin_count, 2, `round ${round}`);
  }
});

// ---- The count repair (INV-03; OP-41) ----

test('G5 repair: a correct count is left alone', async () => {
  await admins(2);
  await setGuard(2, 5);
  const report = await repairAdminCount(backend);
  assert.deepEqual(report, { stored: 2, actual: 2, corrected: false, guard_missing: false, no_active_admin: false });
  assert.equal((await readGuard()).version, 5);
});

test('G5 repair: a wrong count is reported and corrected, and the version rises', async () => {
  await admins(2);
  await setGuard(9, 5);
  const report = await repairAdminCount(backend);
  assert.deepEqual(report, { stored: 9, actual: 2, corrected: true, guard_missing: false, no_active_admin: false });
  const guard = await readGuard();
  assert.equal(guard.active_admin_count, 2);
  assert.equal(guard.version, 6);
});

test('G5 repair: disabled, deleting, deleted and removed admins are not counted (an outside change is detected)', async () => {
  const [kept, disabled, deleting, deleted, removed] = await admins(5);
  await disableAccount(disabled.uid);
  await db.doc(`users/${deleting.uid}`).set({ user_id: deleting.uid, status: 'deleting' });
  await deleteAccount(deleted.idToken);
  await removeAdminRole(backend, removed.uid);
  assert.equal((await readGuard()).active_admin_count, 4);

  const report = await repairAdminCount(backend);
  assert.equal(report.actual, 1);
  assert.equal(report.corrected, true);
  await requireAdmin(backend, kept.uid);
});

test('G5 repair: no usable admin left is reported, and removals then stay refused', async () => {
  const [only] = await admins(1);
  await disableAccount(only.uid);
  const report = await repairAdminCount(backend);
  assert.deepEqual(report, { stored: 1, actual: 0, corrected: true, guard_missing: false, no_active_admin: true });
  await assert.rejects(removeAdminRole(backend, only.uid), refusedWith('failed-precondition', 'LAST_ADMIN'));
});

test('G5 repair: a missing guard record is reported and not created (the bootstrap step creates it)', async () => {
  await admins(1);
  await db.doc('admin_guard/current').delete();
  const report = await repairAdminCount(backend);
  assert.deepEqual(report, { stored: null, actual: 1, corrected: false, guard_missing: true, no_active_admin: false });
  assert.equal((await db.doc('admin_guard/current').get()).exists, false);
});

test('G5 repair: the report holds numbers and flags only, with no user identifier', async () => {
  const [admin] = await admins(1);
  await setGuard(4);
  const report = await repairAdminCount(backend);
  assert.equal(JSON.stringify(report).includes(admin.uid), false);
});
