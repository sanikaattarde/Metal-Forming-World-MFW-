// Group G20: the full allowed and refused rule matrix (MOD13-P2-T01, TESTING_STRATEGY.md section 9;
// SECURITY_AND_ACCESS_CONTROL.md section 12). Every client operation on every kind of record and file, for
// each access state of FX-USR-01 to FX-USR-05, a visitor (FX-USR-09), another reader, an admin, a removed
// admin and a reader carrying admin-looking claims. Each cell is checked against the expected result, and
// the run prints the matrix (lines starting "MATRIX ") for the evidence record.
//
// The rules know only the signed-in identity: whether the address is verified, the profile complete or the
// sign-in made with Google changes nothing at this level. Those steps are enforced by the app and the
// functions (SECURITY_AND_ACCESS_CONTROL.md section 13; threat T25). Admins have no direct access (GS-Q20).
// Synthetic data only. Emulator only.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  setDoc,
  where,
} from 'firebase/firestore';
import { deleteObject, getBytes, ref, uploadString } from 'firebase/storage';
import { bookmark, favourite, newTestEnv, now, preference, SEED_CATEGORIES, seedFirestore, seedStorage, STORAGE_FILES } from './helpers.mjs';

// Each actor: its identity, and whose records are its own.
const ACTORS = {
  'FX-USR-09 visitor': { uid: null },
  'FX-USR-01 full access': { uid: 'reader-a', token: { email_verified: true } },
  'FX-USR-02 not verified': { uid: 'usr-02', token: { email_verified: false } },
  'FX-USR-03 profile incomplete': { uid: 'usr-03', token: { email_verified: true } },
  'FX-USR-04 Google': { uid: 'usr-04', token: { email_verified: true, firebase: { sign_in_provider: 'google.com' } } },
  'FX-USR-05 Google, incomplete': { uid: 'usr-05', token: { email_verified: true, firebase: { sign_in_provider: 'google.com' } } },
  'another reader': { uid: 'reader-b', token: { email_verified: true } },
  admin: { uid: 'admin-1', token: { email_verified: true } },
  'removed admin': { uid: 'admin-2', token: { email_verified: true } },
  'admin-looking claims': { uid: 'reader-c', token: { email_verified: true, admin: true, role: 'admin', is_admin: true } },
};

const SERVER_ONLY = [
  'admin_roles/admin-1',
  'admin_audit/e1',
  'admin_guard/current',
  'upload_jobs/j1',
  'notification_sends/s1',
  'edition_updates/e1',
  'issue_deletion_requests/r1',
  'rate_limits/c__reader-a',
  'config/private',
  'issues/i-pub/files/1',
];
const PUBLIC = ['segments/s1', 'categories/c1', `notification_categories/${SEED_CATEGORIES[0]}`, 'news_controls/101', 'deleted_issues/i-gone', 'config/public'];

let env;
const cells = [];

before(async () => {
  env = await newTestEnv();
  await env.clearFirestore();
  await env.clearStorage();
  await seedFirestore(env);
  await seedStorage(env);
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'admin_roles/admin-2'), { user_id: 'admin-2', is_active: false });
    await setDoc(doc(db, 'issue_deletion_requests/r1'), { issue_id: 'i-gone' });
    await setDoc(doc(db, 'rate_limits/c__reader-a'), { count: 1 });
    // Own records for the other personas, as reader A has.
    for (const uid of ['usr-02', 'usr-03', 'usr-04', 'usr-05', 'reader-c', 'admin-1', 'admin-2']) {
      await setDoc(doc(db, `users/${uid}`), { user_id: uid, status: 'active', created_at: now() });
      await setDoc(doc(db, `users/${uid}/profile/current`), { user_id: uid, full_name: 'Test Reader' });
      await setDoc(doc(db, `users/${uid}/bookmarks/i-pub_7`), bookmark(uid, 'i-pub_7'));
      await setDoc(doc(db, `users/${uid}/favourites/i-pub`), favourite(uid, 'i-pub'));
      await setDoc(doc(db, `users/${uid}/notification_preferences/${SEED_CATEGORIES[0]}`), preference(uid, SEED_CATEGORIES[0]));
    }
  });
});

after(async () => {
  // The matrix, one line per actor and area, for the evidence record.
  const areas = [...new Set(cells.map((c) => c.area))];
  console.log(`MATRIX | Actor | ${areas.join(' | ')} |`);
  for (const actor of Object.keys(ACTORS)) {
    const row = areas.map((area) => {
      const mine = cells.filter((c) => c.actor === actor && c.area === area);
      if (mine.length === 0) return 'n/a';
      const allowed = mine.filter((c) => c.expect === 'allow').map((c) => c.op);
      const label = allowed.length === 0 ? 'all refused' : `allowed: ${[...new Set(allowed)].join(', ')}`;
      return mine.every((c) => c.ok) ? label : `MISMATCH (${mine.filter((c) => !c.ok).map((c) => c.op).join(', ')})`;
    });
    console.log(`MATRIX | ${actor} | ${row.join(' | ')} |`);
  }
  console.log(`MATRIX total ${cells.length}, matching ${cells.filter((c) => c.ok).length}`);
  await env.cleanup();
});

const context = ({ uid, token }) => (uid === null ? env.unauthenticatedContext() : env.authenticatedContext(uid, token));

