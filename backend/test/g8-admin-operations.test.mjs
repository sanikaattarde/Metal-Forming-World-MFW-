// Group G8: the admin operations OP-15 to OP-18 and OP-21 to
// OP-23, through the Functions emulator (SC-02 to SC-05, SEC-CHK-06, SEC-CHK-18, INV-02, INV-12 to INV-14,
// AC-8.6, AC-8.7). Emulator only. The Functions emulator does not verify tokens
// (spike note 04, B-1), so an expired token (FX-ADM-06) cannot be shown here.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { doc, getDoc } from 'firebase/firestore';
import { removeAdminRole } from '../functions/dist/admin.js';
import { derivedId } from '../functions/dist/validation.js';
import {
  adminBackend,
  callFunction,
  clearAuthAccounts,
  disableAccount,
  forgedToken,
  newTestEnv,
  signUp,
} from './helpers.mjs';

let env;
let backend;
let db;
let admin;
let otherAdmin;
let reader;

const NOW = new Date('2026-10-30T10:00:00Z');

const ISSUE_INPUT = {
  title: 'An issue',
  description: 'What it covers',
  category_id: 'c1',
  segment_ids: ['s1'],
  publication_date: '2026-11-01',
};

const seedIssue = (id, over = {}) =>
  db.doc(`issues/${id}`).set({
    issue_id: id,
    ...ISSUE_INPUT,
    year: 2026,
    publication_state: 'unpublished',
    created_at: NOW,
    updated_at: NOW,
    ...over,
  });

const seedAcceptedFile = (issueId, revision = 1, status = 'current') =>
  db.doc(`issues/${issueId}/files/${revision}`).set({ issue_id: issueId, revision, status, storage_path: `issues/${issueId}/${revision}.pdf` });

const call = (name, data, token = admin.idToken) => callFunction(name, data, token);

const refused = (reply, status, reason) => {
  assert.equal(reply.error?.status, status, reply.raw);
  if (reason) assert.equal(reply.error.details?.reason, reason, reply.raw);
};

const invalid = (reply, fields) => {
  assert.equal(reply.error?.status, 'INVALID_ARGUMENT', reply.raw);
  assert.deepEqual(reply.error.details.fields, fields);
};

async function dump() {
  const out = {};
  for (const name of ['issues', 'categories', 'segments', 'news_controls', 'admin_roles', 'admin_guard', 'deleted_issues']) {
    const snap = await db.collection(name).get();
    for (const item of snap.docs) out[`${name}/${item.id}`] = item.data();
  }
  const files = await db.collectionGroup('files').get();
  for (const item of files.docs) out[item.ref.path] = item.data();
  return JSON.stringify(Object.keys(out).sort().map((key) => [key, out[key]]));
}

before(async () => {
  env = await newTestEnv();
  backend = adminBackend();
  db = backend.db;
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  admin = await signUp('admin-a@example.test');
  otherAdmin = await signUp('admin-b@example.test');
  reader = await signUp('reader@example.test');
  for (const account of [admin, otherAdmin]) {
    await db.doc(`admin_roles/${account.uid}`).set({ user_id: account.uid, is_active: true, granted_by: 'test-seed', granted_at: NOW });
  }
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 2, version: 1, updated_at: NOW });
  await db.doc('categories/c1').set({ category_id: 'c1', name: 'Category one', display_order: 1 });
  await db.doc('categories/c-unused').set({ category_id: 'c-unused', name: 'Unused', display_order: 2 });
  await db.doc('segments/s1').set({ segment_id: 's1', name: 'Segment one', display_order: 1, is_active: true });
  await seedIssue('i-ready', { current_revision: 1 });
  await seedAcceptedFile('i-ready');
  await seedIssue('i-live', { current_revision: 1, publication_state: 'published', published_at: NOW });
  await seedAcceptedFile('i-live');
});

// ---- The gate, for every operation and every kind of caller. A refusal writes nothing. ----

