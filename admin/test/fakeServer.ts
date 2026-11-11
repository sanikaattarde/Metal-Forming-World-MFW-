// An in-memory stand-in for OP-15 to OP-18, OP-21 to OP-27 and the public reads, for the
// screen tests. It refuses the way the backend does, with the same codes and reasons. The emulator
// tests check the real operations.
import type { CallFn } from '../src/adminApi';
import type { Category, Issue, NewsControl, NotificationCategory, Post, ReaderRow, Reads, Segment, SendRecord, UploadJob } from '../src/data';
import { serverError } from './fakes';

const PAGE = 20;

export const issueRecord = (over: Partial<Issue> & { issue_id: string }): Issue => ({
  title: 'An issue',
  description: 'What it covers',
  publication_date: '2026-10-01',
  year: 2026,
  edition: null,
  category_id: 'c1',
  segment_ids: [],
  publication_state: 'unpublished',
  current_revision: null,
  page_count: null,
  file_size_bytes: null,
  published_at: null,
  updated_at: 1,
  ...over,
});

const invalid = (fields: string[]) => Object.assign(serverError('invalid-argument'), { details: { fields: fields.sort() } });

export const makePost = (i: number, over: Partial<Post> = {}): Post => ({
  id: 100 + i,
  title: `Post ${i + 1}`,
  date: `2026-10-${String((i % 28) + 1).padStart(2, '0')}T09:00:00`,
  link: `https://news.example.test/post-${i + 1}/`,
  categories: [7],
  ...over,
});

export const NOTIFICATION_CATEGORIES: NotificationCategory[] = [
  { category_id: 'notif-new-issues', name: 'New issues', display_order: 1, is_active: true },
  { category_id: 'notif-expo-specials', name: 'Expo specials', display_order: 2, is_active: true },
  { category_id: 'notif-major-news', name: 'Major news', display_order: 3, is_active: true },
  { category_id: 'notif-old', name: 'Old category', display_order: 4, is_active: false },
];

export const sendRecord = (over: Partial<SendRecord> & { send_id: string }): SendRecord => ({
  category_id: 'notif-new-issues',
  title: `Send ${over.send_id}`,
  body: 'A message',
  target_type: 'none',
  target_ref: null,
  sent_by: 'u-1',
  sent_at: Date.UTC(2026, 10, 11, 9, 30),
  outcome: 'accepted',
  attempt_count: 1,
  last_attempt_at: Date.UTC(2026, 10, 11, 9, 30),
  ...over,
});

