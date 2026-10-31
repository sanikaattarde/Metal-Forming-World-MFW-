// SPIKE (DEC-003 OPEN, DEC-026 PROPOSED). OP-15 listIssuesForAdmin, OP-16 saveIssue, OP-21 publishIssue
// and OP-22 unpublishIssue, from API_AND_BACKEND_CONTRACT.md section 5.1. The input and output shapes,
// and the form of the cursor, are spike choices.
import { FieldValue } from 'firebase-admin/firestore';
import type { DocumentSnapshot, Timestamp } from 'firebase-admin/firestore';
import { adminCall } from './adminCall.js';
import { gone, invalidArgument, noAcceptedFile, notFound, staleRecord } from './errors.js';
import { checkIssueInput, sameIssueValues } from './issueChecks.js';
import { derivedId, isDocumentId, isNonEmptyText } from './validation.js';

// PLACEHOLDER. "The largest page size is OPEN" (section 2.6). Not a decided value.
export const PLACEHOLDER_MAX_PAGE_SIZE = 100;

const millis = (value: unknown): number | null =>
  value && typeof (value as Timestamp).toMillis === 'function' ? (value as Timestamp).toMillis() : null;

// A fixed list of fields. A file location is never returned (SC-07), and it is not on the issue anyway.
function issueView(snap: DocumentSnapshot) {
  const get = (name: string) => snap.get(name) ?? null;
  return {
    issue_id: snap.id,
    title: get('title'),
    description: get('description'),
    publication_date: get('publication_date'),
    year: get('year'),
    edition: get('edition'),
    category_id: get('category_id'),
    segment_ids: get('segment_ids') ?? [],
    publication_state: get('publication_state'),
    cover_path: get('cover_path'),
    current_revision: get('current_revision'),
    file_size_bytes: get('file_size_bytes'),
    page_count: get('page_count'),
    published_at: millis(snap.get('published_at')),
    created_at: millis(snap.get('created_at')),
    updated_at: millis(snap.get('updated_at')),
  };
}

export const listIssuesForAdmin = adminCall(async ({ db, data }) => {
  const invalid: string[] = [];

  const state = data.publication_state;
  if (state !== undefined && state !== 'published' && state !== 'unpublished') invalid.push('publication_state');

  const pageSize = data.page_size ?? PLACEHOLDER_MAX_PAGE_SIZE;
  if (!Number.isInteger(pageSize) || (pageSize as number) < 1 || (pageSize as number) > PLACEHOLDER_MAX_PAGE_SIZE) {
    invalid.push('page_size');
  }

  let after: DocumentSnapshot | undefined;
  if (data.cursor !== undefined) {
    const cursor = isDocumentId(data.cursor) ? await db.collection('issues').doc(data.cursor).get() : null;
    if (cursor?.exists) after = cursor;
    else invalid.push('cursor');
  }

  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  // With the filter, this query needs the composite index the data model names (section 4.7).
  let query = db.collection('issues').orderBy('publication_date', 'desc').limit((pageSize as number) + 1);
  if (state !== undefined) query = query.where('publication_state', '==', state);
  if (after) query = query.startAfter(after);

  const { docs } = await query.get();
  const page = docs.slice(0, pageSize as number);
  return {
    items: page.map(issueView),
    next_cursor: docs.length > (pageSize as number) ? page[page.length - 1].id : null,
  };
});

export const saveIssue = adminCall(async ({ uid, db, data }) => {
  const check = checkIssueInput(data);
  if (check.invalid.length > 0) throw invalidArgument(check.invalid);

  const { values, issueId, expectedUpdatedAt, requestId } = check;
  const id = issueId ?? derivedId('issue', uid, requestId);
  const ref = db.collection('issues').doc(id);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (issueId && !snap.exists) throw notFound();

    // An identifier on the deleted-issue list is never reused (INV-14).
    if (!issueId && !snap.exists) {
      const deleted = await tx.get(db.collection('deleted_issues').doc(id));
      if (deleted.exists) throw gone();
    }

    // A server write checks its references inside the transaction (INV-13).
    const [category, ...segments] = await tx.getAll(
      db.collection('categories').doc(values.category_id),
      ...values.segment_ids.map((segmentId) => db.collection('segments').doc(segmentId)),
    );
    const missing: string[] = [];
    if (!category.exists) missing.push('category_id');
    if (segments.some((segment) => !segment.exists)) missing.push('segment_ids');
    if (missing.length > 0) throw invalidArgument(missing);

    const now = FieldValue.serverTimestamp();

    if (!issueId) {
      if (snap.exists) return; // a repeat of the same create
      tx.set(ref, { issue_id: id, ...values, publication_state: 'unpublished', created_at: now, updated_at: now });
      return;
    }

    // A repeat with the same values changes nothing, whatever the screen thought it was editing.
    if (sameIssueValues(values, snap.data() ?? {})) return;

    if (millis(snap.get('updated_at')) !== expectedUpdatedAt) throw staleRecord();

    tx.update(ref, { ...values, edition: values.edition ?? FieldValue.delete(), updated_at: now });
  });

  return issueView(await ref.get());
});

const issueRef = (db: FirebaseFirestore.Firestore, data: Record<string, unknown>) => {
  const invalid: string[] = [];
  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');
  if (!isDocumentId(data.issue_id)) invalid.push('issue_id');
  if (invalid.length > 0) throw invalidArgument(invalid);
  return db.collection('issues').doc(data.issue_id as string);
};

export const publishIssue = adminCall(async ({ db, data }) => {
  const ref = issueRef(db, data);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw notFound();
    if (snap.get('publication_state') === 'published') return; // a repeat changes nothing

    // An issue is published only with an accepted current revision (INV-02).
    const revision: unknown = snap.get('current_revision');
    const file = Number.isInteger(revision) ? await tx.get(ref.collection('files').doc(String(revision))) : null;
    if (!file?.exists || file.get('status') !== 'current') throw noAcceptedFile();

    const missing = ['title', 'description', 'category_id'].filter((name) => !isNonEmptyText(snap.get(name)));
    if (missing.length > 0) throw invalidArgument(missing);

    const now = FieldValue.serverTimestamp();
    tx.update(ref, { publication_state: 'published', published_at: now, updated_at: now });
  });

  return issueView(await ref.get());
});

export const unpublishIssue = adminCall(async ({ db, data }) => {
  const ref = issueRef(db, data);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw notFound();
    if (snap.get('publication_state') === 'unpublished') return; // a repeat changes nothing

    tx.update(ref, { publication_state: 'unpublished', updated_at: FieldValue.serverTimestamp() });
  });

  return issueView(await ref.get());
});
