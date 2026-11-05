// SPIKE (DEC-003, DEC-004 OPEN). Connects the panel to the local Auth emulator only. There is no real
// project configuration (CFG-01 is OPEN), so a page served from any other address gets no services and
// shows a notice instead. The values below are the emulator's: a demo project name and its placeholder
// key, which reach no cloud project. No secret is placed in the bundle (TD-14, CODING_STANDARDS.md §15).
import { initializeApp } from 'firebase/app';
import { connectAuthEmulator, initializeAuth, inMemoryPersistence, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import type { Auth } from 'firebase/auth';
import { roleCheckNotBuilt } from './roleCheck';
import type { SignInDeps } from './signIn';

export const EMULATOR = {
  projectId: 'demo-mfw-spike',
  apiKey: 'fake-api-key',
  authUrl: 'http://127.0.0.1:9099',
} as const;

const LOCAL_HOSTS = new Set(['127.0.0.1', 'localhost']);

export const isLocalHost = (hostname: string): boolean => LOCAL_HOSTS.has(hostname);

// The session lives in memory only, from the start: nothing about the account is kept in browser storage
// (CODING_STANDARDS.md §15 item 5), and a reload signs the admin out. How long a session lasts is OQ-20.
export const AUTH_OPTIONS = { persistence: inMemoryPersistence } as const;

export function emulatorAuth(authUrl: string = EMULATOR.authUrl, name?: string): Auth {
  const app = initializeApp({ apiKey: EMULATOR.apiKey, projectId: EMULATOR.projectId }, name);
  const auth = initializeAuth(app, AUTH_OPTIONS);
  connectAuthEmulator(auth, authUrl, { disableWarnings: true });
  return auth;
}

export function authDeps(auth: Auth, roleCheck = roleCheckNotBuilt): SignInDeps {
  return {
    signIn: async (email, password) => (await signInWithEmailAndPassword(auth, email, password)).user,
    signOut: () => signOut(auth),
    roleCheck,
  };
}

export async function createServices(hostname: string): Promise<SignInDeps | null> {
  if (!isLocalHost(hostname)) return null;
  return authDeps(emulatorAuth());
}
