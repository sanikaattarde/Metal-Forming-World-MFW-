// Group G23: cover uploads through OP-19 requestUpload and OP-40 onUploadFinalized, and the limits read
// (MOD12-P2-T02; FR-ADMIN-008; FX-ADM-02, FX-ADM-03; OQ-22 and OQ-30 working positions of 14 November
// 2026, PROVISIONAL). Emulator only. As in G10, a test puts the file in the holding area itself, as the
// signed URL would. Generated images only (DEC-024).
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { assertSucceeds } from '@firebase/rules-unit-testing';
import { getBytes, ref } from 'firebase/storage';
import { adminBackend, adminBucket, callFunction, clearAuthAccounts, newTestEnv, signUp, TRIGGER_BUCKET, verifyEmail } from './helpers.mjs';
import { gif, hugePng, jpeg, jpegWithMetadata, metadataOf, noisyJpeg, png, svg, TEST_COVER_RULES, truncatedJpeg, webp } from './cover-fixtures.mjs';
import { makePdf } from './pdf-fixtures.mjs';

const TEST_LIMIT = 8192;
const NOW = new Date('2026-11-14T10:00:00Z');
const COVER = { request_id: 'c1', kind: 'cover', issue_id: 'i-new', declared_size_bytes: 1000, content_type: 'image/jpeg' };

let env;
let backend;
let db;
let bucket;
let admin;
let reader;

const call = (name, data, token = admin.idToken) => callFunction(name, data, token);
const request = (over = {}, token = admin.idToken) => call('requestUpload', { ...COVER, ...over }, token);
const exists = async (target, path) => (await target.file(path).exists())[0];
const covers = async (target = bucket) => (await target.getFiles({ prefix: 'covers/' }))[0].map((f) => f.name).sort();

async function waitFor(check, what, ms = 20_000) {
  const end = Date.now() + ms;
  for (;;) {
    const value = await check();
    if (value) return value;
    if (Date.now() > end) throw new Error(`timed out waiting for ${what}`);
    await new Promise((resolve) => setTimeout(resolve, 150));
  }
}

const settled = (jobId) =>
  waitFor(async () => {
    const job = await db.doc(`upload_jobs/${jobId}`).get();
    return job.exists && job.get('status') !== 'pending' ? job.data() : null;
  }, `job ${jobId} to finish`);

async function upload(bytes, over = {}) {
  const reply = await request(over);
  assert.equal(reply.error, undefined, reply.raw);
  await bucket.file(`holding/${reply.result.job_id}`).save(bytes, { contentType: over.content_type ?? COVER.content_type, resumable: false });
  return { jobId: reply.result.job_id, job: await settled(reply.result.job_id) };
}

async function dump() {
  const out = {};
  for (const name of ['issues', 'upload_jobs']) {
    for (const item of (await db.collection(name).get()).docs) out[`${name}/${item.id}`] = item.data();
  }
  const [objects] = await bucket.getFiles();
  return { records: out, objects: objects.map((o) => o.name).sort() };
}

const setConfig = (over = {}) =>
  db.doc('config/private').set({ max_upload_bytes: TEST_LIMIT, cover_rules: TEST_COVER_RULES, profile_gate_enabled: false, signed_url_lifetime: 600, ...over });

before(async () => {
  env = await newTestEnv();
  backend = adminBackend();
  db = backend.db;
  bucket = adminBucket();
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  await bucket.deleteFiles({ force: true });
  admin = await signUp('admin-a@example.test');
  reader = await signUp('reader@example.test');
  await verifyEmail(admin.uid);
  await verifyEmail(reader.uid);
  await db.doc(`admin_roles/${admin.uid}`).set({ user_id: admin.uid, is_active: true, granted_by: 'test-seed', granted_at: NOW });
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 1, version: 1, updated_at: NOW });
  await setConfig();
  await db.doc('issues/i-new').set({ issue_id: 'i-new', title: 'An issue', description: 'What it covers', category_id: 'c1', publication_state: 'unpublished' });
});

// ---- OP-19 for a cover ----

for (const type of ['image/jpeg', 'image/png']) {
  test(`G23 requestUpload: a ${type} cover gets a job and an address, and the job keeps its type`, async () => {
    const reply = await request({ content_type: type });
    assert.equal(reply.error, undefined, reply.raw);
    assert.deepEqual(reply.result.upload_headers['content-type'], type);
    const job = (await db.doc(`upload_jobs/${reply.result.job_id}`).get()).data();
    assert.equal(job.kind, 'cover');
    assert.equal(job.content_type, type);
    assert.equal(job.status, 'pending');
  });
}

