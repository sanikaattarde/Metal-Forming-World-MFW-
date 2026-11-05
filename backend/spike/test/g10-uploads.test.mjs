// SPIKE (DEC-003 OPEN, DEC-020 OPEN; OQ-21, OQ-22 and OQ-30 OPEN). Group G10: the upload backend, OP-19
// requestUpload, OP-20 listUploadJobs and OP-40 onUploadFinalized, through the emulators (FR-ADMIN-005 to
// FR-ADMIN-007, NFR-SEC-008, INV-01, INV-02, INV-08, GS-Q45, AC-8.3 to AC-8.5, SEC-CHK-07). Emulator only.
// The upload address is a stub, so a test puts the file in the holding area itself, as the signed URL
// would. Generated files only (DEC-024).
import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { getBytes, ref } from 'firebase/storage';
import { removeAdminRole } from '../functions/dist/admin.js';
import { finalizeUpload } from '../functions/dist/uploadFinalized.js';
import { PLACEHOLDER_UPLOAD_URL_LIFETIME_SECONDS } from '../functions/dist/uploads.js';
import { derivedId } from '../functions/dist/validation.js';
import {
  adminBackend,
  adminBucket,
  callFunction,
  clearAuthAccounts,
  disableAccount,
  forgedToken,
  newTestEnv,
  PROJECT_ID,
  signUp,
  TRIGGER_BUCKET,
  verifyEmail,
} from './helpers.mjs';
import {
  brokenPageTreePdf,
  corruptXrefPdf,
  emptyFile,
  headerOnly,
  makePdf,
  noPagesPdf,
  notAPdf,
  protectedPdf,
  truncatedPdf,
} from './pdf-fixtures.mjs';

// TEST VALUES. The real limit is "150 MB by default", with its unit and boundary open (OQ-30).
const TEST_LIMIT = 8192;
const TEST_LIFETIME_SECONDS = 600;
const NOW = new Date('2026-11-03T10:00:00Z');
const LIVE_FILE = makePdf({ pages: 2 });

const JOB_FIELDS = ['created_at', 'declared_size_bytes', 'issue_id', 'job_id', 'kind', 'requested_by', 'status'];
const VIEW_FIELDS = ['created_at', 'declared_size_bytes', 'finished_at', 'issue_id', 'job_id', 'kind', 'reason', 'revision', 'status'];
const FILE_FIELDS = ['accepted_at', 'checksum_sha256', 'issue_id', 'page_count', 'revision', 'size_bytes', 'status', 'storage_path', 'uploaded_at', 'uploaded_by'];

let env;
let backend;
let db;
let auth;
let bucket;
let direct;
let admin;
let otherAdmin;
let reader;

const sha256 = (bytes) => createHash('sha256').update(bytes).digest('hex');
const call = (name, data, token = admin.idToken) => callFunction(name, data, token);
const UPLOAD = { request_id: 'r1', kind: 'pdf', issue_id: 'i-new', declared_size_bytes: 1000, content_type: 'application/pdf' };
const request = (over = {}, token = admin.idToken) => call('requestUpload', { ...UPLOAD, ...over }, token);
const jobIdFor = (uid, requestId) => derivedId('upload', uid, requestId);
const put = (target, path, bytes) => target.file(path).save(bytes, { contentType: 'application/pdf', resumable: false });
const exists = async (target, path) => (await target.file(path).exists())[0];
const read = async (target, path) => (await target.file(path).download())[0];

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

const removed = (path) => waitFor(async () => !(await exists(bucket, path)), `${path} to be removed`);

// Requests an upload as the admin and puts the bytes where the upload address would.
async function upload(bytes, over = {}) {
  const reply = await request(over);
  assert.equal(reply.error, undefined, reply.raw);
  await put(bucket, `holding/${reply.result.job_id}`, bytes);
  return { jobId: reply.result.job_id, job: await settled(reply.result.job_id) };
}

