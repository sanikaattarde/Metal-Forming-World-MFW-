// OP-24 listWordPressPosts, from API_AND_BACKEND_CONTRACT.md
// section 5.1: a page of MFW's WordPress posts for the admin's news-controls screen (FR-ADMIN-013). The
// panel does not call the site itself (TD-12). The site's address is CFG-03, which is OPEN (OQ-39), so it
// is read from the private configuration and nothing has a default. No post is copied or stored (M3).
import type { Firestore } from 'firebase-admin/firestore';
import * as logger from 'firebase-functions/logger';
import { adminCall } from './adminCall.js';
import { cannotVerify, invalidArgument, siteUnavailable } from './errors.js';
import { logOperation } from './safeLog.js';
import { unknownFields } from './validation.js';

// PLACEHOLDERS. No document sets these. They are not decided values.
export const PLACEHOLDER_SITE_TIMEOUT_MS = 10_000;
export const PLACEHOLDER_SITE_MAX_BYTES = 1_000_000;
export const PLACEHOLDER_POSTS_PER_PAGE = 20;
export const PLACEHOLDER_MAX_PAGE = 1000;
// The WordPress REST API's own maximum per request (TECHNOLOGY_DECISIONS.md TD-12, VS-41).
export const SITE_MAX_PER_PAGE = 100;

const OPERATION = 'listWordPressPosts';
const FIELDS = new Set(['page', 'per_page', 'category']);
const LOOPBACK = new Set(['127.0.0.1', 'localhost', '[::1]']);

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
}

// Why a site reply could not be used. Only the kind is logged, never an address or a value.
export class SiteError extends Error {
  constructor(readonly kind: string) {
    super(`the news site could not be used: ${kind}`);
  }
}

// The address must be HTTPS, with no user name, password, query or fragment. Plain HTTP is allowed only for
// this machine, and only on the emulators, for the stand-in site the tests use.
export function checkBaseUrl(value: unknown, { allowLoopbackHttp = process.env.FUNCTIONS_EMULATOR === 'true' } = {}): URL | null {
  if (typeof value !== 'string' || value.trim() === '') return null;
  let url: URL;
  try {
    url = new URL(value.trim());
  } catch {
    return null;
  }
  if (url.username || url.password || url.search || url.hash) return null;
  const loopback = LOOPBACK.has(url.hostname);
  if (url.protocol !== 'https:' && !(url.protocol === 'http:' && loopback && allowLoopbackHttp)) return null;
  if (!url.pathname.endsWith('/')) url.pathname += '/';
  return url;
}

export async function readSiteBase(db: Firestore): Promise<URL> {
  const base = checkBaseUrl((await db.doc('config/private').get()).get('wordpress_base_url'));
  if (!base) {
    logger.error('listWordPressPosts refused: wordpress_base_url is missing or not usable');
    throw cannotVerify();
  }
  return base;
}

const NAMED: Record<string, string> = {
  amp: '&', lt: '<', gt: '>', quot: '"', apos: "'", nbsp: ' ', hellip: '…', ndash: '–', mdash: '—',
  lsquo: '‘', rsquo: '’', ldquo: '“', rdquo: '”',
};

// A post title arrives as HTML. It becomes plain text: tags are dropped and character references decoded.
// The panel then shows it as text, so nothing in it can run (CODING_STANDARDS.md §7, SEC-CHK-15).
export function plainText(html: string): string {
  return html
    .replace(/<[^>]*>/g, '')
    .replace(/&(#\d+|#x[0-9a-fA-F]+|[a-zA-Z]+);/g, (whole, ref: string) => {
      if (ref.startsWith('#x') || ref.startsWith('#X')) return String.fromCodePoint(parseInt(ref.slice(2), 16) || 0xfffd);
      if (ref.startsWith('#')) return String.fromCodePoint(Number(ref.slice(1)) || 0xfffd);
      return NAMED[ref.toLowerCase()] ?? whole;
    })
    .replace(/\s+/g, ' ')
    .trim();
}

const isPositiveInteger = (value: unknown): value is number => Number.isInteger(value) && (value as number) > 0;

