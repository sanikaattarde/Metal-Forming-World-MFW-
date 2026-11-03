# Test Data and Fixtures: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Test Data and Fixtures |
| File | `Documentation/TEST_DATA_AND_FIXTURES.md` |
| Phase | 4 — Testing, Release and Risk Management (document 32) |
| Version | 0.3 |
| Status | Draft for review. Not approved. Every fixture is PLANNED. None has been created. |
| Date | 31 October 2026 |
| Approval required | Both developers. MFW confirms where its sample PDFs may be stored (DEC-024). |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. FX-USR-13, FX-ADM-08 and FX-ADM-09 added. Planned name replaced by the existing document. |
| 0.3 | 31 October 2026 | FX-LIB-01 to FX-LIB-03 name the file revision of each bookmark, because the bookmark contract requires one. No other fixture changed. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `TESTING_STRATEGY.md`, `ACCEPTANCE_CRITERIA.md` | Exist (draft). They use the fixture IDs below. |
| `API_AND_MODULE_CONTRACTS.md` | Exists (draft). Access states and payload shapes. |
| `DECISION_LOG.md` DEC-024 | Exists (draft). Test data policy (PROPOSED). |
| `REQUIREMENTS_SPECIFICATION.md` (RS) | Exists, draft |
| `DATABASE_AND_DATA_MODEL.md` | Exists on `main` (draft; planned as `DATABASE_DESIGN.md`). Seed formats for ENV-TEST wait for the data model to be agreed. |

Status labels follow RS §1.2. **PLANNED** means designed but not created.

## 2. Purpose, Scope and Status

This document defines safe, repeatable test data: users and roles, access states, magazine metadata, PDF files, network scenarios, bookmarks and favourites, WordPress responses, notification payloads, and admin test cases.

**This task creates no fixture files, no large test files and no code.** Formats for backend seed data are blocked by DEC-003 and by agreement of `DATABASE_AND_DATA_MODEL.md`.

## 3. Principles

1. **Synthetic only.** Every identity and record is invented for testing. No real reader, MFW staff or production data (DEC-024).
2. **No credentials in the repository.** Passwords for test accounts are generated when the account is set up and stored in the team's password manager (owner: OPEN). They never appear in fixtures, code, documents or commit messages.
3. **Deterministic.** Fixed IDs prefixed `fx-`, fixed UTC timestamps, sorted lists, and an injected clock in unit tests. Automated tests never depend on the live WordPress site.
4. **MFW content is confidential.** MFW's sample PDFs and launch content are covered by the S1 confidentiality term. They are not committed to Git, and are kept only where MFW approves.
5. **Large files stay out of Git.** Files above about 1 MB are generated or fetched on demand. A manifest with SHA-256 checksums is committed instead.

## 4. Fixture Storage and Formats

All paths are PROPOSED. They are created in WP-01 or later.

| Kind | Format | Location | Committed to Git |
|---|---|---|---|
| Small JSON fixtures (WordPress, notifications, metadata) | JSON | `app/test/fixtures/` | Yes |
| Small PDFs (1 MB or less) | PDF | `app/test/fixtures/pdf/` | Yes, if generated synthetically |
| Large PDFs and MFW samples | PDF | Team or MFW-approved storage; ENV-TEST storage for downloads | No. Listed in `app/test/fixtures/large_files_manifest.json` with SHA-256 and size. |
| Generation script for large synthetic PDFs | Script | `tools/fixtures/` (PROPOSED) | Yes, once written. Not written in this task. |
| ENV-TEST seed data | Blocked by DEC-003 | `backend/seed/` (PROPOSED) | Yes, synthetic only |
| Test-account credentials | — | Team password manager | **Never** |

## 5. Test Users, Roles and Access States

Access states follow `API_AND_MODULE_CONTRACTS.md` §4.1.

