// The upload calls of the issue-file section (MOD12-P2-T02) against the backend's real OP-19 and OP-20 on the
// local emulators. The emulators cannot sign, so the upload address is the emulator's unresolvable one and no
// file is sent from here; the backend's G10 puts files in the holding area and checks OP-40. Emulator only.
import { afterAll, beforeAll, beforeEach, expect, test } from 'vitest';
import { adminApi } from '../src/adminApi';
import type { CallFn } from '../src/adminApi';
import { getUploadLimits, newRequestId, requestUpload, uploadJobs } from '../src/data';
import { emulatorBackend, servicesFor } from '../src/services';
import type { Backend, Services } from '../src/services';
import { signInAdmin } from '../src/signIn';
import { AUTH_URL, clearAll, createAdmin, PASSWORD, requireEmulators, setDoc } from './emulator';

// TEST VALUE. The real limit is "150 MB by default", with its unit and boundary open (OQ-30).
const TEST_LIMIT = 4096;
const TEST_COVER_RULES = { max_bytes: 2048, min_width_px: 600, min_height_ratio: 1.27, max_height_ratio: 1.56, stored_max_width_px: 1600 };

let backend: Backend;
let services: Services;
let api: CallFn;
let n = 0;

beforeAll(() => {
  requireEmulators();
  backend = emulatorBackend(AUTH_URL, 'b52-admin');
  services = servicesFor(backend);
  api = adminApi(services.call, () => {
    throw new Error('the session ended during a test');
  });
});

afterAll(async () => {
  await backend.auth.signOut();
});

beforeEach(async () => {
  await backend.auth.signOut();
  await clearAll();
  n += 1;
  await createAdmin(`admin-${n}@example.test`);
  await setDoc('config/private', { max_upload_bytes: TEST_LIMIT, cover_rules: TEST_COVER_RULES });
  await setDoc('issues/i-1', { issue_id: 'i-1', title: 'November', publication_state: 'unpublished', publication_date: '2026-11-01' });
  expect(await signInAdmin(services, `admin-${n}@example.test`, PASSWORD)).toBe('signed-in');
});

test('OP-19 gives a pending job with an address and the headers to open it; the same request is the same job', async () => {
  const requestId = newRequestId();
  const first = await requestUpload(api, requestId, 'i-1', 2048);
  expect(first.upload_url).toMatch(/^https:\/\/upload-emulator\.invalid\//);
  expect(first.upload_headers).toEqual({ 'content-type': 'application/pdf', 'x-goog-resumable': 'start' });
  const again = await requestUpload(api, requestId, 'i-1', 2048);
  expect(again.job_id).toBe(first.job_id);

  const jobs = await uploadJobs(api, { issue_id: 'i-1' });
  expect(jobs).toHaveLength(1);
  expect(jobs[0]).toMatchObject({ job_id: first.job_id, status: 'pending', declared_size_bytes: 2048, reason: null });
  expect(await uploadJobs(api, { job_id: first.job_id })).toEqual(jobs);
});

test('AC-8.5: a declared size over the limit is refused naming the size field, and no job is made', async () => {
  const error = await requestUpload(api, newRequestId(), 'i-1', TEST_LIMIT + 1).catch((e: unknown) => e);
  expect(error).toMatchObject({ code: 'functions/invalid-argument', details: { fields: ['declared_size_bytes'] } });
  expect(await uploadJobs(api, { issue_id: 'i-1' })).toEqual([]);
});

test('an issue that does not exist is not found', async () => {
  const error = await requestUpload(api, newRequestId(), 'i-none', 10).catch((e: unknown) => e);
  expect(error).toMatchObject({ code: 'functions/not-found' });
});

test('a cover is requested with its own kind and type, against the cover limit (MOD12-P2-T02, OQ-22)', async () => {
  const cover = await requestUpload(api, newRequestId(), 'i-1', 2048, 'cover', 'image/png');
  expect(cover.upload_headers).toEqual({ 'content-type': 'image/png', 'x-goog-resumable': 'start' });
  const [job] = await uploadJobs(api, { job_id: cover.job_id });
  expect(job).toMatchObject({ kind: 'cover', content_type: 'image/png', status: 'pending', detail: null });

  const over = await requestUpload(api, newRequestId(), 'i-1', 2049, 'cover', 'image/jpeg').catch((e: unknown) => e);
  expect(over).toMatchObject({ code: 'functions/invalid-argument', details: { fields: ['declared_size_bytes'] } });
  const gif = await requestUpload(api, newRequestId(), 'i-1', 10, 'cover', 'image/gif').catch((e: unknown) => e);
  expect(gif).toMatchObject({ code: 'functions/invalid-argument', details: { fields: ['content_type'] } });
});

test('getUploadLimits gives the limits from the settings, for the panel to name them', async () => {
  expect(await getUploadLimits(api)).toEqual({
    pdf_max_bytes: TEST_LIMIT,
    cover: { max_bytes: 2048, min_width_px: 600, min_height_ratio: 1.27, max_height_ratio: 1.56, content_types: ['image/jpeg', 'image/png'] },
  });
});
