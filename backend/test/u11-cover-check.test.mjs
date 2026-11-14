// Unit tests of the cover check for OP-40 (FR-ADMIN-008; FX-ADM-02, FX-ADM-03; OQ-22 working position
// of 14 November 2026, PROVISIONAL). Generated images only (DEC-024). No database.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { coverFormat, inspectCover } from '../functions/dist/coverCheck.js';
import {
  asCoverRules,
  gif,
  hugePng,
  jpeg,
  jpegWithMetadata,
  metadataOf,
  pdfAsCover,
  png,
  sidewaysJpeg,
  svg,
  tiff,
  truncatedJpeg,
  webp,
} from './cover-fixtures.mjs';

const RULES = asCoverRules();

// ---- Accepted, and what is stored ----

for (const [name, make] of [
  ['a portrait JPEG', () => jpeg()],
  ['a portrait PNG', () => png()],
]) {
  test(`U11 ${name} is accepted and stored as a JPEG of the same size`, async () => {
    const verdict = await inspectCover(await make(), RULES);
    assert.equal(verdict.ok, true);
    assert.deepEqual([verdict.width, verdict.height], [800, 1131]);
    assert.equal(coverFormat(verdict.jpeg), 'jpeg');
    assert.equal((await metadataOf(verdict.jpeg)).format, 'jpeg');
  });
}

test('U11 a PNG with see-through parts is stored on white, with no see-through parts left', async () => {
  const verdict = await inspectCover(await png(), RULES);
  const meta = await metadataOf(verdict.jpeg);
  assert.equal(meta.hasAlpha, false);
  assert.equal(meta.channels, 3);
});

test('U11 a location and a camera name are not in the stored copy', async () => {
  const original = await jpegWithMetadata();
  assert.ok((await metadataOf(original)).exif, 'the fixture carries metadata');
  const verdict = await inspectCover(original, RULES);
  const meta = await metadataOf(verdict.jpeg);
  assert.equal(meta.exif, undefined);
  assert.equal(meta.xmp, undefined);
  assert.equal(meta.iptc, undefined);
  assert.equal(verdict.jpeg.includes(Buffer.from('TestCamera')), false);
});

test('U11 a wide image is scaled down to the stored width, keeping its shape', async () => {
  const verdict = await inspectCover(await jpeg(3000, 4243), RULES);
  assert.deepEqual([verdict.width, verdict.height], [1600, 2263]);
});

test('U11 an image is never scaled up', async () => {
  const verdict = await inspectCover(await jpeg(600, 849), RULES);
  assert.deepEqual([verdict.width, verdict.height], [600, 849]);
});

test('U11 a photo stored sideways with an orientation flag is judged and stored upright', async () => {
  const sideways = await sidewaysJpeg();
  const raw = await metadataOf(sideways);
  assert.deepEqual([raw.width, raw.height, raw.orientation], [1131, 800, 6]);
  const verdict = await inspectCover(sideways, RULES);
  assert.equal(verdict.ok, true);
  assert.deepEqual([verdict.width, verdict.height], [800, 1131]);
  assert.equal((await metadataOf(verdict.jpeg)).orientation, undefined);
});

// ---- The size and shape boundaries (600 px; height 1.27 to 1.56 times the width) ----

for (const [width, height, expected] of [
  [600, 849, true], // the narrowest accepted
  [599, 847, 'TOO_NARROW'],
  [600, 762, true], // 1.270
  [600, 761, 'SHAPE'], // 1.268
  [600, 936, true], // 1.560
  [600, 937, 'SHAPE'], // 1.562
  [800, 1035, true], // US Letter, 1.294
  [800, 800, 'SHAPE'], // square
  [1131, 800, 'SHAPE'], // landscape
]) {
  test(`U11 ${width} by ${height} px: ${expected === true ? 'accepted' : expected}`, async () => {
    const verdict = await inspectCover(await jpeg(width, height), RULES);
    if (expected === true) assert.equal(verdict.ok, true);
    else assert.deepEqual(verdict, { ok: false, detail: expected });
  });
}

// ---- Refused ----

for (const [name, make, detail] of [
  ['a GIF (FX-ADM-02)', gif, 'FORMAT'],
  ['a WebP image (FX-ADM-02)', webp, 'FORMAT'],
  ['a TIFF image', tiff, 'FORMAT'],
  ['an SVG drawing, which is never parsed', svg, 'FORMAT'],
  ['a PDF named as a cover', pdfAsCover, 'FORMAT'],
  ['an empty file', () => Buffer.alloc(0), 'FORMAT'],
  ['a JPEG cut short', truncatedJpeg, 'UNREADABLE'],
  ['a JPEG signature and nothing usable', () => Buffer.concat([Buffer.from([0xff, 0xd8, 0xff, 0xe0]), Buffer.alloc(500, 7)]), 'UNREADABLE'],
  ['a PNG whose header claims 140 megapixels', hugePng, 'UNREADABLE'],
  ['a PNG signature on JPEG data', async () => Buffer.concat([Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]), (await jpeg()).subarray(3)]), 'UNREADABLE'],
]) {
  test(`U11 refused: ${name}, ${detail}`, async () => {
    assert.deepEqual(await inspectCover(await make(), RULES), { ok: false, detail });
  });
}

test('U11 the minimum width and the shape come from the rules given', async () => {
  const file = await jpeg(800, 800);
  assert.equal((await inspectCover(file, { ...RULES, minHeightRatio: 0.9, maxHeightRatio: 1.1 })).ok, true);
  assert.deepEqual(await inspectCover(file, { ...RULES, minWidthPx: 801, minHeightRatio: 0.9, maxHeightRatio: 1.1 }), { ok: false, detail: 'TOO_NARROW' });
});
