// The real link issuers of DEC-020 (AGREED, TD-09): V4 signed URLs from Cloud Storage, made by a
// function after its own checks. A signed URL is a bearer link, so it is short-lived, it is never
// logged or stored (SC-16), and its lifetime has a ceiling here (SEC-CHK-03).
//
// Signing needs the functions' service account to hold the Service Account Token Creator role and
// the IAM Credentials API (TD-09, VS-08), which MFW grants when ENV-TEST is set up (MOD14-P2-T01).
// The emulators have no key to sign with, so on the emulators the emulator issuers are used instead,
// and these are tested with a fake file (U6). Range requests and resume on a signed URL are the
// TD-09 proof plan on real devices (AR-01, AOQ-07), not shown here.
import { getStorage } from 'firebase-admin/storage';

// The working assumption of AOQ-07 (60 minutes) as a ceiling, so that a wrong setting cannot make a
// long-lived link. The lifetime itself is configuration (CFG-06, OQ-37).
export const MAX_LINK_LIFETIME_SECONDS = 3600;

export const isUsableLifetime = (seconds: unknown): seconds is number =>
  Number.isInteger(seconds) && (seconds as number) >= 1 && (seconds as number) <= MAX_LINK_LIFETIME_SECONDS;

// The part of a Cloud Storage file that signs a link. Passed in, so a test needs no bucket.
export interface SignRequest {
  version: 'v4';
  action: 'read' | 'resumable';
  expires: number;
  contentType?: string;
  extensionHeaders?: Record<string, string>;
}

export interface SignableFile {
  getSignedUrl(request: SignRequest): Promise<[string]>;
}

export type OpenFile = (path: string) => SignableFile;

// The default bucket, the one the upload trigger listens on.
export const openDefaultBucketFile: OpenFile = (path) => getStorage().bucket().file(path);

export interface SignedLink {
  url: string;
  expiresAtMillis: number;
}

export async function signLink(
  open: OpenFile,
  path: string,
  lifetimeSeconds: number,
  options: { action: 'read' } | { action: 'resumable'; contentType: string },
  now: () => number = Date.now,
): Promise<SignedLink> {
  if (!isUsableLifetime(lifetimeSeconds)) {
    throw new Error(`A link lifetime must be a whole number of seconds from 1 to ${MAX_LINK_LIFETIME_SECONDS}.`);
  }
  const expiresAtMillis = now() + lifetimeSeconds * 1000;
  const [url] = await open(path).getSignedUrl({ version: 'v4', expires: expiresAtMillis, ...options });
  return { url, expiresAtMillis };
}

export const onEmulators = () => process.env.FUNCTIONS_EMULATOR === 'true';
