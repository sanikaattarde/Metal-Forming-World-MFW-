// The cover check for OP-40 (FR-ADMIN-008; OQ-22 working position of 14 November 2026, PROVISIONAL).
// A cover passes only if its first bytes are a JPEG or PNG signature, the image decodes, and, once turned
// upright, it is at least the minimum width and its height divided by its width is within the range set.
// The stored copy is made here: turned upright, scaled down to the stored width, flattened onto white and
// written as a JPEG. Writing a new file drops every piece of metadata, such as a location or a camera
// name, because a cover is public (GS-D7).
//
// The image parser reads untrusted bytes, as pdf.js does for PDFs (SYSTEM_ARCHITECTURE.md T8). The
// signature check comes first, so only the JPEG and PNG decoders are ever reached: an SVG, a TIFF or
// any other format the library knows is refused before it is parsed. The pixel count is capped, so a
// small file that claims a huge image is refused without being decoded in full.
import sharp from 'sharp';

export interface CoverRules {
  maxBytes: number;
  minWidthPx: number;
  minHeightRatio: number; // height divided by width
  maxHeightRatio: number;
  storedMaxWidthPx: number;
}

// Why a cover was refused. The job's reason is COVER_INVALID (OP-40); this is its detail (PROPOSED).
export type CoverDetail = 'FORMAT' | 'UNREADABLE' | 'TOO_NARROW' | 'SHAPE';

export type CoverVerdict =
  | { ok: true; jpeg: Buffer; width: number; height: number }
  | { ok: false; detail: CoverDetail };

export const COVER_CONTENT_TYPES = ['image/jpeg', 'image/png'] as const;

// PLACEHOLDER. No document sets the largest image a cover may decode to. 50 megapixels is well above a
// print-quality A4 scan at 300 dpi (about 8.7 megapixels). Not a decided value.
export const PLACEHOLDER_COVER_MAX_INPUT_PIXELS = 50_000_000;

// PROVISIONAL (OQ-22 working position). The quality of the stored JPEG.
export const PROVISIONAL_COVER_JPEG_QUALITY = 85;

const JPEG = Buffer.from([0xff, 0xd8, 0xff]);
const PNG = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);

export function coverFormat(file: Buffer): 'jpeg' | 'png' | null {
  if (file.subarray(0, JPEG.length).equals(JPEG)) return 'jpeg';
  if (file.subarray(0, PNG.length).equals(PNG)) return 'png';
  return null;
}

export async function inspectCover(file: Buffer, rules: CoverRules): Promise<CoverVerdict> {
  const format = coverFormat(file);
  if (format === null) return { ok: false, detail: 'FORMAT' };

  const options = { failOn: 'error', limitInputPixels: PLACEHOLDER_COVER_MAX_INPUT_PIXELS } as const;
  let width: number;
  let height: number;
  try {
    const meta = await sharp(file, options).metadata();
    // The library sniffs the bytes itself. It must agree with the signature.
    if (meta.format !== format || !meta.width || !meta.height) return { ok: false, detail: 'UNREADABLE' };
    // Orientations 5 to 8 turn the image a quarter, so its upright width is its stored height.
    const quarterTurn = (meta.orientation ?? 1) >= 5;
    width = quarterTurn ? meta.height : meta.width;
    height = quarterTurn ? meta.width : meta.height;
  } catch {
    return { ok: false, detail: 'UNREADABLE' };
  }

  if (width < rules.minWidthPx) return { ok: false, detail: 'TOO_NARROW' };
  const ratio = height / width;
  if (ratio < rules.minHeightRatio || ratio > rules.maxHeightRatio) return { ok: false, detail: 'SHAPE' };

  try {
    // The whole image is decoded here, so a file that is cut short or damaged fails now.
    const { data, info } = await sharp(file, options)
      .autoOrient()
      .resize({ width: rules.storedMaxWidthPx, withoutEnlargement: true })
      .flatten({ background: '#ffffff' })
      .jpeg({ quality: PROVISIONAL_COVER_JPEG_QUALITY })
      .toBuffer({ resolveWithObject: true });
    return { ok: true, jpeg: data, width: info.width, height: info.height };
  } catch {
    return { ok: false, detail: 'UNREADABLE' };
  }
}
