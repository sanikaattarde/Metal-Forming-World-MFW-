// Generated files for the upload tests (TEST_DATA_AND_FIXTURES.md FX-PDF-06 to FX-PDF-13).
// No MFW file is used (DEC-024). Each PDF is written out by hand, so its structure is known exactly.

import { createHash } from 'node:crypto';

const bytes = (text) => Buffer.from(text, 'latin1');

// RC4, written out because the platform's crypto library no longer offers it. Used only to build fixtures.
const rc4 = (key, data) => {
  const s = Array.from({ length: 256 }, (_, i) => i);
  for (let i = 0, j = 0; i < 256; i += 1) {
    j = (j + s[i] + key[i % key.length]) & 255;
    [s[i], s[j]] = [s[j], s[i]];
  }
  const out = Buffer.alloc(data.length);
  for (let n = 0, i = 0, j = 0; n < data.length; n += 1) {
    i = (i + 1) & 255;
    j = (j + s[i]) & 255;
    [s[i], s[j]] = [s[j], s[i]];
    out[n] = data[n] ^ s[(s[i] + s[j]) & 255];
  }
  return out;
};

const md5 = (...parts) => createHash('md5').update(Buffer.concat(parts)).digest();
const PASSWORD_PAD = Buffer.from('28BF4E5E4E758A4164004E56FFFA01082E2E00B6D0683E802F0CA9FE6453697A', 'hex');

// The /U value of a standard security handler (revision 3, 128-bit) whose user password is empty
// (PDF 1.7 algorithms 3.2 and 3.5), so a reader opens the file without asking. The permissions say
// "no printing, no copying". The pages hold no strings or streams, so nothing else needs encrypting.
const OWNER_ONLY = { o: Buffer.alloc(32, 0xab), p: -3904, id: Buffer.alloc(16, 0x01) };
const emptyPasswordU = ({ o, p, id }) => {
  const permissions = Buffer.alloc(4);
  permissions.writeInt32LE(p);
  let key = md5(PASSWORD_PAD, o, permissions, id);
  for (let round = 0; round < 50; round += 1) key = md5(key);
  let u = rc4(key, md5(PASSWORD_PAD, id));
  for (let round = 1; round <= 19; round += 1) u = rc4(key.map((b) => b ^ round), u);
  return Buffer.concat([u, Buffer.alloc(16)]);
};

// A small valid PDF with blank pages. `padTo` makes it exactly that many bytes, with a padding stream,
// for the boundary files. `encrypt` adds a standard security handler whose values match no password,
// so a reader asks for one (FX-PDF-12). The encryption is not real. `ownerOnly` adds a real handler with an
// empty user password: it opens without a password and only limits printing and copying.
export function makePdf({ pages = 1, padTo, encrypt = false, ownerOnly = false } = {}) {
  const build = (padLength) => {
    const pageIds = Array.from({ length: pages }, (_, index) => 3 + index);
    const objects = [
      '<< /Type /Catalog /Pages 2 0 R >>',
      `<< /Type /Pages /Kids [${pageIds.map((id) => `${id} 0 R`).join(' ')}] /Count ${pages} >>`,
      ...pageIds.map(() => '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] >>'),
    ];
    if (padLength !== undefined) objects.push(`<< /Length ${padLength} >>\nstream\n${'0'.repeat(padLength)}\nendstream`);

    let body = '%PDF-1.7\n%\xE2\xE3\xCF\xD3\n';
    const offsets = objects.map((content, index) => {
      const at = Buffer.byteLength(body, 'latin1');
      body += `${index + 1} 0 obj\n${content}\nendobj\n`;
      return at;
    });
    const xrefAt = Buffer.byteLength(body, 'latin1');
    body += `xref\n0 ${objects.length + 1}\n0000000000 65535 f \n`;
    body += offsets.map((at) => `${String(at).padStart(10, '0')} 00000 n \n`).join('');
    const handler = (u, p) =>
      ` /Encrypt << /Filter /Standard /V 2 /R 3 /Length 128 /P ${p} /O <${'ab'.repeat(32)}> /U <${u}> >> /ID [<${'01'.repeat(16)}> <${'01'.repeat(16)}>]`;
    const security = encrypt
      ? handler('cd'.repeat(32), -4)
      : ownerOnly
        ? handler(emptyPasswordU(OWNER_ONLY).toString('hex'), OWNER_ONLY.p)
        : '';
    body += `trailer\n<< /Size ${objects.length + 1} /Root 1 0 R${security} >>\nstartxref\n${xrefAt}\n%%EOF\n`;
    return bytes(body);
  };

  if (padTo === undefined) return build();
  let padLength = 0;
  for (let round = 0; round < 10; round += 1) {
    const file = build(padLength);
    if (file.length === padTo) return file;
    padLength += padTo - file.length;
    if (padLength < 0) throw new Error(`A PDF of ${padTo} bytes is too small to build`);
  }
  throw new Error(`Could not pad a PDF to ${padTo} bytes`);
}

// FX-PDF-08: a PNG signature and some bytes, given a .pdf name by the test.
export const notAPdf = () => Buffer.concat([Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]), bytes('IHDR'.repeat(64))]);

// FX-PDF-09: the header, and then nothing a reader can use.
export const headerOnly = () => bytes(`%PDF-1.7\n${'this is not a PDF\n'.repeat(20)}%%EOF\n`);

// FX-PDF-10: the first half of a valid file.
export const truncatedPdf = () => {
  const file = makePdf({ pages: 3 });
  return file.subarray(0, Math.floor(file.length / 2));
};

// FX-PDF-11: a valid file whose cross-reference table points at the wrong places.
export const corruptXrefPdf = () => {
  const text = makePdf({ pages: 3 }).toString('latin1');
  return bytes(text.replace(/(\d{10}) 00000 n /g, '0000000001 00000 n '));
};

// FX-PDF-12.
export const protectedPdf = () => makePdf({ encrypt: true });

// A PDF that limits printing and copying but needs no password to open (OQ-30): accepted.
export const ownerOnlyPdf = () => makePdf({ pages: 2, ownerOnly: true });

// FX-PDF-13.
export const emptyFile = () => Buffer.alloc(0);

// A valid structure with no pages.
export const noPagesPdf = () => makePdf({ pages: 0 });

// It opens, and says it has a page, but the page tree points at an object that is not there.
export const brokenPageTreePdf = () => Buffer.from(makePdf().toString('latin1').replace('/Kids [3 0 R]', '/Kids [9 0 R]'), 'latin1');
