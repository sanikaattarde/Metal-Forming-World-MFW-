// OP-40 onUploadFinalized, from
// API_AND_BACKEND_CONTRACT.md section 6. It runs for every object that arrives in the bucket and acts only on
// the holding area, so its own copy into the private area is ignored.
import { createHash } from 'node:crypto';
import type { Auth } from 'firebase-admin/auth';
import { getAuth } from 'firebase-admin/auth';
import { FieldValue, getFirestore, Timestamp } from 'firebase-admin/firestore';
import type { Firestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import { onObjectFinalized } from 'firebase-functions/v2/storage';
import { readStanding } from './admin.js';
import { inspectCover } from './coverCheck.js';
import type { CoverDetail } from './coverCheck.js';
import { inspectPdf } from './pdfCheck.js';
import { logOperation } from './safeLog.js';
import { readCoverRules, readUploadLimit } from './uploads.js';
import { isDocumentId } from './validation.js';

const OPERATION = 'onUploadFinalized';

// The contract's reasons. ISSUE_NOT_FOUND is added (spike note 09). PDF_PROTECTED is added for a PDF that
// needs a password to open (OQ-30 working position of 14 November 2026, PROVISIONAL): readers could not
// open it. A PDF that only limits printing or copying opens without a password, so it is accepted.
export type Rejection = 'NOT_A_PDF' | 'PDF_PROTECTED' | 'OVER_LIMIT' | 'UPLOADER_NOT_AUTHORISED' | 'ISSUE_NOT_FOUND' | 'COVER_INVALID';

// The cover area (DATABASE_AND_DATA_MODEL.md section 8). The job is the version, so each cover has a new,
// unguessable address and an app never shows an old copy it kept (AOQ-20).
export const coverPath = (issueId: string, jobId: string) => `covers/${issueId}/${jobId}`;

type Bucket = ReturnType<ReturnType<typeof getStorage>['bucket']>;

// Passed in, so that a test can make a step fail.
export interface UploadBackend {
  db: Firestore;
  auth: Auth;
  bucket: Bucket;
}

export interface UploadedObject {
  name: string;
  size: number;
  timeCreated?: string;
}

export interface Outcome {
  outcome: 'IGNORED' | 'NO_PENDING_JOB' | 'ACCEPTED' | Rejection;
  uploader?: string;
}

export async function finalizeUpload({ db, auth, bucket }: UploadBackend, object: UploadedObject): Promise<Outcome> {
  const parts = object.name.split('/');
  if (parts[0] !== 'holding') return { outcome: 'IGNORED' };

  const file = bucket.file(object.name);
  const jobRef = parts.length === 2 && isDocumentId(parts[1]) ? db.collection('upload_jobs').doc(parts[1]) : null;
  const job = jobRef === null ? null : await jobRef.get();

  // An object with no pending job came round the interface (SEC-CHK-07), or is a second upload to an address
  // already used. It is removed, and nothing else changes.
  if (jobRef === null || !job?.exists || job.get('status') !== 'pending') {
    await file.delete({ ignoreNotFound: true });
    return { outcome: 'NO_PENDING_JOB' };
  }

  const uploader: unknown = job.get('requested_by');
  const reject = async (reason: Rejection, detail?: CoverDetail): Promise<Outcome> => {
    await file.delete({ ignoreNotFound: true });
    await db.runTransaction(async (tx) => {
      // A job moves on from pending once, and not back (DATABASE_AND_DATA_MODEL.md section 4.19).
      if ((await tx.get(jobRef)).get('status') !== 'pending') return;
      tx.update(jobRef, { status: 'rejected', reason, ...(detail ? { detail } : {}), finished_at: FieldValue.serverTimestamp() });
    });
    return { outcome: reason, uploader: uploader as string };
  };

  // 1. The uploader's role and account, read again now (INV-08).
  const standing = isDocumentId(uploader) ? await readStanding({ db, auth }, uploader) : null;
  if (!standing || standing.accountClosed || !standing.roleActive || !standing.emailVerified) return reject('UPLOADER_NOT_AUTHORISED');

  if (job.get('kind') === 'cover') return acceptCover({ db, bucket }, object, jobRef, job.get('issue_id') as string, reject, uploader as string);

  // 2. The size the store reports, then the bytes themselves. The name and the declared type count for nothing.
  const limit = await readUploadLimit(db);
  if (!(object.size <= limit)) return reject('OVER_LIMIT');
  const [content] = await file.download();
  if (content.length > limit) return reject('OVER_LIMIT');
  const verdict = await inspectPdf(content);
  if (!verdict.ok) return reject(verdict.why === 'PasswordException' ? 'PDF_PROTECTED' : 'NOT_A_PDF');

  const issueRef = db.collection('issues').doc(job.get('issue_id') as string);
  const issue = await issueRef.get();
  if (!issue.exists) return reject('ISSUE_NOT_FOUND');

  // A new revision follows the highest one recorded.
  const previous: unknown = issue.get('current_revision');
  const latest = await issueRef.collection('files').orderBy('revision', 'desc').limit(1).get();
  const revision = (latest.empty ? 0 : (latest.docs[0].get('revision') as number)) + 1;
  // The job is part of the path, so two uploads that pick the same revision never write to the same object,
  // and a record's checksum is always its own file's. This differs from the provisional pattern
  // issues/{issue_id}/{revision}.pdf (DATABASE_AND_DATA_MODEL.md section 8; spike note 09).
  const storagePath = `issues/${issueRef.id}/${revision}-${jobRef.id}.pdf`;

  // 3. Into the private area, then out of the holding area. The current revision stays until step 4 (GS-Q45).
  // The copy also refuses to replace an object, for a repeated event. The emulator ignores that condition,
  // so it is NOT VERIFIED here.
  await file.copy(bucket.file(storagePath), { preconditionOpts: { ifGenerationMatch: 0 } });
  await file.delete();

  // 4. One transaction (INV-01). If it fails, the copy is an orphan that the cleanup removes (OP-41).
  const fileRef = issueRef.collection('files').doc(String(revision));
  const oldRef = Number.isInteger(previous) ? issueRef.collection('files').doc(String(previous)) : null;
  await db.runTransaction(async (tx) => {
    const [jobNow, issueNow, slot, old] = await Promise.all([
      tx.get(jobRef),
      tx.get(issueRef),
      tx.get(fileRef),
      oldRef === null ? Promise.resolve(null) : tx.get(oldRef),
    ]);
    if (jobNow.get('status') !== 'pending' || !issueNow.exists || issueNow.get('current_revision') !== previous || slot.exists) {
      throw new Error('the job or the issue changed while the file was checked');
    }

    const now = FieldValue.serverTimestamp();
    if (old?.exists && old.get('status') === 'current') tx.update(old.ref, { status: 'superseded' });
    tx.create(fileRef, {
      issue_id: issueRef.id,
      revision,
      storage_path: storagePath,
      size_bytes: content.length,
      page_count: verdict.pageCount,
      checksum_sha256: createHash('sha256').update(content).digest('hex'),
      status: 'current',
      uploaded_by: uploader,
      uploaded_at: object.timeCreated ? Timestamp.fromDate(new Date(object.timeCreated)) : now,
      accepted_at: now,
    });
    tx.update(issueRef, { current_revision: revision, file_size_bytes: content.length, page_count: verdict.pageCount });
    tx.update(jobRef, { status: 'accepted', revision, finished_at: now });
  });

  return { outcome: 'ACCEPTED', uploader: uploader as string };
}

// A cover, after the uploader's standing is checked (OP-40 step 2, "a cover goes through its own checks").
// Only the re-encoded copy is stored, never the uploaded bytes. The issue points to it in one transaction,
// and the cover it replaces is then deleted. If that deletion fails, the old cover is an orphan for the
// cleanup (OP-41); if the transaction fails, the new one is.
async function acceptCover(
  { db, bucket }: Pick<UploadBackend, 'db' | 'bucket'>,
  object: UploadedObject,
  jobRef: FirebaseFirestore.DocumentReference,
  issueId: string,
  reject: (reason: Rejection, detail?: CoverDetail) => Promise<Outcome>,
  uploader: string,
): Promise<Outcome> {
  const file = bucket.file(object.name);
  const rules = await readCoverRules(db);
  if (!(object.size <= rules.maxBytes)) return reject('OVER_LIMIT');
  const [content] = await file.download();
  if (content.length > rules.maxBytes) return reject('OVER_LIMIT');
  const verdict = await inspectCover(content, rules);
  if (!verdict.ok) return reject('COVER_INVALID', verdict.detail);

  const issueRef = db.collection('issues').doc(issueId);
  if (!(await issueRef.get()).exists) return reject('ISSUE_NOT_FOUND');

  const path = coverPath(issueRef.id, jobRef.id);
  // Each address is used once, so the copy may be kept by any cache for a long time. The value is PROPOSED.
  await bucket.file(path).save(verdict.jpeg, {
    resumable: false,
    contentType: 'image/jpeg',
    metadata: { cacheControl: 'public, max-age=31536000, immutable' },
    preconditionOpts: { ifGenerationMatch: 0 },
  });
  await file.delete();

  const previous = await db.runTransaction(async (tx) => {
    const [jobNow, issueNow] = await Promise.all([tx.get(jobRef), tx.get(issueRef)]);
    if (jobNow.get('status') !== 'pending' || !issueNow.exists) throw new Error('the job or the issue changed while the cover was checked');
    const old: unknown = issueNow.get('cover_path');
    const now = FieldValue.serverTimestamp();
    tx.update(issueRef, { cover_path: path });
    tx.update(jobRef, { status: 'accepted', finished_at: now });
    return old;
  });

  // Only a cover of this issue is ever deleted here.
  if (typeof previous === 'string' && previous !== path && previous.startsWith(`covers/${issueRef.id}/`)) {
    await bucket.file(previous).delete({ ignoreNotFound: true }).catch(() => undefined);
  }
  return { outcome: 'ACCEPTED', uploader };
}

export const onUploadFinalized = onObjectFinalized(async (event) => {
  const created = event.data.timeCreated;
  const object = {
    name: event.data.name,
    size: Number(event.data.size),
    timeCreated: created instanceof Date ? created.toISOString() : created,
  };
  try {
    const { outcome, uploader } = await finalizeUpload(
      { db: getFirestore(), auth: getAuth(), bucket: getStorage().bucket(event.data.bucket) },
      object,
    );
    if (outcome !== 'IGNORED') logOperation({ operation: OPERATION, caller: uploader ?? 'none', outcome });
  } catch (error) {
    // The job stays pending and the cleanup expires it (OP-41). Nothing from the error is logged (SC-16).
    logOperation({ operation: OPERATION, outcome: 'internal' });
    throw error;
  }
});
