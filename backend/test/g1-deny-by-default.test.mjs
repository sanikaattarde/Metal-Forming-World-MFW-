// Group G1: deny by default (SC-05, SEC-CHK-05). Emulator only.
// Entities with no client access, and paths no rule lists, are refused for every actor,
// including an admin account and an account that carries forged admin claims (SC-04, GS-Q20).
import { test, before, after } from 'node:test';
import { assertFails } from '@firebase/rules-unit-testing';
import { collection, collectionGroup, deleteDoc, doc, getDoc, getDocs, setDoc } from 'firebase/firestore';
import { actors, EVERY_ACTOR, newTestEnv, seedFirestore } from './helpers.mjs';

let env;

before(async () => {
  env = await newTestEnv();
  await env.clearFirestore();
  await seedFirestore(env);
});

after(async () => {
  await env.cleanup();
});

// Entities the data model gives no client access (DATABASE_AND_DATA_MODEL.md section 19).
const NO_CLIENT_ACCESS = [
  'admin_roles/admin-1',
  'admin_audit/e1',
  'admin_guard/current',
  'upload_jobs/j1',
  'notification_sends/s1',
  'edition_updates/e1',
  'config/private',
  'issues/i-pub/files/1', // ISSUE_FILE: never readable by a client
  'issues/i-unpub', // an unpublished issue
];

// Paths no rule lists.
const UNLISTED = ['unlisted/x', 'users/reader-a/unlisted/x', 'issues/i-pub/other/x', 'config/other'];

for (const path of [...NO_CLIENT_ACCESS, ...UNLISTED]) {
  for (const who of EVERY_ACTOR) {
    test(`G1 ${path}: read, write and delete refused for ${who}`, async () => {
      const db = actors[who](env).firestore();
      await assertFails(getDoc(doc(db, path)));
      await assertFails(setDoc(doc(db, path), { a: 1 }));
      await assertFails(deleteDoc(doc(db, path)));
    });
  }
}

for (const name of ['admin_roles', 'admin_audit', 'upload_jobs', 'notification_sends', 'edition_updates', 'emulator_push_outbox', 'emulator_push', 'issue_deletion_requests', 'rate_limits', 'unlisted']) {
  for (const who of EVERY_ACTOR) {
    test(`G1 listing the ${name} collection is refused for ${who}`, async () => {
      const db = actors[who](env).firestore();
      await assertFails(getDocs(collection(db, name)));
    });
  }
}

// A collection-group query must not let a reader scan other readers' records.
for (const name of ['bookmarks', 'favourites', 'notification_preferences', 'files', 'profile', 'consents']) {
  for (const who of EVERY_ACTOR) {
    test(`G1 a collection-group query on ${name} is refused for ${who}`, async () => {
      const db = actors[who](env).firestore();
      await assertFails(getDocs(collectionGroup(db, name)));
    });
  }
}