// Every record and every stored object, to show what a step changed.
async function dump() {
  const out = {};
  for (const name of ['issues', 'upload_jobs', 'admin_roles']) {
    for (const item of (await db.collection(name).get()).docs) out[`${name}/${item.id}`] = item.data();
  }
  for (const item of (await db.collectionGroup('files').get()).docs) out[item.ref.path] = item.data();
  const [objects] = await bucket.getFiles();
  return JSON.stringify({ records: Object.keys(out).sort().map((key) => [key, out[key]]), objects: objects.map((o) => o.name).sort() });
}

const invalid = (reply, fields) => {
  assert.equal(reply.error?.status, 'INVALID_ARGUMENT', reply.raw);
  assert.deepEqual(reply.error.details.fields, fields);
};

const setConfig = (over = {}) =>
  db.doc('config/private').set({ max_upload_bytes: TEST_LIMIT, profile_gate_enabled: false, signed_url_lifetime: TEST_LIFETIME_SECONDS, ...over });

const seedIssue = (id, over = {}) =>
  db.doc(`issues/${id}`).set({ issue_id: id, title: 'An issue', description: 'What it covers', category_id: 'c1', publication_state: 'unpublished', ...over });

before(async () => {
  env = await newTestEnv();
  backend = adminBackend();
  db = backend.db;
  auth = backend.auth;
  bucket = adminBucket();
  // No trigger listens on this bucket, so the tests that call the function themselves are not raced by it.
  direct = adminBucket(`${PROJECT_ID}-direct`);
});

after(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await clearAuthAccounts();
  await bucket.deleteFiles({ force: true });
  await direct.deleteFiles({ force: true });
  admin = await signUp('admin-a@example.test');
  otherAdmin = await signUp('admin-b@example.test');
  reader = await signUp('reader@example.test');
  await auth.updateUser(reader.uid, { emailVerified: true });
  for (const account of [admin, otherAdmin]) {
    await verifyEmail(account.uid);
    await db.doc(`admin_roles/${account.uid}`).set({ user_id: account.uid, is_active: true, granted_by: 'test-seed', granted_at: NOW });
  }
  await db.doc('admin_guard/current').set({ guard_id: 'current', active_admin_count: 2, version: 1, updated_at: NOW });
  await setConfig();
  await seedIssue('i-new');
  await seedIssue('i-live', { publication_state: 'published', current_revision: 1, file_size_bytes: LIVE_FILE.length, page_count: 2 });
  await db.doc('issues/i-live/files/1').set({
    issue_id: 'i-live',
    revision: 1,
    storage_path: 'issues/i-live/1.pdf',
    size_bytes: LIVE_FILE.length,
    page_count: 2,
    checksum_sha256: sha256(LIVE_FILE),
    status: 'current',
    uploaded_by: 'test-seed',
  });
  await put(bucket, 'issues/i-live/1.pdf', LIVE_FILE);
});

// ---- The gate. A refusal writes nothing. ----

const CALLERS = {
  'no sign-in token': { token: async () => null, status: 'UNAUTHENTICATED' },
  'a reader': { token: async () => reader.idToken, status: 'PERMISSION_DENIED' },
  'a reader with forged admin claims': {
    token: async () => forgedToken(reader.uid, { admin: true, role: 'admin', is_admin: true }),
    status: 'PERMISSION_DENIED',
  },
  'a removed admin with a token from before the removal': {
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
  },
  'an admin whose email is not verified (OQ-20)': {
    token: async () => {
      await verifyEmail(otherAdmin.uid, false);
      return otherAdmin.idToken;
    },
    status: 'FAILED_PRECONDITION',
  },
};

for (const [operation, data] of [
  ['requestUpload', UPLOAD],
  ['listUploadJobs', { issue_id: 'i-new' }],
]) {
  for (const [who, { token, status }] of Object.entries(CALLERS)) {
    test(`G10 ${operation}: ${who} is refused, and nothing changes`, async () => {
      const idToken = await token();
      const before = await dump();
      const reply = await call(operation, data, idToken);
      assert.equal(reply.error?.status, status, reply.raw);
      assert.equal(await dump(), before);
    });
  }
}

// ---- OP-19 requestUpload ----

