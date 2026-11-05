# Backend Rules Evidence, Emulator Only: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Backend Rules Evidence, Emulator Only |
| File | `Documentation/test-evidence/BACKEND_RULES_EMULATOR_EVIDENCE.md` |
| Phase | 4 — Testing, Release and Risk Management. A test evidence report (`TESTING_STRATEGY.md` §13) |
| Version | 0.1 |
| Status | Draft for review. Not reviewed. **Every result is "emulator only".** No result here is a pass for the concurrency or token cases (`TECHNOLOGY_DECISIONS.md` TD-15, "Result to record"). Nothing is AGREED, and nothing here has gone to MFW |
| Date | 5 November 2026 |
| Tests run by | Sanika Attarde (WS-A) |
| Approval required | Both developers |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 5 November 2026 | First report: the emulator part of the WS-A rule evidence for T-11.3 |

### 1.1 Related documents

| Document | Status on 5 November 2026 |
|---|---|
| `TESTING_STRATEGY.md` §9, §13, §16 | Exists, draft. The security checklist, the evidence location and the intended-and-tested table |
| `DEFINITION_OF_DONE.md` §11 | Exists, draft. The form of a security-check record: SEC-CHK ID, method, result, evidence location |
| `DEVELOPMENT_ROADMAP.md` T-03.5, T-03.6, T-07.1, T-11.3 | Exists, draft. T-11.3 records every SEC-CHK item as passed or as a logged defect |
| `DEVELOPMENT_WORKFLOW.md` §13 item 5 | Exists, draft. A spike is not merged into `main` as production code. Its findings are merged as a document. This report is that document |
| `CI_CD_AND_QUALITY_GATES.md` QG-08 | Exists, draft. Backend and rule tests, "Blocked by DEC-003". Section 8 gives the command used here |
| Branch `spike/sa-backend-rules`, commit `e7d9f37` | Not merged to `main`. Holds the code, the tests and the working notes `backend/spike/01-access-inventory.md` to `10-deletion-notes.md`. Every finding ID below (A-n to H-n) is defined in those notes |

## 2. What This Report Is

1. It records the rule and server tests that the WS-A backend spike ran on the local emulators, against the checklist items SEC-CHK-02 to SEC-CHK-07, SEC-CHK-11 and SEC-CHK-18.
2. It lists what the emulators could not show, and the cases to run again once ENV-TEST exists.
3. It gives the command for running the suite (section 8), for QG-08.

**What it is not.**

- It is not a pass for T-11.3, which needs the full checklist and a test project.
- It does not change any decision, requirement, checklist item or status label. DEC-003, DEC-020 and DEC-029 stay as they are. The Firebase mapping stays PROVISIONAL (TD-03).
- It does not change the table in `TESTING_STRATEGY.md` §16. The rows on issuing a link, its expiry and unpublishing all need a real signed link, and the link issuer here is a stub (DEC-020).

**Why emulator results are limited.**

- `TECHNOLOGY_DECISIONS.md` says a pass on the emulators alone is not a pass for the concurrency cases.
- TD-15 also says that how closely the emulators reproduce transaction conflicts and token behaviour "was not researched". The TD-09 proof plan (item D4) says the same of signed URLs.
- The spike also found two places where the emulators do not behave like the platform: token checks (B-1) and write conditions (G-1).

## 3. The Run

| Field | Detail |
|---|---|
| Command | `npm --prefix backend/spike test` |
| Commit | `e7d9f37` on `spike/sa-backend-rules` |
| Date | 5 November 2026 |
| Result | **907 tests, 907 passed, 0 failed, 0 skipped.** Emulator only |
| Time | About three minutes on one Mac, including the build. The runner reported 161 seconds for the tests |
| Runner output | **Not filed.** It holds local paths and the Auth emulator's one-time codes, and it was kept only in a temporary folder. So the time above and the log counts in section 5.1 cannot be checked from the repository. Running the suite again (section 8) gives a new output. Where the spike notes say "the run's saved output", they mean the same kind of unfiled local output |
| Emulators | Auth, Functions, Firestore and Storage from `firebase-tools` 15.34.2, project name `demo-mfw-spike`. No login and no cloud project |
| Runtime | Node.js 26.0.0. The functions declare Node 22, and the deploy runtime has not been tried (B-10). OpenJDK 21.0.13 for the emulators |
| Test data | Generated. Accounts use `example.test` addresses and a fixed test password that works only on the emulators. Test PDFs are generated in `backend/spike/test/pdf-fixtures.mjs`. No MFW PDF, no real person, no credential (DEC-024) |

