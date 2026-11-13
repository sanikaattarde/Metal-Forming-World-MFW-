# Review of Five Drafts: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/DRAFTS_REVIEW_YUVRAJ.md` |
| Task | MOD20-P1-T03, review of the reader, incident, coverage, screen and cloud drafts |
| Version | 0.1 |
| Status | Draft for review. **A self-check by the author, not a second-person review.** Yuvraj Gaykhe wrote all five drafts, so this record cannot meet the task's objective of a second-person review. Sanika Attarde made a first pass over four of the five on 6 and 7 November 2026 (issue 31, still open): the screen inventory, the coverage matrix, the cost document and the incident procedure. Its findings are in the 0.4 versions of those documents. **The reader design is the one document that first pass did not cover.** This record lists what a mechanical check and a reading found since, and edits none of the five documents. It approves nothing |
| Date | 14 November 2026 |
| Reviewed | `PDF_READER_AND_OFFLINE_DESIGN.md`, `SECURITY_INCIDENT_PROCEDURE.md`, `REQUIREMENT_COVERAGE_MATRIX.md`, `SCREEN_INVENTORY_AND_NAVIGATION.md` and `CLOUD_INFRASTRUCTURE_AND_COSTS.md`, as on `main` at commit e3c9c9d |
| Acceptance of the task | "Review recorded for each document." Section 2 records a self-check for each. The task is not complete until Sanika Attarde has reviewed the reader design and closed issue 31 |

## 1. What was checked

A script read the five documents and printed findings only. It is not kept in the repository.

| Check | Result |
|---|---|
| Identifiers | Every DEC, OQ, TD, FR, NFR, SEC-CHK, OP, SCR and AC or PAC identifier named in the five documents exists in the register that owns it |
| Files | Every document named in backticks exists |
| Decision statuses in running text | DEC-020 is read as OPEN in the reader design, and DEC-003 as OPEN in the cloud document and as undecided in the incident procedure. `DECISION_LOG.md` says both are AGREED (items RD-A1, SI-A1, CL-A1) |
| Figures | The 24 figures of sections 10.1 and 17.2 of the cloud document, the two per-download figures and the CloudFront break-even were recomputed from the stated formula and prices. All agree |
| Built behaviour | Checked against the routes and the download manager on `main` where a document states a rule that the app now follows |

## 2. Findings by document

### 2.1 `PDF_READER_AND_OFFLINE_DESIGN.md`

| Ref | Finding | Proposed change |
|---|---|---|
| RD-A1 | The status block (line 10) says nothing is built in the app. Section 2 (line 63) says the delivery mechanism, DEC-020, is OPEN. DEC-020 is AGREED (`DECISION_LOG.md` section 5.12) and the download manager and the reader are on `main` | Update both statements |
| RD-A2 | The state diagram and section 6.2 have no rule for a reader who leaves while Read is still downloading, and none for Download tapped while a temporary copy is open. Yuvraj Gaykhe decided both on 14 November 2026 (`YUVRAJ_DECISION_POSITIONS.md`, DEC-033): the download is cancelled and the partial file removed, and the open copy is converted with no second download | Add the two rules to sections 4.2 and 6.2 once Sanika Attarde agrees with DEC-033 |
| RD-A3 | RD-01 proposes that cancel deletes the partial file. `IssueDownloadManager.cancel` does this and cites RD-01 | Mark RD-01 as built, pending agreement |

### 2.2 `SECURITY_INCIDENT_PROCEDURE.md`

| Ref | Finding | Proposed change |
|---|---|---|
| SI-A1 | Line 56 says no cloud platform is decided (DEC-003). DEC-003 is AGREED: Firebase (`DECISION_LOG.md` section 5.11) | Say the platform is Firebase and keep "NOT VERIFIED unless a source says otherwise" for platform behaviour |
| SI-A2 | Line 59 says nothing can be rehearsed because no backend, accounts or admin panel exist. The rules and functions run on the emulators with a closed list of security events, and an admin panel spike exists (`test-evidence/ADMIN_PANEL_SPIKE_EVIDENCE.md`) | Reword: a rehearsal on ENV-LOCAL is possible, and one on ENV-TEST waits for that project (OQ-40) |
| SI-A3 | Section 9 says the throwaway project for ST-09 is blocked by DEC-003 | It waits for the cloud project and its approval (OQ-40), not for DEC-003 |

