// The calls the issue and category screens make (MOD12-P2-T03, T-09.3), against the backend
// real operations and rules on the local emulators. Every result is "emulator only". Run through
// `npm test`.
import { doc, getDoc } from 'firebase/firestore/lite';
import { afterAll, beforeAll, beforeEach, expect, test } from 'vitest';
import { adminApi } from '../src/adminApi';
import type { CallFn } from '../src/adminApi';
import { createIssue, deleteCategory, findIssue, listIssues, newRequestId, saveCategory, setPublished, updateIssue } from '../src/data';
import type { IssueDetails } from '../src/data';
import { emulatorBackend, servicesFor } from '../src/services';
import type { Backend, Services } from '../src/services';
import { signInAdmin } from '../src/signIn';
import { AUTH_URL, clearAll, createAdmin, PASSWORD, requireEmulators, setDoc } from './emulator';

let backend: Backend;
let visitor: Backend;
let services: Services;
let api: CallFn;
let n = 0;

const DETAILS: IssueDetails = {
  title: 'November issue',
  description: 'Presses and dies',
  category_id: 'c1',
  segment_ids: [],
  publication_date: '2026-11-01',
};

beforeAll(() => {
  requireEmulators();
  backend = emulatorBackend(AUTH_URL, 'b52-admin');
  visitor = emulatorBackend(AUTH_URL, 'b52-visitor');
  services = servicesFor(backend);
  api = adminApi(services.call, () => {
    throw new Error('the session ended during a test');
  });
});

beforeEach(async () => {
  await backend.auth.signOut();
  await clearAll();
  n += 1;
  await createAdmin(`admin-${n}@example.test`);
  expect(await signInAdmin(services, `admin-${n}@example.test`, PASSWORD)).toBe('signed-in');
  await setDoc('categories/c1', { category_id: 'c1', name: 'Category one', display_order: 1 });
});

afterAll(async () => {
  await backend.auth.signOut();
});

const visitorCanRead = async (issueId: string) =>
  getDoc(doc(visitor.firestore, 'issues', issueId)).then(
    (snap) => snap.exists(),
    (error: { code?: string }) => {
      if (error.code === 'permission-denied') return false;
      throw error;
    },
  );

// An accepted file, as the upload trigger (OP-40) would leave it. The upload screen waits for OQ-22 and OQ-30 (MOD12-P2-T02).
async function acceptFile(issueId: string) {
  await setDoc(`issues/${issueId}/files/1`, { revision: 1, status: 'current', size_bytes: 1000, checksum_sha256: 'a'.repeat(64), storage_path: `issues/${issueId}/1-test.pdf` });
  const issue = await findIssue(api, issueId);
  await setDoc(`issues/${issueId}`, {
    issue_id: issueId,
    title: issue!.title!,
    description: issue!.description!,
    category_id: issue!.category_id!,
    segment_ids: [],
    publication_date: issue!.publication_date!,
    year: issue!.year!,
    publication_state: 'unpublished',
    current_revision: 1,
    page_count: 3,
    file_size_bytes: 1000,
    created_at: new Date(),
    updated_at: new Date(),
  });
}

test('AC-8.6: a category added and renamed in the panel is what the public read returns', async () => {
  const added = await saveCategory(api, { name: 'Expo specials', display_order: 2 });
  expect((await services.read.categories()).map((c) => c.name)).toEqual(['Category one', 'Expo specials']);
  await saveCategory(api, { category_id: added.category_id, name: 'Expo special issues', display_order: 0 });
  expect((await services.read.categories()).map((c) => c.name)).toEqual(['Expo special issues', 'Category one']);
});

test('a category name is unique ignoring case (NAME_TAKEN)', async () => {
  await expect(saveCategory(api, { name: 'CATEGORY ONE', display_order: 5 })).rejects.toMatchObject({ code: 'functions/aborted', details: { reason: 'NAME_TAKEN' } });
});

test('a repeated create with the same request identifier makes one category', async () => {
  const request = newRequestId();
  const first = await saveCategory(api, { name: 'Repeat', display_order: 3 }, request);
  const second = await saveCategory(api, { name: 'Repeat', display_order: 3 }, request);
  expect(second.category_id).toBe(first.category_id);
  expect((await services.read.categories()).filter((c) => c.name === 'Repeat')).toHaveLength(1);
});

test('a category in use cannot be deleted; an unused one can', async () => {
  await createIssue(api, newRequestId(), DETAILS);
  await expect(deleteCategory(api, 'c1')).rejects.toMatchObject({ code: 'functions/failed-precondition', details: { reason: 'IN_USE' } });
  const spare = await saveCategory(api, { name: 'Spare', display_order: 9 });
  await deleteCategory(api, spare.category_id);
  expect((await services.read.categories()).map((c) => c.category_id)).toEqual(['c1']);
});

test('FR-ADMIN-009: an issue is created unpublished, found again, and listed by state', async () => {
  const created = await createIssue(api, newRequestId(), DETAILS);
  expect(created).toMatchObject({ title: 'November issue', publication_state: 'unpublished', year: 2026, current_revision: null });
  expect((await findIssue(api, created.issue_id))?.title).toBe('November issue');
  expect((await listIssues(api, { state: 'unpublished' })).items.map((i) => i.issue_id)).toEqual([created.issue_id]);
  expect((await listIssues(api, { state: 'published' })).items).toEqual([]);
  expect(await visitorCanRead(created.issue_id)).toBe(false);
});

test('a repeated create with the same request identifier makes one issue', async () => {
  const request = newRequestId();
  const first = await createIssue(api, request, DETAILS);
  const second = await createIssue(api, request, DETAILS);
  expect(second.issue_id).toBe(first.issue_id);
  expect((await listIssues(api)).items).toHaveLength(1);
});

test('an edit on a stale screen is refused (STALE_RECORD), and a fresh one saves', async () => {
  const created = await createIssue(api, newRequestId(), DETAILS);
  const edited = await updateIssue(api, created, { ...DETAILS, title: 'November issue, revised' });
  expect(edited.title).toBe('November issue, revised');
  await expect(updateIssue(api, created, { ...DETAILS, title: 'From a stale screen' })).rejects.toMatchObject({ details: { reason: 'STALE_RECORD' } });
  expect((await findIssue(api, created.issue_id))?.title).toBe('November issue, revised');
});

test('missing details are refused with the field names (INVALID_ARGUMENT)', async () => {
  await expect(createIssue(api, newRequestId(), { ...DETAILS, title: '', publication_date: '1 Nov 2026' })).rejects.toMatchObject({
    code: 'functions/invalid-argument',
    details: { fields: ['publication_date', 'title'] },
  });
});

test('an issue with no accepted file cannot be published (NO_ACCEPTED_FILE, INV-02)', async () => {
  const created = await createIssue(api, newRequestId(), DETAILS);
  await expect(setPublished(api, created.issue_id, true)).rejects.toMatchObject({ details: { reason: 'NO_ACCEPTED_FILE' } });
});

test('AC-8.7: once published a visitor can read the issue, and once unpublished cannot', async () => {
  const created = await createIssue(api, newRequestId(), DETAILS);
  await acceptFile(created.issue_id);
  expect((await setPublished(api, created.issue_id, true)).publication_state).toBe('published');
  expect(await visitorCanRead(created.issue_id)).toBe(true);
  expect((await setPublished(api, created.issue_id, false)).publication_state).toBe('unpublished');
  expect(await visitorCanRead(created.issue_id)).toBe(false);
});
