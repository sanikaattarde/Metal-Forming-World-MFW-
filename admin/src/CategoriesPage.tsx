// SCR-W-05 Categories (FR-ADMIN-010): issue categories only, through OP-17 and OP-18.
// Segments and notification categories are seeded by the developers (GS-Q47, GS-Q56). A category in use
// cannot be deleted, and deleting asks for confirmation first. Placeholder visuals.
import { useCallback, useEffect, useRef, useState } from 'react';
import type { FormEvent } from 'react';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import { deleteCategory, newRequestId, saveCategory } from './data';
import type { Category, Reads } from './data';
import { describeError } from './describeError';

interface Props {
  api: CallFn;
  read: Reads;
}

interface Row {
  name: string;
  display_order: string;
}

export function CategoriesPage({ api, read }: Props) {
  const [categories, setCategories] = useState<Category[]>([]);
  const [rows, setRows] = useState<Record<string, Row>>({});
  const [newName, setNewName] = useState('');
  const [newOrder, setNewOrder] = useState('');
  const [busy, setBusy] = useState(false);
  const [confirmingDelete, setConfirmingDelete] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [saved, setSaved] = useState<string | null>(null);
  // One request identifier per new category, so a retry finds the record the first try made (OP-17).
  const createRequest = useRef(newRequestId());

  const reload = useCallback(async () => {
    try {
      const list = await read.categories();
      setCategories(list);
      setRows(Object.fromEntries(list.map((c) => [c.category_id, { name: c.name, display_order: String(c.display_order) }])));
    } catch {
      setMessage('The categories could not be loaded.');
    }
  }, [read]);

  useEffect(() => {
    void reload();
  }, [reload]);

  async function run(action: () => Promise<unknown>, done: string) {
    if (busy) return false;
    setBusy(true);
    setMessage(null);
    setSaved(null);
    try {
      await action();
      setSaved(done);
      await reload();
      return true;
    } catch (error) {
      if (!(error instanceof AccessLost)) setMessage(describeError(error));
      return false;
    } finally {
      setBusy(false);
    }
  }

  // An order that is not a whole number is sent as typed, so the server names the field.
  const orderOf = (text: string) => (/^-?\d+$/.test(text.trim()) ? Number(text.trim()) : (text as unknown as number));

  async function add(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const nextOrder = newOrder.trim() === '' ? Math.max(0, ...categories.map((c) => c.display_order)) + 1 : orderOf(newOrder);
    const ok = await run(() => saveCategory(api, { name: newName, display_order: nextOrder }, createRequest.current), 'Category added.');
    if (ok) {
      setNewName('');
      setNewOrder('');
      createRequest.current = newRequestId();
    }
  }

  return (
    <section>
      <h2>Categories</h2>
      <p>Issue categories. Segments and notification categories are set up by the developers.</p>
      {categories.length === 0 ? (
        <p>No categories.</p>
      ) : (
        <table>
          <thead>
            <tr>
              <th scope="col">Name</th>
              <th scope="col">Order</th>
              <th scope="col">Actions</th>
            </tr>
          </thead>
          <tbody>
            {categories.map((c) => {
              const row = rows[c.category_id] ?? { name: c.name, display_order: String(c.display_order) };
              const setRow = (change: Partial<Row>) => setRows((all) => ({ ...all, [c.category_id]: { ...row, ...change } }));
              return (
                <tr key={c.category_id}>
                  <td>
                    <input aria-label={`Name of ${c.name}`} value={row.name} onChange={(e) => setRow({ name: e.target.value })} />
                  </td>
                  <td>
                    <input aria-label={`Order of ${c.name}`} inputMode="numeric" value={row.display_order} onChange={(e) => setRow({ display_order: e.target.value })} />
                  </td>
                  <td>
                    <button
                      type="button"
                      disabled={busy}
                      onClick={() => void run(() => saveCategory(api, { category_id: c.category_id, name: row.name, display_order: orderOf(row.display_order) }), 'Category saved.')}
                    >
                      Save
                    </button>
                    {confirmingDelete === c.category_id ? (
                      <>
                        <button
                          type="button"
                          disabled={busy}
                          onClick={() => {
                            setConfirmingDelete(null);
                            void run(() => deleteCategory(api, c.category_id), 'Category deleted.');
                          }}
                        >
                          {`Confirm delete of ${c.name}`}
                        </button>
                        <button type="button" onClick={() => setConfirmingDelete(null)}>
                          Cancel
                        </button>
                      </>
                    ) : (
                      <button type="button" disabled={busy} onClick={() => setConfirmingDelete(c.category_id)}>
                        {`Delete ${c.name}`}
                      </button>
                    )}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      )}

      <form onSubmit={add}>
        <h3>New category</h3>
        <label htmlFor="new-category-name">Name</label>
        <input id="new-category-name" value={newName} onChange={(e) => setNewName(e.target.value)} />
        <label htmlFor="new-category-order">Order (optional; after the last if empty)</label>
        <input id="new-category-order" inputMode="numeric" value={newOrder} onChange={(e) => setNewOrder(e.target.value)} />
        <button type="submit" disabled={busy}>
          Add category
        </button>
      </form>

      {saved && <p role="status">{saved}</p>}
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
    </section>
  );
}
