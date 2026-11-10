// An in-memory stand-in for OP-15 to OP-18, OP-21 and OP-22 and the public category read, for the
// screen tests. It refuses the way the backend does, with the same codes and reasons. The emulator
// tests check the real operations.
import type { CallFn } from '../src/adminApi';
import type { Category, Issue, NewsControl, Post, Reads } from '../src/data';
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

export function fakeServer({ issues = [] as Issue[], categories = [] as Category[], posts = [] as Post[], controls = [] as NewsControl[] } = {}) {
  const state = {
    issues: issues.map((i) => ({ ...i })),
    categories: categories.map((c) => ({ ...c })),
    posts: posts.map((p) => ({ ...p })),
    controls: new Map(controls.map((c) => [c.wp_post_id, { ...c }])),
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
      default:
        return {};
    }
  };

  const read: Reads = {
    categories: async () => [...state.categories].sort((a, b) => a.display_order - b.display_order),
    segments: async () => [],
    newsControls: async () => [...state.controls.values()].map((c) => ({ ...c })),
  };

  return {
    call,
    read,
    log,
    state,
    calls: (name: string) => log.filter((entry) => entry.name === name),
    failNext: (name: string, error: unknown) => failures.set(name, error),
  };
}
