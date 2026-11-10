// Group G13: OP-42, the first-admin bootstrap and recovery step (MOD12-P1-T02, SC-14, INV-03, INV-04,
// SECURITY_AND_ACCESS_CONTROL.md section 7.1), through the step itself and its command, on the emulators.
// Emulator only. The step is rehearsed in a throwaway project before ENV-TEST (ST-09).
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { assertFails } from '@firebase/rules-unit-testing';
import { doc, getDoc } from 'firebase/firestore';
import { requireAdmin } from '../functions/dist/admin.js';
import { BOOTSTRAP_MARKER, bootstrapAdmin, BootstrapRefused, verifyBootstrap } from '../functions/dist/bootstrap.js';
import { adminBackend, clearAuthAccounts, disableAccount, newTestEnv, signUp, verifyEmail } from './helpers.mjs';

const SCRIPT = fileURLToPath(new URL('../scripts/bootstrap-admin.mjs', import.meta.url));
const REFERENCE = 'MFW written request, test reference 1';

let env;
let backend;
let db;
let person;

const run = (args, extraEnv = {}) =>
  spawnSync(process.execPath, [SCRIPT, ...args], { encoding: 'utf8', env: { ...process.env, ...extraEnv }, timeout: 30_000 });

const dump = async () => {
  const out = {};
  for (const name of ['admin_roles', 'admin_guard', 'admin_audit']) {
    for (const d of (await db.collection(name).get()).docs) out[`${name}/${d.id}`] = d.data();
  }
  return JSON.stringify(Object.keys(out).sort().map((key) => [key, out[key]]));
};

const refused = async (promise, reason) => {
  await assert.rejects(promise, (error) => error instanceof BootstrapRefused && error.reason === reason);
};

const makeAdmin = (uid, over = {}) =>
  db.doc(`admin_roles/${uid}`).set({ user_id: uid, is_active: true, granted_by: 'test-seed', granted_at: new Date(), ...over });

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
  person = await signUp('first-admin@example.test');
  await verifyEmail(person.uid);
});

// ---- The first admin ----

test('G13 the step makes a verified reader the first admin, with the guard at 1 and the change record', async () => {
  const result = await bootstrapAdmin(backend, { target: { email: 'first-admin@example.test' }, reference: REFERENCE, recovery: false });
  assert.equal(result.uid, person.uid);
  assert.equal(result.active_admin_count, 1);

  const role = (await db.doc(`admin_roles/${person.uid}`).get()).data();
  assert.deepEqual({ ...role, granted_at: undefined }, { user_id: person.uid, is_active: true, granted_by: BOOTSTRAP_MARKER, granted_at: undefined });
  const guard = (await db.doc('admin_guard/current').get()).data();
  assert.deepEqual({ ...guard, updated_at: undefined }, { guard_id: 'current', active_admin_count: 1, version: 1, updated_at: undefined });
  const event = (await db.doc(`admin_audit/${result.event_id}`).get()).data();
  assert.deepEqual({ ...event, occurred_at: undefined }, {
    event_id: result.event_id,
    action: 'bootstrap_admin',
    actor_user_id: BOOTSTRAP_MARKER,
    target_user_id: person.uid,
    reference: REFERENCE,
    recent_sign_in_checked: false,
    occurred_at: undefined,
  });
  // The change record holds identifiers and the reference only: no email address.
  assert.equal(JSON.stringify(event).includes('@'), false);
});

test('G13 the new admin passes the admin gate, and can be found by identifier too', async () => {
  await bootstrapAdmin(backend, { target: { uid: person.uid }, reference: REFERENCE, recovery: false });
  await requireAdmin(backend, person.uid);
});

// ---- Refusals: nothing is written ----

