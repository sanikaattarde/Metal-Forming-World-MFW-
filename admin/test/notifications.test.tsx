// @vitest-environment jsdom
// The send-notification and send-log screens (MOD12-P2-T05, SCR-W-07, SCR-W-08) in a simulated browser,
// against the in-memory stand-in server. OP-25 to OP-27 themselves are checked in notifications.emulator.test.ts
// and the backend's G15.
import { cleanup, fireEvent, screen, waitFor, within } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { ERRORS } from '../src/describeError';
import { FIELD_ERRORS, SEND_TEXT } from '../src/SendNotificationPage';
import { LOG_TEXT } from '../src/SendLogPage';
import { fakeDeps } from './fakes';
import { fakeServer, issueRecord, makePost, sendRecord } from './fakeServer';
import { signedInApp } from './render';

afterEach(cleanup);

function setUp(server = fakeServer({ issues: [issueRecord({ issue_id: 'i-pub', title: 'November issue', publication_state: 'published', current_revision: 1 })], posts: [makePost(0), makePost(1)] })) {
  return { server, deps: fakeDeps({ isAdmin: true, call: server.call, read: server.read }) };
}

const field = (label: string) => screen.getByLabelText(label) as HTMLInputElement;
const button = (name: string) => screen.getByRole('button', { name }) as HTMLButtonElement;

async function fillForm({ category = 'notif-new-issues', title = 'A new issue', body = 'Read the November issue.' } = {}) {
  await screen.findByRole('heading', { name: 'Send a notification' });
  await screen.findByRole('option', { name: 'New issues' });
  fireEvent.change(field('Category'), { target: { value: category } });
  fireEvent.change(field('Title'), { target: { value: title } });
  fireEvent.change(field('Message'), { target: { value: body } });
}

// ---- SCR-W-07 ----

test('FR-ADMIN-016: only the active categories are offered, in their order', async () => {
  const { deps } = setUp();
  await signedInApp(deps, '/notifications/new');
  await screen.findByRole('option', { name: 'New issues' });
  const options = within(field('Category') as unknown as HTMLElement).getAllByRole('option').map((o) => o.textContent);
  expect(options).toEqual(['Choose a category', 'New issues', 'Expo specials', 'Major news']);
});

test('the form is checked before anything is sent, and each problem is named', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/notifications/new');
  await screen.findByRole('option', { name: 'New issues' });
  fireEvent.change(field('Title'), { target: { value: 'x'.repeat(101) } });
  fireEvent.click(screen.getByRole('radio', { name: 'An issue' }));
  fireEvent.click(button('Review'));
  for (const text of [FIELD_ERRORS.category_id, FIELD_ERRORS.title, FIELD_ERRORS.body, FIELD_ERRORS.target_ref]) {
    expect(screen.getByText(text)).toBeTruthy();
  }
  expect(server.calls('sendNotification')).toHaveLength(0);
});

test('AC-9.4: a send is reviewed, confirmed, then sent through OP-25 with a request identifier', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/notifications/new');
  await fillForm({ title: '  A new issue  ' });
  fireEvent.click(button('Review'));
  const review = screen.getByRole('group', { name: 'Review the notification' });
  expect(within(review).getByText(SEND_TEXT.confirm)).toBeTruthy();
  expect(within(review).getByText('New issues')).toBeTruthy();
  expect(within(review).getByText('Nothing: the app opens')).toBeTruthy();
  expect(server.calls('sendNotification')).toHaveLength(0);

  fireEvent.click(button('Send now'));
  expect(await screen.findByText(SEND_TEXT.sent)).toBeTruthy();
  const [sent] = server.calls('sendNotification');
  expect(sent.data).toMatchObject({ category_id: 'notif-new-issues', title: 'A new issue', body: 'Read the November issue.', target_type: 'none' });
  expect(sent.data).not.toHaveProperty('target_ref');
  expect(typeof sent.data.request_id).toBe('string');
  expect(field('Title').value).toBe('');
});