function toPost(item: unknown): Post {
  const raw = item as { id?: unknown; title?: { rendered?: unknown }; date?: unknown; link?: unknown; categories?: unknown };
  if (!raw || typeof raw !== 'object') throw new SiteError('item');
  if (!isPositiveInteger(raw.id)) throw new SiteError('item id');
  if (typeof raw.title?.rendered !== 'string') throw new SiteError('item title');
  if (typeof raw.date !== 'string' || Number.isNaN(Date.parse(raw.date))) throw new SiteError('item date');
  // The link is shown to the admin as a link, so only a web address is accepted, never javascript: or data:.
  let link: URL;
  try {
    link = new URL(String(raw.link));
  } catch {
    throw new SiteError('item link');
  }
  if (link.protocol !== 'https:' && link.protocol !== 'http:') throw new SiteError('item link');
  if (!Array.isArray(raw.categories) || !raw.categories.every(isPositiveInteger)) throw new SiteError('item categories');
  return { id: raw.id, title: plainText(raw.title.rendered), date: raw.date, link: link.href, categories: raw.categories };
}

async function readCapped(response: Response, maxBytes: number): Promise<string> {
  const declared = Number(response.headers.get('content-length'));
  if (Number.isFinite(declared) && declared > maxBytes) throw new SiteError('too large');
  if (!response.body) return '';
  const reader = response.body.getReader();
  const chunks: Uint8Array[] = [];
  let total = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.byteLength;
    if (total > maxBytes) {
      await reader.cancel();
      throw new SiteError('too large');
    }
    chunks.push(value);
  }
  return Buffer.concat(chunks).toString('utf8');
}

// Reads one page of posts. No credentials are sent, and a redirect is refused, so the request reaches only
// the configured site.
export async function fetchPosts(
  base: URL,
  { page, perPage, category }: { page: number; perPage: number; category?: number },
  { timeoutMs = PLACEHOLDER_SITE_TIMEOUT_MS, maxBytes = PLACEHOLDER_SITE_MAX_BYTES } = {},
): Promise<PostPage> {
  const url = new URL('wp-json/wp/v2/posts', base);
  url.searchParams.set('page', String(page));
  url.searchParams.set('per_page', String(perPage));
  url.searchParams.set('_fields', 'id,title,date,link,categories');
  if (category !== undefined) url.searchParams.set('categories', String(category));

  let response: Response;
  try {
    response = await fetch(url, { headers: { Accept: 'application/json' }, redirect: 'error', credentials: 'omit', signal: AbortSignal.timeout(timeoutMs) });
  } catch {
    throw new SiteError('unreachable');
  }

  const body = await readCapped(response, maxBytes).catch((error: unknown) => {
    throw error instanceof SiteError ? error : new SiteError('read');
  });
  // A missing header is unknown, not zero (Number(null) would be 0).
  const pagesText = response.headers.get('x-wp-totalpages');
  const pagesHeader = pagesText === null || pagesText.trim() === '' ? NaN : Number(pagesText);
  const totalPages = Number.isInteger(pagesHeader) && pagesHeader >= 0 ? pagesHeader : null;

  // A page past the last one is an empty page, not a failure.
  if (response.status === 400) {
    let code: unknown;
    try {
      code = (JSON.parse(body) as { code?: unknown }).code;
    } catch {
      code = undefined;
    }
    if (code === 'rest_post_invalid_page_number') return { posts: [], total_pages: totalPages };
  }
  if (!response.ok) throw new SiteError(`status ${response.status}`);

  let parsed: unknown;
  try {
    parsed = JSON.parse(body);
  } catch {
    throw new SiteError('not JSON');
  }
  if (!Array.isArray(parsed)) throw new SiteError('not a list');
  return { posts: parsed.map(toPost), total_pages: totalPages };
}

export const listWordPressPosts = adminCall('listWordPressPosts', async ({ uid, db, data }) => {
  const invalid = unknownFields(data, FIELDS);
  const page = data.page ?? 1;
  const perPage = data.per_page ?? PLACEHOLDER_POSTS_PER_PAGE;
  if (!isPositiveInteger(page) || page > PLACEHOLDER_MAX_PAGE) invalid.push('page');
  if (!isPositiveInteger(perPage) || perPage > SITE_MAX_PER_PAGE) invalid.push('per_page');
  if (data.category !== undefined && !isPositiveInteger(data.category)) invalid.push('category');
  if (invalid.length > 0) throw invalidArgument(invalid.sort());

  const base = await readSiteBase(db);
  try {
    const result = await fetchPosts(base, { page: page as number, perPage: perPage as number, category: data.category as number | undefined });
    logOperation({ operation: OPERATION, caller: uid, outcome: 'OK' });
    return { ...result, page, per_page: perPage };
  } catch (error) {
    logOperation({ operation: OPERATION, caller: uid, outcome: 'SITE_UNAVAILABLE' });
    if (!(error instanceof SiteError)) logger.error('listWordPressPosts: unexpected failure reading the site');
    throw siteUnavailable();
  }
});
