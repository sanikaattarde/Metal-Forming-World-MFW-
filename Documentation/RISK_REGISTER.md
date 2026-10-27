# Risk Register: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Risk Register |
| File | `Documentation/RISK_REGISTER.md` |
| Phase | 4 — Testing, Release and Risk Management (document 38) |
| Version | 0.4 |
| Status | Draft for review. Not approved. Ratings are an initial development-team assessment and are unreviewed. |
| Date | 27 October 2026 |
| Approval required | Both developers. Risks that MFW must accept need MFW's written acceptance. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial register. CH R1 to R11 carried with their IDs. R12 to R22 added. |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. R23 and R24 added, with the AR crosswalk (section 7). Scope note on R4 (the app's copy only). Stale evidence on R6, R7 and R12 corrected. Backup items on R19 marked as proposed additions. All ratings remain unreviewed. |
| 0.3 | 25 October 2026 | Tracking edit, see `CHANGELOG.md`. The mitigation of R14 now says that a draft comparison of candidates and a parameterised cost model exists in `CLOUD_INFRASTRUCTURE_AND_COSTS.md`. No rating, trigger or contingency changed, and all ratings remain unreviewed. |
| 0.4 | 27 October 2026 | Positions from the questioning session of 26 and 27 October 2026 applied (Technology Decisions section 10.5). R7 and R15 carry the late-input evidence and the decision to send no delay notice. R21 records that both developers are reported as full time. R24 names the other verbal approvals. R25 added: required test devices are missing. The AR crosswalk wording follows the architecture. All ratings remain unreviewed, and no status changed. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `PROJECT_CHARTER.md` (CH) §18 | Exists, draft. Source of R1 to R11. |
| `REQUIREMENTS_SPECIFICATION.md` (RS) §12.4 | Exists, draft. Maps CH risks to requirements. |
| `MFW_Statement_of_Work.pdf` (S2) "Assumptions and key risks" | Exists, issued, unsigned |
| `OPEN_QUESTIONS.md`, `DECISION_LOG.md`, `DEVELOPMENT_ROADMAP.md` | Exist (draft) |

## 2. Purpose, Scope and Status

This is the single register of project and product risks. It keeps the charter's risks R1 to R11 under their original IDs and descriptions, updates each with current evidence, and adds new risks from R12 onwards.

**Relationship to CH §18.** CH §18 stays as the original record. This register becomes the working copy once both developers agree. At its next revision, CH §18 could point here. That is a Phase 1 change and is not made in this task.

No risk incident has occurred or been recorded. No mitigation is complete.

## 3. Scoring

| Scale | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Probability (P) | Rare | Unlikely | Possible | Likely | Almost certain |
| Impact (I) | Negligible | Minor: small rework | Moderate: a feature or date slips within the milestone | Major: a milestone slips, or a feature or contract term is at risk | Severe: data exposure, legal exposure, or failure to deliver |

**Score = P × I. Bands:** Low 1–6, Medium 8–12, High 15–25.

**Status values**

| Status | Meaning |
|---|---|
| OPEN | Identified. Mitigation not started or not evidenced. |
| MITIGATING | Mitigation actions in progress, with evidence linked |
| ACCEPTED | Formally accepted by the party responsible, with written evidence |
| CLOSED | No longer applicable, with the reason |

Owners follow the PROPOSED workstreams in `TASK_OWNERSHIP_MATRIX.md`: WS-A (proposed Sanika Attarde) and WS-B (proposed Yuvraj).

## 4. Summary

