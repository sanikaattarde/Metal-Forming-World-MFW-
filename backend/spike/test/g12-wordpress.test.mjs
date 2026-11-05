// SPIKE (DEC-003 OPEN, DEC-026 PROPOSED). Group G12: OP-24 listWordPressPosts through the Functions
// emulator, against a stand-in for MFW's WordPress site (wp-standin.mjs). MFW's address is OQ-39, and no
// test reads the live site. Emulator only.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { removeAdminRole } from '../functions/dist/admin.js';
import { adminBackend, callFunction, clearAuthAccounts, forgedToken, newTestEnv, signUp, verifyEmail } from './helpers.mjs';
import { makePosts, startWordPress } from './wp-standin.mjs';

let env;
let backend;
let db;
let wp;
let admin;
let otherAdmin;
let reader;

const NOW = new Date('2026-11-05T10:00:00Z');

before(async () => {
  env = await newTestEnv();
  backend = adminBackend();
  db = backend.db;
  wp = await startWordPress();
});

after(async () => {
  await wp.close();
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  wp.reset(makePosts(3));
  admin = await signUp('admin-a@example.test');
  otherAdmin = await signUp('admin-b@example.test');
  reader = await signUp('reader@example.test');
  for (const account of [admin, otherAdmin]) {
    await verifyEmail(account.uid);
    await db.doc(`admin_roles/${account.uid}`).set({ user_id: account.uid, is_active: true, granted_by: 'test-seed', granted_at: NOW });
  }
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 2, version: 1, updated_at: NOW });
  await db.doc('config/private').set({ wordpress_base_url: wp.url });
});

const call = (data = {}, token = admin.idToken) => callFunction('listWordPressPosts', data, token);
const siteCalls = () => wp.state.requests.length;

const assertUnavailable = (reply) => {
  assert.equal(reply.error?.status, 'UNAVAILABLE', reply.raw);
  assert.equal(reply.error.details?.reason, 'SITE_UNAVAILABLE');
};

// ---- The allowed path (FR-ADMIN-013, INT-WP-001) ----

test('G12 OP-24: an admin gets a page of posts with only the contract fields, and the number of pages', async () => {
  const reply = await call();
  assert.equal(reply.status, 200, reply.raw);
  assert.deepEqual(reply.result, {
    posts: [
      { id: 100, title: 'Post 1', date: '2026-10-01T09:00:00', link: 'https://news.example.test/post-1/', categories: [7] },
      { id: 101, title: 'Post 2', date: '2026-10-02T09:00:00', link: 'https://news.example.test/post-2/', categories: [8] },
      { id: 102, title: 'Post 3', date: '2026-10-03T09:00:00', link: 'https://news.example.test/post-3/', categories: [7] },
    ],
    total_pages: 1,
    page: 1,
    per_page: 20,
  });
  assert.doesNotMatch(reply.raw, /Body that OP-24 must not ask for/);
});

test('G12 OP-24: the request asks the site for the contract fields only, and sends no credentials', async () => {
  await call();
  assert.equal(siteCalls(), 1);
  const [request] = wp.state.requests;
  assert.equal(request.method, 'GET');
  assert.deepEqual(request.query, { page: '1', per_page: '20', _fields: 'id,title,date,link,categories' });
  for (const header of ['authorization', 'cookie']) assert.equal(request.headers[header], undefined, header);
});

test('G12 OP-24: the page, the page size and the category filter reach the site', async () => {
  wp.reset(makePosts(25));
  const reply = await call({ page: 2, per_page: 5, category: 8 });
  assert.equal(reply.status, 200, reply.raw);
  assert.deepEqual(wp.state.requests[0].query, { page: '2', per_page: '5', _fields: 'id,title,date,link,categories', categories: '8' });
  assert.deepEqual(reply.result.posts.map((p) => p.id), [111, 113, 115, 117, 119]);
  assert.equal(reply.result.total_pages, 3);
});

test('G12 OP-24: a page past the last one is an empty page, not a failure', async () => {
  const reply = await call({ page: 9 });
  assert.equal(reply.status, 200, reply.raw);
  assert.deepEqual(reply.result.posts, []);
  assert.equal(reply.result.total_pages, 1);
});

