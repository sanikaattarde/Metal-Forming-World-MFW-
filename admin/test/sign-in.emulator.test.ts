// SPIKE (DEC-004 OPEN). The sign-in decision against the local Auth emulator, with the real provider SDK.
// Every result is "emulator only". Run through `npm test`, which starts the emulator.
import type { Auth } from 'firebase/auth';
import { beforeAll, beforeEach, expect, test } from 'vitest';
import { roleCheckNotBuilt } from '../src/roleCheck';
import { authDeps, createServices, EMULATOR, emulatorAuth, isLocalHost } from '../src/services';
import { signInAdmin } from '../src/signIn';
import type { RoleCheck } from '../src/signIn';

// Set by `firebase emulators:exec`. Vitest passes the environment through import.meta.env.
const host: string | undefined = import.meta.env.FIREBASE_AUTH_EMULATOR_HOST;
const base = `http://${host}`;
const PASSWORD = 'admin-spike-password-1';
const admitAll: RoleCheck = async () => true;

let auth: Auth;
let email: string;
let uid: string;

async function rest(path: string, body?: unknown, method = 'POST') {
  const reply = await fetch(`${base}${path}`, {
    method,
    headers: { 'Content-Type': 'application/json', Authorization: 'Bearer owner' },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  return reply.json();
}

beforeAll(() => {
  if (!host) throw new Error('FIREBASE_AUTH_EMULATOR_HOST is not set: run these tests with `npm test`, which starts the emulator');
  auth = emulatorAuth(base, 'b3-emulator-tests');
});

beforeEach(async () => {
  await rest(`/emulator/v1/projects/${EMULATOR.projectId}/accounts`, undefined, 'DELETE');
  email = `admin-${Date.now()}@example.test`;
  const account = await rest(`/identitytoolkit.googleapis.com/v1/accounts:signUp?key=${EMULATOR.apiKey}`, { email, password: PASSWORD, returnSecureToken: true });
  uid = account.localId;
  expect(uid).toBeTruthy();
});

test('B3 emulator: the panel serves services only on a local address', async () => {
  expect(isLocalHost('127.0.0.1')).toBe(true);
  expect(isLocalHost('localhost')).toBe(true);
  for (const name of ['example.com', 'admin.example.com', '127.0.0.1.example.com', '0.0.0.0', '']) {
    expect(isLocalHost(name)).toBe(false);
    expect(await createServices(name)).toBeNull();
  }
});

test('B3 emulator AC-8.1: a wrong password is refused, and no one is signed in', async () => {
  expect(await signInAdmin(authDeps(auth, admitAll), email, 'not-the-password')).toBe('refused');
  expect(auth.currentUser).toBeNull();
});

test('B3 emulator SEC-CHK-17: an unknown address gets the same outcome as a wrong password', async () => {
  const deps = authDeps(auth, admitAll);
  const unknown = await signInAdmin(deps, `nobody-${Date.now()}@example.test`, PASSWORD);
  const wrong = await signInAdmin(deps, email, 'not-the-password');
  expect(unknown).toBe('refused');
  expect(unknown).toBe(wrong);
});

test('B3 emulator AC-8.2: the right password on an account without the admin role is refused, and the account is signed out', async () => {
  const deny: RoleCheck = async (user) => (expect(user.uid).toBe(uid), false);
  expect(await signInAdmin(authDeps(auth, deny), email, PASSWORD)).toBe('refused');
  expect(auth.currentUser).toBeNull();
});

test('B3 emulator: the built panel refuses every account, because its role check is not built (B5)', async () => {
  expect(await signInAdmin(authDeps(auth, roleCheckNotBuilt), email, PASSWORD)).toBe('refused');
  expect(await signInAdmin(authDeps(auth), email, PASSWORD)).toBe('refused');
  expect(auth.currentUser).toBeNull();
});

test('B3 emulator: with a role check that says admin, the account is signed in', async () => {
  expect(await signInAdmin(authDeps(auth, admitAll), email, PASSWORD)).toBe('signed-in');
  expect(auth.currentUser?.uid).toBe(uid);
  await auth.signOut();
});

test('B3 emulator: a role check that fails is a refusal, and the account is signed out', async () => {
  const broken: RoleCheck = async () => {
    throw new Error('the check could not be made');
  };
  expect(await signInAdmin(authDeps(auth, broken), email, PASSWORD)).toBe('refused');
  expect(auth.currentUser).toBeNull();
});

test('B3 emulator: an account the provider has disabled is refused with the same outcome', async () => {
  await rest(`/identitytoolkit.googleapis.com/v1/projects/${EMULATOR.projectId}/accounts:update`, { localId: uid, disableUser: true });
  expect(await signInAdmin(authDeps(auth, admitAll), email, PASSWORD)).toBe('refused');
  expect(auth.currentUser).toBeNull();
});

test('B3 emulator: when the provider cannot be reached, the outcome is "unavailable"', async () => {
  // Port 9 (discard) has nothing listening on it here.
  const unreachable = emulatorAuth('http://127.0.0.1:9', 'b3-unreachable');
  expect(await signInAdmin(authDeps(unreachable, admitAll), email, PASSWORD)).toBe('unavailable');
});
