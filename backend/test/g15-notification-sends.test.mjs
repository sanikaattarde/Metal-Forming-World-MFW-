// Group G15: OP-25 sendNotification, OP-26 retryNotification and OP-27 listNotificationSends through the
// emulators (FR-ADMIN-015 to FR-ADMIN-018, DATA-008, INV-17, GS-Q27, AC-9.4, AC-9.5). The emulators have no
// messaging service, so the stand-in push sender takes the message (pushSender.ts). No real device is reached,
// and the send record's fields wait for OQ-19. Emulator only.
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { markStaleSends, PLACEHOLDER_PENDING_WINDOW_MS } from '../functions/dist/notifications.js';
import { EMULATOR_CONTROL, EMULATOR_OUTBOX } from '../functions/dist/pushSender.js';
import { derivedId } from '../functions/dist/validation.js';
import { adminBackend, callFunction, clearAuthAccounts, newTestEnv, SEED_CATEGORIES, signUp, verifyEmail } from './helpers.mjs';
import { makePosts, startWordPress } from './wp-standin.mjs';

const NOW = new Date('2026-11-11T10:00:00Z');
const CATEGORY = SEED_CATEGORIES[0];
const RECORD_FIELDS = [
  'attempt_count', 'body', 'category_id', 'last_attempt_at', 'outcome', 'send_id', 'sent_at', 'sent_by', 'settled_at',
  'target_ref', 'target_type', 'title',
];
const VIEW_FIELDS = [
  'attempt_count', 'body', 'category_id', 'last_attempt_at', 'outcome', 'send_id', 'sent_at', 'sent_by', 'target_ref',
  'target_type', 'title',
];

let env;
let db;
let wp;
let admin;
let reader;
let requestCounter = 0;

before(async () => {
  env = await newTestEnv();
  db = adminBackend().db;
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
  reader = await signUp('reader@example.test');
  await verifyEmail(admin.uid);
  await verifyEmail(reader.uid);
  await db.doc(`admin_roles/${admin.uid}`).set({ user_id: admin.uid, is_active: true, granted_by: 'test-seed', granted_at: NOW });
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 1, version: 1, updated_at: NOW });
  await db.doc('config/private').set({ wordpress_base_url: wp.url });
  for (const [index, id] of SEED_CATEGORIES.entries()) {
    await db.doc(`notification_categories/${id}`).set({ category_id: id, name: `Category ${index}`, display_order: index, is_active: true });
  }
  await db.doc('notification_categories/inactive').set({ category_id: 'inactive', name: 'Old', display_order: 9, is_active: false });
  await db.doc('issues/i-pub').set({ title: 'Published', publication_state: 'published' });
  await db.doc('issues/i-unpub').set({ title: 'Unpublished', publication_state: 'unpublished' });
});

const nextRequest = () => `request-${(requestCounter += 1)}`;

const send = (over = {}, token = admin.idToken) =>
  callFunction('sendNotification', { request_id: nextRequest(), category_id: CATEGORY, title: 'A new issue', body: 'Read the November issue.', target_type: 'none', ...over }, token);

const retry = (sendId, over = {}, token = admin.idToken) => callFunction('retryNotification', { request_id: nextRequest(), send_id: sendId, ...over }, token);

const list = (data = {}, token = admin.idToken) => callFunction('listNotificationSends', data, token);

const outbox = async () => (await db.collection(EMULATOR_OUTBOX).get()).docs.map((d) => d.data());
const records = async () => (await db.collection('notification_sends').get()).docs;
const failPush = (on = true) => db.doc(EMULATOR_CONTROL).set({ outcome: on ? 'fail' : 'accept' });

const assertRefused = (reply, status, reason) => {
  assert.equal(reply.error?.status, status, reply.raw);
  if (reason) assert.equal(reply.error.details?.reason, reason, reply.raw);
};

const seedSend = (id, over = {}) =>
  db.doc(`notification_sends/${id}`).set({
    send_id: id,
    category_id: CATEGORY,
    title: `Send ${id}`,
    body: 'Body',
    target_type: 'none',
    target_ref: null,
    sent_by: admin.uid,
    sent_at: new Date(Date.now() - 60_000),
    outcome: 'accepted',
    attempt_count: 1,
    last_attempt_at: new Date(Date.now() - 60_000),
    ...over,
  });

