// SPIKE (DEC-003 OPEN, DEC-020 OPEN). Group G7: OP-11 getIssueFile through the Functions emulator (PAC-13,
// SEC-CHK-02, SEC-CHK-03, AC-3.5, AC-8.7, INV-10, SC-03, SC-07, SC-16). Emulator only. The link is a stub, so
// nothing here shows a real signed link: another reader's grant and an expired grant are not tested. The
// Functions emulator does not verify tokens (04-save-profile-notes.md, B-1).
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { getBytes, ref, uploadString } from 'firebase/storage';
import { releaseIssueFile } from '../functions/dist/issueFile.js';
import {
  adminBackend,
  callFunction,
  clearAuthAccounts,
  deleteAccount,
  disableAccount,
  forgedToken,
  newTestEnv,
  signUp,
} from './helpers.mjs';

// TEST VALUE. The lifetime is OPEN (OQ-37, CFG-06). This number decides nothing.
const TEST_LIFETIME_SECONDS = 600;
const STORAGE_PATH = 'issues/i-pub/1.pdf';
const CHECKSUM = 'a'.repeat(64);
const SIZE = 1234;
const FIVE = ['full_name', 'age_value', 'gender', 'job_title', 'industry_segment_id'];
const PROFILE = { full_name: 'Test Reader', age_value: 30, gender: 'test-gender', job_title: 'Tester', industry_segment_id: 's1' };
const VERSIONS = { privacy_policy: 'pp-test-1', terms_of_use: 'tou-test-1' };
const GRANT_FIELDS = ['checksum_sha256', 'expires_at', 'revision', 'size_bytes', 'url'];
const SECRET = 'https://secret.example.test/link?signature=abc';

let env;
let backend;
let db;
let auth;
let reader;

const getFile = (data, token = reader.idToken) => callFunction('getIssueFile', data, token);
const code = (reply) => reply.error?.details?.reason ?? reply.error?.status;

async function dump() {
  const out = {};
  const walk = async (collections) => {
    for (const collection of collections) {
      for (const item of await collection.listDocuments()) {
        const snap = await item.get();
        if (snap.exists) out[item.path] = snap.data();
        await walk(await item.listCollections());
      }
    }
  };
  await walk(await db.listCollections());
  return JSON.stringify(Object.keys(out).sort().map((key) => [key, out[key]]));
}

async function refused(expected, data, token = reader.idToken) {
  const before = await dump();
  const reply = await getFile(data, token);
  assert.equal(code(reply), expected, reply.raw);
  assert.equal(reply.result, undefined);
  assert.equal(await dump(), before, 'a refusal writes nothing');
  return reply;
}

const assertGrant = (reply, { revision = 1, size = SIZE, checksum = CHECKSUM } = {}) => {
  assert.equal(reply.error, undefined, reply.raw);
  assert.deepEqual(Object.keys(reply.result).sort(), GRANT_FIELDS);
  assert.equal(reply.result.revision, revision);
  assert.equal(reply.result.size_bytes, size);
  assert.equal(reply.result.checksum_sha256, checksum);
};

const seedIssue = (id, over = {}) =>
  db.doc(`issues/${id}`).set({ issue_id: id, title: 'An issue', publication_state: 'published', current_revision: 1, ...over });

const seedFile = (id, revision = 1, over = {}) =>
  db.doc(`issues/${id}/files/${revision}`).set({
    issue_id: id,
    revision,
    storage_path: `issues/${id}/${revision}.pdf`,
    size_bytes: SIZE,
    page_count: 10,
    checksum_sha256: CHECKSUM,
    status: 'current',
    ...over,
  });

const setPrivateConfig = (over = {}) =>
  db.doc('config/private').set({ profile_gate_enabled: true, signed_url_lifetime: TEST_LIFETIME_SECONDS, ...over });

const setPublicConfig = (fields = FIVE) =>
  db.doc('config/public').set({ profile_required_fields: fields, policy_versions: VERSIONS });

const verify = (uid) => auth.updateUser(uid, { emailVerified: true });

async function fullAccessReader(email) {
  const account = await signUp(email);
  await verify(account.uid);
  await db.doc(`users/${account.uid}`).set({ user_id: account.uid, status: 'active' });
  await db.doc(`users/${account.uid}/profile/current`).set({ ...PROFILE, user_id: account.uid });
  return account;
}

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
  await setPrivateConfig();
  await setPublicConfig();
  await seedIssue('i-pub');
  await seedFile('i-pub');
  await db.doc('deleted_issues/i-gone').set({ issue_id: 'i-gone' });
  reader = await fullAccessReader('reader@example.test');
});

