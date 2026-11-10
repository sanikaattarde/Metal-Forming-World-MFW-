// Group U7: the parts of OP-24 that need no emulator: the address check, the plain-text title, and
// the time and size limits, against the stand-in site with small limits.
import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { checkBaseUrl, fetchPosts, plainText, SiteError } from '../functions/dist/wordpress.js';
import { startWordPress } from './wp-standin.mjs';

let wp;

before(async () => {
  wp = await startWordPress();
});

after(async () => {
  await wp.close();
});

test('U7 address: HTTPS is accepted, and a missing trailing slash is added', () => {
  assert.equal(checkBaseUrl('https://news.example.test')?.href, 'https://news.example.test/');
  assert.equal(checkBaseUrl(' https://news.example.test/blog ')?.href, 'https://news.example.test/blog/');
});

test('U7 address: plain HTTP only to this machine, and only when allowed (the emulators)', () => {
  assert.equal(checkBaseUrl('http://127.0.0.1:8000', { allowLoopbackHttp: true })?.href, 'http://127.0.0.1:8000/');
  assert.equal(checkBaseUrl('http://localhost:8000', { allowLoopbackHttp: true })?.href, 'http://localhost:8000/');
  assert.equal(checkBaseUrl('http://127.0.0.1:8000', { allowLoopbackHttp: false }), null);
  assert.equal(checkBaseUrl('http://news.example.test', { allowLoopbackHttp: true }), null);
  assert.equal(checkBaseUrl('http://127.0.0.1.example.test', { allowLoopbackHttp: true }), null);
});

test('U7 address: anything else is refused', () => {
  for (const value of [undefined, null, 42, '', '   ', 'news.example.test', 'ftp://news.example.test', 'file:///etc/passwd', 'javascript:alert(1)', 'https://u:p@news.example.test', 'https://news.example.test/?a=1', 'https://news.example.test/#top']) {
    assert.equal(checkBaseUrl(value, { allowLoopbackHttp: true }), null, String(value));
  }
});

test('U7 title: tags are dropped, character references decoded, and spaces tidied', () => {
  assert.equal(plainText('<b>Bold</b> &amp; <a href="x">linked</a>'), 'Bold & linked');
  assert.equal(plainText('MFW&#8217;s &#x201C;expo&#x201D; &hellip;'), 'MFW’s “expo” …');
  assert.equal(plainText('<script>alert(1)</script>Safe'), 'alert(1)Safe');
  assert.equal(plainText('  many\n\n  spaces  '), 'many spaces');
  assert.equal(plainText('&unknown; stays'), '&unknown; stays');
});

// The test has its own limit, so a fetch with no time limit fails here instead of hanging the run.
test('U7 limits: a site that does not answer in time is a SiteError', { timeout: 5000 }, async () => {
  wp.set('hang');
  await assert.rejects(fetchPosts(new URL(`${wp.url}/`), { page: 1, perPage: 5 }, { timeoutMs: 300 }), SiteError);
  wp.reset();
});

test('U7 limits: a reply over the size limit is a SiteError', async () => {
  await assert.rejects(fetchPosts(new URL(`${wp.url}/`), { page: 1, perPage: 5 }, { maxBytes: 100 }), SiteError);
  const fine = await fetchPosts(new URL(`${wp.url}/`), { page: 1, perPage: 5 }, { maxBytes: 100_000 });
  assert.equal(fine.posts.length, 3);
});
