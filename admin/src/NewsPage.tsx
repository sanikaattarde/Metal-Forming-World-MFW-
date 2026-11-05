// SPIKE (DEC-004 OPEN). SCR-W-06 News controls (FR-ADMIN-013, FR-ADMIN-014): pick a WordPress post, hide it
// in the app, or mark it as breaking. Posts come through OP-24 on the server and the flags are saved through
// OP-23. The panel does not write or edit news. Marking a post as breaking sends no notification: that is
// OP-25, which is not built (AC-9.7 is not claimed). Placeholder visuals.
import { useCallback, useEffect, useState } from 'react';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import { listPosts, setNewsControl } from './data';
import type { PostPage, Reads } from './data';
import { describeError } from './describeError';

interface Props {
  api: CallFn;
  read: Reads;
}

interface Flags {
  is_hidden: boolean;
  is_breaking: boolean;
}

const NONE: Flags = { is_hidden: false, is_breaking: false };

export function NewsPage({ api, read }: Props) {
  const [page, setPage] = useState(1);
  const [result, setResult] = useState<PostPage | null>(null);
  const [saved, setSavedFlags] = useState<Record<number, Flags>>({});
  const [drafts, setDrafts] = useState<Record<number, Flags>>({});
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState<number | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [status, setStatus] = useState<string | null>(null);

  const load = useCallback(
    async (which: number) => {
      setLoading(true);
      setMessage(null);
      try {
        const [posts, controls] = await Promise.all([listPosts(api, which), read.newsControls()]);
        const flags = Object.fromEntries(controls.map((c) => [c.wp_post_id, { is_hidden: c.is_hidden, is_breaking: c.is_breaking }]));
        setResult(posts);
        setSavedFlags(flags);
        setDrafts(flags);
      } catch (error) {
        if (error instanceof AccessLost) return;
        setResult(null);
        setMessage(describeError(error));
      } finally {
        setLoading(false);
      }
    },
    [api, read],
  );

  useEffect(() => {
    void load(page);
  }, [load, page]);

  async function save(postId: number) {
    const flags = drafts[postId] ?? NONE;
    setBusy(postId);
    setMessage(null);
    setStatus(null);
    try {
      await setNewsControl(api, { wp_post_id: postId, ...flags });
      setSavedFlags((all) => ({ ...all, [postId]: flags }));
      setStatus('Saved.');
    } catch (error) {
      if (!(error instanceof AccessLost)) setMessage(describeError(error));
    } finally {
      setBusy(null);
    }
  }

  const posts = result?.posts ?? [];
  const totalPages = result?.total_pages ?? null;
  const hasNext = totalPages === null ? posts.length === (result?.per_page ?? 0) && posts.length > 0 : page < totalPages;

  return (
    <section>
      <h2>News</h2>
      <p>Hide a post in the app, or mark it as breaking. Marking a post as breaking does not send a notification.</p>
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
      {loading && <p>Loading…</p>}
      {!loading && result && posts.length === 0 && <p>No posts on this page.</p>}
      {posts.length > 0 && (
        <table>
          <thead>
            <tr>
              <th scope="col">Title</th>
              <th scope="col">Date</th>
              <th scope="col">Hidden</th>
              <th scope="col">Breaking</th>
              <th scope="col">Actions</th>
            </tr>
          </thead>
          <tbody>
            {posts.map((post) => {
              const draft = drafts[post.id] ?? NONE;
              const current = saved[post.id] ?? NONE;
              const changed = draft.is_hidden !== current.is_hidden || draft.is_breaking !== current.is_breaking;
              const set = (change: Partial<Flags>) => setDrafts((all) => ({ ...all, [post.id]: { ...draft, ...change } }));
              return (
                <tr key={post.id}>
                  <td>
                    {post.title}{' '}
                    <a href={post.link} target="_blank" rel="noopener noreferrer">
                      Open post
                    </a>
                  </td>
                  <td>{post.date.slice(0, 10)}</td>
                  <td>
                    <input type="checkbox" aria-label={`Hide ${post.title}`} checked={draft.is_hidden} onChange={(e) => set({ is_hidden: e.target.checked })} />
                  </td>
                  <td>
                    <input type="checkbox" aria-label={`Mark ${post.title} as breaking`} checked={draft.is_breaking} onChange={(e) => set({ is_breaking: e.target.checked })} />
                  </td>
                  <td>
                    <button type="button" disabled={!changed || busy !== null} onClick={() => void save(post.id)}>
                      {`Save ${post.title}`}
                    </button>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}
      {result && (
        <p>
          <button type="button" disabled={loading || page <= 1} onClick={() => setPage((p) => p - 1)}>
            Previous
          </button>{' '}
          {totalPages === null ? `Page ${page}` : `Page ${page} of ${totalPages}`}{' '}
          <button type="button" disabled={loading || !hasNext} onClick={() => setPage((p) => p + 1)}>
            Next
          </button>
        </p>
      )}
      {status && <p role="status">{status}</p>}
    </section>
  );
}
