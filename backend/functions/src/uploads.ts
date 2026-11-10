// OP-19 requestUpload and OP-20 listUploadJobs, from
// API_AND_BACKEND_CONTRACT.md section 5.1. The backend half of T-09.2, which stays held as a feature.
// PDFs only: a cover waits for OQ-22. RATE_LIMITED is not built (MOD13-P1-T07).
import { FieldValue } from 'firebase-admin/firestore';
import type { DocumentSnapshot, Firestore } from 'firebase-admin/firestore';
import { adminCall } from './adminCall.js';
import { invalidArgument, notFound } from './errors.js';
import { uploadUrlIssuer } from './uploadUrlIssuer.js';
import { derivedId, isDocumentId, isNonEmptyText, unknownFields } from './validation.js';

export const PDF_CONTENT_TYPE = 'application/pdf';

// PLACEHOLDER. OP-19 says only "short-lived". Not a decided value.
export const PLACEHOLDER_UPLOAD_URL_LIFETIME_SECONDS = 900;

// PLACEHOLDER. No document sets how many jobs one list returns. Not a decided value.
export const PLACEHOLDER_MAX_JOBS_LISTED = 50;

const REQUEST_FIELDS = new Set(['request_id', 'kind', 'issue_id', 'declared_size_bytes', 'content_type']);
const LIST_FIELDS = new Set(['issue_id', 'job_id']);

export const holdingPath = (jobId: string) => `holding/${jobId}`;

// The upload limit (CFG-05). There is no default here: "150 MB by default" leaves the unit and the
// boundary to OQ-30, so a missing or unusable setting refuses the upload (SC-03).
export async function readUploadLimit(db: Firestore): Promise<number> {
  const limit: unknown = (await db.doc('config/private').get()).get('max_upload_bytes');
  if (!Number.isInteger(limit) || (limit as number) < 1) throw new Error('max_upload_bytes is missing or malformed');
  return limit as number;
}

const millis = (snap: DocumentSnapshot, name: string) => {
  const value: unknown = snap.get(name);
  return value instanceof Object && 'toMillis' in value ? (value as FirebaseFirestore.Timestamp).toMillis() : null;
};

// What an admin sees of a job. The uploader's identifier is not shown.
const jobView = (snap: DocumentSnapshot) => ({
  job_id: snap.id,
  kind: snap.get('kind'),
  issue_id: snap.get('issue_id'),
  declared_size_bytes: snap.get('declared_size_bytes'),
  status: snap.get('status'),
  reason: snap.get('reason') ?? null,
  revision: snap.get('revision') ?? null,
  created_at: millis(snap, 'created_at'),
  finished_at: millis(snap, 'finished_at'),
});

export const requestUpload = adminCall('requestUpload', async ({ uid, db, data }) => {
  const invalid = unknownFields(data, REQUEST_FIELDS);
  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');
  if (data.kind !== 'pdf') invalid.push('kind'); // a cover waits for OQ-22
  if (!isDocumentId(data.issue_id)) invalid.push('issue_id');
  if (!Number.isInteger(data.declared_size_bytes) || (data.declared_size_bytes as number) < 1) invalid.push('declared_size_bytes');
  if (data.content_type !== PDF_CONTENT_TYPE) invalid.push('content_type');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  const limit = await readUploadLimit(db);
  if ((data.declared_size_bytes as number) > limit) throw invalidArgument(['declared_size_bytes']);

  const jobRef = db.collection('upload_jobs').doc(derivedId('upload', uid, data.request_id as string));
  const issueRef = db.collection('issues').doc(data.issue_id as string);

  await db.runTransaction(async (tx) => {
    // A repeat returns the job it made the first time, as stored, whatever the repeat asks.
    if ((await tx.get(jobRef)).exists) return;
    if (!(await tx.get(issueRef)).exists) throw notFound();
    tx.create(jobRef, {
      job_id: jobRef.id,
      kind: 'pdf',
      issue_id: issueRef.id,
      requested_by: uid,
      declared_size_bytes: data.declared_size_bytes,
      status: 'pending',
      created_at: FieldValue.serverTimestamp(),
    });
  });

  // A finished job gets no new address: the file it took, or refused, is already decided.
  const job = await jobRef.get();
  if (job.get('status') !== 'pending') return { job_id: job.id, status: job.get('status') };

  const address = await uploadUrlIssuer().issue({
    holdingPath: holdingPath(job.id),
    contentType: PDF_CONTENT_TYPE,
    maxBytes: limit,
    lifetimeSeconds: PLACEHOLDER_UPLOAD_URL_LIFETIME_SECONDS,
  });
  return { job_id: job.id, upload_url: address.url, upload_headers: address.headers, expires_at: address.expiresAtMillis };
});

export const listUploadJobs = adminCall('listUploadJobs', async ({ db, data }) => {
  const invalid = unknownFields(data, LIST_FIELDS);
  const byIssue = data.issue_id !== undefined;
  const byJob = data.job_id !== undefined;
  if (byIssue === byJob) invalid.push('issue_id', 'job_id'); // exactly one of them
  else if (byIssue && !isDocumentId(data.issue_id)) invalid.push('issue_id');
  else if (byJob && !isDocumentId(data.job_id)) invalid.push('job_id');
  if (invalid.length > 0) throw invalidArgument([...new Set(invalid)].sort());

  if (byJob) {
    const job = await db.collection('upload_jobs').doc(data.job_id as string).get();
    return { jobs: job.exists ? [jobView(job)] : [] };
  }

  // The (issue_id, created_at) index of DATABASE_AND_DATA_MODEL.md section 4.19. The emulator does not
  // need it, so a missing index would not show here (D-4).
  const jobs = await db
    .collection('upload_jobs')
    .where('issue_id', '==', data.issue_id)
    .orderBy('created_at', 'desc')
    .limit(PLACEHOLDER_MAX_JOBS_LISTED)
    .get();
  return { jobs: jobs.docs.map(jobView) };
});
