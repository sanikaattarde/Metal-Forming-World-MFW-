# Backend spike notes 07: `getIssueFile`, and a path fix

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`) |
| Date | 31 October 2026 |
| Task | Backend spike for `MOD13-P1-T04`: OP-11 from `API_AND_BACKEND_CONTRACT.md` |
| Status | Working notes. PROPOSED. Not reviewed. Every result is "emulator only" |
| Rests on | DEC-003, DEC-020, OQ-37 and CFG-06 (OPEN); BR-003 (PROVISIONAL); OQ-04 and AOQ-09 for Google accounts |

## 1. What was built

`getIssueFile` runs the contract's check 0 and six ordered checks, and stops at the first that fails.

| # | Check | Refusal | How it decides |
|---|---|---|---|
| 0 | On the deleted-issue list | `not-found`, reason `GONE` | Reads `deleted_issues`. Runs before sign-in, as OP-11 orders. Tests seed the entry, since OP-30 waits for OQ-21 |
| 1 | Signed in | `UNAUTHENTICATED` | The token the platform passes in |
| 2 | Account active, not being deleted | `ACCOUNT_CLOSED` | The sign-in provider on this call, and `users/{uid}` |
| 3 | Email verified | `EMAIL_NOT_VERIFIED` | The provider on this call, not the claim in the token |
| 4 | Profile complete, only when the gate is on | `PROFILE_INCOMPLETE` | Computed from the required fields on each call (INV-10). Nothing is stored |
| 5 | Issue exists and is published | `ISSUE_NOT_AVAILABLE` | `issues/{id}` |
| 6 | A current revision exists | `NO_CURRENT_FILE` | `issues/{id}/files/{current_revision}` with status `current` |

| Part | What it does |
|---|---|
| `grantIssuer.ts` | The interface for making a link (GAP-07), and a stub. The stub's address ends in `.invalid`, so it cannot resolve, and it holds no path. Outside the emulators the stub throws. **The real issuer is not built** |
| `safeLog.ts` | Keeps only `operation`, `caller` and `outcome` (`API_AND_BACKEND_CONTRACT.md` section 2.8). It refuses any other field, a listed field holding something that looks like a link, signature or token, and any long value. It names a refused field without its value |
| `profile.ts` | `isProfileComplete`: every required field present, not null, not empty |
| `validation.ts` | `isDocumentId`: see section 3 |

The reply is the five OP-11 fields: `url`, `expires_at`, `revision`, `size_bytes`, `checksum_sha256`. The storage path goes to the issuer and never into the reply. The call writes nothing. Each call makes a new link.

The lifetime comes from `config/private`, and a missing or unusable setting refuses the call. There is no default. The tests use 600 seconds, labelled as a test value (E-4).

**Not built.** The real signed-link issuer (DEC-020); Range and resume (`MOD06-P1-T02`); rate limiting (`MOD13-P1-T07`); OP-30, which writes the deleted-issue list.

## 2. Results

`npm --prefix backend/spike test` on 31 October 2026: **723 tests, 723 passed, 0 failed.** Emulator only.

| Group | Tests | What it shows |
|---|---|---|
| G7 Issue file | 91 | The allowed reply and its five fields. Each check and its variants, and the order: a chain test fails all seven at once and fixes them one at a time. Input, forged claims, an admin getting nothing extra, unpublishing and publishing through the real operations, failing closed, the log, and direct reads of the file store |
| U3 Issue file parts | 52 | The key check, the profile computation, the log wrapper and the stub, with no database |
| G4 File store | 56 | 25 more than before: listing, see below |
| G6 Save profile | 41 | Four more: segment values that are paths |
| G8 Admin operations | 121 | Nine more: identifiers that are paths |
| G0, G1, G2, G3, G5, U1, U2 | 362 | Unchanged |

| Requirement | Case | Result |
|---|---|---|
| PAC-13, SEC-CHK-02 | Signed out, unverified, profile incomplete | Refused |
| PAC-13, SEC-CHK-02 | A guessed storage path | Refused by the rules, for every kind of caller |
| PAC-13, SEC-CHK-02 | Another reader's grant, an expired grant | **NOT TESTED** (section 5) |
| PAC-13 | A valid grant for a full-access reader | Succeeds with the **stub** only. No file was downloaded |
| SEC-CHK-03 | PDFs not readable or listable by a client | Refused for every kind of caller, including a reader who holds a grant |
| SEC-CHK-03 | No long-lived bearer link is issued | **Not shown** (E-4). The stub is not a real link, and nothing limits the setting |
| AC-3.5 | A direct request for the PDF | Refused |
| AC-8.7 | Unpublishing stops new links | Stops them at once, and publishing restores them |

**The log.** The run's saved output holds the emulator's function logs. It has 112 log lines with an outcome, 20 of them `OK`, and the stub's address appears in none of them. A test also reads the real logger's output.

**Do the tests catch broken code?** 91 deliberate breaks were tried one at a time on clean baselines, and 87 were caught. Three were missed and one did not compile:

| Break | Why it got through | What changed |
|---|---|---|
| A fractional lifetime allowed | The test used 0.5, which is also refused for being under one second | A test with 90.5, and the same for a file size |
| The wrong path sent to the issuer | The test's stored path was the same as the wrong one | A test with a stored path that cannot be worked out, on revision 2 |
| `saveIssue` category not checked as a key | `c1/x/y` is a valid path to nothing, so it was refused for another reason | A test with `c1/x` |
| Account status ignored (did not compile) | The break left a variable unused | The break was rewritten |

Those four and two new breaks were then run again, and all six were caught. The other 87 were not run again, because the test changes only add cases.

**Listing.** Checking the results against SEC-CHK-03 showed that no test listed the file store, although the check says "readable or listable". The rules did refuse it, so this was a gap in the tests and not a hole. 25 tests were added: a control, and the whole store, the private area, an issue's folder and the holding area for each of the six kinds of caller. Allowing listing in `storage.rules` on purpose made exactly those 24 refusal tests fail, and the rules were then restored.

## 3. The path fix

Building this showed a bug in my earlier B2.3 and B2.5 code. An identifier with a slash in it becomes a path.

| Before | What happened |
|---|---|
| `unpublishIssue` with `i-live/files/1` | Wrote `publication_state` into a file record. Admin only |
| `saveProfile` with `industry_segment_id` of `a/b` | The read threw, so a reader got `INTERNAL` instead of `INVALID_ARGUMENT` |

`isDocumentId` now checks every identifier a caller supplies before it reaches `doc()`: `saveProfile`, the issue details check, the list cursor, publish and unpublish, and saving and deleting a category. It refuses a slash, `.`, `..`, a reserved `__name__` form and anything over 1,500 bytes. In `getIssueFile` the same check stops a path from reaching a deleted-issue entry through check 0.

## 4. Findings

| ID | Finding | What it means |
|---|---|---|
| E-1 | OP-11 lists no `INVALID_ARGUMENT`. The input check sits right after sign-in, so a signed-out caller only ever gets `GONE` or `UNAUTHENTICATED` | Spike choice. To add to the contract |
| E-2 | `API_AND_BACKEND_CONTRACT.md` section 2.3 rule 1 says every operation authenticates the caller first, and `SYSTEM_ARCHITECTURE.md` shows six checks. OP-11 puts check 0 before sign-in. OP-11 was followed | The documents disagree. To correct whichever is wrong |
| E-3 | `IssueFileGrant` in `API_AND_MODULE_CONTRACTS.md` has `issueId`, an access descriptor, `expiresAt`, `sizeBytes` and `contentHash`. OP-11 returns `url`, `expires_at`, `revision`, `size_bytes` and `checksum_sha256`. The OP-FILE-01 row lists `NOT_FOUND` and has no `ACCOUNT_CLOSED`, `ISSUE_NOT_AVAILABLE`, `NO_CURRENT_FILE` or `GONE`. The alias table says OP-11 adds some of this, but the app contract still needs the revision, which it does not list | For Yuvraj, since MOD-06 reads this. To agree before `MOD06-P1-T02` |
| E-4 | `signed_url_lifetime` has no stated unit, and nothing bounds it. Seconds is a spike choice. A wrong setting could make a long-lived link, which SEC-CHK-03 forbids | Needs a unit and a ceiling from OQ-37 and CFG-06. 60 minutes is still an ASSUMPTION (AOQ-07) |
| E-5 | A reader with no account record passes check 2, and with the gate off passes every check. The provider's account is what decides. Tested, and kept because no document says otherwise | To confirm. `saveProfile` already allows a first save with no record |
| E-6 | Nothing branches on the sign-in method. A Google account passes check 3 only if the provider reports it verified. Only password accounts are tested | Follows OQ-04 and AOQ-09 |
| E-7 | The issue and its file record are read outside a transaction. A replacement at the same moment could briefly answer `NO_CURRENT_FILE` | Small, and replacement waits for OQ-21. Look again with B2.8 |
| E-8 | A damaged current file record answers `INTERNAL`, not `NO_CURRENT_FILE`. Damaged data is a defect, and calling it "no file" would hide it | Spike choice |
| E-9 | The log carries the caller's identifier, as section 2.8 asks, while SC-16 says logs hold no personal data. The identifier is pseudonymous | To confirm with `MOD02-P2-T03` |
| E-10 | `expires_at` in milliseconds is a spike choice, like D-7 in `06-admin-operations-notes.md` | To settle with MOD-06 |

## 5. Not tested

| Case | Why | Where it goes |
|---|---|---|
| A real signed link | The issuer is a stub (DEC-020) | B2.10 re-run list |
| Another reader's grant, an expired grant | They need a real link. The emulator's signed-link fidelity "was not researched" (`TECHNOLOGY_DECISIONS.md`). **PAC-13 and SEC-CHK-02 are not met for these two** | B2.10 re-run list |
| The bound on link lifetime in SEC-CHK-03 | The stub honours what the setting says, and nothing limits the setting (E-4) | B2.10 re-run list |
| Range and resume | Yuvraj's `MOD06-P1-T02` | MOD-06 |
| A real or expired token | The Functions emulator does not verify tokens (`04-save-profile-notes.md`, B-1) | B2.10 re-run list |
| The Google path | OQ-04, AOQ-09 | When those are answered |
| Real concurrency (E-7) | The emulator is not the platform | B2.10 re-run list |
| `RATE_LIMITED` | Not built (`MOD13-P1-T07`) | B2.10 re-run list |
