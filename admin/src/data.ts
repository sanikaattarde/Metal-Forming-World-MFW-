// The panel's calls for issues and categories (MOD12-P2-T03, T-09.3). Every write goes through
// the server operations OP-15 to OP-18, OP-21 and OP-22. Categories and segments are public reads, as the
// app reads them. The shapes follow the backend, whose shapes are PROPOSED (D-7).
import type { CallFn } from './adminApi';

// PLACEHOLDER. "The largest page size is OPEN" (D-5). Not a decided value.
export const PLACEHOLDER_ISSUES_PER_PAGE = 20;

export type PublicationState = 'published' | 'unpublished';

export interface Issue {
  issue_id: string;
  title: string | null;
  description: string | null;
  publication_date: string | null;
  year: number | null;
  edition: string | null;
  category_id: string | null;
  segment_ids: string[];
  publication_state: PublicationState | null;
  current_revision: number | null;
  page_count: number | null;
  file_size_bytes: number | null;
  published_at: number | null;
  updated_at: number | null;
}

export interface IssuePage {
  items: Issue[];
  next_cursor: string | null;
}

export interface Category {
  category_id: string;
  name: string;
  display_order: number;
}

export interface Segment {
  segment_id: string;
  name: string;
}

// The details an admin edits (OP-16). Year and edition are optional; publication state and the file facts
// cannot be set here.
export interface IssueDetails {
  title: string;
  description: string;
  category_id: string;
  segment_ids: string[];
  publication_date: string;
  year?: number;
  edition?: string;
}

// A WordPress post as OP-24 returns it. The post stays in WordPress; the panel copies nothing (M3).
export interface Post {
  id: number;
  title: string;
  date: string;
  link: string;
  categories: number[];
}

export interface PostPage {
  posts: Post[];
  total_pages: number | null;
  page: number;
  per_page: number;
}

// NEWS_CONTROL: hide a post in the app, or mark it as breaking. No record means neither.
export interface NewsControl {
  wp_post_id: number;
  is_hidden: boolean;
  is_breaking: boolean;
}

// PLACEHOLDER. No document sets how many posts the news screen shows at once.
export const PLACEHOLDER_POSTS_PER_PAGE = 20;

// NOTIFICATION_CATEGORY: the three fixed categories of the working position (GS-Q47; OQ-18 is OPEN). A public
// read, as the app makes it.
export interface NotificationCategory {
  category_id: string;
  name: string;
  display_order: number;
  is_active: boolean;
}

export interface Reads {
  categories(): Promise<Category[]>;
  segments(): Promise<Segment[]>;
  newsControls(): Promise<NewsControl[]>;
  notificationCategories(): Promise<NotificationCategory[]>;
}

export const newRequestId = (): string => crypto.randomUUID();

export function listIssues(api: CallFn, { state, cursor }: { state?: PublicationState; cursor?: string | null } = {}): Promise<IssuePage> {
  return api('listIssuesForAdmin', {
    page_size: PLACEHOLDER_ISSUES_PER_PAGE,
    ...(state ? { publication_state: state } : {}),
    ...(cursor ? { cursor } : {}),
  }) as Promise<IssuePage>;
}

// No operation returns one issue to an admin, so the panel pages through OP-15 until it finds it (K-2).
export async function findIssue(api: CallFn, issueId: string): Promise<Issue | null> {
  let cursor: string | null = null;
  do {
    const page: IssuePage = await listIssues(api, { cursor });
    const found = page.items.find((issue) => issue.issue_id === issueId);
    if (found) return found;
    cursor = page.next_cursor;
  } while (cursor);
  return null;
}

export function createIssue(api: CallFn, requestId: string, details: IssueDetails): Promise<Issue> {
  return api('saveIssue', { request_id: requestId, ...details }) as Promise<Issue>;
}

// The edit says which version the screen showed, so a stale screen is refused (STALE_RECORD).
export function updateIssue(api: CallFn, issue: Issue, details: IssueDetails): Promise<Issue> {
  return api('saveIssue', { request_id: newRequestId(), issue_id: issue.issue_id, expected_updated_at: issue.updated_at, ...details }) as Promise<Issue>;
}

export function setPublished(api: CallFn, issueId: string, published: boolean): Promise<Issue> {
  return api(published ? 'publishIssue' : 'unpublishIssue', { request_id: newRequestId(), issue_id: issueId }) as Promise<Issue>;
}

export function saveCategory(api: CallFn, category: { category_id?: string; name: string; display_order: number }, requestId = newRequestId()): Promise<Category> {
  return api('saveCategory', { request_id: requestId, ...category }) as Promise<Category>;
}

export function deleteCategory(api: CallFn, categoryId: string): Promise<unknown> {
  return api('deleteCategory', { request_id: newRequestId(), category_id: categoryId });
}

// OP-24, run on the server: the panel never calls the WordPress site itself (TD-12).
export function listPosts(api: CallFn, page: number): Promise<PostPage> {
  return api('listWordPressPosts', { page, per_page: PLACEHOLDER_POSTS_PER_PAGE }) as Promise<PostPage>;
}

// OP-23. Clearing both flags removes the record. Marking a post as breaking sends nothing; a send is OP-25.
export function setNewsControl(api: CallFn, control: NewsControl): Promise<NewsControl> {
  return api('setNewsControl', { request_id: newRequestId(), ...control }) as Promise<NewsControl>;
}

