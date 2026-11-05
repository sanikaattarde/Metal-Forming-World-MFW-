// SPIKE (DEC-003 OPEN). PROVISIONAL (DEC-029, OQ-24). Group G11: OP-12 requestAccountDeletion and the
// deletion task of OP-41, on the working position of immediate deletion (GS-Q50, TD-19). FR-PRIV-003,
// INV-03, INV-18, SEC-CHK-11, PAC-06. Emulator only. OQ-24 is open, so nothing is kept.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, setDoc } from 'firebase/firestore';
import { eraseAccount, OWN_COLLECTIONS, requestDeletion } from '../functions/dist/accountDeletion.js';
import { removeAdminRole } from '../functions/dist/admin.js';
import { finishDeletions } from '../functions/dist/deletionCleanup.js';
import {
  adminBackend,
  bookmark,
  callFunction,
  clearAuthAccounts,
  favourite,
  newTestEnv,
  preference,
  signInError,
  signUp,
} from './helpers.mjs';

const P = 'G11 PROVISIONAL (DEC-029, OQ-24):';
const NOW = new Date('2026-11-05T10:00:00Z');
const PROFILE = { full_name: 'Test Reader', age_value: 30 };

let env;
let backend;
let db;
let auth;
let readerA;
let readerB;
let admin;
let otherAdmin;

const DELETE = { request_id: 'd1', confirm: true };
const del = (data = DELETE, token = readerA.idToken) => callFunction('requestAccountDeletion', data, token);

// A reader with one of every own record (DATABASE_AND_DATA_MODEL.md section 13.3).
async function seedReader(uid) {
  await db.doc(`users/${uid}`).set({ user_id: uid, status: 'active', created_at: NOW });
  await db.doc(`users/${uid}/profile/current`).set({ ...PROFILE, user_id: uid });
  await db.doc(`users/${uid}/consents/c1`).set({ consent_id: 'c1', user_id: uid, document_type: 'privacy_policy' });
  // The helpers make client-SDK timestamps, which the Admin SDK does not take, so a date is given.
  await db.doc(`users/${uid}/bookmarks/i-pub_7`).set(bookmark(uid, 'i-pub_7', { created_at: NOW }));
  await db.doc(`users/${uid}/favourites/i-pub`).set(favourite(uid, 'i-pub', { created_at: NOW }));
  await db.doc(`users/${uid}/notification_preferences/notif-new-issues`).set(preference(uid, 'notif-new-issues', { created_at: NOW }));
}

// Everything stored about one account: its records, any role record, and whether the sign-in account exists.
async function holdings(uid) {
  const out = [];
  const userRef = db.doc(`users/${uid}`);
  if ((await userRef.get()).exists) out.push(userRef.path);
  for (const collection of await userRef.listCollections()) {
    for (const item of (await collection.get()).docs) out.push(item.ref.path);
  }
  if ((await db.doc(`admin_roles/${uid}`).get()).exists) out.push(`admin_roles/${uid}`);
  const account = await auth.getUser(uid).catch(() => null);
  if (account) out.push(`sign-in account ${uid}`);
  return out.sort();
}

// Every record outside one account, to show that a deletion touched nothing else.
async function everythingBut(uid) {
  const out = {};
  const walk = async (collections) => {
    for (const collection of collections) {
      for (const item of (await collection.get()).docs) {
        if (item.ref.path === `users/${uid}` || item.ref.path === `admin_roles/${uid}`) continue;
        out[item.ref.path] = item.data();
        await walk(await item.ref.listCollections());
      }
    }
  };
  await walk(await db.listCollections());
  return JSON.stringify(Object.keys(out).sort().map((key) => [key, out[key]]));
}

const refused = (reply, status, reason) => {
  assert.equal(reply.error?.status, status, reply.raw);
  if (reason) assert.equal(reply.error.details?.reason, reason, reply.raw);
};

