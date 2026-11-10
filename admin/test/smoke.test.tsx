// @vitest-environment jsdom
// The smoke test for QG-09: the panel starts and shows the sign-in page (SCR-W-01).
// It needs no emulator: `npm run test:smoke`.
import { cleanup, screen } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { MESSAGES } from '../src/messages';
import { fakeDeps } from './fakes';
import { renderApp } from './render';

afterEach(cleanup);

test('the panel shows the sign-in page with an email field, a hidden password field and a button (SCR-W-01)', () => {
  renderApp(fakeDeps());
  expect(screen.getByRole('heading', { name: 'Admin sign-in' })).toBeTruthy();
  expect(screen.getByLabelText('Email address').getAttribute('type')).toBe('email');
  expect(screen.getByLabelText('Password').getAttribute('type')).toBe('password');
  expect((screen.getByRole('button', { name: 'Sign in' }) as HTMLButtonElement).disabled).toBe(false);
  expect(screen.queryByRole('alert')).toBeNull();
});

test('with no project configuration and served from an address that is not local, the panel shows a notice and no form (CFG-01)', () => {
  renderApp(null);
  expect(screen.getByRole('alert').textContent).toBe(MESSAGES.notConfigured);
  expect(screen.queryByRole('textbox')).toBeNull();
  expect(screen.queryByRole('button')).toBeNull();
});