test('Back to edit keeps the draft and sends nothing', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/notifications/new');
  await fillForm();
  fireEvent.click(button('Review'));
  fireEvent.click(button('Back to edit'));
  expect(field('Title').value).toBe('A new issue');
  expect(server.calls('sendNotification')).toHaveLength(0);
});

test('FR-ADMIN-015: a notification can open a published issue', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/notifications/new');
  await fillForm();
  fireEvent.click(screen.getByRole('radio', { name: 'An issue' }));
  fireEvent.change(field('Issue'), { target: { value: 'i-pub' } });
  fireEvent.click(button('Review'));
  expect(screen.getByText('The issue November issue')).toBeTruthy();
  fireEvent.click(button('Send now'));
  await screen.findByText(SEND_TEXT.sent);
  expect(server.calls('sendNotification')[0].data).toMatchObject({ target_type: 'issue', target_ref: 'i-pub' });
  expect(server.calls('listIssuesForAdmin')[0].data).toMatchObject({ publication_state: 'published' });
});

test('AC-9.7: a post marked on the news screen opens the send screen with the post linked', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/news');
  const row = (await screen.findByRole('button', { name: 'Save Post 2' })).closest('tr')!;
  fireEvent.click(within(row).getByRole('link', { name: 'Notify readers' }));
  await fillForm({ category: 'notif-major-news', title: 'Breaking' });
  expect((screen.getByRole('radio', { name: 'A news post' }) as HTMLInputElement).checked).toBe(true);
  await waitFor(() => expect(field('News post').value).toBe('101'));
  fireEvent.click(button('Review'));
  fireEvent.click(button('Send now'));
  await screen.findByText(SEND_TEXT.sent);
  expect(server.calls('sendNotification')[0].data).toMatchObject({ category_id: 'notif-major-news', target_type: 'news_post', target_ref: '101' });
});

test('a refused target says why, and the next try reuses the request identifier', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/notifications/new');
  await fillForm();
  fireEvent.click(screen.getByRole('radio', { name: 'A news post' }));
  await screen.findByRole('option', { name: 'Post 1' });
  fireEvent.change(field('News post'), { target: { value: '100' } });
  server.state.posts = [];
  fireEvent.click(button('Review'));
  fireEvent.click(button('Send now'));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.targetNotAvailable);
  fireEvent.click(screen.getByRole('radio', { name: 'Nothing: the app opens' }));
  fireEvent.click(button('Review'));
  fireEvent.click(button('Send now'));
  await screen.findByText(SEND_TEXT.sent);
  const [first, second] = server.calls('sendNotification');
  expect(second.data.request_id).toBe(first.data.request_id);
});

test('a push failure says the send is in the log as failed, and the next send is a new one', async () => {
  const { server, deps } = setUp();
  server.state.pushFails = true;
  await signedInApp(deps, '/notifications/new');
  await fillForm();
  fireEvent.click(button('Review'));
  fireEvent.click(button('Send now'));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.pushFailed);
  server.state.pushFails = false;
  await fillForm({ title: 'Another' });
  fireEvent.click(button('Review'));
  fireEvent.click(button('Send now'));
  await screen.findByText(SEND_TEXT.sent);
  const [first, second] = server.calls('sendNotification');
  expect(second.data.request_id).not.toBe(first.data.request_id);
});

// ---- SCR-W-08 ----

test('FR-ADMIN-018: the log lists sends newest first with the category name, the target and the outcome', async () => {
  const server = fakeServer({
    sends: [
      sendRecord({ send_id: 's2', title: 'Second', target_type: 'issue', target_ref: 'i-pub', outcome: 'failed', sent_at: Date.UTC(2026, 10, 11, 10, 5) }),
      sendRecord({ send_id: 's1', title: 'First', category_id: 'notif-major-news' }),
    ],
  });
  const { deps } = setUp(server);
  await signedInApp(deps, '/notifications');
  const rows = (await screen.findAllByRole('row')).slice(1);
  expect(rows.map((row) => within(row).getAllByRole('cell')[2].textContent)).toEqual(['Second', 'First']);
  const cells = within(rows[0]).getAllByRole('cell').map((cell) => cell.textContent);
  expect(cells.slice(0, 6)).toEqual(['2026-11-11 10:05 GMT', 'New issues', 'Second', 'Issue i-pub', 'Failed', '1']);
  expect(within(rows[1]).getAllByRole('cell')[1].textContent).toBe('Major news');
  expect(within(rows[1]).queryByRole('button')).toBeNull();
});

