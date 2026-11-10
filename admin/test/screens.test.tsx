// @vitest-environment jsdom
// The issue and category screens (MOD12-P2-T03, T-09.3) in a simulated browser, against the
// in-memory stand-in server. The real operations are checked in content.emulator.test.ts.
import { cleanup, fireEvent, screen, waitFor, within } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { ERRORS } from '../src/describeError';
import { MESSAGES } from '../src/messages';
import { fakeDeps, serverError } from './fakes';
import { fakeServer, issueRecord } from './fakeServer';
import { signedInApp } from './render';

afterEach(cleanup);

const CATEGORIES = [
  { category_id: 'c1', name: 'Category one', display_order: 1 },
  { category_id: 'c2', name: 'Category two', display_order: 2 },
];

function setUp(server = fakeServer({ categories: CATEGORIES })) {
  return { server, deps: fakeDeps({ isAdmin: true, call: server.call, read: server.read }) };
}

const rowTitles = () => screen.getAllByRole('row').slice(1).map((row) => within(row).getAllByRole('cell')[0].textContent);
const type = (label: string | RegExp, value: string) => fireEvent.change(screen.getByLabelText(label), { target: { value } });

// ---- SCR-W-02 issues list ----

test('after sign-in the panel opens the issues list, with a menu for issues and categories', async () => {
  const { deps } = setUp();
  await signedInApp(deps);
  expect(await screen.findByRole('heading', { name: 'Issues' })).toBeTruthy();
  const menu = screen.getByRole('navigation', { name: 'Admin sections' });
  expect(within(menu).getAllByRole('link').map((link) => link.textContent)).toEqual(['Issues', 'Categories']);
});

test('FR-ADMIN-011: the list shows published and unpublished issues, newest first, and filters by state', async () => {
  const { server, deps } = setUp(
    fakeServer({
      issues: [
        issueRecord({ issue_id: 'i-old', title: 'Old', publication_date: '2026-01-01', publication_state: 'published' }),
        issueRecord({ issue_id: 'i-new', title: 'New', publication_date: '2026-09-01' }),
      ],
      categories: CATEGORIES,
    }),
  );
  await signedInApp(deps, '/issues');
  await screen.findByText('New');
  expect(rowTitles()).toEqual(['New', 'Old']);
  expect(screen.getAllByRole('row')[1].textContent).toContain('Unpublished');

  fireEvent.change(screen.getByLabelText('Show'), { target: { value: 'published' } });
  await waitFor(() => expect(rowTitles()).toEqual(['Old']));
  expect(server.calls('listIssuesForAdmin').at(-1)?.data.publication_state).toBe('published');
});

test('"Show more" asks for the next page with the cursor', async () => {
  const issues = Array.from({ length: 25 }, (_, i) => issueRecord({ issue_id: `i-${String(i).padStart(2, '0')}`, title: `Issue ${i}`, publication_date: `2026-01-${String(i + 1).padStart(2, '0')}` }));
  const { server, deps } = setUp(fakeServer({ issues, categories: CATEGORIES }));
  await signedInApp(deps, '/issues');
  await screen.findByText('Issue 24');
  expect(rowTitles()).toHaveLength(20);
  fireEvent.click(screen.getByRole('button', { name: 'Show more' }));
  await waitFor(() => expect(rowTitles()).toHaveLength(25));
  expect(server.calls('listIssuesForAdmin').at(-1)?.data.cursor).toBe('i-05');
  expect(screen.queryByRole('button', { name: 'Show more' })).toBeNull();
});

test('opening an issue from the list shows its details without asking the server again', async () => {
  const { server, deps } = setUp(fakeServer({ issues: [issueRecord({ issue_id: 'i-1', title: 'March issue' })], categories: CATEGORIES }));
  await signedInApp(deps, '/issues');
  fireEvent.click(await screen.findByRole('link', { name: 'March issue' }));
  expect(await screen.findByRole('heading', { name: 'Edit issue' })).toBeTruthy();
  expect((screen.getByLabelText('Title') as HTMLInputElement).value).toBe('March issue');
  expect(server.calls('listIssuesForAdmin')).toHaveLength(1);
});

test('opening an issue by its address finds it by paging through the list (K-2)', async () => {
  const issues = Array.from({ length: 25 }, (_, i) => issueRecord({ issue_id: `i-${String(i).padStart(2, '0')}`, title: `Issue ${i}`, publication_date: `2026-01-${String(i + 1).padStart(2, '0')}` }));
  const { server, deps } = setUp(fakeServer({ issues, categories: CATEGORIES }));
  await signedInApp(deps, '/issues/i-00');
  expect(await screen.findByDisplayValue('Issue 0')).toBeTruthy();
  expect(server.calls('listIssuesForAdmin')).toHaveLength(2);
});

