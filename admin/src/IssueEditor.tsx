// SCR-W-03 Issue editor (FR-ADMIN-009, FR-ADMIN-011): an issue's details through
// OP-16, and publish and unpublish through OP-21 and OP-22, each confirmed first (CODING_STANDARDS.md §15
// item 7). The PDF and cover upload is left out of this block (W3), so an issue can be published only once a
// file has been accepted some other way. Placeholder visuals.
import { useEffect, useRef, useState } from 'react';
import type { FormEvent } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import { createIssue, findIssue, newRequestId, setPublished, updateIssue } from './data';
import type { Category, Issue, IssueDetails, Reads, Segment } from './data';
import { describeError } from './describeError';

interface Props {
  api: CallFn;
  read: Reads;
}

interface Form {
  title: string;
  description: string;
  category_id: string;
  segment_ids: string[];
  publication_date: string;
  year: string;
  edition: string;
}

const EMPTY: Form = { title: '', description: '', category_id: '', segment_ids: [], publication_date: '', year: '', edition: '' };

const formOf = (issue: Issue): Form => ({
  title: issue.title ?? '',
  description: issue.description ?? '',
  category_id: issue.category_id ?? '',
  segment_ids: issue.segment_ids ?? [],
  publication_date: issue.publication_date ?? '',
  year: issue.year === null || issue.year === undefined ? '' : String(issue.year),
  edition: issue.edition ?? '',
});

// Empty optional fields are left out. A year that is not a whole number is sent as typed, so the server
// names the field (the panel's checks are a convenience only).
function detailsOf(form: Form): IssueDetails {
  const details: IssueDetails = {
    title: form.title,
    description: form.description,
    category_id: form.category_id,
    segment_ids: form.segment_ids,
    publication_date: form.publication_date,
  };
  if (form.year.trim() !== '') details.year = /^\d+$/.test(form.year.trim()) ? Number(form.year.trim()) : (form.year as unknown as number);
  if (form.edition.trim() !== '') details.edition = form.edition;
  return details;
}

export function IssueEditorRoute(props: Props) {
  const { issueId } = useParams();
  return <IssueEditor key={issueId ?? 'new'} issueId={issueId ?? null} {...props} />;
}

