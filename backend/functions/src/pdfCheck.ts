// The genuine-PDF check for OP-40 (FR-ADMIN-006, NFR-SEC-008). A file passes only if
// it starts with the PDF header, ends with the end-of-file marker, and pdf.js opens it and loads every page.
// The name and the declared type count for nothing. pdf.js parses untrusted bytes here
// (SYSTEM_ARCHITECTURE.md T8). Version 6 has no code-evaluation path to switch off (its build has no `eval`
// or `new Function`, checked for spike note 09), and font loading is off.

const HEADER = Buffer.from('%PDF-', 'latin1');
const END = Buffer.from('%%EOF', 'latin1');
// A writer may put a line ending or a few stray bytes after the marker. The window is PROPOSED.
const END_WINDOW = 1024;

export type PdfVerdict = { ok: true; pageCount: number } | { ok: false; why: string };

export async function inspectPdf(file: Buffer): Promise<PdfVerdict> {
  if (!file.subarray(0, HEADER.length).equals(HEADER)) return { ok: false, why: 'no PDF header' };
  if (!file.subarray(Math.max(0, file.length - END_WINDOW)).includes(END)) return { ok: false, why: 'no end-of-file marker' };

  // Loaded here, so that the other functions do not load the parser.
  const { getDocument } = await import('pdfjs-dist/legacy/build/pdf.mjs');
  const task = getDocument({
    data: new Uint8Array(file), // a copy: pdf.js takes over the array it is given
    disableFontFace: true,
    useSystemFonts: false,
    stopAtErrors: true,
    verbosity: 0,
  });
  try {
    const document = await task.promise;
    if (document.numPages < 1) return { ok: false, why: 'no pages' };
    for (let page = 1; page <= document.numPages; page += 1) await document.getPage(page);
    return { ok: true, pageCount: document.numPages };
  } catch (error) {
    // A password-protected file lands here. Whether one is refused at upload is OQ-30 (spike note 09).
    return { ok: false, why: error instanceof Error ? error.name : 'unreadable' };
  } finally {
    await task.destroy();
  }
}