const OPERATIONS = {
  listIssuesForAdmin: () => ({}),
  saveIssue: () => ({ request_id: 'r-gate', ...ISSUE_INPUT }),
  saveCategory: () => ({ request_id: 'r-gate', name: 'A new category', display_order: 3 }),
  deleteCategory: () => ({ request_id: 'r-gate', category_id: 'c-unused' }),
  publishIssue: () => ({ request_id: 'r-gate', issue_id: 'i-ready' }),
  unpublishIssue: () => ({ request_id: 'r-gate', issue_id: 'i-live' }),
  setNewsControl: () => ({ request_id: 'r-gate', wp_post_id: 55, is_hidden: true, is_breaking: false }),
};

const CALLERS = {
  'no sign-in token': { token: async () => null, status: 'UNAUTHENTICATED' },
  'a reader (FX-ADM-05)': { token: async () => reader.idToken, status: 'PERMISSION_DENIED' },
  'a reader with forged admin claims (SC-04)': {
    token: async () => forgedToken(reader.uid, { admin: true, role: 'admin', is_admin: true }),
    status: 'PERMISSION_DENIED',
  },
  'a removed admin with a token from before the removal (FX-ADM-08)': {
    token: async () => {
      await removeAdminRole(backend, otherAdmin.uid);
      return otherAdmin.idToken;
    },
    status: 'PERMISSION_DENIED',
  },
  'an admin whose account is marked deleting': {
    token: async () => {
      await db.doc(`users/${otherAdmin.uid}`).set({ user_id: otherAdmin.uid, status: 'deleting' });
      return otherAdmin.idToken;
    },
    status: 'FAILED_PRECONDITION',
    reason: 'ACCOUNT_CLOSED',
  },
  'an admin the provider has disabled': {
    token: async () => {
      await disableAccount(otherAdmin.uid);
      return otherAdmin.idToken;
    },
    status: 'FAILED_PRECONDITION',
    reason: 'ACCOUNT_CLOSED',
  },
};

for (const [name, payload] of Object.entries(OPERATIONS)) {
  test(`G8 ${name}: an active admin can call it (control for the refusals below)`, async () => {
    const reply = await call(name, payload());
    assert.equal(reply.status, 200, reply.raw);
  });

  for (const [label, caller] of Object.entries(CALLERS)) {
    test(`G8 ${name}: ${label} is refused, and nothing is written`, async () => {
      const token = await caller.token();
      const before = await dump();
      const reply = await callFunction(name, payload(), token);
      refused(reply, caller.status, caller.reason);
      assert.equal(await dump(), before);
    });
  }
}

test('G8 the gate comes before the input: a reader with bad input is refused as a reader, not told about the input', async () => {
  const reply = await callFunction('saveIssue', { title: '' }, reader.idToken);
  refused(reply, 'PERMISSION_DENIED');
  assert.equal(reply.raw.includes('fields'), false);
});

// ---- OP-16 saveIssue ----

test('G8 saveIssue: a create writes a fixed list of fields, unpublished, with no admin identity (INV-12)', async () => {
  const reply = await call('saveIssue', { request_id: 'r1', ...ISSUE_INPUT, edition: 'E1', year: 2027 });
  assert.equal(reply.status, 200, reply.raw);
  const { issue_id: id, publication_state: state } = reply.result;
  assert.equal(state, 'unpublished');

  const stored = (await db.doc(`issues/${id}`).get()).data();
  assert.deepEqual(Object.keys(stored).sort(), [
    'category_id', 'created_at', 'description', 'edition', 'issue_id', 'publication_date',
    'publication_state', 'segment_ids', 'title', 'updated_at', 'year',
  ]);
  assert.equal(stored.year, 2027);
  assert.equal(JSON.stringify(stored).includes(admin.uid), false);
  assert.equal(id.includes(admin.uid), false, 'the identifier is opaque');
});