| ID | Role | Sign-in method | Email verified | Profile | Access state | Used by | Status |
|---|---|---|---|---|---|---|---|
| FX-USR-01 | Reader A | Email and password | Yes | Complete | `fullAccess` | AC-2, AC-3.6, AC-4, AC-5, AC-8.2 (as non-admin), AC-9.5 | PLANNED |
| FX-USR-02 | Reader | Email and password | No | Complete | `emailUnverified` | AC-3.4, AC-3.5 | PLANNED |
| FX-USR-03 | Reader | Email and password | Yes | Incomplete | `profileIncomplete` (PROVISIONAL) | PAC-02 | PLANNED |
| FX-USR-04 | Reader | Google | Rule: OQ-04 | Complete | `fullAccess` (PROVISIONAL, C-04) | PAC-01 | PLANNED |
| FX-USR-05 | Reader | Google | Rule: OQ-04 | Incomplete | `profileIncomplete` | PAC-01, PAC-02 | PLANNED |
| FX-USR-06 | Reader B (isolation) | Email and password | Yes | Complete | `fullAccess` | AC-5.4, SEC-CHK-05 | PLANNED |
| FX-USR-07 | Reader to be deleted | Email and password | Yes | Complete, with library data and preferences | `fullAccess` | AC-3.7, PAC-06 | PLANNED (recreated each cycle) |
| FX-USR-08 | Admin | Admin sign-in (OQ-20) | — | — | Admin | AC-8, AC-9 | PLANNED |
| FX-USR-09 | Logged-out visitor | None | — | — | `signedOut` | AC-1, AC-3.3, AC-3.5, PAC-04 | Not an account |
| FX-USR-10 | Readers with boundary age values, for the OQ-07 review | Email and password | Yes | Complete | `fullAccess` | Profile validation once OQ-02 and OQ-07 are answered | BLOCKED |
| FX-USR-11 | Same address registered by email, then tried with Google | Both | Yes | Complete | Per OQ-05 | PAC-12 | BLOCKED |
| FX-USR-12 | Store-review demo account, production only | Email and password | Yes | Complete | `fullAccess` | `APP_STORE_RELEASE_CHECKLIST.md` | BLOCKED (OQ-43). Created only with MFW's approval. Credentials are given only through the store consoles. |
| FX-USR-13 | A known and an unknown email address, for the registration, sign-in and password-reset messages | Email and password | Known address: Yes | Known address: Complete | Not applicable | SEC-CHK-17, PAC-17 | PLANNED |

**Addresses**

- Flows that need a real inbox (verification, password reset) use a team-controlled test mailbox with plus-addressing, for example `<test-mailbox>+mfw-usr01@<team-domain>`. The mailbox owner is OPEN.
- Flows that never send email may use the reserved domain `example.com`.
- Google test accounts are dedicated test accounts, never personal ones. Who owns them is OPEN.

**Profile values** are synthetic, for example name "Test Reader 01", occupation "Test Engineer", domain of work "Test Domain". Gender values and age format follow OQ-01 and OQ-02 once decided.

## 6. Magazine Metadata and Categories

Values are synthetic placeholders, not MFW's real categories or issues. MFW supplies the real launch content (CH §12).

| ID | Content |
|---|---|
| FX-CAT-01 to FX-CAT-04 | Four categories named "Test Category A" to "Test Category D" |
| FX-ISS-01 | Latest issue, published, FX-CAT-01, year 2026, edition "E1", industry segment "Segment 1", cover image, linked to FX-PDF-01 |
| FX-ISS-02 to FX-ISS-07 | Six archive issues, published, spread over FX-CAT-01 to FX-CAT-04, years 2025 and 2026, editions "E1" to "E3", two industry segments |
| FX-ISS-08 | Unpublished issue, for the publish and unpublish tests (AC-1.4, AC-8.7) |
| FX-ISS-09 | Issue with a long title containing special characters (`&`, quotes, `₹`, accented letters), for layout and search tests |
| FX-ISS-10 | Issue linked to FX-PDF-05 (near-limit file), for download and performance tests |

