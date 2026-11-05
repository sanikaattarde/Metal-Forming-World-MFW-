# Backend spike notes 10: account deletion, PROVISIONAL (DEC-029, OQ-24)

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`) |
| Date | 5 November 2026 |
| Task | Backend spike for `MOD13-P1-T06`, the server part of T-03.5: OP-12 `requestAccountDeletion` from `API_AND_BACKEND_CONTRACT.md` section 4, and the deletion task of OP-41 |
| Status | Working notes. **PROVISIONAL (DEC-029, OQ-24).** PROPOSED. Not reviewed. Every result is "emulator only" |
| Rests on | DEC-029 (PROPOSED); the working position of immediate deletion (GS-Q50, TD-19); OQ-24 (OPEN: is any record kept?); DEC-003 (OPEN) |

## 1. What was built

`requestAccountDeletion` takes `request_id` and `confirm: true`, and no account identifier, so it always acts on the caller's own account.

| Step | What happens | If it fails |
|---|---|---|
| Checks | Signed in; the input; not already deleting | `UNAUTHENTICATED`, `INVALID_ARGUMENT`, `FAILED_PRECONDITION` `ALREADY_DELETING` |
| One transaction | The user record is set to `deleting` with `deletion_requested_at`, and written if the reader never had one. An active admin leaves the admin count, and the last one cannot (INV-03) | `LAST_ADMIN`; an unusable guard record fails closed. Nothing is written |
| 1 | End the sessions (the refresh tokens are revoked) | The reply says `deleting`, and the cleanup finishes it |
| 2 | Delete the profile, consent records, bookmarks, favourites and notification preferences | As above |
| 3 | Delete the admin role record (section 13.3) | As above |
| 4 | Delete the sign-in account | As above |
| 5 | Delete the user record and anything left under it | As above |

Every step can run again. The reply is `{ state: 'deleted' }` when all five finish, and `{ state: 'deleting' }` when one fails. A failure is never thrown at the reader, because the account is already closed.

**The cleanup.** `finishDeletions` is the account-deletion task of OP-41. It runs all five steps again for every user record still `deleting`, and reports counts only. One that fails is tried on the next run. **The schedule is not built**, and a test runs the task directly.

**While deleting.** `saveProfile`, `getIssueFile` and every admin operation refuse the account with `ACCOUNT_CLOSED`, because each reads the status on the call.

**Nothing is kept**, because OQ-24 is open.

**Not built.** The app side (`MOD03-P4-T01`); removing the topic subscriptions (OQ-55); the OP-41 schedule and its other tasks; the admin list and the export that PAC-06 also names (OP-31, OP-32).

## 2. Results

`npm --prefix backend/spike test` on 5 November 2026: **907 tests, 907 passed, 0 failed.** Emulator only.

| Group | Tests | What it shows |
|---|---|---|
| G11 Account deletion | 34 | Every name begins "PROVISIONAL (DEC-029, OQ-24)". A deletion removes every own record, the role record and the sign-in account, and touches nothing else. Afterwards the email cannot sign in, and can register again as a new account with none of the old records. Seven refused inputs, each changing nothing. `ALREADY_DELETING`; an admin leaving the count; `LAST_ADMIN`; an unusable guard record; a removed admin. `saveProfile` and `getIssueFile` refuse a deleting account. A failure at each of the nine steps, each finished by the cleanup, with the own records already gone when a later step fails. A reader with no record whose deletion stops. The cleanup leaving active accounts alone, and counting one it could not finish. The known gap (H-2) |
| The rest | 873 | Unchanged |

| Requirement | Result |
|---|---|
| SEC-CHK-11: deletion removes the reader's data on the server | Met, emulator only |
| PAC-06: the reader cannot sign in afterwards | Met, emulator only. Absence from the admin list and new exports is not shown (OP-31, OP-32 not built) |
| INV-03: the last admin cannot delete their account | Met, emulator only |
| INV-18: from `deleting`, the record is only removed | Shown: a repeat is refused, and the cleanup only removes |

**The log.** The run's saved output holds 19 `requestAccountDeletion` log lines: 8 `deleted`, 6 `invalid-argument`, 2 `ALREADY_DELETING`, 1 `LAST_ADMIN`, 1 `unauthenticated` and 1 `internal` (the unusable guard record). Each holds the operation, the caller's identifier and the outcome only (H-6).

**Do the tests catch broken code?** 21 deliberate breaks were tried one at a time, each rebuilt, on a clean baseline: OP-12 (18) and the cleanup (3). All 21 were caught. Listing them first showed two gaps, which were closed before the run. The final step removes everything under the user record, so the tests could not tell whether the own records went early; they now check that, for every later step that fails. And no test covered a reader with no record whose deletion stops, which would leave the cleanup nothing to find.

## 3. Findings

| ID | Finding | What it means |
|---|---|---|
| H-1 | OP-12 refuses `ALREADY_DELETING`, and also says a repeat "returns the same state". The spike refuses. So a reader whose first call stopped part-way is refused, and their data waits up to a day for the cleanup | To agree. The alternative is that a repeat runs the remaining steps |
| H-2 | **Known gap.** After a deletion, the rules still take a direct write from the old session until its token expires, and the deletion task cannot see the orphan, because no user record is left. A test shows it. The rules do not check revocation; a rules check on the user record is the A-10 option ("a rule reads one document"). The weekly orphan task in OP-41 is not built | Needs both developers, with A-10. How long a real token lasts is NOT VERIFIED here |
| H-3 | The user record goes last, after the sign-in account. OP-12 lists it before the sign-in account. Otherwise a deletion that stopped between the two would leave a sign-in account nothing can find | Order changed so the cleanup can recover. To agree |
| H-4 | A reader with no user record gets one written as `deleting`, so the cleanup can find them if the deletion stops | Spike choice |
| H-5 | The role record is deleted with the account (section 13.3), while removing an admin keeps the record with `revoked_at` (section 4.17). The change record (ADMIN_AUDIT_EVENT) is not built, so no trace is left that the person was an admin | AOQ-04 and OQ-58 |
| H-6 | The account identifier stays in pseudonymous records that section 13.3 says are not affected: an upload job's `requested_by`, a file revision's `uploaded_by`, and the logs | To confirm with OQ-24 |
| H-7 | The name `confirm` and the exact value `true` are spike choices. `request_id` is required, but a repeat is refused anyway | To agree with the app (MOD-03) |
| H-8 | The cleanup takes a PLACEHOLDER of 100 deletions a run | To set with OP-41 |
| H-9 | An account the provider has disabled can still ask to be deleted. OP-12 names no check against it | Seems right. To confirm |
| H-10 | Backups may still hold deleted data (AOQ-02) | Not in this block |

## 4. Not tested

| Case | Why |
|---|---|
| A real or expired token, and the old session after deletion on the platform | The emulators do not verify tokens (B-1, H-2) |
| The OP-41 schedule | Not built |
| The admin list and the export (PAC-06) | OP-31 and OP-32 are not built |
| The app side, and the topic subscriptions | `MOD03-P4-T01`, OQ-55 |
| Real concurrency, for example two deletions at once | The emulator is not the platform |