test('G12 OP-24: a title arrives as plain text, with tags dropped and character references decoded', async () => {
  wp.reset([{ ...makePosts(1)[0], title: { rendered: 'Presses &amp; dies: MFW&#8217;s <em>November</em> &#x201C;special&#x201D;' } }]);
  const reply = await call();
  assert.equal(reply.result.posts[0].title, 'Presses & dies: MFW’s November “special”');
});

test('G12 OP-24: without the pages header the number of pages is null', async () => {
  wp.set('noPagesHeader');
  const reply = await call();
  assert.equal(reply.status, 200, reply.raw);
  assert.equal(reply.result.total_pages, null);
});

// ---- Refused input, and the site is not asked ----

for (const [name, data] of [
  ['page 0', { page: 0 }],
  ['a fractional page', { page: 1.5 }],
  ['a page past the PLACEHOLDER maximum', { page: 1001 }],
  ['per_page 0', { per_page: 0 }],
  ['per_page over the API maximum of 100', { per_page: 101 }],
  ['a category that is not a positive whole number', { category: 'news' }],
  ['an unknown field', { search: 'presses' }],
]) {
  test(`G12 OP-24: ${name} is refused with INVALID_ARGUMENT, and the site is not asked`, async () => {
    const reply = await call(data);
    assert.equal(reply.error?.status, 'INVALID_ARGUMENT', reply.raw);
    assert.equal(siteCalls(), 0);
  });
}

// ---- The gate: refused callers, and the site is not asked (SEC-CHK-06) ----

const CALLERS = {
  'no sign-in token': { token: async () => null, status: 'UNAUTHENTICATED' },
  'a reader': { token: async () => reader.idToken, status: 'PERMISSION_DENIED' },
  'a reader with forged admin claims': { token: async () => forgedToken(reader.uid, { admin: true, role: 'admin', is_admin: true }), status: 'PERMISSION_DENIED' },
  'a removed admin with a token from before the removal': {
    token: async () => {
      await removeAdminRole(backend, otherAdmin.uid);
      return otherAdmin.idToken;
    },
    status: 'PERMISSION_DENIED',
  },
  'an admin whose email is not verified (OQ-20)': {
    token: async () => {
      await verifyEmail(otherAdmin.uid, false);
      return otherAdmin.idToken;
    },
    status: 'FAILED_PRECONDITION',
  },
};

for (const [who, { token, status }] of Object.entries(CALLERS)) {
  test(`G12 OP-24: ${who} is refused, and the site is not asked`, async () => {
    const reply = await call({}, await token());
    assert.equal(reply.error?.status, status, reply.raw);
    assert.equal(siteCalls(), 0);
  });
}

// ---- The site failing: UNAVAILABLE, as the contract says ----

for (const [mode, what] of [
  ['status500', 'answers with a server error'],
  ['notJson', 'answers with a page that is not JSON'],
  ['notList', 'answers with something other than a list'],
  ['badItem', 'sends a post with no title'],
  ['scriptLink', 'sends a post whose link is javascript:'],
  ['redirect', 'redirects to another address'],
  ['huge', 'sends more than the PLACEHOLDER size limit'],
]) {
  test(`G12 OP-24: a site that ${what} gives UNAVAILABLE, with no part of the reply passed on`, async () => {
    wp.set(mode);
    const reply = await call();
    assertUnavailable(reply);
    assert.doesNotMatch(reply.raw, /javascript:|maintenance|elsewhere/);
  });
}

test('G12 OP-24: a site that cannot be reached gives UNAVAILABLE', async () => {
  await db.doc('config/private').set({ wordpress_base_url: 'http://127.0.0.1:9' });
  assertUnavailable(await call());
});

// ---- The address setting (CFG-03, OQ-39): missing or unusable fails closed ----

for (const [name, value] of [
  ['missing', undefined],
  ['not a web address', 'news.example.test'],
  ['plain HTTP to another host', 'http://news.example.test'],
  ['with a user name and password', 'https://user:pass@news.example.test'],
  ['with a query', 'https://news.example.test/?x=1'],
]) {
  test(`G12 OP-24: an address setting that is ${name} refuses the call (INTERNAL), and no site is asked`, async () => {
    await db.doc('config/private').set(value === undefined ? {} : { wordpress_base_url: value });
    const reply = await call();
    assert.equal(reply.error?.status, 'INTERNAL', reply.raw);
    assert.equal(siteCalls(), 0);
  });
}