### 3.1 Tests by group

| Group | Tests | What it covers |
|---|---|---|
| G0 Auth emulator | 1 | Sign-up works and the verification code can be read back |
| G1 Deny by default | 150 | Unlisted paths and the function-only entities, refused for six kinds of caller; list and collection-group queries refused |
| G2 Public reads | 54 | The public paths read by anyone and written by no one; unpublished issues refused |
| G3 Own records | 58 | Bookmarks, favourites and preferences for their owner only; the account, profile and consent records read-only for the owner |
| G4 File store | 56 | The private area, a guessed path, the holding area and unlisted paths refused for read, write, delete and list |
| G5 Admin gate | 36 | The role check on every call, the last-admin guard, removals at the same moment, the count repair, OP-14 |
| G6 `saveProfile` | 41 | OP-10: what is written, and every refusal |
| G7 Issue file | 91 | OP-11: check 0 and checks 1 to 6, their order, failing closed, the log |
| G8 Admin operations | 121 | OP-15 to OP-18 and OP-21 to OP-23, each refusing six kinds of caller |
| G9 Seed | 18 | OP-05 and the three fixed categories; no client can change them |
| G10 Uploads | 75 | OP-19, OP-20 and OP-40, through the storage trigger |
| G11 Account deletion | 34 | OP-12 and the deletion cleanup. PROVISIONAL (DEC-029, OQ-24) |
| U1 to U5 | 172 | Checks with no database: profile values, issue input, the file-link parts, the seed, the PDF check |

### 3.2 Do the tests catch broken code?

Each block of the spike was checked with deliberate breaks of its rules or code, one at a time, each on a clean baseline. 319 breaks were tried in all:

| Notes | Breaks |
|---|---|
| 03 | 23 |
| 04 | 23 |
| 05 | 27 |
| 06 | 39 |
| 07 | 93 (91, then 2 more with the re-run) |
| 08 | 37 |
| 09 | 56 |
| 10 | 21 |

Every break was caught in the end. Some were missed at first, and each miss led to a stronger test, which the notes record. The breaks were run when each block was built. They were not run again on `e7d9f37`.

## 4. Access States Covered

The spike creates its own accounts. Each state below matches a planned fixture in `TEST_DATA_AND_FIXTURES.md`, where one exists. The fixtures themselves are still PLANNED.

| State | Planned fixture | Where tested |
|---|---|---|
| Signed out (no token) | — | G1 to G4, G6 to G11 |
| Reader with full access, email and password | FX-USR-01 | G3, G6, G7, G11 |
| A second reader | Two readers (SEC-CHK-05) | G1, G3, G11 |
| Email not verified | FX-USR-02 | G7 |
| Profile incomplete | FX-USR-03 | G6, G7 |
| Google account, complete or incomplete | FX-USR-04, FX-USR-05 | **NOT TESTED.** Nothing branches on the sign-in method; it follows OQ-04 and AOQ-09 (E-6) |
| Reader with forged admin claims | — | G1, G3, G5, G7, G8, G10 |
| Active admin | — | G5, G8, G10, G11 |
| Removed admin, with a session from before the removal | FX-ADM-08 | G5, G8, G10 |
| Admin account marked deleting | — | G8, G10 |
| Admin account disabled by the provider | — | G8 |
| Reader account marked deleting | — | G6, G7, G11 |

## 5. Results by Checklist Item

The form is that of `DEFINITION_OF_DONE.md` §11.

- **Evidence location:** the run in section 3, plus the notes on branch `spike/sa-backend-rules` named in each row.
- **The result words.**
  - "Met, emulator only": every case the item names passed on the emulators, and no open defect in section 6 is logged against it.
  - "Partly met, emulator only": some cases passed, and the rest are NOT TESTED, not built, or have an open defect in section 6. The row names which.
  - "Not covered": no test here addresses the item.
  - None of them is a pass for T-11.3.

