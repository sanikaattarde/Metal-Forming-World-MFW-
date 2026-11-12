// Group G19: IC-04 on the emulators (MOD08-P2-T03). One reader signed in on two devices sees the same
// bookmarks and favourites as they change; another reader's device never sees them; and account deletion
// removes them from both devices' view (RS FR-BKM-005, FR-BKM-007, FR-FAV-003, FR-AUTH-009, IC-04, IC-08).
// Each "device" is its own client SDK app, signed in through the Auth emulator, as the app's adapter is.
// Synthetic accounts only. Emulator only.
import { test, before, after, beforeEach, afterEach } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { deleteApp, initializeApp } from 'firebase/app';
import { connectAuthEmulator, getAuth, signInWithEmailAndPassword } from 'firebase/auth';
import {
  collection,
  connectFirestoreEmulator,
  deleteDoc,
  doc,
  getDocs,
  getFirestore,
  onSnapshot,
  setDoc,
  terminate,
} from 'firebase/firestore';
import { adminBackend, AUTH_BASE, bookmark, callFunction, clearAuthAccounts, favourite, newTestEnv, PROJECT_ID, signUp, verifyEmail } from './helpers.mjs';

const config = JSON.parse(readFileSync(new URL('../firebase.json', import.meta.url), 'utf8'));
const PASSWORD = 'test-password-1';

let env;
let db;
let devices = [];
let counter = 0;

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
});

afterEach(async () => {
  for (const device of devices) {
    await terminate(device.firestore).catch(() => undefined);
    await deleteApp(device.app).catch(() => undefined);
  }
  devices = [];
});

// A device signed in as `email`, through the emulators.
async function device(email) {
  const app = initializeApp({ apiKey: 'fake-key', projectId: PROJECT_ID }, `device-${(counter += 1)}`);
  const auth = getAuth(app);
  connectAuthEmulator(auth, AUTH_BASE, { disableWarnings: true });
  const firestore = getFirestore(app);
  connectFirestoreEmulator(firestore, config.emulators.firestore.host, config.emulators.firestore.port);
  const { user } = await signInWithEmailAndPassword(auth, email, PASSWORD);
  const made = { app, auth, firestore, uid: user.uid };
  devices.push(made);
  return made;
}

// The latest snapshot of a collection, as the app's watch sees it.
function watch(firestore, path) {
  const state = { ids: null, error: null, waiters: [] };
  const stop = onSnapshot(
    collection(firestore, path),
    (snap) => {
      state.ids = snap.docs.map((d) => d.id).sort();
      state.waiters.splice(0).forEach((w) => w());
    },
    (error) => {
      state.error = error.code;
      state.waiters.splice(0).forEach((w) => w());
    },
  );
  const until = async (check) => {
    const end = Date.now() + 5000;
    while (!check(state)) {
      if (Date.now() > end) throw new Error(`watch of ${path} never reached the state: ${JSON.stringify(state.ids)} ${state.error}`);
      await new Promise((resolve) => {
        state.waiters.push(resolve);
        setTimeout(resolve, 200);
      });
    }
    return state;
  };
  return { until, stop };
}

async function reader(email) {
  const account = await signUp(email);
  await verifyEmail(account.uid);
  return account;
}

test('G19 IC-04: a bookmark and a favourite made on one device show on the reader\'s other device', async () => {
  const a = await reader('reader-a@example.test');
  const phone = await device('reader-a@example.test');
  const tablet = await device('reader-a@example.test');
  assert.equal(phone.uid, a.uid);
  assert.equal(tablet.uid, a.uid);

  const bookmarks = watch(tablet.firestore, `users/${a.uid}/bookmarks`);
  const favourites = watch(tablet.firestore, `users/${a.uid}/favourites`);
  await bookmarks.until((s) => s.ids !== null);

  await setDoc(doc(phone.firestore, `users/${a.uid}/bookmarks/i-pub_7`), bookmark(a.uid, 'i-pub_7'));
  await setDoc(doc(phone.firestore, `users/${a.uid}/favourites/i-pub`), favourite(a.uid, 'i-pub'));
  await bookmarks.until((s) => s.ids?.includes('i-pub_7'));
  await favourites.until((s) => s.ids?.includes('i-pub'));

  // A removal on the second device reaches the first.
  const onPhone = watch(phone.firestore, `users/${a.uid}/bookmarks`);
  await onPhone.until((s) => s.ids?.includes('i-pub_7'));
  await deleteDoc(doc(tablet.firestore, `users/${a.uid}/bookmarks/i-pub_7`));
  await onPhone.until((s) => s.ids?.length === 0);
  bookmarks.stop();
  favourites.stop();
  onPhone.stop();
});

test('G19 IC-04 isolation: another reader\'s device can neither see nor write reader A\'s records', async () => {
  const a = await reader('reader-a@example.test');
  await reader('reader-b@example.test');
  const phoneA = await device('reader-a@example.test');
  const phoneB = await device('reader-b@example.test');
  await setDoc(doc(phoneA.firestore, `users/${a.uid}/bookmarks/i-pub_7`), bookmark(a.uid, 'i-pub_7'));

  await assert.rejects(getDocs(collection(phoneB.firestore, `users/${a.uid}/bookmarks`)), { code: 'permission-denied' });
  const peek = watch(phoneB.firestore, `users/${a.uid}/favourites`);
  await peek.until((s) => s.error === 'permission-denied');
  peek.stop();
  await assert.rejects(
    setDoc(doc(phoneB.firestore, `users/${a.uid}/bookmarks/i-pub_8`), bookmark(a.uid, 'i-pub_8')),
    { code: 'permission-denied' },
  );
  // Reader B's own list stays empty.
  assert.equal((await getDocs(collection(phoneB.firestore, `users/${phoneB.uid}/bookmarks`))).size, 0);
});

test('G19 IC-08: account deletion removes the records, and the other device sees the list emptied', async () => {
  const a = await reader('reader-a@example.test');
  const phone = await device('reader-a@example.test');
  const tablet = await device('reader-a@example.test');
  await setDoc(doc(phone.firestore, `users/${a.uid}/bookmarks/i-pub_7`), bookmark(a.uid, 'i-pub_7'));
  await setDoc(doc(phone.firestore, `users/${a.uid}/favourites/i-pub`), favourite(a.uid, 'i-pub'));
  const onTablet = watch(tablet.firestore, `users/${a.uid}/bookmarks`);
  await onTablet.until((s) => s.ids?.includes('i-pub_7'));

  const token = await phone.auth.currentUser.getIdToken();
  const reply = await callFunction('requestAccountDeletion', { request_id: 'g19-1', confirm: true }, token);
  assert.equal(reply.status, 200, reply.raw);

  assert.equal((await db.collection(`users/${a.uid}/bookmarks`).get()).size, 0);
  assert.equal((await db.collection(`users/${a.uid}/favourites`).get()).size, 0);
  // The second device either sees the list emptied or loses access; it never keeps the records.
  const seen = await onTablet.until((s) => s.error !== null || s.ids?.length === 0);
  assert.ok(seen.error === 'permission-denied' || seen.ids.length === 0, JSON.stringify(seen));
  onTablet.stop();
});
