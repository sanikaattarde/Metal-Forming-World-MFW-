// Hand-written stand-ins for the provider and the server, for the tests that need no emulator.
import type { CallFn } from '../src/adminApi';
import type { Reads } from '../src/data';
import type { FileSender, SaveText, Services } from '../src/services';
import type { SignedInUser } from '../src/signIn';

export interface FakeDeps extends Services {
  calls: { signIn: number; signOut: number; roleCheck: number; call: string[] };
}

interface Options {
  signIn?: (email: string, password: string) => Promise<SignedInUser>;
  isAdmin?: boolean | (() => Promise<boolean>);
  call?: CallFn;
  read?: Reads;
  upload?: FileSender;
  saveText?: SaveText;
}

export const providerError = (code: string) => Object.assign(new Error(`Firebase: Error (${code}).`), { code });

// A server refusal as the callable SDK reports it.
export const serverError = (code: string, reason?: string) =>
  Object.assign(new Error(code), { code: `functions/${code}`, details: reason ? { reason } : undefined });

export function fakeDeps({ signIn, isAdmin = false, call, read, upload, saveText }: Options = {}): FakeDeps {
  const calls = { signIn: 0, signOut: 0, roleCheck: 0, call: [] as string[] };
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
    call: async (name, data) => {
      calls.call.push(name);
      return call ? call(name, data) : { items: [], next_cursor: null };
    },
    read: read ?? { categories: async () => [], segments: async () => [], newsControls: async () => [], notificationCategories: async () => [] },
    upload: upload ?? { send: async () => undefined, wait: async () => undefined },
    saveText: saveText ?? (() => undefined),
  };
}