test('G10 requestUpload: an admin gets a job, an address that cannot resolve and its expiry, and the job is pending', async () => {
  const start = Date.now();
  const reply = await request();
  assert.equal(reply.error, undefined, reply.raw);
  assert.deepEqual(Object.keys(reply.result).sort(), ['expires_at', 'job_id', 'upload_url']);
  assert.equal(reply.result.job_id, jobIdFor(admin.uid, 'r1'));
  assert.equal(new URL(reply.result.upload_url).hostname.endsWith('.invalid'), true);
  const lifetime = PLACEHOLDER_UPLOAD_URL_LIFETIME_SECONDS * 1000;
  assert.ok(reply.result.expires_at >= start + lifetime && reply.result.expires_at <= Date.now() + lifetime);

  const job = (await db.doc(`upload_jobs/${reply.result.job_id}`).get()).data();
  assert.deepEqual(Object.keys(job).sort(), JOB_FIELDS);
  assert.deepEqual({ ...job, created_at: undefined }, {
    job_id: reply.result.job_id,
    kind: 'pdf',
    issue_id: 'i-new',
    requested_by: admin.uid,
    declared_size_bytes: 1000,
    status: 'pending',
    created_at: undefined,
  });
  assert.equal(await exists(bucket, `holding/${reply.result.job_id}`), false);
});

test('G10 requestUpload: a repeat returns the same job, and a repeat that asks for more changes nothing', async () => {
  const first = await request();
  const second = await request();
  const third = await request({ declared_size_bytes: 2000 });
  assert.equal(second.result.job_id, first.result.job_id);
  assert.equal(third.result.job_id, first.result.job_id);
  const jobs = await db.collection('upload_jobs').get();
  assert.equal(jobs.size, 1);
  assert.equal(jobs.docs[0].get('declared_size_bytes'), 1000);
});

test('G10 requestUpload: another request or another admin makes another job', async () => {
  const one = await request();
  const two = await request({ request_id: 'r2' });
  const three = await request({}, otherAdmin.idToken);
  assert.equal(new Set([one.result.job_id, two.result.job_id, three.result.job_id]).size, 3);
});

const BAD_REQUESTS = {
  'a field it does not take': [{ revision: 2 }, ['revision']],
  'a cover (OQ-22)': [{ kind: 'cover' }, ['kind']],
  'no kind': [{ kind: undefined }, ['kind']],
  'an issue path': [{ issue_id: 'i-live/files/1' }, ['issue_id']],
  'a size of zero': [{ declared_size_bytes: 0 }, ['declared_size_bytes']],
  'a negative size': [{ declared_size_bytes: -1 }, ['declared_size_bytes']],
  'a fractional size': [{ declared_size_bytes: 10.5 }, ['declared_size_bytes']],
  'a size as text': [{ declared_size_bytes: '1000' }, ['declared_size_bytes']],
  'a size over the limit': [{ declared_size_bytes: TEST_LIMIT + 1 }, ['declared_size_bytes']],
  'another content type': [{ content_type: 'image/png' }, ['content_type']],
  'the PDF type with a parameter': [{ content_type: 'application/pdf; charset=binary' }, ['content_type']],
  'the PDF type in capitals': [{ content_type: 'APPLICATION/PDF' }, ['content_type']],
  'no content type': [{ content_type: undefined }, ['content_type']],
  'no request identifier': [{ request_id: '' }, ['request_id']],
  'two problems, named in order': [{ kind: 'cover', content_type: 'text/plain' }, ['content_type', 'kind']],
};

for (const [name, [over, fields]] of Object.entries(BAD_REQUESTS)) {
  test(`G10 requestUpload refuses ${name}, and nothing changes`, async () => {
    const before = await dump();
    invalid(await request(over), fields);
    assert.equal(await dump(), before);
  });
}

test('G10 requestUpload: a declared size exactly at the limit is taken (the boundary is OQ-30)', async () => {
  const reply = await request({ declared_size_bytes: TEST_LIMIT });
  assert.equal(reply.error, undefined, reply.raw);
});

test('G10 requestUpload: an issue that does not exist is refused, and nothing changes', async () => {
  const before = await dump();
  const reply = await request({ issue_id: 'i-none' });
  assert.equal(reply.error?.status, 'NOT_FOUND', reply.raw);
  assert.equal(await dump(), before);
});

