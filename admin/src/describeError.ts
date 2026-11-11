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
  body: 'Message',
  target_type: 'Opens',
  target_ref: 'Linked issue or post',
};

export const ERRORS = {
  stale: 'This record changed after you opened it. Reload it to see the latest version, then make your change again.',
  nameTaken: 'Another category already has that name.',
  inUse: 'This category is used by at least one issue, so it cannot be deleted.',
  noAcceptedFile: 'This issue has no accepted PDF yet, so it cannot be published.',
  gone: 'This issue was deleted.',
  siteUnavailable: 'The news site could not be reached. Try again later.',
  notFound: 'This record no longer exists. Reload the list.',
  targetNotAvailable: 'The linked issue is not published, or the linked post is missing or hidden in the app.',
  notRetryable: 'This notification was already accepted, so it cannot be sent again.',
  attemptInProgress: 'An attempt at this notification is still running. Wait a few minutes, then reload the log.',
  pushFailed: 'The notification could not be sent. It is in the send log as failed, where it can be retried.',
  exportTooLarge: 'The reader list is too long to export in one file.',
  rateLimited: 'Too many requests in a short time. Wait a minute, then try again.',
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
  if (reason === 'SITE_UNAVAILABLE') return ERRORS.siteUnavailable;
  if (reason === 'TARGET_NOT_AVAILABLE') return ERRORS.targetNotAvailable;
  if (reason === 'NOT_RETRYABLE') return ERRORS.notRetryable;
  if (reason === 'ATTEMPT_IN_PROGRESS') return ERRORS.attemptInProgress;
  if (reason === 'PUSH_FAILED') return ERRORS.pushFailed;
  if (reason === 'EXPORT_TOO_LARGE') return ERRORS.exportTooLarge;
  if (reason === 'RATE_LIMITED' || code === 'functions/resource-exhausted') return ERRORS.rateLimited;
  if (code === 'functions/not-found') return ERRORS.notFound;
  return ERRORS.other;
}
