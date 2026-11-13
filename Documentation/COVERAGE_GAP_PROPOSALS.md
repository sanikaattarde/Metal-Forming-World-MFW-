# Coverage Gap Proposals: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/COVERAGE_GAP_PROPOSALS.md` |
| Task | MOD17-P1-T03, close the coverage gaps and regenerate the matrix (RC-01, RC-02) |
| Version | 0.1 |
| Status | Draft for review. **PROPOSED.** Prepared by Yuvraj Gaykhe (WS-B) on 14 November 2026. Sanika Attarde has not reviewed it. No check here is a PAC row: a new PAC row needs both developers' agreement and then MFW's written approval before it is contractual (`ACCEPTANCE_CRITERIA.md`). |
| Date | 14 November 2026 |
| Related | `REQUIREMENT_COVERAGE_MATRIX.md`; `ACCEPTANCE_CRITERIA.md`; `TEST_DATA_AND_FIXTURES.md` |

## 1. What changed on 14 November 2026

Fifteen RS CLAIM requirements are now named in the Source cell of the row that tests them (RC-02). Only the Source cells changed: no criterion, pass condition, priority or status.

| Requirement | Named in | Why that row tests it |
|---|---|---|
| FR-PROF-002 | PAC-02 | The row needs every mandatory field at registration |
| FR-PROF-003 | PAC-01 | A Google reader completes the profile before a full issue |
| FR-PROF-004 | PAC-02 | An incomplete profile is prompted before a full issue opens |
| FR-MAG-001 | PAC-04 | A logged-out visitor browses the catalogue |
| FR-SRCH-006 | PAC-04 | A logged-out visitor searches and filters |
| FR-NEWS-007 | PAC-04 | A logged-out visitor reads news |
| FR-DL-002 | PAC-13 | The issue file is refused when signed out or unverified, so no download starts |
| FR-READ-002 | AC-4.2 | A downloaded issue reads in full in airplane mode |
| NFR-OFF-001 | AC-4.2 | The same: a downloaded issue works with no network |
| NFR-COMP-002 | AC-2.4 | Tablets and landscape; phones in portrait are the setting of every other AC-2 row |
| NFR-SEC-007 | AC-8.2 | A non-admin account is refused by the admin panel; the server side is SEC-CHK-06 |
| FR-ADMIN-016 | AC-9.2 | The admin sends the category notification that the row checks |
| NFR-PRIV-004 | PAC-03 | Non-admins cannot see or export registered users |
| NFR-COMP-001 | AC-11.1 | Both store builds come from the same tagged source |
| NFR-MAINT-004 | AC-12.2 | The developer works only from the written documentation |

For review: whether AC-8.2 and AC-2.4 are enough for NFR-SEC-007 and NFR-COMP-002, or whether each needs its own check.

## 2. Candidate checks

Each candidate below is PROPOSED. If both developers agree, it goes to MFW as a new PAC row (numbers from PAC-21 on, given only when MFW approves).

| Ref | Requirements | Matrix state | Criterion | Fixtures | Pass condition |
|---|---|---|---|---|---|
| CAND-01 | FR-AUTH-008 | AREA ONLY | A signed-in reader signs out, then tries to open a full issue | FX-USR-01 | The sign-in prompt shows and no issue content. What happens to kept downloads follows OQ-11 and PAC-14 |
| CAND-02 | FR-PROF-007 | AREA ONLY | A reader changes one profile field, then signs in on a second device | FX-USR-01 | The second device shows the new value, validated as OQ-01 decides |
| CAND-03 | FR-MAG-003 | AREA ONLY | Each issue shows its category on the catalogue entry and on issue details | FX-ISS-01 to FX-ISS-07 | Every issue shows its category. AC-1.1 lists cover, title, date and description only (RC-04) |
| CAND-04 | FR-BKM-007 | AREA ONLY | A reader removes a bookmark, then looks at the list and at a second device | FX-LIB-01 | The bookmark is gone on both devices |
| CAND-05 | FR-NOTIF-002, FR-NOTIF-003 | AREA ONLY (003), RS CLAIM (002) | A reader chooses categories, later changes the choice, and the admin sends to the old and the new category | Two devices, FX-NTF-01 | Only the send to the new choice arrives. Also closes the RS CLAIM of FR-NOTIF-002, where AC-9.2 uses the choice only as its precondition |
| CAND-06 | NFR-STOR-001 | NO ROW | Upload, publish, download and open the largest MFW sample and the near-limit file | FX-PDF-04, FX-PDF-05 | Each step completes. FX-PDF-05 is not generated yet (`app/test/fixtures/README.md`), and the limit waits for OQ-30 |
| CAND-07 | NFR-STOR-002 | NO ROW | Publish twelve issues and use the catalogue, search and filters | Twelve synthetic issues | Recorded, not judged: RS sets no threshold |
| CAND-08 | NFR-OBS-001 | NO ROW | Force a crash in a test build on each platform | A test build with a crash action | A report reaches MFW's crash service with no reader identity (DATA-014). Depends on DEC-028 and C-07 |
| CAND-09 | FR-DL-001 | RS CLAIM | After a download, look for the file outside the app | FX-ISS-01 | The file is in the app's private storage only: not in the Files app, the gallery or shared storage |
| CAND-10 | FR-ADMIN-009 | RS CLAIM | The admin edits an issue's details after upload | FX-ISS-02 | The app shows the edited details. AC-8.3 enters details at upload but never edits them |
| CAND-11 | NFR-OBS-002 | RS CLAIM | Use the app through browse, read and download | FX-USR-01 | The basic usage events arrive in the analytics debug view. PAC-09 checks only what events must not record |

## 3. What is still open

- **RC-01.** Which candidates become PAC rows: both developers, then MFW in writing.
- **RC-03.** The script that regenerated the matrix is not kept in the repository. Whether to keep one is still open.
- **RC-04.** Whether AC-1.1's pass condition should list the category (CAND-03).
