// SPIKE (DEC-003 OPEN). Group G6: OP-10 saveProfile through the Functions emulator. Emulator only.
// The mandatory profile is PROVISIONAL (BR-003). A function bypasses the rules, so it checks the
// caller itself. Whether the emulator verifies a token's signature is not shown here (03-rules-notes).
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { doc, getDoc, getDocs, collection, setDoc } from 'firebase/firestore';
import {
  callFunction,
  clearAuthAccounts,
  deleteAccount,
  disableAccount,
  newTestEnv,
  signUp,
} from './helpers.mjs';

const VERSIONS = { privacy_policy: 'pp-test-1', terms_of_use: 'tou-test-1' };
const FIVE = ['full_name', 'age_value', 'gender', 'job_title', 'industry_segment_id'];
const PROFILE = {
  full_name: 'Test Reader',
  age_value: 30,
  gender: 'test-gender',
  job_title: 'Tester',
  industry_segment_id: 's1',
};

let env;
let reader;

const firstCall = (over = {}) => ({
  request_id: 'r1',
  profile: PROFILE,
  accepted_versions: VERSIONS,
  ...over,
});

const save = (data, token = reader.idToken) => callFunction('saveProfile', data, token);

async function put(path, data) {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), path), data);
  });
}

async function read(path) {
  let data;
  await env.withSecurityRulesDisabled(async (context) => {
    const snap = await getDoc(doc(context.firestore(), path));
    data = snap.exists() ? snap.data() : undefined;
  });
  return data;
}

async function listIds(path) {
  let ids;
  await env.withSecurityRulesDisabled(async (context) => {
    const snap = await getDocs(collection(context.firestore(), path));
    ids = snap.docs.map((d) => d.id).sort();
  });
  return ids;
}

async function assertNothingWritten(uid) {
  assert.equal(await read(`users/${uid}`), undefined, 'no account record');
  assert.equal(await read(`users/${uid}/profile/current`), undefined, 'no profile');
  assert.deepEqual(await listIds(`users/${uid}/consents`), [], 'no consent record');
}

const assertInvalid = (reply, fields) => {
  assert.equal(reply.status, 400);
  assert.equal(reply.error.status, 'INVALID_ARGUMENT');
  assert.deepEqual(reply.error.details.fields, fields);
};

const assertClosed = (reply) => {
  assert.equal(reply.status, 400);
  assert.equal(reply.error.status, 'FAILED_PRECONDITION');
  assert.equal(reply.error.details.reason, 'ACCOUNT_CLOSED');
};

before(async () => {
  env = await newTestEnv();
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  await put('config/public', { profile_required_fields: FIVE, policy_versions: VERSIONS });
  await put('segments/s1', { segment_id: 's1', name: 'Segment one', display_order: 1, is_active: true });
  reader = await signUp('reader-a@example.test');
});

// ---- Allowed ----

test('G6 the first complete call writes the account, the profile and both consent records', async () => {
  const reply = await save(firstCall());
  assert.equal(reply.status, 200, reply.raw);
  assert.deepEqual(reply.result, { profile_status: 'complete' });

  const account = await read(`users/${reader.uid}`);
  assert.equal(account.user_id, reader.uid);
  assert.equal(account.status, 'active');
  assert.ok(account.created_at);

  const profile = await read(`users/${reader.uid}/profile/current`);
  const { updated_at, user_id, ...fields } = profile;
  assert.deepEqual(fields, PROFILE);
  assert.equal(user_id, reader.uid);
  assert.ok(updated_at);

  const ids = await listIds(`users/${reader.uid}/consents`);
  assert.deepEqual(ids, ['privacy_policy__pp-test-1', 'terms_of_use__tou-test-1']);
  const consent = await read(`users/${reader.uid}/consents/privacy_policy__pp-test-1`);
  assert.equal(consent.user_id, reader.uid);
  assert.equal(consent.document_type, 'privacy_policy');
  assert.equal(consent.document_version, 'pp-test-1');
  assert.equal(consent.method, 'registration_action');
  assert.ok(consent.accepted_at);
});

test('G6 the email address is not copied into any record', async () => {
  await save(firstCall());
  const stored = JSON.stringify([
    await read(`users/${reader.uid}`),
    await read(`users/${reader.uid}/profile/current`),
    await read(`users/${reader.uid}/consents/privacy_policy__pp-test-1`),
  ]);
  assert.equal(stored.includes('reader-a@example.test'), false);
});

test('G6 text values are stored trimmed', async () => {
  await save(firstCall({ profile: { ...PROFILE, full_name: '  Test Reader  ' } }));
  assert.equal((await read(`users/${reader.uid}/profile/current`)).full_name, 'Test Reader');
});

