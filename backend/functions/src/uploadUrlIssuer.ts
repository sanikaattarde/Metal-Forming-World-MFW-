// How OP-19 makes a short-lived address for one upload into the holding area (DEC-020 AGREED, TD-09).
// The real issuer signs a V4 PUT URL for the one holding path. The client must send the content type
// and the size range it was given, so the store itself refuses another type or a file over the limit;
// OP-40 checks the file again when it lands (SEC-CHK-07).
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
  headers: Record<string, string>; // the headers the client sends with the upload, and nothing secret
}

export interface UploadUrlIssuer {
  issue(request: UploadRequest): Promise<UploadAddress>;
}

const headersFor = ({ contentType, maxBytes }: UploadRequest) => ({
  'content-type': contentType,
  'x-goog-content-length-range': `1,${maxBytes}`,
});

export function signedUploadUrlIssuer(open: OpenFile = openDefaultBucketFile, now: () => number = Date.now): UploadUrlIssuer {
  return {
    async issue(request) {
      const headers = headersFor(request);
      const link = await signLink(
        open,
        request.holdingPath,
        request.lifetimeSeconds,
        {
          action: 'write',
          contentType: request.contentType,
          extensionHeaders: { 'x-goog-content-length-range': headers['x-goog-content-length-range'] },
        },
        now,
      );
      return { ...link, headers };
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