test('G23 requestUpload: a repeat is signed for the type stored, whatever it asks', async () => {
  const first = await request({ content_type: 'image/png' });
  const again = await request({ content_type: 'image/jpeg' });
  assert.equal(again.result.job_id, first.result.job_id);
  assert.equal(again.result.upload_headers['content-type'], 'image/png');
});

test('G23 requestUpload: a cover of exactly the cover limit is taken', async () => {
  assert.equal((await request({ declared_size_bytes: TEST_COVER_RULES.max_bytes })).error, undefined);
});

for (const [name, over, fields] of [
  ['a GIF (FX-ADM-02)', { content_type: 'image/gif' }, ['content_type']],
  ['a WebP image (FX-ADM-02)', { content_type: 'image/webp' }, ['content_type']],
  ['an SVG drawing', { content_type: 'image/svg+xml' }, ['content_type']],
  ['a PDF sent as a cover', { content_type: 'application/pdf' }, ['content_type']],
  ['the JPEG type in capitals', { content_type: 'IMAGE/JPEG' }, ['content_type']],
  ['one byte over the cover limit (FX-ADM-03)', { declared_size_bytes: TEST_COVER_RULES.max_bytes + 1 }, ['declared_size_bytes']],
  ['a PDF job sent with a cover type', { kind: 'pdf', content_type: 'image/jpeg' }, ['content_type']],
]) {
  test(`G23 requestUpload refuses ${name}, and nothing changes`, async () => {
    const before = await dump();
    const reply = await request(over);
    assert.equal(reply.error?.status, 'INVALID_ARGUMENT', reply.raw);
    assert.deepEqual(reply.error.details.fields, fields);
    assert.deepEqual(await dump(), before);
  });
}

test('G23 requestUpload: the PDF limit does not apply to a cover, nor the cover limit to a PDF', async () => {
  assert.ok(TEST_COVER_RULES.max_bytes > TEST_LIMIT);
  assert.equal((await request({ request_id: 'c-big', declared_size_bytes: TEST_LIMIT + 1 })).error, undefined);
  const pdf = await request({ request_id: 'p-big', kind: 'pdf', content_type: 'application/pdf', declared_size_bytes: TEST_LIMIT + 1 });
  assert.equal(pdf.error?.status, 'INVALID_ARGUMENT', pdf.raw);
});

for (const [name, rules] of [
  ['missing', undefined],
  ['without a minimum width', { ...TEST_COVER_RULES, min_width_px: undefined }],
  ['with the ratios the wrong way round', { ...TEST_COVER_RULES, min_height_ratio: 1.6, max_height_ratio: 1.2 }],
  ['with a size as text', { ...TEST_COVER_RULES, max_bytes: '5' }],
]) {
  test(`G23 requestUpload fails closed: the cover rules ${name}`, async () => {
    const cleaned = rules === undefined ? undefined : Object.fromEntries(Object.entries(rules).filter(([, v]) => v !== undefined));
    if (cleaned === undefined) await db.doc('config/private').set({ max_upload_bytes: TEST_LIMIT, profile_gate_enabled: false });
    else await setConfig({ cover_rules: cleaned });
    const before = await dump();
    assert.equal((await request()).error?.status, 'INTERNAL');
    assert.deepEqual(await dump(), before);
  });
}

// ---- OP-40 for a cover: accepted ----

test('G23 a JPEG cover is accepted: stored clean at a new public address, and the issue points to it', async () => {
  const { jobId, job } = await upload(await jpegWithMetadata());
  assert.equal(job.status, 'accepted');
  assert.equal(job.revision, undefined);
  assert.ok(job.finished_at);
  const path = `covers/i-new/${jobId}`;

  const issue = (await db.doc('issues/i-new').get()).data();
  assert.equal(issue.cover_path, path);
  assert.equal(issue.current_revision, undefined, 'the PDF is not touched');
  assert.equal(issue.publication_state, 'unpublished');
  assert.equal(await exists(bucket, `holding/${jobId}`), false);
  assert.deepEqual(await covers(), [path]);

  const [metadata] = await bucket.file(path).getMetadata();
  assert.equal(metadata.contentType, 'image/jpeg');
  assert.equal(metadata.cacheControl, 'public, max-age=31536000, immutable');
  const [stored] = await bucket.file(path).download();
  const meta = await metadataOf(stored);
  assert.equal(meta.format, 'jpeg');
  assert.equal(meta.exif, undefined);
  assert.equal(stored.includes(Buffer.from('TestCamera')), false);
});