test('G6 a partial profile is saved and the missing fields are named', async () => {
  const reply = await save(firstCall({ profile: { full_name: 'Test Reader' } }));
  assert.equal(reply.status, 200, reply.raw);
  assert.deepEqual(reply.result, {
    profile_status: 'incomplete',
    missing_fields: ['age_value', 'gender', 'job_title', 'industry_segment_id'],
  });
  assert.equal((await read(`users/${reader.uid}/profile/current`)).full_name, 'Test Reader');
});

test('G6 a later call replaces the profile and needs no versions', async () => {
  await save(firstCall());
  const reply = await save({ request_id: 'r2', profile: { full_name: 'New Name' } });
  assert.equal(reply.status, 200, reply.raw);
  assert.equal(reply.result.profile_status, 'incomplete');
  const profile = await read(`users/${reader.uid}/profile/current`);
  assert.equal(profile.full_name, 'New Name');
  assert.equal('job_title' in profile, false, 'a field left out is gone: the profile is replaced');
});

test('G6 a repeat is harmless: same result, and the consent keeps its first acceptance time', async () => {
  const first = await save(firstCall());
  const consentBefore = await read(`users/${reader.uid}/consents/privacy_policy__pp-test-1`);
  const accountBefore = await read(`users/${reader.uid}`);

  const repeat = await save(firstCall());
  assert.deepEqual(repeat.result, first.result);

  const consentAfter = await read(`users/${reader.uid}/consents/privacy_policy__pp-test-1`);
  assert.equal(consentAfter.accepted_at.toMillis(), consentBefore.accepted_at.toMillis());
  const accountAfter = await read(`users/${reader.uid}`);
  assert.equal(accountAfter.created_at.toMillis(), accountBefore.created_at.toMillis());
  assert.equal((await listIds(`users/${reader.uid}/consents`)).length, 2);
});

test('G6 the set comes from configuration: a change to it needs no code change', async () => {
  await put('config/public', { profile_required_fields: FIVE.filter((f) => f !== 'gender'), policy_versions: VERSIONS });
  const { gender, ...withoutGender } = PROFILE;

  const refused = await save(firstCall());
  assertInvalid(refused, ['gender']);

  const reply = await save(firstCall({ profile: withoutGender }));
  assert.deepEqual(reply.result, { profile_status: 'complete' });
});

// ---- Refused: the caller ----

test('G6 no sign-in token: refused, nothing written', async () => {
  const reply = await save(firstCall(), null);
  assert.equal(reply.status, 401);
  assert.equal(reply.error.status, 'UNAUTHENTICATED');
  await assertNothingWritten(reader.uid);
});

test('G6 a token that is not a token at all: refused, nothing written', async () => {
  const reply = await save(firstCall(), 'not-a-token');
  assert.equal(reply.status, 401);
  assert.equal(reply.error.status, 'UNAUTHENTICATED');
  await assertNothingWritten(reader.uid);
});

test('G6 an account marked deleting: refused, and nothing changes', async () => {
  await save(firstCall());
  await put(`users/${reader.uid}`, { user_id: reader.uid, status: 'deleting' });
  assertClosed(await save({ request_id: 'r2', profile: { full_name: 'Changed' } }));
  assert.equal((await read(`users/${reader.uid}/profile/current`)).full_name, 'Test Reader');
});

test('G6 an account the provider has disabled: refused, nothing written', async () => {
  await disableAccount(reader.uid);
  assertClosed(await save(firstCall()));
  await assertNothingWritten(reader.uid);
});

test('G6 an account the provider no longer has, with an old token: refused, nothing written', async () => {
  await deleteAccount(reader.idToken);
  assertClosed(await save(firstCall()));
  await assertNothingWritten(reader.uid);
});

test('G6 one reader cannot touch another reader, and records go under the caller only', async () => {
  const other = await signUp('reader-b@example.test');
  await save(firstCall());

  const refused = await save(
    { request_id: 'r3', profile: { ...PROFILE, user_id: reader.uid, full_name: 'Attack' }, accepted_versions: VERSIONS },
    other.idToken,
  );
  assertInvalid(refused, ['user_id']);
  assert.equal((await read(`users/${reader.uid}/profile/current`)).full_name, 'Test Reader');
  await assertNothingWritten(other.uid);

  await save(firstCall({ profile: { ...PROFILE, full_name: 'Reader B' } }), other.idToken);
  assert.equal((await read(`users/${other.uid}/profile/current`)).full_name, 'Reader B');
  assert.equal((await read(`users/${reader.uid}/profile/current`)).full_name, 'Test Reader');
});

// ---- Refused: the input ----

