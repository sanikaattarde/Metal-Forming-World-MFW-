// The cover part of SCR-W-04, in the issue editor (FR-ADMIN-008, MOD12-P2-T02; OQ-22 working position of
// 14 November 2026, PROVISIONAL): choose a JPEG or PNG, see it, upload it through OP-19, and follow OP-40's
// check through OP-20. The server checks the format, the size, the width and the shape, and stores a clean
// JPEG copy; the panel checks only the type and the size, to save a wasted upload. An issue is published
// only with a cover. A replacement keeps the current cover until the new one is accepted. Placeholder visuals.
import { useEffect, useState } from 'react';
import type { CallFn } from './adminApi';
import { COVER_TYPES } from './data';
import type { UploadJob, UploadLimits } from './data';
import type { FileSender } from './services';
import { megabytes, useUploadFlow } from './uploadFlow';

interface Props {
  api: CallFn;
  upload: FileSender;
  issueId: string;
  coverUrl: string | null;
  limits: UploadLimits | null;
  onAccepted: () => void;
}

export const COVER_TEXT = {
  notImage: 'Choose a JPEG or PNG image.',
  empty: 'The image is empty.',
  tooLarge: 'The image is larger than the cover limit.',
  none: 'No cover yet. An issue needs a cover before it can be published.',
  replaceNote: 'The current cover stays until a new one is accepted.',
  accepted: 'Cover accepted. The server stored a copy without the photo details.',
  rules: (limits: UploadLimits) =>
    `A JPEG or PNG of up to ${megabytes(limits.cover.max_bytes)}, at least ${limits.cover.min_width_px} pixels wide, ` +
    `and portrait: its height between ${limits.cover.min_height_ratio} and ${limits.cover.max_height_ratio} times its width (A4 is 1.41).`,
} as const;

export const COVER_REJECTIONS: Record<string, string> = {
  FORMAT: 'The image is not a JPEG or PNG file, so it was deleted.',
  UNREADABLE: 'The image could not be read. It may be damaged, or too large in pixels. It was deleted.',
  TOO_NARROW: 'The image is narrower than the minimum width, so it was deleted.',
  SHAPE: 'The image is not a portrait close to A4 in shape, so it was deleted.',
  OVER_LIMIT: 'The image is larger than the cover limit, so it was deleted.',
  UPLOADER_NOT_AUTHORISED: 'Your admin access had ended when the image arrived, so it was deleted.',
  ISSUE_NOT_FOUND: 'The issue no longer exists, so the image was deleted.',
  NO_PENDING_JOB: 'The image was not expected, so it was deleted. Upload it again.',
};

export const coverRejectionText = (job: Pick<UploadJob, 'reason' | 'detail'>) =>
  (job.reason === 'COVER_INVALID' ? job.detail && COVER_REJECTIONS[job.detail] : job.reason && COVER_REJECTIONS[job.reason]) ??
  'The image was refused and deleted.';

const jobLine = (job: UploadJob) => {
  if (job.status === 'accepted') return 'Accepted';
  if (job.status === 'rejected') return coverRejectionText(job);
  return 'Waiting for the image or the check';
};

// The type the browser reports, or one read from the name when it reports none.
const typeOf = (file: File): string => {
  if (file.type) return file.type;
  const name = file.name.toLowerCase();
  if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
  if (name.endsWith('.png')) return 'image/png';
  return '';
};

// A preview of the chosen image, made in the browser. Nothing is sent to show it.
function usePreview(file: File | null): string | null {
  const [url, setUrl] = useState<string | null>(null);
  useEffect(() => {
    if (!file || typeof URL.createObjectURL !== 'function') return setUrl(null);
    const made = URL.createObjectURL(file);
    setUrl(made);
    return () => URL.revokeObjectURL(made);
  }, [file]);
  return url;
}

export function CoverSection({ api, upload, issueId, coverUrl, limits, onAccepted }: Props) {
  const allowed: readonly string[] = limits?.cover.content_types ?? COVER_TYPES;
  const { file, choose, start, jobs, busy, progress, message, status } = useUploadFlow({
    api,
    upload,
    issueId,
    kind: 'cover',
    refuse: (chosen) => {
      if (!allowed.includes(typeOf(chosen))) return COVER_TEXT.notImage;
      if (chosen.size === 0) return COVER_TEXT.empty;
      if (limits && chosen.size > limits.cover.max_bytes) return COVER_TEXT.tooLarge;
      return null;
    },
    contentType: typeOf,
    tooLarge: COVER_TEXT.tooLarge,
    accepted: () => COVER_TEXT.accepted,
    rejected: coverRejectionText,
    onAccepted,
  });
  const preview = usePreview(file);

  return (
    <section aria-labelledby="cover-heading">
      <h3 id="cover-heading">Cover</h3>
      {coverUrl ? <img src={coverUrl} alt="Current cover" className="cover" width={160} /> : <p>{COVER_TEXT.none}</p>}
      {limits && <p>{COVER_TEXT.rules(limits)}</p>}
      {coverUrl && <p>{COVER_TEXT.replaceNote}</p>}
      <label htmlFor="issue-cover">Cover image</label>
      <input id="issue-cover" type="file" accept="image/jpeg,image/png,.jpg,.jpeg,.png" disabled={busy} onChange={(e) => choose(e.target.files?.[0] ?? null)} />
      {file && <p>{`${file.name}, ${megabytes(file.size)}`}</p>}
      {preview && <img src={preview} alt="Chosen image" className="cover" width={160} />}
      <button type="button" disabled={!file || busy} onClick={() => void start()}>
        {coverUrl ? 'Replace cover' : 'Upload cover'}
      </button>
      {progress && <p aria-live="polite">{progress}</p>}
      {status && <p role="status">{status}</p>}
      {message && (
        <p role="alert" className="message">
          {message}
        </p>
      )}
      {jobs.length > 0 && (
        <table>
          <caption>Cover uploads of this issue</caption>
          <thead>
            <tr>
              <th scope="col">Started</th>
              <th scope="col">Size</th>
              <th scope="col">Result</th>
            </tr>
          </thead>
          <tbody>
            {jobs.map((job) => (
              <tr key={job.job_id}>
                <td>{job.created_at === null ? '' : `${new Date(job.created_at).toISOString().slice(0, 16).replace('T', ' ')} GMT`}</td>
                <td>{megabytes(job.declared_size_bytes)}</td>
                <td>{jobLine(job)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </section>
  );
}
