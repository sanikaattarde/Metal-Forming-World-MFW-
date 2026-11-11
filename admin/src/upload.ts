// Sends one PDF to the upload address OP-19 gave (MOD12-P2-T02, FR-ADMIN-005 to FR-ADMIN-007, DEC-020). The
// address is a V4 signed resumable-upload URL for the holding area: a POST with the given headers opens an
// upload session, and the file goes to the session address in pieces, so a break in the connection resumes
// from the last byte the store holds instead of starting again (FR-ADMIN-007). The session address is a
// credential and stays in memory. OP-40 then checks the file on the server.
//
// The protocol is the documented one for resumable uploads to Cloud Storage (a 308 reply with a Range header
// while incomplete). It is NOT VERIFIED against a real bucket: the emulators cannot sign, and the bucket's CORS
// setting, which must let the panel send Content-Range and read Location and Range, comes with ENV-TEST.

export interface UploadAddress {
  upload_url: string;
  upload_headers: Record<string, string>;
}

export type FetchFn = (input: string, init: RequestInit) => Promise<Response>;

// PLACEHOLDERS. No document sets these. A piece is a multiple of 256 KiB, as the store requires.
export const PLACEHOLDER_CHUNK_BYTES = 8 * 1024 * 1024;
export const PLACEHOLDER_MAX_RESUMES = 5;

// Why an upload stopped. Only the kind, never an address.
export class UploadError extends Error {
  constructor(readonly kind: 'start' | 'refused' | 'broken') {
    super(`the upload stopped: ${kind}`);
    this.name = 'UploadError';
  }
}

const isDone = (status: number) => status === 200 || status === 201;

// "bytes=0-1048575" holds the last byte the store has; no header means it has none.
function nextOffset(response: Response): number {
  const range = response.headers.get('range');
  const match = range ? /^bytes=0-(\d+)$/.exec(range.trim()) : null;
  return match ? Number(match[1]) + 1 : 0;
}

export async function resumableUpload(
  fetchFn: FetchFn,
  address: UploadAddress,
  file: Blob,
  onProgress: (sentBytes: number) => void = () => undefined,
  { chunkBytes = PLACEHOLDER_CHUNK_BYTES, maxResumes = PLACEHOLDER_MAX_RESUMES } = {},
): Promise<void> {
  let start: Response;
  try {
    start = await fetchFn(address.upload_url, { method: 'POST', headers: address.upload_headers, credentials: 'omit' });
  } catch {
    throw new UploadError('start');
  }
  const session = start.headers.get('location');
  if (!isDone(start.status) || !session) throw new UploadError('start');

  const size = file.size;
  let offset = 0;
  let resumes = 0;

  // After a break: ask the store how much it holds.
  const resume = async (): Promise<boolean> => {
    if (resumes >= maxResumes) throw new UploadError('broken');
    resumes += 1;
    let status: Response;
    try {
      status = await fetchFn(session, { method: 'PUT', headers: { 'content-range': `bytes */${size}` }, credentials: 'omit' });
    } catch {
      return resume();
    }
    if (isDone(status.status)) return true;
    if (status.status !== 308) throw new UploadError(status.status >= 500 ? 'broken' : 'refused');
    offset = nextOffset(status);
    return false;
  };

  for (;;) {
    const end = Math.min(offset + chunkBytes, size);
    let reply: Response | null = null;
    try {
      reply = await fetchFn(session, {
        method: 'PUT',
        headers: { 'content-range': size === 0 ? 'bytes */0' : `bytes ${offset}-${end - 1}/${size}` },
        body: file.slice(offset, end),
        credentials: 'omit',
      });
    } catch {
      reply = null;
    }

    if (reply && isDone(reply.status)) {
      onProgress(size);
      return;
    }
    if (reply && reply.status === 308) {
      offset = nextOffset(reply);
      onProgress(offset);
      continue;
    }
    if (reply && reply.status >= 400 && reply.status < 500) throw new UploadError('refused');
    // A lost connection or a server error: resume from what the store holds.
    if (await resume()) {
      onProgress(size);
      return;
    }
    onProgress(offset);
  }
}