| ID | Risk | Category | P | I | Score | Band | Owner | Status |
|---|---|---|---|---|---|---|---|---|
| R1 | Reader performance or library licensing | Technical | 3 | 4 | 12 | Medium | WS-B | OPEN |
| R2 | Large PDF performance and bandwidth | Technical | 3 | 4 | 12 | Medium | WS-B | OPEN |
| R3 | Offline content handling | Technical | 3 | 3 | 9 | Medium | WS-B | OPEN |
| R4 | Authentication and protected-content access | Security | 3 | 5 | 15 | High | WS-A | OPEN |
| R5 | WordPress API blocked, slow or not enabled | External | 3 | 3 | 9 | Medium | WS-B | OPEN |
| R6 | Parallel-development conflicts | Delivery | 3 | 3 | 9 | Medium | Both | OPEN |
| R7 | Compressed timeline | Schedule | 4 | 4 | 16 | High | Both (lead WS-A) | OPEN |
| R8 | Store account lead time and review | External | 3 | 4 | 12 | Medium | WS-A | OPEN |
| R9 | Apple guideline 4.8 (login services) | Compliance | 3 | 4 | 12 | Medium | WS-A | OPEN (acceptance not evidenced) |
| R10 | Minors' data | Legal and privacy | 3 | 4 | 12 | Medium | WS-A, with MFW | OPEN |
| R11 | Personal-data collection | Legal and privacy | 3 | 4 | 12 | Medium | WS-A, with MFW | OPEN |
| R12 | Unapproved architecture | Technical and governance | 4 | 4 | 16 | High | Both | OPEN |
| R13 | Commercial ambiguity | Commercial | 3 | 3 | 9 | Medium | Sanika Attarde | OPEN |
| R14 | Unknown cloud operating costs | Cost | 3 | 3 | 9 | Medium | WS-A | OPEN |
| R15 | Client inputs late or unavailable | Schedule and external | 4 | 4 | 16 | High | Sanika Attarde | OPEN |
| R16 | Incomplete tests and release automation | Quality | 3 | 3 | 9 | Medium | WS-B | OPEN |
| R17 | No separate test environment | Quality and privacy | 3 | 3 | 9 | Medium | WS-A | OPEN |
| R18 | Store policy requirements beyond guideline 4.8 | Compliance | 3 | 3 | 9 | Medium | WS-A | OPEN |
| R19 | Backup and recovery uncertainty | Operations | 2 | 4 | 8 | Medium | WS-A | OPEN |
| R20 | PROVISIONAL requirements not confirmed | Scope | 2 | 4 | 8 | Medium | Sanika Attarde | OPEN |
| R21 | Developer availability not recorded | Delivery | 3 | 4 | 12 | Medium | Both | OPEN |
| R22 | Documentation drift and duplicate sources of truth | Governance | 3 | 2 | 6 | Low | Sanika Attarde (interim editor) | OPEN |
| R23 | Vendor facts not fully verified | Technical and governance | 3 | 3 | 9 | Medium | Both | OPEN |
| R24 | Developers' latitude on development decisions is verbal | Scope and governance | 2 | 3 | 6 | Low | Both | OPEN |
| R25 | Required test devices are missing | Quality | 4 | 3 | 12 | Medium | Both | OPEN |

## 5. Risk Details

### R1 Reader performance or library licensing

| Field | Detail |
|---|---|
| Description [CH §18] | The interactive reader performs poorly on low-end phones or heavy PDFs, or a third-party library carries licence cost or restrictions. |
| Trigger | The T-02.3 reader test misses an AC-2 target, or the preferred library needs a paid licence. |
| Mitigation [CH §18; S2 Risks] | Test on MFW's real PDFs in Week 2 against the stated targets. Always build the swipe-and-zoom fallback. Use no paid component without MFW's written approval. Keep the library behind `PdfRenderer` (MOD-07). |
| Contingency | Use the fallback reader as the default. Record an agreed alternative at M2 (S2 M2). |
| Evidence and related | DEC-005; OQ-36; OQ-14; RS FR-READ-006, FR-READ-007, NFR-PERF-001, NFR-MAINT-006 |

### R2 Large PDF performance and bandwidth

| Field | Detail |
|---|---|
| Description [CH §18] | Files of up to 150 MB are downloaded in full before reading, with no CDN at launch. |
| Trigger | Near-limit downloads (FX-PDF-05) are slow or unreliable on the test devices, or open slowly. |
| Mitigation [CH §18] | Resume interrupted downloads; size warning on mobile data; test with the largest expected issue (FX-PDF-04). Measure download and open times (`TESTING_STRATEGY.md` §8.1). |
| Contingency | Propose a CDN or server-prepared pages. Both are architecture or scope changes that need MFW's approval (RS NFR-STOR-003; S2 later-phase features). |
| Evidence and related | RS NFR-STOR-001, NFR-STOR-003, FR-DL-004, FR-DL-006; DEC-020; R14 |

