// SPIKE helper (DEC-003 OPEN). Local emulators only. Results are "emulator only".
import { readFileSync } from 'node:fs';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, setDoc, Timestamp } from 'firebase/firestore';
import { ref, uploadString } from 'firebase/storage';

const config = JSON.parse(readFileSync(new URL('../firebase.json', import.meta.url), 'utf8'));
const read = (name) => readFileSync(new URL(`../${name}`, import.meta.url), 'utf8');

// A "demo-" project name is meant to keep the emulators offline. NOT VERIFIED here.
export const PROJECT_ID = 'demo-mfw-spike';
export const AUTH_BASE = `http://${config.emulators.auth.host}:${config.emulators.auth.port}`;

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

export const bookmark = (uid, id, over = {}) => ({
  bookmark_id: id,
  user_id: uid,
  issue_id: 'i-pub',
  page_number: 7,
  file_revision: 1,
  created_at: now(),
  ...over,
});

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
    await put('notification_categories/n1', { name: 'new issues', is_active: true });
    await put('news_controls/101', { is_hidden: true, is_breaking: false });
    await put('deleted_issues/i-gone', { deleted_at: now() });
    await put('config/public', { policy_versions: { privacy_policy: 'test' } });
    await put('config/private', { max_upload_bytes: 1 });

    for (const uid of ['reader-a', 'reader-b']) {
      await put(`users/${uid}`, { user_id: uid, status: 'active', created_at: now() });
      await put(`users/${uid}/profile/current`, { user_id: uid, full_name: 'Test Reader' });
      await put(`users/${uid}/consents/c1`, { consent_id: 'c1', user_id: uid, document_type: 'privacy_policy' });
      await put(`users/${uid}/bookmarks/b-seed`, bookmark(uid, 'b-seed'));
      await put(`users/${uid}/favourites/i-pub`, favourite(uid, 'i-pub'));
      await put(`users/${uid}/notification_preferences/n1`, preference(uid, 'n1'));
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
