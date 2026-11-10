// Unit tests of the parts of OP-11 that need no database: the key
// check, the profile computation (INV-10), the log wrapper (SC-16) and the emulator grant issuer.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { emulatorGrantIssuer } from '../functions/dist/grantIssuer.js';
import { isProfileComplete } from '../functions/dist/profile.js';
import { cleanLogFields } from '../functions/dist/safeLog.js';
import { isDocumentId } from '../functions/dist/validation.js';

// ---- One document key ----

for (const good of ['i-pub', 'a', '0f3a9c', 'with space', 'é', 'x'.repeat(1500)]) {
  test(`U3 a document key is accepted: ${good.slice(0, 12)}`, () => {
    assert.equal(isDocumentId(good), true);
  });
}

const BAD_KEYS = {
  'a path into a subcollection': 'i-pub/files/1',
  'a path of two parts': 'a/b',
  'a leading slash': '/i-pub',
  'a trailing slash': 'i-pub/',
  'one dot': '.',
  'two dots': '..',
  'a reserved name': '__name__',
  'too long': 'x'.repeat(1501),
  'too long in bytes': 'é'.repeat(751),
  empty: '',
  'only spaces': '   ',
  'a number': 7,
  'an object': { id: 'i-pub' },
  'an array': ['i-pub'],
  null: null,
  'not given': undefined,
};

for (const [name, value] of Object.entries(BAD_KEYS)) {
  test(`U3 a document key is refused: ${name}`, () => {
    assert.equal(isDocumentId(value), false);
  });
}

// ---- A profile is complete when the required fields are present (INV-10) ----

const REQUIRED = ['full_name', 'age_value'];

test('U3 a profile with every required field is complete, and extra fields do not matter', () => {
  assert.equal(isProfileComplete({ full_name: 'A', age_value: 30 }, REQUIRED), true);
  assert.equal(isProfileComplete({ full_name: 'A', age_value: 30, job_title: 'B' }, REQUIRED), true);
});

for (const [name, profile] of Object.entries({
  'no profile': undefined,
  'an empty profile': {},
  'a missing field': { full_name: 'A' },
  'a null field': { full_name: 'A', age_value: null },
  'an empty text field': { full_name: '', age_value: 30 },
})) {
  test(`U3 a profile is not complete: ${name}`, () => {
    assert.equal(isProfileComplete(profile, REQUIRED), false);
  });
}

test('U3 changing the required set changes the answer, because nothing is stored', () => {
  const profile = { full_name: 'A' };
  assert.equal(isProfileComplete(profile, ['full_name']), true);
  assert.equal(isProfileComplete(profile, ['full_name', 'gender']), false);
});

// ---- The log wrapper refuses a grant (SC-16) ----

const LINK = 'https://storage.example.test/bucket/issues/i-pub/1.pdf?X-Goog-Signature=abc';

test('U3 the log keeps the operation, the caller and the outcome', () => {
  const { fields, refused } = cleanLogFields({ operation: 'getIssueFile', caller: 'uid-1', outcome: 'OK' });
  assert.deepEqual(fields, { operation: 'getIssueFile', caller: 'uid-1', outcome: 'OK' });
  assert.deepEqual(refused, []);
});

test('U3 the log refuses a whole grant and names only the field', () => {
  const grant = { url: LINK, expires_at: 1, revision: 1, size_bytes: 1, checksum_sha256: 'abc' };
  const { fields, refused } = cleanLogFields({ operation: 'getIssueFile', grant });
  assert.deepEqual(fields, { operation: 'getIssueFile' });
  assert.deepEqual(refused, ['grant']);
});

for (const field of ['url', 'link', 'token', 'storage_path', 'email', 'profile', 'issue_id']) {
  test(`U3 the log refuses a field it does not list: ${field}`, () => {
    const { fields, refused } = cleanLogFields({ [field]: 'plain-value' });
    assert.deepEqual(fields, {});
    assert.deepEqual(refused, [field]);
  });
}

const CREDENTIALS = {
  'a link': LINK,
  'any address': 'gs://bucket/issues/i-pub/1.pdf',
  'a signature': 'X-Goog-Signature',
  'a token in a query': 'token=abc',
  'a sign-in token': 'eyJhbGciOiJub25lIn0.eyJzdWIiOiJ1In0.',
  'a long value': 'x'.repeat(129),
  'not text': { url: LINK },
  'a number': 7,
};

for (const [name, value] of Object.entries(CREDENTIALS)) {
  test(`U3 the log refuses a listed field that holds ${name}`, () => {
    const { fields, refused } = cleanLogFields({ outcome: value });
    assert.deepEqual(fields, {});
    assert.deepEqual(refused, ['outcome']);
    assert.equal(JSON.stringify({ fields, refused }).includes('abc'), false);
  });
}

// ---- The emulator grant issuer ----

const withEmulatorFlag = async (value, run) => {
  const saved = process.env.FUNCTIONS_EMULATOR;
  if (value === undefined) delete process.env.FUNCTIONS_EMULATOR;
  else process.env.FUNCTIONS_EMULATOR = value;
  try {
    return await run();
  } finally {
    if (saved === undefined) delete process.env.FUNCTIONS_EMULATOR;
    else process.env.FUNCTIONS_EMULATOR = saved;
  }
};

const REQUEST = { storagePath: 'issues/i-pub/1.pdf', lifetimeSeconds: 60 };

for (const value of [undefined, 'false', '1', '']) {
  test(`U3 the emulator grant issuer is refused outside the emulators (FUNCTIONS_EMULATOR=${value})`, async () => {
    await withEmulatorFlag(value, () => assert.rejects(emulatorGrantIssuer.issue(REQUEST), /runs only on the emulators/));
  });
}

test('U3 on the emulators the grant issuer gives an address that cannot resolve and holds no path', async () => {
  const link = await withEmulatorFlag('true', () => emulatorGrantIssuer.issue(REQUEST));
  assert.equal(new URL(link.url).hostname.endsWith('.invalid'), true);
  assert.equal(link.url.includes('issues'), false);
  assert.equal(link.url.includes('pdf'), false);
});

test('U3 the emulator grant issuer honours the lifetime it is given, and each link differs', async () => {
  const start = Date.now();
  const [one, two] = await withEmulatorFlag('true', () => Promise.all([emulatorGrantIssuer.issue(REQUEST), emulatorGrantIssuer.issue(REQUEST)]));
  assert.ok(one.expiresAtMillis >= start + 60_000 && one.expiresAtMillis <= Date.now() + 60_000);
  assert.notEqual(one.url, two.url);
});
