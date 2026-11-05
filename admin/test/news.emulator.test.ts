// SPIKE (DEC-004 OPEN). The news-controls screen's calls (B5.3, T-09.4) against the backend spike's real OP-24
// and OP-23 on the local emulators, with the backend's stand-in WordPress site. MFW's address is OQ-39, and no
// test reads the live site. Every result is "emulator only". Run through `npm test`.
import { afterAll, beforeAll, beforeEach, expect, test } from 'vitest';
// @ts-expect-error The stand-in is plain JavaScript shared with the backend tests, and has no type declarations.
import { makePosts, startWordPress } from '../../backend/spike/test/wp-standin.mjs';
import { adminApi } from '../src/adminApi';
import type { CallFn } from '../src/adminApi';
import { listPosts, setNewsControl } from '../src/data';
import { describeError, ERRORS } from '../src/describeError';
import { emulatorBackend, servicesFor } from '../src/services';
import type { Backend, Services } from '../src/services';
import { signInAdmin } from '../src/signIn';
import { AUTH_URL, clearAll, createAdmin, PASSWORD, requireEmulators, setDoc } from './emulator';

interface StandIn {
  url: string;
  state: { requests: unknown[] };
  set(mode: string): void;
  reset(posts?: unknown[]): void;
  close(): Promise<void>;
}

let wp: StandIn;
let backend: Backend;
let services: Services;
let api: CallFn;
let n = 0;

beforeAll(async () => {
  requireEmulators();
  wp = (await startWordPress({ posts: makePosts(3) })) as StandIn;
  backend = emulatorBackend(AUTH_URL, 'b53-admin');
  services = servicesFor(backend);
  api = adminApi(services.call, () => {
    throw new Error('the session ended during a test');
  });
});

afterAll(async () => {
  await backend.auth.signOut();
  await wp.close();
});

beforeEach(async () => {
  await backend.auth.signOut();
  await clearAll();
  wp.reset(makePosts(3));
  n += 1;
  await createAdmin(`admin-${n}@example.test`);
  await setDoc('config/private', { wordpress_base_url: wp.url });
  expect(await signInAdmin(services, `admin-${n}@example.test`, PASSWORD)).toBe('signed-in');
});

test('B5.3 emulator FR-ADMIN-013: the panel lists the site\'s posts through OP-24 on the server', async () => {
  const page = await listPosts(api, 1);
  expect(page.posts.map((p) => p.title)).toEqual(['Post 1', 'Post 2', 'Post 3']);
  expect(page).toMatchObject({ total_pages: 1, page: 1, per_page: 20 });
  expect(wp.state.requests).toHaveLength(1);
});

test('B5.3 emulator AC-8.8: a post hidden in the panel is hidden in the public read the app makes', async () => {
  await setNewsControl(api, { wp_post_id: 101, is_hidden: true, is_breaking: false });
  expect(await services.read.newsControls()).toEqual([{ wp_post_id: 101, is_hidden: true, is_breaking: false }]);
});

test('B5.3 emulator FR-ADMIN-014: a post marked as breaking shows as breaking, and clearing both flags removes the record', async () => {
  await setNewsControl(api, { wp_post_id: 102, is_hidden: false, is_breaking: true });
  expect(await services.read.newsControls()).toEqual([{ wp_post_id: 102, is_hidden: false, is_breaking: true }]);
  await setNewsControl(api, { wp_post_id: 102, is_hidden: false, is_breaking: false });
  expect(await services.read.newsControls()).toEqual([]);
});

test('B5.3 emulator: when the site fails, the panel gets SITE_UNAVAILABLE and its message', async () => {
  wp.set('status500');
  const error = await listPosts(api, 1).catch((e: unknown) => e);
  expect(error).toMatchObject({ code: 'functions/unavailable', details: { reason: 'SITE_UNAVAILABLE' } });
  expect(describeError(error)).toBe(ERRORS.siteUnavailable);
});
