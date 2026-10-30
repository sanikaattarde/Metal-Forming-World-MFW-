// SPIKE (DEC-003 OPEN). Harness check: shows the local emulators run and enforce rules.
// These are not the access tests for the product. Results are "emulator only".
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';
import { ref, getBytes, uploadString } from 'firebase/storage';
import { newTestEnv, PROJECT_ID, AUTH_BASE } from './helpers.mjs';

let env;

before(async () => {
  env = await newTestEnv();
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

test('firestore: a path no rule lists is refused for a visitor and a signed-in user', async () => {
  const visitor = env.unauthenticatedContext().firestore();
  const reader = env.authenticatedContext('reader-a').firestore();
  await assertFails(getDoc(doc(visitor, 'unlisted/x')));
  await assertFails(setDoc(doc(reader, 'unlisted/x'), { a: 1 }));
});

test('firestore: an owner-only record is open to its owner and refused to anyone else', async () => {
  const owner = env.authenticatedContext('reader-a').firestore();
  const other = env.authenticatedContext('reader-b').firestore();
  const visitor = env.unauthenticatedContext().firestore();
  const path = 'users/reader-a/bookmarks/b1';
  await assertSucceeds(setDoc(doc(owner, path), { issueId: 'i1', page: 7 }));
  await assertSucceeds(getDoc(doc(owner, path)));
  await assertFails(getDoc(doc(other, path)));
  await assertFails(setDoc(doc(other, path), { page: 8 }));
  await assertFails(getDoc(doc(visitor, path)));
});

test('storage: a private path is refused for a visitor and a signed-in user', async () => {
  const path = 'private/issues/i1.pdf';
  const visitor = env.unauthenticatedContext().storage();
  const reader = env.authenticatedContext('reader-a').storage();

  // Positive control: put the file there with the rules switched off, and read it back.
  // This shows the storage emulator is serving, so the refusals below come from the rules.
  await env.withSecurityRulesDisabled(async (context) => {
    await uploadString(ref(context.storage(), path), 'control-bytes');
  });
  await env.withSecurityRulesDisabled(async (context) => {
    const bytes = await getBytes(ref(context.storage(), path));
    assert.equal(bytes.byteLength, 'control-bytes'.length);
  });

  await assertFails(getBytes(ref(visitor, path)));
  await assertFails(getBytes(ref(reader, path)));
  await assertFails(uploadString(ref(reader, 'private/issues/i2.pdf'), 'x'));
});

test('auth emulator: sign-up works and the verification code can be read back from the emulator', async () => {
  const json = { 'content-type': 'application/json' };
  const email = 'spike-user@example.test';

  const signUp = await fetch(`${AUTH_BASE}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-key`, {
    method: 'POST',
    headers: json,
    body: JSON.stringify({ email, password: 'spike-password-1', returnSecureToken: true }),
  });
  assert.equal(signUp.status, 200);
  const { idToken } = await signUp.json();
  assert.ok(idToken, 'sign-up returns an id token');

  const send = await fetch(`${AUTH_BASE}/identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=fake-key`, {
    method: 'POST',
    headers: json,
    body: JSON.stringify({ requestType: 'VERIFY_EMAIL', idToken }),
  });
  assert.equal(send.status, 200);

  const codes = await fetch(`${AUTH_BASE}/emulator/v1/projects/${PROJECT_ID}/oobCodes`);
  assert.equal(codes.status, 200);
  const { oobCodes } = await codes.json();
  assert.ok(
    oobCodes.some((c) => c.email === email && c.requestType === 'VERIFY_EMAIL'),
    'the emulator lists the verification code for the new account',
  );

  const cleared = await fetch(`${AUTH_BASE}/emulator/v1/projects/${PROJECT_ID}/accounts`, { method: 'DELETE' });
  assert.equal(cleared.status, 200);
});