// ---- Allowed ----

test('G7 a full-access reader gets exactly the five fields (OP-11)', async () => {
  assertGrant(await getFile({ issue_id: 'i-pub' }));
});

test('G7 the reply never holds the storage path (SC-07, DATABASE_AND_DATA_MODEL.md section 9)', async () => {
  const { raw } = await getFile({ issue_id: 'i-pub' });
  assert.equal(raw.includes(STORAGE_PATH), false);
  assert.equal(raw.includes('storage_path'), false);
  assert.equal(raw.includes('.pdf'), false);
});

test('G7 the expiry follows the configured lifetime (CFG-06)', async () => {
  const start = Date.now();
  const first = await getFile({ issue_id: 'i-pub' });
  assert.ok(first.result.expires_at >= start + TEST_LIFETIME_SECONDS * 1000);
  assert.ok(first.result.expires_at <= Date.now() + TEST_LIFETIME_SECONDS * 1000);

  await setPrivateConfig({ signed_url_lifetime: 60 });
  const second = await getFile({ issue_id: 'i-pub' });
  assert.ok(second.result.expires_at <= Date.now() + 60 * 1000);
});

test('G7 a repeat returns a new link', async () => {
  const one = await getFile({ issue_id: 'i-pub' });
  const two = await getFile({ issue_id: 'i-pub' });
  assertGrant(one);
  assertGrant(two);
  assert.notEqual(one.result.url, two.result.url);
});

test('G7 an allowed call writes nothing, so the link is not stored', async () => {
  const before = await dump();
  const { result } = await getFile({ issue_id: 'i-pub' });
  const after = await dump();
  assert.equal(after, before);
  assert.equal(after.includes(result.url), false);
});

test('G7 the current revision is the one released', async () => {
  await seedFile('i-pub', 1, { status: 'superseded', size_bytes: 1, checksum_sha256: 'old' });
  await seedFile('i-pub', 2, { size_bytes: 22, checksum_sha256: 'new' });
  await seedIssue('i-pub', { current_revision: 2 });
  assertGrant(await getFile({ issue_id: 'i-pub' }), { revision: 2, size: 22, checksum: 'new' });
});

test('G7 a token from before verification still passes: the provider decides, on this call', async () => {
  const account = await signUp('late@example.test');
  await db.doc(`users/${account.uid}/profile/current`).set({ ...PROFILE, user_id: account.uid });
  await refused('EMAIL_NOT_VERIFIED', { issue_id: 'i-pub' }, account.idToken);
  await verify(account.uid);
  assertGrant(await getFile({ issue_id: 'i-pub' }, account.idToken));
});

// ---- Check 0: on the deleted-issue list ----

test('G7 check 0: a deleted issue answers GONE when signed out, before sign-in', async () => {
  const reply = await refused('GONE', { issue_id: 'i-gone' }, null);
  assert.equal(reply.error.status, 'NOT_FOUND');
});

test('G7 check 0: a deleted issue answers GONE to a full-access reader', async () => {
  await refused('GONE', { issue_id: 'i-gone' });
});

test('G7 check 0: the list wins over a published issue with a current file', async () => {
  await seedIssue('i-gone');
  await seedFile('i-gone');
  await refused('GONE', { issue_id: 'i-gone' });
});

test('G7 check 0: a path cannot reach an entry on the list', async () => {
  await db.doc('deleted_issues/i-gone/x/y').set({ issue_id: 'y' });
  await refused('INVALID_ARGUMENT', { issue_id: 'i-gone/x/y' });
});

// ---- Check 1: signed in ----

test('G7 check 1: no token is refused (FX-USR-09, AC-3.5)', async () => {
  await refused('UNAUTHENTICATED', { issue_id: 'i-pub' }, null);
});

test('G7 check 1: a value that is not a token is refused', async () => {
  await refused('UNAUTHENTICATED', { issue_id: 'i-pub' }, 'not-a-token');
});