The meanings of "edition" and "industry segment" are OQ-13. The fixture values are neutral placeholders until those are answered. Publication dates are fixed synthetic dates.

## 7. PDF Files

The upload limit is 150 MB by default (RS FR-ADMIN-007). Whether exactly 150 MB is accepted, and whether "MB" means 10⁶ or 2²⁰ bytes, are open (OQ-30). The boundary fixtures are therefore defined relative to the limit value, L.

| ID | Description | Approximate size | Source | In Git | Used by |
|---|---|---|---|---|---|
| FX-PDF-01 | Small valid PDF, about 4 portrait pages, with text | 1 MB or less | Generated | Yes | Unit, widget and smoke tests; FX-ADM-01 |
| FX-PDF-02 | Valid PDF mixing portrait and landscape pages, including spreads | 5 MB or less | Generated | No (manifest) | AC-2.4 |
| FX-PDF-03 | MFW sample PDFs (two or three) | As supplied | MFW (CH §12) | **No** (confidential) | T-02.3 reader test; AC-2 |
| FX-PDF-04 | MFW's largest expected issue | As supplied | MFW (CH §12) | **No** (confidential) | AC-2.1; risk R2 |
| FX-PDF-05 | Synthetic near-limit PDF, about 120 pages (RS ASM-01) of high-resolution images | Just below L | Generated by script | No (manifest) | AC-4.3; performance |
| FX-PDF-06 | Boundary file | Exactly L | Generated by padding | No (manifest) | AC-8.5 (expected result: OQ-30) |
| FX-PDF-07 | Over the limit | L + 1 byte | Generated by padding | No (manifest) | AC-8.5 |
| FX-PDF-08 | Non-PDF renamed with a `.pdf` extension (for example PNG bytes) | Small | Generated | Yes | AC-8.4 |
| FX-PDF-09 | Starts with the `%PDF-` header but is not a valid PDF | Small | Generated | Yes | AC-8.4 (depth of the "genuine PDF" check) |
| FX-PDF-10 | Truncated PDF (valid first half only) | Small | Generated | Yes | AC-2.6 |
| FX-PDF-11 | PDF with a corrupted cross-reference table | Small | Generated | Yes | AC-2.6 |
| FX-PDF-12 | Password-protected PDF | Small | Generated | Yes | Upload behaviour (OQ-30) |
| FX-PDF-13 | Zero-byte file named `.pdf` | 0 bytes | Generated | Yes | Upload validation |

## 8. Download and Network Scenarios

These are procedures, not files. They are run with OS airplane mode, the platform network-conditioning tools, or a fault-injecting test proxy (candidate tooling in `DEPENDENCY_REGISTER.md`).

| ID | Scenario | Procedure (PROPOSED) | Expected result |
|---|---|---|---|
| FX-NET-01 | Network lost mid-download | Start FX-PDF-05; enable airplane mode at about 50%; restore after about 30 seconds | Waits, then resumes from the same point (AC-4.3) |
| FX-NET-02 | Wi-Fi to mobile data mid-download | Turn Wi-Fi off during a download, with mobile data on | Behaviour agreed in WP-06 (`TESTING_STRATEGY.md` §7.5) |
| FX-NET-03 | App closed or killed mid-download | Force-stop the app at about 50% and reopen | No partial file listed. Resume or restart as WP-02 decides. |
| FX-NET-04 | Device restarted mid-download | Restart the device at about 50% | Same as FX-NET-03 |
| FX-NET-05 | Grant expires mid-download | Use a short grant lifetime in ENV-TEST; throttle the connection | A new grant is requested; continues from the same offset (DEC-020) |
| FX-NET-06 | Storage full | Fill device storage until free space is below the file size | Clear message; no partial file listed (RS FR-STATE-004) |
| FX-NET-07 | Server error or connection reset mid-transfer | Inject a reset or error through the test proxy | Retryable failure; a retry continues or restarts cleanly |

