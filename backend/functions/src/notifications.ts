// OP-25 sendNotification, OP-26 retryNotification and OP-27 listNotificationSends, from
// API_AND_BACKEND_CONTRACT.md section 5.1 (FR-ADMIN-015 to FR-ADMIN-018, DATA-008, INV-17, GS-Q27). The server
// part of T-10.3 (MOD11-P2-T03). The send record's fields wait for OQ-19, so the list below is PROVISIONAL; the
// record-first order and the states are PROPOSED (GS-Q27). Push is not set up in MFW's accounts (MOD11-P2-T01).
//
// The order of a send: check the category and the link target; write the record as pending; send to the
// category's topic; mark the record accepted or failed. Nothing retries on its own. A record left pending past
// the window counts as unknown, which an admin may retry (DATABASE_AND_DATA_MODEL.md section 4.14).
import { FieldValue, Timestamp } from 'firebase-admin/firestore';
import type { DocumentReference, DocumentSnapshot, Firestore } from 'firebase-admin/firestore';
import { adminCall } from './adminCall.js';
import {
  attemptInProgress,
  cannotVerify,
  invalidArgument,
  notFound,
  notRetryable,
  pushFailed,
  siteUnavailable,
  targetNotAvailable,
} from './errors.js';
import { PLACEHOLDER_MAX_PAGE_SIZE } from './issues.js';
import { pushSender, topicFor } from './pushSender.js';
import { logOperation } from './safeLog.js';
import { derivedId, isDocumentId, isNonEmptyText, unknownFields } from './validation.js';
import { postExists, readSiteBase, SiteError } from './wordpress.js';

// PLACEHOLDERS. No document sets these. They are not decided values.
export const PLACEHOLDER_MAX_TITLE_LENGTH = 100;
export const PLACEHOLDER_MAX_BODY_LENGTH = 400;
// How long an attempt may stay pending before it counts as unknown ("the configured time", section 4.14).
export const PLACEHOLDER_PENDING_WINDOW_MS = 10 * 60 * 1000;

export const TARGET_TYPES = ['issue', 'news_post', 'none'] as const;
export const OUTCOMES = ['pending', 'accepted', 'failed', 'unknown'] as const;
type Outcome = (typeof OUTCOMES)[number];

const SEND_FIELDS = new Set(['request_id', 'category_id', 'title', 'body', 'target_type', 'target_ref']);
const RETRY_FIELDS = new Set(['request_id', 'send_id']);
const LIST_FIELDS = new Set(['outcome', 'page_size', 'cursor']);
const POST_NUMBER = /^[1-9]\d{0,11}$/;

const sends = (db: Firestore) => db.collection('notification_sends');

const millis = (value: unknown): number | null => (value instanceof Timestamp ? value.toMillis() : null);

// A pending attempt older than the window never reported back, so it is unknown (INV-17).
function outcomeOf(snap: DocumentSnapshot, now: number): Outcome {
  const outcome = snap.get('outcome') as Outcome;
  const started = millis(snap.get('last_attempt_at'));
  if (outcome === 'pending' && started !== null && now - started > PLACEHOLDER_PENDING_WINDOW_MS) return 'unknown';
  return outcome;
}

// What an admin sees of a send. sent_by is an admin identifier, pseudonymous, as the record holds it (GS-Q44).
function sendView(snap: DocumentSnapshot, now = Date.now()) {
  return {
    send_id: snap.id,
    category_id: snap.get('category_id'),
    title: snap.get('title'),
    body: snap.get('body'),
    target_type: snap.get('target_type'),
    target_ref: snap.get('target_ref') ?? null,
    sent_by: snap.get('sent_by'),
    sent_at: millis(snap.get('sent_at')),
    outcome: outcomeOf(snap, now),
    attempt_count: snap.get('attempt_count'),
    last_attempt_at: millis(snap.get('last_attempt_at')),
  };
}

const isText = (value: unknown, max: number): value is string => isNonEmptyText(value) && value.trim().length <= max;

interface SendInput {
  categoryId: string;
  title: string;
  body: string;
  targetType: (typeof TARGET_TYPES)[number];
  targetRef: string | null;
}

