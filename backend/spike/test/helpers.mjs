// SPIKE helper (DEC-003 OPEN). Local emulators only. Results are "emulator only".
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, setDoc, Timestamp } from 'firebase/firestore';
import { ref, uploadString } from 'firebase/storage';
import { seedDocuments } from '../seed/seed.mjs';

const config = JSON.parse(readFileSync(new URL('../firebase.json', import.meta.url), 'utf8'));
const read = (name) => readFileSync(new URL(`../${name}`, import.meta.url), 'utf8');

// A "demo-" project name is meant to keep the emulators offline. NOT VERIFIED here.
export const PROJECT_ID = 'demo-mfw-spike';
export const AUTH_BASE = `http://${config.emulators.auth.host}:${config.emulators.auth.port}`;
const FUNCTIONS_BASE = `http://${config.emulators.functions.host}:${config.emulators.functions.port}`;

const JSON_HEADERS = { 'content-type': 'application/json' };

export async function clearAuthAccounts() {
  const reply = await fetch(`${AUTH_BASE}/emulator/v1/projects/${PROJECT_ID}/accounts`, {
    method: 'DELETE',
    headers: { authorization: 'Bearer owner' },
  });
  if (!reply.ok) throw new Error(`could not clear accounts: ${reply.status}`);
}

// Test accounts on the local Auth emulator, which holds no real account.
export async function signUp(email) {
  const reply = await fetch(`${AUTH_BASE}/identitytoolkit.googleapis.com/v1/accounts:signUp?key=fake-key`, {
    method: 'POST',
    headers: JSON_HEADERS,
    body: JSON.stringify({ email, password: 'spike-password-1', returnSecureToken: true }),
  });
  const body = await reply.json();
  if (!reply.ok) throw new Error(`sign-up failed: ${JSON.stringify(body)}`);
  return { uid: body.localId, idToken: body.idToken };
}

// Signs in with the test password. Returns the provider's error code, or null when sign-in works.
export async function signInError(email) {
  const reply = await fetch(`${AUTH_BASE}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-key`, {
    method: 'POST',
    headers: JSON_HEADERS,
    body: JSON.stringify({ email, password: 'spike-password-1', returnSecureToken: true }),
  });
  if (reply.ok) return null;
  return (await reply.json()).error?.message ?? String(reply.status);
}

export async function disableAccount(uid) {
  const reply = await fetch(`${AUTH_BASE}/identitytoolkit.googleapis.com/v1/projects/${PROJECT_ID}/accounts:update`, {
    method: 'POST',
    headers: { ...JSON_HEADERS, authorization: 'Bearer owner' },
    body: JSON.stringify({ localId: uid, disableUser: true }),
  });
  if (!reply.ok) throw new Error(`could not disable the account: ${reply.status}`);
}

export async function deleteAccount(idToken) {
  const reply = await fetch(`${AUTH_BASE}/identitytoolkit.googleapis.com/v1/accounts:delete?key=fake-key`, {
    method: 'POST',
    headers: JSON_HEADERS,
    body: JSON.stringify({ idToken }),
  });
  if (!reply.ok) throw new Error(`could not delete the account: ${reply.status}`);
}

// The Admin SDK from the functions folder, pointed at the emulators by emulators:exec. It bypasses
// the rules, so a test can seed and inspect records and call the server code directly.
const requireFromFunctions = createRequire(new URL('../functions/package.json', import.meta.url));

export function adminBackend() {
  const { getApps, initializeApp } = requireFromFunctions('firebase-admin/app');
  const { getAuth } = requireFromFunctions('firebase-admin/auth');
  const { getFirestore } = requireFromFunctions('firebase-admin/firestore');
  const app = getApps()[0] ?? initializeApp({ projectId: PROJECT_ID });
  return { db: getFirestore(app), auth: getAuth(app) };
}

// The bucket the Functions emulator's storage trigger listens on. It is not the test library's default
// bucket (gs://demo-mfw-spike), so a test that needs the trigger names it.
export const TRIGGER_BUCKET = `${PROJECT_ID}.appspot.com`;

export function adminBucket(name = TRIGGER_BUCKET) {
  const { getApps, initializeApp } = requireFromFunctions('firebase-admin/app');
  const { getStorage } = requireFromFunctions('firebase-admin/storage');
  const app = getApps()[0] ?? initializeApp({ projectId: PROJECT_ID });
  return getStorage(app).bucket(name);
}

// A token nobody signed, for a real account, carrying whatever claims the test wants. The Functions
// emulator accepts it (04-save-profile-notes.md, B-1), so it can show that the code ignores claims.
// It says nothing about whether a real platform would accept it.
export function forgedToken(uid, claims = {}) {
  const part = (value) => Buffer.from(JSON.stringify(value)).toString('base64url');
  const issuedAt = Math.floor(Date.now() / 1000);
  const body = {
    iss: `https://securetoken.google.com/${PROJECT_ID}`,
    aud: PROJECT_ID,
    auth_time: issuedAt,
    iat: issuedAt,
    exp: issuedAt + 3600,
    sub: uid,
    user_id: uid,
    firebase: { identities: {}, sign_in_provider: 'password' },
    ...claims,
  };
  return `${part({ alg: 'none', typ: 'JWT' })}.${part(body)}.`;
}