const REFUSALS = {
  'an unverified email': [async () => verifyEmail(person.uid, false), { email: 'first-admin@example.test' }, REFERENCE, 'EMAIL_NOT_VERIFIED'],
  'an unknown address': [async () => {}, { email: 'nobody@example.test' }, REFERENCE, 'ACCOUNT_NOT_FOUND'],
  'an unknown identifier': [async () => {}, { uid: 'no-such-user' }, REFERENCE, 'ACCOUNT_NOT_FOUND'],
  'a disabled account': [async () => disableAccount(person.uid), { email: 'first-admin@example.test' }, REFERENCE, 'ACCOUNT_CLOSED'],
  'an account being deleted': [
    async () => db.doc(`users/${person.uid}`).set({ user_id: person.uid, status: 'deleting' }),
    { email: 'first-admin@example.test' },
    REFERENCE,
    'ACCOUNT_CLOSED',
  ],
  'an empty reference': [async () => {}, { email: 'first-admin@example.test' }, '   ', 'REFERENCE_INVALID'],
  'a reference over 200 characters': [async () => {}, { email: 'first-admin@example.test' }, 'r'.repeat(201), 'REFERENCE_INVALID'],
  'a reference over two lines': [async () => {}, { email: 'first-admin@example.test' }, 'line one\nline two', 'REFERENCE_INVALID'],
};

for (const [name, [arrange, target, reference, reason]] of Object.entries(REFUSALS)) {
  test(`G13 refused: ${name} (${reason}), and nothing is written`, async () => {
    await arrange();
    const before = await dump();
    await refused(bootstrapAdmin(backend, { target, reference, recovery: false }), reason);
    assert.equal(await dump(), before);
  });
}

test('G13 refused while an active admin exists (ACTIVE_ADMIN_EXISTS), and nothing is written', async () => {
  const other = await signUp('existing-admin@example.test');
  await makeAdmin(other.uid);
  const before = await dump();
  await refused(bootstrapAdmin(backend, { target: { uid: person.uid }, reference: REFERENCE, recovery: false }), 'ACTIVE_ADMIN_EXISTS');
  assert.equal(await dump(), before);
});

test('G13 a removed admin does not count as active, so the first-admin step may run', async () => {
  const other = await signUp('removed-admin@example.test');
  await makeAdmin(other.uid, { is_active: false, revoked_at: new Date() });
  const result = await bootstrapAdmin(backend, { target: { uid: person.uid }, reference: REFERENCE, recovery: false });
  assert.equal(result.active_admin_count, 1);
});

test('G13 two first-admin steps at the same moment make exactly one admin (INV-03)', async () => {
  const second = await signUp('second@example.test');
  await verifyEmail(second.uid);
  const results = await Promise.allSettled([
    bootstrapAdmin(backend, { target: { uid: person.uid }, reference: REFERENCE, recovery: false }),
    bootstrapAdmin(backend, { target: { uid: second.uid }, reference: REFERENCE, recovery: false }),
  ]);
  assert.equal(results.filter((r) => r.status === 'fulfilled').length, 1);
  assert.equal(results.filter((r) => r.status === 'rejected' && r.reason.reason === 'ACTIVE_ADMIN_EXISTS').length, 1);
  assert.equal((await db.collection('admin_roles').where('is_active', '==', true).get()).size, 1);
  assert.equal((await db.doc('admin_guard/current').get()).get('active_admin_count'), 1);
});

// ---- Recovery ----

test('G13 a recovery runs while admins exist, counts them again and records the reference', async () => {
  const other = await signUp('locked-out@example.test');
  await makeAdmin(other.uid);
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 7, version: 4, updated_at: new Date() });
  const result = await bootstrapAdmin(backend, { target: { uid: person.uid }, reference: 'Recovery request 2', recovery: true });
  assert.equal(result.active_admin_count, 2);
  const guard = (await db.doc('admin_guard/current').get()).data();
  assert.equal(guard.active_admin_count, 2);
  assert.equal(guard.version, 5);
  assert.equal((await db.doc(`admin_audit/${result.event_id}`).get()).get('reference'), 'Recovery request 2');
});

test('G13 a recovery gives a removed admin the role again, without revoked_at', async () => {
  await makeAdmin(person.uid, { is_active: false, revoked_at: new Date() });
  await bootstrapAdmin(backend, { target: { uid: person.uid }, reference: REFERENCE, recovery: true });
  const role = (await db.doc(`admin_roles/${person.uid}`).get()).data();
  assert.equal(role.is_active, true);
  assert.equal(role.granted_by, BOOTSTRAP_MARKER);
  assert.equal('revoked_at' in role, false);
});

test('G13 a recovery for someone who is already an active admin is refused (ALREADY_AN_ADMIN)', async () => {
  await makeAdmin(person.uid);
  const before = await dump();
  await refused(bootstrapAdmin(backend, { target: { uid: person.uid }, reference: REFERENCE, recovery: true }), 'ALREADY_AN_ADMIN');
  assert.equal(await dump(), before);
});