// OP-25 to OP-27 (MOD12-P2-T05). What a notification opens: an issue, a news post or nothing (FR-NOTIF-005).
export type TargetType = 'issue' | 'news_post' | 'none';

export type SendOutcome = 'pending' | 'accepted' | 'failed' | 'unknown';

export interface NotificationDraft {
  category_id: string;
  title: string;
  body: string;
  target_type: TargetType;
  target_ref?: string;
}

// A send record as OP-27 returns it. The fields wait for OQ-19 (PROVISIONAL).
export interface SendRecord {
  send_id: string;
  category_id: string;
  title: string;
  body: string;
  target_type: TargetType;
  target_ref: string | null;
  sent_by: string;
  sent_at: number | null;
  outcome: SendOutcome;
  attempt_count: number;
  last_attempt_at: number | null;
}

export interface SendPage {
  items: SendRecord[];
  next_cursor: string | null;
}

export interface SendResult {
  send_id: string;
  outcome: SendOutcome;
}

// PLACEHOLDERS, the backend's own: no document sets them (notifications.ts).
export const PLACEHOLDER_MAX_TITLE_LENGTH = 100;
export const PLACEHOLDER_MAX_BODY_LENGTH = 400;
// PLACEHOLDER. No document sets how many sends the log shows at once.
export const PLACEHOLDER_SENDS_PER_PAGE = 20;

// The same request identifier for the same send, so a repeat after a lost reply sends nothing twice.
export function sendNotification(api: CallFn, requestId: string, draft: NotificationDraft): Promise<SendResult> {
  const { target_ref, ...rest } = draft;
  return api('sendNotification', { request_id: requestId, ...rest, ...(draft.target_type === 'none' ? {} : { target_ref }) }) as Promise<SendResult>;
}

export function retryNotification(api: CallFn, sendId: string, requestId = newRequestId()): Promise<SendResult> {
  return api('retryNotification', { request_id: requestId, send_id: sendId }) as Promise<SendResult>;
}

export function listSends(api: CallFn, { outcome, cursor }: { outcome?: SendOutcome; cursor?: string | null } = {}): Promise<SendPage> {
  return api('listNotificationSends', {
    page_size: PLACEHOLDER_SENDS_PER_PAGE,
    ...(outcome ? { outcome } : {}),
    ...(cursor ? { cursor } : {}),
  }) as Promise<SendPage>;
}

// PLACEHOLDER. How many pages of published issues the send screen reads for its list of targets.
export const PLACEHOLDER_TARGET_ISSUE_PAGES = 5;

export async function publishedIssues(api: CallFn): Promise<Issue[]> {
  const found: Issue[] = [];
  let cursor: string | null = null;
  for (let page = 0; page < PLACEHOLDER_TARGET_ISSUE_PAGES; page += 1) {
    const result: IssuePage = await listIssues(api, { state: 'published', cursor });
    found.push(...result.items);
    cursor = result.next_cursor;
    if (!cursor) break;
  }
  return found;
}

// OP-19 and OP-20 (MOD12-P2-T02). A PDF only: a cover waits for OQ-22. The size limit is the server's
// (CFG-05, OQ-30), so the panel does not know it and the server refuses a declared size over it.
export const PDF_TYPE = 'application/pdf';

export type JobStatus = 'pending' | 'accepted' | 'rejected';

export interface UploadJob {
  job_id: string;
  kind: 'pdf';
  issue_id: string;
  declared_size_bytes: number;
  status: JobStatus;
  reason: string | null;
  revision: number | null;
  created_at: number | null;
  finished_at: number | null;
}

// A pending job comes with an upload address and the headers to open it. A job already finished has none.
export interface UploadStart {
  job_id: string;
  status?: JobStatus;
  upload_url?: string;
  upload_headers?: Record<string, string>;
  expires_at?: number;
}

// The same request identifier for the same file, so a second try finds the same job and gets a new address.
export function requestUpload(api: CallFn, requestId: string, issueId: string, sizeBytes: number): Promise<UploadStart> {
  return api('requestUpload', { request_id: requestId, kind: 'pdf', issue_id: issueId, declared_size_bytes: sizeBytes, content_type: PDF_TYPE }) as Promise<UploadStart>;
}

export async function uploadJobs(api: CallFn, query: { issue_id: string } | { job_id: string }): Promise<UploadJob[]> {
  return ((await api('listUploadJobs', query)) as { jobs: UploadJob[] }).jobs;
}

// OP-31 and OP-32 (MOD12-P2-T06). PROVISIONAL: who sees the list is OQ-51, and the fields wait for OQ-01.
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

export interface ReaderPage {
  items: ReaderRow[];
  next_cursor: string | null;
}

export interface ReaderExport {
  csv: string;
  row_count: number;
  file_name: string;
}

// PLACEHOLDER. No document sets how many readers the screen shows at once.
export const PLACEHOLDER_READERS_PER_PAGE = 50;

export function listReaders(api: CallFn, cursor?: string | null): Promise<ReaderPage> {
  return api('listRegisteredUsers', { page_size: PLACEHOLDER_READERS_PER_PAGE, ...(cursor ? { cursor } : {}) }) as Promise<ReaderPage>;
}

export function exportReaders(api: CallFn): Promise<ReaderExport> {
  return api('exportRegisteredUsers', {}) as Promise<ReaderExport>;
}