test('G23 a PNG cover is stored as a JPEG', async () => {
  const { jobId } = await upload(await png(), { content_type: 'image/png' });
  const [stored] = await bucket.file(`covers/i-new/${jobId}`).download();
  assert.equal((await metadataOf(stored)).format, 'jpeg');
});

test('G23 anyone can read an accepted cover, as the app does (GS-D7)', async () => {
  const { jobId } = await upload(await jpeg());
  const visitor = env.unauthenticatedContext().storage(`gs://${TRIGGER_BUCKET}`);
  await assertSucceeds(getBytes(ref(visitor, `covers/i-new/${jobId}`)));
});

test('G23 a replacement points the issue to the new cover and deletes the old one', async () => {
  const first = await upload(await jpeg(), { request_id: 'c-first' });
  const second = await upload(await png(), { request_id: 'c-second', content_type: 'image/png' });
  assert.equal(second.job.status, 'accepted');
  assert.equal((await db.doc('issues/i-new').get()).get('cover_path'), `covers/i-new/${second.jobId}`);
  await waitFor(async () => !(await exists(bucket, `covers/i-new/${first.jobId}`)), 'the old cover to go');
  assert.deepEqual(await covers(), [`covers/i-new/${second.jobId}`]);
});

test('G23 a cover replacement never deletes a file outside the issue\'s cover area', async () => {
  await db.doc('issues/i-new').update({ cover_path: 'issues/i-new/1.pdf' });
  await bucket.file('issues/i-new/1.pdf').save(makePdf(), { resumable: false });
  const { job } = await upload(await jpeg());
  assert.equal(job.status, 'accepted');
  assert.equal(await exists(bucket, 'issues/i-new/1.pdf'), true);
});

test('G23 with a cover and an accepted PDF, the issue can be published', async () => {
  const refused = await call('publishIssue', { request_id: 'p1', issue_id: 'i-new' });
  assert.equal(refused.error?.details?.reason, 'NO_ACCEPTED_FILE', refused.raw);

  const pdf = await upload(makePdf(), { request_id: 'pdf', kind: 'pdf', content_type: 'application/pdf' });
  assert.equal(pdf.job.status, 'accepted');
  const noCover = await call('publishIssue', { request_id: 'p2', issue_id: 'i-new' });
  assert.equal(noCover.error?.details?.reason, 'NO_COVER', noCover.raw);

  const cover = await upload(await jpeg());
  const published = await call('publishIssue', { request_id: 'p3', issue_id: 'i-new' });
  assert.equal(published.result.publication_state, 'published', published.raw);
  assert.equal(published.result.cover_path, `covers/i-new/${cover.jobId}`);
});

// ---- OP-40 for a cover: rejected. Only the job changes. ----

for (const [name, make, type, reason, detail] of [
  ['a GIF sent as a JPEG (FX-ADM-02)', gif, 'image/jpeg', 'COVER_INVALID', 'FORMAT'],
  ['a WebP image sent as a PNG (FX-ADM-02)', webp, 'image/png', 'COVER_INVALID', 'FORMAT'],
  ['an SVG drawing sent as a PNG', svg, 'image/png', 'COVER_INVALID', 'FORMAT'],
  ['a PDF sent as a JPEG', () => makePdf(), 'image/jpeg', 'COVER_INVALID', 'FORMAT'],
  ['a JPEG cut short', truncatedJpeg, 'image/jpeg', 'COVER_INVALID', 'UNREADABLE'],
  ['a PNG that claims 140 megapixels', hugePng, 'image/png', 'COVER_INVALID', 'UNREADABLE'],
  ['a cover 599 px wide', () => jpeg(599, 847), 'image/jpeg', 'COVER_INVALID', 'TOO_NARROW'],
  ['a square cover', () => jpeg(800, 800), 'image/jpeg', 'COVER_INVALID', 'SHAPE'],
  ['a landscape cover', () => jpeg(1131, 800), 'image/jpeg', 'COVER_INVALID', 'SHAPE'],
  ['a cover over the limit with a small declared size (FX-ADM-03)', noisyJpeg, 'image/jpeg', 'OVER_LIMIT', undefined],
]) {
  test(`G23 rejected: ${name}, ${reason}${detail ? ` (${detail})` : ''}`, async () => {
    const bytes = await make();
    if (reason === 'OVER_LIMIT') assert.ok(bytes.length > TEST_COVER_RULES.max_bytes, `the fixture is ${bytes.length} bytes`);
    const before = await dump();
    const { jobId, job } = await upload(bytes, { content_type: type });
    assert.equal(job.status, 'rejected');
    assert.equal(job.reason, reason);
    assert.equal(job.detail, detail);
    assert.equal(await exists(bucket, `holding/${jobId}`), false);
    const now = await dump();
    delete now.records[`upload_jobs/${jobId}`];
    assert.deepEqual(now, before);
  });
}

