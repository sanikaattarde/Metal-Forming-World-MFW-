// SCR-W-09 Registered users (FR-USER-002, FR-USER-003, NFR-PRIV-004, PAC-03, MOD12-P2-T06): the registered
// readers with their profile fields through OP-31, and a CSV export through OP-32, built on the server with
// formula cells neutralised (SEC-CHK-12). PROVISIONAL: who may see it is OQ-51, the fields wait for OQ-01, and
// whether this is the "subscriber list" is OQ-31. Any admin, on the working position (GS-Q49). The export is
// handed to the admin as a file and nothing is kept in the browser. Placeholder visuals and wording.
import { useCallback, useEffect, useState } from 'react';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import { exportReaders, listReaders } from './data';
import type { Reads, ReaderRow } from './data';
import { describeError } from './describeError';
import type { SaveText } from './services';

interface Props {
  api: CallFn;
  read: Reads;
  saveText: SaveText;
}

export const READER_TEXT = {
  notice: 'This list holds personal data. Use it and its export only for the purpose MFW has agreed, and do not keep copies longer than needed.',
  empty: 'No readers have registered yet.',
  exported: (count: number) => `Exported ${count} ${count === 1 ? 'reader' : 'readers'}.`,
} as const;

// A byte-order mark, so that a spreadsheet opens the file as UTF-8 and names keep their accents.
const BOM = '﻿';

const show = (value: string | number | null) => (value === null || value === '' ? '' : String(value));

export function RegisteredUsersPage({ api, read, saveText }: Props) {
  const [rows, setRows] = useState<ReaderRow[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);
  const [segments, setSegments] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(true);
  const [exporting, setExporting] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [status, setStatus] = useState<string | null>(null);

  const load = useCallback(
    async (more: string | null) => {
      setLoading(true);
      setMessage(null);
      try {
        const page = await listReaders(api, more);
        setRows((current) => (more ? [...current, ...page.items] : page.items));
        setCursor(page.next_cursor);
      } catch (error) {
        if (!(error instanceof AccessLost)) setMessage(describeError(error));
      } finally {
        setLoading(false);
      }
    },
    [api],
  );

  useEffect(() => {
    void load(null);
  }, [load]);

  useEffect(() => {
    read.segments().then(
      (all) => setSegments(Object.fromEntries(all.map((segment) => [segment.segment_id, segment.name]))),
      () => undefined, // the identifier is shown instead
    );
  }, [read]);

  async function exportAll() {
    setExporting(true);
    setMessage(null);
    setStatus(null);
    try {
      const file = await exportReaders(api);
      saveText(file.file_name, BOM + file.csv, 'text/csv;charset=utf-8');
      setStatus(READER_TEXT.exported(file.row_count));
    } catch (error) {
      if (!(error instanceof AccessLost)) setMessage(describeError(error));
    } finally {
      setExporting(false);
    }
  }

  return (
    <section>
      <h2>Registered readers</h2>
      <p>{READER_TEXT.notice}</p>
      <button type="button" disabled={exporting} onClick={() => void exportAll()}>
        Export as CSV
      </button>
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
      {status && <p role="status">{status}</p>}
      {!loading && rows.length === 0 && !message && <p>{READER_TEXT.empty}</p>}
      {rows.length > 0 && (
        <table>
          <thead>
            <tr>
              <th scope="col">Email</th>
              <th scope="col">Full name</th>
              <th scope="col">Age</th>
              <th scope="col">Gender</th>
              <th scope="col">Occupation</th>
              <th scope="col">Domain of work</th>
              <th scope="col">Registered</th>
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr key={row.user_id}>
                <td>{show(row.email)}</td>
                <td>{show(row.full_name)}</td>
                <td>{show(row.age_value)}</td>
                <td>{show(row.gender)}</td>
                <td>{show(row.job_title)}</td>
                <td>{row.industry_segment_id ? (segments[row.industry_segment_id] ?? row.industry_segment_id) : ''}</td>
                <td>{row.created_at === null ? '' : new Date(row.created_at).toISOString().slice(0, 10)}</td>
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
