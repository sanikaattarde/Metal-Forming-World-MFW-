// Turns a server refusal into a message for the admin. PLACEHOLDER wording: there is no M2 design.
// The server's own message is never shown, and neither is any value the admin typed.

const FIELD_LABELS: Record<string, string> = {
  title: 'Title',
  description: 'Description',
  category_id: 'Category',
  segment_ids: 'Segments',
  publication_date: 'Publication date',
  year: 'Year',
  edition: 'Edition',
  name: 'Name',
  display_order: 'Order',
};

export const ERRORS = {
  stale: 'This record changed after you opened it. Reload it to see the latest version, then make your change again.',
  nameTaken: 'Another category already has that name.',
  inUse: 'This category is used by at least one issue, so it cannot be deleted.',
  noAcceptedFile: 'This issue has no accepted PDF yet, so it cannot be published.',
  gone: 'This issue was deleted.',
  notFound: 'This record no longer exists. Reload the list.',
  fields: 'Check these fields: ',
  other: 'The change could not be saved. Try again.',
} as const;

export function describeError(error: unknown): string {
  const { code, details } = (error ?? {}) as { code?: unknown; details?: { reason?: unknown; fields?: unknown } };
  const reason = typeof details?.reason === 'string' ? details.reason : undefined;
  if (code === 'functions/invalid-argument' && Array.isArray(details?.fields)) {
    const labels = details.fields.map((field) => FIELD_LABELS[String(field)] ?? 'another field');
    return ERRORS.fields + [...new Set(labels)].join(', ') + '.';
  }
  if (reason === 'STALE_RECORD') return ERRORS.stale;
  if (reason === 'NAME_TAKEN') return ERRORS.nameTaken;
  if (reason === 'IN_USE') return ERRORS.inUse;
  if (reason === 'NO_ACCEPTED_FILE') return ERRORS.noAcceptedFile;
  if (reason === 'GONE') return ERRORS.gone;
  if (code === 'functions/not-found') return ERRORS.notFound;
  return ERRORS.other;
}