for (const [name, value] of [['missing', undefined], ['as text', String(TEST_LIMIT)], ['zero', 0]]) {
  test(`G10 requestUpload fails closed: the upload limit ${name}`, async () => {
    if (value === undefined) await db.doc('config/private').set({ profile_gate_enabled: false });
    else await setConfig({ max_upload_bytes: value });
    const before = await dump();
    const reply = await request();
    assert.equal(reply.error?.status, 'INTERNAL', reply.raw);
    assert.equal(await dump(), before);
  });
}

// ---- OP-40 onUploadFinalized: accepted ----

test('G10 a valid PDF becomes revision 1 of a new issue, which stays unpublished (AC-8.3, INV-01)', async () => {
  const file = makePdf({ pages: 3 });
  const { jobId, job } = await upload(file);
  assert.equal(job.status, 'accepted');
  assert.equal(job.revision, 1);
  assert.equal(job.reason, undefined);
  assert.ok(job.finished_at);

  assert.equal(await exists(bucket, `holding/${jobId}`), false);
  const path = `issues/i-new/1-${jobId}.pdf`;
  assert.equal(sha256(await read(bucket, path)), sha256(file));

  const record = (await db.doc('issues/i-new/files/1').get()).data();
  assert.deepEqual(Object.keys(record).sort(), FILE_FIELDS);
  assert.deepEqual({ ...record, uploaded_at: undefined, accepted_at: undefined }, {
    issue_id: 'i-new',
    revision: 1,
    storage_path: path,
    size_bytes: file.length,
    page_count: 3,
    checksum_sha256: sha256(file),
    status: 'current',
    uploaded_by: admin.uid,
    uploaded_at: undefined,
    accepted_at: undefined,
  });

  const issue = (await db.doc('issues/i-new').get()).data();
  assert.equal(issue.current_revision, 1);
  assert.equal(issue.file_size_bytes, file.length);
  assert.equal(issue.page_count, 3);
  assert.equal(issue.publication_state, 'unpublished');
});

test('G10 an accepted file can be published, and then a reader gets it through getIssueFile (INV-02, OP-11)', async () => {
  const file = makePdf({ pages: 3 });
  await upload(file);
  const published = await call('publishIssue', { request_id: 'p1', issue_id: 'i-new' });
  assert.equal(published.error, undefined, published.raw);

  const grant = await call('getIssueFile', { issue_id: 'i-new' }, reader.idToken);
  assert.equal(grant.error, undefined, grant.raw);
  assert.equal(grant.result.revision, 1);
  assert.equal(grant.result.size_bytes, file.length);
  assert.equal(grant.result.checksum_sha256, sha256(file));
});

test('G10 a replacement becomes revision 2; revision 1 is superseded and its file kept (GS-Q45)', async () => {
  const file = makePdf({ pages: 4 });
  const { job } = await upload(file, { issue_id: 'i-live' });
  assert.equal(job.status, 'accepted');
  assert.equal(job.revision, 2);

  assert.equal((await db.doc('issues/i-live/files/1').get()).get('status'), 'superseded');
  assert.equal((await db.doc('issues/i-live/files/2').get()).get('status'), 'current');
  assert.equal(sha256(await read(bucket, 'issues/i-live/1.pdf')), sha256(LIVE_FILE));
  const issue = (await db.doc('issues/i-live').get()).data();
  assert.equal(issue.current_revision, 2);
  assert.equal(issue.publication_state, 'published');

  const grant = await call('getIssueFile', { issue_id: 'i-live' }, reader.idToken);
  assert.equal(grant.result.revision, 2, grant.raw);
  assert.equal(grant.result.checksum_sha256, sha256(file));
});

