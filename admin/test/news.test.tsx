// @vitest-environment jsdom
// SPIKE (DEC-004 OPEN). The news-controls screen (B5.3, T-09.4, SCR-W-06) in a simulated browser, against the
// in-memory stand-in server. OP-24 and OP-23 themselves are checked in news.emulator.test.ts and G12.
import { cleanup, fireEvent, screen, waitFor, within } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { ERRORS } from '../src/describeError';
import { fakeDeps, serverError } from './fakes';
import { fakeServer, makePost } from './fakeServer';
import { signedInApp } from './render';

afterEach(cleanup);

function setUp(server = fakeServer({ posts: [makePost(0), makePost(1), makePost(2)] })) {
  return { server, deps: fakeDeps({ isAdmin: true, call: server.call, read: server.read }) };
}

const checkbox = (name: string) => screen.getByRole('checkbox', { name }) as HTMLInputElement;
const saveButton = (title: string) => screen.getByRole('button', { name: `Save ${title}` }) as HTMLButtonElement;

test('B5.3 FR-ADMIN-013: the news screen lists posts through OP-24, with the flags already set', async () => {
  const server = fakeServer({ posts: [makePost(0), makePost(1)], controls: [{ wp_post_id: 101, is_hidden: true, is_breaking: false }] });
  const { deps } = setUp(server);
  await signedInApp(deps, '/news');
  expect(await screen.findByText('Post 1')).toBeTruthy();
  expect(checkbox('Hide Post 1').checked).toBe(false);
  expect(checkbox('Hide Post 2').checked).toBe(true);
  expect(checkbox('Mark Post 2 as breaking').checked).toBe(false);
  expect(server.calls('listWordPressPosts')[0].data).toEqual({ page: 1, per_page: 20 });
});

test('B5.3 AC-8.8: hiding a post saves it through OP-23, and Save is only offered for a change', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/news');
  await screen.findByText('Post 1');
  expect(saveButton('Post 1').disabled).toBe(true);
  fireEvent.click(checkbox('Hide Post 1'));
  expect(saveButton('Post 1').disabled).toBe(false);
  fireEvent.click(saveButton('Post 1'));
  expect(await screen.findByText('Saved.')).toBeTruthy();
  const sent = server.calls('setNewsControl')[0].data;
  expect(sent).toMatchObject({ wp_post_id: 100, is_hidden: true, is_breaking: false });
  expect(typeof sent.request_id).toBe('string');
  await waitFor(() => expect(saveButton('Post 1').disabled).toBe(true));
});

test('B5.3 FR-ADMIN-014: marking a post as breaking sends the flag and nothing else', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/news');
  await screen.findByText('Post 2');
  fireEvent.click(checkbox('Mark Post 2 as breaking'));
  fireEvent.click(saveButton('Post 2'));
  await screen.findByText('Saved.');
  expect(server.calls('setNewsControl')[0].data).toMatchObject({ wp_post_id: 101, is_hidden: false, is_breaking: true });
  expect(server.log.map((entry) => entry.name)).not.toContain('sendNotification');
});

test('B5.3: clearing both flags sends both as false, which removes the record', async () => {
  const server = fakeServer({ posts: [makePost(0)], controls: [{ wp_post_id: 100, is_hidden: true, is_breaking: true }] });
  const { deps } = setUp(server);
  await signedInApp(deps, '/news');
  await screen.findByText('Post 1');
  fireEvent.click(checkbox('Hide Post 1'));
  fireEvent.click(checkbox('Mark Post 1 as breaking'));
  fireEvent.click(saveButton('Post 1'));
  await screen.findByText('Saved.');
  expect(server.calls('setNewsControl')[0].data).toMatchObject({ wp_post_id: 100, is_hidden: false, is_breaking: false });
  expect(server.state.controls.size).toBe(0);
});

test('B5.3: the pages move with Next and Previous, and the page count is shown', async () => {
  const posts = Array.from({ length: 25 }, (_, i) => makePost(i));
  const { server, deps } = setUp(fakeServer({ posts }));
  await signedInApp(deps, '/news');
  await screen.findByText('Page 1 of 2');
  expect((screen.getByRole('button', { name: 'Previous' }) as HTMLButtonElement).disabled).toBe(true);
  fireEvent.click(screen.getByRole('button', { name: 'Next' }));
  expect(await screen.findByText('Post 21')).toBeTruthy();
  expect(screen.getByText('Page 2 of 2')).toBeTruthy();
  expect(server.calls('listWordPressPosts').at(-1)?.data).toEqual({ page: 2, per_page: 20 });
  expect((screen.getByRole('button', { name: 'Next' }) as HTMLButtonElement).disabled).toBe(true);
  fireEvent.click(screen.getByRole('button', { name: 'Previous' }));
  expect(await screen.findByText('Post 1')).toBeTruthy();
});

test('B5.3: when the site cannot be reached, the screen says so and lists nothing', async () => {
  const { server, deps } = setUp();
  server.failNext('listWordPressPosts', serverError('unavailable', 'SITE_UNAVAILABLE'));
  await signedInApp(deps, '/news');
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.siteUnavailable);
  expect(screen.queryByRole('table')).toBeNull();
});

test('B5.3 SEC-CHK-15: a title is shown as text, and each link opens outside the panel with no opener', async () => {
  const { deps } = setUp(fakeServer({ posts: [makePost(0, { title: '<img src=x onerror=alert(1)> & more' })] }));
  await signedInApp(deps, '/news');
  const row = (await screen.findByRole('button', { name: 'Save <img src=x onerror=alert(1)> & more' })).closest('tr')!;
  expect(row.textContent).toContain('<img src=x onerror=alert(1)> & more');
  expect(row.querySelector('img')).toBeNull();
  const link = within(row).getByRole('link', { name: 'Open post' });
  expect(link.getAttribute('href')).toBe('https://news.example.test/post-1/');
  expect(link.getAttribute('target')).toBe('_blank');
  expect(link.getAttribute('rel')).toBe('noopener noreferrer');
});

test('B5.3: the screen says that breaking sends no notification (AC-9.7 not claimed)', async () => {
  const { deps } = setUp();
  await signedInApp(deps, '/news');
  expect(await screen.findByText(/does not send a notification/)).toBeTruthy();
});
