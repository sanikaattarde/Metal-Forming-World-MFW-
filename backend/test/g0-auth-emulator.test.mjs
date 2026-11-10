// Auth emulator check for MOD-03 (UA-8). Emulator only.
// The email and password below are test values for the local emulator, which holds no real account.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { AUTH_BASE, PROJECT_ID } from './helpers.mjs';

test('auth emulator: sign-up works and the verification code can be read back from the emulator', async () => {
  const json = { 'content-type': 'application/json' };
  const email = 'test-user@example.test';

  const signUp = await fetch(`${AUTH_BASE}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-key`, {
    method: 'POST',
    headers: json,
    body: JSON.stringify({ email, password: 'test-password-1', returnSecureToken: true }),
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