export function checkSendInput(data: Record<string, unknown>): { invalid: string[]; input?: SendInput } {
  const invalid = unknownFields(data, SEND_FIELDS);
  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');
  if (!isDocumentId(data.category_id)) invalid.push('category_id');
  if (!isText(data.title, PLACEHOLDER_MAX_TITLE_LENGTH)) invalid.push('title');
  if (!isText(data.body, PLACEHOLDER_MAX_BODY_LENGTH)) invalid.push('body');

  const type = data.target_type;
  if (!TARGET_TYPES.includes(type as SendInput['targetType'])) invalid.push('target_type');
  else if (type === 'none' && data.target_ref !== undefined && data.target_ref !== null) invalid.push('target_ref');
  else if (type === 'issue' && !isDocumentId(data.target_ref)) invalid.push('target_ref');
  else if (type === 'news_post' && !(typeof data.target_ref === 'string' && POST_NUMBER.test(data.target_ref))) invalid.push('target_ref');

  if (invalid.length > 0) return { invalid: [...new Set(invalid)].sort() };
  return {
    invalid: [],
    input: {
      categoryId: data.category_id as string,
      title: (data.title as string).trim(),
      body: (data.body as string).trim(),
      targetType: type as SendInput['targetType'],
      targetRef: type === 'none' ? null : (data.target_ref as string),
    },
  };
}

// The category must exist and be active; its topic name must be usable.
async function categoryTopic(db: Firestore, categoryId: string): Promise<string> {
  const category = await db.collection('notification_categories').doc(categoryId).get();
  if (!category.exists || category.get('is_active') !== true) throw invalidArgument(['category_id']);
  const topic = topicFor(categoryId);
  if (topic === null) throw cannotVerify();
  return topic;
}

// An issue must be published. A post must exist on the site and not be hidden in the app (DATA-009; hiding
// a post that a notification opens is PROPOSED as a refusal). The site's failure is UNAVAILABLE.
async function checkTarget(db: Firestore, type: SendInput['targetType'], ref: string | null): Promise<void> {
  if (type === 'none' || ref === null) return;
  if (type === 'issue') {
    const issue = await db.collection('issues').doc(ref).get();
    if (issue.get('publication_state') !== 'published') throw targetNotAvailable();
    return;
  }
  const control = await db.collection('news_controls').doc(ref).get();
  if (control.get('is_hidden') === true) throw targetNotAvailable();
  const base = await readSiteBase(db);
  let exists: boolean;
  try {
    exists = await postExists(base, Number(ref));
  } catch (error) {
    if (error instanceof SiteError) throw siteUnavailable();
    throw error;
  }
  if (!exists) throw targetNotAvailable();
}

// One attempt: send, then mark the record, but only if it is still this attempt's (a later retry wins).
async function attempt(db: Firestore, ref: DocumentReference, attemptNumber: number, operation: string, uid: string) {
  const snap = await ref.get();
  const topic = topicFor(snap.get('category_id'));
  let outcome: 'accepted' | 'failed' = 'accepted';
  try {
    if (topic === null) throw new Error('the category has no usable topic');
    await pushSender().send({
      topic,
      title: snap.get('title'),
      body: snap.get('body'),
      data: { send_id: ref.id, target_type: snap.get('target_type'), ...(snap.get('target_ref') ? { target_ref: snap.get('target_ref') } : {}) },
    });
  } catch {
    outcome = 'failed';
  }

  await db.runTransaction(async (tx) => {
    const current = await tx.get(ref);
    if (current.get('attempt_count') !== attemptNumber || current.get('outcome') !== 'pending') return;
    tx.update(ref, { outcome, settled_at: FieldValue.serverTimestamp() });
  });
  logOperation({ operation, caller: uid, outcome });
  if (outcome === 'failed') throw pushFailed(ref.id);
  return { send_id: ref.id, outcome };
}

export const sendNotification = adminCall('sendNotification', async ({ uid, db, data }) => {
  const { invalid, input } = checkSendInput(data);
  if (!input) throw invalidArgument(invalid);

  const ref = sends(db).doc(derivedId('send', uid, data.request_id as string));
  // A repeat returns the send it made the first time, whatever the repeat asks.
  const earlier = await ref.get();
  if (earlier.exists) return { send_id: ref.id, outcome: outcomeOf(earlier, Date.now()) };

  await categoryTopic(db, input.categoryId);
  await checkTarget(db, input.targetType, input.targetRef);

  const created = await db.runTransaction(async (tx) => {
    if ((await tx.get(ref)).exists) return false;
    const now = FieldValue.serverTimestamp();
    tx.create(ref, {
      send_id: ref.id,
      category_id: input.categoryId,
      title: input.title,
      body: input.body,
      target_type: input.targetType,
      target_ref: input.targetRef,
      sent_by: uid,
      sent_at: now,
      outcome: 'pending',
      attempt_count: 1,
      last_attempt_at: now,
    });
    return true;
  });
  if (!created) return { send_id: ref.id, outcome: outcomeOf(await ref.get(), Date.now()) };

  return attempt(db, ref, 1, 'sendNotification', uid);
});