### R3 Offline content handling

| Field | Detail |
|---|---|
| Description [CH §18] | Interrupted downloads, storage use and damaged files. |
| Trigger | A partial or corrupt file is listed as downloaded, or storage is not freed. |
| Mitigation [CH §18] | Cover under AC-2 and AC-4. Keep downloads in app-private storage. Integrity check before listing (`API_AND_MODULE_CONTRACTS.md` §6.6). Network scenarios FX-NET-01 to FX-NET-07. |
| Contingency | Remove the partial file and offer a retry. |
| Evidence and related | RS FR-DL-006, FR-DL-009, FR-READ-010, NFR-SEC-004; OQ-08; OQ-11 |

### R4 Authentication and protected-content access

| Field | Detail |
|---|---|
| Description [CH §18] | Full issues must not be reachable without signing in. The mandatory profile adds a registration step, and Google users need a profile-completion step. |
| Scope note | The controls below cover the app's copy of an issue. The same issues are publicly downloadable from MFW's website (observed 23 October 2026, not an approved source). The app's sign-in does not protect or remove the website copy, and MFW has not decided whether those copies stay public (OQ-57). |
| Trigger | Any refused state can obtain issue content, or a long-lived public link to a PDF exists. |
| Mitigation [CH §18] | Enforce access on the backend, not only in app screens. Test with direct file requests (AC-3.5). Additionally: DEC-009, PAC-13, SEC-CHK-02 and SEC-CHK-03, and rule tests for every access state (QG-08). |
| Contingency | Treat any exposure of an issue through the app's storage or API as a critical defect (S2): stop the release and fix before anything else. |
| Evidence and related | RS NFR-SEC-002, BR-002, BR-003, FR-PROF-004; DEC-007; DEC-020; OQ-04; OQ-37 |

### R5 WordPress API blocked, slow or not enabled

| Field | Detail |
|---|---|
| Description [CH §18] | The WordPress API is blocked, slow or not enabled. |
| Trigger | The live check in T-08.1 fails, or responses match FX-WP-08 or FX-WP-12. |
| Mitigation [CH §18] | Confirm access in Week 1, test early, cache recent articles. The site address and API confirmation are an MFW input (OQ-39). |
| Contingency | MFW's host changes its settings. The project changes nothing on WordPress (RS INT-WP-002). A backend proxy is an option under DEC-021. |
| Evidence and related | RS INT-WP-001, INT-WP-004, FR-STATE-005; ASM-03; OQ-39 |

### R6 Parallel-development conflicts

| Field | Detail |
|---|---|
| Description [CH §18] | Conflicts between two developers on one codebase and one cloud project. |
| Trigger | Merge conflicts in shared files, overwritten work, or a direct push to `main`. |
| Mitigation [CH §18, expanded] | Branch discipline, reviewed integration into `main`, an agreed task split. Drafted but not agreed: `DEVELOPMENT_WORKFLOW.md`, `TASK_OWNERSHIP_MATRIX.md`, `CLAUDE_CODE_WORKING_RULES.md`. |
| Contingency | The recovery procedures in `DEVELOPMENT_WORKFLOW.md` §14 |
| Evidence and related | Commit `8941964` reached `main` with no pull request visible locally (`DEVELOPMENT_WORKFLOW.md` §3). Since then, pull request #1 (merge commit 56c6d97) and pull request #2 (merge commit 6e85734) were merged into `main` on 23 October 2026. DEC-010, DEC-011, OQ-38. |

### R7 Compressed timeline