test('an address for an issue that does not exist says so', async () => {
  const { deps } = setUp();
  await signedInApp(deps, '/issues/no-such-issue');
  expect((await screen.findByRole('alert')).textContent).toBe('This issue was not found.');
});

test('an unknown address goes to the issues list', async () => {
  const { deps } = setUp();
  await signedInApp(deps, '/somewhere-else');
  expect(await screen.findByRole('heading', { name: 'Issues' })).toBeTruthy();
});

// ---- SCR-W-03 issue editor ----

async function fillNewIssue() {
  await screen.findByRole('heading', { name: 'New issue' });
  await screen.findByRole('option', { name: 'Category one' });
  type('Title', 'November issue');
  type('Description', 'Presses and dies');
  type('Category', 'c1');
  type('Publication date', '2026-11-01');
}

test('FR-ADMIN-009: a new issue is created through OP-16, unpublished, and the screen moves to it', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/issues/new');
  await fillNewIssue();
  fireEvent.click(screen.getByRole('button', { name: 'Create issue' }));
  expect(await screen.findByRole('heading', { name: 'Edit issue' })).toBeTruthy();
  const sent = server.calls('saveIssue')[0].data;
  expect(sent.issue_id).toBeUndefined();
  expect(sent).toMatchObject({ title: 'November issue', description: 'Presses and dies', category_id: 'c1', publication_date: '2026-11-01' });
  expect(typeof sent.request_id).toBe('string');
  expect(sent).not.toHaveProperty('year');
  expect(sent).not.toHaveProperty('edition');
  expect(screen.getByText('Unpublished')).toBeTruthy();
  expect(server.state.issues).toHaveLength(1);
});

test('a retry after a failed create sends the same request identifier, so no second issue is made', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/issues/new');
  await fillNewIssue();
  server.failNext('saveIssue', serverError('unavailable'));
  fireEvent.click(screen.getByRole('button', { name: 'Create issue' }));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.other);
  fireEvent.click(screen.getByRole('button', { name: 'Create issue' }));
  await screen.findByRole('heading', { name: 'Edit issue' });
  const [first, second] = server.calls('saveIssue');
  expect(second.data.request_id).toBe(first.data.request_id);
});

test('missing details are named by label, never by the value typed', async () => {
  const { deps } = setUp();
  await signedInApp(deps, '/issues/new');
  await screen.findByRole('heading', { name: 'New issue' });
  type('Description', 'Only a description');
  type(/^Year/, 'twenty');
  fireEvent.click(screen.getByRole('button', { name: 'Create issue' }));
  expect((await screen.findByRole('alert')).textContent).toBe(`${ERRORS.fields}Category, Publication date, Title, Year.`);
});

test('an edit sends the record version the screen showed, and a stale screen is told to reload', async () => {
  const issue = issueRecord({ issue_id: 'i-1', title: 'March issue', updated_at: 500 });
  const { server, deps } = setUp(fakeServer({ issues: [issue], categories: CATEGORIES }));
  await signedInApp(deps, '/issues/i-1');
  await screen.findByDisplayValue('March issue');
  type('Title', 'March issue, revised');
  type(/^Edition/, 'Expo special');
  fireEvent.click(screen.getByRole('button', { name: 'Save changes' }));
  expect(await screen.findByText('Saved.')).toBeTruthy();
  expect(server.calls('saveIssue')[0].data).toMatchObject({ issue_id: 'i-1', expected_updated_at: 500, title: 'March issue, revised', edition: 'Expo special' });

  server.state.issues[0].updated_at = 9999; // someone else saved meanwhile
  type('Title', 'Another change');
  fireEvent.click(screen.getByRole('button', { name: 'Save changes' }));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.stale);
});

test('AC-8.7: publishing asks first; cancelling sends nothing; confirming publishes', async () => {
  const issue = issueRecord({ issue_id: 'i-1', current_revision: 1 });
  const { server, deps } = setUp(fakeServer({ issues: [issue], categories: CATEGORIES }));
  await signedInApp(deps, '/issues/i-1');
  fireEvent.click(await screen.findByRole('button', { name: 'Publish' }));
  fireEvent.click(screen.getByRole('button', { name: 'Cancel' }));
  expect(server.calls('publishIssue')).toHaveLength(0);

  fireEvent.click(screen.getByRole('button', { name: 'Publish' }));
  fireEvent.click(screen.getByRole('button', { name: 'Confirm publish' }));
  expect(await screen.findByText('Published.')).toBeTruthy();
  expect(screen.getByText('Published', { selector: 'strong' })).toBeTruthy();
  expect(server.calls('publishIssue')[0].data.issue_id).toBe('i-1');

  fireEvent.click(screen.getByRole('button', { name: 'Unpublish' }));
  fireEvent.click(screen.getByRole('button', { name: 'Confirm unpublish' }));
  expect(await screen.findByText('Unpublished.')).toBeTruthy();
  expect(server.state.issues[0].publication_state).toBe('unpublished');
});

