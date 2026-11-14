// Generated images for the cover tests (TEST_DATA_AND_FIXTURES.md FX-ADM-02, FX-ADM-03; OQ-22 working
// position of 14 November 2026). No MFW file is used (DEC-024). The images are drawn here with the same
// library the backend uses, loaded from the functions folder.
import { createRequire } from 'node:module';
import { crc32, deflateSync } from 'node:zlib';

const sharp = createRequire(new URL('../functions/package.json', import.meta.url))('sharp');

// TEST VALUES, smaller than the working position so that the files stay small.
export const TEST_COVER_RULES = {
  max_bytes: 200_000,
  min_width_px: 600,
  min_height_ratio: 1.27,
  max_height_ratio: 1.56,
  stored_max_width_px: 1600,
};

export const asCoverRules = (r = TEST_COVER_RULES) => ({
  maxBytes: r.max_bytes,
  minWidthPx: r.min_width_px,
  minHeightRatio: r.min_height_ratio,
  maxHeightRatio: r.max_height_ratio,
  storedMaxWidthPx: r.stored_max_width_px,
});

// A plain image of the given size, with an alpha channel for PNG so that flattening shows.
const canvas = (width, height, alpha = false) =>
  sharp({ create: { width, height, channels: alpha ? 4 : 3, background: alpha ? { r: 200, g: 40, b: 40, alpha: 0.5 } : { r: 30, g: 60, b: 120 } } });

export const jpeg = (width = 800, height = 1131, options = {}) => canvas(width, height).jpeg(options).toBuffer();
// Random grey noise does not compress, so this is larger than the test limit (FX-ADM-03).
export const noisyJpeg = () =>
  sharp({ create: { width: 800, height: 1131, channels: 3, noise: { type: 'gaussian', mean: 128, sigma: 60 } } }).jpeg({ quality: 95 }).toBuffer();
export const png = (width = 800, height = 1131) => canvas(width, height, true).png().toBuffer();

// FX-ADM-02: formats not allowed.
export const gif = () => canvas(800, 1131).gif().toBuffer();
export const webp = () => canvas(800, 1131).webp().toBuffer();
export const tiff = () => canvas(800, 1131).tiff().toBuffer();
export const svg = () =>
  Buffer.from('<svg xmlns="http://www.w3.org/2000/svg" width="800" height="1131"><rect width="800" height="1131" fill="#123"/></svg>');

// A JPEG carrying a location and a camera name, as a phone photo would.
export const jpegWithMetadata = () =>
  canvas(800, 1131)
    .jpeg()
    .withExif({ IFD0: { Make: 'TestCamera', Model: 'Model 1', Copyright: 'synthetic' }, IFD3: { GPSLatitudeRef: 'N', GPSLatitude: '18/1 31/1 0/1' } })
    .toBuffer();

// Stored landscape, with the orientation flag that turns it upright into a portrait cover.
export const sidewaysJpeg = () => canvas(1131, 800).jpeg().withMetadata({ orientation: 6 }).toBuffer();

// A JPEG signature, and then the first half of a real file.
export const truncatedJpeg = async () => {
  const file = await jpeg();
  return file.subarray(0, Math.floor(file.length / 2));
};

// A real PNG with a PDF name would still be a PNG; this is a PDF given a cover's name.
export const pdfAsCover = () => Buffer.from('%PDF-1.7\n%%EOF\n', 'latin1');

// A PNG written by hand whose header claims 10,000 by 14,000 pixels while its data holds almost nothing, so
// it must be refused from its header and never decoded in full.
export const hugePng = () => {
  const chunk = (type, data) => {
    const length = Buffer.alloc(4);
    length.writeUInt32BE(data.length);
    const body = Buffer.concat([Buffer.from(type, 'latin1'), data]);
    const crc = Buffer.alloc(4);
    crc.writeUInt32BE(crc32(body));
    return Buffer.concat([length, body, crc]);
  };
  const header = Buffer.alloc(13);
  header.writeUInt32BE(10_000, 0);
  header.writeUInt32BE(14_000, 4);
  header.set([8, 0, 0, 0, 0], 8); // 8-bit greyscale
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', header),
    chunk('IDAT', deflateSync(Buffer.alloc(10_001))),
    chunk('IEND', Buffer.alloc(0)),
  ]);
};

export const metadataOf = (bytes) => sharp(bytes).metadata();
