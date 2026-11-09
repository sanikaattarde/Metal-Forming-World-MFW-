// Group G2: public reads, no client write (SC-05). Emulator only.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { collection, deleteDoc, doc, getDoc, getDocs, query, setDoc, where } from 'firebase/firestore';
import { actors, EVERY_ACTOR, newTestEnv, SEED_CATEGORIES, seedFirestore } from './helpers.mjs';

let env;

before(async () => {
  env = await newTestEnv();
  await env.clearFirestore();
  await seedFirestore(env);
});

after(async () => {
  await env.cleanup();
});

// [existing document, a new document in the same collection]
const PUBLIC = [
  ['segments/s1', 'segments/new'],
  ['categories/c1', 'categories/new'],
  [`notification_categories/${SEED_CATEGORIES[0]}`, 'notification_categories/new'],
  ['news_controls/101', 'news_controls/999'],
  ['deleted_issues/i-gone', 'deleted_issues/new'],
  ['config/public', 'config/public-new'],
  ['issues/i-pub', 'issues/new'],
];

for (const [existing, fresh] of PUBLIC) {
  for (const who of EVERY_ACTOR) {
    test(`G2 ${existing}: anyone reads; ${who} cannot create, change or delete`, async () => {
      const db = actors[who](env).firestore();
      await assertSucceeds(getDoc(doc(db, existing)));
      await assertFails(setDoc(doc(db, fresh), { name: 'x', publication_state: 'published' }));
      await assertFails(setDoc(doc(db, existing), { name: 'changed' }));
      await assertFails(deleteDoc(doc(db, existing)));
    });
  }
}

for (const who of EVERY_ACTOR) {
  test(`G2 issues: ${who} lists published issues only, with the filter`, async () => {
    const db = actors[who](env).firestore();
    const published = query(collection(db, 'issues'), where('publication_state', '==', 'published'));
    const snap = await assertSucceeds(getDocs(published));
    assert.deepEqual(snap.docs.map((d) => d.id), ['i-pub']);
    // The segment links are the array on the issue (DATABASE_AND_DATA_MODEL.md section 12).
    assert.deepEqual(snap.docs[0].data().segment_ids, ['s1']);
  });

  test(`G2 issues: ${who} cannot list without the filter or list the unpublished ones`, async () => {
    const db = actors[who](env).firestore();
    await assertFails(getDocs(collection(db, 'issues')));
    await assertFails(getDocs(query(collection(db, 'issues'), where('publication_state', '==', 'unpublished'))));
  });
}