// Calls a callable function the way the client SDK does. Returns the HTTP status, the parsed reply
// and the raw text, so a test can check what the reply does not contain.
export async function callFunction(name, data, idToken) {
  const headers = { ...JSON_HEADERS };
  if (idToken) headers.authorization = `Bearer ${idToken}`;
  const reply = await fetch(`${FUNCTIONS_BASE}/${PROJECT_ID}/us-central1/${name}`, {
    method: 'POST',
    headers,
    body: JSON.stringify({ data }),
  });
  const raw = await reply.text();
  return { status: reply.status, raw, ...JSON.parse(raw) };
}

export async function newTestEnv() {
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      host: config.emulators.firestore.host,
      port: config.emulators.firestore.port,
      rules: read('firestore.rules'),
    },
    storage: {
      host: config.emulators.storage.host,
      port: config.emulators.storage.port,
      rules: read('storage.rules'),
    },
  });
}

// The actors of the access inventory (backend/spike/01-access-inventory.md section 2).
// "admin" is an ordinary account that has a role record. Rules give it nothing extra (GS-Q20).
// "forged" is reader A carrying admin-looking claims. No rule may trust a claim (SC-04).
export const actors = {
  visitor: (env) => env.unauthenticatedContext(),
  readerA: (env) => env.authenticatedContext('reader-a'),
  readerB: (env) => env.authenticatedContext('reader-b'),
  admin: (env) => env.authenticatedContext('admin-1'),
  forged: (env) => env.authenticatedContext('reader-a', { admin: true, role: 'admin', is_admin: true }),
  // A third reader with admin-looking claims. It owns nothing that the tests seed.
  forgedOther: (env) => env.authenticatedContext('reader-c', { admin: true, role: 'admin', is_admin: true }),
};

// Every actor that is not the owner of reader A's records.
export const NOT_READER_A = ['visitor', 'readerB', 'admin', 'forgedOther'];
export const EVERY_ACTOR = ['visitor', 'readerA', 'readerB', 'admin', 'forged', 'forgedOther'];

export const now = () => Timestamp.now();

export const SEED_BOOKMARK = 'i-pub_7';

// The document key of a bookmark, derived from the issue and the page (firestore.rules).
// The notification categories come from the real seed (MOD13-P1-T10), not from test values.
export const SEED_CATEGORIES = seedDocuments().map(({ data }) => data.category_id);

export const bookmarkKey = (issueId, page) => `${issueId}_${page}`;

// `id` is the document key, and the issue and page are read from it unless a test overrides them.
export const bookmark = (uid, id, over = {}) => {
  const split = id.lastIndexOf('_');
  return {
    bookmark_id: id,
    user_id: uid,
    issue_id: id.slice(0, split),
    page_number: Number(id.slice(split + 1)),
    file_revision: 1,
    created_at: now(),
    ...over,
  };
};

export const favourite = (uid, issueId, over = {}) => ({
  user_id: uid,
  issue_id: issueId,
  created_at: now(),
  ...over,
});

export const preference = (uid, categoryId, over = {}) => ({
  user_id: uid,
  category_id: categoryId,
  created_at: now(),
  ...over,
});

// Data written with the rules switched off, to give the tests something to read.
export async function seedFirestore(env) {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    const put = (path, data) => setDoc(doc(db, path), data);

    await put('issues/i-pub', { title: 'Published', publication_state: 'published', segment_ids: ['s1'] });
    await put('issues/i-unpub', { title: 'Unpublished', publication_state: 'unpublished', segment_ids: ['s1'] });
    await put('issues/i-pub/files/1', { storage_path: 'issues/i-pub/1.pdf', status: 'current' });
    await put('segments/s1', { name: 'Segment one' });
    await put('categories/c1', { name: 'Category one' });
    for (const { path, data } of seedDocuments()) await put(path, data);
    await put('news_controls/101', { is_hidden: true, is_breaking: false });
    await put('deleted_issues/i-gone', { deleted_at: now() });
    await put('config/public', { policy_versions: { privacy_policy: 'test' } });
    await put('config/private', { max_upload_bytes: 1 });

    for (const uid of ['reader-a', 'reader-b']) {
      await put(`users/${uid}`, { user_id: uid, status: 'active', created_at: now() });
      await put(`users/${uid}/profile/current`, { user_id: uid, full_name: 'Test Reader' });
      await put(`users/${uid}/consents/c1`, { consent_id: 'c1', user_id: uid, document_type: 'privacy_policy' });
      await put(`users/${uid}/bookmarks/${SEED_BOOKMARK}`, bookmark(uid, SEED_BOOKMARK));
      await put(`users/${uid}/favourites/i-pub`, favourite(uid, 'i-pub'));
      await put(`users/${uid}/notification_preferences/${SEED_CATEGORIES[0]}`, preference(uid, SEED_CATEGORIES[0]));
    }

    await put('admin_roles/admin-1', { user_id: 'admin-1', is_active: true });
    await put('admin_audit/e1', { event_id: 'e1' });
    await put('admin_guard/current', { active_admin_count: 1 });
    await put('upload_jobs/j1', { job_id: 'j1', status: 'pending' });
    await put('notification_sends/s1', { send_id: 's1' });
    await put('edition_updates/e1', { signup_id: 'e1' });
  });
}

export const STORAGE_FILES = {
  privatePdf: 'issues/i-pub/1.pdf',
  cover: 'covers/i-pub/v1',
  holding: 'holding/job-1',
};

// Files written with the rules switched off, so a refusal can only come from the rules.
export async function seedStorage(env) {
  await env.withSecurityRulesDisabled(async (context) => {
    const storage = context.storage();
    for (const path of Object.values(STORAGE_FILES)) {
      await uploadString(ref(storage, path), 'control-bytes');
    }
  });
}