## 9. Bookmarks and Favourites

| ID | Content | Used by |
|---|---|---|
| FX-LIB-01 | Reader A (FX-USR-01): bookmarks FX-ISS-01 page 7 and FX-ISS-02 page 12, both on revision 1; favourite FX-ISS-03 | AC-5.1, AC-5.3 |
| FX-LIB-02 | Reader B (FX-USR-06): bookmark FX-ISS-01 page 3 on revision 1; favourite FX-ISS-04 | AC-5.4 |
| FX-LIB-03 | A bookmark on revision 1 of FX-ISS-08, which is then unpublished | Behaviour per OQ-11 and OQ-21 |

## 10. WordPress API Responses

These are recorded or hand-written JSON files, shaped like the standard WordPress REST API (`API_AND_MODULE_CONTRACTS.md` §9.1). Contents are synthetic. A recording from MFW's live site may be used only after the content check in Section 14.

| ID | Scenario | Shape |
|---|---|---|
| FX-WP-01 | First page of posts, with matching categories | 10 posts with embedded featured media; headers `X-WP-Total: 25`, `X-WP-TotalPages: 3`; plus a list of 3 categories |
| FX-WP-02 | Last page | 5 posts |
| FX-WP-03 | Empty category | `[]` |
| FX-WP-04 | Post without featured media | No `_embedded` media entry |
| FX-WP-05 | Post with embedded media and a `<script>` element | For SEC-CHK-15 and OQ-16 |
| FX-WP-06 | Titles with HTML entities and non-ASCII characters | For example `&#8217;` and `₹` |
| FX-WP-07 | Page out of range | HTTP 400 with code `rest_post_invalid_page_number` |
| FX-WP-08 | REST API blocked, for example by a security plugin | HTTP 401 or 403 |
| FX-WP-09 | Wrong route or base address | HTTP 404 with code `rest_no_route` |
| FX-WP-10 | Server error | HTTP 500 or 503 |
| FX-WP-11 | Slow response | Delay beyond the client timeout |
| FX-WP-12 | HTML instead of JSON, with status 200 (for example a cache or firewall page) | Maps to `invalidResponse` |
| FX-WP-13 | News controls | One FX-WP-01 post hidden and one marked breaking (RS DATA-009) |

Example shape (synthetic, abbreviated):

```json
[
  {
    "id": 101,
    "date_gmt": "2026-01-15T09:30:00",
    "link": "https://wordpress.example/news/test-post-101/",
    "title": { "rendered": "Test post 101 &#8211; synthetic" },
    "content": { "rendered": "<p>Synthetic body text.</p>" },
    "categories": [11],
    "_embedded": { "wp:featuredmedia": [ { "source_url": "https://wordpress.example/img/101.jpg" } ] }
  }
]
```

## 11. Notification Payloads

The shape follows `API_AND_MODULE_CONTRACTS.md` §6.11 (PROPOSED).

| ID | Payload | Expected result |
|---|---|---|
| FX-NTF-01 | `{"type":"issue","targetId":"fx-iss-01","sendId":"fx-send-01"}` | Opens FX-ISS-01 details, or the reader if allowed |
| FX-NTF-02 | `{"type":"article","targetId":"101","sendId":"fx-send-02"}` | Opens the article |
| FX-NTF-03 | Breaking-news article from a WordPress post | Opens the article. Presentation per OQ-17. |
| FX-NTF-04 | Unknown `type` | Ignored safely; opens the home screen |
| FX-NTF-05 | Missing `targetId` | Opens the home screen; warning logged without personal data |
| FX-NTF-06 | Issue since unpublished | "No longer available" message |
| FX-NTF-07 | Issue, received while signed out | Sign-in prompt instead of the issue (RS BR-005) |
| FX-NTF-08 | Malformed or oversized payload | Ignored safely; no crash |