test('G7 check 1: signed out, the answer does not show whether an issue exists', async () => {
  await seedIssue('i-hidden', { publication_state: 'unpublished' });
  const existing = await refused('UNAUTHENTICATED', { issue_id: 'i-pub' }, null);
  const hidden = await refused('UNAUTHENTICATED', { issue_id: 'i-hidden' }, null);
  const missing = await refused('UNAUTHENTICATED', { issue_id: 'i-none' }, null);
  assert.equal(hidden.raw, existing.raw);
  assert.equal(missing.raw, existing.raw);
});

// ---- Input ----

const BAD_INPUT = {
  'no identifier': [{}, ['issue_id']],
  'an empty identifier': [{ issue_id: '' }, ['issue_id']],
  'a number': [{ issue_id: 7 }, ['issue_id']],
  'a path to a file record': [{ issue_id: 'i-pub/files/1' }, ['issue_id']],
  'a path of two parts': [{ issue_id: 'a/b' }, ['issue_id']],
  'two dots': [{ issue_id: '..' }, ['issue_id']],
  'a reserved name': [{ issue_id: '__name__' }, ['issue_id']],
  'a revision chosen by the caller': [{ issue_id: 'i-pub', revision: 1 }, ['revision']],
  'a storage path chosen by the caller': [{ issue_id: 'i-pub', storage_path: STORAGE_PATH }, ['storage_path']],
  'not an object': ['i-pub', ['issue_id']],
};

for (const [name, [data, fields]] of Object.entries(BAD_INPUT)) {
  test(`G7 input: ${name} is refused and named`, async () => {
    const reply = await refused('INVALID_ARGUMENT', data);
    assert.deepEqual(reply.error.details.fields, fields);
  });

  test(`G7 input: ${name}, signed out, stays UNAUTHENTICATED`, async () => {
    await refused('UNAUTHENTICATED', data, null);
  });
}

// ---- Check 2: the account is active ----

test('G7 check 2: an account being deleted is refused (PAC-06)', async () => {
  await db.doc(`users/${reader.uid}`).update({ status: 'deleting' });
  await refused('ACCOUNT_CLOSED', { issue_id: 'i-pub' });
});

test('G7 check 2: a status that is not active is refused', async () => {
  await db.doc(`users/${reader.uid}`).update({ status: 'anything-else' });
  await refused('ACCOUNT_CLOSED', { issue_id: 'i-pub' });
});

test('G7 check 2: an account the provider disabled is refused', async () => {
  await disableAccount(reader.uid);
  await refused('ACCOUNT_CLOSED', { issue_id: 'i-pub' });
});

test('G7 check 2: a deleted sign-in account with a token from before is refused', async () => {
  const { idToken } = reader;
  await deleteAccount(idToken);
  await refused('ACCOUNT_CLOSED', { issue_id: 'i-pub' }, idToken);
});

test('G7 check 2: a reader with no account record yet is not treated as closed', async () => {
  await db.doc(`users/${reader.uid}`).delete();
  assertGrant(await getFile({ issue_id: 'i-pub' }));
});

// ---- Check 3: the email is verified ----

test('G7 check 3: an unverified password account is refused (FX-USR-02, AC-3.4)', async () => {
  const account = await signUp('unverified@example.test');
  await db.doc(`users/${account.uid}/profile/current`).set({ ...PROFILE, user_id: account.uid });
  await refused('EMAIL_NOT_VERIFIED', { issue_id: 'i-pub' }, account.idToken);
});

test('G7 check 3: a token claiming a verified email is not believed (SC-04)', async () => {
  const account = await signUp('claims@example.test');
  await db.doc(`users/${account.uid}/profile/current`).set({ ...PROFILE, user_id: account.uid });
  await refused('EMAIL_NOT_VERIFIED', { issue_id: 'i-pub' }, forgedToken(account.uid, { email_verified: true }));
});

test('G7 check 3: a verified address that the provider later marks unverified is refused', async () => {
  await auth.updateUser(reader.uid, { emailVerified: false });
  await refused('EMAIL_NOT_VERIFIED', { issue_id: 'i-pub' });
});

// ---- Check 4: the profile, only when the gate is on ----

test('G7 check 4: no profile is refused when the gate is on (FX-USR-03, PAC-02)', async () => {
  await db.doc(`users/${reader.uid}/profile/current`).delete();
  await refused('PROFILE_INCOMPLETE', { issue_id: 'i-pub' });
});

