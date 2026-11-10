// How OP-19 makes a short-lived address for one upload into the holding area (DEC-020 AGREED, TD-09).
// The real issuer signs a V4 resumable-upload URL for the one holding path, as OP-19 asks ("signed,
// resumable, short-lived"), so a 150 MB file can continue after a break (FR-ADMIN-007). The client
// POSTs to it with the headers it was given, which opens an upload session, and sends the file to the
// session address the store returns. That address is a credential, held in memory only.
//
// The store does not limit the size here: OP-19 checks the declared size, and OP-40 checks the real
// size and deletes a file over the limit (SEC-CHK-07). Whether a size-range header works on a
// resumable upload is NOT VERIFIED, so none is signed.
import { randomBytes } from 'node:crypto';
import { onEmulators, openDefaultBucketFile, signLink } from './signedLinks.js';
import type { OpenFile } from './signedLinks.js';

export interface UploadRequest {
  holdingPath: string;
  contentType: string;
  maxBytes: number;
  lifetimeSeconds: number;
}

export interface UploadAddress {
  url: string;
  expiresAtMillis: number;
  headers: Record<string, string>; // the headers the client sends to open the session, and nothing secret
}

export interface UploadUrlIssuer {
  issue(request: UploadRequest): Promise<UploadAddress>;
}

// The storage library adds x-goog-resumable to what it signs for a resumable action, so the client
// must send it too.
const headersFor = ({ contentType }: UploadRequest) => ({
  'content-type': contentType,
  'x-goog-resumable': 'start',
});

export function signedUploadUrlIssuer(open: OpenFile = openDefaultBucketFile, now: () => number = Date.now): UploadUrlIssuer {
  return {
    async issue(request) {
      const link = await signLink(open, request.holdingPath, request.lifetimeSeconds, { action: 'resumable', contentType: request.contentType }, now);
      return { ...link, headers: headersFor(request) };
    },
  };
}

// On the emulators, which cannot sign: an address that cannot resolve (".invalid", RFC 2606) and holds
// no path. The tests put the file in the holding area directly. It refuses to run anywhere else.
export const emulatorUploadUrlIssuer: UploadUrlIssuer = {
  async issue(request) {
    if (!onEmulators()) throw new Error('The emulator upload address runs only on the emulators.');
    return {
      url: `https://upload-emulator.invalid/${randomBytes(32).toString('base64url')}`,
      expiresAtMillis: Date.now() + request.lifetimeSeconds * 1000,
      headers: headersFor(request),
    };
  },
};

export const uploadUrlIssuer = (): UploadUrlIssuer => (onEmulators() ? emulatorUploadUrlIssuer : signedUploadUrlIssuer());
