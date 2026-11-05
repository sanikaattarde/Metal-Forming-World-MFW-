// SPIKE (DEC-004 OPEN). The call wrapper that ends the session, and the OP-14 role check, with stand-ins.
import { expect, test } from 'vitest';
import { AccessLost, adminApi, endsAccess, roleCheckThrough } from '../src/adminApi';
import { serverError } from './fakes';

test('B5: refusals that mean "no longer an admin" end the session', () => {
  for (const error of [serverError('permission-denied'), serverError('unauthenticated'), serverError('failed-precondition', 'ACCOUNT_CLOSED'), serverError('failed-precondition', 'EMAIL_NOT_VERIFIED')]) {
    expect(endsAccess(error)).toBe(true);
  }
});

test('B5: refusals about the request itself do not end the session', () => {
  for (const error of [
    serverError('failed-precondition', 'NO_ACCEPTED_FILE'),
    serverError('failed-precondition', 'IN_USE'),
    serverError('failed-precondition'),
    serverError('not-found'),
    serverError('invalid-argument'),
    serverError('aborted', 'STALE_RECORD'),
    serverError('internal'),
    serverError('unavailable'),
    new Error('network'),
    null,
    undefined,
  ]) {
    expect(endsAccess(error)).toBe(false);
  }
});

test('B5: a call that succeeds passes its reply through', async () => {
  let ended = 0;
  const api = adminApi(async (name, data) => ({ name, data }), () => (ended += 1));
  expect(await api('listIssuesForAdmin', { page_size: 5 })).toEqual({ name: 'listIssuesForAdmin', data: { page_size: 5 } });
  expect(ended).toBe(0);
});

test('B5: a refusal that ends access calls back once and throws AccessLost, not the server error', async () => {
  let ended = 0;
  const api = adminApi(async () => Promise.reject(serverError('permission-denied')), () => (ended += 1));
  const error = await api('saveIssue', {}).catch((e: unknown) => e);
  expect(error).toBeInstanceOf(AccessLost);
  expect(ended).toBe(1);
});

test('B5: any other error reaches the screen unchanged, and the session stays', async () => {
  let ended = 0;
  const original = serverError('failed-precondition', 'NO_ACCEPTED_FILE');
  const api = adminApi(async () => Promise.reject(original), () => (ended += 1));
  await expect(api('publishIssue', {})).rejects.toBe(original);
  expect(ended).toBe(0);
});

test('B5 OQ-20: the role check admits only an active role with a verified email, through OP-14', async () => {
  const asked: string[] = [];
  const check = (reply: unknown) => roleCheckThrough(async (name) => (asked.push(name), reply))({ uid: 'u-1' });
  expect(await check({ is_admin: true, is_active: true, email_verified: true })).toBe(true);
  expect(await check({ is_admin: true, is_active: true, email_verified: false })).toBe(false);
  expect(await check({ is_admin: true, is_active: false, email_verified: true })).toBe(false);
  expect(await check({ is_admin: false, is_active: true, email_verified: true })).toBe(false);
  expect(await check({ is_admin: 'true', is_active: 1, email_verified: 'yes' })).toBe(false);
  expect(await check({ is_admin: true, is_active: true })).toBe(false);
  expect(await check(null)).toBe(false);
  expect(new Set(asked)).toEqual(new Set(['getMyAdminRole']));
});