test('G7 check 4: one missing field is refused when the gate is on', async () => {
  const { job_title: _left, ...rest } = PROFILE;
  await db.doc(`users/${reader.uid}/profile/current`).set({ ...rest, user_id: reader.uid });
  await refused('PROFILE_INCOMPLETE', { issue_id: 'i-pub' });
});

test('G7 check 4: with the gate off, an incomplete profile passes (BR-003 is PROVISIONAL)', async () => {
  await setPrivateConfig({ profile_gate_enabled: false });
  await db.doc(`users/${reader.uid}/profile/current`).delete();
  assertGrant(await getFile({ issue_id: 'i-pub' }));
});

test('G7 check 4: with the gate off, the public configuration is not needed', async () => {
  await setPrivateConfig({ profile_gate_enabled: false });
  await db.doc('config/public').delete();
  assertGrant(await getFile({ issue_id: 'i-pub' }));
});

test('G7 check 4: changing the required set changes both functions (INV-10)', async () => {
  const fieldsWithout = FIVE.filter((name) => name !== 'job_title');
  const { job_title: _left, ...rest } = PROFILE;
  await db.doc('segments/s1').set({ segment_id: 's1', name: 'Segment one' });
  await db.doc(`users/${reader.uid}/profile/current`).set({ ...rest, user_id: reader.uid });

  await setPublicConfig(fieldsWithout);
  assertGrant(await getFile({ issue_id: 'i-pub' }));
  const complete = await callFunction('saveProfile', { request_id: 'r1', profile: rest }, reader.idToken);
  assert.equal(complete.result.profile_status, 'complete', complete.raw);

  await setPublicConfig(FIVE);
  await refused('PROFILE_INCOMPLETE', { issue_id: 'i-pub' });
  const incomplete = await callFunction('saveProfile', { request_id: 'r2', profile: rest }, reader.idToken);
  assert.equal(incomplete.result.profile_status, 'incomplete', incomplete.raw);
  assert.deepEqual(incomplete.result.missing_fields, ['job_title']);
});

// ---- Check 5: exists and is published ----

test('G7 check 5: an issue that does not exist is refused', async () => {
  await refused('ISSUE_NOT_AVAILABLE', { issue_id: 'i-none' });
});

test('G7 check 5: an unpublished issue is refused, even with a current file', async () => {
  await seedIssue('i-hidden', { publication_state: 'unpublished' });
  await seedFile('i-hidden');
  await refused('ISSUE_NOT_AVAILABLE', { issue_id: 'i-hidden' });
});

test('G7 check 5: unpublished and missing get the same answer', async () => {
  await seedIssue('i-hidden', { publication_state: 'unpublished' });
  const hidden = await refused('ISSUE_NOT_AVAILABLE', { issue_id: 'i-hidden' });
  const missing = await refused('ISSUE_NOT_AVAILABLE', { issue_id: 'i-none' });
  assert.equal(hidden.raw, missing.raw);
});

test('G7 check 5: unpublishing stops new links at once, and publishing restores them (AC-8.7)', async () => {
  const admin = await signUp('admin@example.test');
  await db.doc(`admin_roles/${admin.uid}`).set({ user_id: admin.uid, is_active: true });

  assertGrant(await getFile({ issue_id: 'i-pub' }));

  const off = await callFunction('unpublishIssue', { request_id: 'r1', issue_id: 'i-pub' }, admin.idToken);
  assert.equal(off.result.publication_state, 'unpublished', off.raw);
  await refused('ISSUE_NOT_AVAILABLE', { issue_id: 'i-pub' });

  await db.doc('issues/i-pub').update({ title: 'An issue', description: 'What it covers', category_id: 'c1' });
  const on = await callFunction('publishIssue', { request_id: 'r2', issue_id: 'i-pub' }, admin.idToken);
  assert.equal(on.result.publication_state, 'published', on.raw);
  assertGrant(await getFile({ issue_id: 'i-pub' }));
});

// ---- Check 6: a current file revision ----

test('G7 check 6: no current revision on the issue is refused', async () => {
  await seedIssue('i-nofile', { current_revision: null });
  await seedFile('i-nofile'); // a file record exists, so only the issue's own field can refuse this
  await refused('NO_CURRENT_FILE', { issue_id: 'i-nofile' });
});

test('G7 check 6: a revision with no file record is refused', async () => {
  await seedIssue('i-nofile', { current_revision: 3 });
  await refused('NO_CURRENT_FILE', { issue_id: 'i-nofile' });
});

