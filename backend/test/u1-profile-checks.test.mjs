// Unit tests of the OP-10 profile checks, with no database. The mandatory
// profile is PROVISIONAL (BR-003), and the field list and formats are working positions (OQ-01, OQ-02).
import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  AGE_MAX,
  AGE_MIN,
  checkProfile,
  ConfigError,
  consentId,
  parsePublicConfig,
  PLACEHOLDER_MAX_TEXT_LENGTH,
  versionsMatch,
} from '../functions/dist/profile.js';

const FIVE = ['full_name', 'age_value', 'gender', 'job_title', 'industry_segment_id'];
const VERSIONS = { privacy_policy: 'pp-1', terms_of_use: 'tou-1' };
const CONFIG = { profile_required_fields: FIVE, policy_versions: VERSIONS };

test('U1 text fields are trimmed', () => {
  const { values, invalid } = checkProfile({ full_name: '  Test Reader  ' }, FIVE);
  assert.deepEqual(invalid, []);
  assert.equal(values.full_name, 'Test Reader');
});

for (const [label, value] of [
  ['empty', ''],
  ['only spaces', '   '],
  ['a number', 12],
  ['null', null],
  ['a list', ['x']],
  ['over the placeholder limit', 'x'.repeat(PLACEHOLDER_MAX_TEXT_LENGTH + 1)],
]) {
  test(`U1 a text field that is ${label} is invalid`, () => {
    const { invalid, values } = checkProfile({ job_title: value }, FIVE);
    assert.deepEqual(invalid, ['job_title']);
    assert.equal('job_title' in values, false);
  });
}

test('U1 a text field at the placeholder limit is valid', () => {
  const { invalid } = checkProfile({ job_title: 'x'.repeat(PLACEHOLDER_MAX_TEXT_LENGTH) }, FIVE);
  assert.deepEqual(invalid, []);
});

for (const age of [AGE_MIN, 30, AGE_MAX]) {
  test(`U1 age ${age} is valid`, () => {
    const { invalid, values } = checkProfile({ age_value: age }, FIVE);
    assert.deepEqual(invalid, []);
    assert.equal(values.age_value, age);
  });
}

for (const age of [AGE_MIN - 1, AGE_MAX + 1, 1.5, '30', null, Number.NaN]) {
  test(`U1 age ${String(age)} (${typeof age}) is invalid`, () => {
    assert.deepEqual(checkProfile({ age_value: age }, FIVE).invalid, ['age_value']);
  });
}

test('U1 a field outside the configured set is invalid and named', () => {
  const { invalid } = checkProfile({ email: 'a@example.test', user_id: 'other', mobile_number: '1' }, FIVE);
  assert.deepEqual(invalid, ['email', 'mobile_number', 'user_id']);
});

test('U1 the missing fields are named, and a complete input has none', () => {
  assert.deepEqual(checkProfile({ full_name: 'A' }, FIVE).missing, ['age_value', 'gender', 'job_title', 'industry_segment_id']);
  const complete = { full_name: 'A', age_value: 30, gender: 'x', job_title: 'y', industry_segment_id: 's1' };
  assert.deepEqual(checkProfile(complete, FIVE).missing, []);
});

test('U1 the set comes from configuration: without gender, gender is not collected and not missing', () => {
  const four = FIVE.filter((name) => name !== 'gender');
  const check = checkProfile({ gender: 'x' }, four);
  assert.deepEqual(check.invalid, ['gender']);
  assert.equal(check.missing.includes('gender'), false);
});

test('U1 a usable configuration parses', () => {
  const parsed = parsePublicConfig(CONFIG);
  assert.deepEqual(parsed.requiredFields, FIVE);
  assert.deepEqual(parsed.policyVersions, VERSIONS);
});

for (const [label, config] of [
  ['missing', undefined],
  ['without the field list', { policy_versions: VERSIONS }],
  ['with an empty field list', { profile_required_fields: [], policy_versions: VERSIONS }],
  ['naming a field with no validator', { profile_required_fields: ['full_name', 'shoe_size'], policy_versions: VERSIONS }],
  ['without the policy versions', { profile_required_fields: FIVE }],
  ['with one policy version only', { profile_required_fields: FIVE, policy_versions: { privacy_policy: 'pp-1' } }],
]) {
  test(`U1 a configuration ${label} fails closed`, () => {
    assert.throws(() => parsePublicConfig(config), ConfigError);
  });
}

test('U1 accepted versions must equal the current versions exactly', () => {
  assert.equal(versionsMatch(VERSIONS, VERSIONS), true);
  assert.equal(versionsMatch({ ...VERSIONS, terms_of_use: 'old' }, VERSIONS), false);
  assert.equal(versionsMatch({ privacy_policy: 'pp-1' }, VERSIONS), false);
  assert.equal(versionsMatch({ ...VERSIONS, extra: 'x' }, VERSIONS), false);
  assert.equal(versionsMatch('pp-1', VERSIONS), false);
  assert.equal(versionsMatch(null, VERSIONS), false);
});

test('U1 the consent key is stable for a document and version, and a slash cannot make a sub-path', () => {
  assert.equal(consentId('privacy_policy', 'v1'), consentId('privacy_policy', 'v1'));
  assert.notEqual(consentId('privacy_policy', 'v1'), consentId('terms_of_use', 'v1'));
  assert.notEqual(consentId('privacy_policy', 'v1'), consentId('privacy_policy', 'v2'));
  assert.equal(consentId('privacy_policy', 'a/b').includes('/'), false);
});
