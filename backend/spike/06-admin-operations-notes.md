# Backend spike notes 06: the admin operations, and a bookmark rule fix

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`) |
| Date | 30 October 2026 |
| Task | Backend spike for the server part of T-09.3 and T-09.4 in `DEVELOPMENT_ROADMAP.md`: OP-15 to OP-18 and OP-21 to OP-23 from `API_AND_BACKEND_CONTRACT.md` section 5.1 |
| Status | Working notes. PROPOSED. Not reviewed. Every result is "emulator only" |
| Rests on | DEC-003 (OPEN); DEC-026 and DEC-027 (PROPOSED); OQ-13 and OQ-17 (OPEN) |

## 1. What was built

| Operation | What it does | Refuses |
|---|---|---|
| OP-15 `listIssuesForAdmin` | A page of issues, including unpublished ones, newest publication date first, with a cursor | `INVALID_ARGUMENT` |
| OP-16 `saveIssue` | Creates or edits an issue's details. It cannot set `publication_state`, `current_revision`, the file facts or the cover. References are checked inside the transaction (INV-13) | `INVALID_ARGUMENT`, `NOT_FOUND`, `GONE`, `CONFLICT` `STALE_RECORD` |
| OP-17 `saveCategory` | Creates or edits a category. The name is unique, ignoring case | `INVALID_ARGUMENT`, `NOT_FOUND`, `CONFLICT` `NAME_TAKEN` |
| OP-18 `deleteCategory` | Deletes a category nobody uses | `INVALID_ARGUMENT`, `FAILED_PRECONDITION` `IN_USE` |
| OP-21 `publishIssue` | Publishes only with an accepted current revision and the required details, in one transaction (INV-02) | `NOT_FOUND`, `FAILED_PRECONDITION` `NO_ACCEPTED_FILE`, `INVALID_ARGUMENT` |
| OP-22 `unpublishIssue` | Hides the issue | `NOT_FOUND`, `INVALID_ARGUMENT` |
| OP-23 `setNewsControl` | Sets the hidden and breaking flags. Neither flag set removes the record. It sends no notification | `INVALID_ARGUMENT` |

`adminCall.ts` is the one way to declare a privileged operation. It runs the sign-in check and `requireAdmin` before the handler sees any input, so an operation cannot leave them out, and a reader with bad input learns nothing about the input.

**Repeats.** A create derives its identifier from the caller and the `request_id`, so a retry after a lost reply finds the same record and makes no second one. An edit that matches what is stored succeeds and writes nothing, whatever `expected_updated_at` says. Publish and unpublish change nothing if the issue is already in that state.

**Not built.** The panel screens (B5), OP-24, OP-25 to OP-27, OP-28 and OP-29 (GS-Q47, GS-Q56), OP-30 and the upload operations (B2.8). Tests seed the accepted file record, because no upload exists yet.

## 2. Results

`npm --prefix backend/spike test` on 30 October 2026: **542 tests, 542 passed, 0 failed.** Emulator only.

| Group | Tests | What it shows |
|---|---|---|
| G8 Admin operations | 112 | Each of the seven operations, for six kinds of caller who must be refused, each checking that nothing was written, plus a control showing the same call works for an active admin. Then each operation's behaviour, shapes and refusals. With the rules: a visitor can read an issue only while it is published |
| U2 Issue checks | 34 | The input checks for OP-16 and the derived identifier. No database |
| G3 Own records | 58 | Four more than before: see section 3 |
| G0, G1, G2, G4, G5, G6, U1 | 338 | Unchanged |

The six callers refused by every operation: no token; a reader; a reader with forged admin claims; a removed admin with a token from before the removal; an admin whose account is marked deleting; an admin the provider has disabled.

**Do the tests catch broken code?** 39 deliberate breaks were tried one at a time, each on a clean baseline, and each made at least one test fail. They include removing the gate, running the gate after the work, publishing without a file, removing the stale-screen check, and reading the name check outside the transaction. One break first failed to compile, so it was rewritten and then caught. Listing the breaks also showed that nothing tested a last page that is exactly full, so that test was added before the run.

## 3. The bookmark rule fix

Reviewing pull request 9 showed an error in the rules of `03-rules-notes.md`. They let a repeat change a bookmark's `file_revision`, but `DATABASE_AND_DATA_MODEL.md` section 4.10 says that bookmarking a page already bookmarked changes nothing. They also allowed two bookmarks with different keys for one page.

| Rule now | Why |
|---|---|
| The document key must be `<issue_id>_<page_number>` | A direct write has no function to check uniqueness, so the key has to carry it. Section 12 says the key "can be derived from the issue and page". The format is a spike choice |
| An update must change nothing | A replayed write with the same values passes. Any change is refused, so a bookmark keeps the revision it was first made on |

**What this means for MOD-08.** A repeat with a new `created_at` is refused, not ignored, so the app must check first or treat that refusal as "already bookmarked". Removing a bookmark and adding it again makes a new one on the later revision, which is tested. That is also the way to clear the "revision differs" notice.

## 4. Findings

| ID | Finding | What it means |
|---|---|---|
| D-1 | `API_AND_BACKEND_CONTRACT.md` section 11 lists no callable code for `CONFLICT`. `aborted` is used, with the reason in the details | To agree, since the app and the panel will read it |
| D-2 | The contract names no reason for a duplicate category name. `NAME_TAKEN` is added | To agree |
| D-3 | Uniqueness of a category name relies on a transaction reading the whole collection. On the emulator one of two creates won in each of 5 rounds, and reading outside the transaction was caught. How this behaves on the platform is NOT VERIFIED (`TECHNOLOGY_DECISIONS.md` section 9.4, item 20) | Re-run on a test project. If it fails, a record keyed by the name is the alternative |
| D-4 | The filtered list needs the composite index the data model names. The emulator does not require it, so a missing index will not show here | Write the index file before anything is deployed |
| D-5 | No document sets the title, description or category name lengths, or the page size. They are placeholders (200, 5000, 200, 100) | Set with the panel designs. "The largest page size is OPEN" |
| D-6 | `segment_ids` is optional here, because the contract asks only that those named exist | OQ-13 may change it |
| D-7 | `publication_date` as `YYYY-MM-DD`, `expected_updated_at` in milliseconds, and the reply shapes are spike choices. Two saves in the same millisecond would not be told apart | To settle with the panel in B5 |
| D-8 | Editing a published issue takes effect at once, because S2 excludes a draft and review workflow | As designed. Worth making clear on the panel screen |
| D-9 | Unpublishing keeps `published_at`. No document says either way | Small. To confirm |

## 5. Not tested

1. **A real or expired token** (FX-ADM-06). The Functions emulator does not verify tokens (`04-save-profile-notes.md`, B-1).
2. **Real concurrency**, for the category name and for any transaction (D-3).
3. **The real upload path.** Accepted files are seeded until B2.8.
4. **Deployed functions, indexes and the region** (D-4; DEC-031).
5. **Rate limits** (SC-18).