test('G10 a replacement that fails leaves revision 1 in place, and readers still get it (FX-ADM-09)', async () => {
  const before = await db.doc('issues/i-live').get();
  const { job } = await upload(headerOnly(), { issue_id: 'i-live' });
  assert.equal(job.status, 'rejected');
  assert.deepEqual((await db.doc('issues/i-live').get()).data(), before.data());
  assert.equal((await db.doc('issues/i-live/files/1').get()).get('status'), 'current');
  assert.equal((await db.collection('issues/i-live/files').get()).size, 1);

  const grant = await call('getIssueFile', { issue_id: 'i-live' }, reader.idToken);
  assert.equal(grant.result.revision, 1, grant.raw);
  assert.equal(grant.result.checksum_sha256, sha256(LIVE_FILE));
});

test('G10 a file exactly at the limit is accepted (FX-PDF-06; the boundary is OQ-30)', async () => {
  const { job } = await upload(makePdf({ padTo: TEST_LIMIT }), { declared_size_bytes: TEST_LIMIT });
  assert.equal(job.status, 'accepted');
});

test('G10 a damaged cross-reference table is accepted, because pdf.js repairs it (FX-PDF-11)', async () => {
  const { job } = await upload(corruptXrefPdf());
  assert.equal(job.status, 'accepted');
  assert.equal((await db.doc('issues/i-new/files/1').get()).get('page_count'), 3);
});

test('G10 after a job is finished, a repeat gets its status and no new address', async () => {
  await upload(makePdf());
  const reply = await request();
  assert.deepEqual(reply.result, { job_id: jobIdFor(admin.uid, 'r1'), status: 'accepted' });
});

// ---- OP-40: rejected. The job says why, the file is removed and nothing else changes. ----

const REJECTED = {
  'a PNG named as a PDF (FX-PDF-08)': [notAPdf, 'NOT_A_PDF'],
  'the header and nothing usable (FX-PDF-09)': [headerOnly, 'NOT_A_PDF'],
  'the first half of a valid file (FX-PDF-10)': [truncatedPdf, 'NOT_A_PDF'],
  'a password-protected PDF (FX-PDF-12; OQ-30)': [protectedPdf, 'NOT_A_PDF'],
  'an empty file (FX-PDF-13)': [emptyFile, 'NOT_A_PDF'],
  'a PDF with no pages': [noPagesPdf, 'NOT_A_PDF'],
  'a page that cannot be loaded': [brokenPageTreePdf, 'NOT_A_PDF'],
  'one byte over the limit (FX-PDF-07)': [() => makePdf({ padTo: TEST_LIMIT + 1 }), 'OVER_LIMIT'],
  'over the limit with a small declared size': [() => makePdf({ padTo: TEST_LIMIT * 2 }), 'OVER_LIMIT'],
};

for (const [name, [make, reason]] of Object.entries(REJECTED)) {
  test(`G10 rejected: ${name}, ${reason}`, async () => {
    const before = await dump();
    const { jobId, job } = await upload(make());
    assert.equal(job.status, 'rejected');
    assert.equal(job.reason, reason);
    assert.ok(job.finished_at);
    assert.equal(await exists(bucket, `holding/${jobId}`), false);
    // Only the job changed.
    const after = JSON.parse(await dump());
    const expected = JSON.parse(before);
    after.records = after.records.filter(([key]) => key !== `upload_jobs/${jobId}`);
    assert.deepEqual(after, expected);
  });
}

// ---- OP-40: the uploader is checked again when the file arrives (INV-08) ----

const LOST_STANDING = {
  'the role removed (FX-ADM-08)': () => removeAdminRole(backend, admin.uid),
  'the account marked deleting': () => db.doc(`users/${admin.uid}`).set({ user_id: admin.uid, status: 'deleting' }),
  'the account disabled by the provider': () => disableAccount(admin.uid),
  'the email no longer verified (OQ-20)': () => verifyEmail(admin.uid, false),
};

for (const [name, change] of Object.entries(LOST_STANDING)) {
  test(`G10 rejected: ${name} between the request and the file arriving, UPLOADER_NOT_AUTHORISED`, async () => {
    const reply = await request();
    await change();
    await put(bucket, `holding/${reply.result.job_id}`, makePdf());
    const job = await settled(reply.result.job_id);
    assert.equal(job.reason, 'UPLOADER_NOT_AUTHORISED');
    assert.equal((await db.collection('issues/i-new/files').get()).size, 0);
    assert.deepEqual((await bucket.getFiles({ prefix: 'issues/i-new/' }))[0], []);
  });
}

