# Backend spike notes 05: the admin gate, the last-admin guard and the count repair

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`) |
| Date | 30 October 2026 |
| Task | Backend spike for the admin record and last-admin guard, part of T-09.7's design that is needed whatever OQ-58 decides (`DATABASE_AND_DATA_MODEL.md` section 10.8: "INV-03 stays for the account deletion path") |
| Status | Working notes. PROPOSED. Not reviewed. Every result is "emulator only" |
| Rests on | DEC-003 (OPEN); DEC-027 (PROPOSED); OQ-58 (OPEN, MFW has not confirmed in-panel add and remove) |

## 1. What was built

`functions/src/admin.ts` is the only module that writes `admin_roles` and `admin_guard` (INV-05).

| Piece | What it does | Source |
|---|---|---|
| `requireAdmin` | Every privileged operation calls this first. It reads the current role record, the account record and the provider's flag on this call. It trusts no claim. Not an admin: `FORBIDDEN`. Account closed: `ACCOUNT_CLOSED`. A read fails: refused, fail closed | SC-02 to SC-04, INV-08 |
| `planAdminRemoval`, `applyAdminRemoval` | The read and write halves of taking an admin out of the count, for use inside a caller's transaction. OP-12 will use them in B2.9, and OP-37 if OQ-58 allows it. Leaving no active admin: `LAST_ADMIN` | INV-03, SC-10 |
| `removeAdminRole` | Those two halves in one transaction. **No client can reach it**: it is not exported as a function | INV-03 |
| `repairAdminCount` | Recomputes the count from the role records, the account status and the provider, reports any difference and corrects it. It reports numbers and flags only. Not scheduled yet | INV-03, OP-41 |
| `getMyAdminRole` (OP-14) | A callable for any signed-in reader. It is never an authorisation | GS-D20 |

**Not built, because they wait for OQ-58:** OP-34, OP-35, OP-37, OP-38, OP-39, the change record (`ADMIN_AUDIT_EVENT`), INV-04, INV-06 and INV-07. **Also not built:** the real bootstrap step (OP-42), and ending a removed admin's sessions (INV-09). Tests seed admins directly.

## 2. Results

`npm --prefix backend/spike test` on 30 October 2026: **392 tests, 392 passed, 0 failed.** Emulator only.

| Group | Tests | What it shows |
|---|---|---|
| G5 Admin gate | 36 | The gate for an admin, a reader, a removed admin, a malformed flag, a closed account and failed reads. OP-14 through the Functions emulator, including admin claims giving a reader nothing. The guard, removals at the same moment, and the repair |
| U1, G6 | 66 | Unchanged from `04-save-profile-notes.md` |
| G0 to G4 | 290 | Unchanged from `03-rules-notes.md` |

**Removals at the same moment** (emulator only, and not a pass for concurrency):

| Case | Result |
|---|---|
| Two admins remove each other, 20 rounds | Exactly one won each round. The count stayed at 1, with one active role |
| Three admins, three removals at once | Two won, one was refused with `LAST_ADMIN`, and one active admin remained |
| The same admin removed twice at once, 10 rounds | One won each round, and the count dropped once |

**Do the tests catch broken code?** 27 deliberate breaks of the source were tried one at a time against G5, and each made at least one test fail. They include ignoring the role, ignoring a closed account, failing open on a failed read, removing the last-admin check, trusting a claim in OP-14, and reading the guard record outside the transaction.

Three things this check showed:

1. **The first run was void.** Every test failed in every run, including the baseline, because the script left out the Storage emulator that the test set-up needs. The failures looked like catches and proved nothing. The script now stops if the baseline is not clean.
2. **A real blind spot, now closed.** Reading the role record outside the transaction was not caught while the same-admin test ran once. Repeated over 10 rounds, it is caught.
3. Two breaks did not compile on the first try, so they were rewritten and run again.

## 3. Findings

| ID | Finding | What it means |
|---|---|---|
| C-1 | OP-42 writes a change record `bootstrap_admin` that holds the written reference. The data model says the change record is not built if MFW declines OQ-58 | Open: how the first admin is recorded in that case. Settle in writing before the real bootstrap step |
| C-2 | `DATABASE_AND_DATA_MODEL.md` section 4.21 says the guard "depends on in-panel add and remove". Section 10.8 says INV-03 stays for the account deletion path, and INV-03 is enforced by the guard | The two passages disagree. This spike follows section 10.8, so the guard is built either way |
| C-3 | An admin disabled in the console is still counted until the repair runs (hourly, an ASSUMPTION). In that window a removal can leave only that disabled admin as "the last one" | The documents accept this: "Detected, not prevented". The repair reports it. Worth a look when the schedule is set |
| C-4 | The data model says the count is never below 1 after a change. The repair writes the true number, which can be 0 if every admin is disabled outside the app, and reports `no_active_admin` | A choice here: the record stays truthful and removals stay refused. The way back is the bootstrap step's recovery |
| C-5 | An account with no account record yet (a reader who has not saved a profile) is not treated as closed. The role record and the provider decide | A choice here, because OP-42 needs only "an ordinary reader account". To confirm |
| C-6 | OP-14's output is a choice. A removed admin gets `is_admin: true, is_active: false`, because the record is kept. The panel must go by `is_active` | To agree when the panel uses it |
| C-7 | The contract says "refused, fail closed" and names no category for a failed read. `INTERNAL` is used, with no cause in the reply | To agree. `UNAVAILABLE` is the alternative, if a retry should be invited |
| C-8 | No privileged callable exists yet, so the gate is called directly in G5. "A refusal writes nothing" is shown only when B2.5 adds privileged operations | Next step |

## 4. Not tested

1. **Real concurrency.** How the platform's transactions behave under conflict is NOT VERIFIED (`TECHNOLOGY_DECISIONS.md` section 9.4, item 20). On the emulator each conflicting round took about three seconds, with no error reaching the caller. On a real project a loser might get an error after its retries. **Re-run on a test project.**
2. **An old or forged token.** The Functions emulator does not verify tokens (`04-save-profile-notes.md`, B-1). The claim test works only because of that.
3. **How soon a removal is seen.** SEC-CHK-18 asks for the time until the refusal to be measured. On the emulator it is immediate, which says nothing about a real project (INV-08, items 20 and 21).
4. **A forced write failure (INV-04).** That test belongs with the change record, which waits for OQ-58.
5. **The schedule.** `repairAdminCount` is called directly. The scheduled function (OP-41) is not built.
