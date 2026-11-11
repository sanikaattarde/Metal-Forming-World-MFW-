// OP-31 listRegisteredUsers and OP-32 exportRegisteredUsers, from API_AND_BACKEND_CONTRACT.md section 5.2
// (FR-USER-002, FR-USER-003, NFR-PRIV-004, PAC-03, SEC-CHK-12, MOD12-P2-T06). PROVISIONAL: which admins see the
// list is OQ-51, the S3 confirmation is OQ-29, and whether this is the "subscriber list" is OQ-31. On the working
// position any admin may (GS-Q49). No audit record is written (GS-Q44).
//
// A reader is listed from the first profile save, which creates the user record (OP-10). An account being
// deleted is hidden. The email address comes from the sign-in provider on each call and is not copied anywhere.
// The export is built in memory and not stored, and a cell that a spreadsheet would read as a formula is
// neutralised (FX-ADM-07).
import { getAuth } from 'firebase-admin/auth';
import type { Auth } from 'firebase-admin/auth';
import { Timestamp } from 'firebase-admin/firestore';
import type { DocumentSnapshot, Firestore } from 'firebase-admin/firestore';
import { HttpsError } from 'firebase-functions/v2/https';
import { adminCall } from './adminCall.js';
import { invalidArgument } from './errors.js';
import { PLACEHOLDER_MAX_PAGE_SIZE } from './issues.js';
import { logOperation } from './safeLog.js';
import { isDocumentId, unknownFields } from './validation.js';

// The profile fields of the working position (GS-Q40), in the order the panel and the export show them.
export const PROFILE_FIELDS = ['full_name', 'age_value', 'gender', 'job_title', 'industry_segment_id'] as const;

// PLACEHOLDERS. No document sets these. They are not decided values.
export const PLACEHOLDER_MAX_EXPORT_ROWS = 10_000;
const EXPORT_BATCH = 500;
const PROVIDER_BATCH = 100; // the provider's own limit for one lookup

const LIST_FIELDS = new Set(['page_size', 'cursor']);

const activeUsers = (db: Firestore) => db.collection('users').where('status', '==', 'active').orderBy('created_at', 'desc');

const millis = (value: unknown): number | null => (value instanceof Timestamp ? value.toMillis() : null);

export interface ReaderRow {
  user_id: string;
  email: string | null;
  full_name: string | null;
  age_value: number | null;
  gender: string | null;
  job_title: string | null;
  industry_segment_id: string | null;
  created_at: number | null;
}

// The email addresses of the accounts, from the provider, in lookups of 100.
async function emailsOf(auth: Auth, uids: string[]): Promise<Map<string, string | null>> {
  const emails = new Map<string, string | null>();
  for (let i = 0; i < uids.length; i += PROVIDER_BATCH) {
    const { users } = await auth.getUsers(uids.slice(i, i + PROVIDER_BATCH).map((uid) => ({ uid })));
    for (const user of users) emails.set(user.uid, user.email ?? null);
  }
  return emails;
}

async function rowsFor(db: Firestore, auth: Auth, users: DocumentSnapshot[]): Promise<ReaderRow[]> {
  if (users.length === 0) return [];
  const profiles = await db.getAll(...users.map((user) => user.ref.collection('profile').doc('current')));
  const emails = await emailsOf(auth, users.map((user) => user.id));
  return users.map((user, i) => {
    const profile = profiles[i];
    const value = (name: string) => profile.get(name) ?? null;
    return {
      user_id: user.id,
      email: emails.get(user.id) ?? null,
      full_name: value('full_name'),
      age_value: value('age_value'),
      gender: value('gender'),
      job_title: value('job_title'),
      industry_segment_id: value('industry_segment_id'),
      created_at: millis(user.get('created_at')),
    };
  });
}

