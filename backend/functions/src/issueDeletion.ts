// OP-30 deleteIssue, from API_AND_BACKEND_CONTRACT.md section 5.2 (FR-ADMIN-012, INV-14, INV-15, GS-Q45, DEC-033),
// and the deleted-issue record that OP-03 lists (MOD13-P1-T05, DATABASE_AND_DATA_MODEL.md section 4.22).
// PROVISIONAL: whether an issue may be deleted at all is OQ-21, so the panel has no delete control yet; the
// server operation is built on the working position of GS-Q45. Kept copies on devices: OQ-11.
//
// One transaction deletes the issue and writes the deleted-issue record, which holds the identifier and the time
// only: no title, no content and no admin identity (M9, M11). The identifier is never reused (INV-14). Afterwards
// the file records, the stored files, the cover and the upload jobs are removed; a part that fails is left for the
// cleanup task (`removeIssueRemains`), and the deletion stands. Readers' bookmarks and favourites of the issue are
// removed by the orphan cleanup (DM section 10.3), which is not built. No audit record is written (GS-Q44).
import { FieldValue } from 'firebase-admin/firestore';
import type { Firestore } from 'firebase-admin/firestore';
import { getStorage } from 'firebase-admin/storage';
import * as logger from 'firebase-functions/logger';
import { HttpsError } from 'firebase-functions/v2/https';
import { adminCall } from './adminCall.js';
import { gone, invalidArgument, notFound } from './errors.js';
import { holdingPath } from './uploads.js';
import { derivedId, isDocumentId, isNonEmptyText, unknownFields } from './validation.js';

type Bucket = ReturnType<ReturnType<typeof getStorage>['bucket']>;

export interface DeletionBackend {
  db: Firestore;
  bucket: Bucket;
}

const FIELDS = new Set(['request_id', 'issue_id', 'confirmation']);

export const notUnpublished = () =>
  new HttpsError('failed-precondition', 'Unpublish the issue before deleting it.', { reason: 'NOT_UNPUBLISHED' });

export const confirmationMismatch = () =>
  new HttpsError('failed-precondition', 'The confirmation does not match the issue title.', { reason: 'CONFIRMATION_MISMATCH' });

// The proposal: the admin types the issue's title. Spaces at the ends do not count; the case does.
export const confirms = (typed: unknown, title: unknown): boolean =>
  typeof typed === 'string' && typeof title === 'string' && title.trim().length > 0 && typed.trim() === title.trim();

// Everything an issue leaves once its record is gone. Safe to run again: each part removes only what is there.
export async function removeIssueRemains({ db, bucket }: DeletionBackend, issueId: string): Promise<void> {
  const files = await db.collection('issues').doc(issueId).collection('files').get();
  const jobs = await db.collection('upload_jobs').where('issue_id', '==', issueId).get();

  const paths = new Set<string>();
  for (const file of files.docs) {
    const path: unknown = file.get('storage_path');
    if (typeof path === 'string' && path.length > 0) paths.add(path);
  }
  for (const job of jobs.docs) paths.add(holdingPath(job.id));
  await Promise.all([...paths].map((path) => bucket.file(path).delete({ ignoreNotFound: true })));
  await bucket.deleteFiles({ prefix: `issues/${issueId}/` });
  await bucket.deleteFiles({ prefix: `covers/${issueId}/` });

  const writer = db.bulkWriter();
  for (const doc of [...files.docs, ...jobs.docs]) void writer.delete(doc.ref);
  await writer.close();
}

export async function deleteIssueAs(backend: DeletionBackend, uid: string, data: Record<string, unknown>) {
  const { db } = backend;
  const invalid = unknownFields(data, FIELDS);
  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');
  if (!isDocumentId(data.issue_id)) invalid.push('issue_id');
  if (typeof data.confirmation !== 'string') invalid.push('confirmation');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  const issueId = data.issue_id as string;
  const issueRef = db.collection('issues').doc(issueId);
  const deletedRef = db.collection('deleted_issues').doc(issueId);
  // A server-only note of the request, so that a repeat returns the first result. It is not on the public
  // deleted-issue record, which holds no admin identity.
  const requestRef = db.collection('issue_deletion_requests').doc(derivedId('delete-issue', uid, data.request_id as string));

  const repeat = await db.runTransaction(async (tx) => {
    const [request, issue, deleted] = await tx.getAll(requestRef, issueRef, deletedRef);
    if (request.exists) return true;
    if (!issue.exists) throw deleted.exists ? gone() : notFound();
    if (issue.get('publication_state') !== 'unpublished') throw notUnpublished();
    if (!confirms(data.confirmation, issue.get('title'))) throw confirmationMismatch();

    const now = FieldValue.serverTimestamp();
    tx.delete(issueRef);
    tx.create(deletedRef, { issue_id: issueId, deleted_at: now });
    tx.create(requestRef, { issue_id: issueId, created_at: now });
    return false;
  });

  if (!repeat) {
    try {
      await removeIssueRemains(backend, issueId);
    } catch {
      // The deletion stands; the remains are removed by the next run of the cleanup task.
      logger.error('deleteIssue: the remains of a deleted issue could not all be removed');
    }
  }
  return { issue_id: issueId, deleted: true };
}

export const deleteIssue = adminCall('deleteIssue', ({ uid, db, data }) => deleteIssueAs({ db, bucket: getStorage().bucket() }, uid, data));