before(async () => {
  env = await newTestEnv();
  backend = adminBackend();
  db = backend.db;
  auth = backend.auth;
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  readerA = await signUp('reader-a@example.test');
  readerB = await signUp('reader-b@example.test');
  admin = await signUp('admin-a@example.test');
  otherAdmin = await signUp('admin-b@example.test');
  for (const account of [readerA, readerB]) await seedReader(account.uid);
  for (const account of [admin, otherAdmin]) {
    await seedReader(account.uid);
    await db.doc(`admin_roles/${account.uid}`).set({ user_id: account.uid, is_active: true, granted_by: 'test-seed', granted_at: NOW });
  }
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 2, version: 1, updated_at: NOW });
  await db.doc('config/private').set({ profile_gate_enabled: false, signed_url_lifetime: 600, max_upload_bytes: 1 });
  await db.doc('issues/i-pub').set({ issue_id: 'i-pub', publication_state: 'published', current_revision: 1 });
});

// ---- A reader deletes their account ----

test(`${P} every record and the sign-in account are removed, and the reply says deleted (SEC-CHK-11)`, async () => {
  assert.equal((await holdings(readerA.uid)).length, 7);
  const reply = await del();
  assert.equal(reply.error, undefined, reply.raw);
  assert.deepEqual(reply.result, { state: 'deleted' });
  assert.deepEqual(await holdings(readerA.uid), []);
});

test(`${P} afterwards the reader cannot sign in (PAC-06)`, async () => {
  await del();
  assert.equal(await signInError('reader-a@example.test'), 'EMAIL_NOT_FOUND');
});

test(`${P} another reader's records, and everything else, are untouched`, async () => {
  const before = await everythingBut(readerA.uid);
  await del();
  assert.equal(await everythingBut(readerA.uid), before);
  assert.equal((await holdings(readerB.uid)).length, 7);
});

test(`${P} a reader with no account record can delete, and nothing is left`, async () => {
  const fresh = await signUp('fresh@example.test');
  const reply = await del(DELETE, fresh.idToken);
  assert.deepEqual(reply.result, { state: 'deleted' }, reply.raw);
  assert.deepEqual(await holdings(fresh.uid), []);
});

test(`${P} the same email can register again, as a new account with none of the old records`, async () => {
  await del();
  const again = await signUp('reader-a@example.test');
  assert.notEqual(again.uid, readerA.uid);
  assert.deepEqual(await holdings(again.uid), [`sign-in account ${again.uid}`]);
});

// ---- Refusals. Each changes nothing. ----

for (const [name, data, fields] of [
  ['no confirmation', { request_id: 'd1' }, ['confirm']],
  ['a confirmation that is false', { request_id: 'd1', confirm: false }, ['confirm']],
  ['a confirmation as text', { request_id: 'd1', confirm: 'true' }, ['confirm']],
  ['no request identifier', { confirm: true }, ['request_id']],
  ['another account named', { ...DELETE, user_id: 'someone-else' }, ['user_id']],
  ['nothing at all', null, ['confirm', 'request_id']],
]) {
  test(`${P} refused: ${name}, and nothing changes`, async () => {
    const before = await everythingBut('nobody');
    const reply = await del(data);
    refused(reply, 'INVALID_ARGUMENT');
    assert.deepEqual(reply.error.details.fields, fields);
    assert.equal(await everythingBut('nobody'), before);
    assert.equal((await holdings(readerA.uid)).length, 7);
  });
}

test(`${P} refused: no sign-in token, and nothing changes`, async () => {
  const before = await everythingBut('nobody');
  refused(await del(DELETE, null), 'UNAUTHENTICATED');
  assert.equal(await everythingBut('nobody'), before);
});

test(`${P} an account already being deleted is refused with ALREADY_DELETING, and nothing changes`, async () => {
  await db.doc(`users/${readerA.uid}`).update({ status: 'deleting' });
  const before = await everythingBut('nobody');
  refused(await del(), 'FAILED_PRECONDITION', 'ALREADY_DELETING');
  assert.equal(await everythingBut('nobody'), before);
});

// ---- Admins (INV-03) ----

test(`${P} an admin who is not the last leaves the count in the same step, and the role record goes with the account`, async () => {
  const reply = await del(DELETE, admin.idToken);
  assert.deepEqual(reply.result, { state: 'deleted' }, reply.raw);
  assert.deepEqual(await holdings(admin.uid), []);
  const guard = (await db.doc('admin_guard/current').get()).data();
  assert.equal(guard.active_admin_count, 1);
  assert.equal(guard.version, 2);
  assert.equal((await db.doc(`admin_roles/${otherAdmin.uid}`).get()).get('is_active'), true);
});