test('G10 rejected: the issue deleted between the request and the file arriving, ISSUE_NOT_FOUND', async () => {
  const reply = await request();
  await db.doc('issues/i-new').delete();
  await put(bucket, `holding/${reply.result.job_id}`, makePdf());
  const job = await settled(reply.result.job_id);
  assert.equal(job.reason, 'ISSUE_NOT_FOUND');
  assert.deepEqual((await bucket.getFiles({ prefix: 'issues/i-new/' }))[0], []);
});

// ---- SEC-CHK-07: a file that comes round the interface is still checked ----

for (const [name, path] of [
  ['with no job', 'holding/no-such-job'],
  ['under a deeper path', 'holding/a/b'],
]) {
  test(`G10 a valid PDF put in the holding area ${name} is removed, and nothing else changes`, async () => {
    const before = await dump();
    await put(bucket, path, makePdf());
    await removed(path);
    assert.equal(await dump(), before);
  });
}

test('G10 a second file sent to an address already used is removed, and the accepted revision is unchanged', async () => {
  const first = makePdf({ pages: 1 });
  const { jobId } = await upload(first);
  const before = await dump();
  await put(bucket, `holding/${jobId}`, makePdf({ pages: 5 }));
  await removed(`holding/${jobId}`);
  assert.equal(await dump(), before);
  assert.equal((await db.doc('issues/i-new/files/1').get()).get('checksum_sha256'), sha256(first));
});

test('G10 neither a reader nor an admin can read the accepted file directly, on the trigger bucket too', async () => {
  const { jobId } = await upload(makePdf());
  const path = `issues/i-new/1-${jobId}.pdf`;
  await env.withSecurityRulesDisabled(async (context) => {
    await assertSucceeds(getBytes(ref(context.storage(`gs://${TRIGGER_BUCKET}`), path))); // the file is there
  });
  for (const context of [env.authenticatedContext(admin.uid, { email_verified: true }), env.authenticatedContext(reader.uid, { email_verified: true }), env.unauthenticatedContext()]) {
    await assertFails(getBytes(ref(context.storage(`gs://${TRIGGER_BUCKET}`), path)));
  }
});

// ---- OP-20 listUploadJobs ----

test('G10 listUploadJobs: by job, one job with its status and no uploader', async () => {
  const { jobId } = await upload(notAPdf());
  const reply = await call('listUploadJobs', { job_id: jobId });
  assert.equal(reply.result.jobs.length, 1);
  const [job] = reply.result.jobs;
  assert.deepEqual(Object.keys(job).sort(), VIEW_FIELDS);
  assert.equal(job.status, 'rejected');
  assert.equal(job.reason, 'NOT_A_PDF');
  assert.equal(reply.raw.includes(admin.uid), false);
});

test('G10 listUploadJobs: by issue, newest first, with the reason for a rejection', async () => {
  const rejected = await upload(notAPdf(), { request_id: 'r-old' });
  const accepted = await upload(makePdf(), { request_id: 'r-new' });
  await request({ request_id: 'r-other', issue_id: 'i-live' }); // another issue's job is not listed
  const reply = await call('listUploadJobs', { issue_id: 'i-new' });
  assert.deepEqual(reply.result.jobs.map((job) => [job.job_id, job.status, job.reason, job.revision]), [
    [accepted.jobId, 'accepted', null, 1],
    [rejected.jobId, 'rejected', 'NOT_A_PDF', null],
  ]);
});

test('G10 listUploadJobs: a job that does not exist gives an empty list', async () => {
  assert.deepEqual((await call('listUploadJobs', { job_id: 'no-such-job' })).result, { jobs: [] });
});

for (const [name, data, fields] of [
  ['both an issue and a job', { issue_id: 'i-new', job_id: 'j1' }, ['issue_id', 'job_id']],
  ['neither', {}, ['issue_id', 'job_id']],
  ['a job path', { job_id: 'j1/x' }, ['job_id']],
  ['an issue path', { issue_id: 'i-new/files' }, ['issue_id']],
  ['a field it does not take', { issue_id: 'i-new', status: 'pending' }, ['status']],
]) {
  test(`G10 listUploadJobs refuses ${name}`, async () => {
    invalid(await call('listUploadJobs', data), fields);
  });
}

