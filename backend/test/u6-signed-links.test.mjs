// Unit tests of the signed-link issuers of DEC-020 (TD-09), with a fake file in place of a bucket, so
// they run without the emulators and without a signing key (SEC-CHK-03, SC-16). What a real signed URL
// does (expiry, another reader's link, Range and resume) is the TD-09 proof plan in ENV-TEST.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { emulatorGrantIssuer, grantIssuer, signedGrantIssuer } from '../functions/dist/grantIssuer.js';
import { isUsableLifetime, MAX_LINK_LIFETIME_SECONDS, signLink } from '../functions/dist/signedLinks.js';

const NOW = 1_800_000_000_000;

// Records what it was asked to sign, and answers with a link that names the path.
function fakeBucket() {
  const calls = [];
  const open = (path) => ({
    async getSignedUrl(request) {
      calls.push({ path, request });
      return [`https://storage.example.test/${path}?X-Goog-Signature=fake`];
    },
  });
  return { open, calls };
}

async function withEmulatorFlag(value, run) {
  const before = process.env.FUNCTIONS_EMULATOR;
  if (value === undefined) delete process.env.FUNCTIONS_EMULATOR;
  else process.env.FUNCTIONS_EMULATOR = value;
  try {
    return await run();
  } finally {
    if (before === undefined) delete process.env.FUNCTIONS_EMULATOR;
    else process.env.FUNCTIONS_EMULATOR = before;
  }
}

// ---- The lifetime ----

test('U6 the lifetime ceiling is one hour, the AOQ-07 working assumption', () => {
  assert.equal(MAX_LINK_LIFETIME_SECONDS, 3600);
});

for (const [name, value, usable] of [
  ['one second', 1, true],
  ['the ceiling', 3600, true],
  ['zero', 0, false],
  ['negative', -60, false],
  ['a fraction', 90.5, false],
  ['one over the ceiling', 3601, false],
  ['seven days', 604800, false],
  ['text', '600', false],
  ['missing', undefined, false],
]) {
  test(`U6 a lifetime of ${name} is ${usable ? 'usable' : 'refused'}`, () => {
    assert.equal(isUsableLifetime(value), usable);
  });
}

test('U6 signLink refuses a lifetime over the ceiling and signs nothing', async () => {
  const bucket = fakeBucket();
  await assert.rejects(signLink(bucket.open, 'issues/i-1/1.pdf', 3601, { action: 'read' }, () => NOW), /from 1 to 3600/);
  assert.deepEqual(bucket.calls, []);
});

// ---- The grant issuer (OP-11) ----

test('U6 the grant issuer signs a V4 read link for the stored path, expiring after the lifetime', async () => {
  const bucket = fakeBucket();
  const link = await signedGrantIssuer(bucket.open, () => NOW).issue({ storagePath: 'issues/i-1/2.pdf', lifetimeSeconds: 600 });
  assert.deepEqual(bucket.calls, [{ path: 'issues/i-1/2.pdf', request: { version: 'v4', action: 'read', expires: NOW + 600_000 } }]);
  assert.deepEqual(link, { url: 'https://storage.example.test/issues/i-1/2.pdf?X-Goog-Signature=fake', expiresAtMillis: NOW + 600_000 });
});

test('U6 the grant issuer refuses a lifetime over the ceiling', async () => {
  const bucket = fakeBucket();
  await assert.rejects(signedGrantIssuer(bucket.open, () => NOW).issue({ storagePath: 'issues/i-1/2.pdf', lifetimeSeconds: 86400 }));
  assert.deepEqual(bucket.calls, []);
});

test('U6 a signing failure is passed on, not turned into a link', async () => {
  const open = () => ({ getSignedUrl: async () => { throw new Error('no signing permission'); } });
  await assert.rejects(signedGrantIssuer(open, () => NOW).issue({ storagePath: 'issues/i-1/2.pdf', lifetimeSeconds: 600 }), /no signing permission/);
});

test('U6 the chosen grant issuer is the emulator one only on the emulators', async () => {
  assert.equal(await withEmulatorFlag('true', () => grantIssuer()), emulatorGrantIssuer);
  for (const value of [undefined, 'false', '1', '']) {
    assert.notEqual(await withEmulatorFlag(value, () => grantIssuer()), emulatorGrantIssuer);
  }
});