test('G8 saveIssue: a repeated create finds the same record, and a new request makes a new one', async () => {
  const first = await call('saveIssue', { request_id: 'r1', ...ISSUE_INPUT });
  const repeat = await call('saveIssue', { request_id: 'r1', ...ISSUE_INPUT });
  assert.equal(repeat.result.issue_id, first.result.issue_id);
  assert.equal(repeat.result.updated_at, first.result.updated_at);
  const other = await call('saveIssue', { request_id: 'r2', ...ISSUE_INPUT });
  assert.notEqual(other.result.issue_id, first.result.issue_id);
});

test('G8 saveIssue: an identifier on the deleted-issue list is not reused (INV-14)', async () => {
  await db.doc(`deleted_issues/${derivedId('issue', admin.uid, 'r-old')}`).set({ deleted_at: NOW });
  const before = await dump();
  refused(await call('saveIssue', { request_id: 'r-old', ...ISSUE_INPUT }), 'NOT_FOUND', 'GONE');
  assert.equal(await dump(), before);
});

test('G8 saveIssue: an edit changes the details and nothing about publication or the file', async () => {
  await seedIssue('i-edit', { current_revision: 3, file_size_bytes: 10, page_count: 4, publication_state: 'published', cover_path: 'covers/i-edit/v1' });
  const reply = await call('saveIssue', { request_id: 'r1', issue_id: 'i-edit', expected_updated_at: NOW.getTime(), ...ISSUE_INPUT, title: 'New title' });
  assert.equal(reply.status, 200, reply.raw);
  assert.equal(reply.result.title, 'New title');
  assert.ok(reply.result.updated_at > NOW.getTime());
  const stored = (await db.doc('issues/i-edit').get()).data();
  assert.equal(stored.publication_state, 'published');
  assert.equal(stored.current_revision, 3);
  assert.equal(stored.file_size_bytes, 10);
  assert.equal(stored.page_count, 4);
  assert.equal(stored.cover_path, 'covers/i-edit/v1');
  assert.equal(stored.created_at.toMillis(), NOW.getTime());
});

test('G8 saveIssue: an edit that leaves out the edition removes it', async () => {
  await seedIssue('i-edit', { edition: 'Old' });
  await call('saveIssue', { request_id: 'r1', issue_id: 'i-edit', expected_updated_at: NOW.getTime(), ...ISSUE_INPUT });
  assert.equal('edition' in (await db.doc('issues/i-edit').get()).data(), false);
});

test('G8 saveIssue: a stale screen is refused, and nothing changes (STALE_RECORD)', async () => {
  await seedIssue('i-edit');
  const before = await dump();
  const reply = await call('saveIssue', { request_id: 'r1', issue_id: 'i-edit', expected_updated_at: NOW.getTime() - 1, ...ISSUE_INPUT, title: 'Stale' });
  refused(reply, 'ABORTED', 'STALE_RECORD');
  assert.equal(await dump(), before);
});

test('G8 saveIssue: a retried edit whose first attempt landed succeeds and changes nothing', async () => {
  await seedIssue('i-edit');
  const data = { request_id: 'r1', issue_id: 'i-edit', expected_updated_at: NOW.getTime(), ...ISSUE_INPUT, title: 'New title' };
  const first = await call('saveIssue', data);
  const repeat = await call('saveIssue', data);
  assert.equal(repeat.status, 200, repeat.raw);
  assert.equal(repeat.result.updated_at, first.result.updated_at);
});

test('G8 saveIssue: editing an issue that does not exist is refused', async () => {
  const before = await dump();
  refused(await call('saveIssue', { request_id: 'r1', issue_id: 'nope', expected_updated_at: 1, ...ISSUE_INPUT }), 'NOT_FOUND');
  assert.equal(await dump(), before);
});

for (const [label, change, field] of [
  ['a category that does not exist', { category_id: 'nope' }, 'category_id'],
  ['a segment that does not exist', { segment_ids: ['s1', 'nope'] }, 'segment_ids'],
]) {
  test(`G8 saveIssue: ${label} is refused by name, and nothing is written (INV-13)`, async () => {
    const before = await dump();
    invalid(await call('saveIssue', { request_id: 'r1', ...ISSUE_INPUT, ...change }), [field]);
    assert.equal(await dump(), before);
  });
}

