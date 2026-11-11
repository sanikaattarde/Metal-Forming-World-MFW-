// SCR-W-07 Send notification (FR-ADMIN-015 to FR-ADMIN-017, MOD12-P2-T05): a notification to one category,
// opening an issue, a news post or nothing. The panel checks the form before it sends, and asks once more
// before the send, which cannot be taken back; the server checks everything again (OP-25). Categories are the
// three fixed ones (GS-Q47, OQ-18). Placeholder visuals and wording: there is no M2 design.
import { useEffect, useState } from 'react';
import type { FormEvent } from 'react';
import { Link, useSearchParams } from 'react-router';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import {
  listPosts,
  newRequestId,
  PLACEHOLDER_MAX_BODY_LENGTH,
  PLACEHOLDER_MAX_TITLE_LENGTH,
  publishedIssues,
  sendNotification,
} from './data';
import type { Issue, NotificationCategory, NotificationDraft, Post, Reads, TargetType } from './data';
import { describeError } from './describeError';

interface Props {
  api: CallFn;
  read: Reads;
}

export const SEND_TEXT = {
  sent: 'Sent. The push service accepted the notification. That is not a delivery receipt.',
  noCategories: 'No notification categories are available.',
  postsUnavailable: 'The news posts could not be loaded, so a post cannot be linked now.',
  confirm: 'Send this notification now? It cannot be taken back.',
} as const;

export const FIELD_ERRORS = {
  category_id: 'Choose a category.',
  title: `Enter a title of up to ${PLACEHOLDER_MAX_TITLE_LENGTH} characters.`,
  body: `Enter a message of up to ${PLACEHOLDER_MAX_BODY_LENGTH} characters.`,
  target_ref: 'Choose what the notification opens.',
} as const;

type Field = keyof typeof FIELD_ERRORS;

// The panel's own check, before anything is sent. A convenience only: OP-25 checks again.
export function checkDraft(draft: NotificationDraft): Field[] {
  const problems: Field[] = [];
  const title = draft.title.trim();
  const body = draft.body.trim();
  if (!draft.category_id) problems.push('category_id');
  if (!title || title.length > PLACEHOLDER_MAX_TITLE_LENGTH) problems.push('title');
  if (!body || body.length > PLACEHOLDER_MAX_BODY_LENGTH) problems.push('body');
  if (draft.target_type !== 'none' && !draft.target_ref) problems.push('target_ref');
  return problems;
}

const EMPTY: NotificationDraft = { category_id: '', title: '', body: '', target_type: 'none' };

