// SPIKE (DEC-003 OPEN; OQ-30 OPEN). Unit tests of the genuine-PDF check for OP-40 (FR-ADMIN-006,
// NFR-SEC-008, AC-8.4) and of the upload address stub. Generated files only (DEC-024). No database.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { inspectPdf } from '../functions/dist/pdfCheck.js';
import { stubUploadUrlIssuer } from '../functions/dist/uploadUrlIssuer.js';
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

// ---- Accepted ----

for (const pages of [1, 3, 120]) {
  test(`U5 a valid PDF of ${pages} pages is accepted, with its page count`, async () => {
    assert.deepEqual(await inspectPdf(makePdf({ pages })), { ok: true, pageCount: pages });
  });
}

test('U5 a padded PDF of an exact size is accepted, and the fixture really is that size', async () => {
  const file = makePdf({ padTo: 8192 });
  assert.equal(file.length, 8192);
  assert.deepEqual(await inspectPdf(file), { ok: true, pageCount: 1 });
});

test('U5 a few stray bytes after the end-of-file marker are accepted', async () => {
  const file = Buffer.concat([makePdf(), Buffer.from('\n'.repeat(100))]);
  assert.equal((await inspectPdf(file)).ok, true);
});

// pdf.js repairs a damaged cross-reference table and loads every page. Recorded as behaviour, not as a decision.
test('U5 a PDF with a damaged cross-reference table is accepted, because pdf.js repairs it (FX-PDF-11)', async () => {
  assert.deepEqual(await inspectPdf(corruptXrefPdf()), { ok: true, pageCount: 3 });
});

// ---- Refused ----

const REFUSED = {
  'a PNG named as a PDF (FX-PDF-08)': [notAPdf, 'no PDF header'],
  'the header and nothing usable (FX-PDF-09)': [headerOnly, 'InvalidPDFException'],
  'the first half of a valid file (FX-PDF-10)': [truncatedPdf, 'no end-of-file marker'],
  'a password-protected PDF (FX-PDF-12, OQ-30)': [protectedPdf, 'PasswordException'],
  'an empty file (FX-PDF-13)': [emptyFile, 'no PDF header'],
  'a PDF with no pages': [noPagesPdf, 'no pages'],
  'a page that cannot be loaded': [brokenPageTreePdf, 'UnknownErrorException'],
  'the end-of-file marker too far from the end': [() => Buffer.concat([makePdf(), Buffer.alloc(2000, 0x20)]), 'no end-of-file marker'],
  'the header after a leading byte': [() => Buffer.concat([Buffer.from(' '), makePdf()]), 'no PDF header'],
  'the header in lower case': [() => Buffer.from(makePdf().toString('latin1').replace('%PDF-', '%pdf-'), 'latin1'), 'no PDF header'],
};

for (const [name, [make, why]] of Object.entries(REFUSED)) {
  test(`U5 refused: ${name}`, async () => {
    assert.deepEqual(await inspectPdf(make()), { ok: false, why });
  });
}

test('U5 the check leaves the bytes it was given unchanged, so the checksum is of the file accepted', async () => {
  const file = makePdf({ pages: 3 });
  const before = createHash('sha256').update(file).digest('hex');
  await inspectPdf(file);
  assert.equal(createHash('sha256').update(file).digest('hex'), before);
});

// ---- The upload address stub ----

const withEmulatorFlag = async (value, run) => {
  const saved = process.env.FUNCTIONS_EMULATOR;
  if (value === undefined) delete process.env.FUNCTIONS_EMULATOR;
  else process.env.FUNCTIONS_EMULATOR = value;
  try {
    return await run();
  } finally {
    if (saved === undefined) delete process.env.FUNCTIONS_EMULATOR;
    else process.env.FUNCTIONS_EMULATOR = saved;
  }
};

const REQUEST = { holdingPath: 'holding/job-1', contentType: 'application/pdf', maxBytes: 100, lifetimeSeconds: 60 };

for (const value of [undefined, 'false', '1', '']) {
  test(`U5 the upload stub releases nothing outside the emulators (FUNCTIONS_EMULATOR=${value})`, async () => {
    await withEmulatorFlag(value, () => assert.rejects(stubUploadUrlIssuer.issue(REQUEST), /No upload URL issuer is built/));
  });
}

test('U5 on the emulators the upload stub gives an address that cannot resolve, holds no path and honours the lifetime', async () => {
  const start = Date.now();
  const [one, two] = await withEmulatorFlag('true', () => Promise.all([stubUploadUrlIssuer.issue(REQUEST), stubUploadUrlIssuer.issue(REQUEST)]));
  assert.equal(new URL(one.url).hostname.endsWith('.invalid'), true);
  assert.equal(one.url.includes('holding'), false);
  assert.ok(one.expiresAtMillis >= start + 60_000 && one.expiresAtMillis <= Date.now() + 60_000);
  assert.notEqual(one.url, two.url);
});