for (const name of ['publication_state', 'current_revision', 'file_size_bytes', 'page_count', 'cover_path']) {
  test(`G8 saveIssue: cannot set ${name}, even on an edit`, async () => {
    await seedIssue('i-edit');
    const before = await dump();
    invalid(await call('saveIssue', { request_id: 'r1', issue_id: 'i-edit', expected_updated_at: NOW.getTime(), ...ISSUE_INPUT, [name]: 'published' }), [name]);
    assert.equal(await dump(), before);
  });
}

// ---- OP-21 and OP-22, with the rules: what a visitor can read follows the state (AC-8.7) ----

test('G8 publish and unpublish: a visitor can read the issue only while it is published', async () => {
  const visitor = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(visitor, 'issues/i-ready')));

  const published = await call('publishIssue', { request_id: 'r1', issue_id: 'i-ready' });
  assert.equal(published.result.publication_state, 'published');
  assert.ok(published.result.published_at);
  await assertSucceeds(getDoc(doc(visitor, 'issues/i-ready')));

  const unpublished = await call('unpublishIssue', { request_id: 'r2', issue_id: 'i-ready' });
  assert.equal(unpublished.result.publication_state, 'unpublished');
  await assertFails(getDoc(doc(visitor, 'issues/i-ready')));
});

test('G8 publish: no revision on the issue is refused, and nothing changes (INV-02)', async () => {
  await seedIssue('i-none');
  const before = await dump();
  refused(await call('publishIssue', { request_id: 'r1', issue_id: 'i-none' }), 'FAILED_PRECONDITION', 'NO_ACCEPTED_FILE');
  assert.equal(await dump(), before);
});

test('G8 publish: a revision with no file record is refused (INV-02)', async () => {
  await seedIssue('i-none', { current_revision: 2 });
  refused(await call('publishIssue', { request_id: 'r1', issue_id: 'i-none' }), 'FAILED_PRECONDITION', 'NO_ACCEPTED_FILE');
});

for (const status of ['superseded', 'removed']) {
  test(`G8 publish: a file with the status ${status} is refused (INV-02)`, async () => {
    await seedIssue('i-old', { current_revision: 1 });
    await seedAcceptedFile('i-old', 1, status);
    refused(await call('publishIssue', { request_id: 'r1', issue_id: 'i-old' }), 'FAILED_PRECONDITION', 'NO_ACCEPTED_FILE');
    assert.equal((await db.doc('issues/i-old').get()).get('publication_state'), 'unpublished');
  });
}

test('G8 publish: an issue with no description is refused by name', async () => {
  await seedIssue('i-bare', { current_revision: 1, description: '' });
  await seedAcceptedFile('i-bare');
  invalid(await call('publishIssue', { request_id: 'r1', issue_id: 'i-bare' }), ['description']);
});

for (const [name, id] of [['publishIssue', 'i-live'], ['unpublishIssue', 'i-ready']]) {
  test(`G8 ${name}: a repeat of the same state succeeds and changes nothing`, async () => {
    const before = await dump();
    const reply = await call(name, { request_id: 'r1', issue_id: id });
    assert.equal(reply.status, 200, reply.raw);
    assert.equal(await dump(), before);
  });

  test(`G8 ${name}: an issue that does not exist is refused`, async () => {
    refused(await call(name, { request_id: 'r1', issue_id: 'nope' }), 'NOT_FOUND');
  });

  test(`G8 ${name}: a missing request_id or issue_id is refused by name`, async () => {
    invalid(await call(name, {}), ['request_id', 'issue_id']);
  });
}

test('G8 publish: the reply holds no file location (SC-07)', async () => {
  const reply = await call('publishIssue', { request_id: 'r1', issue_id: 'i-ready' });
  assert.equal(reply.raw.includes('storage_path'), false);
  assert.equal(reply.raw.includes('.pdf'), false);
});

// ---- OP-15 listIssuesForAdmin ----

