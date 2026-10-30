# Backend spike notes 01: access inventory

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`; findings merge later as a document, `DEVELOPMENT_WORKFLOW.md` section 13) |
| Task | Backend spike for T-01.4 (spike part), T-03.6 and T-07.1 in `DEVELOPMENT_ROADMAP.md` |
| Date | 30 October 2026 |
| Status | Working notes. PROPOSED. Not reviewed. Written from the documents only. The rules and tests that follow from it are in `03-rules-notes.md` (290 tests, emulator only) |
| Rests on | DEC-003 and DEC-020 (OPEN); DEC-026, DEC-027, DEC-029 (PROPOSED). The Firebase mapping is PROVISIONAL (TD-03) |

**Purpose.** Deny-by-default (SC-05) needs a list to deny against. This file lists every entity and operation with who may do what, and records where the sources disagree, so that the rules and their tests are written against one agreed table.

**Sources.** `DATABASE_AND_DATA_MODEL.md` section 19 (access by entity and actor) and section 9 (private access); `API_AND_BACKEND_CONTRACT.md` sections 2 to 6 (operations); `SECURITY_AND_ACCESS_CONTROL.md` SC-01 to SC-21.

## 1. Reading rules

1. In the data model's table, a plain letter is a direct access the rules allow. A letter followed by "f" goes through a function that checks the caller on every call. A dash means no access.
2. The "Functions and triggers" column lists what the backend itself writes. For the test table below, a client write is **refused unless the actor column grants it directly** (a plain letter).
3. "Own" means the record whose owner is the caller (INV-11).
4. Every function starts with the same check: authenticated, current role record and account status read on this call, refused if they cannot be read (INV-08, SC-02, SC-03). No role is read from a token (SC-04).

## 2. Entities and actors

Expected result of a **direct client access** (rules), by actor. "Refuse" is what a test asserts.

| Entity | Logged out | Reader (own) | Reader B (other) | Admin | Notes for the tests |
|---|---|---|---|---|---|
| APP_USER | refuse | read | refuse | refuse (list is OP-31) | Client write refused for everyone |
| READER_PROFILE | refuse | read | refuse | refuse (list is OP-31) | Client write refused. Update only through OP-10 |
| CONSENT_RECORD | refuse | read | refuse | refuse | Client write refused. Create only through OP-10 |
| INDUSTRY_SEGMENT | read | read | read | read | Client write refused for everyone. Admin write is conditional (AOQ-16), finding A-2 |
| ISSUE_CATEGORY | read | read | read | read | Client write refused for everyone. Writes through OP-17 and OP-18 |
| ISSUE, published | read | read | read | read | Client write refused. No file location in the record (finding A-9) |
| ISSUE, unpublished | refuse | refuse | refuse | refuse | Admin reads through OP-15 only (GS-Q20) |
| ISSUE_SEGMENT | read, published issues only | same | same | same | The `segment_ids` array on the issue (DM section 12), so it follows the issue's rule. Finding A-3 (resolved) |
| ISSUE_FILE | refuse | refuse | refuse | refuse | No client access at all. Release only through OP-11 |
| BOOKMARK | refuse | create, read, update, delete | refuse | refuse | Finding A-4 |
| FAVOURITE | refuse | create, read, update, delete | refuse | refuse | Finding A-4. Below full access: OQ-12 |
| NOTIFICATION_CATEGORY | read | read | read | read | Three fixed categories (GS-Q47). Client write refused for everyone |
| NOTIFICATION_PREFERENCE | refuse | create, read, update, delete | refuse | refuse | Category must exist and be active (OP-09) |
| NOTIFICATION_SEND | refuse | refuse | refuse | refuse | Admin reads through OP-27 |
| NEWS_CONTROL | read | read | read | read | Client write refused. Writes through OP-23. No admin identity in the record (INV-12) |
| DELETED_ISSUE | read | read | read | read | Client write refused. Contains no personal data |
| UPLOAD_JOB | refuse | refuse | refuse | refuse | Admin reads through OP-20 |
| EDITION_UPDATE_SIGNUP | not built | not built | not built | not built | Dropped on the working position (GS-Q49, OQ-31). Falls under deny-by-default |
| ADMIN_ROLE | refuse | refuse | refuse | refuse | Functions only (INV-05). Finding A-6 |
| ADMIN_AUDIT_EVENT | refuse | refuse | refuse | refuse | Exists only if OQ-58 is approved. Functions only (INV-05) |
| ADMIN_GUARD | refuse | refuse | refuse | refuse | Functions only (INV-05) |
| APP_CONFIG, public | read | read | read | read | Client write refused |
| APP_CONFIG, private | refuse | refuse | refuse | refuse | Functions only |
| Any path not listed | refuse | refuse | refuse | refuse | SC-05. Includes the file store: every direct read of the private area is refused (DM section 9, item 4) |

## 3. Operations

"Built here" names the planned spike step. "Later" means the operation is outside this list or waits for an input.

| Operation | Access path | Caller | Built here? |
|---|---|---|---|
| OP-01 listCatalogue, OP-02 getPublicConfig, OP-03 listDeletedIssues, OP-04 listNewsControls, OP-05 listNotificationCategories | direct, public read | anyone | Rules only |
| OP-06 getMyAccount | direct, own records | reader | Rules only |
| OP-07 manageBookmarks, OP-08 manageFavourites, OP-09 managePreferences | direct, own records | reader | Rules only |
| OP-10 saveProfile | server | reader | Yes |
| OP-11 getIssueFile | server | reader | Yes, with a stub for the signed link (DEC-020) |
| OP-12 requestAccountDeletion | server | the account owner | Yes, PROVISIONAL (DEC-029, OQ-24) |
| OP-13 cancelAccountDeletion | withdrawn | none | No |
| OP-14 getMyAdminRole | server | any signed-in reader | Yes |
| OP-15, OP-16, OP-17, OP-18, OP-21, OP-22, OP-23 | server | admin | Yes |
| OP-19 requestUpload, OP-20 listUploadJobs | server | admin | Yes, backend only |
| OP-40 onUploadFinalized | trigger | the backend | Yes, PDF path only (cover rules: OQ-22) |
| OP-24 listWordPressPosts | server | admin | Later (needs a fixture; WordPress address OQ-39) |
| OP-25, OP-26, OP-27 | server | admin | Later (dispatch is not in this list) |
| OP-28, OP-29 | not built on the working position | none | No (GS-Q47, GS-Q56) |
| OP-30 deleteIssue | server | admin | Later (OQ-21) |
| OP-31, OP-32 | server | admin | Later (OQ-29, OQ-31, OQ-51) |
| OP-33 exportSubscribers | dropped | none | No (GS-Q49) |
| OP-34, OP-35, OP-37, OP-38, OP-39 | server | admin | Later (OQ-58) |
| OP-36 changeAdminRole | withdrawn | none | No |
| OP-41 scheduledMaintenance | schedule | the backend | Partly: admin-count repair, deletion cleanup, holding-area cleanup |
| OP-42 bootstrapAdmin | developer-run step | two developers | Test-only seed here. The real step waits for MFW's admin list |

## 4. Findings

None of these is settled here. Each is recorded so that the spike tests the documented behaviour and reports the difference, instead of choosing silently.

| ID | Finding | Sources | What the spike does |
|---|---|---|---|
| A-1 | The backend stores no device token. The app-side contract's `registerDevice` assumes stored registrations. This is the open difference about device tokens or topics | DM section 2.1 (M3) and section 3.2; API contract section 3.4 and section 11 (TD-13); `API_AND_MODULE_CONTRACTS.md` OP-NTF-01 | Account deletion (OP-12) has no device record to delete. Nothing about registration is built |
| A-2 | The data model gives an admin create and update on INDUSTRY_SEGMENT (AOQ-16). The API says OP-28 is not built on the working position, and segments are seeded | DM section 19; API contract OP-28; GS-Q47, GS-Q56 | Tests assert there is no write path for anyone. The conditional case is not built |
| A-3 | **Resolved.** ISSUE_SEGMENT is readable by anyone only for published issues. The data model keeps the links as the `segment_ids` array on the issue, so the issue's rule covers them | DM section 19 and section 12 | Tested in G2. No cross-document read is needed |
| A-4 | RS section 9.2 says bookmarks need full access. OP-07 lists ownership and the page number as its checks, and the security design says rules do not look up account status | RS section 9.2; API contract OP-07; `SECURITY_AND_ACCESS_CONTROL.md` section 4.3, T25 | Tests cover ownership. Whether the server also refuses creation below full access is raised with Yuvraj |
| A-5 | A reader whose account is being deleted can still use the direct operations on their own records. Every function is refused with `ACCOUNT_CLOSED` | `SECURITY_AND_ACCESS_CONTROL.md` section 4.3, T25 | Tests assert the documented behaviour and name it |
| A-6 | ADMIN_ROLE changes by function exist only if OQ-58 is approved. Without it a developer-run step grants admin access. INV-03 applies in both cases | DM section 4.17 and section 10; API contract section 5.2 | Records and the last-admin rule are built. In-panel add and remove are not |
| A-7 | An admin can upload a file to the holding area. The data model says the write is only through the uploader's signed upload URL. A signed URL is checked by the file store, not by the rules, so the rules can deny every client read and write there | API contract OP-19, OP-40; DM sections 8 and 9 | The rules deny the holding area (G4). The signed upload URL is not tested, because emulator support for signed URLs was not researched |
| A-8 | The deleted-issue list is read by OP-11 (check 0) and is public (OP-03). Its writer is OP-30, which waits for OQ-21 | API contract OP-11, OP-03, OP-30 | Tests seed an entry. No writer is built |
| A-9 | The public ISSUE record must carry no file location. The location lives in ISSUE_FILE, which has no client access | DM section 9, item 1; SC-07 | The rules deny `issues/{id}/files/*` for every actor (G1). Whether the function that writes an issue keeps the location out of it is tested with `saveIssue` |
| A-10 | Rules cannot check that a referenced issue or category exists (no rule reads another document), although the data model's validation for a favourite and a preference says it must | DM sections 4.11 and 4.13; `SECURITY_AND_ACCESS_CONTROL.md` section 13 | The tests show the gap and name it. A decision for both developers (see `03-rules-notes.md`) |
| A-11 | A query on `issues` is allowed only with the published filter. An unfiltered list is refused, even for a visitor | `SECURITY_AND_ACCESS_CONTROL.md` section 12.1 | Tested in G2. The app's catalogue query must carry the filter |
| A-12 | Paths under `users/{uid}` that no rule lists are refused, even for the owner | `SECURITY_AND_ACCESS_CONTROL.md` section 12.1 | Tested in G1. A new subcollection needs a rule |

## 5. Test groups

| Group | What it proves | Checklist item |
|---|---|---|
| G1 Deny by default | Unlisted path refused for logged out, reader and admin; functions-only entities refused for everyone | SEC-CHK-05, SC-05 |
| G2 Public reads | The public entities read for anyone; writes refused; unpublished issue refused | SC-05 |
| G3 Own records | Reader A reads and writes own records; Reader B and logged out refused; admin refused | SEC-CHK-05 |
| G4 Private files | Direct reads of the private area refused, with and without sign-in; a guessed path refused | SEC-CHK-02, SEC-CHK-03 |
| G5 Admin gate | Reader session on an admin operation refused; removed admin refused on the next call; role record unreadable refused; forged claim refused | SEC-CHK-06, SEC-CHK-18, SC-02 to SC-04 |
| G6 Function checks | One refused test per check of OP-10, OP-11 and OP-12; allowed path for each | SEC-CHK-02, SEC-CHK-11 |
| G7 Upload | Not a PDF, over the limit, uploader no longer admin, valid file accepted | SEC-CHK-07 |

Every result is recorded as "emulator only". Concurrency, token handling and real signed links are re-run when a test environment exists (`TECHNOLOGY_DECISIONS.md`, section on test evidence).