test('AC-9.5: a failed send is retried from the log through OP-26, by the admin only', async () => {
  const server = fakeServer({ sends: [sendRecord({ send_id: 's1', title: 'Failed one', outcome: 'failed' })] });
  const { deps } = setUp(server);
  await signedInApp(deps, '/notifications');
  fireEvent.click(await screen.findByRole('button', { name: 'Retry Failed one' }));
  expect(await screen.findByText(LOG_TEXT.retried)).toBeTruthy();
  const row = screen.getByText('Failed one').closest('tr')!;
  expect(within(row).getByText('Accepted')).toBeTruthy();
  expect(within(row).getByText('2')).toBeTruthy();
  expect(within(row).queryByRole('button')).toBeNull();
  expect(server.calls('retryNotification')[0].data).toMatchObject({ send_id: 's1' });
});

test('a retry that fails again stays failed, with one more attempt', async () => {
  const server = fakeServer({ sends: [sendRecord({ send_id: 's1', title: 'Failed one', outcome: 'unknown' })] });
  server.state.pushFails = true;
  const { deps } = setUp(server);
  await signedInApp(deps, '/notifications');
  fireEvent.click(await screen.findByRole('button', { name: 'Retry Failed one' }));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.pushFailed);
  const row = screen.getByText('Failed one').closest('tr')!;
  expect(within(row).getByText('Failed')).toBeTruthy();
  expect(within(row).getByText('2')).toBeTruthy();
});

test('the outcome filter asks OP-27 again, and Load more follows the cursor', async () => {
  const sends = Array.from({ length: 25 }, (_, i) => sendRecord({ send_id: `s${i}`, title: `Send ${i}`, outcome: i === 3 ? 'failed' : 'accepted' }));
  const { server, deps } = setUp(fakeServer({ sends }));
  await signedInApp(deps, '/notifications');
  await screen.findByText('Send 0');
  expect(screen.queryByText('Send 24')).toBeNull();
  fireEvent.click(button('Load more'));
  expect(await screen.findByText('Send 24')).toBeTruthy();
  expect(server.calls('listNotificationSends').at(-1)?.data).toMatchObject({ cursor: 's19' });

  fireEvent.change(screen.getByLabelText('Show'), { target: { value: 'failed' } });
  await waitFor(() => expect(screen.queryByText('Send 0')).toBeNull());
  expect(screen.getByText('Send 3')).toBeTruthy();
  expect(server.calls('listNotificationSends').at(-1)?.data).toEqual({ page_size: 20, outcome: 'failed' });
});

test('an empty log says so', async () => {
  const { deps } = setUp(fakeServer());
  await signedInApp(deps, '/notifications');
  expect(await screen.findByText(LOG_TEXT.empty)).toBeTruthy();
});

test('SEC-CHK-15: a title is shown as text', async () => {
  const { deps } = setUp(fakeServer({ sends: [sendRecord({ send_id: 's1', title: '<img src=x onerror=alert(1)>', outcome: 'failed' })] }));
  await signedInApp(deps, '/notifications');
  const row = (await screen.findByText('<img src=x onerror=alert(1)>')).closest('tr')!;
  expect(row.querySelector('img')).toBeNull();
});

test('SC-18: a send over the rate limit says to wait, and nothing is sent', async () => {
  const { server, deps } = setUp();
  server.failNext('sendNotification', Object.assign(new Error('resource-exhausted'), { code: 'functions/resource-exhausted', details: { reason: 'RATE_LIMITED', retry_after_seconds: 30 } }));
  await signedInApp(deps, '/notifications/new');
  await fillForm();
  fireEvent.click(button('Review'));
  fireEvent.click(button('Send now'));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.rateLimited);
  expect(server.state.sends).toHaveLength(0);
});
