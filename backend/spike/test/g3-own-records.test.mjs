// SPIKE (DEC-003 OPEN). Group G3: own records only (T-03.6, T-07.1, SEC-CHK-05). Emulator only.
// A reader reads and changes only their own records. Another reader, a visitor, an admin account
// and an account carrying forged admin claims are refused (INV-11, SC-04, GS-Q20).
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { collection, deleteDoc, doc, getDoc, getDocs, setDoc, Timestamp } from 'firebase/firestore';
import {
  actors,
  bookmark,
  favourite,
  newTestEnv,
  NOT_READER_A,
  now,
  preference,
  SEED_BOOKMARK,
  seedFirestore,
} from './helpers.mjs';

let env;

before(async () => {
  env = await newTestEnv();
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await seedFirestore(env);
});

// The three entities a reader reads and writes directly (OP-07, OP-08, OP-09).
const OWNED = [
  { name: 'bookmarks', existing: SEED_BOOKMARK, fresh: 'i-pub_8', make: bookmark },
  { name: 'favourites', existing: 'i-pub', fresh: 'i-other', make: favourite },
  { name: 'notification_preferences', existing: 'n1', fresh: 'n2', make: preference },
];

for (const { name, existing, fresh, make } of OWNED) {
  const col = `users/reader-a/${name}`;

  test(`G3 ${name}: the owner can list, read, create, update and delete`, async () => {
    const db = actors.readerA(env).firestore();
    await assertSucceeds(getDocs(collection(db, col)));
    await assertSucceeds(getDoc(doc(db, `${col}/${existing}`)));
    const record = make('reader-a', fresh);
    await assertSucceeds(setDoc(doc(db, `${col}/${fresh}`), record));
    await assertSucceeds(setDoc(doc(db, `${col}/${fresh}`), record)); // a replayed write is harmless
    await assertSucceeds(deleteDoc(doc(db, `${col}/${fresh}`)));
  });

  for (const who of NOT_READER_A) {
    test(`G3 ${name}: ${who} cannot list, read, create, update or delete reader A's records`, async () => {
      const db = actors[who](env).firestore();
      await assertFails(getDocs(collection(db, col)));
      await assertFails(getDoc(doc(db, `${col}/${existing}`)));
      await assertFails(setDoc(doc(db, `${col}/${fresh}`), make('reader-a', fresh)));
      await assertFails(setDoc(doc(db, `${col}/${existing}`), make('reader-a', existing)));
      await assertFails(deleteDoc(doc(db, `${col}/${existing}`)));
    });
  }

  test(`G3 ${name}: reader B cannot write to their own path in reader A's name`, async () => {
    const db = actors.readerB(env).firestore();
    await assertFails(setDoc(doc(db, `users/reader-b/${name}/${fresh}`), make('reader-a', fresh)));
  });

  test(`G3 ${name}: a write with an extra field, a missing field or another user's identifier is refused`, async () => {
    const db = actors.readerA(env).firestore();
    const path = `${col}/${fresh}`;
    await assertFails(setDoc(doc(db, path), { ...make('reader-a', fresh), role: 'admin' }));
    const { created_at, ...withoutCreatedAt } = make('reader-a', fresh);
    await assertFails(setDoc(doc(db, path), withoutCreatedAt));
    await assertFails(setDoc(doc(db, path), make('reader-b', fresh)));
    await assertFails(setDoc(doc(db, path), make('reader-a', fresh, { created_at: 'yesterday' })));
  });
}

// Entity-specific fields (DATABASE_AND_DATA_MODEL.md sections 4.10, 4.11 and 4.13).
// Each bad value is tried as a fresh create, on its own document, whose key is otherwise right, so
// that the refusal can only come from the field check and not from another rule.
const BAD_BOOKMARK_FIELDS = [
  ['page_number 0', 'i-pub_0', { page_number: 0 }],
  ['page_number -1', 'i-pub_-1', { page_number: -1 }],
  ['page_number 1.5', 'i-pub_1.5', { page_number: 1.5 }],
  ['page_number as text', 'i-pub_9', { page_number: '9' }],
  ['page_number null', 'i-pub_9', { page_number: null }],
  ['file_revision 0', 'i-pub_9', { file_revision: 0 }],
  ['file_revision 1.5', 'i-pub_9', { file_revision: 1.5 }],
  ['file_revision as text', 'i-pub_9', { file_revision: '1' }],
  ['issue_id empty', '_9', { issue_id: '' }],
  ['issue_id a number', '12_9', { issue_id: 12 }],
];

test('G3 bookmarks: a good bookmark is accepted (control for the bad ones below)', async () => {
  const db = actors.readerA(env).firestore();
  await assertSucceeds(setDoc(doc(db, 'users/reader-a/bookmarks/i-pub_1'), bookmark('reader-a', 'i-pub_1')));
});

for (const [label, key, over] of BAD_BOOKMARK_FIELDS) {
  test(`G3 bookmarks: a new bookmark with ${label} is refused`, async () => {
    const db = actors.readerA(env).firestore();
    await assertFails(setDoc(doc(db, `users/reader-a/bookmarks/${key}`), bookmark('reader-a', key, over)));
  });
}

test('G3 bookmarks: the bookmark_id in the record must match the document key', async () => {
  const db = actors.readerA(env).firestore();
  await assertFails(setDoc(doc(db, 'users/reader-a/bookmarks/i-pub_9'), bookmark('reader-a', 'i-pub_9', { bookmark_id: 'i-pub_10' })));
});

