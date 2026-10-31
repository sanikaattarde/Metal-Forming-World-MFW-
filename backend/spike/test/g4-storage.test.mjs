// SPIKE (DEC-003 and DEC-020 OPEN). Group G4: the file store (SC-07, SEC-CHK-02, SEC-CHK-03). Emulator only.
// The private area has no client read or write. The cover area is public read with no client write.
// The holding area has no client read, and no client write through the rules (the backend's signed
// upload URL is checked by the store, not by these rules, and is not tested here).
// Not tested here: another reader's grant and an expired grant. They need a real signed link (UA-3).
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { dirname } from 'node:path';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { deleteObject, getBytes, listAll, ref, uploadString } from 'firebase/storage';
import { actors, EVERY_ACTOR, newTestEnv, seedStorage, STORAGE_FILES } from './helpers.mjs';

let env;

before(async () => {
  env = await newTestEnv();
  await env.clearStorage();
  await seedStorage(env);
});

after(async () => {
  await env.cleanup();
});

// Control: with the rules switched off every seeded file can be read, so a refusal below
// can only come from the rules.
test('G4 control: the seeded files exist and are readable with the rules switched off', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    for (const path of Object.values(STORAGE_FILES)) {
      const bytes = await getBytes(ref(context.storage(), path));
      assert.equal(bytes.byteLength, 'control-bytes'.length, path);
    }
  });
});

const NO_CLIENT_ACCESS = [
  ['the private issue file', STORAGE_FILES.privatePdf],
  ['a guessed private path', 'issues/guessed-id/1.pdf'],
  ['the holding area', STORAGE_FILES.holding],
  ['an unlisted path', 'other/x'],
];

for (const [label, path] of NO_CLIENT_ACCESS) {
  for (const who of EVERY_ACTOR) {
    test(`G4 ${label}: read, write and delete refused for ${who}`, async () => {
      const storage = actors[who](env).storage();
      await assertFails(getBytes(ref(storage, path)));
      await assertFails(uploadString(ref(storage, path), 'x'));
      await assertFails(deleteObject(ref(storage, path)));
    });
  }
}

// Listing is its own permission. SEC-CHK-03 says "readable or listable".
const PRIVATE_FOLDER = dirname(STORAGE_FILES.privatePdf);

test('G4 control: with the rules switched off, listing the folder finds the private file', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const { items } = await listAll(ref(context.storage(), PRIVATE_FOLDER));
    assert.deepEqual(items.map((item) => item.fullPath), [STORAGE_FILES.privatePdf]);
  });
});

const NO_CLIENT_LISTING = [
  ['the whole file store', ''],
  ['the private area', 'issues'],
  ['the folder of an issue', PRIVATE_FOLDER],
  ['the holding area', dirname(STORAGE_FILES.holding)],
];

for (const [label, folder] of NO_CLIENT_LISTING) {
  for (const who of EVERY_ACTOR) {
    test(`G4 listing ${label}: refused for ${who}`, async () => {
      await assertFails(listAll(ref(actors[who](env).storage(), folder)));
    });
  }
}

for (const who of EVERY_ACTOR) {
  test(`G4 the cover area: ${who} can read a cover but cannot write or delete one`, async () => {
    const storage = actors[who](env).storage();
    const bytes = await assertSucceeds(getBytes(ref(storage, STORAGE_FILES.cover)));
    assert.equal(bytes.byteLength, 'control-bytes'.length);
    await assertFails(uploadString(ref(storage, STORAGE_FILES.cover), 'x'));
    await assertFails(uploadString(ref(storage, 'covers/i-pub/v2'), 'x'));
    await assertFails(deleteObject(ref(storage, STORAGE_FILES.cover)));
  });
}