// ---- OP-25: the allowed path ----

test('G15 OP-25: an admin sends to the category topic; the record is written first, then accepted', async () => {
  const requestId = nextRequest();
  const reply = await send({ request_id: requestId });
  assert.equal(reply.status, 200, reply.raw);
  const sendId = derivedId('send', admin.uid, requestId);
  assert.deepEqual(reply.result, { send_id: sendId, outcome: 'accepted' });

  const [record] = await records();
  assert.deepEqual(Object.keys(record.data()).sort(), RECORD_FIELDS);
  assert.equal(record.id, sendId);
  assert.equal(record.get('sent_by'), admin.uid);
  assert.equal(record.get('attempt_count'), 1);
  assert.equal(record.get('target_ref'), null);

  assert.deepEqual(
    (await outbox()).map(({ received_at, ...message }) => message),
    [{ topic: CATEGORY, title: 'A new issue', body: 'Read the November issue.', data: { send_id: sendId, target_type: 'none' } }],
  );
});

test('G15 OP-25: a repeat of the same request returns the same send and sends nothing again', async () => {
  const first = await send({ request_id: 'same-request' });
  const again = await send({ request_id: 'same-request', title: 'Something else' });
  assert.deepEqual(again.result, first.result);
  assert.equal((await records()).length, 1);
  assert.equal((await outbox()).length, 1);
});

test('G15 OP-25: a published issue and an existing post are linked targets (FR-ADMIN-015)', async () => {
  assert.equal((await send({ target_type: 'issue', target_ref: 'i-pub' })).status, 200);
  const post = await send({ target_type: 'news_post', target_ref: '101' });
  assert.equal(post.status, 200, post.raw);
  const data = (await outbox()).map((message) => message.data);
  assert.deepEqual(data.map(({ target_type, target_ref }) => [target_type, target_ref]).sort(), [['issue', 'i-pub'], ['news_post', '101']]);
  assert.equal(wp.state.requests.at(-1).path, '/wp-json/wp/v2/posts/101');
  assert.deepEqual(wp.state.requests.at(-1).query, { _fields: 'id' });
});

// ---- OP-25: refusals write nothing ----

for (const [name, over, fields] of [
  ['no title', { title: ' ' }, ['title']],
  ['a title over the limit', { title: 'x'.repeat(101) }, ['title']],
  ['a body over the limit', { body: 'x'.repeat(401) }, ['body']],
  ['an unknown target type', { target_type: 'page' }, ['target_type']],
  ['a reference with no target', { target_ref: 'i-pub' }, ['target_ref']],
  ['an issue reference that is a path', { target_type: 'issue', target_ref: 'a/b' }, ['target_ref']],
  ['a post reference that is not a number', { target_type: 'news_post', target_ref: '12a' }, ['target_ref']],
  ['an unknown field', { audience: 'all' }, ['audience']],
  ['a missing category', { category_id: 'no-such-category' }, ['category_id']],
  ['an inactive category', { category_id: 'inactive' }, ['category_id']],
]) {
  test(`G15 OP-25: ${name} is INVALID_ARGUMENT, and nothing is written or sent`, async () => {
    const reply = await send(over);
    assertRefused(reply, 'INVALID_ARGUMENT');
    assert.deepEqual(reply.error.details.fields, fields);
    assert.equal((await records()).length, 0);
    assert.equal((await outbox()).length, 0);
  });
}

for (const [name, over] of [
  ['an unpublished issue', { target_type: 'issue', target_ref: 'i-unpub' }],
  ['a missing issue', { target_type: 'issue', target_ref: 'i-none' }],
  ['a missing post', { target_type: 'news_post', target_ref: '999' }],
]) {
  test(`G15 OP-25: ${name} is TARGET_NOT_AVAILABLE, and nothing is written`, async () => {
    assertRefused(await send(over), 'FAILED_PRECONDITION', 'TARGET_NOT_AVAILABLE');
    assert.equal((await records()).length, 0);
  });
}

