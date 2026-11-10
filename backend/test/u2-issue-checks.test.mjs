// Unit tests of the OP-16 input checks and the derived identifier, with no database.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  checkIssueInput,
  PLACEHOLDER_MAX_DESCRIPTION_LENGTH,
  PLACEHOLDER_MAX_TITLE_LENGTH,
  sameIssueValues,
} from '../functions/dist/issueChecks.js';
import { derivedId } from '../functions/dist/validation.js';

const GOOD = {
  request_id: 'r1',
  title: 'An issue',
  description: 'What it covers',
  category_id: 'c1',
  publication_date: '2026-11-01',
};

test('U2 a good create passes, and the year defaults to the year of the publication date', () => {
  const check = checkIssueInput(GOOD);
  assert.deepEqual(check.invalid, []);
  assert.equal(check.values.year, 2026);
  assert.deepEqual(check.values.segment_ids, []);
  assert.equal('edition' in check.values, false);
});

test('U2 a stated year is kept', () => {
  assert.equal(checkIssueInput({ ...GOOD, year: 2027 }).values.year, 2027);
});

test('U2 text is trimmed', () => {
  const { values } = checkIssueInput({ ...GOOD, title: '  An issue  ', description: ' Covers ', edition: ' Label ' });
  assert.deepEqual([values.title, values.description, values.edition], ['An issue', 'Covers', 'Label']);
});

test('U2 segments lose duplicates and are sorted', () => {
  assert.deepEqual(checkIssueInput({ ...GOOD, segment_ids: ['s2', 's1', 's2'] }).values.segment_ids, ['s1', 's2']);
});

for (const [label, change, field] of [
  ['no request_id', { request_id: undefined }, 'request_id'],
  ['an empty request_id', { request_id: ' ' }, 'request_id'],
  ['no title', { title: undefined }, 'title'],
  ['an empty title', { title: '   ' }, 'title'],
  ['a title over the placeholder limit', { title: 'x'.repeat(PLACEHOLDER_MAX_TITLE_LENGTH + 1) }, 'title'],
  ['no description', { description: undefined }, 'description'],
  ['a description over the placeholder limit', { description: 'x'.repeat(PLACEHOLDER_MAX_DESCRIPTION_LENGTH + 1) }, 'description'],
  ['no category', { category_id: undefined }, 'category_id'],
  ['no publication date', { publication_date: undefined }, 'publication_date'],
  ['a date in the wrong form', { publication_date: '01/11/2026' }, 'publication_date'],
  ['a date that does not exist', { publication_date: '2026-02-30' }, 'publication_date'],
  ['a year as text', { year: '2026' }, 'year'],
  ['a fractional year', { year: 2026.5 }, 'year'],
  ['a year of 0', { year: 0 }, 'year'],
  ['segments that are not a list', { segment_ids: 's1' }, 'segment_ids'],
  ['a segment that is not text', { segment_ids: ['s1', 2] }, 'segment_ids'],
  ['an edition that is not text', { edition: 3 }, 'edition'],
]) {
  test(`U2 ${label} is refused by name`, () => {
    const data = { ...GOOD, ...change };
    for (const key of Object.keys(data)) if (data[key] === undefined) delete data[key];
    assert.deepEqual(checkIssueInput(data).invalid, [field]);
  });
}

for (const name of ['publication_state', 'current_revision', 'file_size_bytes', 'page_count', 'cover_path', 'published_at', 'created_at', 'updated_at', 'uploaded_by', 'storage_path']) {
  test(`U2 saveIssue cannot set ${name}`, () => {
    assert.deepEqual(checkIssueInput({ ...GOOD, [name]: 'x' }).invalid, [name]);
  });
}

test('U2 an edit needs the version the screen showed, and a create must not send one', () => {
  assert.deepEqual(checkIssueInput({ ...GOOD, issue_id: 'i1' }).invalid, ['expected_updated_at']);
  assert.deepEqual(checkIssueInput({ ...GOOD, issue_id: 'i1', expected_updated_at: 'yesterday' }).invalid, ['expected_updated_at']);
  assert.deepEqual(checkIssueInput({ ...GOOD, issue_id: 'i1', expected_updated_at: 5 }).invalid, []);
  assert.deepEqual(checkIssueInput({ ...GOOD, expected_updated_at: 5 }).invalid, ['expected_updated_at']);
});

test('U2 sameIssueValues sees any difference in an editable field, and ignores segment order', () => {
  const { values } = checkIssueInput({ ...GOOD, segment_ids: ['s1', 's2'], edition: 'E' });
  const stored = { ...values, segment_ids: ['s2', 's1'], publication_state: 'published', updated_at: 1 };
  assert.equal(sameIssueValues(values, stored), true);
  for (const change of [{ title: 'x' }, { description: 'x' }, { category_id: 'x' }, { publication_date: '2020-01-01' }, { year: 1 }, { edition: 'x' }, { segment_ids: ['s1'] }]) {
    assert.equal(sameIssueValues(values, { ...stored, ...change }), false, JSON.stringify(change));
  }
  const { edition, ...withoutEdition } = stored;
  assert.equal(sameIssueValues(values, withoutEdition), false);
});

test('U2 the derived identifier is stable for one caller and request, opaque, and differs otherwise', () => {
  const id = derivedId('issue', 'admin-1', 'r1');
  assert.equal(id, derivedId('issue', 'admin-1', 'r1'));
  assert.notEqual(id, derivedId('issue', 'admin-1', 'r2'));
  assert.notEqual(id, derivedId('issue', 'admin-2', 'r1'));
  assert.notEqual(id, derivedId('category', 'admin-1', 'r1'));
  assert.equal(id.includes('admin-1'), false);
  assert.equal(id.includes('r1'), false);
});
