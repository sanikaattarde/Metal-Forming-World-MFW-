// A stand-in for MFW's WordPress REST API, for the tests of OP-24 and of OP-25's link check. MFW has not given the site's address
// (OQ-39), and no test reads the live site. It serves generated posts on 127.0.0.1, pages them the way the
// API is documented to (TD-12, VS-41), records each request, and can be told to misbehave.
import { createServer } from 'node:http';

export const MODES = ['ok', 'status500', 'notJson', 'notList', 'badItem', 'scriptLink', 'redirect', 'hang', 'huge', 'noPagesHeader'];

export const makePosts = (count) =>
  Array.from({ length: count }, (_, i) => ({
    id: 100 + i,
    title: { rendered: `Post ${i + 1}` },
    date: `2026-10-${String((i % 28) + 1).padStart(2, '0')}T09:00:00`,
    link: `https://news.example.test/post-${i + 1}/`,
    categories: [i % 2 === 0 ? 7 : 8],
    content: { rendered: '<p>Body that OP-24 must not ask for.</p>' },
  }));

export async function startWordPress({ posts = makePosts(3) } = {}) {
  const state = { mode: 'ok', posts, requests: [] };
  const sockets = new Set();

  const server = createServer((req, res) => {
    const url = new URL(req.url, 'http://127.0.0.1');
    state.requests.push({ method: req.method, path: url.pathname, query: Object.fromEntries(url.searchParams), headers: { ...req.headers } });
    const json = (status, body, headers = {}) => {
      res.writeHead(status, { 'Content-Type': 'application/json', ...headers });
      res.end(JSON.stringify(body));
    };

    // Where the redirect mode points: a page that answers with good posts, so that following a redirect
    // would succeed, and a test can tell that OP-24 refused it.
    if (url.pathname === '/elsewhere/wp-json/wp/v2/posts') return json(200, [], { 'X-WP-TotalPages': '1' });
    // One post, for OP-25's link check.
    const one = /^\/wp-json\/wp\/v2\/posts\/(\d+)$/.exec(url.pathname);
    if (one) {
      if (state.mode === 'status500') return json(500, {});
      if (state.mode === 'hang') return; // never answers
      if (state.mode === 'redirect') {
        res.writeHead(302, { Location: `http://127.0.0.1:${server.address().port}/elsewhere/wp-json/wp/v2/posts` });
        return res.end();
      }
      const post = state.posts.find((p) => p.id === Number(one[1]));
      if (!post) return json(404, { code: 'rest_post_invalid_id', message: 'Invalid post ID.' });
      return json(200, url.searchParams.get('_fields') === 'id' ? { id: post.id } : post);
    }
    if (url.pathname !== '/wp-json/wp/v2/posts') return json(404, { code: 'rest_no_route' });
    switch (state.mode) {
      case 'status500':
        // A body that looks like a usable empty list, so only the status shows the failure.
        return json(500, [], { 'X-WP-TotalPages': '1' });
      case 'notJson':
        res.writeHead(200, { 'Content-Type': 'text/html' });
        return res.end('<html>maintenance</html>');
      case 'notList':
        return json(200, { posts: [] });
      case 'redirect':
        res.writeHead(302, { Location: `http://127.0.0.1:${server.address().port}/elsewhere/wp-json/wp/v2/posts${url.search}` });
        return res.end();
      case 'hang':
        return; // never answers
      case 'huge':
        res.writeHead(200, { 'Content-Type': 'application/json' });
        return res.end(`[${'"x",'.repeat(400_000)}"x"]`);
      default:
        break;
    }

    const category = url.searchParams.get('categories');
    const all = state.posts.filter((p) => !category || p.categories.includes(Number(category)));
    const perPage = Number(url.searchParams.get('per_page') ?? 10);
    const page = Number(url.searchParams.get('page') ?? 1);
    const totalPages = Math.max(1, Math.ceil(all.length / perPage));
    const headers = state.mode === 'noPagesHeader' ? {} : { 'X-WP-Total': String(all.length), 'X-WP-TotalPages': String(totalPages) };
    if (page > totalPages) return json(400, { code: 'rest_post_invalid_page_number', message: 'The page number requested is larger than the number of pages available.' }, headers);

    let items = all.slice((page - 1) * perPage, page * perPage);
    if (state.mode === 'badItem') items = items.map((p, i) => (i === 0 ? { ...p, title: undefined } : p));
    if (state.mode === 'scriptLink') items = items.map((p, i) => (i === 0 ? { ...p, link: 'javascript:alert(1)' } : p));
    // The API honours _fields; the stand-in does too, so a request for more is visible in the reply.
    const fields = url.searchParams.get('_fields')?.split(',');
    if (fields) items = items.map((p) => Object.fromEntries(Object.entries(p).filter(([key]) => fields.includes(key))));
    return json(200, items, headers);
  });
  server.on('connection', (socket) => {
    sockets.add(socket);
    socket.on('close', () => sockets.delete(socket));
  });

  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const { port } = server.address();
  return {
    url: `http://127.0.0.1:${port}`,
    state,
    set(mode) {
      state.mode = mode;
    },
    reset(nextPosts = posts) {
      state.mode = 'ok';
      state.posts = nextPosts;
      state.requests.length = 0;
    },
    close() {
      for (const socket of sockets) socket.destroy();
      return new Promise((resolve) => server.close(resolve));
    },
  };
}