async function check(actor, area, op, expect, run) {
  let ok = true;
  try {
    await (expect === 'allow' ? assertSucceeds(run()) : assertFails(run()));
  } catch {
    ok = false;
  }
  cells.push({ actor, area, op, expect, ok });
  assert.ok(ok, `${actor}: ${area} ${op} should be ${expect === 'allow' ? 'allowed' : 'refused'}`);
}

for (const [actor, who] of Object.entries(ACTORS)) {
  test(`G20 ${actor}: public records are read by anyone and written by no client`, async () => {
    const db = context(who).firestore();
    for (const path of PUBLIC) {
      await check(actor, 'Public records', 'read', 'allow', () => getDoc(doc(db, path)));
      await check(actor, 'Public records', 'write', 'deny', () => setDoc(doc(db, path), { x: 1 }));
      await check(actor, 'Public records', 'delete', 'deny', () => deleteDoc(doc(db, path)));
    }
  });

  test(`G20 ${actor}: published issues only, through a filtered query; no write`, async () => {
    const db = context(who).firestore();
    await check(actor, 'Issues', 'read published', 'allow', () => getDoc(doc(db, 'issues/i-pub')));
    await check(actor, 'Issues', 'list published', 'allow', () => getDocs(query(collection(db, 'issues'), where('publication_state', '==', 'published'))));
    await check(actor, 'Issues', 'read unpublished', 'deny', () => getDoc(doc(db, 'issues/i-unpub')));
    await check(actor, 'Issues', 'list all', 'deny', () => getDocs(collection(db, 'issues')));
    await check(actor, 'Issues', 'write', 'deny', () => setDoc(doc(db, 'issues/i-new'), { title: 'x', publication_state: 'published' }));
  });

  if (who.uid !== null) {
    test(`G20 ${actor}: own records`, async () => {
      const db = context(who).firestore();
      const me = `users/${who.uid}`;
      await check(actor, 'Own records', 'read account, profile', 'allow', () => getDoc(doc(db, `${me}/profile/current`)));
      await check(actor, 'Own records', 'read account, profile', 'allow', () => getDoc(doc(db, me)));
      await check(actor, 'Own records', 'write account, profile', 'deny', () => setDoc(doc(db, `${me}/profile/current`), { full_name: 'x' }));
      await check(actor, 'Own records', 'read bookmarks, favourites, preferences', 'allow', () => getDocs(collection(db, `${me}/bookmarks`)));
      await check(actor, 'Own records', 'create valid', 'allow', () => setDoc(doc(db, `${me}/bookmarks/i-pub_9`), bookmark(who.uid, 'i-pub_9')));
      await check(actor, 'Own records', 'create valid', 'allow', () => setDoc(doc(db, `${me}/favourites/i-new`), favourite(who.uid, 'i-new')));
      await check(actor, 'Own records', 'create invalid', 'deny', () => setDoc(doc(db, `${me}/bookmarks/i-pub_10`), bookmark(who.uid, 'i-pub_10', { role: 'admin' })));
      await check(actor, 'Own records', 'change stored', 'deny', () => setDoc(doc(db, `${me}/bookmarks/i-pub_7`), bookmark(who.uid, 'i-pub_7', { file_revision: 9 })));
      await check(actor, 'Own records', 'delete', 'allow', () => deleteDoc(doc(db, `${me}/favourites/i-pub`)));
      await check(actor, 'Own records', 'delete', 'allow', () => deleteDoc(doc(db, `${me}/notification_preferences/${SEED_CATEGORIES[0]}`)));
    });
  }

  if (who.uid !== 'reader-a') {
    test(`G20 ${actor}: reader A's records are closed`, async () => {
      const db = context(who).firestore();
      const a = 'users/reader-a';
      await check(actor, "Reader A's records", 'read', 'deny', () => getDoc(doc(db, `${a}/profile/current`)));
      await check(actor, "Reader A's records", 'read', 'deny', () => getDocs(collection(db, `${a}/bookmarks`)));
      await check(actor, "Reader A's records", 'write', 'deny', () => setDoc(doc(db, `${a}/favourites/i-x`), favourite('reader-a', 'i-x')));
      await check(actor, "Reader A's records", 'delete', 'deny', () => deleteDoc(doc(db, `${a}/bookmarks/i-pub_7`)));
    });
  }

  test(`G20 ${actor}: server-only records are closed to every client`, async () => {
    const db = context(who).firestore();
    for (const path of SERVER_ONLY) {
      await check(actor, 'Server-only records', 'read', 'deny', () => getDoc(doc(db, path)));
      await check(actor, 'Server-only records', 'write', 'deny', () => setDoc(doc(db, path), { x: 1 }));
    }
    await check(actor, 'Server-only records', 'list roles', 'deny', () => getDocs(collection(db, 'admin_roles')));
  });

  test(`G20 ${actor}: files`, async () => {
    const storage = context(who).storage();
    await check(actor, 'Files', 'read cover', 'allow', () => getBytes(ref(storage, STORAGE_FILES.cover)));
    await check(actor, 'Files', 'write cover', 'deny', () => uploadString(ref(storage, STORAGE_FILES.cover), 'x'));
    for (const path of [STORAGE_FILES.privatePdf, STORAGE_FILES.holding, 'other/x']) {
      await check(actor, 'Files', 'read', 'deny', () => getBytes(ref(storage, path)));
      await check(actor, 'Files', 'write', 'deny', () => uploadString(ref(storage, path), 'x'));
      await check(actor, 'Files', 'delete', 'deny', () => deleteObject(ref(storage, path)));
    }
  });
}