test(`${P} the last active admin is refused with LAST_ADMIN, and nothing changes`, async () => {
  await removeAdminRole(backend, otherAdmin.uid);
  const before = await everythingBut('nobody');
  refused(await del(DELETE, admin.idToken), 'FAILED_PRECONDITION', 'LAST_ADMIN');
  assert.equal(await everythingBut('nobody'), before);
  assert.equal((await holdings(admin.uid)).length, 8);
});

test(`${P} an admin's deletion fails closed when the guard record is unusable, and nothing changes`, async () => {
  await db.doc('admin_guard/current').delete();
  const before = await everythingBut('nobody');
  refused(await del(DELETE, admin.idToken), 'INTERNAL');
  assert.equal(await everythingBut('nobody'), before);
});

test(`${P} a removed admin deletes as a reader, and the count does not move`, async () => {
  await removeAdminRole(backend, otherAdmin.uid);
  const reply = await del(DELETE, otherAdmin.idToken);
  assert.deepEqual(reply.result, { state: 'deleted' }, reply.raw);
  assert.equal((await db.doc('admin_guard/current').get()).get('active_admin_count'), 1);
  assert.deepEqual(await holdings(otherAdmin.uid), []);
});

// ---- While an account is being deleted, the server refuses it (GS-Q50) ----

test(`${P} an account marked deleting is refused by saveProfile and getIssueFile with ACCOUNT_CLOSED`, async () => {
  await db.doc(`users/${readerA.uid}`).update({ status: 'deleting' });
  await auth.updateUser(readerA.uid, { emailVerified: true });
  refused(await callFunction('saveProfile', { request_id: 'p1', profile: { full_name: 'New Name' } }, readerA.idToken), 'FAILED_PRECONDITION', 'ACCOUNT_CLOSED');
  refused(await callFunction('getIssueFile', { issue_id: 'i-pub' }, readerA.idToken), 'FAILED_PRECONDITION', 'ACCOUNT_CLOSED');
});

// ---- A deletion that stops part-way is finished by the cleanup (OP-41) ----

const failOnce = (target, name, when = () => true) => {
  let failed = false;
  return new Proxy(target, {
    get: (object, property) => {
      const value = object[property];
      if (property === name) {
        return (...args) => {
          if (!failed && when(...args)) {
            failed = true;
            return Promise.reject(new Error('secret'));
          }
          return value.apply(object, args);
        };
      }
      return typeof value === 'function' ? value.bind(object) : value;
    },
  });
};

// A Firestore whose delete of one admin role record fails once.
const failingRoleDelete = () => {
  let failed = false;
  return new Proxy(db, {
    get: (object, property) =>
      property === 'collection'
        ? (name) => {
            const collection = object.collection(name);
            if (name !== 'admin_roles') return collection;
            return {
              doc: (id) =>
                new Proxy(collection.doc(id), {
                  get: (ref, name) => {
                    if (name !== 'delete') return typeof ref[name] === 'function' ? ref[name].bind(ref) : ref[name];
                    return () => {
                      if (failed) return ref.delete();
                      failed = true;
                      return Promise.reject(new Error('secret'));
                    };
                  },
                }),
            };
          }
        : typeof object[property] === 'function'
          ? object[property].bind(object)
          : object[property],
  });
};

const STEPS = {
  'ending the sessions': (uid) => ({ db, auth: failOnce(auth, 'revokeRefreshTokens', (id) => id === uid) }),
  ...Object.fromEntries(
    OWN_COLLECTIONS.map((name) => [`removing ${name}`, (uid) => ({ db: failOnce(db, 'recursiveDelete', (ref) => ref.path === `users/${uid}/${name}`), auth })]),
  ),
  'removing the admin role record': () => ({ db: failingRoleDelete(), auth }),
  'removing the sign-in account': (uid) => ({ db, auth: failOnce(auth, 'deleteUser', (id) => id === uid) }),
  'removing the user record': (uid) => ({ db: failOnce(db, 'recursiveDelete', (ref) => ref.path === `users/${uid}`), auth }),
};

// The reader's own records go before the role record, the sign-in account and the user record.
const AFTER_OWN_RECORDS = ['removing the admin role record', 'removing the sign-in account', 'removing the user record'];