export const retryNotification = adminCall('retryNotification', async ({ uid, db, data }) => {
  const invalid = unknownFields(data, RETRY_FIELDS);
  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');
  if (!isDocumentId(data.send_id)) invalid.push('send_id');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  const ref = sends(db).doc(data.send_id as string);
  const first = await ref.get();
  if (!first.exists) throw notFound();
  // A repeat of the same retry starts nothing new.
  if (first.get('last_retry_request_id') === data.request_id) return { send_id: ref.id, outcome: outcomeOf(first, Date.now()) };
  if (first.get('outcome') === 'accepted') throw notRetryable();

  // The target may have gone since the first attempt.
  await checkTarget(db, first.get('target_type'), first.get('target_ref') ?? null);

  const next = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.get('last_retry_request_id') === data.request_id) return null;
    const outcome = outcomeOf(snap, Date.now());
    if (outcome === 'accepted') throw notRetryable();
    if (outcome === 'pending') throw attemptInProgress();
    const attemptNumber = (snap.get('attempt_count') as number) + 1;
    tx.update(ref, {
      outcome: 'pending',
      attempt_count: attemptNumber,
      last_attempt_at: FieldValue.serverTimestamp(),
      last_retry_request_id: data.request_id,
    });
    return attemptNumber;
  });
  if (next === null) return { send_id: ref.id, outcome: outcomeOf(await ref.get(), Date.now()) };

  return attempt(db, ref, next, 'retryNotification', uid);
});

export const listNotificationSends = adminCall('listNotificationSends', async ({ db, data }) => {
  const invalid = unknownFields(data, LIST_FIELDS);
  const filter = data.outcome;
  if (filter !== undefined && !OUTCOMES.includes(filter as Outcome)) invalid.push('outcome');

  const pageSize = data.page_size ?? PLACEHOLDER_MAX_PAGE_SIZE;
  if (!Number.isInteger(pageSize) || (pageSize as number) < 1 || (pageSize as number) > PLACEHOLDER_MAX_PAGE_SIZE) {
    invalid.push('page_size');
  }

  let after: DocumentSnapshot | undefined;
  if (data.cursor !== undefined) {
    const cursor = isDocumentId(data.cursor) ? await sends(db).doc(data.cursor).get() : null;
    if (cursor?.exists) after = cursor;
    else invalid.push('cursor');
  }
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  // The filter is on the stored outcome, so "unknown" also finds the pending records past the window, and
  // "pending" leaves them out. With the filter, the query needs an (outcome, sent_at) index (D-4).
  const now = Date.now();
  const size = pageSize as number;
  let query = sends(db).orderBy('sent_at', 'desc');
  if (filter === 'unknown') query = query.where('outcome', 'in', ['unknown', 'pending']);
  else if (filter !== undefined) query = query.where('outcome', '==', filter);
  if (after) query = query.startAfter(after);

  // A filter that the stored outcome cannot express is finished here, so a page may hold fewer than asked.
  const { docs } = await query.limit(size + 1).get();
  const page = docs.slice(0, size);
  const items = page.map((snap) => sendView(snap, now)).filter((item) => filter === undefined || item.outcome === filter);
  return { items, next_cursor: docs.length > size ? page[page.length - 1].id : null };
});

// The OP-41 task that marks the attempts still pending past the window as unknown (DATABASE_AND_DATA_MODEL.md
// section 9, hourly, an ASSUMPTION). The schedule is not built, as for the other OP-41 tasks; a test runs it.
export async function markStaleSends(db: Firestore, now = Date.now()): Promise<number> {
  const cutoff = Timestamp.fromMillis(now - PLACEHOLDER_PENDING_WINDOW_MS);
  const stale = await sends(db).where('outcome', '==', 'pending').where('last_attempt_at', '<', cutoff).limit(PLACEHOLDER_MAX_PAGE_SIZE).get();
  let marked = 0;
  for (const snap of stale.docs) {
    const changed = await db.runTransaction(async (tx) => {
      const current = await tx.get(snap.ref);
      if (outcomeOf(current, now) !== 'unknown' || current.get('outcome') !== 'pending') return false;
      tx.update(snap.ref, { outcome: 'unknown' });
      return true;
    });
    if (changed) marked += 1;
  }
  return marked;
}
