// Group U10: the CSV of OP-32 with no emulator (SEC-CHK-12, FX-ADM-07): formula cells neutralised, quoting
// and line ends as RFC 4180, and the columns in the panel's order. Synthetic values only.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { csvCell, toCsv } from '../functions/dist/registeredUsers.js';

test('U10 FX-ADM-07: a cell that starts like a formula gets a leading apostrophe', () => {
  for (const value of ['=SUM(A1:A9)', '+1', '-1', '@cmd', '\tx', '\rx', '=HYPERLINK("https://x.example.test")']) {
    assert.ok(csvCell(value).replace(/^"/, '').startsWith("'"), JSON.stringify(value));
  }
  assert.equal(csvCell('a=1'), 'a=1');
  assert.equal(csvCell(42), '42');
});

test('U10 commas, quotes and line breaks are quoted, and quotes are doubled', () => {
  assert.equal(csvCell('Smith, Jo'), '"Smith, Jo"');
  assert.equal(csvCell('Say "hi"'), '"Say ""hi"""');
  assert.equal(csvCell('two\nlines'), '"two\nlines"');
  assert.equal(csvCell('=1,2'), `"'=1,2"`);
  assert.equal(csvCell(null), '');
  assert.equal(csvCell(undefined), '');
});

test('U10 the file has a header, one line per reader, the segment name and CRLF line ends', () => {
  const csv = toCsv(
    [{ user_id: 'u1', email: 'a@example.test', full_name: 'Reader A', age_value: 30, gender: 'Woman', job_title: 'Engineer', industry_segment_id: 's1', created_at: Date.UTC(2026, 10, 1, 8, 30) }],
    new Map([['s1', 'Forging']]),
  );
  assert.equal(csv, 'Email,Full name,Age,Gender,Occupation,Domain of work,Registered (GMT)\r\na@example.test,Reader A,30,Woman,Engineer,Forging,2026-11-01 08:30:00\r\n');
  assert.doesNotMatch(csv, /u1/, 'the internal identifier is not exported');
});
