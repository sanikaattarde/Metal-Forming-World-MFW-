// Sign-in and the role check against the local emulators, with the real SDK and the
// backend's OP-14 (MOD12-P2-T01). Every result is "emulator only". Run through `npm test`.
import { beforeAll, beforeEach, expect, test } from 'vitest';
import { AccessLost, adminApi } from '../src/adminApi';
import { createServices, emulatorBackend, isLocalHost, servicesFor } from '../src/services';
import type { Backend } from '../src/services';
import { signInAdmin } from '../src/signIn';
import { AUTH_URL, clearAll, createAccount, createAdmin, PASSWORD, removeRole, requireEmulators, setDoc, updateAccount } from './emulator';

let backend: Backend;
let n = 0;

beforeAll(() => {
  requireEmulators();
  backend = emulatorBackend(AUTH_URL, 'b5-emulator-tests');
});

beforeEach(async () => {
  await clearAll();
  n += 1;
});

const email = (who: string) => `${who}-${n}@example.test`;
const signIn = (address: string, password = PASSWORD) => signInAdmin(servicesFor(backend), address, password);

test('B5 emulator: the panel serves services only on a local address', async () => {
  expect(isLocalHost('127.0.0.1')).toBe(true);
  expect(isLocalHost('localhost')).toBe(true);
  for (const name of ['example.com', 'admin.example.com', '127.0.0.1.example.com', '0.0.0.0', '']) {
    expect(isLocalHost(name)).toBe(false);
    expect(await createServices(name)).toBeNull();
  }
});

test('B5 emulator: an admin with a verified email signs in, through OP-14 (MOD12-P2-T01)', async () => {
  const uid = await createAdmin(email('admin'));
  expect(await signIn(email('admin'))).toBe('signed-in');
  expect(backend.auth.currentUser?.uid).toBe(uid);
  await backend.auth.signOut();
});

test('B5 emulator AC-8.1: a wrong password is refused, and no one is signed in', async () => {
  await createAdmin(email('admin'));
  expect(await signIn(email('admin'), 'not-the-password')).toBe('refused');
  expect(backend.auth.currentUser).toBeNull();
});

test('B5 emulator AC-8.2: a reader without the role is refused by OP-14, and signed out', async () => {
  await createAccount(email('reader'));
  expect(await signIn(email('reader'))).toBe('refused');
  expect(backend.auth.currentUser).toBeNull();
});

test('B5 emulator SEC-CHK-17: an unknown address gets the same outcome as a wrong password and a reader', async () => {
  await createAccount(email('reader'));
  const outcomes = [await signIn(email('nobody')), await signIn(email('reader'), 'not-the-password'), await signIn(email('reader'))];
  expect(new Set(outcomes)).toEqual(new Set(['refused']));
});

test('B5 emulator OQ-20: an admin whose email is not verified is refused, and signed out', async () => {
  await createAdmin(email('admin'), { verified: false });
  expect(await signIn(email('admin'))).toBe('refused');
  expect(backend.auth.currentUser).toBeNull();
});

test('B5 emulator: a removed admin is refused (FX-ADM-08)', async () => {
  const uid = await createAdmin(email('admin'));
  await removeRole(uid);
  expect(await signIn(email('admin'))).toBe('refused');
});

test('B5 emulator: an admin whose account is marked deleting is refused', async () => {
  const uid = await createAdmin(email('admin'));
  await setDoc(`users/${uid}`, { user_id: uid, status: 'deleting' });
  expect(await signIn(email('admin'))).toBe('refused');
  expect(backend.auth.currentUser).toBeNull();
});

test('B5 emulator: an account the provider has disabled is refused', async () => {
  const uid = await createAdmin(email('admin'));
  await updateAccount(uid, { disableUser: true });
  expect(await signIn(email('admin'))).toBe('refused');
});

test('B5 emulator: when the sign-in provider cannot be reached, the outcome is "unavailable"', async () => {
  // Port 9 (discard) has nothing listening on it here.
  const unreachable = emulatorBackend('http://127.0.0.1:9', 'b5-no-auth');
  expect(await signInAdmin(servicesFor(unreachable), 'anyone@example.test', PASSWORD)).toBe('unavailable');
});

test('B5 emulator: when OP-14 cannot be reached, the account is refused and signed out (fails closed)', async () => {
  await createAdmin(email('admin'));
  const noFunctions = emulatorBackend(AUTH_URL, 'b5-no-functions', 9);
  expect(await signInAdmin(servicesFor(noFunctions), email('admin'), PASSWORD)).toBe('refused');
  expect(noFunctions.auth.currentUser).toBeNull();
});

test('B5 emulator SEC-CHK-18: removing the role ends the session on the next call (MOD12-P2-T01 step 4)', async () => {
  const uid = await createAdmin(email('admin'));
  const services = servicesFor(backend);
  expect(await signInAdmin(services, email('admin'), PASSWORD)).toBe('signed-in');
  let ended = 0;
  const api = adminApi(services.call, () => (ended += 1));

  await api('listIssuesForAdmin', {});
  expect(ended).toBe(0);

  await removeRole(uid);
  await expect(api('listIssuesForAdmin', {})).rejects.toBeInstanceOf(AccessLost);
  expect(ended).toBe(1);
  await backend.auth.signOut();
});

test('B5 emulator: an admin whose email stops being verified loses the session on the next call', async () => {
  const uid = await createAdmin(email('admin'));
  const services = servicesFor(backend);
  expect(await signInAdmin(services, email('admin'), PASSWORD)).toBe('signed-in');
  let ended = 0;
  const api = adminApi(services.call, () => (ended += 1));
  await updateAccount(uid, { emailVerified: false });
  await expect(api('listIssuesForAdmin', {})).rejects.toBeInstanceOf(AccessLost);
  expect(ended).toBe(1);
  await backend.auth.signOut();
});

test('B5 emulator: a refusal about the input does not end the session', async () => {
  await createAdmin(email('admin'));
  const services = servicesFor(backend);
  expect(await signInAdmin(services, email('admin'), PASSWORD)).toBe('signed-in');
  let ended = 0;
  const api = adminApi(services.call, () => (ended += 1));
  await expect(api('publishIssue', { request_id: 'r1', issue_id: 'no-such-issue' })).rejects.toMatchObject({ code: 'functions/not-found' });
  expect(ended).toBe(0);
  await backend.auth.signOut();
});