test('G23 a rejected cover leaves the current cover in place', async () => {
  const first = await upload(await jpeg(), { request_id: 'c-first' });
  const { job } = await upload(await gif(), { request_id: 'c-bad' });
  assert.equal(job.reason, 'COVER_INVALID');
  assert.equal((await db.doc('issues/i-new').get()).get('cover_path'), `covers/i-new/${first.jobId}`);
  assert.deepEqual(await covers(), [`covers/i-new/${first.jobId}`]);
});

test('G23 rejected: the admin role removed before the cover arrived, UPLOADER_NOT_AUTHORISED (INV-08)', async () => {
  const reply = await request();
  // The only admin, so the role is ended directly rather than through the last-admin check.
  await db.doc(`admin_roles/${admin.uid}`).update({ is_active: false });
  await bucket.file(`holding/${reply.result.job_id}`).save(await jpeg(), { resumable: false });
  assert.equal((await settled(reply.result.job_id)).reason, 'UPLOADER_NOT_AUTHORISED');
  assert.deepEqual(await covers(), []);
});

test('G23 rejected: the issue deleted before the cover arrived, ISSUE_NOT_FOUND', async () => {
  const reply = await request();
  await db.doc('issues/i-new').delete();
  await bucket.file(`holding/${reply.result.job_id}`).save(await jpeg(), { resumable: false });
  assert.equal((await settled(reply.result.job_id)).reason, 'ISSUE_NOT_FOUND');
  assert.deepEqual(await covers(), []);
});

// ---- listUploadJobs shows a cover job with its detail ----

test('G23 listUploadJobs: a cover job shows its kind, type and the detail of a refusal', async () => {
  const { jobId } = await upload(await jpeg(800, 800));
  const [job] = (await call('listUploadJobs', { job_id: jobId })).result.jobs;
  assert.deepEqual([job.kind, job.content_type, job.status, job.reason, job.detail], ['cover', 'image/jpeg', 'rejected', 'COVER_INVALID', 'SHAPE']);
});

// ---- getUploadLimits (PROPOSED) ----

test('G23 getUploadLimits: an admin gets the limits from the settings', async () => {
  const reply = await call('getUploadLimits', {});
  assert.deepEqual(reply.result, {
    pdf_max_bytes: TEST_LIMIT,
    cover: {
      max_bytes: TEST_COVER_RULES.max_bytes,
      min_width_px: TEST_COVER_RULES.min_width_px,
      min_height_ratio: TEST_COVER_RULES.min_height_ratio,
      max_height_ratio: TEST_COVER_RULES.max_height_ratio,
      content_types: ['image/jpeg', 'image/png'],
    },
  });
});

test('G23 getUploadLimits: a reader is refused', async () => {
  assert.equal((await call('getUploadLimits', {}, reader.idToken)).error?.status, 'PERMISSION_DENIED');
});

test('G23 getUploadLimits: a field it does not take is refused by name', async () => {
  const reply = await call('getUploadLimits', { pdf_max_bytes: 1 });
  assert.deepEqual(reply.error?.details?.fields, ['pdf_max_bytes']);
});

test('G23 getUploadLimits fails closed when a setting is missing', async () => {
  await db.doc('config/private').set({ max_upload_bytes: TEST_LIMIT });
  assert.equal((await call('getUploadLimits', {})).error?.status, 'INTERNAL');
});
