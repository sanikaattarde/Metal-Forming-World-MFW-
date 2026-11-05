// SPIKE (DEC-004 OPEN). The sign-in decision on its own, with stand-ins for the provider. No emulator.
import { expect, test } from 'vitest';
import { signInAdmin } from '../src/signIn';
import { fakeDeps } from './fakes';

test('B3: the address is sent without spaces at either end, and the password exactly as typed', async () => {
  // A browser already trims an email field, so the page test cannot show this. signInAdmin must not rely on it.
  const seen: string[] = [];
  const deps = fakeDeps({ signIn: async (email, password) => (seen.push(email, password), { uid: 'u-1' }) });
  await signInAdmin(deps, '  admin@example.test \t', ' pass word ');
  expect(seen).toEqual(['admin@example.test', ' pass word ']);
});