export function IssueEditor({ api, read, issueId }: Props & { issueId: string | null }) {
  const navigate = useNavigate();
  const location = useLocation();
  const handedOver = (location.state as { issue?: Issue } | null)?.issue;

  const [issue, setIssue] = useState<Issue | null>(handedOver?.issue_id === issueId ? handedOver : null);
  const [form, setForm] = useState<Form>(issue ? formOf(issue) : EMPTY);
  const [categories, setCategories] = useState<Category[]>([]);
  const [segments, setSegments] = useState<Segment[]>([]);
  const [loading, setLoading] = useState(issueId !== null && issue === null);
  const [busy, setBusy] = useState(false);
  const [confirming, setConfirming] = useState<'publish' | 'unpublish' | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [saved, setSaved] = useState<string | null>(null);
  // One request identifier for the life of a new issue's form, so a retry after a lost reply finds the
  // record the first try made, instead of making a second one (OP-16).
  const createRequest = useRef(newRequestId());

  useEffect(() => {
    read.categories().then(setCategories, () => setMessage('The categories could not be loaded.'));
    read.segments().then(setSegments, () => setSegments([]));
  }, [read]);

  useEffect(() => {
    if (issueId === null || issue !== null) return;
    findIssue(api, issueId).then(
      (found) => {
        setLoading(false);
        if (!found) return setMessage('This issue was not found.');
        setIssue(found);
        setForm(formOf(found));
      },
      (error) => {
        if (error instanceof AccessLost) return;
        setLoading(false);
        setMessage(describeError(error));
      },
    );
  }, [api, issueId, issue]);

  const field = (name: keyof Form) => (e: { target: { value: string } }) => setForm((f) => ({ ...f, [name]: e.target.value }));

  async function save(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (busy) return;
    setBusy(true);
    setMessage(null);
    setSaved(null);
    try {
      const result = issue ? await updateIssue(api, issue, detailsOf(form)) : await createIssue(api, createRequest.current, detailsOf(form));
      setIssue(result);
      setForm(formOf(result));
      setSaved('Saved.');
      if (!issue) navigate(`/issues/${result.issue_id}`, { replace: true, state: { issue: result } });
    } catch (error) {
      if (!(error instanceof AccessLost)) setMessage(describeError(error));
    } finally {
      setBusy(false);
    }
  }

  async function changeState(publish: boolean) {
    if (!issue || busy) return;
    setBusy(true);
    setConfirming(null);
    setMessage(null);
    setSaved(null);
    try {
      const result = await setPublished(api, issue.issue_id, publish);
      setIssue(result);
      setSaved(publish ? 'Published.' : 'Unpublished.');
    } catch (error) {
      if (!(error instanceof AccessLost)) setMessage(describeError(error));
    } finally {
      setBusy(false);
    }
  }

  if (loading) return <p>Loading…</p>;
  if (issueId !== null && !issue) {
    return (
      <section>
        <h2>Issue</h2>
        <p role="alert" className="message">
          {message ?? 'This issue was not found.'}
        </p>
      </section>
    );
  }

  const published = issue?.publication_state === 'published';

  return (
    <section>
      <h2>{issue ? 'Edit issue' : 'New issue'}</h2>
      {issue && (
        <p>
          State: <strong>{published ? 'Published' : 'Unpublished'}</strong>
          {issue.current_revision ? ` · File revision ${issue.current_revision}` : ' · No accepted file'}
        </p>
      )}
      <form onSubmit={save}>
        <label htmlFor="title">Title</label>
        <input id="title" value={form.title} onChange={field('title')} />
        <label htmlFor="description">Description</label>
        <textarea id="description" rows={4} value={form.description} onChange={field('description')} />
        <label htmlFor="category">Category</label>
        <select id="category" value={form.category_id} onChange={field('category_id')}>
          <option value="">Choose a category</option>
          {categories.map((c) => (
            <option key={c.category_id} value={c.category_id}>
              {c.name}
            </option>
          ))}
        </select>
        {segments.length > 0 && (
          <fieldset>
            <legend>Segments</legend>
            {segments.map((s) => (
              <label key={s.segment_id}>
                <input
                  type="checkbox"
                  checked={form.segment_ids.includes(s.segment_id)}
                  onChange={(e) =>
                    setForm((f) => ({
                      ...f,
                      segment_ids: e.target.checked ? [...f.segment_ids, s.segment_id] : f.segment_ids.filter((id) => id !== s.segment_id),
                    }))
                  }
                />
                {s.name}
              </label>
            ))}
          </fieldset>
        )}
        <label htmlFor="publication-date">Publication date</label>
        <input id="publication-date" type="date" value={form.publication_date} onChange={field('publication_date')} />
        <label htmlFor="year">Year (optional; the publication date's year if empty)</label>
        <input id="year" inputMode="numeric" value={form.year} onChange={field('year')} />
        <label htmlFor="edition">Edition (optional)</label>
        <input id="edition" value={form.edition} onChange={field('edition')} />
        <button type="submit" disabled={busy}>
          {issue ? 'Save changes' : 'Create issue'}
        </button>
      </form>

      {issue && confirming === null && (
        <button type="button" disabled={busy} onClick={() => setConfirming(published ? 'unpublish' : 'publish')}>
          {published ? 'Unpublish' : 'Publish'}
        </button>
      )}
      {issue && confirming !== null && (
        <div role="group" aria-label="Confirm">
          <p>{confirming === 'publish' ? 'Publish this issue? Readers will see it in the catalogue.' : 'Unpublish this issue? Readers will no longer see it, and no new download link is issued.'}</p>
          <button type="button" onClick={() => void changeState(confirming === 'publish')}>
            {confirming === 'publish' ? 'Confirm publish' : 'Confirm unpublish'}
          </button>
          <button type="button" onClick={() => setConfirming(null)}>
            Cancel
          </button>
        </div>
      )}

      {saved && <p role="status">{saved}</p>}
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
    </section>
  );
}