test('G8 list: includes unpublished issues, and the filter narrows them', async () => {
  const all = await call('listIssuesForAdmin', {});
  assert.deepEqual(all.result.items.map((i) => i.issue_id).sort(), ['i-live', 'i-ready']);
  const live = await call('listIssuesForAdmin', { publication_state: 'published' });
  assert.deepEqual(live.result.items.map((i) => i.issue_id), ['i-live']);
  const draft = await call('listIssuesForAdmin', { publication_state: 'unpublished' });
  assert.deepEqual(draft.result.items.map((i) => i.issue_id), ['i-ready']);
  assert.equal(all.raw.includes('storage_path'), false);
});

test('G8 list: pages with a cursor, with no repeat and no gap, newest date first', async () => {
  await seedIssue('i-a', { publication_date: '2026-01-01' });
  await seedIssue('i-b', { publication_date: '2026-12-01' });
  await seedIssue('i-c', { publication_date: '2026-06-01' });

  const seen = [];
  let cursor;
  let pages = 0;
  do {
    const reply = await call('listIssuesForAdmin', { page_size: 2, ...(cursor ? { cursor } : {}) });
    assert.equal(reply.status, 200, reply.raw);
    assert.ok(reply.result.items.length <= 2);
    seen.push(...reply.result.items.map((i) => i.issue_id));
    cursor = reply.result.next_cursor;
    pages += 1;
  } while (cursor && pages < 10);

  assert.equal(seen.length, 5);
  assert.equal(new Set(seen).size, 5);
  assert.equal(seen[0], 'i-b');
  assert.equal(seen[seen.length - 1], 'i-a');
  assert.equal(pages, 3);
});

test('G8 list: a last page that is exactly full has no next cursor', async () => {
  const reply = await call('listIssuesForAdmin', { page_size: 2 });
  assert.equal(reply.result.items.length, 2);
  assert.equal(reply.result.next_cursor, null);
});

for (const [label, data, field] of [
  ['a page size of 0', { page_size: 0 }, 'page_size'],
  ['a page size over the placeholder limit', { page_size: 101 }, 'page_size'],
  ['a page size as text', { page_size: '2' }, 'page_size'],
  ['an unknown state', { publication_state: 'draft' }, 'publication_state'],
  ['a cursor for a record that does not exist', { cursor: 'nope' }, 'cursor'],
]) {
  test(`G8 list: ${label} is refused by name`, async () => {
    invalid(await call('listIssuesForAdmin', data), [field]);
  });
}

// ---- OP-17 saveCategory and OP-18 deleteCategory (AC-8.6) ----

test('G8 saveCategory: a create writes a fixed list of fields, and a visitor can read it (INV-12)', async () => {
  const reply = await call('saveCategory', { request_id: 'r1', name: '  New category  ', display_order: 5 });
  assert.equal(reply.status, 200, reply.raw);
  const id = reply.result.category_id;
  const stored = (await db.doc(`categories/${id}`).get()).data();
  assert.deepEqual(stored, { category_id: id, name: 'New category', display_order: 5 });
  await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), `categories/${id}`)));
});

test('G8 saveCategory: a repeated create finds the same record', async () => {
  const first = await call('saveCategory', { request_id: 'r1', name: 'New category', display_order: 5 });
  const repeat = await call('saveCategory', { request_id: 'r1', name: 'New category', display_order: 5 });
  assert.equal(repeat.status, 200, repeat.raw);
  assert.equal(repeat.result.category_id, first.result.category_id);
  assert.equal((await db.collection('categories').where('name', '==', 'New category').get()).size, 1);
});

test('G8 saveCategory: a rename reaches the record', async () => {
  const reply = await call('saveCategory', { request_id: 'r1', category_id: 'c1', name: 'Renamed', display_order: 9 });
  assert.equal(reply.status, 200, reply.raw);
  const stored = (await db.doc('categories/c1').get()).data();
  assert.deepEqual([stored.name, stored.display_order], ['Renamed', 9]);
});

