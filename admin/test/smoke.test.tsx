// @vitest-environment jsdom
// The smoke test for QG-09: the panel starts and shows the sign-in page (SCR-W-01).
// It needs no emulator: `npm run test:smoke`.
import { cleanup, render, screen } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { App } from '../src/App';
import { MESSAGES } from '../src/messages';
import { fakeDeps } from './fakes';

afterEach(cleanup);

test('B3 smoke: the panel shows the sign-in page with an email field, a hidden password field and a button (SCR-W-01)', () => {
  render(<App services={fakeDeps()} />);
  expect(screen.getByRole('heading', { name: 'Admin sign-in' })).toBeTruthy();
  expect(screen.getByLabelText('Email address').getAttribute('type')).toBe('email');
  expect(screen.getByLabelText('Password').getAttribute('type')).toBe('password');
  expect((screen.getByRole('button', { name: 'Sign in' }) as HTMLButtonElement).disabled).toBe(false);
  expect(screen.queryByRole('alert')).toBeNull();
});

test('B3 smoke: with no project configuration and served from an address that is not local, the panel shows a notice and no form (CFG-01)', () => {
  render(<App services={null} />);
  expect(screen.getByRole('alert').textContent).toBe(MESSAGES.notConfigured);
  expect(screen.queryByRole('textbox')).toBeNull();
  expect(screen.queryByRole('button')).toBeNull();
});
