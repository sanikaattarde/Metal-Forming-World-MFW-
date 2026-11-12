// @vitest-environment jsdom
// SCR-W-10 Admins (MOD12-P3-T02), switched off until OQ-58, against the in-memory stand-in server. The real
// operations are checked in backend G22.
import { cleanup, fireEvent, screen, waitFor, within } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { ERRORS } from '../src/describeError';
import { ADMINS_TEXT } from '../src/AdminsPage';
import { fakeDeps } from './fakes';
import { fakeServer } from './fakeServer';
import { signedInApp } from './render';

afterEach(cleanup);

const setUp = (adminManagement: boolean, server = fakeServer()) => ({
  server,
  deps: fakeDeps({ isAdmin: true, call: server.call, read: server.read, adminManagement }),
});

const menu = () => within(screen.getByRole('navigation', { name: 'Admin sections' }));

test('switched off (the default): no Admins entry, and its address opens the issues', async () => {
  const { server, deps } = setUp(false);
  await signedInApp(deps, '/admins');
  expect(await screen.findByRole('heading', { name: 'Issues' })).toBeTruthy();
  expect(menu().queryByRole('link', { name: 'Admins' })).toBeNull();
  expect(server.calls('listAdmins')).toHaveLength(0);
});

test('switched on: the admins are listed, and a verified reader is added by address', async () => {
  const { server, deps } = setUp(true);
  await signedInApp(deps, '/admins');
  expect(menu().getByRole('link', { name: 'Admins' })).toBeTruthy();
  expect(await screen.findByText('admin@example.test')).toBeTruthy();

  fireEvent.change(screen.getByLabelText(/Add an admin by email address/), { target: { value: ' reader@example.test ' } });
  fireEvent.click(screen.getByRole('button', { name: 'Add admin' }));

  expect((await screen.findByRole('status')).textContent).toBe(ADMINS_TEXT.added('reader@example.test'));
  expect(server.calls('addAdmin')[0].data).toMatchObject({ target_email: 'reader@example.test', expected_state: 'not_admin' });
  expect(await screen.findByText('reader@example.test')).toBeTruthy();
  expect(screen.getByText(/^Added/)).toBeTruthy();
});

test('an unknown address and an unverified one say why', async () => {
  const server = fakeServer();
  server.state.accounts.set('new@example.test', { user_id: 'u-3', verified: false });
  const { deps } = setUp(true, server);
  await signedInApp(deps, '/admins');
  await screen.findByText('admin@example.test');

  fireEvent.change(screen.getByLabelText(/Add an admin by email address/), { target: { value: 'nobody@example.test' } });
  fireEvent.click(screen.getByRole('button', { name: 'Add admin' }));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.noAccount);

  fireEvent.change(screen.getByLabelText(/Add an admin by email address/), { target: { value: 'new@example.test' } });
  fireEvent.click(screen.getByRole('button', { name: 'Add admin' }));
  await waitFor(() => expect(screen.getByRole('alert').textContent).toBe(ERRORS.targetUnverified));
});

test('removing needs the address typed, and the last admin cannot go', async () => {
  const server = fakeServer();
  server.state.admins.push({ user_id: 'u-2', email: 'reader@example.test', is_active: true });
  const { deps } = setUp(true, server);
  await signedInApp(deps, '/admins');
  const row = (await screen.findByText('reader@example.test')).closest('tr') as HTMLElement;
  fireEvent.click(within(row).getByRole('button', { name: 'Remove' }));

  const confirm = screen.getByRole('button', { name: 'Remove admin' }) as HTMLButtonElement;
  expect(confirm.disabled).toBe(true);
  fireEvent.change(screen.getByLabelText(ADMINS_TEXT.confirmLabel('reader@example.test')), { target: { value: 'READER@example.test' } });
  expect(confirm.disabled).toBe(false);
  fireEvent.click(confirm);
  expect((await screen.findByRole('status')).textContent).toBe(ADMINS_TEXT.removed('reader@example.test'));
  await waitFor(() => expect(screen.queryByText('reader@example.test')).toBeNull());

  const last = (await screen.findByText('admin@example.test')).closest('tr') as HTMLElement;
  fireEvent.click(within(last).getByRole('button', { name: 'Remove' }));
  fireEvent.change(screen.getByLabelText(ADMINS_TEXT.confirmLabel('admin@example.test')), { target: { value: 'admin@example.test' } });
  fireEvent.click(screen.getByRole('button', { name: 'Remove admin' }));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.lastAdmin);
});
