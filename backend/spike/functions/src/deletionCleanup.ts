// SPIKE (DEC-003 OPEN). PROVISIONAL (DEC-029, OQ-24). The account-deletion task of OP-41
// scheduledMaintenance: it finishes every deletion left in the deleting state (TD-19, GS-Q50). The schedule
// itself is not built, and the other OP-41 tasks wait. A test runs this task directly.
import { eraseAccount } from './accountDeletion.js';
import type { DeletionBackend } from './accountDeletion.js';

// PLACEHOLDER. No document sets how many deletions one run finishes. Not a decided value.
export const PLACEHOLDER_DELETIONS_PER_RUN = 100;

export interface CleanupReport {
  finished: number;
  failed: number;
}

// Counts only, so that a report or a log holds no account identifier. One that fails is tried on the next run.
export async function finishDeletions(backend: DeletionBackend): Promise<CleanupReport> {
  const pending = await backend.db.collection('users').where('status', '==', 'deleting').limit(PLACEHOLDER_DELETIONS_PER_RUN).get();
  const report = { finished: 0, failed: 0 };
  for (const user of pending.docs) {
    try {
      await eraseAccount(backend, user.id);
      report.finished += 1;
    } catch {
      report.failed += 1;
    }
  }
  return report;
}