for (const status of ['superseded', 'removed']) {
  test(`G7 check 6: a file record marked ${status} is refused`, async () => {
    await seedIssue('i-old');
    await seedFile('i-old', 1, { status });
    await refused('NO_CURRENT_FILE', { issue_id: 'i-old' });
  });
}

// ---- The order: one request that fails every check, fixed one check at a time ----

test('G7 order: the checks answer in the contract order, 0 to 6', async () => {
  const account = await signUp('chain@example.test');
  const data = { issue_id: 'i-chain' };
  await db.doc('deleted_issues/i-chain').set({ issue_id: 'i-chain' });
  await db.doc(`users/${account.uid}`).set({ user_id: account.uid, status: 'deleting' });
  await seedIssue('i-chain', { publication_state: 'unpublished' });

  await refused('GONE', data, null);
  await db.doc('deleted_issues/i-chain').delete();

  await refused('UNAUTHENTICATED', data, null);

  await refused('ACCOUNT_CLOSED', data, account.idToken);
  await db.doc(`users/${account.uid}`).update({ status: 'active' });

  await refused('EMAIL_NOT_VERIFIED', data, account.idToken);
  await verify(account.uid);

  await refused('PROFILE_INCOMPLETE', data, account.idToken);
  await db.doc(`users/${account.uid}/profile/current`).set({ ...PROFILE, user_id: account.uid });

  await refused('ISSUE_NOT_AVAILABLE', data, account.idToken);
  await db.doc('issues/i-chain').update({ publication_state: 'published' });

  await refused('NO_CURRENT_FILE', data, account.idToken);
  await seedFile('i-chain');

  assertGrant(await getFile(data, account.idToken));
});

// ---- An admin account gets nothing extra (GS-Q20) ----

test('G7 an unverified admin is refused like any reader', async () => {
  const admin = await signUp('admin@example.test');
  await db.doc(`admin_roles/${admin.uid}`).set({ user_id: admin.uid, is_active: true });
  await refused('EMAIL_NOT_VERIFIED', { issue_id: 'i-pub' }, admin.idToken);
});

test('G7 a verified admin cannot get the file of an unpublished issue', async () => {
  const admin = await fullAccessReader('admin@example.test');
  await db.doc(`admin_roles/${admin.uid}`).set({ user_id: admin.uid, is_active: true });
  await seedIssue('i-hidden', { publication_state: 'unpublished' });
  await seedFile('i-hidden');
  await refused('ISSUE_NOT_AVAILABLE', { issue_id: 'i-hidden' }, admin.idToken);
});

test('G7 forged admin claims change nothing (SC-04)', async () => {
  await seedIssue('i-hidden', { publication_state: 'unpublished' });
  await seedFile('i-hidden');
  await refused('ISSUE_NOT_AVAILABLE', { issue_id: 'i-hidden' }, forgedToken(reader.uid, { admin: true, role: 'admin', is_admin: true }));
});

// ---- Fails closed: anything unusable refuses the call, and no link is released (SC-03) ----

const UNUSABLE = {
  'no private configuration': () => db.doc('config/private').delete(),
  'the gate setting missing': () => db.doc('config/private').set({ signed_url_lifetime: TEST_LIFETIME_SECONDS }),
  'the gate setting as text': () => setPrivateConfig({ profile_gate_enabled: 'false' }),
  'the lifetime missing': () => db.doc('config/private').set({ profile_gate_enabled: true }),
  'a lifetime of zero': () => setPrivateConfig({ signed_url_lifetime: 0 }),
  'a negative lifetime': () => setPrivateConfig({ signed_url_lifetime: -60 }),
  'a lifetime as text': () => setPrivateConfig({ signed_url_lifetime: '600' }),
  'a lifetime under a second': () => setPrivateConfig({ signed_url_lifetime: 0.5 }),
  'a fractional lifetime': () => setPrivateConfig({ signed_url_lifetime: 90.5 }),
  'no public configuration with the gate on': () => db.doc('config/public').delete(),
  'a required set that is not usable': () => db.doc('config/public').set({ profile_required_fields: [], policy_versions: VERSIONS }),
  'a current file with no size': () => seedFile('i-pub', 1, { size_bytes: null }),
  'a current file with a size of zero': () => seedFile('i-pub', 1, { size_bytes: 0 }),
  'a current file with a fractional size': () => seedFile('i-pub', 1, { size_bytes: 10.5 }),
  'a current file with no checksum': () => seedFile('i-pub', 1, { checksum_sha256: '' }),
  'a current file with no path': () => seedFile('i-pub', 1, { storage_path: '' }),
};

