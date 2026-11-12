// SCR-W-02 Issues list (FR-ADMIN-011): published and unpublished issues through OP-15,
// newest publication date first, a page at a time. Placeholder visuals.
import { useCallback, useEffect, useState } from 'react';
import { Link, useLocation } from 'react-router';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import { listIssues } from './data';
import type { Issue, PublicationState } from './data';
import { describeError } from './describeError';

interface Props {
  api: CallFn;
}

type Filter = 'all' | PublicationState;

export function IssuesPage({ api }: Props) {
  const [filter, setFilter] = useState<Filter>('all');
  const [issues, setIssues] = useState<Issue[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState<string | null>(null);
  // A notice handed over by the editor, such as after a deletion.
  const notice = (useLocation().state as { notice?: string } | null)?.notice ?? null;

  const load = useCallback(
    async (more: boolean, from: string | null) => {
      setLoading(true);
      setMessage(null);
      try {
        const page = await listIssues(api, { state: filter === 'all' ? undefined : filter, cursor: more ? from : null });
        setIssues((shown) => (more ? [...shown, ...page.items] : page.items));
        setCursor(page.next_cursor);
      } catch (error) {
        if (error instanceof AccessLost) return;
        setMessage(describeError(error));
      } finally {
        setLoading(false);
      }
    },
    [api, filter],
  );

  useEffect(() => {
    void load(false, null);
  }, [load]);

  return (
    <section>
      <h2>Issues</h2>
      {notice && <p role="status">{notice}</p>}
      <p>
        <Link to="/issues/new">New issue</Link>
      </p>
      <label htmlFor="issue-filter">Show</label>
      <select id="issue-filter" value={filter} onChange={(e) => setFilter(e.target.value as Filter)}>
        <option value="all">All issues</option>
        <option value="published">Published</option>
        <option value="unpublished">Unpublished</option>
      </select>
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
      {!loading && issues.length === 0 && !message && <p>No issues.</p>}
      {issues.length > 0 && (
        <table>
          <thead>
            <tr>
              <th scope="col">Title</th>
              <th scope="col">Publication date</th>
              <th scope="col">State</th>
            </tr>
          </thead>
          <tbody>
            {issues.map((issue) => (
              <tr key={issue.issue_id}>
                <td>
                  <Link to={`/issues/${issue.issue_id}`} state={{ issue }}>
                    {issue.title ?? '(no title)'}
                  </Link>
                </td>
                <td>{issue.publication_date ?? ''}</td>
                <td>{issue.publication_state === 'published' ? 'Published' : 'Unpublished'}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      {loading && <p>Loading…</p>}
      {!loading && cursor && (
        <button type="button" onClick={() => void load(true, cursor)}>
          Show more
        </button>
      )}
    </section>
  );
}