test('an issue with no accepted file cannot be published, and the screen says why', async () => {
  const { deps } = setUp(fakeServer({ issues: [issueRecord({ issue_id: 'i-1' })], categories: CATEGORIES }));
  await signedInApp(deps, '/issues/i-1');
  expect(await screen.findByText(/No accepted file/)).toBeTruthy();
  fireEvent.click(screen.getByRole('button', { name: 'Publish' }));
  fireEvent.click(screen.getByRole('button', { name: 'Confirm publish' }));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.noAcceptedFile);
});

// ---- SCR-W-05 categories ----

test('FR-ADMIN-010: categories are listed in order, and a new one goes after the last', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/categories');
  await screen.findByDisplayValue('Category one');
  expect(screen.getAllByRole('row').slice(1).map((row) => (within(row).getAllByRole('textbox')[0] as HTMLInputElement).value)).toEqual(['Category one', 'Category two']);
  type('Name', 'Category three');
  fireEvent.click(screen.getByRole('button', { name: 'Add category' }));
  expect(await screen.findByDisplayValue('Category three')).toBeTruthy();
  expect(server.calls('saveCategory')[0].data).toMatchObject({ name: 'Category three', display_order: 3 });
  expect(server.calls('saveCategory')[0].data.category_id).toBeUndefined();
});

test('AC-8.6: renaming a category saves it by its identifier', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/categories');
  fireEvent.change(await screen.findByLabelText('Name of Category two'), { target: { value: 'Category 2' } });
  fireEvent.click(screen.getAllByRole('button', { name: 'Save' })[1]);
  expect(await screen.findByText('Category saved.')).toBeTruthy();
  expect(server.calls('saveCategory')[0].data).toMatchObject({ category_id: 'c2', name: 'Category 2', display_order: 2 });
});

test('a name another category has, ignoring case, is refused with its own message', async () => {
  const { deps } = setUp();
  await signedInApp(deps, '/categories');
  await screen.findByDisplayValue('Category one');
  type('Name', 'CATEGORY ONE');
  fireEvent.click(screen.getByRole('button', { name: 'Add category' }));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.nameTaken);
});

test('deleting asks first; a category in use is refused; an unused one is removed', async () => {
  const server = fakeServer({ issues: [issueRecord({ issue_id: 'i-1', category_id: 'c1' })], categories: CATEGORIES });
  const { deps } = setUp(server);
  await signedInApp(deps, '/categories');
  fireEvent.click(await screen.findByRole('button', { name: 'Delete Category one' }));
  fireEvent.click(screen.getByRole('button', { name: 'Cancel' }));
  expect(server.calls('deleteCategory')).toHaveLength(0);

  fireEvent.click(screen.getByRole('button', { name: 'Delete Category one' }));
  fireEvent.click(screen.getByRole('button', { name: 'Confirm delete of Category one' }));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.inUse);
  expect(server.state.categories).toHaveLength(2);

  fireEvent.click(screen.getByRole('button', { name: 'Delete Category two' }));
  fireEvent.click(screen.getByRole('button', { name: 'Confirm delete of Category two' }));
  expect(await screen.findByText('Category deleted.')).toBeTruthy();
  await waitFor(() => expect(screen.queryByDisplayValue('Category two')).toBeNull());
});

// ---- The session and the server's messages ----

test('SEC-CHK-18: a screen whose call is refused as no longer an admin returns to sign-in with the notice', async () => {
  const { server, deps } = setUp();
  server.failNext('listIssuesForAdmin', serverError('permission-denied'));
  await signedInApp(deps, '/issues');
  expect((await screen.findByRole('alert')).textContent).toBe(MESSAGES.accessEnded);
  expect(screen.getByRole('heading', { name: 'Admin sign-in' })).toBeTruthy();
  expect(deps.calls.signOut).toBe(1);
});

test('the server\'s own message never reaches the screen', async () => {
  const { server, deps } = setUp();
  server.failNext('listIssuesForAdmin', Object.assign(new Error('internal detail from the server'), { code: 'functions/internal' }));
  await signedInApp(deps, '/issues');
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.other);
  expect(document.body.textContent).not.toContain('internal detail');
});