for (const [name, breakIt] of Object.entries(UNUSABLE)) {
  test(`G7 fails closed: ${name}`, async () => {
    await breakIt();
    const reply = await refused('INTERNAL', { issue_id: 'i-pub' });
    assert.equal(reply.raw.includes(STORAGE_PATH), false);
  });
}

// The same function, called directly, so that a read or the issuer can be made to fail.

const countingIssuer = () => {
  const calls = [];
  return {
    calls,
    issue: async (request) => {
      calls.push(request);
      return { url: 'https://grant-test.invalid/one', expiresAtMillis: 1 };
    },
  };
};

const failingDb = (fails) => {
  const failed = { get: () => Promise.reject(new Error(SECRET)) };
  return {
    doc: (path) => (fails(path) ? failed : db.doc(path)),
    collection: (name) => ({ doc: (id) => (fails(`${name}/${id}`) ? failed : db.collection(name).doc(id)) }),
  };
};

const assertRefusedInternal = async (promise) => {
  await assert.rejects(promise, (error) => {
    assert.equal(error.code, 'internal');
    assert.equal(String(error.message).includes('secret'), false);
    assert.equal(JSON.stringify(error.details ?? {}).includes('secret'), false);
    return true;
  });
};

for (const [name, fails] of Object.entries({
  'the deleted-issue list': (path) => path.startsWith('deleted_issues/'),
  'the account record': (path) => path.startsWith('users/') && !path.includes('/profile/'),
  'the private configuration': (path) => path === 'config/private',
  'the public configuration': (path) => path === 'config/public',
  'the profile': (path) => path.includes('/profile/'),
  'the issue': (path) => path.startsWith('issues/'),
})) {
  test(`G7 fails closed: ${name} cannot be read`, async () => {
    const issuer = countingIssuer();
    await assertRefusedInternal(releaseIssueFile({ db: failingDb(fails), auth, issuer }, reader.uid, { issue_id: 'i-pub' }));
    assert.equal(issuer.calls.length, 0);
  });
}

test('G7 fails closed: the provider cannot be reached', async () => {
  const issuer = countingIssuer();
  const brokenAuth = { getUser: () => Promise.reject(new Error(SECRET)) };
  await assertRefusedInternal(releaseIssueFile({ db, auth: brokenAuth, issuer }, reader.uid, { issue_id: 'i-pub' }));
  assert.equal(issuer.calls.length, 0);
});

test('G7 fails closed: the issuer fails', async () => {
  const issuer = { issue: () => Promise.reject(new Error(SECRET)) };
  await assertRefusedInternal(releaseIssueFile({ db, auth, issuer }, reader.uid, { issue_id: 'i-pub' }));
});

// ---- The issuer is asked only after every check, for the right file ----

test('G7 the issuer gets the current path and the configured lifetime', async () => {
  const issuer = countingIssuer();
  await releaseIssueFile({ db, auth, issuer }, reader.uid, { issue_id: 'i-pub' });
  assert.deepEqual(issuer.calls, [{ storagePath: STORAGE_PATH, lifetimeSeconds: TEST_LIFETIME_SECONDS }]);
});

test('G7 the issuer gets the path stored on the current revision, not one worked out from the identifier', async () => {
  await seedIssue('i-two', { current_revision: 2 });
  await seedFile('i-two', 1, { status: 'superseded', storage_path: 'issues/i-two/old.pdf' });
  await seedFile('i-two', 2, { storage_path: 'issues/i-two/moved.pdf' });
  const issuer = countingIssuer();
  await releaseIssueFile({ db, auth, issuer }, reader.uid, { issue_id: 'i-two' });
  assert.deepEqual(issuer.calls, [{ storagePath: 'issues/i-two/moved.pdf', lifetimeSeconds: TEST_LIFETIME_SECONDS }]);
});