| Item | Method | Result | Evidence |
|---|---|---|---|
| SEC-CHK-02: a request for an issue file is refused when signed out, unverified, profile incomplete, using another reader's grant, using an expired grant, or using a guessed storage path | Function tests through the Functions emulator; rule tests of direct reads | **Partly met, emulator only.** Refused: signed out, unverified, profile incomplete (with the gate on), and a guessed path (for every kind of caller). **NOT TESTED:** another reader's grant and an expired grant, because they need a real signed link and the issuer is a stub (DEC-020). Also refused: an account marked deleting, an unpublished issue, an issue with no current file, a deleted issue | G7, G4; `07-issue-file-notes.md` §2 |
| SEC-CHK-03: issue PDFs are not publicly readable or listable, and no long-lived bearer link is issued | Rule tests of read and list on the file store; inspection of the link reply | **Partly met, emulator only.** Read and list are refused for every kind of caller, including a reader holding a link, on the test library's bucket. Direct reads are also refused on the bucket the upload trigger uses (G-12). **Not shown:** that no long-lived link is issued. Nothing bounds the lifetime setting, which has no stated unit (E-4, logged in section 6) | G4, G7, G10; `07-issue-file-notes.md` §2; `09-upload-notes.md` G-12 |
| SEC-CHK-04: downloaded issues are only in app-private storage | Device file inspection | **Not covered.** A device check, outside the backend | — |
| SEC-CHK-05: a reader reads and changes only their own bookmarks, favourites, profile and preferences | Rule tests with two readers, a visitor, an admin and forged claims | **Met, emulator only.** Reader B, a visitor, an admin and forged claims are refused on every operation. The profile and consent records cannot be written by a client. Two known gaps sit next to this item: a missing issue or category is not checked (A-10), and a deleted account's old session can still write (H-2). Both are logged in section 6 | G1, G3; `03-rules-notes.md` §2, §4; `06-admin-operations-notes.md` §3 |
| SEC-CHK-06: every admin operation is refused on the server for non-admin accounts | Direct calls to each operation | **Partly met, emulator only.** Met for the operations built, OP-15 to OP-23. Each refuses five or six kinds of caller (no token, a reader, forged admin claims, a removed admin, an admin marked deleting, and in G8 an admin the provider has disabled), and each refusal writes nothing. The operations not built yet (OP-24 to OP-27, OP-30 to OP-32, OP-34, OP-35 and OP-37 to OP-39) are **not covered**. OP-28 and OP-29 are not built on the working position, because the developers seed segments and notification categories (GS-Q47, GS-Q56). OP-33 is dropped (GS-Q49), and OP-36 is withdrawn. A forged or expired token cannot be tested on the emulators (B-1) | G5, G8, G10; `05-admin-guard-notes.md`, `06-admin-operations-notes.md`, `09-upload-notes.md` |
| SEC-CHK-07: upload validation is enforced on the server | Files placed in the holding area round the interface; direct calls | **Partly met, emulator only.** Met for PDFs: every file that arrives is checked again for the uploader's role, its size and a genuine PDF. A file with no pending job is removed. **Not covered:** cover images (OQ-22) and the real signed upload URL (DEC-020). The cleanup after a failure is a separate gap (G-10, logged in section 6) | G10, U5; `09-upload-notes.md` §1, §2 |
| SEC-CHK-11: account deletion removes the reader's data on the server | Function tests of OP-12, with a failure forced at each step | **Partly met, emulator only. PROVISIONAL (DEC-029, OQ-24).** Every own record, the role record, the sign-in account and the user record are removed, and another reader's records are untouched. A stopped deletion is finished by the cleanup task, which the tests run directly because its schedule is not built. **Known gap:** a write from the deleted account's old session is still accepted until its token expires, and nothing removes it (H-2, logged in section 6) | G11; `10-deletion-notes.md` §2, §3 |
| SEC-CHK-18: a removed admin is refused on the next privileged call, including from a session opened before the removal; the delay is measured | Direct calls with a session from before the removal | **Partly met, emulator only.** The refusal is met: the role record is read on every call, so the next call is refused, including an upload that finishes after the removal. **Delay not measured.** On the emulators it is immediate, which says nothing about the platform | G5, G8, G10; `05-admin-guard-notes.md` §4 |

### 5.1 Related results, not claimed

