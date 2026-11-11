// SCR-W-04 Upload status, as part of the issue editor (FR-ADMIN-005 to FR-ADMIN-008, FR-STATE-007,
// MOD12-P2-T02): choose a PDF, upload it through OP-19 to the holding area, then follow the job through OP-20
// while OP-40 checks it on the server. Only a file the server accepts becomes the issue's file; anything else
// is deleted there, with the reason shown here. A replacement keeps the current file until the new one is
// accepted (GS-Q45). A cover waits for OQ-22, and the size limit and its unit for OQ-30. Placeholder visuals.
import { useCallback, useEffect, useState } from 'react';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import { newRequestId, PDF_TYPE, requestUpload, uploadJobs } from './data';
import type { UploadJob } from './data';
import { describeError } from './describeError';
import type { FileSender } from './services';
import { UploadError } from './upload';

interface Props {
  api: CallFn;
  upload: FileSender;
  issueId: string;
  hasFile: boolean;
  onAccepted: () => void;
}

// PLACEHOLDERS. How often, and how many times, the screen asks OP-20 whether the check has finished.
export const PLACEHOLDER_POLL_MS = 2000;
export const PLACEHOLDER_POLL_TIMES = 90;

export const UPLOAD_TEXT = {
  notPdf: 'Choose a PDF file.',
  empty: 'The file is empty.',
  tooLarge: 'The file is larger than the upload limit.',
  sending: 'Uploading',
  checking: 'Uploaded. The server is checking the file…',
  stillChecking: 'The check is taking longer than usual. The list below shows the result when it finishes.',
  broken: 'The upload did not finish. Choose Upload again to continue with the same file.',
  replaceNote: 'The current file stays until a new one is accepted.',
} as const;

export const REJECTIONS: Record<string, string> = {
  NOT_A_PDF: 'The file is not a usable PDF, so it was deleted.',
  OVER_LIMIT: 'The file is larger than the upload limit, so it was deleted.',
  UPLOADER_NOT_AUTHORISED: 'Your admin access had ended when the file arrived, so it was deleted.',
  ISSUE_NOT_FOUND: 'The issue no longer exists, so the file was deleted.',
  NO_PENDING_JOB: 'The file was not expected, so it was deleted. Upload it again.',
};

export const rejectionText = (reason: string | null) => (reason && REJECTIONS[reason]) ?? 'The file was refused and deleted.';

export const acceptedText = (revision: number | null) => `Accepted as file revision ${revision ?? '?'}. The issue can be published with it.`;

const megabytes = (bytes: number) => `${(bytes / (1024 * 1024)).toFixed(1)} MB`;

const jobLine = (job: UploadJob) => {
  if (job.status === 'accepted') return `Accepted, revision ${job.revision ?? '?'}`;
  if (job.status === 'rejected') return rejectionText(job.reason);
  return 'Waiting for the file or the check';
};

const isPdf = (file: File) => file.type === PDF_TYPE || (file.type === '' && file.name.toLowerCase().endsWith('.pdf'));

export function IssueFileSection({ api, upload, issueId, hasFile, onAccepted }: Props) {
  const [file, setFile] = useState<File | null>(null);
  // One request identifier per chosen file, so Upload again continues the same job (OP-19).
  const [requestId, setRequestId] = useState(newRequestId);
  const [jobs, setJobs] = useState<UploadJob[]>([]);
  const [busy, setBusy] = useState(false);
  const [progress, setProgress] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [status, setStatus] = useState<string | null>(null);

  const refresh = useCallback(async () => {
    try {
      setJobs(await uploadJobs(api, { issue_id: issueId }));
    } catch (error) {
      if (!(error instanceof AccessLost)) setMessage(describeError(error));
    }
  }, [api, issueId]);

  useEffect(() => {
    void refresh();
  }, [refresh]);

  function choose(chosen: File | null) {
    setFile(chosen);
    setRequestId(newRequestId());
    setMessage(null);
    setStatus(null);
    setProgress(null);
  }

  async function follow(jobId: string): Promise<UploadJob | null> {
    for (let i = 0; i < PLACEHOLDER_POLL_TIMES; i += 1) {
      const [job] = await uploadJobs(api, { job_id: jobId });
      if (job && job.status !== 'pending') return job;
      await upload.wait(PLACEHOLDER_POLL_MS);
    }
    return null;
  }

  async function start() {
    if (!file || busy) return;
    if (!isPdf(file)) return setMessage(UPLOAD_TEXT.notPdf);
    if (file.size === 0) return setMessage(UPLOAD_TEXT.empty);
    setBusy(true);
    setMessage(null);
    setStatus(null);
    try {
      const job = await requestUpload(api, requestId, issueId, file.size);
      if (job.upload_url && job.upload_headers) {
        setProgress(`${UPLOAD_TEXT.sending} 0%`);
        await upload.send({ upload_url: job.upload_url, upload_headers: job.upload_headers }, file, (sent) =>
          setProgress(`${UPLOAD_TEXT.sending} ${Math.floor((sent / file.size) * 100)}%`),
        );
      }
      setProgress(UPLOAD_TEXT.checking);
      const done = await follow(job.job_id);
      setProgress(null);
      await refresh();
      if (!done) return setStatus(UPLOAD_TEXT.stillChecking);
      if (done.status === 'accepted') {
        setStatus(acceptedText(done.revision));
        setFile(null);
        setRequestId(newRequestId());
        onAccepted();
      } else {
        setMessage(rejectionText(done.reason));
        setFile(null);
        setRequestId(newRequestId());
      }
    } catch (error) {
      setProgress(null);
      if (error instanceof AccessLost) return;
      if (error instanceof UploadError) return setMessage(UPLOAD_TEXT.broken);
      const fields = (error as { details?: { fields?: unknown } }).details?.fields;
      setMessage(Array.isArray(fields) && fields.includes('declared_size_bytes') ? UPLOAD_TEXT.tooLarge : describeError(error));
    } finally {
      setBusy(false);
    }
  }

  return (
    <section aria-labelledby="issue-file-heading">
      <h3 id="issue-file-heading">Issue file</h3>
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