export function fakeServer({
  issues = [] as Issue[],
  categories = [] as Category[],
  posts = [] as Post[],
  controls = [] as NewsControl[],
  notificationCategories = NOTIFICATION_CATEGORIES,
  sends = [] as SendRecord[],
  readers = [] as ReaderRow[],
  segments = [] as Segment[],
} = {}) {
  const state = {
    issues: issues.map((i) => ({ ...i })),
    categories: categories.map((c) => ({ ...c })),
    posts: posts.map((p) => ({ ...p })),
    controls: new Map(controls.map((c) => [c.wp_post_id, { ...c }])),
    notificationCategories: notificationCategories.map((c) => ({ ...c })),
    sends: sends.map((s) => ({ ...s })),
    // Whether the next push is refused, as the stand-in push sender does on the emulators.
    pushFails: false,
    jobs: [] as (UploadJob & { polls?: number })[],
    // The server's upload limit (CFG-05), which the panel never sees.
    uploadLimit: 1_000_000,
    // What OP-40 decides about the next file that arrives, and how many OP-20 checks see it still pending.
    nextCheck: { status: 'accepted', reason: null } as { status: 'accepted' | 'rejected'; reason: string | null },
    checkPolls: 1,
    readers: readers.map((r) => ({ ...r })),
    segments: segments.map((g) => ({ ...g })),
  };
  const log: { name: string; data: Record<string, unknown> }[] = [];
  const failures = new Map<string, unknown>();
  const created = new Map<string, string>();
  let clock = 1000;
  let next = 1;

  const find = (id: unknown) => state.issues.find((i) => i.issue_id === id);

  const call: CallFn = async (name, raw) => {
    const data = (raw ?? {}) as Record<string, unknown>;
    log.push({ name, data });
    if (failures.has(name)) {
      const error = failures.get(name);
      failures.delete(name);
      throw error;
    }
    switch (name) {
      case 'listIssuesForAdmin': {
        const all = state.issues
          .filter((i) => !data.publication_state || i.publication_state === data.publication_state)
          .sort((a, b) => String(b.publication_date).localeCompare(String(a.publication_date)) || a.issue_id.localeCompare(b.issue_id));
        const start = data.cursor ? all.findIndex((i) => i.issue_id === data.cursor) + 1 : 0;
        const items = all.slice(start, start + PAGE);
        // Copies, as a real reply is: a screen must not see a stored record change under it.
        return { items: items.map((i) => ({ ...i })), next_cursor: start + PAGE < all.length ? items[items.length - 1].issue_id : null };
      }
      case 'saveIssue': {
        const missing = ['title', 'description', 'category_id', 'publication_date'].filter((f) => typeof data[f] !== 'string' || (data[f] as string).trim() === '');
        if (data.year !== undefined && !Number.isInteger(data.year)) missing.push('year');
        if (missing.length) throw invalid(missing);
        const values = { ...data };
        delete values.request_id;
        delete values.issue_id;
        delete values.expected_updated_at;
        if (data.issue_id === undefined) {
          const repeat = created.get(String(data.request_id));
          if (repeat) return { ...find(repeat)! };
          const record = issueRecord({ issue_id: `issue-${next++}`, ...(values as Partial<Issue>), updated_at: ++clock });
          created.set(String(data.request_id), record.issue_id);
          state.issues.push(record);
          return { ...record };
        }
        const record = find(data.issue_id);
        if (!record) throw serverError('not-found');
        if (record.updated_at !== data.expected_updated_at) throw serverError('aborted', 'STALE_RECORD');
        Object.assign(record, { edition: null }, values, { updated_at: ++clock });
        return { ...record };
      }
      case 'publishIssue':
      case 'unpublishIssue': {
        const record = find(data.issue_id);
        if (!record) throw serverError('not-found');
        if (name === 'publishIssue' && !record.current_revision) throw serverError('failed-precondition', 'NO_ACCEPTED_FILE');
        record.publication_state = name === 'publishIssue' ? 'published' : 'unpublished';
        record.updated_at = ++clock;
        return { ...record };
      }
      case 'saveCategory': {
        const missing: string[] = [];
        if (typeof data.name !== 'string' || data.name.trim() === '') missing.push('name');
        if (!Number.isInteger(data.display_order)) missing.push('display_order');
        if (missing.length) throw invalid(missing);
        const name = (data.name as string).trim();
        const id = (data.category_id as string | undefined) ?? created.get(String(data.request_id)) ?? `cat-${next++}`;
        if (state.categories.some((c) => c.category_id !== id && c.name.toLowerCase() === name.toLowerCase())) throw serverError('aborted', 'NAME_TAKEN');
        created.set(String(data.request_id), id);
        const record = { category_id: id, name, display_order: data.display_order as number };
        state.categories = [...state.categories.filter((c) => c.category_id !== id), record];
        return { ...record };
      }
      case 'deleteCategory': {
        if (state.issues.some((i) => i.category_id === data.category_id)) throw serverError('failed-precondition', 'IN_USE');
        state.categories = state.categories.filter((c) => c.category_id !== data.category_id);
        return { category_id: data.category_id, deleted: true };
      }
      case 'listWordPressPosts': {
        const page = Number(data.page ?? 1);
        const perPage = Number(data.per_page ?? 20);
        const totalPages = Math.max(1, Math.ceil(state.posts.length / perPage));
        return { posts: state.posts.slice((page - 1) * perPage, page * perPage).map((p) => ({ ...p })), total_pages: totalPages, page, per_page: perPage };
      }
      case 'setNewsControl': {
        const control = { wp_post_id: data.wp_post_id as number, is_hidden: data.is_hidden as boolean, is_breaking: data.is_breaking as boolean };
        if (!control.is_hidden && !control.is_breaking) state.controls.delete(control.wp_post_id);
        else state.controls.set(control.wp_post_id, control);
        return { ...control };
      }
      case 'sendNotification': {
        const missing: string[] = [];
        if (!state.notificationCategories.some((c) => c.category_id === data.category_id && c.is_active)) missing.push('category_id');
        if (typeof data.title !== 'string' || !data.title.trim() || data.title.trim().length > 100) missing.push('title');
        if (typeof data.body !== 'string' || !data.body.trim() || data.body.trim().length > 400) missing.push('body');
        if (missing.length) throw invalid(missing);
        const repeat = created.get(String(data.request_id));
        if (repeat) {
          const record = state.sends.find((s) => s.send_id === repeat)!;
          return { send_id: record.send_id, outcome: record.outcome };
        }
        if (data.target_type === 'issue' && find(data.target_ref)?.publication_state !== 'published') {
          throw serverError('failed-precondition', 'TARGET_NOT_AVAILABLE');
        }
        if (data.target_type === 'news_post' && !state.posts.some((p) => String(p.id) === data.target_ref)) {
          throw serverError('failed-precondition', 'TARGET_NOT_AVAILABLE');
        }
        const outcome = state.pushFails ? 'failed' : 'accepted';
        const record: SendRecord = {
          send_id: `send-${next++}`,
          category_id: data.category_id as string,
          title: (data.title as string).trim(),
          body: (data.body as string).trim(),
          target_type: data.target_type as SendRecord['target_type'],
          target_ref: (data.target_ref as string | undefined) ?? null,
          sent_by: 'u-1',
          sent_at: ++clock,
          outcome,
          attempt_count: 1,
          last_attempt_at: clock,
        };
        state.sends.unshift(record);
        created.set(String(data.request_id), record.send_id);
        if (outcome === 'failed') throw Object.assign(serverError('unavailable'), { details: { reason: 'PUSH_FAILED', send_id: record.send_id } });
        return { send_id: record.send_id, outcome };
      }
      case 'retryNotification': {
        const record = state.sends.find((s) => s.send_id === data.send_id);
        if (!record) throw serverError('not-found');
        if (record.outcome === 'accepted') throw serverError('failed-precondition', 'NOT_RETRYABLE');
        if (record.outcome === 'pending') throw serverError('aborted', 'ATTEMPT_IN_PROGRESS');
        record.attempt_count += 1;
        record.outcome = state.pushFails ? 'failed' : 'accepted';
        if (record.outcome === 'failed') throw Object.assign(serverError('unavailable'), { details: { reason: 'PUSH_FAILED', send_id: record.send_id } });
        return { send_id: record.send_id, outcome: record.outcome };
      }
      case 'listNotificationSends': {
        const size = Number(data.page_size ?? 20);
        const all = state.sends.filter((s) => !data.outcome || s.outcome === data.outcome);
        const start = data.cursor ? all.findIndex((s) => s.send_id === data.cursor) + 1 : 0;
        const items = all.slice(start, start + size);
        return { items: items.map((s) => ({ ...s })), next_cursor: start + size < all.length ? items[items.length - 1].send_id : null };
      }
      case 'requestUpload': {
        if (typeof data.declared_size_bytes !== 'number' || data.declared_size_bytes > state.uploadLimit) throw invalid(['declared_size_bytes']);
        if (!find(data.issue_id)) throw serverError('not-found');
        const known = created.get(String(data.request_id));
        let job = state.jobs.find((j) => j.job_id === known);
        if (!job) {
          job = { job_id: `job-${next++}`, kind: 'pdf', issue_id: data.issue_id as string, declared_size_bytes: data.declared_size_bytes, status: 'pending', reason: null, revision: null, created_at: ++clock, finished_at: null };
          state.jobs.unshift(job);
          created.set(String(data.request_id), job.job_id);
        }
        if (job.status !== 'pending') return { job_id: job.job_id, status: job.status };
        return { job_id: job.job_id, upload_url: `https://upload.example.test/${job.job_id}`, upload_headers: { 'content-type': 'application/pdf', 'x-goog-resumable': 'start' }, expires_at: clock + 900_000 };
      }
      case 'listUploadJobs': {
        const strip = ({ polls, ...job }: UploadJob & { polls?: number }) => ({ ...job });
        if (data.job_id) {
          const job = state.jobs.find((j) => j.job_id === data.job_id);
          if (job && job.polls !== undefined) {
            if (job.polls > 0) job.polls -= 1;
            else settle(job);
          }
          return { jobs: job ? [strip(job)] : [] };
        }
        return { jobs: state.jobs.filter((j) => j.issue_id === data.issue_id).map(strip) };
      }
      case 'listRegisteredUsers': {
        const size = Number(data.page_size ?? 50);
        const start = data.cursor ? state.readers.findIndex((r) => r.user_id === data.cursor) + 1 : 0;
        const items = state.readers.slice(start, start + size);
        return { items: items.map((r) => ({ ...r })), next_cursor: start + size < state.readers.length ? items[items.length - 1].user_id : null };
      }
      case 'exportRegisteredUsers': {
        const lines = ['Email,Full name', ...state.readers.map((r) => `${r.email},${r.full_name}`)];
        return { csv: `${lines.join('\r\n')}\r\n`, row_count: state.readers.length, file_name: 'registered-users-2026-11-11.csv' };
      }
      default:
        return {};
    }
  };

  // OP-40, once the file is in the holding area.
  function settle(job: UploadJob & { polls?: number }) {
    delete job.polls;
    job.finished_at = ++clock;
    if (state.nextCheck.status === 'rejected') {
      Object.assign(job, { status: 'rejected', reason: state.nextCheck.reason });
      return;
    }
    const issue = find(job.issue_id)!;
    const revision = (issue.current_revision ?? 0) + 1;
    Object.assign(job, { status: 'accepted', revision });
    Object.assign(issue, { current_revision: revision, updated_at: ++clock });
  }

  // The file reached the upload address: the check starts, and finishes after `checkPolls` looks.
  const arrive = (uploadUrl: string) => {
    const job = state.jobs.find((j) => uploadUrl.endsWith(`/${j.job_id}`));
    if (job && job.status === 'pending') job.polls = state.checkPolls;
  };

  const read: Reads = {
    categories: async () => [...state.categories].sort((a, b) => a.display_order - b.display_order),
    segments: async () => state.segments.map((g) => ({ ...g })),
    newsControls: async () => [...state.controls.values()].map((c) => ({ ...c })),
    notificationCategories: async () => [...state.notificationCategories].sort((a, b) => a.display_order - b.display_order),
  };

  return {
    call,
    read,
    log,
    state,
    calls: (name: string) => log.filter((entry) => entry.name === name),
    failNext: (name: string, error: unknown) => failures.set(name, error),
    arrive,
  };
}

export const readerRow = (i: number, over: Partial<ReaderRow> = {}): ReaderRow => ({
  user_id: `u-${i}`,
  email: `reader-${i}@example.test`,
  full_name: `Reader ${i}`,
  age_value: 30 + i,
  gender: 'Prefer not to say',
  job_title: 'Engineer',
  industry_segment_id: 's1',
  created_at: Date.UTC(2026, 10, 1 + (i % 28)),
  ...over,
});
