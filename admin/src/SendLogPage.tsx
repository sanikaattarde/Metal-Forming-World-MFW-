// SCR-W-08 Send log (FR-ADMIN-018, FR-STATE-007, MOD12-P2-T05): every notification sent, newest first, through
// OP-27, and a retry of one that failed or never reported back, through OP-26. Nothing retries on its own
// (INV-17). The columns wait for OQ-19 (PROVISIONAL). Placeholder visuals and wording.
import { useCallback, useEffect, useState } from 'react';
import { Link } from 'react-router';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import { listSends, retryNotification } from './data';
import type { Reads, SendOutcome, SendRecord } from './data';
import { describeError } from './describeError';

interface Props {
  api: CallFn;
  read: Reads;
}

export const OUTCOME_LABELS: Record<SendOutcome, string> = {
  accepted: 'Accepted',
  failed: 'Failed',
  unknown: 'Unknown',
  pending: 'Sending',
};

export const LOG_TEXT = {
  empty: 'No notifications have been sent.',
  retried: 'Sent again. The push service accepted the notification.',
} as const;

// GMT, as the other panel times are, so that two admins see the same time.
export const showTime = (millis: number | null): string => (millis === null ? '' : `${new Date(millis).toISOString().slice(0, 16).replace('T', ' ')} GMT`);

const opens = (send: SendRecord): string => {
  if (send.target_type === 'issue') return `Issue ${send.target_ref ?? ''}`;
  if (send.target_type === 'news_post') return `Post ${send.target_ref ?? ''}`;
  return 'The app';
};

const retryable = (outcome: SendOutcome) => outcome === 'failed' || outcome === 'unknown';

export function SendLogPage({ api, read }: Props) {
  const [filter, setFilter] = useState<SendOutcome | ''>('');
  const [sends, setSends] = useState<SendRecord[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);
  const [names, setNames] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [status, setStatus] = useState<string | null>(null);

  const load = useCallback(
    async (more: string | null) => {
      setLoading(true);
      setMessage(null);
      try {
        const page = await listSends(api, { outcome: filter || undefined, cursor: more });
        setSends((current) => (more ? [...current, ...page.items] : page.items));
        setCursor(page.next_cursor);
      } catch (error) {
        if (!(error instanceof AccessLost)) setMessage(describeError(error));
      } finally {
        setLoading(false);
      }
    },
    [api, filter],
  );

  useEffect(() => {
    void load(null);
  }, [load]);

  useEffect(() => {
    read.notificationCategories().then(
      (all) => setNames(Object.fromEntries(all.map((category) => [category.category_id, category.name]))),
      () => undefined, // the identifier is shown instead
    );
  }, [read]);

  async function retry(send: SendRecord) {
    setBusy(send.send_id);
    setMessage(null);
    setStatus(null);
    const update = (change: Partial<SendRecord>) => setSends((all) => all.map((item) => (item.send_id === send.send_id ? { ...item, ...change } : item)));
    try {
      const result = await retryNotification(api, send.send_id);
      update({ outcome: result.outcome, attempt_count: send.attempt_count + 1 });
      setStatus(LOG_TEXT.retried);
    } catch (error) {
      if (error instanceof AccessLost) return;
      const reason = (error as { details?: { reason?: unknown } }).details?.reason;
      if (reason === 'PUSH_FAILED') update({ outcome: 'failed', attempt_count: send.attempt_count + 1 });
      if (reason === 'NOT_RETRYABLE') update({ outcome: 'accepted' });
      setMessage(describeError(error));
    } finally {
      setBusy(null);
    }
  }

  return (
    <section>
      <h2>Send log</h2>
      <p>
        <Link to="/notifications/new">Send a notification</Link>
      </p>
      <label>
        Show
        <select value={filter} onChange={(e) => setFilter(e.target.value as SendOutcome | '')}>
          <option value="">All</option>
          {(Object.keys(OUTCOME_LABELS) as SendOutcome[]).map((outcome) => (
            <option key={outcome} value={outcome}>
              {OUTCOME_LABELS[outcome]}
            </option>
          ))}
        </select>
      </label>
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
      {status && <p role="status">{status}</p>}
      {!loading && sends.length === 0 && !message && <p>{LOG_TEXT.empty}</p>}
      {sends.length > 0 && (
        <table>
          <thead>
            <tr>
              <th scope="col">Sent</th>
              <th scope="col">Category</th>
              <th scope="col">Title</th>
              <th scope="col">Opens</th>
              <th scope="col">Outcome</th>
              <th scope="col">Attempts</th>
              <th scope="col">Actions</th>
            </tr>
          </thead>
          <tbody>
            {sends.map((send) => (
              <tr key={send.send_id}>
                <td>{showTime(send.sent_at)}</td>
                <td>{names[send.category_id] ?? send.category_id}</td>
                <td>{send.title}</td>
                <td>{opens(send)}</td>
                <td>{OUTCOME_LABELS[send.outcome] ?? send.outcome}</td>
                <td>{send.attempt_count}</td>
                <td>
                  {retryable(send.outcome) && (
                    <button type="button" disabled={busy !== null} onClick={() => void retry(send)}>
                      {`Retry ${send.title}`}
                    </button>
                  )}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
      {loading && <p>Loading…</p>}
      {cursor && !loading && (
        <button type="button" onClick={() => void load(cursor)}>
          Load more
        </button>
      )}
    </section>
  );
}
