// SPIKE (DEC-004 OPEN). The panel's calls for issues and categories (B5.2, T-09.3). Every write goes through
// the server operations OP-15 to OP-18, OP-21 and OP-22. Categories and segments are public reads, as the
// app reads them. The shapes follow the backend spike, whose shapes are spike choices (D-7).
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

export interface Reads {
  categories(): Promise<Category[]>;
  segments(): Promise<Segment[]>;
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