// ---- Called directly, on a bucket no trigger listens on, so that a step can be made to fail ----

async function directJob(requestId = 'r-direct', bytes = makePdf()) {
  const reply = await request({ request_id: requestId });
  const jobId = reply.result.job_id;
  await put(direct, `holding/${jobId}`, bytes);
  const [metadata] = await direct.file(`holding/${jobId}`).getMetadata();
  return { jobId, object: { name: `holding/${jobId}`, size: Number(metadata.size), timeCreated: metadata.timeCreated } };
}

const jobStatus = async (jobId) => (await db.doc(`upload_jobs/${jobId}`).get()).get('status');

test('G10 objects outside the holding area are left alone, including the function\'s own copy', async () => {
  for (const path of ['covers/i-new/v1', 'issues/i-new/9.pdf']) {
    await put(direct, path, makePdf());
    assert.deepEqual(await finalizeUpload({ db, auth, bucket: direct }, { name: path, size: 1 }), { outcome: 'IGNORED' });
    assert.equal(await exists(direct, path), true);
  }
});

test('G10 fails closed: the sign-in provider cannot be reached. The job stays pending and the file stays', async () => {
  const { jobId, object } = await directJob();
  const brokenAuth = { getUser: () => Promise.reject(new Error('secret')) };
  await assert.rejects(finalizeUpload({ db, auth: brokenAuth, bucket: direct }, object));
  assert.equal(await jobStatus(jobId), 'pending');
  assert.equal(await exists(direct, object.name), true);
  assert.deepEqual((await direct.getFiles({ prefix: 'issues/' }))[0], []);
});

test('G10 fails closed: the upload limit is unusable when the file arrives', async () => {
  const { jobId, object } = await directJob();
  await setConfig({ max_upload_bytes: 'large' });
  await assert.rejects(finalizeUpload({ db, auth, bucket: direct }, object), /max_upload_bytes/);
  assert.equal(await jobStatus(jobId), 'pending');
  assert.equal(await exists(direct, object.name), true);
});

test('G10 the size the store reports is checked before the file is read', async () => {
  const { jobId, object } = await directJob('r-size', makePdf());
  assert.deepEqual(await finalizeUpload({ db, auth, bucket: direct }, { ...object, size: TEST_LIMIT + 1 }), { outcome: 'OVER_LIMIT', uploader: admin.uid });
  assert.equal(await jobStatus(jobId), 'rejected');
});

test('G10 the bytes are checked too, whatever size the store reports', async () => {
  const { jobId, object } = await directJob('r-bytes', makePdf({ padTo: TEST_LIMIT + 1 }));
  assert.deepEqual(await finalizeUpload({ db, auth, bucket: direct }, { ...object, size: 10 }), { outcome: 'OVER_LIMIT', uploader: admin.uid });
  assert.equal(await jobStatus(jobId), 'rejected');
});

const failingTransactions = new Proxy({}, {
  get: (_, name) => (name === 'runTransaction' ? () => Promise.reject(new Error('secret')) : typeof db[name] === 'function' ? db[name].bind(db) : db[name]),
});

// Runs a step just before the final transaction, as if something else changed meanwhile.
const beforeFinalWrite = (step) =>
  new Proxy({}, {
    get: (_, name) =>
      name === 'runTransaction'
        ? async (work) => {
            await step();
            return db.runTransaction(work);
          }
        : typeof db[name] === 'function'
          ? db[name].bind(db)
          : db[name],
  });

test('G10 a job that expired while its file was checked is not accepted, and no record points at the copy', async () => {
  const { jobId, object } = await directJob('r-expired');
  const changed = beforeFinalWrite(() => db.doc(`upload_jobs/${jobId}`).update({ status: 'expired' }));
  await assert.rejects(finalizeUpload({ db: changed, auth, bucket: direct }, object));
  assert.equal(await jobStatus(jobId), 'expired');
  assert.equal((await db.collection('issues/i-new/files').get()).size, 0);
  assert.equal((await db.doc('issues/i-new').get()).get('current_revision'), undefined);
});

