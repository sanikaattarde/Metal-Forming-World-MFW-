// @vitest-environment jsdom
// The cover section of the issue editor (MOD12-P2-T02, SCR-W-04; FR-ADMIN-008; OQ-22 working position of
// 14 November 2026, PROVISIONAL) in a simulated browser, against the in-memory stand-in server and a stand-in
// file sender. The server's checks themselves are in the backend's U11 and G23.
import { cleanup, fireEvent, screen, waitFor, within } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { COVER_REJECTIONS, COVER_TEXT, coverRejectionText } from '../src/CoverSection';
import { REJECTIONS, UPLOAD_TEXT } from '../src/IssueFileSection';
import type { FileSender } from '../src/services';
import { fakeDeps } from './fakes';
import { fakeServer, issueRecord } from './fakeServer';
import { signedInApp } from './render';

afterEach(cleanup);

const image = (size = 4096, name = 'cover.jpg', type = 'image/jpeg') => new File([new Uint8Array(size)], name, { type });

function setUp(over: Parameters<typeof issueRecord>[0] = { issue_id: 'i-1', title: 'November' }) {
  const server = fakeServer({ issues: [issueRecord(over)] });
  const sent: { url: string; headers: Record<string, string>; size: number }[] = [];
  const upload: FileSender = {
    send: async (address, file, onProgress) => {
      sent.push({ url: address.upload_url, headers: address.upload_headers, size: file.size });
      onProgress(file.size);
      server.arrive(address.upload_url);
    },
    wait: async () => undefined,
  };
  return { server, sent, deps: fakeDeps({ isAdmin: true, call: server.call, read: server.read, upload }) };
}

const choose = (file: File) => fireEvent.change(screen.getByLabelText('Cover image'), { target: { files: [file] } });
const button = (name: string) => screen.getByRole('button', { name }) as HTMLButtonElement;

test('an issue with no cover says it needs one, names the rules from the server, and offers Upload cover', async () => {
  const { deps } = setUp();
  await signedInApp(deps, '/issues/i-1');
  expect(await screen.findByText(COVER_TEXT.none)).toBeTruthy();
  expect(await screen.findByText(/A JPEG or PNG of up to 0\.5 MB, at least 600 pixels wide/)).toBeTruthy();
  expect(button('Upload cover').disabled).toBe(true);
  // The PDF section names its limit too.
  expect(screen.getByText(UPLOAD_TEXT.limit(1_000_000))).toBeTruthy();
});

test('a JPEG goes through OP-19 as a cover with its type, is accepted, and the editor shows it and can publish', async () => {
  const { server, sent, deps } = setUp({ issue_id: 'i-1', title: 'November', current_revision: 1 });
  await signedInApp(deps, '/issues/i-1');
  await screen.findByText(COVER_TEXT.none);
  choose(image());
  fireEvent.click(button('Upload cover'));
  expect(await screen.findByText(COVER_TEXT.accepted)).toBeTruthy();

  const [request] = server.calls('requestUpload');
  expect(request.data).toMatchObject({ kind: 'cover', issue_id: 'i-1', declared_size_bytes: 4096, content_type: 'image/jpeg' });
  expect(sent[0].headers['content-type']).toBe('image/jpeg');
  // The issue was read again: its cover shows, and the button now replaces it.
  const shown = (await screen.findByAltText('Current cover')) as HTMLImageElement;
  expect(shown.src).toBe('https://covers.example.test/i-1/job-1');
  expect(button('Replace cover')).toBeTruthy();
  expect(screen.getByText(COVER_TEXT.replaceNote)).toBeTruthy();
  expect(within(screen.getByRole('table', { name: 'Cover uploads of this issue' })).getByText('Accepted')).toBeTruthy();
  // The PDF section lists only PDF jobs.
  expect(screen.queryByRole('table', { name: 'Uploads of this issue' })).toBeNull();

  fireEvent.click(button('Publish'));
  fireEvent.click(button('Confirm publish'));
  expect(await screen.findByText('Published.')).toBeTruthy();
});

test('a PNG named without a type is sent as a PNG', async () => {
  const { server, deps } = setUp();
  await signedInApp(deps, '/issues/i-1');
  await screen.findByLabelText('Cover image');
  choose(image(4096, 'cover.PNG', ''));
  fireEvent.click(button('Upload cover'));
  await screen.findByText(COVER_TEXT.accepted);
  expect(server.calls('requestUpload')[0].data.content_type).toBe('image/png');
});

