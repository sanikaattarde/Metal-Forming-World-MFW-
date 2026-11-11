// @vitest-environment jsdom
// The issue-file section of the issue editor (MOD12-P2-T02, SCR-W-04) in a simulated browser, against the
// in-memory stand-in server and a stand-in file sender. OP-19, OP-20 and OP-40 themselves are checked in the
// backend's G10 and in upload.emulator.test.ts; the resumable sending in upload.test.ts.
import { cleanup, fireEvent, screen, waitFor, within } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { acceptedText, PLACEHOLDER_POLL_TIMES, REJECTIONS, UPLOAD_TEXT } from '../src/IssueFileSection';
import type { FileSender } from '../src/services';
import { UploadError } from '../src/upload';
import { fakeDeps } from './fakes';
import { fakeServer, issueRecord } from './fakeServer';
import { signedInApp } from './render';

afterEach(cleanup);

const pdf = (size = 2048, name = 'november.pdf', type = 'application/pdf') => new File([new Uint8Array(size)], name, { type });

function setUp({ revision = null as number | null, sender }: { revision?: number | null; sender?: (server: ReturnType<typeof fakeServer>) => FileSender } = {}) {
  const server = fakeServer({ issues: [issueRecord({ issue_id: 'i-1', title: 'November', current_revision: revision })] });
  const sent: { url: string; headers: Record<string, string>; size: number }[] = [];
  const upload: FileSender = sender?.(server) ?? {
    send: async (address, file, onProgress) => {
      sent.push({ url: address.upload_url, headers: address.upload_headers, size: file.size });
      onProgress(file.size / 2);
      onProgress(file.size);
      server.arrive(address.upload_url);
    },
    wait: async () => undefined,
  };
  return { server, sent, deps: fakeDeps({ isAdmin: true, call: server.call, read: server.read, upload }) };
}

const choose = (file: File) => fireEvent.change(screen.getByLabelText('PDF file'), { target: { files: [file] } });
const button = (name: string) => screen.getByRole('button', { name }) as HTMLButtonElement;

test('a new issue has no file section; an existing one offers Upload, off until a file is chosen', async () => {
  const { deps } = setUp();
  await signedInApp(deps, '/issues/new');
  expect(screen.queryByLabelText('PDF file')).toBeNull();
  cleanup();
  await signedInApp(setUp().deps, '/issues/i-1');
  expect(await screen.findByLabelText('PDF file')).toBeTruthy();
  expect(button('Upload').disabled).toBe(true);
});

test('AC-8.3: a PDF goes through OP-19 and the sender, then OP-20 shows it accepted, and the issue has its file', async () => {
  const { server, sent, deps } = setUp();
  await signedInApp(deps, '/issues/i-1');
  await screen.findByText(/No accepted file/);
  choose(pdf());
  expect(screen.getByText('november.pdf, 0.0 MB')).toBeTruthy();
  fireEvent.click(button('Upload'));
  expect(await screen.findByText(acceptedText(1))).toBeTruthy();

  const [request] = server.calls('requestUpload');
  expect(request.data).toMatchObject({ kind: 'pdf', issue_id: 'i-1', declared_size_bytes: 2048, content_type: 'application/pdf' });
  expect(sent).toEqual([{ url: 'https://upload.example.test/job-1', headers: { 'content-type': 'application/pdf', 'x-goog-resumable': 'start' }, size: 2048 }]);
  // The check was followed until it finished, and the issue was read again for its new version.
  expect(server.calls('listUploadJobs').filter((c) => c.data.job_id === 'job-1').length).toBeGreaterThanOrEqual(2);
  await waitFor(() => expect(screen.getByText(/File revision 1/)).toBeTruthy());
  const table = screen.getByRole('table', { name: 'Uploads of this issue' });
  expect(within(table).getByText('Accepted, revision 1')).toBeTruthy();
});

test('AC-8.4: a file the server finds is not a PDF is reported as deleted, and the issue keeps no file', async () => {
  const { server, deps } = setUp();
  server.state.nextCheck = { status: 'rejected', reason: 'NOT_A_PDF' };
  await signedInApp(deps, '/issues/i-1');
  await screen.findByLabelText('PDF file');
  choose(pdf());
  fireEvent.click(button('Upload'));
  expect((await screen.findByRole('alert')).textContent).toBe(REJECTIONS.NOT_A_PDF);
  expect(screen.getByText(/No accepted file/)).toBeTruthy();
});

test('AC-8.5: a declared size over the server limit is refused before anything is sent', async () => {
  const { server, sent, deps } = setUp();
  server.state.uploadLimit = 1000;
  await signedInApp(deps, '/issues/i-1');
  await screen.findByLabelText('PDF file');
  choose(pdf(2048));
  fireEvent.click(button('Upload'));
  expect((await screen.findByRole('alert')).textContent).toBe(UPLOAD_TEXT.tooLarge);
  expect(sent).toHaveLength(0);
});

test('a file that is not a PDF, or is empty, is refused in the panel and nothing is asked', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/issues/i-1');
  await screen.findByLabelText('PDF file');
  choose(pdf(10, 'notes.txt', 'text/plain'));
  fireEvent.click(button('Upload'));
  expect((await screen.findByRole('alert')).textContent).toBe(UPLOAD_TEXT.notPdf);
  choose(pdf(0));
  fireEvent.click(button('Upload'));
  expect((await screen.findByRole('alert')).textContent).toBe(UPLOAD_TEXT.empty);
  expect(server.calls('requestUpload')).toHaveLength(0);
});

test('FR-ADMIN-007: a broken upload says so, and Upload again continues the same job', async () => {
  let breaks = 1;
  const { server, deps } = setUp({
    sender: (srv) => ({
      send: async (address) => {
        if (breaks-- > 0) throw new UploadError('broken');
        srv.arrive(address.upload_url);
      },
      wait: async () => undefined,
    }),
  });
  await signedInApp(deps, '/issues/i-1');
  await screen.findByLabelText('PDF file');
  choose(pdf());
  fireEvent.click(button('Upload'));
  expect((await screen.findByRole('alert')).textContent).toBe(UPLOAD_TEXT.broken);
  fireEvent.click(button('Upload'));
  expect(await screen.findByText(acceptedText(1))).toBeTruthy();
  const [first, second] = server.calls('requestUpload');
  expect(second.data.request_id).toBe(first.data.request_id);
  expect(server.state.jobs).toHaveLength(1);
});

test('a replacement keeps the current file until the new one is accepted (GS-Q45)', async () => {
  const { deps } = setUp({ revision: 1 });
  await signedInApp(deps, '/issues/i-1');
  expect(await screen.findByText(UPLOAD_TEXT.replaceNote)).toBeTruthy();
  choose(pdf());
  fireEvent.click(button('Upload a replacement'));
  expect(await screen.findByText(acceptedText(2))).toBeTruthy();
});

test('a check that does not finish in time says the list will show the result', async () => {
  const { server, deps } = setUp();
  server.state.checkPolls = PLACEHOLDER_POLL_TIMES + 5;
  await signedInApp(deps, '/issues/i-1');
  await screen.findByLabelText('PDF file');
  choose(pdf());
  fireEvent.click(button('Upload'));
  expect(await screen.findByText(UPLOAD_TEXT.stillChecking)).toBeTruthy();
  expect(within(screen.getByRole('table', { name: 'Uploads of this issue' })).getByText('Waiting for the file or the check')).toBeTruthy();
});