| Item | What the spike shows |
|---|---|
| SEC-CHK-10: no personal data, tokens or links in logs | Partial evidence only. The function logs in this run were searched. 163 lines come from the logging wrapper, which keeps only the operation, the caller's identifier and the outcome. The 20 error and warning lines hold a fixed message, and the error lines a stack trace, but no caller value. No email address, token or link appears in a function log. The one email address and link in the output are the Auth emulator's own verification message for G0. The caller's identifier is pseudonymous (E-9, H-6). TS-06 is the real check |
| SEC-CHK-13: dependencies reviewed | Only `pdfjs-dist` has a register row (DEP-33), and that row is on the spike branch, not on `main`. The other spike packages are listed in `02-setup-notes.md` and `04-save-profile-notes.md`. Their rows belong to the pull request that promotes this work |
| SEC-CHK-19: requests are limited, and a limited request gets `RATE_LIMITED` | **Not built.** No rate limit exists in the spike, so nothing was tested |

## 6. Defects and Gaps Logged

T-11.3 asks for every item to be recorded as passed, or as a logged defect. The entries below are logged by their finding IDs, which are defined in the spike notes. None is fixed on `main`, because no backend code is on `main`.

### 6.1 Open

| Finding | Item | What is wrong | What it needs |
|---|---|---|---|
| H-2 | SEC-CHK-11 | After a deletion, the rules still accept a direct write to the reader's own records from the old session, until its token expires. Nothing finds that record afterwards, because no user record is left. A test shows it | Both developers, with A-10: a rule that reads the user record, or a cleanup for orphans (OP-41). How long a real token lasts is NOT VERIFIED |
| A-10 | None. Against the data model | The rules accept a favourite, a preference or a bookmark for an issue or a category that does not exist. `DATABASE_AND_DATA_MODEL.md` §4.11 and §4.13 require them to exist | Both developers: tolerate and clean up, or let a rule read one document |
| E-4 | SEC-CHK-03 | `signed_url_lifetime` has no stated unit and no ceiling, so a wrong setting would issue a long-lived link | A unit and a ceiling from OQ-37 and CFG-06 |
| G-10 | None. Every file is still checked before readers can reach it | An upload that fails part-way leaves a file in the private area or the holding area, and the job pending. The cleanup that would remove them (OP-41) is not built | Build that part of OP-41 before uploads are used |
| B-2 | None. Against `API_AND_BACKEND_CONTRACT.md` §2.4 | `request_id` is required and not stored. `API_AND_BACKEND_CONTRACT.md` §2.4 says the backend remembers it. A late retry of an old profile save can overwrite a newer one | Both developers: accept it for OP-10, or add a store for request identifiers |

### 6.2 Found and fixed in the spike

| Notes | What was wrong | Fix |
|---|---|---|
| `06-admin-operations-notes.md` §3 | The bookmark rules let a repeat change the file revision, and allowed two bookmarks for one page | The key carries the issue and the page, and an update must change nothing |
| `07-issue-file-notes.md` §3 | An identifier with a slash in it became a path. An admin call could write into a file record, and a reader got `INTERNAL` instead of `INVALID_ARGUMENT` | Every identifier a caller supplies is checked before it reaches the database |

## 7. Re-run on ENV-TEST

ENV-TEST does not exist yet. It needs DEC-023 and MFW's approval (OQ-40). Each case below is run there once, and the result is recorded with the project and the date.

| No. | Case | Why the emulators cannot show it | From |
|---|---|---|---|
| 1 | A forged token, an unsigned token and an expired token, each refused by every function | The Functions emulator accepted all three (B-1) | B-1; FX-ADM-06 |
| 2 | A removed admin's old session: the next privileged call is refused, and the time until the refusal is measured | On the emulators the refusal is immediate | SEC-CHK-18; FX-ADM-08 |
| 3 | A deleted account's old session: how long a direct write is still accepted | Depends on real token lifetimes | H-2; SEC-CHK-11 |
| 4 | The last-admin guard under conflict: two admins removing each other, three removals at once, one admin removed twice at once | Transaction conflicts on the emulator are not a pass | `05-admin-guard-notes.md` §2; INV-03 |
| 5 | Other same-moment cases: a category name taken twice, two profile saves, a file link during a replacement, two uploads finishing together, two deletions at once | As item 4 | D-3, E-7, G-1; `04-save-profile-notes.md` §5 |
| 6 | A copy marked "only if nothing is there" does not replace an object | The Storage emulator ignores the condition | G-1 |
| 7 | A real signed link: issued only after the checks, for one object, read only; another reader's link refused; an expired link refused; the lifetime bound | The issuer is a stub | SEC-CHK-02, SEC-CHK-03; PAC-13; E-4 |
| 8 | Unpublishing while a link is live, and recording what happens | As item 7 | AR-06; `TESTING_STRATEGY.md` §16 |
| 9 | A real signed upload URL and its expiry | The upload address is a stub | G-9; DEC-020 |
| 10 | Rate limits and `RATE_LIMITED` | Not built yet. To add when rate limiting is built | SEC-CHK-19; SC-18 |
| 11 | Queries without their composite index fail on the platform | The emulator does not need the indexes | D-4, G-15 |
| 12 | A repeated storage trigger event, and a 150 MB file: its memory and time | Not reproduced by the emulator; no large file was generated | G-11; FX-PDF-05 |
| 13 | The deploy runtime and the region | The emulator ran Node 26 in the default region | B-10, B-11; DEC-031 |
| 14 | The logs in a real environment hold no personal data, tokens or links | Only the emulator's output was read | SEC-CHK-10 |