// ---- Verification and client access ----

test('G13 the second developer verifies the role, the guard and the change record', async () => {
  await bootstrapAdmin(backend, { target: { uid: person.uid }, reference: REFERENCE, recovery: false });
  assert.deepEqual(await verifyBootstrap(backend, { email: 'first-admin@example.test' }), {
    uid: person.uid,
    role_active: true,
    granted_by: BOOTSTRAP_MARKER,
    guard_count: 1,
    bootstrap_events: 1,
  });
});

test('G13 no client can read the change record, not even the new admin (SC-05)', async () => {
  const { event_id: eventId } = await bootstrapAdmin(backend, { target: { uid: person.uid }, reference: REFERENCE, recovery: false });
  for (const client of [env.unauthenticatedContext(), env.authenticatedContext(person.uid)]) {
    await assertFails(getDoc(doc(client.firestore(), `admin_audit/${eventId}`)));
  }
});

// ---- The command ----

test('G13 the command runs the step on the emulators and prints the identifier, never the address', () => {
  const out = run(['--email', 'first-admin@example.test', '--reference', REFERENCE]);
  assert.equal(out.status, 0, out.stderr);
  const printed = JSON.parse(out.stdout);
  assert.equal(printed.uid, person.uid);
  assert.equal(printed.project, 'demo-mfw');
  assert.equal(out.stdout.includes('first-admin@example.test'), false);
});

test('G13 the command verifies, and reports a refusal with exit status 1', () => {
  assert.equal(run(['--uid', person.uid, '--reference', REFERENCE]).status, 0);
  const verified = run(['--verify', '--uid', person.uid]);
  assert.equal(verified.status, 0, verified.stderr);
  assert.equal(JSON.parse(verified.stdout).role_active, true);
  const again = run(['--uid', person.uid, '--reference', REFERENCE]);
  assert.equal(again.status, 1);
  assert.match(again.stderr, /ALREADY_AN_ADMIN|ACTIVE_ADMIN_EXISTS/);
});

const COMMAND_REFUSALS = {
  'no emulators and no --project': [['--uid', 'x', '--reference', REFERENCE], { FIRESTORE_EMULATOR_HOST: '', FIREBASE_AUTH_EMULATOR_HOST: '' }, /not on the local emulators/],
  'an emulator address that is not local': [['--uid', 'x', '--reference', REFERENCE], { FIRESTORE_EMULATOR_HOST: '192.0.2.1:8080' }, /not on the local emulators/],
  '--project while the emulator variables are set': [['--uid', 'x', '--reference', REFERENCE, '--project', 'mfw-test', '--confirm', 'mfw-test'], {}, /ambiguous/],
  'both --email and --uid': [['--uid', 'x', '--email', 'a@example.test', '--reference', REFERENCE], {}, /exactly one/],
  'no reference': [['--uid', 'x'], {}, /--reference/],
  'an unknown option': [['--uid', 'x', '--reference', REFERENCE, '--force'], {}, /Usage error/],
};

for (const [name, [args, extraEnv, message]] of Object.entries(COMMAND_REFUSALS)) {
  test(`G13 the command refuses ${name}, with exit status 2 and nothing written`, async () => {
    const before = await dump();
    const out = run(args, extraEnv);
    assert.equal(out.status, 2, out.stderr);
    assert.match(out.stderr, message);
    assert.equal(await dump(), before);
  });
}

test('G13 for a real project the command needs --confirm to repeat it, and refuses a demo- name', () => {
  const real = { FIRESTORE_EMULATOR_HOST: '', FIREBASE_AUTH_EMULATOR_HOST: '' };
  // Empty variables count as unset for the project path, so the check below never reaches a cloud project.
  const unconfirmed = run(['--uid', 'x', '--reference', REFERENCE, '--project', 'mfw-test'], real);
  assert.equal(unconfirmed.status, 2);
  assert.match(unconfirmed.stderr, /--confirm must repeat/);
  const demo = run(['--uid', 'x', '--reference', REFERENCE, '--project', 'demo-mfw', '--confirm', 'demo-mfw'], real);
  assert.equal(demo.status, 2);
  assert.match(demo.stderr, /demo- project/);
});