test('G3 bookmarks: the document key must come from the issue and the page, so a page cannot be bookmarked twice', async () => {
  const db = actors.readerA(env).firestore();
  // The seed already bookmarks page 7 of i-pub. Another key for the same issue and page is refused.
  const other = bookmark('reader-a', 'another-key_7', { issue_id: 'i-pub', page_number: 7 });
  await assertFails(setDoc(doc(db, 'users/reader-a/bookmarks/another-key_7'), other));
  // The right key with the wrong page is refused as well.
  const wrongPage = bookmark('reader-a', 'i-pub_9', { page_number: 10 });
  await assertFails(setDoc(doc(db, 'users/reader-a/bookmarks/i-pub_9'), wrongPage));
});

test('G3 bookmarks: a replayed write with the same values passes and changes nothing', async () => {
  const db = actors.readerA(env).firestore();
  const path = 'users/reader-a/bookmarks/i-pub_1';
  const original = bookmark('reader-a', 'i-pub_1');
  await assertSucceeds(setDoc(doc(db, path), original));
  await assertSucceeds(setDoc(doc(db, path), original));
});

test('G3 bookmarks: adding the same page on a later revision is refused, so it keeps its first revision', async () => {
  const db = actors.readerA(env).firestore();
  const path = `users/reader-a/bookmarks/${SEED_BOOKMARK}`;
  await assertFails(setDoc(doc(db, path), bookmark('reader-a', SEED_BOOKMARK, { file_revision: 2 })));
  const stored = await getDoc(doc(db, path));
  assert.equal(stored.data().file_revision, 1);
});

test('G3 bookmarks: an update cannot change the issue, the page or the time', async () => {
  const db = actors.readerA(env).firestore();
  const path = `users/reader-a/bookmarks/${SEED_BOOKMARK}`;
  await assertFails(setDoc(doc(db, path), bookmark('reader-a', SEED_BOOKMARK, { issue_id: 'i-other' })));
  await assertFails(setDoc(doc(db, path), bookmark('reader-a', SEED_BOOKMARK, { page_number: 8 })));
  await assertFails(setDoc(doc(db, path), bookmark('reader-a', SEED_BOOKMARK, { created_at: Timestamp.fromMillis(1000) })));
});

test('G3 bookmarks: removing a bookmark and adding it again makes a new one on the later revision', async () => {
  const db = actors.readerA(env).firestore();
  const path = `users/reader-a/bookmarks/${SEED_BOOKMARK}`;
  await assertSucceeds(deleteDoc(doc(db, path)));
  await assertSucceeds(setDoc(doc(db, path), bookmark('reader-a', SEED_BOOKMARK, { file_revision: 2 })));
  assert.equal((await getDoc(doc(db, path))).data().file_revision, 2);
});

test('G3 favourites: the document key must match the issue in the record', async () => {
  const db = actors.readerA(env).firestore();
  await assertFails(setDoc(doc(db, 'users/reader-a/favourites/i-x'), favourite('reader-a', 'i-y')));
});

test('G3 notification preferences: the document key must match the category in the record', async () => {
  const db = actors.readerA(env).firestore();
  await assertFails(setDoc(doc(db, 'users/reader-a/notification_preferences/n9'), preference('reader-a', 'n8')));
});

// Records a reader can read but only a function writes (APP_USER, READER_PROFILE, CONSENT_RECORD).
const READ_ONLY_OWNED = ['users/reader-a', 'users/reader-a/profile/current', 'users/reader-a/consents/c1'];

for (const path of READ_ONLY_OWNED) {
  test(`G3 ${path}: the owner reads it but cannot write or delete it`, async () => {
    const db = actors.readerA(env).firestore();
    await assertSucceeds(getDoc(doc(db, path)));
    await assertFails(setDoc(doc(db, path), { user_id: 'reader-a', status: 'active' }));
    await assertFails(deleteDoc(doc(db, path)));
  });

  for (const who of NOT_READER_A) {
    test(`G3 ${path}: ${who} cannot read or write it`, async () => {
      const db = actors[who](env).firestore();
      await assertFails(getDoc(doc(db, path)));
      await assertFails(setDoc(doc(db, path), { user_id: 'reader-a' }));
    });
  }
}

test('G3 the owner cannot create a consent record, a profile or a new account record directly', async () => {
  const db = actors.readerA(env).firestore();
  await assertFails(setDoc(doc(db, 'users/reader-a/consents/c2'), { consent_id: 'c2', user_id: 'reader-a' }));
  await assertFails(setDoc(doc(db, 'users/reader-a/profile/other'), { user_id: 'reader-a' }));
  await assertFails(setDoc(doc(db, 'users/reader-a'), { user_id: 'reader-a', status: 'active', created_at: now() }));
});

// ---- Behaviour the documents describe or leave open. The tests name it; they do not hide it. ----

test('G3 A-5: a reader whose account is being deleted can still use the direct operations (documented, SECURITY T25)', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/reader-a'), { user_id: 'reader-a', status: 'deleting' });
  });
  const db = actors.readerA(env).firestore();
  await assertSucceeds(setDoc(doc(db, 'users/reader-a/bookmarks/i-pub_3'), bookmark('reader-a', 'i-pub_3')));
});

test('G3 A-10 known gap: the rules do not check that the issue or category exists (no rule reads another document)', async () => {
  const db = actors.readerA(env).firestore();
  await assertSucceeds(setDoc(doc(db, 'users/reader-a/favourites/no-such-issue'), favourite('reader-a', 'no-such-issue')));
  await assertSucceeds(
    setDoc(doc(db, 'users/reader-a/notification_preferences/no-such-category'), preference('reader-a', 'no-such-category')),
  );
  await assertSucceeds(
    setDoc(doc(db, 'users/reader-a/bookmarks/no-such-issue_1'), bookmark('reader-a', 'no-such-issue_1')),
  );
});