test('G10 an issue whose current revision changed while the file was checked is left as it is', async () => {
  const reply = await request({ request_id: 'r-moved', issue_id: 'i-live' });
  const name = `holding/${reply.result.job_id}`;
  await put(direct, name, makePdf());
  const changed = beforeFinalWrite(() => db.doc('issues/i-live').update({ current_revision: 5 }));
  await assert.rejects(finalizeUpload({ db: changed, auth, bucket: direct }, { name, size: makePdf().length }));
  assert.equal((await db.doc('issues/i-live').get()).get('current_revision'), 5);
  assert.equal((await db.doc('issues/i-live/files/1').get()).get('status'), 'current');
  assert.equal((await db.collection('issues/i-live/files').get()).size, 1);
  assert.equal(await jobStatus(reply.result.job_id), 'pending');
});

test('G10 if the final write fails, the copy is an orphan, the job stays pending and no record points at it', async () => {
  const { jobId, object } = await directJob();
  await assert.rejects(finalizeUpload({ db: failingTransactions, auth, bucket: direct }, object));
  assert.equal(await jobStatus(jobId), 'pending');
  assert.equal(await exists(direct, `issues/i-new/1-${jobId}.pdf`), true);
  assert.equal(await exists(direct, object.name), false);
  assert.equal((await db.collection('issues/i-new/files').get()).size, 0);
  assert.equal((await db.doc('issues/i-new').get()).get('current_revision'), undefined);
});

test('G10 the next upload after an orphan takes the same number at its own path, and leaves the orphan untouched', async () => {
  const orphan = makePdf({ pages: 1 });
  const first = await directJob('r-a', orphan);
  await assert.rejects(finalizeUpload({ db: failingTransactions, auth, bucket: direct }, first.object));

  const file = makePdf({ pages: 2 });
  const second = await directJob('r-b', file);
  assert.deepEqual(await finalizeUpload({ db, auth, bucket: direct }, second.object), { outcome: 'ACCEPTED', uploader: admin.uid });
  const record = (await db.doc('issues/i-new/files/1').get()).data();
  assert.equal(record.storage_path, `issues/i-new/1-${second.jobId}.pdf`);
  assert.equal(sha256(await read(direct, record.storage_path)), sha256(file));
  assert.equal(sha256(await read(direct, `issues/i-new/1-${first.jobId}.pdf`)), sha256(orphan));
});

// EMULATOR ONLY: not a pass for concurrency.
test('G10 at the same moment: two uploads for one issue never leave a record whose checksum is another file\'s', async () => {
  for (let round = 0; round < 3; round += 1) {
    const issueId = `i-race-${round}`;
    await seedIssue(issueId);
    const files = [makePdf({ pages: 1 }), makePdf({ pages: 2 })];
    const jobs = [];
    for (const [index, bytes] of files.entries()) {
      const reply = await request({ request_id: `race-${round}-${index}`, issue_id: issueId });
      await put(direct, `holding/${reply.result.job_id}`, bytes);
      const [metadata] = await direct.file(`holding/${reply.result.job_id}`).getMetadata();
      jobs.push({ jobId: reply.result.job_id, object: { name: `holding/${reply.result.job_id}`, size: Number(metadata.size) } });
    }
    await Promise.allSettled(jobs.map(({ object }) => finalizeUpload({ db, auth, bucket: direct }, object)));

    const records = (await db.collection(`issues/${issueId}/files`).get()).docs.map((d) => d.data());
    assert.ok(records.length >= 1, `round ${round}: nothing accepted`);
    assert.equal(records.filter((r) => r.status === 'current').length, 1, `round ${round}`);
    for (const record of records) {
      assert.equal(sha256(await read(direct, record.storage_path)), record.checksum_sha256, `round ${round}: ${record.storage_path}`);
    }
    for (const { jobId } of jobs) assert.ok(['accepted', 'pending'].includes(await jobStatus(jobId)), `round ${round}`);
  }
});
