// SPIKE (DEC-003, DEC-004 OPEN). Connects the panel to the local emulators only. There is no real project
// configuration (CFG-01 is OPEN), so a page served from any other address gets no services and shows a
// notice instead. The values below are the emulators': a demo project name and its placeholder key, which
// reach no cloud project. No secret is placed in the bundle (TD-14, CODING_STANDARDS.md §15).
import { initializeApp } from 'firebase/app';
import { connectAuthEmulator, initializeAuth, inMemoryPersistence, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import type { Auth } from 'firebase/auth';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';
import type { Functions } from 'firebase/functions';
import { roleCheckThrough } from './adminApi';
import type { CallFn } from './adminApi';
import type { SignInDeps } from './signIn';

export const EMULATOR = {
  projectId: 'demo-mfw-spike',
  apiKey: 'fake-api-key',
  authUrl: 'http://127.0.0.1:9099',
  functionsHost: '127.0.0.1',
  functionsPort: 5001,
} as const;

const LOCAL_HOSTS = new Set(['127.0.0.1', 'localhost']);

export const isLocalHost = (hostname: string): boolean => LOCAL_HOSTS.has(hostname);

// The session lives in memory only, from the start: nothing about the account is kept in browser storage
// (CODING_STANDARDS.md §15 item 5), and a reload signs the admin out. How long a session lasts is OQ-20.
export const AUTH_OPTIONS = { persistence: inMemoryPersistence } as const;

export interface Backend {
  auth: Auth;
  functions: Functions;
}

export interface Services extends SignInDeps {
  // Calls a server operation as the signed-in account. Screens go through adminApi, never this directly.
  call: CallFn;
}

export function emulatorBackend(authUrl: string = EMULATOR.authUrl, name?: string, functionsPort: number = EMULATOR.functionsPort): Backend {
  const app = initializeApp({ apiKey: EMULATOR.apiKey, projectId: EMULATOR.projectId }, name);
  const auth = initializeAuth(app, AUTH_OPTIONS);
  connectAuthEmulator(auth, authUrl, { disableWarnings: true });
  const functions = getFunctions(app);
  connectFunctionsEmulator(functions, EMULATOR.functionsHost, functionsPort);
  return { auth, functions };
}

export function callThrough(functions: Functions): CallFn {
  return async (name, data) => (await httpsCallable(functions, name)(data)).data;
}

export function servicesFor({ auth, functions }: Backend): Services {
  const call = callThrough(functions);
  return {
    signIn: async (email, password) => (await signInWithEmailAndPassword(auth, email, password)).user,
    signOut: () => signOut(auth),
    roleCheck: roleCheckThrough(call),
    call,
  };
}

export async function createServices(hostname: string): Promise<Services | null> {
  if (!isLocalHost(hostname)) return null;
  return servicesFor(emulatorBackend());
}