| Field | Detail |
|---|---|
| Description [CH §18] | The start moved up from 16 November, client inputs are due earlier, and added scope is absorbed. |
| Current evidence | The CH dates are the working baseline (YG's order of authority; PROVISIONAL because the S3 emails are not filed, DEC-017). On them, M1 (21 October 2026) has no evidence of approval, and M2 (4 November 2026) needs approved screens and a reader test. Internal estimates total 58–88 developer-days against at most 80 at full time over eight weeks (`DEVELOPMENT_ROADMAP.md` §8). On 27 October 2026 YG reported that MFW has not yet provided the brand assets, the sample PDFs, the WordPress details, the cloud project or the Apple and Google accounts (GS-Q35), and that the team chose to take no action on the M2 date and to send no delay notice (GS-Q64). That is the development team's choice and not MFW's acceptance, so the status stays OPEN. Reported, not filed. |
| Trigger | A milestone exit check is not met by its relative week. |
| Mitigation [CH §18, expanded] | Eight weeks remains the commitment. Track client inputs weekly. Raise delays in writing (S2). Prioritise the P1 questions. |
| Contingency | The S2 delay rule. A schedule change agreed in writing for delays over five working days. |
| Evidence and related | DEC-017; C-08; GS-Q35, GS-Q64; R15; R21 |

### R8 Store account lead time and review

| Field | Detail |
|---|---|
| Description [CH §18] | Apple organisation enrolment can take weeks. Review timing and outcome are outside the team's control. |
| Trigger | Accounts not active by the end of Week 4 [S1], or a rejection at review. |
| Mitigation [CH §18] | Start enrolment in Week 1. M5 completes at submission. No approval date is promised. |
| Contingency | Fix and resubmit (S2 Warranty). Notification testing on iOS slips with account activation. |
| Evidence and related | OQ-42; `APP_STORE_RELEASE_CHECKLIST.md` IOS-01, AND-01 |

### R9 Apple guideline 4.8 (login services)

| Field | Detail |
|---|---|
| Description [CH §18] | The iOS build offers Google Sign-In and email login but not Sign in with Apple, so review may require an equivalent privacy-preserving login option. |
| Status note | CH records this as "Accepted risk [S3]". S3 is not in the repository, so the acceptance is not evidenced. The status stays OPEN until OQ-06 is answered in writing. |
| Trigger | Apple's review cites guideline 4.8. |
| Mitigation [CH §18] | Sign in with Apple is the known mitigation, handled as a change request if Apple requires it. |
| Contingency | A change request for Sign in with Apple, priced under S2 Changes |
| Evidence and related | OQ-06; DEC-006; C-04; IOS-12 |

### R10 Minors' data

| Field | Detail |
|---|---|
| Description [CH §18] | Age is collected with no age gate or parental-consent flow, and India's data-protection rules on children's data are due to apply within months of launch. |
| Trigger | MFW's legal adviser advises against the approach, or store age declarations conflict with it. |
| Mitigation [CH §18] | Raised with MFW as the party responsible for the data. MFW's legal adviser to confirm. An age gate can be added later by change request. |
| Contingency | A change request for an age gate or consent flow |
| Evidence and related | OQ-07; RS FR-PROF-005, NFR-PRIV-006; COM-09; AND-12; IOS-14 |

### R11 Personal-data collection

| Field | Detail |
|---|---|
| Description [CH §18] | The mandatory profile fields raise privacy obligations, and store privacy declarations must match MFW's policy. |
| Trigger | The privacy policy does not name the fields, or the store declarations do not match. |
| Mitigation [CH §18, expanded] | MFW's privacy policy names the fields and their purpose. The developers implement consent and deletion. No personal data in logs (SEC-CHK-10). Synthetic test data only (DEC-024). |
| Contingency | Hold submission until the declarations match (AC-11.3) |
| Evidence and related | OQ-01; OQ-24; OQ-27; OQ-44; RS NFR-PRIV-001, NFR-PRIV-002 |

### R12 Unapproved architecture

| Field | Detail |
|---|---|
| Description | The backend platform, admin technology and data model are not approved (DEC-003, DEC-004). Most backend and admin work, ENV-TEST, CI backend gates, deployment and backup depend on them. |
| Trigger | DEC-003 is not AGREED by the end of Week 1, or not APPROVED at M1. |
| Mitigation | Technology-neutral contracts. `SYSTEM_ARCHITECTURE.md` and `TECHNOLOGY_DECISIONS.md` exist as drafts (T-00.3). App work proceeds against fakes. |
| Contingency | Adopt the S2 baseline as the default if no alternative is agreed, recorded in the decision log |
| Evidence and related | C-05; OQ-35; `DEVELOPMENT_ROADMAP.md` §9 |

### R13 Commercial ambiguity

| Field | Detail |
|---|---|
| Description | S1 shows ₹85,000 with a ₹25,500 advance. CH shows ₹91,000 with ₹28,000 received, and different milestone amounts. The source (S3) is not filed, and S1 is unsigned. GST at the revised fee is open. |
| Trigger | A milestone invoice is disputed, or the scope added under S3 is questioned. |
| Mitigation | Obtain a signed revised proposal, or MFW's written confirmation, and a payment record (T-00.1). |
| Contingency | Treat the unsigned S1 as the only documentary baseline until MFW confirms otherwise |
| Evidence and related | DEC-016; OQ-32; OQ-33 |

### R14 Unknown cloud operating costs

| Field | Detail |
|---|---|
| Description | Cloud usage is billed to MFW at actual use [S1]. Full downloads of files up to 150 MB, with no CDN, and a possible second environment, make the costs hard to predict. No estimate exists. |
| Trigger | MFW queries a bill, or usage grows beyond expectations. |
| Mitigation | A draft comparison of candidates and a parameterised cost model exists in `CLOUD_INFRASTRUCTURE_AND_COSTS.md` (version 0.1, 25 October 2026, not reviewed). The single-provider cost model waits until DEC-003 is decided. Cost scenarios also exist in `TECHNOLOGY_DECISIONS.md` section 9 and `SYSTEM_ARCHITECTURE.md` section 13. MFW sets billing alerts in its account. |
| Contingency | A CDN, or limits on re-downloads, as architecture changes approved by MFW |
| Evidence and related | DEC-003; DEC-023; OQ-40; R2 |

### R15 Client inputs late or unavailable

| Field | Detail |
|---|---|
| Description | Brand assets, sample PDFs, WordPress details, the cloud project, store accounts, the privacy policy, launch content and approvers are MFW inputs [S1 What we need from MFW]. The repository holds no record of any being received. |
| Current evidence | Reported by YG on 27 October 2026 and not filed: MFW has not provided the brand assets, the sample PDFs, the WordPress details, the cloud project or the Apple and Google accounts. The request for those inputs has been sent. The product questions have not been sent, and no delay notice has been sent (GS-Q35, GS-Q64). The S2 delay rule is not yet invoked. |
| Trigger | An input is not received by its relative week (`DEVELOPMENT_ROADMAP.md` §3). |
| Mitigation | Weekly input tracking. Requests sent by the contracting developer. Use synthetic fixtures until the inputs arrive. |
| Contingency | The S2 delay rule: dates move one working day per day of delay. A written schedule change beyond five working days. |
| Evidence and related | `DEPENDENCY_REGISTER.md` §4; OQ-28; OQ-39; GS-Q35, GS-Q64 |

### R16 Incomplete tests and release automation

| Field | Detail |
|---|---|
| Description | No CI, no tests and no release automation exist. Without them, regressions and unsigned or untagged builds are possible. |
| Trigger | QG-01 to QG-06 are not running by the end of Week 2, or a release build cannot be traced to a tag. |
| Mitigation | `CI_CD_AND_QUALITY_GATES.md` steps 1 to 7. DoD gates. |
| Contingency | Manual gate checklists, recorded in pull requests, until CI runs |
| Evidence and related | DEC-022; S2 AC-10, AC-11 |

### R17 No separate test environment

| Field | Detail |
|---|---|
| Description | S2 refers to one MFW project. Without a separate test environment, testing either touches production or waits until late. |
| Trigger | MFW declines ENV-TEST (OQ-40). |
| Mitigation | Propose ENV-TEST with its cost to MFW (DEC-023). Use synthetic data only. |
| Contingency | Agree in writing a controlled test approach inside the single project, before any production data exists |
| Evidence and related | DEC-023; DEC-024; OQ-40 |

### R18 Store policy requirements beyond guideline 4.8

| Field | Detail |
|---|---|
| Description | Store requirements may include a web link for account-deletion requests (Google Play), complete privacy declarations, demo access for reviewers, and, depending on the account type, closed testing before production. Some of these may need work outside the stated scope. |
| Trigger | A requirement is confirmed that has no place in the current scope (for example the deletion web link, given that WordPress changes and public web pages are excluded). |
| Mitigation | Verify each item early (`APP_STORE_RELEASE_CHECKLIST.md`). Raise OQ-45 with MFW. |
| Contingency | A change request, or an MFW-hosted page that MFW provides |
| Evidence and related | OQ-42; OQ-43; OQ-44; OQ-45; PAC-15 |

### R19 Backup and recovery uncertainty

| Field | Detail |
|---|---|
| Description | S1 and S2 state no backup or recovery requirement. No provider backup is assumed, and whether MFW keeps master copies of issue PDFs is unknown. Backup set-up, restore tests, RPO and RTO targets and monitoring access are proposed additions and not S2 deliverables. |
| Trigger | Data loss before backups are configured, or an untested restore fails. |
| Mitigation | Get MFW's decision on the proposals in `BACKUP_AND_RECOVERY.md` (OQ-46). Test a restore before M5. |
| Contingency | Re-upload from MFW's master copies, if they exist |
| Evidence and related | OQ-46; OQ-24 |

### R20 PROVISIONAL requirements not confirmed

| Field | Detail |
|---|---|
| Description | Google Sign-In, no guest reading, the mandatory profile, the registered-user export and the revised schedule rest on S3 emails that are not in the repository. If MFW does not confirm them, work done on them may be rework. |
| Reported by YG | The S3 client emails exist and support the amendments. They are not in the repository and were not seen by the reviewer. The items stay PROVISIONAL until the emails are filed or MFW confirms in writing. |
| Trigger | MFW's written response differs from CH §17.3. |
| Mitigation | Obtain written confirmation early (OQ-29, T-00.1). Keep PROVISIONAL features behind clear module boundaries. |
| Contingency | Re-plan through the change process |
| Evidence and related | DEC-019; OQ-29; C-01; C-04; C-08 |

### R21 Developer availability not recorded

| Field | Detail |
|---|---|
| Description | No document records either developer's availability. YG reports that both are full time (GS-Q53, not filed). The upper estimate exceeds full-time capacity (`DEVELOPMENT_ROADMAP.md` §8). |
| Trigger | Capacity confirmed below the estimate, or an unplanned absence. |
| Mitigation | Record availability with the task split (OQ-38). Re-estimate at each task start. |
| Contingency | Narrow the scope only through the change process. Never drop a confirmed requirement unilaterally. |
| Evidence and related | OQ-38; GS-Q53; R7 |

### R22 Documentation drift and duplicate sources of truth

| Field | Detail |
|---|---|
| Description | Questions, risks, criteria and milestones appear in CH, RS and the new registers. Without a rule, the copies drift apart. |
| Trigger | The same item has different text or status in two documents. |
| Mitigation | Each new register names itself as the working copy once agreed, and the CH and RS sections are pointed to it at their next revision. QG-12 documentation checks. The document map and the retired-name aliases are in `TASK_OWNERSHIP_MATRIX.md` section 13. The crosswalks between the register families are in `DECISION_LOG.md` section 5.2, `OPEN_QUESTIONS.md` section 7 and section 7 of this register. |
| Contingency | The document higher in the source-of-truth order prevails, and the discrepancy is recorded |
| Evidence and related | `TASK_OWNERSHIP_MATRIX.md` §8.2; `DEVELOPMENT_WORKFLOW.md` §12 |

### R23 Vendor facts not fully verified

| Field | Detail |
|---|---|
| Description | Many vendor facts in the technology decisions came from summaries of long pages, and some were looked for and not found (NOT VERIFIED). A wrong fact could drive a wrong decision (`SYSTEM_ARCHITECTURE.md` AR-18). The rating is a proposal and is unreviewed. |
| Trigger | A fact marked as a summary, a relay or NOT VERIFIED in `TECHNOLOGY_DECISIONS.md` section 9 is relied on in a decision that MFW is asked to approve. |
| Mitigation | The reading mode is recorded for each source. Re-check summaries and NOT VERIFIED items on the live vendor pages before MFW approves a decision. |
| Contingency | Revise the decision through a new log entry that supersedes the old one (`DECISION_LOG.md` section 3.3). |
| Evidence and related | AR-18; AR-07; `TECHNOLOGY_DECISIONS.md` section 9.1; R12; R14 |

### R24 Developers' latitude on development decisions is verbal

| Field | Detail |
|---|---|
| Description | YG reports that MFW gave the developers latitude on development decisions at the last meeting. This is not written. Other approvals are verbal or informal too: a chat message from MFW that says "go ahead" and names no milestone note (GS-Q63), the legal adviser's approval of exact age with no age gate, relayed by MFW (GS-Q62), the two-action reading answer (GS-Q43), and Sanika's agreement with the proposed decisions (GS-Q38). Changes after the build remain possible and follow S2 change control (CH §17.2). The rating is a proposal and is unreviewed. |
| Trigger | MFW asks for a change to a decision made under that latitude, or questions a decision that was not put to it in writing. |
| Mitigation | A decision that adds third-party cost, changes scope or touches the contract still needs MFW's written approval (CH §17.4). Work on a proposal that needs approval (PRC-03, PRC-04, in-panel add and remove under OQ-58, dropping the edition-update sign-up under OQ-31) is a spike until MFW approves it in writing. The developers may ask MFW for a short written confirmation of the latitude. |
| Contingency | Handle the change under S2 Changes: a written request, a reply with effort and price, and MFW's written approval before work begins. |
| Evidence and related | Reported by YG. No date, attendee or written record. R7; R20; DEC-027; DEC-029; GS-Q38, GS-Q43, GS-Q62, GS-Q63; OQ-28; OQ-59 |

### R25 Required test devices are missing

| Field | Detail |
|---|---|
| Description | NFR-COMP-003 names a low-cost Android phone and an older iPhone for compatibility and for the M2 reader test. YG reports that the team has a mid-range Android phone and a current iPhone, and no low-cost Android phone, no older iPhone and no tablet (GS-Q54, not filed). The reader targets (first page within 3 seconds, sharp text at 300%) are then not tested on the weakest devices. The rating is a proposal and is unreviewed. |
| Trigger | The M2 reader test or a store review needs a device the team does not have, or a reader reports a failure on one. |
| Mitigation | Tell MFW which named devices are missing and ask it to supply them or to accept the gap in writing (OQ-26). Use emulators and simulators for layout only, and not for performance. State the gap in every test report. |
| Contingency | Record the gap as accepted by MFW in writing, or borrow a device for the reader test. |
| Evidence and related | GS-Q54; OQ-26; NFR-COMP-003; TD-10; R1 |

## 6. Review

- Each risk is reviewed at every milestone, and whenever its trigger occurs.
- Rating changes are made in a pull request, with the reason given.
- A risk is CLOSED only with recorded evidence. It is ACCEPTED only with written acceptance from the party responsible.

## 7. Architecture Risks (AR-nn)

`SYSTEM_ARCHITECTURE.md` section 14.1 holds 20 architecture risks, AR-01 to AR-20. This register is the single risk list, so each AR maps to an R here. No AR or R number is changed. Only AR-18 had no fit and became R23. R25 has no AR.

| AR | Topic | R |
|---|---|---|
| AR-01 | Resume with a signed URL not shown to work | R2 |
| AR-02 | Immediate deletion, a restore that brings deleted data back, and the store rules | R18 |
| AR-03 | Bucket location cannot be changed | R14 |
| AR-04 | Account-linking outcomes not verified | R4 |
| AR-05 | In-panel add and remove of admins as a scope question (OQ-58) | R7 |
| AR-06 | Revoked admin keeps access | R4 |
| AR-07 | Vendor prices and plan rules change | R14 |
| AR-08 | Lock-in to Firebase sign-in identifiers and the database model | R12 |
| AR-09 | Whole-file downloads up to 150 MB with no CDN | R2 |
| AR-10 | New major plugin versions | R16 |
| AR-11 | Working profile list wider than the S3-reported list | R11 |
| AR-12 | Charter 17.4 needs both developers to agree each architecture decision | R12 |
| AR-13 | The two-action reading answer is reported and not filed (OQ-08) | R3 |
| AR-14 | Web link for deletion requests | R18 |
| AR-15 | Admin exports carry personal data | R11 |
| AR-16 | WordPress host throttles or blocks the app | R5 |
| AR-17 | Glossary defines one admin role | R22 |
| AR-18 | Vendor facts from summaries of long pages | R23 (new) |
| AR-19 | Issue PDFs may be public on MFW's website | R4 (scope note, OQ-57) |
| AR-20 | Sign-in wall for public content, and a forced-update screen, in store review | R18 |