for (const [name, file, text] of [
  ['a GIF (FX-ADM-02)', image(10, 'cover.gif', 'image/gif'), COVER_TEXT.notImage],
  ['a WebP image (FX-ADM-02)', image(10, 'cover.webp', 'image/webp'), COVER_TEXT.notImage],
  ['a PDF', image(10, 'cover.pdf', 'application/pdf'), COVER_TEXT.notImage],
  ['an empty image', image(0), COVER_TEXT.empty],
  ['an image over the cover limit the server named (FX-ADM-03)', image(500_001), COVER_TEXT.tooLarge],
] as const) {
  test(`${name} is refused in the panel, and nothing is asked`, async () => {
    const { server, deps } = setUp();
    await signedInApp(deps, '/issues/i-1');
    await screen.findByText(/A JPEG or PNG of up to/);
    choose(file);
    fireEvent.click(button('Upload cover'));
    expect((await screen.findByRole('alert')).textContent).toBe(text);
    expect(server.calls('requestUpload')).toHaveLength(0);
  });
}

test('without the limits, an over-limit cover is refused by the server before anything is sent (FX-ADM-03)', async () => {
  const { server, sent, deps } = setUp();
  server.state.limitsFail = true;
  await signedInApp(deps, '/issues/i-1');
  await screen.findByText(COVER_TEXT.none);
  expect(screen.queryByText(/A JPEG or PNG of up to/)).toBeNull();
  choose(image(500_001));
  fireEvent.click(button('Upload cover'));
  expect((await screen.findByRole('alert')).textContent).toBe(COVER_TEXT.tooLarge);
  expect(sent).toHaveLength(0);
});

for (const detail of ['FORMAT', 'UNREADABLE', 'TOO_NARROW', 'SHAPE']) {
  test(`a cover the server refuses as COVER_INVALID (${detail}) says why, and the issue keeps no cover`, async () => {
    const { server, deps } = setUp();
    server.state.nextCheck = { status: 'rejected', reason: 'COVER_INVALID', detail };
    await signedInApp(deps, '/issues/i-1');
    await screen.findByLabelText('Cover image');
    choose(image());
    fireEvent.click(button('Upload cover'));
    expect((await screen.findByRole('alert')).textContent).toBe(COVER_REJECTIONS[detail]);
    expect(screen.getByText(COVER_TEXT.none)).toBeTruthy();
    expect(within(screen.getByRole('table', { name: 'Cover uploads of this issue' })).getByText(COVER_REJECTIONS[detail])).toBeTruthy();
  });
}

test('every refusal has its own words, and an unknown one a general sentence', () => {
  expect(coverRejectionText({ reason: 'OVER_LIMIT', detail: null })).toBe(COVER_REJECTIONS.OVER_LIMIT);
  expect(coverRejectionText({ reason: 'COVER_INVALID', detail: null })).toBe('The image was refused and deleted.');
  expect(coverRejectionText({ reason: 'SOMETHING_NEW', detail: null })).toBe('The image was refused and deleted.');
});

test('a password-protected PDF is reported with its own reason (OQ-30 working position)', async () => {
  const { server, deps } = setUp();
  server.state.nextCheck = { status: 'rejected', reason: 'PDF_PROTECTED' };
  await signedInApp(deps, '/issues/i-1');
  await screen.findByLabelText('PDF file');
  fireEvent.change(screen.getByLabelText('PDF file'), { target: { files: [new File([new Uint8Array(100)], 'locked.pdf', { type: 'application/pdf' })] } });
  fireEvent.click(button('Upload'));
  expect((await screen.findByRole('alert')).textContent).toBe(REJECTIONS.PDF_PROTECTED);
});

test('a replacement keeps the current cover until the new one is accepted', async () => {
  const { server, deps } = setUp({ issue_id: 'i-1', title: 'November', cover_path: 'covers/i-1/old', cover_url: 'https://covers.example.test/i-1/old' });
  server.state.nextCheck = { status: 'rejected', reason: 'COVER_INVALID', detail: 'SHAPE' };
  await signedInApp(deps, '/issues/i-1');
  await screen.findByAltText('Current cover');
  choose(image());
  fireEvent.click(button('Replace cover'));
  await screen.findByRole('alert');
  await waitFor(() => expect((screen.getByAltText('Current cover') as HTMLImageElement).src).toBe('https://covers.example.test/i-1/old'));
});