## 8. Running the Suite (for QG-08)

QG-08 stays "Blocked by DEC-003". The commands below run the spike's suite. They are not the gate.

**What is needed.**

- Node.js. The run used 26.0.0. `npm` warns that one hosting-emulator dependency supports only Node 20, 22 and 24, but the hosting emulator is not started.
- Java 21 or newer, for the emulators. `backend/spike/scripts/run-with-env.sh` puts Homebrew's `openjdk@21` first on `PATH` for the one command. On a machine without Homebrew, `java` 21 must be on `PATH`.
- No login, no cloud project and no credential.

**Commands, from the repository root.**

```bash
git fetch origin
git switch spike/sa-backend-rules
npm --prefix backend/spike ci --ignore-scripts
npm --prefix backend/spike/functions ci
npm --prefix backend/spike test
```

- **Install and first run:** the packages were installed with these lockfiles, and the root packages with lifecycle scripts off. A clean checkout has not been tried, so the install commands are NOT VERIFIED.
- **Emulator download:** the first run downloads the emulator files, about 190 MB, into `backend/spike/node_modules/.cache`. The user's home folder is not used.
- **Result:** the run ends with lines `ℹ tests`, `ℹ pass` and `ℹ fail`.
- **Load the categories for the app:** `npm --prefix backend/spike run seed` loads the three notification categories into a running emulator. It refuses any address that is not local.

## 9. What Is Not Built

Nothing here is evidence for the parts below.

| Part | Waits for |
|---|---|
| The real signed link and upload URL | DEC-020 |
| OP-24 to OP-27 (WordPress list, notification sends) | OQ-39; the dispatch work |
| OP-30 (delete an issue), revision deletion | OQ-21 |
| OP-31, OP-32 (admin list, export) | OQ-29, OQ-31, OQ-51 |
| OP-34, OP-35 and OP-37 to OP-39, the change record, ending a removed admin's sessions | OQ-58 |
| OP-28, OP-29 (admin changes to segments and notification categories) | Not built on the working position: the developers seed them (GS-Q47, GS-Q56) |
| OP-33 (subscriber export), OP-36 (change an admin's role) | Neither will be built: OP-33 is dropped (GS-Q49) and OP-36 is withdrawn |
| OP-41 schedule; the orphan and stale-job cleanup | Not started. The count repair and the deletion cleanup exist and are called directly |
| OP-42, the real first-admin step | MFW's admin list |
| Rate limits, App Check | SC-18; OQ-52 |
| Cover uploads | OQ-22 |
| The app side of account deletion (T-03.5), and topic subscriptions | The app scaffold; OQ-55 |

## 10. Choices to Agree

The spike made choices that the documents leave open. Each is recorded in the notes. These need both developers before the work is promoted (`DEVELOPMENT_WORKFLOW.md` §13).

| Area | Findings |
|---|---|
| Documents that disagree | C-2 (when the guard is built), E-2 (check 0 before sign-in), E-3 (the file-link shape in the app contract), H-1 (a repeated deletion), H-3 (deletion order) |
| Paths and identifiers | F-1 (category identifiers), G-1 (the job identifier in the file path), the bookmark key (`06-admin-operations-notes.md` §3) |
| Error codes and reasons | C-7, D-1, D-2, G-5, G-6 |
| Values that are placeholders | B-3, D-5, E-4, G-3, G-9, G-15, H-8 |
| Records kept or removed | C-1, H-4, H-5, H-6 (OQ-24, OQ-58) |
| Shapes of inputs and replies | B-8, C-6, D-7, E-10, G-7, H-7 |