test('G15 OP-25: a post hidden in the app is TARGET_NOT_AVAILABLE, without asking the site', async () => {
  await db.doc('news_controls/101').set({ wp_post_id: 101, is_hidden: true, is_breaking: false });
  assertRefused(await send({ target_type: 'news_post', target_ref: '101' }), 'FAILED_PRECONDITION', 'TARGET_NOT_AVAILABLE');
  assert.equal(wp.state.requests.length, 0);
});

test('G15 OP-25: a site that cannot be read is UNAVAILABLE, and nothing is written', async () => {
  wp.set('status500');
  assertRefused(await send({ target_type: 'news_post', target_ref: '101' }), 'UNAVAILABLE', 'SITE_UNAVAILABLE');
  wp.set('redirect');
  assertRefused(await send({ target_type: 'news_post', target_ref: '101' }), 'UNAVAILABLE', 'SITE_UNAVAILABLE');
  assert.equal((await records()).length, 0);
});

test('G15 OP-25: a reader is refused and a visitor must sign in; nothing is written (INV-08)', async () => {
  assertRefused(await send({}, reader.idToken), 'PERMISSION_DENIED');
  assertRefused(await send({}, null), 'UNAUTHENTICATED');
  assert.equal((await records()).length, 0);
  assert.equal((await outbox()).length, 0);
});

test('G15 OP-25: a push failure is UNAVAILABLE with the send identifier, and the record is failed', async () => {
  await failPush();
  const requestId = nextRequest();
  const reply = await send({ request_id: requestId });
  assertRefused(reply, 'UNAVAILABLE', 'PUSH_FAILED');
  const sendId = derivedId('send', admin.uid, requestId);
  assert.equal(reply.error.details.send_id, sendId);
  assert.equal((await db.doc(`notification_sends/${sendId}`).get()).get('outcome'), 'failed');
  // A repeat reports the failure; it does not send again.
  assert.deepEqual((await send({ request_id: requestId })).result, { send_id: sendId, outcome: 'failed' });
});

// ---- OP-26: retry by an admin only, never on its own (INV-17) ----

test('G15 OP-26: a failed send is retried once, adds one to the attempt count and is accepted', async () => {
  await failPush();
  const failed = await send();
  const sendId = failed.error.details.send_id;
  assert.equal((await outbox()).length, 0);

  await failPush(false);
  const requestId = nextRequest();
  const reply = await retry(sendId, { request_id: requestId });
  assert.deepEqual(reply.result, { send_id: sendId, outcome: 'accepted' });
  const record = await db.doc(`notification_sends/${sendId}`).get();
  assert.equal(record.get('attempt_count'), 2);
  assert.equal(record.get('outcome'), 'accepted');

  // The same retry again changes nothing and sends nothing.
  assert.deepEqual((await retry(sendId, { request_id: requestId })).result, reply.result);
  assert.equal((await outbox()).length, 1);
  assert.equal((await db.doc(`notification_sends/${sendId}`).get()).get('attempt_count'), 2);
});

test('G15 OP-26: a retry that fails again stays failed and reports PUSH_FAILED', async () => {
  await failPush();
  const sendId = (await send()).error.details.send_id;
  assertRefused(await retry(sendId), 'UNAVAILABLE', 'PUSH_FAILED');
  const record = await db.doc(`notification_sends/${sendId}`).get();
  assert.equal(record.get('outcome'), 'failed');
  assert.equal(record.get('attempt_count'), 2);
});

test('G15 OP-26: an accepted send is NOT_RETRYABLE, and a missing one is NOT_FOUND', async () => {
  const sendId = (await send()).result.send_id;
  assertRefused(await retry(sendId), 'FAILED_PRECONDITION', 'NOT_RETRYABLE');
  assertRefused(await retry('no-such-send'), 'NOT_FOUND');
  assertRefused(await retry('a/b'), 'INVALID_ARGUMENT');
});

test('G15 OP-26: a pending attempt inside the window is a conflict; one past the window is unknown and retried', async () => {
  await seedSend('fresh', { outcome: 'pending', last_attempt_at: new Date() });
  assertRefused(await retry('fresh'), 'ABORTED', 'ATTEMPT_IN_PROGRESS');

  await seedSend('stale', { outcome: 'pending', last_attempt_at: new Date(Date.now() - PLACEHOLDER_PENDING_WINDOW_MS - 60_000) });
  assert.deepEqual((await retry('stale')).result, { send_id: 'stale', outcome: 'accepted' });
});

