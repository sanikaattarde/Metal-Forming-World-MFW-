// SPIKE. Hand-written stand-ins for the provider, for the component tests that need no emulator.
import type { SignInDeps, SignedInUser } from '../src/signIn';

export interface FakeDeps extends SignInDeps {
  calls: { signIn: number; signOut: number; roleCheck: number };
}

interface Options {
  signIn?: (email: string, password: string) => Promise<SignedInUser>;
  isAdmin?: boolean | (() => Promise<boolean>);
}

export const providerError = (code: string) => Object.assign(new Error(`Firebase: Error (${code}).`), { code });

export function fakeDeps({ signIn, isAdmin = false }: Options = {}): FakeDeps {
  const calls = { signIn: 0, signOut: 0, roleCheck: 0 };
  return {
    calls,
    signIn: async (email, password) => {
      calls.signIn += 1;
      return signIn ? signIn(email, password) : { uid: 'u-1' };
    },
    signOut: async () => {
      calls.signOut += 1;
    },
    roleCheck: async () => {
      calls.roleCheck += 1;
      return typeof isAdmin === 'function' ? isAdmin() : isAdmin;
    },
  };
}
