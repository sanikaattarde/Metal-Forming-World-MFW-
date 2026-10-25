# Changelog: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/CHANGELOG.md` |
| Phase | 3 — Development Planning and Collaboration (document 29) |
| Version | 0.6 |
| Status | Draft for review. Not approved. The conventions are PROPOSED (DEC-015). |
| Date | 25 October 2026 |

**Purpose.** A chronological record of changes to the repository. It keeps verified history (from Git and from each document's own change table) apart from work not yet merged to `main`, and from future releases. It invents no releases, tags or dates.

**Related documents**

| Document | Status on 23 October 2026 |
|---|---|
| `DECISION_LOG.md` DEC-015 | Exists (draft). Commit, changelog and version conventions (PROPOSED). |
| `DEVELOPMENT_WORKFLOW.md` §8, §11 | Exists (draft). How pull requests add changelog lines. |
| `APP_STORE_RELEASE_CHECKLIST.md` §8 | Exists (draft). When a version section is added. |

## Conventions

PROPOSED (DEC-015).

1. **Unreleased** lists changes merged, or prepared for merge, since the last release tag. Each pull request adds its own line (`DEVELOPMENT_WORKFLOW.md` §8).
2. **Version sections** (`## [1.0.0] - <date>`) are added only when a release tag `vMAJOR.MINOR.PATCH` is created on `main`. No version has been released.
3. **Repository history** records changes that Git shows, with their commit hashes. It never records changes that cannot be verified.
4. Entry types: **Added**, **Changed**, **Fixed**, **Removed**, **Security**, **Documentation**.
5. Dates use `YYYY-MM-DD`. A date is given only when Git or a document's own history shows it.
6. Each entry cites the files changed and, where relevant, requirement, decision or task IDs.

## Unreleased

### Documentation: cloud infrastructure and costs document added, 2026-10-25, on topic branch `docs/yg-remaining-docs` on top of `4769de3`, not reviewed

Follows the entry below. One new document, `CLOUD_INFRASTRUCTURE_AND_COSTS.md`, is the document that `TASK_OWNERSHIP_MATRIX.md` section 13.3 listed as planned and blocked by DEC-003. It is written while DEC-003 is still OPEN, as a comparison of two candidates (Firebase on Google Cloud, and an illustrative AWS-based design) and a parameterised cost model. It chooses no provider, and it does not lift the block on a single-provider cost model. Its amounts are planning arithmetic on stated inputs, not a quotation, a budget or a commitment, and MFW has seen none of them. Vendor prices were read from official pages in the built-in browser on 2026-10-25. Where a page did not give a figure, the figure is marked NOT VERIFIED. Five existing documents get tracking edits only, and no entry is AGREED, APPROVED or ANSWERED because of them. All five are interim-owned by Sanika Attarde (`TASK_OWNERSHIP_MATRIX.md` 8.2). Sanika Attarde has not reviewed any of it. Nothing here has gone to MFW.

| Date | Document | Change | Reason | Related IDs | Approval status | Affects scope |
|---|---|---|---|---|---|---|
| 2026-10-25 | `Documentation/CLOUD_INFRASTRUCTURE_AND_COSTS.md` | New, version 0.1. Workload inputs, infrastructure requirements, two candidate mappings, unit rates for sign-in, database, files, functions, logs and backups, four egress scenarios with formulas, sensitivity, open items and decision criteria | R14 had no cost model and the first scenarios covered egress only. The vendor figures in `TECHNOLOGY_DECISIONS.md` section 9 that were NOT VERIFIED are read where the pages allowed | DEC-003, DEC-031, DEC-023, OQ-41, OQ-53, R14, TD-03, TD-22 | Both developers (not agreed). MFW's written approval for any provider, region, cost ceiling or CDN | No scope effect by itself. Cloud usage is billed to MFW (S1). A provider that differs from S2 needs MFW's approval (CHG-04, CHG-05) |
| 2026-10-25 | `Documentation/TASK_OWNERSHIP_MATRIX.md` | Version 0.4: the document map (13.1) lists the new document; the 13.3 row says a draft comparison exists and that a single-provider cost model is still blocked; 8.2 records the proposed editor | Keep the map accurate | DEC-003 | Both developers (not agreed) | No scope effect: no assignment is agreed |
| 2026-10-25 | `Documentation/DEVELOPMENT_ROADMAP.md` | Version 0.4: three rows no longer say the document is not written, and T-00.7 covers its review | The rows went stale when the document was added | T-00.7 | Both developers (not agreed) | No scope effect: no date, estimate or milestone changed |
| 2026-10-25 | `Documentation/BACKUP_AND_RECOVERY.md`, `Documentation/DEPLOYMENT_PLAN.md` | Version 0.3 each: the related-documents row no longer says "Planned. Not written." | Same reason | OQ-46; DEC-023 | Both developers (not agreed) | No scope effect: no backup value, environment or configuration item changed |
| 2026-10-25 | `Documentation/RISK_REGISTER.md` | Version 0.3: the mitigation of R14 says a draft comparison and parameterised model exists | Same reason | R14 | Both developers (not agreed) | No scope effect: no rating, trigger or contingency changed |
| 2026-10-25 | `README.md` | Index row added for the new document, and the version column updated for the five documents above and for this changelog | Keep the index accurate | None | Both developers (not agreed) | No scope effect |
| 2026-10-25 | `Documentation/CHANGELOG.md` | Version 0.6: added this entry | The record of changes | None | None | No scope effect |

**New identifiers.** All are local to `CLOUD_INFRASTRUCTURE_AND_COSTS.md` and are not in any register: WI-01 to WI-13 (workload inputs), CV-01 to CV-15 (vendor pages read on 2026-10-25) and CL-01 to CL-07 (open items). They collide with no existing identifier. Registering the open items follows the same step as the identifiers of the entry of 2026-10-24.

**Vendor evidence.** Appendix A of the new document names each page, its region setting and the date read. A request to the AWS Price List host was refused by the browser pane and was not used. Appendix B lists ten observations for the owners of `TECHNOLOGY_DECISIONS.md` section 9, including five items there that were NOT VERIFIED: four are now read and one is read in part. Section 9 itself is not edited.

**Left as written.** The description of R14 in `RISK_REGISTER.md` still says "No estimate exists". Only the mitigation was edited. The new document holds planning arithmetic that no one at MFW has seen, so the statement is loose, not false. The related-documents tables of the edited documents keep their earlier "Status on" dates in the table header. `TASK_OWNERSHIP_MATRIX.md` section 13.4 says four documents carry no number. The new document carries none either, and that sentence was not changed. The stale "v0.2" citations of `SECURITY_AND_ACCESS_CONTROL.md` named in the entry below are still not updated.

**Not changed:** `Documentation/TECHNOLOGY_DECISIONS.md`, `Documentation/SYSTEM_ARCHITECTURE.md`, `Documentation/DECISION_LOG.md`, `Documentation/OPEN_QUESTIONS.md`, `Documentation/REQUIREMENTS_SPECIFICATION.md`, `Documentation/GLOSSARY.md`, every other document, and the SOW and proposal PDFs.

### Documentation: statements about pull request #3 corrected, 2026-10-25, on topic branch `docs/yg-remaining-docs` on top of `9c9dcdb`, not reviewed

Follows the entry below. Pull request #3 reached `main` by a direct push on 2026-10-25, with no review by a person (see Repository History). Six statements that called it open or not merged are corrected, and the push is recorded under Repository History. The 0.1 history rows of four documents are corrected in place without a version change, because a new version would leave the citations of version 0.1 added on 2026-10-25 one behind. The edits change no requirement, scope item, exclusion, date, fee, contract, control, test or criterion. Sanika Attarde has not reviewed any of it. Nothing here has gone to MFW.

| Date | Document | Change | Reason | Related IDs | Approval status | Affects scope |
|---|---|---|---|---|---|---|
| 2026-10-25 | `Documentation/CHANGELOG.md` | Version 0.5: the entry of 2026-10-24 and the heading of the entry of 2026-10-23 no longer call pull request #3 open or not merged. Repository History gains an entry for the push | The statements were true when written and became false when `main` moved | None | Both developers (not agreed) | No scope effect |
| 2026-10-25 | `Documentation/PDF_READER_AND_OFFLINE_DESIGN.md`, `Documentation/SECURITY_INCIDENT_PROCEDURE.md`, `Documentation/REQUIREMENT_COVERAGE_MATRIX.md`, `Documentation/SCREEN_INVENTORY_AND_NAVIGATION.md` | The version 0.1 change-history row no longer says pull request 3 is "not merged". Version and date unchanged | Same reason | None | Both developers (not agreed) | No scope effect |
| 2026-10-25 | `README.md` | Version column for the changelog: 0.5 | Keep the index accurate | None | Both developers (not agreed) | No scope effect |

**Left as written.** Five sentences still say the identifiers are to be registered "after pull request 3 is merged": the "New identifiers" paragraph of the entry of 2026-10-24 and the open-items section of each of the four documents above. The pull request has merged, so the registration is now due. It has not been done.

**Not changed:** every other document, the SOW and the proposal PDFs.

### Documentation: one stale row corrected and pointers to the four new documents added, 2026-10-25, on topic branch `docs/yg-remaining-docs` on top of `7ce9081`, not reviewed

Follows the entry below. The edits correct one row that still said the reader design was not written, and add related-document rows so the four new documents can be found from the documents a reader opens first. They change no requirement, scope item, exclusion, date, fee, contract, control, test or criterion, and no entry is AGREED, APPROVED or ANSWERED because of them. Four of the five edited documents are interim-owned by Sanika Attarde (`TASK_OWNERSHIP_MATRIX.md` 8.2). Sanika Attarde has not reviewed any of it. Nothing here has gone to MFW. The "Not changed" list of the entry below describes that entry only: three of the documents on it are edited here.

| Date | Document | Change | Reason | Related IDs | Approval status | Affects scope |
|---|---|---|---|---|---|---|
| 2026-10-25 | `Documentation/API_AND_MODULE_CONTRACTS.md` | Version 0.3: the related-documents row for `PDF_READER_AND_OFFLINE_DESIGN.md` now says the draft exists. It said "Planned. Not written." | The row went stale when the entry below added the document | T-00.7 | Both developers (not agreed) | No scope effect: no contract changed |
| 2026-10-25 | `Documentation/MAINTENANCE_AND_HANDOVER.md` | Version 0.3: related-documents row added for `SECURITY_INCIDENT_PROCEDURE.md` | A reader of the handover document is told where the steps for security events are. Section 10 stays the general flow | OQ-47; HO-13 | Both developers (not agreed) | No scope effect: no handover item, status or obligation changed |
| 2026-10-25 | `Documentation/SECURITY_AND_ACCESS_CONTROL.md` | Version 0.3: `SECURITY_INCIDENT_PROCEDURE.md` added to the related documents field | A reader of the security document is told where the incident steps are | OQ-47 | Both developers (not agreed) | No scope effect: no role, control, threat or test changed |
| 2026-10-25 | `Documentation/TESTING_STRATEGY.md` | Version 0.3: related-documents row added for `REQUIREMENT_COVERAGE_MATRIX.md` and `PDF_READER_AND_OFFLINE_DESIGN.md` | A reader of the test plans is told where requirement-level coverage is reported and which rules the reader design takes from sections 7.5 and 16 | RC-01 to RC-04 | Both developers (not agreed) | No scope effect: no test, gate or checklist item changed |
| 2026-10-25 | `Documentation/ACCEPTANCE_CRITERIA.md` | Version 0.3: related-documents row added for `REQUIREMENT_COVERAGE_MATRIX.md` and `PDF_READER_AND_OFFLINE_DESIGN.md` | A reader of the acceptance rows is told where coverage is reported. The row repeats that a new PAC row needs MFW's written approval | RC-01; AC-2; AC-4 | Both developers (not agreed). MFW in writing for any PAC row | No scope effect: no criterion changed |
| 2026-10-25 | `README.md` | Version column updated for the five documents above and for this changelog | Keep the index accurate | None | Both developers (not agreed) | No scope effect |
| 2026-10-25 | `Documentation/CHANGELOG.md` | Version 0.4: added this entry | The record of changes | None | None | No scope effect |

**Known effect of the version change.** `SYSTEM_ARCHITECTURE.md`, `TECHNOLOGY_DECISIONS.md`, `DATABASE_AND_DATA_MODEL.md` and `API_AND_BACKEND_CONTRACT.md` cite `SECURITY_AND_ACCESS_CONTROL.md` as v0.2 in their related-documents field. They now cite a version one behind. They were not edited here because they are outside the edits agreed for this task. Update the citations when each of them is next revised.

**Not changed:** `Documentation/REQUIREMENTS_SPECIFICATION.md`, `Documentation/GLOSSARY.md`, `Documentation/SCOPE_AND_EXCLUSIONS.md`, `Documentation/DECISION_LOG.md`, `Documentation/OPEN_QUESTIONS.md`, `Documentation/RISK_REGISTER.md`, the four documents named in the version paragraph above, `Documentation/DEVELOPMENT_ROADMAP.md`, `Documentation/TASK_OWNERSHIP_MATRIX.md`, the four documents added by the entry below, and the SOW and proposal PDFs.

### Documentation: four documents and a document index added, 2026-10-24, on topic branch `docs/yg-remaining-docs` on top of `5a436a3`, not reviewed

Prepared after the remediation below, which was submitted as pull request #3 and has since reached `main` by a direct push on 2026-10-25, with no review by a person (see Repository History). The new documents cite identifiers that came in with commit `5a436a3` (the operation catalogue, PRC-01 to PRC-04, DEC-025 to DEC-031, OQ-51 to OQ-57). If Sanika Attarde renumbers any of those entries, the references in these files are to be updated. The edits add documents for the two developers and track them. They change no requirement, scope item, exclusion, date, fee or CONFIRMED label, and no entry is AGREED, APPROVED or ANSWERED because of them. Nothing here has gone to MFW. Sanika Attarde has not reviewed any of it.

| Date | Document | Change | Reason | Related IDs | Approval status | Affects scope |
|---|---|---|---|---|---|---|
| 2026-10-24 | `Documentation/PDF_READER_AND_OFFLINE_DESIGN.md` | Added (version 0.1): lifecycle of a local copy as a state machine, start-up repair, revisions, storage and removal rules, edge cases and a verification map | Planned as T-00.7. The device-side rules were spread over several documents and the rules between them were open | FR-READ-001 to FR-READ-010; FR-DL-001 to FR-DL-010; DEC-005; DEC-008; DEC-020; OQ-08; OQ-11; OQ-36; OQ-37; OQ-54; RD-01 to RD-07 | Both developers (not agreed). MFW at M2 for the reader approach and library | No scope effect: PROPOSED rules, no requirement changed |
| 2026-10-24 | `Documentation/SECURITY_INCIDENT_PROCEDURE.md` | Added (version 0.1): common steps and six scenarios for security events, taken from the threat list; what the design cannot undo; what must exist first | Gap found in the inventory: only a general incident flow existed (`MAINTENANCE_AND_HANDOVER.md` section 10) | T1 to T26; SC-02, SC-05, SC-06, SC-08, SC-10, SC-12, SC-13, SC-15, SC-16, SC-18, SC-19, SC-21; OQ-28; OQ-47; SI-01 to SI-06 | Both developers (not agreed). MFW for contacts. MFW's legal adviser for anything legal | No scope effect: PLANNED, creates no obligation to MFW |
| 2026-10-24 | `Documentation/REQUIREMENT_COVERAGE_MATRIX.md` | Added (version 0.1): 166 requirements with the acceptance rows, test plans and design anchors that name them, and eight candidate checks | Gap found in the inventory: coverage was traced by area only | RS section 13; AC-1 to AC-12; PAC-01 to PAC-18; RC-01 to RC-04 | Both developers (not agreed). Derived, not a source of truth. A PAC row needs MFW's written approval | No scope effect: candidate checks carry no AC or PAC number |
| 2026-10-24 | `Documentation/SCREEN_INVENTORY_AND_NAVIGATION.md` | Added (version 0.1): app and admin panel screens implied by the requirements, access guard, states, open points and six gaps in the proposed route list | Input to the M2 designs. NFR-UX-002 requires MFW to approve the screens | SCR-A-01 to SCR-A-23; SCR-W-01 to SCR-W-12; SN-01 to SN-06; PAC-10 | Both developers (not agreed). MFW approves the screens at M2 | No scope effect: lists what the requirements imply |
| 2026-10-24 | `README.md` | Replaced the one-line title with a short statement of the repository's state, a reading order and an index of every document | The repository had no entry point or index | None | Sanika Attarde is the primary editor (`TASK_OWNERSHIP_MATRIX.md` 8.1); normal review | No scope effect |
| 2026-10-24 | `Documentation/TASK_OWNERSHIP_MATRIX.md` | Version 0.3: document map (13.1) lists the new documents and the README; 13.3 no longer lists the reader design as unwritten; 8.2 records the proposed editors | Keep the map current | None | Both developers (not agreed) | No scope effect |
| 2026-10-24 | `Documentation/DEVELOPMENT_ROADMAP.md` | Version 0.3: the new documents listed as drafts; T-00.7 now covers their review and keeps the cost document as the one still to write | Keep the task list current | T-00.7 | Both developers (not agreed) | No scope effect: no date, estimate or milestone changed |
| 2026-10-24 | `Documentation/CHANGELOG.md` | Version 0.3: added this entry | The record of changes | None | None | No scope effect |

**New identifiers.** These are local to each file and are not yet in the registers. After pull request #3 merges they are to be registered in `OPEN_QUESTIONS.md`: RD-01 to RD-07 (reader design), SI-01 to SI-06 (incident procedure), RC-01 to RC-04 (coverage matrix) and SN-01 to SN-06 (screen inventory). Also new: SCR-A-01 to SCR-A-23, SCR-W-01 to SCR-W-12 (screens), and I-1 to I-6 (invariants in the reader design).

**Not changed:** `Documentation/REQUIREMENTS_SPECIFICATION.md`, `Documentation/GLOSSARY.md`, `Documentation/SCOPE_AND_EXCLUSIONS.md`, `Documentation/DECISION_LOG.md`, `Documentation/OPEN_QUESTIONS.md`, `Documentation/RISK_REGISTER.md`, `Documentation/MAINTENANCE_AND_HANDOVER.md`, `Documentation/ACCEPTANCE_CRITERIA.md`, `Documentation/TESTING_STRATEGY.md`, and the SOW and proposal PDFs.

### Documentation: remediation of the merged documentation set, 2026-10-23, on topic branch `docs/yg-reconcile-merged-set` on top of `6e85734`, submitted for review by pull request #3, which reached `main` by a direct push on 2026-10-25 (see Repository History), not reviewed by a person

Prepared after pull request #1 and pull request #2 were merged. The edits apply the reconciliation of the two document sets, correct stale statements and record what the developers report as evidence. They change no requirement, scope item, exclusion, date, fee or CONFIRMED label. Statuses follow the repository's rules (`DECISION_LOG.md` section 3.1). What YG reports (the S3 emails, the other developer's agreement, MFW's answer to OQ-08) is recorded as a note. No entry is AGREED, APPROVED or ANSWERED because of it. Each document that changed has a new minor version and a row in its change history. Sanika Attarde has not reviewed any of these edits.

| Date | Document | Change | Reason | Related IDs | Approval status | Affects scope |
|---|---|---|---|---|---|---|
| 2026-10-23 | `Documentation/ACCEPTANCE_CRITERIA.md` | Reworded rule 1; added AC-9.7 (breaking news), PAC-16 (conditional on PRC-02), PAC-17 (account-existence messages) and PAC-18 (conditional on PRC-01); updated the coverage table; removed the Prepared-in row | Review findings F-11, F-12, F-10; deletion baseline and PRC-02 | AC-9.7; PAC-16 to PAC-18; PRC-01; PRC-02 | Both developers (reported by YG, not filed). PAC rows need MFW's written approval to become contractual | No scope effect: proposed checks add no contractual condition |
| 2026-10-23 | `Documentation/API_AND_BACKEND_CONTRACT.md` | Single catalogue: added the 31 aliases (3.1), baseline and PRC-01 privileges (3.2), baseline and PRC-02 deletion (3.3), open design differences (3.4); error scheme changed to category plus reason; OP-12 and OP-13 marked baseline or PRC-02; registration and sign-in message rule; "team-accepted" replaced by PROPOSED plus note; website check updated | Reconciliation of the two document sets; review findings X-02, X-04, F-04, F-06, F-10, F-01 | OP-01 to OP-42; OP-AREA-nn aliases; DEC-026; DEC-027; DEC-029; PRC-01; PRC-02; OQ-57 | Both developers (reported by YG, not filed). MFW for PRC-01 and PRC-02 | No scope effect: the baseline is the confirmed text; PRC-01 and PRC-02 stay labelled proposals |
| 2026-10-23 | `Documentation/API_AND_MODULE_CONTRACTS.md` | Section 8: added the main-identifier column and notes (OP-ADM-11 split waits for OQ-21; OP-ADM-12; OP-ACC-01); section 4.2: category and reason column, GONE and RATE_LIMITED added; registration and sign-in messages; removed-admin and first-admin statements (4.4); compatibility and paging requirements (4.5); guest-reading rule labelled; planned names replaced; removed the Prepared-in row | Reconciliation of the two document sets; review findings X-02, F-04, F-05, F-06, F-10, F-13, F-14, F-15, F-07, X-01 | OP-AREA-nn aliases; DEC-026; OQ-21; OQ-57; PRC-01; PRC-02 | Both developers (reported by YG, not filed) | No scope effect: aliases, labels and PROPOSED requirements only |
| 2026-10-23 | `Documentation/APP_STORE_RELEASE_CHECKLIST.md` | Corrected stale status wording; removed the Prepared-in row | Review findings F-20, F-09 | None | None | No scope effect |
| 2026-10-23 | `Documentation/ASSUMPTIONS_AND_CONSTRAINTS.md` | Added a note to REG-001 (YG states the S3 emails exist; not in the repository; status unchanged) | Interview answers on the S3 evidence | REG-001; OQ-29 | YG (attestation). REG-001 stays OPEN | No scope effect |
| 2026-10-23 | `Documentation/BACKUP_AND_RECOVERY.md` | Marked backup set-up as a proposed addition (not an S2 deliverable); added section 13 (status of the proposals and who does what); corrected related-document rows; removed the Prepared-in row | Review finding F-02; brief section 3.9 | OQ-46; OQ-47; HO-14 | MFW for the additions (OQ-46) | No change order: no effort figure; RPO and RTO remain proposals |
| 2026-10-23 | `Documentation/CHANGELOG.md` | Added this remediation entry and the repository-history entries for the two merged pull requests; corrected the stale heading and related-document rows; removed the Prepared-in row | Review finding F-20, F-09; the record of changes required by the remediation | None | None | No scope effect |
| 2026-10-23 | `Documentation/CI_CD_AND_QUALITY_GATES.md` | QG-12 now states that the documentation-check script is not in the repository; replaced the planned technology-decisions name with the existing document; corrected related-document rows; removed the Prepared-in row | Review findings F-18, X-01, F-20, F-09 | QG-12 | None | No scope effect |
| 2026-10-23 | `Documentation/CLAUDE_CODE_WORKING_RULES.md` | Labelled the no-guest-reading rule as a working position (PROVISIONAL); limited the file-access rule to the app's copy with a pointer to OQ-57; aligned decision wording with the status model; removed the Prepared-in row | Review findings F-07, F-08, F-01, F-09 | DEC-007; DEC-009; OQ-57 | None for labels | No scope effect: behaviour of the rules unchanged |
| 2026-10-23 | `Documentation/CODING_STANDARDS.md` | Replaced the planned technology-decisions name with the existing document; labelled the access rules; marked the personal-data term for crash and usage events NOT VERIFIED; removed the Prepared-in row | Review findings X-01, F-07, F-24, F-09 | DEC-007; DEC-009; DEC-028; OQ-23 | None for labels | No scope effect |
| 2026-10-23 | `Documentation/DATABASE_AND_DATA_MODEL.md` | Profile default required set aligned with the requirements specification (gender added; mobile number, company and country optional); deletion states marked PRC-02; admin role, guard and audit marked PRC-01; "team-accepted" replaced by PROPOSED plus note; website references extended to OQ-57 | Reconciliation of the two document sets; review findings X-03, X-04, X-02, F-01 | GS-Q34; PRC-01; PRC-02; PRC-03 (superseded); OQ-01; OQ-57; MA-5; MA-8 | Both developers (reported by YG, not filed). MFW confirms the field list (OQ-01) | No scope effect: the baseline is the confirmed text |
| 2026-10-23 | `Documentation/DECISION_LOG.md` | Added DEC-025 to DEC-031, TD crosswalk (5.2), status rules 6 and 7, working-position notes on DEC-008, DEC-009, DEC-016, DEC-017, DEC-019; reworded 13 approver lines; corrected names and stale rows; removed the Prepared-in row | Reconciliation of the two document sets; evidence rules for reported statements; review findings F-23, F-01, F-20, F-09 | DEC-025 to DEC-031; DEC-008; DEC-009; DEC-016; DEC-017; DEC-019 | Both developers (reported by YG, not filed). MFW for PRC-01, PRC-02 and region | No scope effect: no requirement, exclusion, date or fee changed |
| 2026-10-23 | `Documentation/DEFINITION_OF_DONE.md` | Labelled the access rules (DEC-007 working position, DEC-009 baseline); aligned decision wording with the status model (not OPEN or PROPOSED); HO-13 and HO-14 gate handover only if MFW agrees; removed the Prepared-in row | Review findings F-07, F-08, F-02, F-09 | DEC-007; DEC-009; HO-13; HO-14 | None for labels. MFW for HO-13 and HO-14 | No scope effect |
| 2026-10-23 | `Documentation/DEPENDENCY_REGISTER.md` | Replaced the planned technology-decisions name with the existing document; corrected stale status rows; removed the Prepared-in row | Review findings X-01, F-20, F-09 | None | None | No scope effect |
| 2026-10-23 | `Documentation/DEPLOYMENT_PLAN.md` | Marked backup steps as proposed additions; named the first-admin step; replaced planned names with the existing documents; removed the Prepared-in row | Review findings F-02, F-04, X-01, F-09 | OQ-20; OQ-46 | MFW for backup (OQ-46); both developers for the first-admin step | No scope effect |
| 2026-10-23 | `Documentation/DEVELOPMENT_ROADMAP.md` | Corrected document names and stale status rows; stated the working baseline for dates with the S3 note; added tasks T-00.6 and T-00.7; removed the Prepared-in row | Document map (X-01), stale statements (F-20), order of authority and S3 evidence (Q1, Q2) | T-00.3; T-00.6; T-00.7; DEC-017; C-08 | Both developers (reported by YG, not filed). Dates stay PROVISIONAL | No scope effect: no date, estimate or milestone changed |
| 2026-10-23 | `Documentation/DEVELOPMENT_WORKFLOW.md` | Updated the repository state (section 3) and the immediate actions (section 16) to the state after the two merges; replaced the co-author trailer requirement with the proposed no-attribution rule; removed the Prepared-in row | Review findings F-20, F-09 | DEC-010 | Both developers (the rule is PROPOSED; agreement reported by YG, not filed) | No scope effect |
| 2026-10-23 | `Documentation/MAINTENANCE_AND_HANDOVER.md` | Marked HO-13 and HO-14 as proposed additions and qualified the "creates no new obligation" sentence; replaced planned names with the existing documents; added a note on the S1 maintenance figures; removed the Prepared-in row | Review findings F-02, F-17, X-01, F-09 | HO-13; HO-14; OQ-32; OQ-46; OQ-47 | MFW for HO-13 and HO-14 (OQ-46, OQ-47) | No change order: no effort figure, no new commitment |
| 2026-10-23 | `Documentation/OPEN_QUESTIONS.md` | Added OQ-51 to OQ-57 and the AOQ crosswalk (section 7); restored OQ-20 and OQ-25 wording; notes on OQ-08, OQ-29, OQ-32, OQ-46, OQ-47; counts updated to 57; removed the Prepared-in row | Reconciliation of the register families; review findings F-01, F-22, F-17, F-02, F-09, F-20 | OQ-08; OQ-20; OQ-25; OQ-29; OQ-32; OQ-46; OQ-47; OQ-51 to OQ-57 | Both developers (reported by YG, not filed). MFW answers each question | No scope effect: no question is answered or closed |
| 2026-10-23 | `Documentation/PROJECT_CHARTER.md` | Added a note on S3 after the amendments table in section 17.3 (YG states the emails exist; not in the repository; status unchanged) | Interview answers on the S3 evidence (the repository's status rules apply) | CH 17.3; OQ-29; REG-001 | YG (attestation). The amendments stay PROVISIONAL | No scope effect: no requirement, date or fee changed |
| 2026-10-23 | `Documentation/RISK_REGISTER.md` | Added R23 (vendor facts) and R24 (verbal latitude), the AR-to-R crosswalk (section 7), a scope note on R4, corrections on R6, R7, R12, R14, R19, R20, R22; removed the Prepared-in row | Reconciliation of the register families; review findings F-01, F-02, F-20, F-09; interview context X1 | R4; R6; R7; R12; R19; R20; R22; R23; R24 | Both developers (reported by YG, not filed). MFW for any risk it must accept | No scope effect: no requirement, exclusion, date or fee changed |
| 2026-10-23 | `Documentation/SECURITY_AND_ACCESS_CONTROL.md` | Separated the baseline from PRC-01 and PRC-02 (6.1a classification, section 7 intro, headers and labels); added T26, SC-21, ST-21; added what the gate and a signed link cannot protect (3.2); updated the website check; aligned the profile fields with the requirements specification; "team-accepted" replaced by PROPOSED plus note; error names upper-case | Reconciliation of the two document sets; review findings X-02, X-03, X-04, F-01, F-10 | PRC-01; PRC-02; SC-21; ST-21; T26; OQ-57; DEC-027; DEC-029 | Both developers (reported by YG, not filed). MFW for PRC-01 and PRC-02 | No scope effect: the baseline is the confirmed text; PRC-01 and PRC-02 stay labelled proposals |
| 2026-10-23 | `Documentation/SYSTEM_ARCHITECTURE.md` | Added section 1.3 (baseline and the labelled changes PRC-01 and PRC-02); deletion flow and function list marked baseline or PRC-02; registration and sign-in messages (7.1); error categories aligned with the API and Backend Contract; "accepted by the development team" replaced by PROPOSED plus note; website references extended to OQ-57; pointers to the AR crosswalk and to the tested table | Reconciliation of the two document sets; review findings X-02, X-04, F-10, F-01 | PRC-01; PRC-02; GS-Q34; OQ-57; DEC-027; DEC-029 | Both developers (reported by YG, not filed). MFW for PRC-01 and PRC-02 | No scope effect: labels and cross-references only |
| 2026-10-23 | `Documentation/TASK_OWNERSHIP_MATRIX.md` | Added the document map (section 13): canonical homes, retired names as aliases, unwritten documents, note on the document numbers; updated Phase 2 ownership row; corrected stale statements; removed the Prepared-in row | Two document sets with different names (review finding X-01, F-21, F-20, F-09) | G2-01; DEC-011 | Both developers (reported by YG, not filed) | No scope effect: names and cross-references only |
| 2026-10-23 | `Documentation/TECHNOLOGY_DECISIONS.md` | TD-15 and TD-19 changed from "accepted by the development team" to proposed, each with a baseline and a labelled change; GS-Q34 added and PRC-03 superseded; not-verified item 24 added; the claim that MFW accepted the App Store risk qualified; AOQ aliases to OQ-51 to OQ-57; "team-accepted" replaced by PROPOSED plus note | Reconciliation of the two document sets; review findings X-04, X-03, F-10, F-01; brief section 3.8 | TD-06; TD-15; TD-19; GS-Q30; GS-Q34; PRC-03; AOQ-05; AOQ-10 to AOQ-14; AOQ-18; OQ-06; OQ-51 to OQ-57 | Both developers (reported by YG, not filed). MFW for PRC-01, PRC-02 and the region | No scope effect: labels and cross-references only |
| 2026-10-23 | `Documentation/TESTING_STRATEGY.md` | Added SEC-CHK-17 to SEC-CHK-19 and section 16 (intended versus tested for protected files and offline copies); SEC-CHK-03 limited to the app's storage; corrected the registration wording; added test lines for breaking news, a removed admin and a failed replacement; personal-data term marked NOT VERIFIED; removed the Prepared-in row | Review findings F-04, F-05, F-06, F-10, F-12, F-24, F-01, F-09; brief section 3.6 | SEC-CHK-03; SEC-CHK-17 to SEC-CHK-19; OQ-08; OQ-57; AC-9.7; FX-ADM-08; FX-ADM-09; FX-USR-13 | Both developers (reported by YG, not filed) | No scope effect: proposed checks only; no test has been run |
| 2026-10-23 | `Documentation/TEST_DATA_AND_FIXTURES.md` | Added FX-USR-13, FX-ADM-08 and FX-ADM-09; replaced the planned data-model name with the existing document; removed the Prepared-in row | Review findings F-10, F-04, F-05, X-01, F-09 | FX-USR-13; FX-ADM-08; FX-ADM-09 | Both developers (reported by YG, not filed) | No scope effect: no fixture file is created |

**New identifiers.** The numbers are the next free ones at the time of the edit, and the primary editor of each register may renumber a new entry before it merges: DEC-025 to DEC-031; OQ-51 to OQ-57; R23 and R24; SEC-CHK-17 to SEC-CHK-19; AC-9.7; PAC-16 to PAC-18; FX-USR-13; FX-ADM-08 and FX-ADM-09; T26; SC-21; ST-21; GS-Q34; T-00.6 and T-00.7; the document map in section 13 of `TASK_OWNERSHIP_MATRIX.md`.

**Version citations.** The version numbers cited in the related-documents rows of `API_AND_BACKEND_CONTRACT.md`, `DATABASE_AND_DATA_MODEL.md`, `SYSTEM_ARCHITECTURE.md`, `SECURITY_AND_ACCESS_CONTROL.md`, `TECHNOLOGY_DECISIONS.md` and `ASSUMPTIONS_AND_CONSTRAINTS.md` were updated to the new versions.

**Not changed:** `README.md`, `Documentation/REQUIREMENTS_SPECIFICATION.md`, `Documentation/GLOSSARY.md`, `Documentation/SCOPE_AND_EXCLUSIONS.md` (checked, no edit needed), `Documentation/MFW_Statement_of_Work.pdf`, `Documentation/MFW_Commercial_Proposal-2.pdf`.

### Documentation: committed on `SA` on 2026-10-23 and merged to `main` by pull request #1 (merge commit `56c6d97`). No review is recorded on the pull request

These were drafted in Sanika Attarde's Claude Code session on branch `SA`, on top of commit `8941964`, and committed to `SA` in a single commit. When that commit was made, it had not been pushed or merged to `main`. It was pushed as `0b54088` and merged to `main` by pull request #1 on 2026-10-23. Every document is a draft v0.1 awaiting review by both developers.

**Added: Phase 3, development planning and collaboration**

- `Documentation/DEVELOPMENT_WORKFLOW.md`: branch roles, pull requests, integration, shared files, recovery (DEC-010)
- `Documentation/TASK_OWNERSHIP_MATRIX.md`: proposed workstreams and module, document and acceptance ownership (DEC-011)
- `Documentation/DEVELOPMENT_ROADMAP.md`: work packages WP-00 to WP-12 in relative weeks, internal estimates, blocked tasks
- `Documentation/API_AND_MODULE_CONTRACTS.md`: modules MOD-00 to MOD-13, technology-neutral operations, integration contracts IC-01 to IC-08
- `Documentation/CODING_STANDARDS.md`: Flutter and Dart standards; technology-neutral backend and admin principles
- `Documentation/CLAUDE_CODE_WORKING_RULES.md`: rules for both Claude Code sessions
- `Documentation/DEFINITION_OF_DONE.md`: DoD-DOC to DoD-HO, with gate-availability labels
- `Documentation/DECISION_LOG.md`: decision record with DEC-001 to DEC-024. None is AGREED or APPROVED.
- `Documentation/CHANGELOG.md`: this file

**Added: Phase 4, testing, release and risk management**

- `Documentation/TESTING_STRATEGY.md`: test suites TS-01 to TS-13 and the proposed security checklist SEC-CHK-01 to SEC-CHK-16
- `Documentation/ACCEPTANCE_CRITERIA.md`: verification checks for S2 AC-1 to AC-12, PAC-01 to PAC-11 from RS, and new proposals PAC-12 to PAC-15
- `Documentation/TEST_DATA_AND_FIXTURES.md`: synthetic fixture definitions (FX-*). No fixture files created.
- `Documentation/CI_CD_AND_QUALITY_GATES.md`: proposed gates QG-01 to QG-13. No workflow files created.
- `Documentation/DEPLOYMENT_PLAN.md`: environments, configuration items, smoke tests, release order, rollback
- `Documentation/APP_STORE_RELEASE_CHECKLIST.md`: Android and iOS checklists. Nothing submitted.
- `Documentation/BACKUP_AND_RECOVERY.md`: proposed backup approach. All values need MFW's approval.
- `Documentation/MAINTENANCE_AND_HANDOVER.md`: handover checklist HO-01 to HO-16; warranty and maintenance terms quoted from S1 and S2
- `Documentation/RISK_REGISTER.md`: CH R1 to R11 carried over; R12 to R22 added
- `Documentation/DEPENDENCY_REGISTER.md`: client inputs, accounts, candidates and tools (DEP-*)
- `Documentation/OPEN_QUESTIONS.md`: consolidated register; RS OQ-01 to OQ-31 kept; OQ-32 to OQ-50 added

**Not changed:** `README.md`, `Documentation/PROJECT_CHARTER.md`, `Documentation/REQUIREMENTS_SPECIFICATION.md`, `Documentation/MFW_Statement_of_Work.pdf`, `Documentation/MFW_Commercial_Proposal-2.pdf`.

## Repository History

From Git on 2026-10-23. The entry dated 2026-10-25 was added from Git and GitHub on that date.

### 2026-10-25 - `9c9dcdb` "docs: link the four new documents and correct the stale reader-design row"

Author: YuvrajGaykhe, for the three commits below. On `main`. `main` moved from `6e85734` to `9c9dcdb` by one direct fast-forward push of the branch `docs/yg-remaining-docs`, made from the YuvrajGaykhe account. No pull request was opened for the last two commits.

- `5a436a3` "docs: reconcile the merged documentation set", authored 2026-10-23. It is the commit of pull request #3. GitHub marked the pull request merged at 2026-10-25T07:19:55Z, with `5a436a3` as the merge commit, merged by the YuvrajGaykhe account.
- `7ce9081` "docs: add reader design, incident procedure, coverage matrix and screen inventory", authored 2026-10-24.
- `9c9dcdb` "docs: link the four new documents and correct the stale reader-design row", authored 2026-10-25.

Pull request #3 shows one automated review comment (Copilot) and no review by a person. Sanika Attarde has not reviewed any of the three commits. Nothing was sent to MFW.

### 2026-10-23 - `6e85734` "Merge pull request #2 from sanikaattarde/YG"

Author: Yuvraj Gaykhe. On `main`. The merge commit of pull request #2, with parents `56c6d97` and `cb85f0b`. The pull request shows one automated comment saying that a review could not be done. No person's review is recorded.

### 2026-10-23 - `cb85f0b` "Add eight documentation drafts to the YG branch"

Author: YuvrajGaykhe. On `YG`, merged by pull request #2. Parent `8941964`.

- **Added** eight documents in `Documentation/`: `SCOPE_AND_EXCLUSIONS.md`, `ASSUMPTIONS_AND_CONSTRAINTS.md`, `GLOSSARY.md`, `SYSTEM_ARCHITECTURE.md`, `TECHNOLOGY_DECISIONS.md`, `DATABASE_AND_DATA_MODEL.md`, `API_AND_BACKEND_CONTRACT.md`, `SECURITY_AND_ACCESS_CONTROL.md`

### 2026-10-23 - `56c6d97` "Merge pull request #1 from sanikaattarde/SA"

Author: Yuvraj Gaykhe. On `main`. The merge commit of pull request #1, with parents `8941964` and `0b54088`. The pull request shows no review.

### 2026-10-23 - `0b54088` "docs: add Phase 3 and Phase 4 project documents"

Author: Sanika Attarde. On `SA`, merged by pull request #1. Parent `8941964`.

- **Added** twenty documents in `Documentation/`, listed in the Phase 3 and Phase 4 entry under Unreleased

### 2026-10-23 — `8941964` "Add project documentation"

Author: YuvrajGaykhe. On `main` (`origin/main`). A single-parent commit; no pull request is visible in local metadata.

- **Added** `Documentation/PROJECT_CHARTER.md`: v0.1, "Draft for review", dated 22 October 2026 in its own history
- **Added** `Documentation/REQUIREMENTS_SPECIFICATION.md`: v0.1, "Draft for Review", dated 22 October 2026 in its own history
- **Added** `Documentation/MFW_Statement_of_Work.pdf`: dated 17 October 2026, unsigned copy
- **Added** `Documentation/MFW_Commercial_Proposal-2.pdf`: dated 17 October 2026, unsigned copy

### 2026-10-20 — `3e642e0` "Initial commit"

Author: sanikaattarde, committed through GitHub.

- **Added** `README.md` (title only)

## Releases

None. No release tags exist (verified 2026-10-23).
