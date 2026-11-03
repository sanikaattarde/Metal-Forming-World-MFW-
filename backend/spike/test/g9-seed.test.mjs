// SPIKE (DEC-003 OPEN; GS-Q47 PROPOSED; OQ-18 OPEN). Group G9: the seed definitions in the emulator
// (MOD13-P1-T10) and OP-05 listNotificationCategories, a direct read by anyone. Emulator only.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { collection, deleteDoc, doc, getDoc, getDocs, orderBy, query, setDoc, updateDoc } from 'firebase/firestore';
import { actors, adminBackend, EVERY_ACTOR, newTestEnv } from './helpers.mjs';
import { loadSeed, SEED } from '../seed/seed.mjs';

const LOADER = new URL('../seed/load.mjs', import.meta.url).pathname;
const runLoader = (env) => spawnSync(process.execPath, [LOADER], { encoding: 'utf8', env, timeout: 20_000 });

const EXPECTED = [...SEED.notification_categories]
  .sort((a, b) => a.display_order - b.display_order)
  .map((entry) => ({ id: entry.category_id, ...entry }));

let env;
let db;

const stored = async () =>
  (await db.collection('notification_categories').orderBy('display_order').get()).docs.map((d) => ({ id: d.id, ...d.data() }));

before(async () => {
  env = await newTestEnv();
  db = adminBackend().db;
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await loadSeed(db);
});

// ---- OP-05 ----

for (const who of EVERY_ACTOR) {
  test(`G9 OP-05: ${who} lists exactly the three categories, in display order`, async () => {
    const client = actors[who](env).firestore();
    const snap = await assertSucceeds(getDocs(query(collection(client, 'notification_categories'), orderBy('display_order'))));
    assert.deepEqual(snap.docs.map((d) => ({ id: d.id, ...d.data() })), EXPECTED);
    const one = await assertSucceeds(getDoc(doc(client, `notification_categories/${EXPECTED[0].id}`)));
    assert.equal(one.get('name'), EXPECTED[0].name);
  });

  // An admin is refused too: on the working position admins cannot change the list (GS-Q47).
  test(`G9 OP-05: ${who} cannot add, change, switch off or remove a category`, async () => {
    const client = actors[who](env).firestore();
    const first = doc(client, `notification_categories/${EXPECTED[0].id}`);
    await assertFails(setDoc(doc(client, 'notification_categories/notif-fourth'), { category_id: 'notif-fourth', name: 'Fourth', display_order: 4, is_active: true }));
    await assertFails(updateDoc(first, { name: 'Renamed' }));
    await assertFails(updateDoc(first, { is_active: false }));
    await assertFails(setDoc(first, { ...SEED.notification_categories[0] }));
    await assertFails(deleteDoc(first));
    assert.deepEqual(await stored(), EXPECTED);
  });
}

// ---- The loader ----

test('G9 the loader: loading again changes nothing', async () => {
  const result = await loadSeed(db);
  assert.deepEqual(result, { written: SEED.notification_categories.map((entry) => entry.category_id), others: [] });
  assert.deepEqual(await stored(), EXPECTED);
});

test('G9 the loader: a changed record is put back as the seed has it', async () => {
  await db.doc(`notification_categories/${EXPECTED[0].id}`).update({ name: 'Changed', is_active: false, extra: 1 });
  await loadSeed(db);
  assert.deepEqual(await stored(), EXPECTED);
});

test('G9 the loader: a record that is not in the seed is left alone and named', async () => {
  await db.doc('notification_categories/notif-old').set({ category_id: 'notif-old', name: 'Old', display_order: 9, is_active: false });
  const { others } = await loadSeed(db);
  assert.deepEqual(others, ['notif-old']);
  assert.equal((await db.doc('notification_categories/notif-old').get()).exists, true);
});

test('G9 the loader: a seed that is not usable writes nothing', async () => {
  await env.clearFirestore();
  const bad = structuredClone(SEED);
  bad.notification_categories[2].category_id = bad.notification_categories[0].category_id;
  await assert.rejects(loadSeed(db, bad), /The seed is not usable/);
  assert.equal((await db.collection('notification_categories').get()).size, 0);
});

// ---- The command, as B6 will use it ----

test('G9 the command loads the emulator named in firebase.json', async () => {
  await env.clearFirestore();
  const childEnv = { ...process.env };
  delete childEnv.FIRESTORE_EMULATOR_HOST;
  const run = runLoader(childEnv);
  assert.equal(run.status, 0, run.stderr);
  assert.match(run.stdout, /Loaded into the emulator at 127\.0\.0\.1:8080/);
  assert.deepEqual(await stored(), EXPECTED);
});

test('G9 the command refuses an address that is not a local emulator, and writes nothing', async () => {
  await env.clearFirestore();
  // 192.0.2.1 is a documentation address that nothing answers on.
  const run = runLoader({ ...process.env, FIRESTORE_EMULATOR_HOST: '192.0.2.1:8080' });
  assert.equal(run.status, 2, `status ${run.status}, signal ${run.signal}`);
  assert.match(run.stderr, /Refused: 192\.0\.2\.1:8080 is not a local emulator address/);
  assert.equal((await db.collection('notification_categories').get()).size, 0);
});