export function SendNotificationPage({ api, read }: Props) {
  const [params] = useSearchParams();
  const linkedPost = params.get('post');
  const [draft, setDraft] = useState<NotificationDraft>(linkedPost ? { ...EMPTY, target_type: 'news_post', target_ref: linkedPost } : EMPTY);
  const [requestId, setRequestId] = useState(newRequestId);
  const [categories, setCategories] = useState<NotificationCategory[] | null>(null);
  const [issues, setIssues] = useState<Issue[]>([]);
  const [posts, setPosts] = useState<Post[] | null>(null);
  const [postsFailed, setPostsFailed] = useState(false);
  const [problems, setProblems] = useState<Field[]>([]);
  const [reviewing, setReviewing] = useState(false);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [status, setStatus] = useState<string | null>(null);

  useEffect(() => {
    let live = true;
    Promise.all([read.notificationCategories(), publishedIssues(api)]).then(
      ([all, published]) => {
        if (!live) return;
        setCategories(all.filter((category) => category.is_active));
        setIssues(published);
      },
      (error: unknown) => {
        if (!live || error instanceof AccessLost) return;
        setCategories([]);
        setMessage(describeError(error));
      },
    );
    return () => {
      live = false;
    };
  }, [api, read]);

  // The posts are read only when a post is to be linked, through OP-24 on the server (TD-12).
  const wantsPosts = draft.target_type === 'news_post';
  useEffect(() => {
    if (!wantsPosts || posts !== null) return;
    let live = true;
    listPosts(api, 1).then(
      (page) => live && setPosts(page.posts),
      (error: unknown) => {
        if (!live || error instanceof AccessLost) return;
        setPosts([]);
        setPostsFailed(true);
      },
    );
    return () => {
      live = false;
    };
  }, [api, wantsPosts, posts]);

  const change = (update: Partial<NotificationDraft>) => {
    setDraft((current) => ({ ...current, ...update }));
    setStatus(null);
  };

  function review(event: FormEvent) {
    event.preventDefault();
    const found = checkDraft(draft);
    setProblems(found);
    setMessage(null);
    setStatus(null);
    if (found.length === 0) setReviewing(true);
  }

  async function send() {
    setBusy(true);
    setMessage(null);
    try {
      await sendNotification(api, requestId, { ...draft, title: draft.title.trim(), body: draft.body.trim() });
      setStatus(SEND_TEXT.sent);
      setDraft(EMPTY);
      setRequestId(newRequestId());
      setReviewing(false);
    } catch (error) {
      if (error instanceof AccessLost) return;
      const reason = (error as { details?: { reason?: unknown } }).details?.reason;
      // A failed push left a record, so the next send is a new one. A refusal wrote nothing.
      if (reason === 'PUSH_FAILED') {
        setRequestId(newRequestId());
        setDraft(EMPTY);
      }
      setMessage(describeError(error));
      setReviewing(false);
    } finally {
      setBusy(false);
    }
  }

  const categoryName = categories?.find((category) => category.category_id === draft.category_id)?.name ?? '';
  const targetLabel = (type: TargetType, ref?: string) => {
    if (type === 'issue') return `The issue ${issues.find((issue) => issue.issue_id === ref)?.title ?? ref}`;
    if (type === 'news_post') return `The news post ${posts?.find((post) => String(post.id) === ref)?.title ?? ref}`;
    return 'Nothing: the app opens';
  };
  const error = (field: Field) =>
    problems.includes(field) ? (
      <span className="field-error" id={`${field}-error`}>
        {FIELD_ERRORS[field]}
      </span>
    ) : null;

  return (
    <section>
      <h2>Send a notification</h2>
      <p>
        The notification goes to every device that chose its category. <Link to="/notifications">Open the send log</Link>
      </p>
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
      {status && <p role="status">{status}</p>}
      {categories === null && <p>Loading…</p>}
      {categories !== null && categories.length === 0 && !message && <p>{SEND_TEXT.noCategories}</p>}
      {categories !== null && categories.length > 0 && !reviewing && (
        <form onSubmit={review} noValidate>
          <label>
            Category
            <select value={draft.category_id} onChange={(e) => change({ category_id: e.target.value })} aria-invalid={problems.includes('category_id')}>
              <option value="">Choose a category</option>
              {categories.map((category) => (
                <option key={category.category_id} value={category.category_id}>
                  {category.name}
                </option>
              ))}
            </select>
          </label>
          {error('category_id')}
          <label>
            Title
            <input value={draft.title} onChange={(e) => change({ title: e.target.value })} aria-invalid={problems.includes('title')} />
          </label>
          <span className="hint">{`${draft.title.trim().length} of ${PLACEHOLDER_MAX_TITLE_LENGTH} characters`}</span>
          {error('title')}
          <label>
            Message
            <textarea value={draft.body} onChange={(e) => change({ body: e.target.value })} aria-invalid={problems.includes('body')} />
          </label>
          <span className="hint">{`${draft.body.trim().length} of ${PLACEHOLDER_MAX_BODY_LENGTH} characters`}</span>
          {error('body')}
          <fieldset>
            <legend>Opens</legend>
            {(
              [
                ['none', 'Nothing: the app opens'],
                ['issue', 'An issue'],
                ['news_post', 'A news post'],
              ] as const
            ).map(([type, label]) => (
              <label key={type}>
                <input type="radio" name="target_type" checked={draft.target_type === type} onChange={() => change({ target_type: type, target_ref: undefined })} />
                {label}
              </label>
            ))}
          </fieldset>
          {draft.target_type === 'issue' && (
            <label>
              Issue
              <select value={draft.target_ref ?? ''} onChange={(e) => change({ target_ref: e.target.value || undefined })}>
                <option value="">Choose a published issue</option>
                {issues.map((issue) => (
                  <option key={issue.issue_id} value={issue.issue_id}>
                    {issue.title ?? issue.issue_id}
                  </option>
                ))}
              </select>
            </label>
          )}
          {draft.target_type === 'news_post' && (
            <label>
              News post
              <select value={draft.target_ref ?? ''} onChange={(e) => change({ target_ref: e.target.value || undefined })}>
                <option value="">Choose a post</option>
                {linkedPost && !(posts ?? []).some((post) => String(post.id) === linkedPost) && <option value={linkedPost}>{`Post ${linkedPost}`}</option>}
                {(posts ?? []).map((post) => (
                  <option key={post.id} value={String(post.id)}>
                    {post.title}
                  </option>
                ))}
              </select>
            </label>
          )}
          {postsFailed && draft.target_type === 'news_post' && <p>{SEND_TEXT.postsUnavailable}</p>}
          {error('target_ref')}
          <button type="submit">Review</button>
        </form>
      )}
      {reviewing && (
        <div aria-label="Review the notification" role="group">
          <p>{SEND_TEXT.confirm}</p>
          <dl>
            <dt>Category</dt>
            <dd>{categoryName}</dd>
            <dt>Title</dt>
            <dd>{draft.title.trim()}</dd>
            <dt>Message</dt>
            <dd>{draft.body.trim()}</dd>
            <dt>Opens</dt>
            <dd>{targetLabel(draft.target_type, draft.target_ref)}</dd>
          </dl>
          <button type="button" disabled={busy} onClick={() => void send()}>
            Send now
          </button>{' '}
          <button type="button" disabled={busy} onClick={() => setReviewing(false)}>
            Back to edit
          </button>
        </div>
      )}
    </section>
  );
}
