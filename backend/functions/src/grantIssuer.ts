// What OP-11 asks of whatever makes the link to a file (DEC-020 AGREED, TD-09). Deployed, it is a V4
// signed read URL for the current revision, made after the checks pass. Its lifetime is configuration
// (CFG-06, OQ-37) under the ceiling in signedLinks.ts.
import { randomBytes } from 'node:crypto';
import { onEmulators, openDefaultBucketFile, signLink } from './signedLinks.js';
import type { OpenFile } from './signedLinks.js';

export interface LinkRequest {
  storagePath: string; // never sent to a client (DATABASE_AND_DATA_MODEL.md section 9)
  lifetimeSeconds: number;
}

export interface IssuedLink {
  url: string;
  expiresAtMillis: number;
}

export interface GrantIssuer {
  issue(request: LinkRequest): Promise<IssuedLink>;
}

export function signedGrantIssuer(open: OpenFile = openDefaultBucketFile, now: () => number = Date.now): GrantIssuer {
  return {
    issue: ({ storagePath, lifetimeSeconds }) => signLink(open, storagePath, lifetimeSeconds, { action: 'read' }, now),
  };
}

// On the emulators, which cannot sign: an address that cannot resolve (".invalid", RFC 2606) and opens
// nothing. It refuses to run anywhere else, so a deployment can never hand out a link that looks real.
export const emulatorGrantIssuer: GrantIssuer = {
  async issue({ lifetimeSeconds }) {
    if (!onEmulators()) throw new Error('The emulator grant issuer runs only on the emulators.');
    return {
      url: `https://grant-emulator.invalid/${randomBytes(32).toString('base64url')}`,
      expiresAtMillis: Date.now() + lifetimeSeconds * 1000,
    };
  },
};

export const grantIssuer = (): GrantIssuer => (onEmulators() ? emulatorGrantIssuer : signedGrantIssuer());
