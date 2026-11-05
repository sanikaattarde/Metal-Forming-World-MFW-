// @vitest-environment jsdom
// SPIKE (DEC-004 OPEN). The sign-in page in a simulated browser, with stand-ins for the provider. The same
// cases run against the Auth emulator in sign-in.emulator.test.ts.
import { cleanup, fireEvent, render, screen, waitFor } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { MESSAGES } from '../src/messages';
import { SignInPage } from '../src/SignInPage';
import { fakeDeps, providerError } from './fakes';
import type { FakeDeps } from './fakes';
import { renderApp } from './render';

afterEach(cleanup);

function fillAndSubmit(email = 'admin@example.test', password = 'a-password') {
  fireEvent.change(screen.getByLabelText('Email address'), { target: { value: email } });
  fireEvent.change(screen.getByLabelText('Password'), { target: { value: password } });
  fireEvent.click(screen.getByRole('button', { name: 'Sign in' }));
}

async function messageFor(deps: FakeDeps): Promise<string> {
  render(<SignInPage deps={deps} onSignedIn={() => undefined} />);
  fillAndSubmit();
  const text = (await screen.findByRole('alert')).textContent ?? '';
  cleanup();
  return text;
}

test('B3 AC-8.1, AC-8.2: a wrong password and an account without the admin role show the same message', async () => {
  const wrongPassword = await messageFor(fakeDeps({ signIn: () => Promise.reject(providerError('auth/invalid-credential')) }));
  const notAdmin = await messageFor(fakeDeps({ isAdmin: false }));
  expect(wrongPassword).toBe(MESSAGES.refused);
  expect(notAdmin).toBe(wrongPassword);
});

test('B3 SEC-CHK-17: an unknown address, a disabled account and too many attempts show that same message', async () => {
  for (const code of ['auth/user-not-found', 'auth/wrong-password', 'auth/user-disabled', 'auth/too-many-requests', 'auth/invalid-email']) {
    expect(await messageFor(fakeDeps({ signIn: () => Promise.reject(providerError(code)) }))).toBe(MESSAGES.refused);
  }
});

test('B3: the page never shows the provider error code', async () => {
  render(<SignInPage deps={fakeDeps({ signIn: () => Promise.reject(providerError('auth/user-not-found')) })} onSignedIn={() => undefined} />);
  fillAndSubmit();
  await screen.findByRole('alert');
  expect(document.body.textContent).not.toMatch(/auth\/|user-not-found|Firebase/);
});

test('B3: an account without the admin role is signed out again', async () => {
  const deps = fakeDeps({ isAdmin: false });
  await messageFor(deps);
  expect(deps.calls.roleCheck).toBe(1);
  expect(deps.calls.signOut).toBe(1);
});

test('B3: a role check that fails is a refusal, with the same message, and the account is signed out', async () => {
  const deps = fakeDeps({ isAdmin: () => Promise.reject(new Error('the check could not be made')) });
  expect(await messageFor(deps)).toBe(MESSAGES.refused);
  expect(deps.calls.signOut).toBe(1);
});

test('B3: a role check that answers something other than true is a refusal', async () => {
  const deps = fakeDeps({ isAdmin: () => Promise.resolve('yes' as unknown as boolean) });
  expect(await messageFor(deps)).toBe(MESSAGES.refused);
});

test('B3: when the provider cannot be reached, the page says so with a message of its own', async () => {
  const text = await messageFor(fakeDeps({ signIn: () => Promise.reject(providerError('auth/network-request-failed')) }));
  expect(text).toBe(MESSAGES.unavailable);
  expect(text).not.toBe(MESSAGES.refused);
});

test('B3: after a refusal the password is cleared and the email address is kept', async () => {
  render(<SignInPage deps={fakeDeps()} onSignedIn={() => undefined} />);
  fillAndSubmit('admin@example.test', 'a-password');
  await screen.findByRole('alert');
  expect((screen.getByLabelText('Password') as HTMLInputElement).value).toBe('');
  expect((screen.getByLabelText('Email address') as HTMLInputElement).value).toBe('admin@example.test');
});

test('B3: the button is disabled while a sign-in is in progress, so it cannot be sent twice', async () => {
  let finish: () => void = () => undefined;
  const deps = fakeDeps({ signIn: () => new Promise((resolve) => (finish = () => resolve({ uid: 'u-1' }))) });
  render(<SignInPage deps={deps} onSignedIn={() => undefined} />);
  fillAndSubmit();
  const button = screen.getByRole('button') as HTMLButtonElement;
  expect(button.disabled).toBe(true);
  fireEvent.click(button);
  fireEvent.submit(button.closest('form')!);
  expect(deps.calls.signIn).toBe(1);
  finish();
  await screen.findByRole('alert');
  expect(button.disabled).toBe(false);
});

test('B3: the page sends the password as typed, spaces included (the browser itself trims the email field)', async () => {
  const seen: string[] = [];
  const deps = fakeDeps({ signIn: async (email, password) => (seen.push(email, password), { uid: 'u-1' }) });
  render(<SignInPage deps={deps} onSignedIn={() => undefined} />);
  fillAndSubmit('  admin@example.test ', ' pass word ');
  await screen.findByRole('alert');
  expect(seen).toEqual(['admin@example.test', ' pass word ']);
});

test('B3: an admin reaches the issues list, and signing out returns to the sign-in page', async () => {
  const deps = fakeDeps({ isAdmin: true });
  renderApp(deps);
  fillAndSubmit();
  await screen.findByRole('heading', { name: 'Issues' });
  expect(deps.calls.signOut).toBe(0);
  fireEvent.click(screen.getByRole('button', { name: 'Sign out' }));
  await waitFor(() => expect(screen.getByRole('heading', { name: 'Admin sign-in' })).toBeTruthy());
  expect(deps.calls.signOut).toBe(1);
});
