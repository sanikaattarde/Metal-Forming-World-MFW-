// SCR-W-04 Upload status, as part of the issue editor (FR-ADMIN-005 to FR-ADMIN-008, FR-STATE-007,
// MOD12-P2-T02): choose a PDF, upload it through OP-19 to the holding area, then follow the job through OP-20
// while OP-40 checks it on the server. Only a file the server accepts becomes the issue's file; anything else
// is deleted there, with the reason shown here. A replacement keeps the current file until the new one is
// accepted (GS-Q45). The limit is the server's (OQ-30 working position of 14 November 2026, PROVISIONAL);
// the steps are shared with the cover section (uploadFlow.ts). Placeholder visuals.
import type { CallFn } from './adminApi';
import { PDF_TYPE } from './data';
import type { UploadJob, UploadLimits } from './data';
import type { FileSender } from './services';
import { FLOW_TEXT, megabytes, useUploadFlow } from './uploadFlow';

export { PLACEHOLDER_POLL_MS, PLACEHOLDER_POLL_TIMES } from './uploadFlow';

interface Props {
  api: CallFn;
  upload: FileSender;
  issueId: string;
  hasFile: boolean;
  // The server's limits, to name them; null until read, or if they could not be read.
  limits: UploadLimits | null;
  onAccepted: () => void;
}

export const UPLOAD_TEXT = {
  ...FLOW_TEXT,
  notPdf: 'Choose a PDF file.',
  empty: 'The file is empty.',
  tooLarge: 'The file is larger than the upload limit.',
  replaceNote: 'The current file stays until a new one is accepted.',
  limit: (bytes: number) => `A PDF of up to ${megabytes(bytes)}. A PDF that needs a password to open is refused.`,
} as const;

export const REJECTIONS: Record<string, string> = {
  NOT_A_PDF: 'The file is not a usable PDF, so it was deleted.',
  PDF_PROTECTED: 'The PDF needs a password to open, so it was deleted. Save it without a password and upload it again.',
  OVER_LIMIT: 'The file is larger than the upload limit, so it was deleted.',
  UPLOADER_NOT_AUTHORISED: 'Your admin access had ended when the file arrived, so it was deleted.',
  ISSUE_NOT_FOUND: 'The issue no longer exists, so the file was deleted.',
  NO_PENDING_JOB: 'The file was not expected, so it was deleted. Upload it again.',
};

export const rejectionText = (reason: string | null) => (reason && REJECTIONS[reason]) ?? 'The file was refused and deleted.';

export const acceptedText = (revision: number | null) => `Accepted as file revision ${revision ?? '?'}. The issue can be published with it.`;

const jobLine = (job: UploadJob) => {
  if (job.status === 'accepted') return `Accepted, revision ${job.revision ?? '?'}`;
  if (job.status === 'rejected') return rejectionText(job.reason);
  return 'Waiting for the file or the check';
};

const isPdf = (file: File) => file.type === PDF_TYPE || (file.type === '' && file.name.toLowerCase().endsWith('.pdf'));

export function IssueFileSection({ api, upload, issueId, hasFile, limits, onAccepted }: Props) {
  const { file, choose, start, jobs, busy, progress, message, status } = useUploadFlow({
    api,
    upload,
    issueId,
    kind: 'pdf',
    refuse: (chosen) => (!isPdf(chosen) ? UPLOAD_TEXT.notPdf : chosen.size === 0 ? UPLOAD_TEXT.empty : null),
    contentType: () => PDF_TYPE,
    tooLarge: UPLOAD_TEXT.tooLarge,
    accepted: (job: UploadJob) => acceptedText(job.revision),
    rejected: (job: UploadJob) => rejectionText(job.reason),
    onAccepted,
  });

  return (
    <section aria-labelledby="issue-file-heading">
      <h3 id="issue-file-heading">Issue file</h3>
      {limits && <p>{UPLOAD_TEXT.limit(limits.pdf_max_bytes)}</p>}
      {hasFile && <p>{UPLOAD_TEXT.replaceNote}</p>}
      <label htmlFor="issue-pdf">PDF file</label>
      <input id="issue-pdf" type="file" accept="application/pdf,.pdf" disabled={busy} onChange={(e) => choose(e.target.files?.[0] ?? null)} />
      {file && <p>{`${file.name}, ${megabytes(file.size)}`}</p>}
      <button type="button" disabled={!file || busy} onClick={() => void start()}>
        {hasFile ? 'Upload a replacement' : 'Upload'}
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
          <caption>Uploads of this issue</caption>
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
