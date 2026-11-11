// The send-notification and send-log calls (MOD12-P2-T05) against the backend's real OP-25 to OP-27 on the
// local emulators, with the backend's stand-in push sender: no real device is reached, and push is not set
// up in MFW's accounts (MOD11-P2-T01). Every result is "emulator only". Run through `npm test`.
import { afterAll, beforeAll, beforeEach, expect, test } from 'vitest';
import { adminApi } from '../src/adminApi';
import type { CallFn } from '../src/adminApi';
import { listSends, newRequestId, publishedIssues, retryNotification, sendNotification } from '../src/data';
import { describeError, ERRORS } from '../src/describeError';
import { emulatorBackend, servicesFor } from '../src/services';
import type { Backend, Services } from '../src/services';
import { signInAdmin } from '../src/signIn';
import { AUTH_URL, clearAll, createAdmin, PASSWORD, requireEmulators, setDoc } from './emulator';

let backend: Backend;
let services: Services;
let api: CallFn;
let n = 0;

const CATEGORIES = [
  { category_id: 'notif-new-issues', name: 'New issues', display_order: 1, is_active: true },
  { category_id: 'notif-major-news', name: 'Major news', display_order: 3, is_active: true },
  { category_id: 'notif-old', name: 'Old', display_order: 9, is_active: false },
];

beforeAll(() => {
  requireEmulators();
  backend = emulatorBackend(AUTH_URL, 'b55-admin');
  services = servicesFor(backend);
  api = adminApi(services.call, () => {
    throw new Error('the session ended during a test');
  });
});

afterAll(async () => {
  await backend.auth.signOut();
});

beforeEach(async () => {
  await backend.auth.signOut();
  await clearAll();
  n += 1;
  await createAdmin(`admin-${n}@example.test`);
  for (const category of CATEGORIES) await setDoc(`notification_categories/${category.category_id}`, category);
  await setDoc('issues/i-pub', { issue_id: 'i-pub', title: 'November issue', publication_state: 'published', publication_date: '2026-11-01' });
  await setDoc('issues/i-unpub', { issue_id: 'i-unpub', title: 'Draft', publication_state: 'unpublished', publication_date: '2026-11-02' });
  expect(await signInAdmin(services, `admin-${n}@example.test`, PASSWORD)).toBe('signed-in');
});

const draft = { category_id: 'notif-new-issues', title: 'A new issue', body: 'Read it now.', target_type: 'none' as const };

test('the public read gives the categories in order, with the inactive one marked', async () => {
  const all = await services.read.notificationCategories();
  expect(all.map((c) => [c.category_id, c.is_active])).toEqual([
    ['notif-new-issues', true],
    ['notif-major-news', true],
    ['notif-old', false],
  ]);
});

test('AC-9.4: a send through OP-25 is accepted and is the first line of the log', async () => {
  const result = await sendNotification(api, newRequestId(), { ...draft, target_type: 'issue', target_ref: 'i-pub' });
  expect(result.outcome).toBe('accepted');
  const page = await listSends(api);
  expect(page.items).toHaveLength(1);
  expect(page.items[0]).toMatchObject({ send_id: result.send_id, title: 'A new issue', target_type: 'issue', target_ref: 'i-pub', outcome: 'accepted', attempt_count: 1 });
});

test('the same request identifier twice is one send', async () => {
  const requestId = newRequestId();
  const first = await sendNotification(api, requestId, draft);
  const second = await sendNotification(api, requestId, draft);
  expect(second).toEqual(first);
  expect((await listSends(api)).items).toHaveLength(1);
});

test('the issue targets are the published issues only', async () => {
  expect((await publishedIssues(api)).map((issue) => issue.issue_id)).toEqual(['i-pub']);
});

test('an unpublished issue is refused with its message, and nothing is logged', async () => {
  const error = await sendNotification(api, newRequestId(), { ...draft, target_type: 'issue', target_ref: 'i-unpub' }).catch((e: unknown) => e);
  expect(describeError(error)).toBe(ERRORS.targetNotAvailable);
  expect((await listSends(api)).items).toHaveLength(0);
});

test('AC-9.5: a push failure is logged as failed and is retried from the log', async () => {
  await setDoc('emulator_push/control', { outcome: 'fail' });
  const error = await sendNotification(api, newRequestId(), draft).catch((e: unknown) => e);
  expect(error).toMatchObject({ code: 'functions/unavailable', details: { reason: 'PUSH_FAILED' } });
  expect(describeError(error)).toBe(ERRORS.pushFailed);
  const [failed] = (await listSends(api, { outcome: 'failed' })).items;
  expect(failed.outcome).toBe('failed');

  await setDoc('emulator_push/control', { outcome: 'accept' });
  expect((await retryNotification(api, failed.send_id)).outcome).toBe('accepted');
  const [after] = (await listSends(api)).items;
  expect(after).toMatchObject({ send_id: failed.send_id, outcome: 'accepted', attempt_count: 2 });

  const again = await retryNotification(api, failed.send_id).catch((e: unknown) => e);
  expect(describeError(again)).toBe(ERRORS.notRetryable);
});
