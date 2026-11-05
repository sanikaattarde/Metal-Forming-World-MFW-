// SPIKE (DEC-003, DEC-004 OPEN). Connects the panel to the local emulators only. There is no real project
// configuration (CFG-01 is OPEN), so a page served from any other address gets no services and shows a
// notice instead. The values below are the emulators': a demo project name and its placeholder key, which
// reach no cloud project. No secret is placed in the bundle (TD-14, CODING_STANDARDS.md §15).
import { initializeApp } from 'firebase/app';
import { connectAuthEmulator, initializeAuth, inMemoryPersistence, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import type { Auth } from 'firebase/auth';
import { collection, connectFirestoreEmulator, getDocs, getFirestore, orderBy, query } from 'firebase/firestore/lite';
import type { Firestore } from 'firebase/firestore/lite';
import { connectFunctionsEmulator, getFunctions, httpsCallable } from 'firebase/functions';
import type { Functions } from 'firebase/functions';
import { roleCheckThrough } from './adminApi';
import type { CallFn } from './adminApi';
import type { Category, NewsControl, Reads, Segment } from './data';
import type { SignInDeps } from './signIn';

export const EMULATOR = {
  projectId: 'demo-mfw-spike',
  apiKey: 'fake-api-key',
  authUrl: 'http://127.0.0.1:9099',
  functionsHost: '127.0.0.1',
  functionsPort: 5001,
  firestoreHost: '127.0.0.1',
  firestorePort: 8080,
} as const;

const LOCAL_HOSTS = new Set(['127.0.0.1', 'localhost']);

export const isLocalHost = (hostname: string): boolean => LOCAL_HOSTS.has(hostname);

// The session lives in memory only, from the start: nothing about the account is kept in browser storage
// (CODING_STANDARDS.md §15 item 5), and a reload signs the admin out. How long a session lasts is OQ-20.
export const AUTH_OPTIONS = { persistence: inMemoryPersistence } as const;

export interface Backend {
  auth: Auth;
  functions: Functions;
  firestore: Firestore;
}

export interface Services extends SignInDeps {
  // Calls a server operation as the signed-in account. Screens go through adminApi, never this directly.
  call: CallFn;
  // Public reads, the same the app makes. The rules allow them to anyone, and refuse every client write.
  read: Reads;
}

export function emulatorBackend(authUrl: string = EMULATOR.authUrl, name?: string, functionsPort: number = EMULATOR.functionsPort): Backend {
  const app = initializeApp({ apiKey: EMULATOR.apiKey, projectId: EMULATOR.projectId }, name);
  const auth = initializeAuth(app, AUTH_OPTIONS);
  connectAuthEmulator(auth, authUrl, { disableWarnings: true });
  const functions = getFunctions(app);
  connectFunctionsEmulator(functions, EMULATOR.functionsHost, functionsPort);
  const firestore = getFirestore(app);
  connectFirestoreEmulator(firestore, EMULATOR.firestoreHost, EMULATOR.firestorePort);
  return { auth, functions, firestore };
}

export function readsThrough(firestore: Firestore): Reads {
  return {
    categories: async () =>
      (await getDocs(query(collection(firestore, 'categories'), orderBy('display_order')))).docs.map((doc) => ({
        category_id: doc.id,
        name: String(doc.get('name') ?? ''),
        display_order: Number(doc.get('display_order') ?? 0),
      }) satisfies Category),
    segments: async () =>
      (await getDocs(collection(firestore, 'segments'))).docs.map((doc) => ({ segment_id: doc.id, name: String(doc.get('name') ?? doc.id) }) satisfies Segment),
    newsControls: async () =>
      (await getDocs(collection(firestore, 'news_controls'))).docs.map(
        (doc) => ({ wp_post_id: Number(doc.get('wp_post_id') ?? doc.id), is_hidden: doc.get('is_hidden') === true, is_breaking: doc.get('is_breaking') === true }) satisfies NewsControl,
      ),
  };
}

export function callThrough(functions: Functions): CallFn {
  return async (name, data) => (await httpsCallable(functions, name)(data)).data;
}

export function servicesFor({ auth, functions, firestore }: Backend): Services {
  const call = callThrough(functions);
  return {
    signIn: async (email, password) => (await signInWithEmailAndPassword(auth, email, password)).user,
    signOut: () => signOut(auth),
    roleCheck: roleCheckThrough(call),
    call,
    read: readsThrough(firestore),
  };
}

export async function createServices(hostname: string): Promise<Services | null> {
  if (!isLocalHost(hostname)) return null;
  return servicesFor(emulatorBackend());
}