test('G7 no refusal reaches the issuer', async () => {
  const issuer = countingIssuer();
  const unverified = await signUp('unverified@example.test');
  await seedIssue('i-hidden', { publication_state: 'unpublished' });
  await seedIssue('i-nofile', { current_revision: 9 });

  const attempts = [
    [reader.uid, { issue_id: 'i-gone' }],
    [undefined, { issue_id: 'i-pub' }],
    [reader.uid, { issue_id: 'a/b' }],
    [unverified.uid, { issue_id: 'i-pub' }],
    [reader.uid, { issue_id: 'i-hidden' }],
    [reader.uid, { issue_id: 'i-nofile' }],
  ];
  for (const [uid, data] of attempts) {
    await assert.rejects(releaseIssueFile({ db, auth, issuer }, uid, data));
  }
  assert.equal(issuer.calls.length, 0);
});

// ---- The log (SC-16): the real logger's output, read back ----

async function captureOutput(run) {
  const chunks = [];
  const out = process.stdout.write;
  const err = process.stderr.write;
  process.stdout.write = function write(chunk, ...rest) {
    chunks.push(String(chunk));
    return out.call(process.stdout, chunk, ...rest);
  };
  process.stderr.write = function write(chunk, ...rest) {
    chunks.push(String(chunk));
    return err.call(process.stderr, chunk, ...rest);
  };
  try {
    await run();
  } finally {
    process.stdout.write = out;
    process.stderr.write = err;
  }
  return chunks.join('');
}

test('G7 log: an allowed call logs the outcome, and not the grant', async () => {
  const issuer = { issue: async () => ({ url: SECRET, expiresAtMillis: 1 }) };
  let grant;
  const output = await captureOutput(async () => {
    grant = await releaseIssueFile({ db, auth, issuer }, reader.uid, { issue_id: 'i-pub' });
  });

  assert.equal(grant.url, SECRET, 'the reader still gets the link');
  assert.match(output, /getIssueFile/);
  assert.match(output, /"outcome":"OK"/);
  assert.ok(output.includes(reader.uid), 'the caller is logged');
  assert.equal(output.includes(SECRET), false, 'no link');
  assert.equal(output.includes('secret.example'), false, 'no part of the link');
  assert.equal(output.includes(STORAGE_PATH), false, 'no path');
  assert.equal(output.includes(CHECKSUM), false, 'no file facts');
});

test('G7 log: a refusal logs the reason and no input', async () => {
  const output = await captureOutput(async () => {
    await assert.rejects(releaseIssueFile({ db, auth, issuer: countingIssuer() }, reader.uid, { issue_id: 'i-none-secret' }));
  });
  assert.match(output, /"outcome":"ISSUE_NOT_AVAILABLE"/);
  assert.equal(output.includes('i-none-secret'), false);
});

test('G7 log: a failure logs no error text, which may hold a link', async () => {
  const issuer = { issue: () => Promise.reject(new Error(SECRET)) };
  const output = await captureOutput(async () => {
    await assert.rejects(releaseIssueFile({ db, auth, issuer }, reader.uid, { issue_id: 'i-pub' }));
  });
  assert.match(output, /"outcome":"internal"/);
  assert.equal(output.includes('secret.example'), false);
});

test('G7 log: a signed-out refusal logs no caller', async () => {
  const output = await captureOutput(async () => {
    await assert.rejects(releaseIssueFile({ db, auth, issuer: countingIssuer() }, undefined, { issue_id: 'i-pub' }));
  });
  assert.match(output, /"caller":"none"/);
  assert.match(output, /"outcome":"unauthenticated"/);
});

// ---- A direct request for the file (AC-3.5, SEC-CHK-02, SEC-CHK-03) ----

test('G7 a reader who holds a grant still cannot read the private path directly, or a guessed one', async () => {
  await env.clearStorage();
  await env.withSecurityRulesDisabled(async (context) => {
    await uploadString(ref(context.storage(), STORAGE_PATH), 'control-bytes');
    await assertSucceeds(getBytes(ref(context.storage(), STORAGE_PATH))); // the file is really there
  });

  assertGrant(await getFile({ issue_id: 'i-pub' }));

  const storage = env.authenticatedContext(reader.uid, { email_verified: true }).storage();
  await assertFails(getBytes(ref(storage, STORAGE_PATH)));
  await assertFails(getBytes(ref(storage, 'issues/i-pub/2.pdf')));
  await assertFails(getBytes(ref(env.unauthenticatedContext().storage(), STORAGE_PATH)));
});