export const listRegisteredUsers = adminCall('listRegisteredUsers', async ({ db, data }) => {
  const invalid = unknownFields(data, LIST_FIELDS);
  const pageSize = data.page_size ?? PLACEHOLDER_MAX_PAGE_SIZE;
  if (!Number.isInteger(pageSize) || (pageSize as number) < 1 || (pageSize as number) > PLACEHOLDER_MAX_PAGE_SIZE) {
    invalid.push('page_size');
  }
  let after: DocumentSnapshot | undefined;
  if (data.cursor !== undefined) {
    const cursor = isDocumentId(data.cursor) ? await db.collection('users').doc(data.cursor).get() : null;
    if (cursor?.exists && cursor.get('status') === 'active') after = cursor;
    else invalid.push('cursor');
  }
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  // With the filter, this query needs a (status, created_at) index (D-4).
  const size = pageSize as number;
  let query = activeUsers(db).limit(size + 1);
  if (after) query = query.startAfter(after);
  const { docs } = await query.get();
  const page = docs.slice(0, size);
  return { items: await rowsFor(db, getAuth(), page), next_cursor: docs.length > size ? page[page.length - 1].id : null };
});

// ---- The CSV (RFC 4180, with CRLF line ends) ----

// A cell a spreadsheet would run as a formula starts with one of these (OWASP's list for CSV injection).
const FORMULA_START = /^[=+\-@\t\r]/;

export function csvCell(value: unknown): string {
  if (value === null || value === undefined) return '';
  let text = String(value);
  if (FORMULA_START.test(text)) text = `'${text}`;
  return /[",\r\n]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
}

export const CSV_COLUMNS: { header: string; value: (row: ReaderRow, segments: Map<string, string>) => unknown }[] = [
  { header: 'Email', value: (row) => row.email },
  { header: 'Full name', value: (row) => row.full_name },
  { header: 'Age', value: (row) => row.age_value },
  { header: 'Gender', value: (row) => row.gender },
  { header: 'Occupation', value: (row) => row.job_title },
  { header: 'Domain of work', value: (row, segments) => (row.industry_segment_id ? (segments.get(row.industry_segment_id) ?? row.industry_segment_id) : null) },
  { header: 'Registered (GMT)', value: (row) => (row.created_at === null ? null : new Date(row.created_at).toISOString().slice(0, 19).replace('T', ' ')) },
];

export function toCsv(rows: ReaderRow[], segments: Map<string, string>): string {
  const lines = [CSV_COLUMNS.map((column) => csvCell(column.header)).join(',')];
  for (const row of rows) lines.push(CSV_COLUMNS.map((column) => csvCell(column.value(row, segments))).join(','));
  return `${lines.join('\r\n')}\r\n`;
}

export const exportTooLarge = () =>
  new HttpsError('failed-precondition', 'The list is too long to export in one file.', { reason: 'EXPORT_TOO_LARGE' });

export const exportRegisteredUsers = adminCall('exportRegisteredUsers', async ({ uid, db, data }) => {
  const invalid = unknownFields(data, new Set());
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  const auth = getAuth();
  const rows: ReaderRow[] = [];
  let after: DocumentSnapshot | undefined;
  for (;;) {
    let query = activeUsers(db).limit(EXPORT_BATCH);
    if (after) query = query.startAfter(after);
    const { docs } = await query.get();
    if (rows.length + docs.length > PLACEHOLDER_MAX_EXPORT_ROWS) throw exportTooLarge();
    rows.push(...(await rowsFor(db, auth, docs)));
    if (docs.length < EXPORT_BATCH) break;
    after = docs[docs.length - 1];
  }

  const segments = new Map((await db.collection('segments').get()).docs.map((doc) => [doc.id, String(doc.get('name') ?? doc.id)]));
  logOperation({ operation: 'exportRegisteredUsers', caller: uid, outcome: 'OK' });
  return { csv: toCsv(rows, segments), row_count: rows.length, file_name: `registered-users-${new Date().toISOString().slice(0, 10)}.csv` };
});