for (const [label, data] of [
  ['a new category', { request_id: 'r1', name: 'CATEGORY ONE', display_order: 5 }],
  ['a rename', { request_id: 'r1', category_id: 'c-unused', name: ' category one ', display_order: 5 }],
]) {
  test(`G8 saveCategory: ${label} with a name already used, ignoring case, is refused, and nothing changes`, async () => {
    const before = await dump();
    refused(await call('saveCategory', data), 'ABORTED', 'NAME_TAKEN');
    assert.equal(await dump(), before);
  });
}

test('G8 saveCategory: renaming a category to its own name in another case is allowed', async () => {
  const reply = await call('saveCategory', { request_id: 'r1', category_id: 'c1', name: 'CATEGORY ONE', display_order: 1 });
  assert.equal(reply.status, 200, reply.raw);
});

test('G8 saveCategory: editing a category that does not exist is refused', async () => {
  refused(await call('saveCategory', { request_id: 'r1', category_id: 'nope', name: 'X', display_order: 1 }), 'NOT_FOUND');
});

for (const [label, data, fields] of [
  ['no request_id', { name: 'X', display_order: 1 }, ['request_id']],
  ['an empty name', { request_id: 'r1', name: '  ', display_order: 1 }, ['name']],
  ['no display order', { request_id: 'r1', name: 'X' }, ['display_order']],
  ['a display order as text', { request_id: 'r1', name: 'X', display_order: '1' }, ['display_order']],
  ['an unknown field', { request_id: 'r1', name: 'X', display_order: 1, granted_by: 'x' }, ['granted_by']],
]) {
  test(`G8 saveCategory: ${label} is refused by name, and nothing is written`, async () => {
    const before = await dump();
    invalid(await call('saveCategory', data), fields);
    assert.equal(await dump(), before);
  });
}

test('G8 deleteCategory: a category nobody uses is deleted, and a repeat is harmless', async () => {
  const first = await call('deleteCategory', { request_id: 'r1', category_id: 'c-unused' });
  assert.equal(first.status, 200, first.raw);
  assert.equal((await db.doc('categories/c-unused').get()).exists, false);
  const repeat = await call('deleteCategory', { request_id: 'r1', category_id: 'c-unused' });
  assert.equal(repeat.status, 200, repeat.raw);
});

test('G8 deleteCategory: a category in use is refused, and nothing changes', async () => {
  const before = await dump();
  refused(await call('deleteCategory', { request_id: 'r1', category_id: 'c1' }), 'FAILED_PRECONDITION', 'IN_USE');
  assert.equal(await dump(), before);
});

test('G8 deleteCategory: a missing category_id is refused by name', async () => {
  invalid(await call('deleteCategory', { request_id: 'r1' }), ['category_id']);
});

// ---- OP-23 setNewsControl (AC-8.8) ----

test('G8 setNewsControl: a record holds a fixed list of fields, and a visitor can read it (INV-12)', async () => {
  const reply = await call('setNewsControl', { request_id: 'r1', wp_post_id: 55, is_hidden: true, is_breaking: true });
  assert.deepEqual(reply.result, { wp_post_id: 55, is_hidden: true, is_breaking: true });
  const stored = (await db.doc('news_controls/55').get()).data();
  assert.deepEqual(Object.keys(stored).sort(), ['is_breaking', 'is_hidden', 'updated_at', 'wp_post_id']);
  await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), 'news_controls/55')));
});

test('G8 setNewsControl: a second call replaces the record, and neither flag set removes it', async () => {
  await call('setNewsControl', { request_id: 'r1', wp_post_id: 55, is_hidden: true, is_breaking: false });
  await call('setNewsControl', { request_id: 'r2', wp_post_id: 55, is_hidden: false, is_breaking: true });
  const stored = (await db.doc('news_controls/55').get()).data();
  assert.deepEqual([stored.is_hidden, stored.is_breaking], [false, true]);

  const cleared = await call('setNewsControl', { request_id: 'r3', wp_post_id: 55, is_hidden: false, is_breaking: false });
  assert.equal(cleared.status, 200, cleared.raw);
  assert.equal((await db.doc('news_controls/55').get()).exists, false);
});

