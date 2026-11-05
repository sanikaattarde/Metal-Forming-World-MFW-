// SPIKE (DEC-020 OPEN). How OP-19 makes a short-lived address for one upload into the holding area. The
// real issuer, a signed resumable upload URL, is not built: whether the emulator honours a signed URL is
// NOT VERIFIED (storage.rules). The stub releases nothing outside the emulators.
import { randomBytes } from 'node:crypto';

export interface UploadRequest {
  holdingPath: string;
  contentType: string;
  maxBytes: number;
  lifetimeSeconds: number;
}

export interface UploadAddress {
  url: string;
  expiresAtMillis: number;
}

export interface UploadUrlIssuer {
  issue(request: UploadRequest): Promise<UploadAddress>;
}

// An address that cannot resolve and holds no path. The tests put the file in the holding area directly.
export const stubUploadUrlIssuer: UploadUrlIssuer = {
  async issue({ lifetimeSeconds }) {
    if (process.env.FUNCTIONS_EMULATOR !== 'true') {
      throw new Error('No upload URL issuer is built (DEC-020). The stub runs only on the emulators.');
    }
    return {
      url: `https://upload-stub.invalid/${randomBytes(32).toString('base64url')}`,
      expiresAtMillis: Date.now() + lifetimeSeconds * 1000,
    };
  },
};
