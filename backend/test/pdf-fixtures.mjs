// Generated files for the upload tests (TEST_DATA_AND_FIXTURES.md FX-PDF-06 to FX-PDF-13).
// No MFW file is used (DEC-024). Each PDF is written out by hand, so its structure is known exactly.

const bytes = (text) => Buffer.from(text, 'latin1');

// A small valid PDF with blank pages. `padTo` makes it exactly that many bytes, with a padding stream,
// for the boundary files. `encrypt` adds a standard security handler whose values match no password,
// so a reader asks for one (FX-PDF-12). The encryption is not real.
export function makePdf({ pages = 1, padTo, encrypt = false } = {}) {
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
    const security = encrypt
      ? ` /Encrypt << /Filter /Standard /V 2 /R 3 /Length 128 /P -4 /O <${'ab'.repeat(32)}> /U <${'cd'.repeat(32)}> >> /ID [<${'01'.repeat(16)}> <${'01'.repeat(16)}>]`
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

// FX-PDF-13.
export const emptyFile = () => Buffer.alloc(0);

// A valid structure with no pages.
export const noPagesPdf = () => makePdf({ pages: 0 });

// It opens, and says it has a page, but the page tree points at an object that is not there.
export const brokenPageTreePdf = () => Buffer.from(makePdf().toString('latin1').replace('/Kids [3 0 R]', '/Kids [9 0 R]'), 'latin1');
