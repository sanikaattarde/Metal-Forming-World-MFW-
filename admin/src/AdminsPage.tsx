// SCR-W-10 Admins (MOD12-P3-T02; FR-ADMIN-003, FR-ADMIN-004; GS-Q44): the active admins through OP-38, adding a
// verified reader by email address through OP-35, removing an admin through OP-37 with the address typed to
// confirm, and the recent changes through OP-39. SWITCHED OFF until MFW answers OQ-58 (DEC-027): the menu entry
// shows only in a build with VITE_ADMIN_MANAGEMENT=true, and the server refuses unless its own switch is on.
// PROVISIONAL. Placeholder visuals and wording.
import { useCallback, useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import { addAdmin, listAdminChanges, listAdmins, removeAdmin } from './data';
import type { AdminChange, AdminRow } from './data';
import { describeError, ERRORS } from './describeError';

interface Props {
  api: CallFn;
}

export const ADMINS_TEXT = {
  notice: 'Every admin can add and remove admins. A removed admin is signed out and refused at once. At least one admin always remains.',
  added: (email: string) => `${email} is now an admin.`,
  removed: (email: string) => `${email} is no longer an admin.`,
  confirmLabel: (email: string) => `Type ${email} to confirm`,
  action: { admin_add: 'Added', admin_remove: 'Removed', bootstrap_admin: 'First admin' } as Record<string, string>,
} as const;

export function AdminsPage({ api }: Props) {
  const [admins, setAdmins] = useState<AdminRow[]>([]);
  const [changes, setChanges] = useState<AdminChange[]>([]);
  const [email, setEmail] = useState('');
  const [removing, setRemoving] = useState<AdminRow | null>(null);
  const [typed, setTyped] = useState('');
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [status, setStatus] = useState<string | null>(null);

  const load = useCallback(async () => {
    try {
      const [list, log] = await Promise.all([listAdmins(api), listAdminChanges(api)]);
      setAdmins(list.items);
      setChanges(log.items);
    } catch (error) {
      if (!(error instanceof AccessLost)) setMessage(describeError(error));
    }
  }, [api]);

  useEffect(() => {
    void load();
  }, [load]);

  async function run(change: () => Promise<AdminRow>, done: (row: AdminRow) => string) {
    setBusy(true);
    setMessage(null);
    setStatus(null);
    try {
      const row = await change();
      setStatus(done(row));
      setEmail('');
      setRemoving(null);
      setTyped('');
      await load();
    } catch (error) {
      if (error instanceof AccessLost) return;
      const code = (error as { code?: string }).code;
      setMessage(code === 'functions/not-found' ? ERRORS.noAccount : describeError(error));
    } finally {
      setBusy(false);
    }
  }

  function add(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (busy || email.trim() === '') return;
    void run(() => addAdmin(api, email), (row) => ADMINS_TEXT.added(row.email ?? email.trim()));
  }

  const target = removing?.email ?? '';
  const confirmed = removing !== null && typed.trim().toLowerCase() === target.toLowerCase() && target !== '';

  return (
    <section>
      <h2>Admins</h2>
      <p>{ADMINS_TEXT.notice}</p>
      {status && <p role="status">{status}</p>}
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
      <table>
        <thead>
          <tr>
            <th scope="col">Email address</th>
            <th scope="col">Action</th>
          </tr>
        </thead>
        <tbody>
          {admins.map((row) => (
            <tr key={row.user_id}>
              <td>{row.email ?? row.user_id}</td>
              <td>
                <button type="button" disabled={busy} onClick={() => { setRemoving(row); setTyped(''); }}>
                  Remove
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {removing && (
        <div role="group" aria-label="Confirm removal">
          <label htmlFor="remove-confirm">{ADMINS_TEXT.confirmLabel(target)}</label>
          <input id="remove-confirm" autoComplete="off" value={typed} onChange={(e) => setTyped(e.target.value)} />
          <button type="button" className="danger" disabled={busy || !confirmed} onClick={() => void run(() => removeAdmin(api, removing.user_id, typed), () => ADMINS_TEXT.removed(target))}>
            Remove admin
          </button>
          <button type="button" onClick={() => setRemoving(null)}>
            Cancel
          </button>
        </div>
      )}
      <form onSubmit={add}>
        <label htmlFor="new-admin">Add an admin by email address (a registered reader who has verified it)</label>
        <input id="new-admin" type="email" autoComplete="off" value={email} onChange={(e) => setEmail(e.target.value)} />
        <button type="submit" disabled={busy || email.trim() === ''}>
          Add admin
        </button>
      </form>
      <h3>Recent changes</h3>
      {changes.length === 0 ? (
        <p>No changes yet.</p>
      ) : (
        <ul>
          {changes.map((change) => (
            <li key={change.event_id}>
              {ADMINS_TEXT.action[change.action] ?? change.action} {change.occurred_at ? `${change.occurred_at.slice(0, 16).replace('T', ' ')} GMT` : ''}
            </li>
          ))}
        </ul>
      )}
    </section>
  );
}
