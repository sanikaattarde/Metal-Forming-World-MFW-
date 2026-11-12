// Group G21: the account-linking spike (MOD03-P3-T01; OQ-04 and OQ-05 working positions, TD-06). How the
// Auth emulator treats one email address used with a password and with Google. Google sign-ins use the
// emulator's test credentials (an unsigned token), which only the emulator accepts. Whether the real service
// behaves the same depends on the project's "one account per email address" setting and is NOT VERIFIED
// until ENV-TEST exists. Synthetic addresses only. Emulator only.
import { test, before, after, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { deleteApp, initializeApp } from 'firebase/app';
import {
  connectAuthEmulator,
  createUserWithEmailAndPassword,
  getAuth,
  GoogleAuthProvider,
  linkWithCredential,
  signInWithCredential,
  signInWithEmailAndPassword,
  signOut,
} from 'firebase/auth';
import { AUTH_BASE, clearAuthAccounts, PROJECT_ID, verifyEmail } from './helpers.mjs';

const PASSWORD = 'test-password-1';
let app;
let auth;
let counter = 0;

const google = (email, { verified = true, sub } = {}) =>
  GoogleAuthProvider.credential(JSON.stringify({ sub: sub ?? `google-${email}`, email, email_verified: verified }));

const providers = (user) => user.providerData.map((p) => p.providerId).sort();

async function outcome(run) {
  try {
    const result = await run();
    return { ok: true, uid: result.user.uid, providers: providers(result.user) };
  } catch (error) {
    return { ok: false, code: error.code };
  }
}

before(() => {
  app = initializeApp({ apiKey: 'fake-key', projectId: PROJECT_ID }, `linking-${(counter += 1)}`);
  auth = getAuth(app);
  connectAuthEmulator(auth, AUTH_BASE, { disableWarnings: true });
});

after(async () => {
  await deleteApp(app);
});

beforeEach(async () => {
  await clearAuthAccounts();
});

afterEach(async () => {
  await signOut(auth);
});

async function passwordAccount(email, { verified }) {
  const { user } = await createUserWithEmailAndPassword(auth, email, PASSWORD);
  if (verified) await verifyEmail(user.uid);
  await signOut(auth);
  return user.uid;
}

const report = (name, value) => console.log(`LINKING ${name}: ${JSON.stringify(value)}`);

test('G21 A: a verified password account, then Google with the same address', async () => {
  const uid = await passwordAccount('a@example.test', { verified: true });
  const google1 = await outcome(() => signInWithCredential(auth, google('a@example.test')));
  report('A', { passwordUid: uid, google: google1 });
  // Joined to the same account, with both ways in (OQ-05 working position).
  assert.equal(google1.uid, uid);
  assert.deepEqual(google1.providers, ['google.com', 'password']);
});

test('G21 B: an unverified password account, then Google with the same address', async () => {
  const uid = await passwordAccount('b@example.test', { verified: false });
  const google1 = await outcome(() => signInWithCredential(auth, google('b@example.test')));
  await signOut(auth);
  const passwordAfter = await outcome(() => signInWithEmailAndPassword(auth, 'b@example.test', PASSWORD));
  report('B', { passwordUid: uid, google: google1, passwordAfter });
  // Google takes the account over and the unverified password stops working.
  assert.equal(google1.uid, uid);
  assert.deepEqual(google1.providers, ['google.com']);
  assert.equal(passwordAfter.code, 'auth/wrong-password');
});

test('G21 C: Google first, then a password sign-up with the same address', async () => {
  const google1 = await outcome(() => signInWithCredential(auth, google('c@example.test')));
  await signOut(auth);
  const signUp = await outcome(() => createUserWithEmailAndPassword(auth, 'c@example.test', PASSWORD));
  report('C', { google: google1, passwordSignUp: signUp });
  assert.equal(signUp.code, 'auth/email-already-in-use');
});

test('G21 D: signed in with a verified password, the reader links Google', async () => {
  const uid = await passwordAccount('d@example.test', { verified: true });
  await signInWithEmailAndPassword(auth, 'd@example.test', PASSWORD);
  const linked = await outcome(() => linkWithCredential(auth.currentUser, google('d@example.test')));
  await signOut(auth);
  const googleAfter = await outcome(() => signInWithCredential(auth, google('d@example.test')));
  report('D', { passwordUid: uid, link: linked, googleAfter });
  assert.equal(linked.uid, uid);
  assert.equal(googleAfter.uid, uid);
});

test('G21 E: a Google account whose address Google has not verified', async () => {
  const google1 = await outcome(() => signInWithCredential(auth, google('e@example.test', { verified: false })));
  report('E', { google: google1, emailVerified: auth.currentUser?.emailVerified ?? null });
  // The app then shows the verify step, as for a password account (TD-06).
  assert.equal(auth.currentUser?.emailVerified, false);
});

test('G21 F: Google with a verified address gives a verified account (OQ-04)', async () => {
  const google1 = await outcome(() => signInWithCredential(auth, google('f@example.test')));
  report('F', { google: google1, emailVerified: auth.currentUser?.emailVerified ?? null });
  assert.ok(google1.ok);
  assert.equal(auth.currentUser?.emailVerified, true);
});