### 2.3 `REQUIREMENT_COVERAGE_MATRIX.md`

| Ref | Finding | Proposed change |
|---|---|---|
| MX-A1 | The first pass raised M-1 and M-2, and version 0.4 of 7 November 2026 answers them. The matrix was regenerated on 14 November 2026 for MOD17-P1-T03 (branch `docs/yg-mod17-coverage`, not yet on `main`). The column of rows now matches the Source cells of `ACCEPTANCE_CRITERIA.md` for all 166 requirements, the counts are recounted, and OP-13 is gone | None. This part is not independent of that task, because the same person made both |
| MX-A2 | RC-01 to RC-04 stay open. `COVERAGE_GAP_PROPOSALS.md` proposes eleven candidate checks | Both developers decide, then MFW for any new PAC row |

### 2.4 `SCREEN_INVENTORY_AND_NAVIGATION.md`

| Ref | Finding | Proposed change |
|---|---|---|
| SN-A1 | The route column says "none" for SCR-A-04, SCR-A-06, SCR-A-08 and SCR-A-11. The app has `/reset-password`, `/profile`, `/settings/delete-account` and `/catalogue` (`app/lib/app/routes.dart`) | Fill the four routes in |
| SN-A2 | SN-01 (routes missing for reset, profile, deletion confirmation) and SN-03 (home and catalogue as one screen or two) are answered by the app as built: the routes exist, and home and catalogue are two screens. The designer and MFW at M2 still decide | Record the answers as "as built, for M2" |

### 2.5 `CLOUD_INFRASTRUCTURE_AND_COSTS.md`

| Ref | Finding | Proposed change |
|---|---|---|
| CL-A1 | The status line, section 2.1, section 22 and section 23 give DEC-003 as OPEN and say no provider is chosen. DEC-003 is AGREED: Firebase, as S2 proposes. MFW still approves the M1 note (OQ-35). Candidate F is now the working platform, and candidate W stays as a comparison | Update the four places. The history row of 25 October 2026 is a dated record and stays |
| CL-A2 | WI-11 gives ENV-TEST as PROPOSED, citing TD-18. DEC-023 is AGREED as an internal position (`DECISION_LOG.md` section 5.11). TD-18 is still unreconciled (VR-03) | Cite DEC-023 and say TD-18 is reconciled when it is next edited |
| CL-A3 | The vendor prices were read on 25 October 2026 (Appendix A). CL-05 says to read them again before MFW sees them. They were not read again for this record | Re-read the prices before the figures go to MFW |
| CL-A4 | The storage rate behind the "to" ranges of section 17.2 was not recomputed, because it needs the vendor's rate | Check it with CL-A3 |

## 3. Across the five documents

| Ref | Finding | Proposed change |
|---|---|---|
| X-1 | The matrix (RC), the reader design (RD), the screen inventory (SN) and the incident procedure (SI) each keep a list of open items that is "not yet in the registers". Each says so because pull request 3 reached `main` by a direct push on 25 October 2026. The items are still local | Register them in `OPEN_QUESTIONS.md` with an owner, or say in each document that its list stays local |

## 4. What is not checked

- Whether each reader rule is the right one. The checks cover consistency and staleness only.
- The reader design's section 10 map from rules to tests, against the tests now on `main`.
- The incident contacts and the legal questions, which wait for MFW (OQ-47, OQ-28).
- The cost scenarios against OQ-53, which MFW has not answered.

## 5. What is needed next

Sanika Attarde's review of the reader design, the close of issue 31 for the other four, and a decision on X-1. Then the edits above are made one document at a time, each with a CHANGELOG entry.
