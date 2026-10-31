// SPIKE (DEC-003 OPEN). Input checks for OP-16 saveIssue, with no database access, so they can be
// tested without the emulators. API_AND_BACKEND_CONTRACT.md section 5.1; DATABASE_AND_DATA_MODEL.md section 4.7.
import { isNonEmptyText, unknownFields } from './validation.js';

// PLACEHOLDERS. No document sets these ("Length limits and formats are proposals",
// DATABASE_AND_DATA_MODEL.md MA-6). They are not decided values.
export const PLACEHOLDER_MAX_TITLE_LENGTH = 200;
export const PLACEHOLDER_MAX_DESCRIPTION_LENGTH = 5000;

// Everything else is refused by name, which is how saveIssue "cannot change publication_state,
// current_revision or the file facts".
const ALLOWED = new Set([
  'request_id',
  'issue_id',
  'expected_updated_at',
  'title',
  'description',
  'category_id',
  'segment_ids',
  'publication_date',
  'year',
  'edition',
]);

export interface IssueValues {
  title: string;
  description: string;
  category_id: string;
  segment_ids: string[];
  publication_date: string;
  year: number;
  edition?: string;
}

export interface IssueCheck {
  invalid: string[]; // field names only, never the values
  requestId: string;
  issueId?: string;
  expectedUpdatedAt?: number;
  values: IssueValues;
}

const text = (value: unknown, limit: number): string | null => {
  if (!isNonEmptyText(value)) return null;
  const trimmed = value.trim();
  return trimmed.length > limit ? null : trimmed;
};

// A real calendar date in the form YYYY-MM-DD. The form is a spike choice, and it sorts correctly.
const isIsoDate = (value: unknown): value is string => {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const date = new Date(`${value}T00:00:00Z`);
  return !Number.isNaN(date.getTime()) && date.toISOString().slice(0, 10) === value;
};

export function checkIssueInput(data: Record<string, unknown>): IssueCheck {
  const invalid = unknownFields(data, ALLOWED);

  if (!isNonEmptyText(data.request_id)) invalid.push('request_id');

  let issueId: string | undefined;
  let expectedUpdatedAt: number | undefined;
  if (data.issue_id !== undefined) {
    if (isNonEmptyText(data.issue_id)) issueId = data.issue_id;
    else invalid.push('issue_id');
    // An edit says which version of the record the screen showed, so a stale screen can be refused.
    if (Number.isInteger(data.expected_updated_at)) expectedUpdatedAt = data.expected_updated_at as number;
    else invalid.push('expected_updated_at');
  } else if (data.expected_updated_at !== undefined) {
    invalid.push('expected_updated_at');
  }

  const title = text(data.title, PLACEHOLDER_MAX_TITLE_LENGTH);
  if (title === null) invalid.push('title');

  const description = text(data.description, PLACEHOLDER_MAX_DESCRIPTION_LENGTH);
  if (description === null) invalid.push('description');

  if (!isNonEmptyText(data.category_id)) invalid.push('category_id');

  // Segments are optional here: the contract asks only that those named exist. OQ-13 stays open.
  let segmentIds: string[] = [];
  if (data.segment_ids !== undefined) {
    if (Array.isArray(data.segment_ids) && data.segment_ids.every(isNonEmptyText)) {
      segmentIds = [...new Set(data.segment_ids as string[])].sort();
    } else {
      invalid.push('segment_ids');
    }
  }

  const publicationDate = isIsoDate(data.publication_date) ? data.publication_date : null;
  if (publicationDate === null) invalid.push('publication_date');

  // The year defaults to the year of the publication date (FR-ADMIN-009).
  let year = publicationDate === null ? 0 : Number(publicationDate.slice(0, 4));
  if (data.year !== undefined) {
    if (Number.isInteger(data.year) && (data.year as number) > 0) year = data.year as number;
    else invalid.push('year');
  }

  // The meaning of "edition" is OQ-13. It is a label.
  let edition: string | undefined;
  if (data.edition !== undefined) {
    const checked = text(data.edition, PLACEHOLDER_MAX_TITLE_LENGTH);
    if (checked === null) invalid.push('edition');
    else edition = checked;
  }

  return {
    invalid: invalid.sort(),
    requestId: isNonEmptyText(data.request_id) ? data.request_id : '',
    issueId,
    expectedUpdatedAt,
    values: {
      title: title ?? '',
      description: description ?? '',
      category_id: isNonEmptyText(data.category_id) ? data.category_id : '',
      segment_ids: segmentIds,
      publication_date: publicationDate ?? '',
      year,
      ...(edition === undefined ? {} : { edition }),
    },
  };
}

// True if the stored issue already holds these values, so a repeat can change nothing.
export function sameIssueValues(values: IssueValues, stored: Record<string, unknown>): boolean {
  const storedSegments = Array.isArray(stored.segment_ids) ? [...(stored.segment_ids as string[])].sort() : [];
  return (
    values.title === stored.title &&
    values.description === stored.description &&
    values.category_id === stored.category_id &&
    values.publication_date === stored.publication_date &&
    values.year === stored.year &&
    (values.edition ?? null) === ((stored.edition as string | undefined) ?? null) &&
    values.segment_ids.length === storedSegments.length &&
    values.segment_ids.every((id, index) => id === storedSegments[index])
  );
}
