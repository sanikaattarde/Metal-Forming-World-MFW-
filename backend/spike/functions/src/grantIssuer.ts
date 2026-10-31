// SPIKE (DEC-020 OPEN, OQ-37 OPEN). What OP-11 asks of whatever makes the link to a file. The real issuer
// is not built, because how a file is delivered is not decided. This stub proves nothing about signed
// links: another reader's grant, an expired grant and resuming a download all need a real one.
import { randomBytes } from 'node:crypto';

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

// The address cannot resolve (".invalid", RFC 2606) and opens nothing. It refuses to run outside the
// emulators, so a deployment of this code releases no link at all rather than a link that looks real.
export const stubGrantIssuer: GrantIssuer = {
  async issue({ lifetimeSeconds }) {
    if (process.env.FUNCTIONS_EMULATOR !== 'true') {
      throw new Error('No grant issuer is built (DEC-020). The stub runs only on the emulators.');
    }
    return {
      url: `https://grant-stub.invalid/${randomBytes(32).toString('base64url')}`,
      expiresAtMillis: Date.now() + lifetimeSeconds * 1000,
    };
  },
};
