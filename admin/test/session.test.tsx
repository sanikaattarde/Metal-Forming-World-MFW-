// @vitest-environment jsdom
// The admin session in a simulated browser, with stand-ins: it ends when the role is
// found removed (MOD12-P2-T01 step 4), and signing out ends it without a notice.
import { act, cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { App } from '../src/App';
import { MESSAGES } from '../src/messages';
import { fakeDeps } from './fakes';

afterEach(cleanup);

async function signInAsAdmin(stillAdmin: { value: boolean }) {
  const deps = fakeDeps({ isAdmin: async () => stillAdmin.value });
  render(<App services={deps} />);
  fireEvent.change(screen.getByLabelText('Email address'), { target: { value: 'admin@example.test' } });
  fireEvent.change(screen.getByLabelText('Password'), { target: { value: 'a-password' } });
  fireEvent.click(screen.getByRole('button', { name: 'Sign in' }));
  await screen.findByRole('heading', { name: 'Admin panel' });
  return deps;
}

test('B5 SEC-CHK-18: coming back to the panel after the role was removed signs the admin out, with a notice', async () => {
  const stillAdmin = { value: true };
  const deps = await signInAsAdmin(stillAdmin);
  stillAdmin.value = false;
  await act(async () => {
    window.dispatchEvent(new Event('focus'));
  });
  expect((await screen.findByRole('alert')).textContent).toBe(MESSAGES.accessEnded);
  expect(screen.getByRole('heading', { name: 'Admin sign-in' })).toBeTruthy();
  expect(deps.calls.signOut).toBe(1);
});

test('B5: coming back to the panel while still an admin keeps the session', async () => {
  const stillAdmin = { value: true };
  const deps = await signInAsAdmin(stillAdmin);
  const checksBefore = deps.calls.roleCheck;
  await act(async () => {
    window.dispatchEvent(new Event('focus'));
  });
  await waitFor(() => expect(deps.calls.roleCheck).toBe(checksBefore + 1));
  expect(screen.getByRole('heading', { name: 'Admin panel' })).toBeTruthy();
  expect(deps.calls.signOut).toBe(0);
});

test('B5: signing out returns to the sign-in page with no notice', async () => {
  const deps = await signInAsAdmin({ value: true });
  fireEvent.click(screen.getByRole('button', { name: 'Sign out' }));
  await screen.findByRole('heading', { name: 'Admin sign-in' });
  expect(screen.queryByRole('alert')).toBeNull();
  expect(deps.calls.signOut).toBe(1);
});