test('G15 OP-26: a retry whose issue was unpublished since is TARGET_NOT_AVAILABLE', async () => {
  await seedSend('linked', { outcome: 'failed', target_type: 'issue', target_ref: 'i-unpub' });
  assertRefused(await retry('linked'), 'FAILED_PRECONDITION', 'TARGET_NOT_AVAILABLE');
  assert.equal((await db.doc('notification_sends/linked').get()).get('attempt_count'), 1);
});

test('G15 OP-26: a reader cannot retry', async () => {
  await seedSend('failed-one', { outcome: 'failed' });
  assertRefused(await retry('failed-one', {}, reader.idToken), 'PERMISSION_DENIED');
  assert.equal((await db.doc('notification_sends/failed-one').get()).get('attempt_count'), 1);
});

// ---- OP-27: the send log ----

test('G15 OP-27: the log is newest first, paged by a cursor, with the view fields only', async () => {
  for (const [index, id] of ['s1', 's2', 's3'].entries()) {
    await seedSend(id, { sent_at: new Date(NOW.getTime() + index * 1000), last_attempt_at: new Date(NOW.getTime() + index * 1000) });
  }
  const first = await list({ page_size: 2 });
  assert.equal(first.status, 200, first.raw);
  assert.deepEqual(first.result.items.map((item) => item.send_id), ['s3', 's2']);
  assert.deepEqual(Object.keys(first.result.items[0]).sort(), VIEW_FIELDS);
  assert.equal(first.result.next_cursor, 's2');

  const second = await list({ page_size: 2, cursor: 's2' });
  assert.deepEqual(second.result.items.map((item) => item.send_id), ['s1']);
  assert.equal(second.result.next_cursor, null);
});

test('G15 OP-27: the outcome filter, with a pending record past the window shown as unknown', async () => {
  const old = new Date(Date.now() - PLACEHOLDER_PENDING_WINDOW_MS - 60_000);
  await seedSend('accepted');
  await seedSend('failed', { outcome: 'failed' });
  await seedSend('fresh', { outcome: 'pending', last_attempt_at: new Date() });
  await seedSend('stale', { outcome: 'pending', sent_at: old, last_attempt_at: old });

  const ids = async (outcome) => (await list({ outcome })).result.items.map((item) => item.send_id);
  assert.deepEqual(await ids('failed'), ['failed']);
  assert.deepEqual(await ids('pending'), ['fresh']);
  assert.deepEqual(await ids('unknown'), ['stale']);
  const all = (await list()).result.items;
  assert.equal(all.find((item) => item.send_id === 'stale').outcome, 'unknown');
});

for (const [name, data, fields] of [
  ['an unknown outcome', { outcome: 'sent' }, ['outcome']],
  ['a page size of 0', { page_size: 0 }, ['page_size']],
  ['a missing cursor', { cursor: 'no-such-send' }, ['cursor']],
  ['an unknown field', { sent_by: 'x' }, ['sent_by']],
]) {
  test(`G15 OP-27: ${name} is INVALID_ARGUMENT`, async () => {
    const reply = await list(data);
    assertRefused(reply, 'INVALID_ARGUMENT');
    assert.deepEqual(reply.error.details.fields, fields);
  });
}

test('G15 OP-27: a reader cannot read the log', async () => {
  await seedSend('s1');
  assertRefused(await list({}, reader.idToken), 'PERMISSION_DENIED');
});

// ---- OP-41: the stale-send task ----

test('G15 OP-41: the maintenance task marks pending sends past the window as unknown, and only those', async () => {
  const old = new Date(Date.now() - PLACEHOLDER_PENDING_WINDOW_MS - 60_000);
  await seedSend('stale', { outcome: 'pending', last_attempt_at: old });
  await seedSend('fresh', { outcome: 'pending', last_attempt_at: new Date() });
  await seedSend('failed', { outcome: 'failed', last_attempt_at: old });
  assert.equal(await markStaleSends(db), 1);
  const outcomes = Object.fromEntries((await records()).map((snap) => [snap.id, snap.get('outcome')]));
  assert.deepEqual(outcomes, { failed: 'failed', fresh: 'pending', stale: 'unknown' });
});
