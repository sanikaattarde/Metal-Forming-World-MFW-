// @vitest-environment jsdom
// The registered-readers screen (MOD12-P2-T06, SCR-W-09) in a simulated browser, against the in-memory
// stand-in server. OP-31 and OP-32 themselves, with the formula-cell check, are the backend's G16 and U10.
// PROVISIONAL (OQ-29, OQ-31, OQ-51). Synthetic values only.
import { cleanup, fireEvent, screen, within } from '@testing-library/react';
import { afterEach, expect, test } from 'vitest';
import { ERRORS } from '../src/describeError';
import { READER_TEXT } from '../src/RegisteredUsersPage';
import { fakeDeps, serverError } from './fakes';
import { fakeServer, readerRow } from './fakeServer';
import { signedInApp } from './render';

afterEach(cleanup);

function setUp(server = fakeServer({ readers: [readerRow(1), readerRow(2)], segments: [{ segment_id: 's1', name: 'Forging' }] })) {
  const saved: { name: string; text: string; type: string }[] = [];
  const deps = fakeDeps({ isAdmin: true, call: server.call, read: server.read, saveText: (name, text, type) => saved.push({ name, text, type }) });
  return { server, deps, saved };
}

test('PAC-03: the readers are listed with their profile fields and the segment name, with the personal-data notice', async () => {
  const { deps } = setUp();
  await signedInApp(deps, '/readers');
  expect(await screen.findByText('reader-1@example.test')).toBeTruthy();
  expect(screen.getByText(READER_TEXT.notice)).toBeTruthy();
  const row = screen.getByText('reader-2@example.test').closest('tr')!;
  expect(within(row).getAllByRole('cell').map((cell) => cell.textContent)).toEqual([
    'reader-2@example.test', 'Reader 2', '32', 'Prefer not to say', 'Engineer', 'Forging', '2026-11-03',
  ]);
});

test('FR-USER-003: Export as CSV asks OP-32 and hands the file over as UTF-8 with a byte-order mark', async () => {
  const { server, deps, saved } = setUp();
  await signedInApp(deps, '/readers');
  await screen.findByText('reader-1@example.test');
  fireEvent.click(screen.getByRole('button', { name: 'Export as CSV' }));
  expect(await screen.findByText(READER_TEXT.exported(2))).toBeTruthy();
  expect(server.calls('exportRegisteredUsers')[0].data).toEqual({});
  expect(saved).toHaveLength(1);
  expect(saved[0].name).toBe('registered-users-2026-11-11.csv');
  expect(saved[0].type).toBe('text/csv;charset=utf-8');
  expect(saved[0].text.startsWith('﻿Email,Full name\r\n')).toBe(true);
});

test('Load more follows the cursor', async () => {
  const readers = Array.from({ length: 60 }, (_, i) => readerRow(i));
  const { server, deps } = setUp(fakeServer({ readers }));
  await signedInApp(deps, '/readers');
  await screen.findByText('reader-0@example.test');
  expect(screen.queryByText('reader-55@example.test')).toBeNull();
  fireEvent.click(screen.getByRole('button', { name: 'Load more' }));
  expect(await screen.findByText('reader-55@example.test')).toBeTruthy();
  expect(server.calls('listRegisteredUsers').at(-1)?.data).toEqual({ page_size: 50, cursor: 'u-49' });
  expect(screen.queryByRole('button', { name: 'Load more' })).toBeNull();
});

test('an export that is too long says so, and no file is handed over', async () => {
  const { server, deps, saved } = setUp();
  server.failNext('exportRegisteredUsers', serverError('failed-precondition', 'EXPORT_TOO_LARGE'));
  await signedInApp(deps, '/readers');
  await screen.findByText('reader-1@example.test');
  fireEvent.click(screen.getByRole('button', { name: 'Export as CSV' }));
  expect((await screen.findByRole('alert')).textContent).toBe(ERRORS.exportTooLarge);
  expect(saved).toHaveLength(0);
});

test('an empty list says so, and a missing field shows as blank', async () => {
  const { deps } = setUp(fakeServer());
  await signedInApp(deps, '/readers');
  expect(await screen.findByText(READER_TEXT.empty)).toBeTruthy();
  cleanup();
  const { deps: one } = setUp(fakeServer({ readers: [readerRow(1, { gender: null, industry_segment_id: null })] }));
  await signedInApp(one, '/readers');
  const row = (await screen.findByText('reader-1@example.test')).closest('tr')!;
  expect(within(row).getAllByRole('cell')[3].textContent).toBe('');
  expect(within(row).getAllByRole('cell')[5].textContent).toBe('');
});

test('SEC-CHK-15: a name is shown as text', async () => {
  const { deps } = setUp(fakeServer({ readers: [readerRow(1, { full_name: '<img src=x onerror=alert(1)>' })] }));
  await signedInApp(deps, '/readers');
  const row = (await screen.findByText('<img src=x onerror=alert(1)>')).closest('tr')!;
  expect(row.querySelector('img')).toBeNull();
});
