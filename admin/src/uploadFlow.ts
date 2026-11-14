// The upload steps shared by the issue-file and cover sections of the issue editor (MOD12-P2-T02,
// SCR-W-04): ask OP-19 for a job and an address, send the file, then follow the job through OP-20 while
// OP-40 checks it on the server. Each section gives its own checks and wording.
import { useCallback, useEffect, useState } from 'react';
import { AccessLost } from './adminApi';
import type { CallFn } from './adminApi';
import { newRequestId, requestUpload, uploadJobs } from './data';
import type { UploadJob, UploadKind } from './data';
import { describeError } from './describeError';
import type { FileSender } from './services';
import { UploadError } from './upload';

// PLACEHOLDERS. How often, and how many times, a section asks OP-20 whether the check has finished.
export const PLACEHOLDER_POLL_MS = 2000;
export const PLACEHOLDER_POLL_TIMES = 90;

export const FLOW_TEXT = {
  sending: 'Uploading',
  checking: 'Uploaded. The server is checking the file…',
  stillChecking: 'The check is taking longer than usual. The list below shows the result when it finishes.',
  broken: 'The upload did not finish. Choose Upload again to continue with the same file.',
} as const;

export const megabytes = (bytes: number) => `${(bytes / (1024 * 1024)).toFixed(1)} MB`;

interface Options {
  api: CallFn;
  upload: FileSender;
  issueId: string;
  kind: UploadKind;
  // A reason to refuse the file in the panel, before anything is asked, or null.
  refuse: (file: File) => string | null;
  contentType: (file: File) => string;
  tooLarge: string;
  accepted: (job: UploadJob) => string;
  rejected: (job: UploadJob) => string;
  onAccepted: () => void;
}

export function useUploadFlow({ api, upload, issueId, kind, refuse, contentType, tooLarge, accepted, rejected, onAccepted }: Options) {
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
      // The issue's jobs of both kinds come back together; each section lists its own.
      setJobs((await uploadJobs(api, { issue_id: issueId })).filter((job) => (job.kind ?? 'pdf') === kind));
    } catch (error) {
      if (!(error instanceof AccessLost)) setMessage(describeError(error));
    }
  }, [api, issueId, kind]);

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

  function finish() {
    setFile(null);
    setRequestId(newRequestId());
  }

  async function start() {
    if (!file || busy) return;
    const refusal = refuse(file);
    if (refusal) return setMessage(refusal);
    setBusy(true);
    setMessage(null);
    setStatus(null);
    try {
      const job = await requestUpload(api, requestId, issueId, file.size, kind, contentType(file));
      if (job.upload_url && job.upload_headers) {
        setProgress(`${FLOW_TEXT.sending} 0%`);
        await upload.send({ upload_url: job.upload_url, upload_headers: job.upload_headers }, file, (sent) =>
          setProgress(`${FLOW_TEXT.sending} ${Math.floor((sent / file.size) * 100)}%`),
        );
      }
      setProgress(FLOW_TEXT.checking);
      const done = await follow(job.job_id);
      setProgress(null);
      await refresh();
      if (!done) return setStatus(FLOW_TEXT.stillChecking);
      finish();
      if (done.status === 'accepted') {
        setStatus(accepted(done));
        onAccepted();
      } else {
        setMessage(rejected(done));
      }
    } catch (error) {
      setProgress(null);
      if (error instanceof AccessLost) return;
      if (error instanceof UploadError) return setMessage(FLOW_TEXT.broken);
      const fields = (error as { details?: { fields?: unknown } }).details?.fields;
      setMessage(Array.isArray(fields) && fields.includes('declared_size_bytes') ? tooLarge : describeError(error));
    } finally {
      setBusy(false);
    }
  }

  return { file, choose, start, jobs, busy, progress, message, status };
}