## 12. Admin Uploads and Authorization

| ID | Content | Expected result |
|---|---|---|
| FX-ADM-01 | FX-PDF-01, a valid synthetic cover image and complete details | Upload succeeds (AC-8.3) |
| FX-ADM-02 | Cover in a format not allowed | Rejected per OQ-22 |
| FX-ADM-03 | Cover over the size limit | Rejected per OQ-22 |
| FX-ADM-04 | Required issue details missing | Rejected with field messages |
| FX-ADM-05 | Admin operation called with a reader session (FX-USR-01) | Refused on the server (SEC-CHK-06) |
| FX-ADM-06 | Admin operation with an expired or signed-out admin session | Refused; asked to sign in |
| FX-ADM-07 | Registered-user rows whose synthetic names start with `=`, `+`, `-` or `@` | Exported cells are escaped (SEC-CHK-12) |
| FX-ADM-08 | An admin whose role record is removed while a session opened before the removal is still held | Refused on the next privileged call (SEC-CHK-18). The time until the refusal is measured and reported |
| FX-ADM-09 | A replacement PDF that fails validation (FX-PDF-10 or FX-PDF-12) for an issue that already has a current revision | The current revision stays in place and readers can still download it. Applies only if OQ-21 allows a replacement |

## 13. Setup and Teardown

| Level | Setup | Teardown |
|---|---|---|
| Unit and widget | In-memory fakes loaded from `app/test/fixtures/` | Nothing persists |
| App integration (ENV-LOCAL) | Fakes, plus local files copied into the app's private storage for reader tests | Uninstall, or clear app data |
| ENV-TEST | Seed scripts create the FX-CAT, FX-ISS, FX-USR and FX-LIB records and upload fixture files (blocked by DEC-003). Accounts get fresh passwords from the password manager. | Reset before each acceptance cycle: delete `fx-` records, re-seed, recreate FX-USR-07 |
| Devices | Install the build under test; set notification preferences per AC-9.2 | Delete downloads; uninstall where needed |
| ENV-PROD | Only FX-USR-12, with MFW's approval | Remains for store review, as MFW decides |

## 14. Privacy Safeguards

1. No production data in ENV-LOCAL or ENV-TEST (DEC-024).
2. Real personal data never appears in fixtures, screenshots, recordings or test reports.
3. MFW sample PDFs are confidential (S1 Key terms). They are not attached to public issues or pull requests, not committed to Git, and not shared outside the team.
4. Recorded WordPress responses are public posts, but are checked before being committed: no author email addresses, no comments, no personal data.
5. CSV exports produced in tests contain synthetic users only, and are deleted after verification.
6. Logs captured during tests are checked against `CODING_STANDARDS.md` §6.2 before they are attached as evidence.

## 15. Ownership

| Fixtures | Owner (PROPOSED) |
|---|---|
| FX-USR, FX-ADM, FX-NTF | WS-A |
| FX-CAT, FX-ISS, FX-PDF, FX-NET, FX-LIB, FX-WP | WS-B |
| FX-PDF-03, FX-PDF-04, launch content, approval for FX-USR-12 | MFW supplies or approves |
| Manifest and generation scripts | WS-B |

## 16. Open Items

| Item | Reference |
|---|---|
| Owner of the team test mailbox and the password manager | OPEN |
| Where large fixtures and MFW samples are stored | DEC-024; MFW to confirm |
| Profile field values and age format | OQ-01, OQ-02 |
| Upload boundary, the unit of "MB", and password-protected PDFs | OQ-30 |
| Cover-image rules | OQ-22 |
| Notification categories | OQ-18 |
| WordPress site and categories | OQ-39 |
| Google test-account ownership | OPEN |
| Store-review demo account | OQ-43 |
| ENV-TEST seed format | DEC-003; `DATABASE_AND_DATA_MODEL.md` (draft) |