for (const [step, broken] of Object.entries(STEPS)) {
  test(`${P} a failure at ${step} leaves the account deleting, and the cleanup finishes it`, async () => {
    const account = step === 'removing the admin role record' ? admin : readerA;
    const before = await everythingBut(account.uid);
    assert.equal(await requestDeletion(broken(account.uid), account.uid, DELETE), 'deleting');
    assert.equal((await db.doc(`users/${account.uid}`).get()).get('status'), 'deleting');
    if (AFTER_OWN_RECORDS.includes(step)) {
      for (const name of OWN_COLLECTIONS) assert.equal((await db.collection(`users/${account.uid}/${name}`).get()).size, 0, name);
    }

    assert.deepEqual(await finishDeletions({ db, auth }), { finished: 1, failed: 0 });
    assert.deepEqual(await holdings(account.uid), []);
    if (account === admin) assert.equal((await db.doc('admin_guard/current').get()).get('active_admin_count'), 1);
    else assert.equal(await everythingBut(account.uid), before);
  });
}

test(`${P} a reader with no account record whose deletion stops part-way is still finished by the cleanup`, async () => {
  const fresh = await signUp('fresh-stop@example.test');
  assert.equal(await requestDeletion({ db, auth: failOnce(auth, 'deleteUser') }, fresh.uid, DELETE), 'deleting');
  assert.deepEqual(await finishDeletions({ db, auth }), { finished: 1, failed: 0 });
  assert.deepEqual(await holdings(fresh.uid), []);
});

test(`${P} a stopped deletion is not started again by a repeat, and the cleanup still finishes it`, async () => {
  await requestDeletion({ db, auth: failOnce(auth, 'deleteUser') }, readerA.uid, DELETE);
  refused(await del(), 'FAILED_PRECONDITION', 'ALREADY_DELETING');
  await finishDeletions({ db, auth });
  assert.deepEqual(await holdings(readerA.uid), []);
});

test(`${P} the sessions are ended before the sign-in account goes`, async () => {
  const before = (await auth.getUser(readerA.uid)).tokensValidAfterTime;
  await new Promise((resolve) => setTimeout(resolve, 1100));
  await requestDeletion({ db, auth: failOnce(auth, 'deleteUser') }, readerA.uid, DELETE);
  const after = (await auth.getUser(readerA.uid)).tokensValidAfterTime;
  assert.ok(new Date(after) > new Date(before), `${before} then ${after}`);
});

test(`${P} the cleanup leaves active accounts alone`, async () => {
  const before = await everythingBut('nobody');
  assert.deepEqual(await finishDeletions({ db, auth }), { finished: 0, failed: 0 });
  assert.equal(await everythingBut('nobody'), before);
});

test(`${P} the cleanup counts a deletion it could not finish, and finishes it on the next run`, async () => {
  await requestDeletion({ db, auth: failOnce(auth, 'deleteUser') }, readerA.uid, DELETE);
  assert.deepEqual(await finishDeletions({ db, auth: failOnce(auth, 'deleteUser') }), { finished: 0, failed: 1 });
  assert.equal((await db.doc(`users/${readerA.uid}`).get()).get('status'), 'deleting');
  assert.deepEqual(await finishDeletions({ db, auth }), { finished: 1, failed: 0 });
  assert.deepEqual(await holdings(readerA.uid), []);
});

test(`${P} erasing an account twice is harmless`, async () => {
  await db.doc(`users/${readerA.uid}`).update({ status: 'deleting' });
  await eraseAccount({ db, auth }, readerA.uid);
  await eraseAccount({ db, auth }, readerA.uid);
  assert.deepEqual(await holdings(readerA.uid), []);
});

// ---- KNOWN GAP (A-10, 10-deletion-notes.md) ----

test(`${P} KNOWN GAP: the rules still take a direct write from a deleted account's session, which leaves an orphan`, async () => {
  await del();
  const session = env.authenticatedContext(readerA.uid).firestore();
  await assertSucceeds(setDoc(doc(session, `users/${readerA.uid}/bookmarks/i-pub_9`), bookmark(readerA.uid, 'i-pub_9')));
  // The deletion task cannot see it: there is no user record in the deleting state any more.
  assert.deepEqual(await finishDeletions({ db, auth }), { finished: 0, failed: 0 });
  assert.equal((await db.doc(`users/${readerA.uid}/bookmarks/i-pub_9`).get()).exists, true);
});