for (const [label, data, fields] of [
  ['a post number of 0', { request_id: 'r1', wp_post_id: 0, is_hidden: true, is_breaking: false }, ['wp_post_id']],
  ['a negative post number', { request_id: 'r1', wp_post_id: -1, is_hidden: true, is_breaking: false }, ['wp_post_id']],
  ['a fractional post number', { request_id: 'r1', wp_post_id: 1.5, is_hidden: true, is_breaking: false }, ['wp_post_id']],
  ['a post number as text', { request_id: 'r1', wp_post_id: '55', is_hidden: true, is_breaking: false }, ['wp_post_id']],
  ['a flag that is not true or false', { request_id: 'r1', wp_post_id: 55, is_hidden: 'yes', is_breaking: false }, ['is_hidden']],
  ['a missing flag', { request_id: 'r1', wp_post_id: 55, is_hidden: true }, ['is_breaking']],
  ['no request_id', { wp_post_id: 55, is_hidden: true, is_breaking: false }, ['request_id']],
  ['an admin identity', { request_id: 'r1', wp_post_id: 55, is_hidden: true, is_breaking: false, updated_by: 'x' }, ['updated_by']],
]) {
  test(`G8 setNewsControl: ${label} is refused by name, and nothing is written`, async () => {
    const before = await dump();
    invalid(await call('setNewsControl', data), fields);
    assert.equal(await dump(), before);
  });
}

// ---- At the same moment. EMULATOR ONLY: not a pass for concurrency. ----

test('G8 at the same moment: two new categories with the same name, repeated. One wins', async () => {
  for (let round = 0; round < 5; round += 1) {
    const name = `Same name ${round}`;
    const replies = await Promise.all([
      call('saveCategory', { request_id: `a-${round}`, name, display_order: 1 }),
      call('saveCategory', { request_id: `b-${round}`, name, display_order: 1 }, otherAdmin.idToken),
    ]);
    const won = replies.filter((r) => r.status === 200).length;
    assert.equal(won, 1, `round ${round}: ${replies.map((r) => r.raw).join(' | ')}`);
    assert.equal((await db.collection('categories').where('name', '==', name).get()).size, 1, `round ${round}`);
  }
});

// ---- An identifier is one key. A slash would reach a record in another collection ----

for (const [label, name, data, fields] of [
  ['unpublishIssue on a file record', 'unpublishIssue', { request_id: 'r1', issue_id: 'i-live/files/1' }, ['issue_id']],
  ['publishIssue on a file record', 'publishIssue', { request_id: 'r1', issue_id: 'i-ready/files/1' }, ['issue_id']],
  ['saveIssue on a file record', 'saveIssue', { request_id: 'r1', issue_id: 'i-live/files/1', expected_updated_at: 1, ...ISSUE_INPUT }, ['issue_id']],
  ['saveIssue with a category path', 'saveIssue', { request_id: 'r1', ...ISSUE_INPUT, category_id: 'c1/x/y' }, ['category_id']],
  ['saveIssue with a two-part category path', 'saveIssue', { request_id: 'r1', ...ISSUE_INPUT, category_id: 'c1/x' }, ['category_id']],
  ['saveIssue with a segment path', 'saveIssue', { request_id: 'r1', ...ISSUE_INPUT, segment_ids: ['s1/x'] }, ['segment_ids']],
  ['saveCategory on a path', 'saveCategory', { request_id: 'r1', category_id: 'c1/x/y', name: 'A name', display_order: 1 }, ['category_id']],
  ['deleteCategory on a path', 'deleteCategory', { request_id: 'r1', category_id: 'c1/x' }, ['category_id']],
  ['listIssuesForAdmin with a cursor path', 'listIssuesForAdmin', { cursor: 'i-live/files/1' }, ['cursor']],
]) {
  test(`G8 one key: ${label} is refused by name, and nothing changes`, async () => {
    const before = await dump();
    invalid(await call(name, data), fields);
    assert.equal(await dump(), before);
  });
}