for (const [label, data, fields] of [
  ['no request_id', { profile: PROFILE, accepted_versions: VERSIONS }, ['request_id']],
  ['an empty request_id', { request_id: '  ', profile: PROFILE, accepted_versions: VERSIONS }, ['request_id']],
  ['no profile', { request_id: 'r1', accepted_versions: VERSIONS }, ['profile']],
  ['a profile that is not an object', { request_id: 'r1', profile: 'x', accepted_versions: VERSIONS }, ['profile']],
]) {
  test(`G6 ${label}: refused, nothing written`, async () => {
    assertInvalid(await save(data), fields);
    await assertNothingWritten(reader.uid);
  });
}

for (const name of ['email', 'user_id', 'status', 'role', 'mobile_number', 'date_of_birth']) {
  test(`G6 the field ${name} is outside the configured set: refused, nothing written`, async () => {
    assertInvalid(await save(firstCall({ profile: { ...PROFILE, [name]: 'x' } })), [name]);
    await assertNothingWritten(reader.uid);
  });
}

for (const [label, profile, field] of [
  ['age 0', { ...PROFILE, age_value: 0 }, 'age_value'],
  ['age 121', { ...PROFILE, age_value: 121 }, 'age_value'],
  ['age as text', { ...PROFILE, age_value: '30' }, 'age_value'],
  ['an empty name', { ...PROFILE, full_name: '   ' }, 'full_name'],
  ['a name over the placeholder limit', { ...PROFILE, full_name: 'x'.repeat(201) }, 'full_name'],
]) {
  test(`G6 ${label}: refused and named, nothing written`, async () => {
    assertInvalid(await save(firstCall({ profile })), [field]);
    await assertNothingWritten(reader.uid);
  });
}

test('G6 a refusal names the field and does not repeat the value', async () => {
  const reply = await save(firstCall({ profile: { ...PROFILE, age_value: 'marker-value-not-to-echo' } }));
  assertInvalid(reply, ['age_value']);
  assert.equal(reply.raw.includes('marker-value-not-to-echo'), false);
});

test('G6 a segment that does not exist: refused and named, nothing written (INV-13)', async () => {
  assertInvalid(await save(firstCall({ profile: { ...PROFILE, industry_segment_id: 'no-such-segment' } })), ['industry_segment_id']);
  await assertNothingWritten(reader.uid);
});

// A slash makes the value a path, which either throws or reaches a record that is not a segment.
for (const value of ['a/b', 's1/x/y', '..', '__name__']) {
  test(`G6 a segment that is not one key, ${value}: refused and named, nothing written`, async () => {
    await put('segments/s1/x/y', { name: 'Not a segment' });
    assertInvalid(await save(firstCall({ profile: { ...PROFILE, industry_segment_id: value } })), ['industry_segment_id']);
    await assertNothingWritten(reader.uid);
  });
}

// ---- Refused: consent ----

test('G6 the first call without accepted versions: refused and named, nothing written', async () => {
  assertInvalid(await save({ request_id: 'r1', profile: PROFILE }), ['accepted_versions']);
  await assertNothingWritten(reader.uid);
});

test('G6 the first call with old versions: refused and named, nothing written', async () => {
  assertInvalid(await save(firstCall({ accepted_versions: { ...VERSIONS, terms_of_use: 'old' } })), ['accepted_versions']);
  await assertNothingWritten(reader.uid);
});

test('G6 a later call with versions that are not current: refused, and the profile is unchanged', async () => {
  await save(firstCall());
  const reply = await save({ request_id: 'r2', profile: { full_name: 'Changed' }, accepted_versions: { ...VERSIONS, privacy_policy: 'old' } });
  assertInvalid(reply, ['accepted_versions']);
  assert.equal((await read(`users/${reader.uid}/profile/current`)).full_name, 'Test Reader');
});

test('G6 every problem is named in one reply', async () => {
  const reply = await save({ request_id: 'r1', profile: { ...PROFILE, age_value: 0, full_name: '' } });
  assertInvalid(reply, ['accepted_versions', 'age_value', 'full_name'].sort());
});

// ---- Refused: the configuration fails closed (SC-03) ----

for (const [label, config] of [
  ['missing', null],
  ['naming a field with no validator', { profile_required_fields: ['shoe_size'], policy_versions: VERSIONS }],
  ['without policy versions', { profile_required_fields: FIVE }],
]) {
  test(`G6 a public configuration ${label}: refused, nothing written`, async () => {
    if (config) await put('config/public', config);
    else {
      await env.clearFirestore();
      await put('segments/s1', { segment_id: 's1', name: 'Segment one', display_order: 1, is_active: true });
    }
    const reply = await save(firstCall());
    assert.equal(reply.status, 500);
    assert.equal(reply.error.status, 'INTERNAL');
    await assertNothingWritten(reader.uid);
  });
}
