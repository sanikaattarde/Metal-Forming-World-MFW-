# Definition of Done: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Definition of Done |
| File | `Documentation/DEFINITION_OF_DONE.md` |
| Phase | 3 — Development Planning and Collaboration (document 27) |
| Version | 0.1 |
| Status | Draft for review. Not approved. |
| Date | 23 October 2026 |
| Prepared in | Sanika Attarde's Claude Code session, branch `SA` |
| Approval required | Both developers |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `MFW_Statement_of_Work.pdf` (S2) "Acceptance criteria" and "How acceptance testing works" | Exists, issued, unsigned. Contractual acceptance. Not changed here. |
| `ACCEPTANCE_CRITERIA.md` | Exists, created in this task. Detailed verification of AC-1 to AC-12 and PAC-01 to PAC-15. |
| `TESTING_STRATEGY.md`, `CI_CD_AND_QUALITY_GATES.md` | Exist, created in this task. Test levels and quality gates, all PLANNED. |
| `CODING_STANDARDS.md`, `DEVELOPMENT_WORKFLOW.md`, `API_AND_MODULE_CONTRACTS.md` | Exist, created in this task |
| `MAINTENANCE_AND_HANDOVER.md`, `APP_STORE_RELEASE_CHECKLIST.md` | Exist, created in this task |

## 2. Purpose, Scope and Status

This document defines when a piece of work counts as done inside the team, using objective checks.

**"Done" is not acceptance.** MFW accepts the product through the S2 acceptance process and milestone approvals. This document never replaces or redefines S2's criteria.

## 3. Gate Availability Labels

Some checks cannot be done until infrastructure exists. Each check is labelled with when it applies. A check that is not yet available is recorded as "not yet available", never as passed.

| Label | Applies from | Depends on |
|---|---|---|
| [NOW] | Immediately | — |
| [SCAFFOLD] | The Flutter app scaffold exists | T-01.1 in `DEVELOPMENT_ROADMAP.md` |
| [BACKEND] | The backend platform is chosen and ENV-TEST exists | DEC-003, DEC-023 |
| [CI] | CI runs on pull requests | DEC-022, T-01.5 |
| [DEVICES] | The test devices are agreed and available | OQ-26; S2 AC-10 |
| [STORE] | Store accounts are active and identifiers are set | OQ-42 |

## 4. DoD-DOC — Documentation Task

| # | Check | Available |
|---|---|---|
| 1 | Document control filled in: file, version, status, date, approval required, change history | [NOW] |
| 2 | Purpose, scope, status and related documents stated. Each related document is marked as existing or planned. | [NOW] |
| 3 | Every statement that matters is labelled CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN, CONFLICT or PROPOSED | [NOW] |
| 4 | Every cited requirement, question, risk, decision or acceptance ID exists in its source document | [NOW] |
| 5 | No invented dates, approvals, test results, prices, credentials or commercial commitments | [NOW] |
| 6 | No draft is described as approved | [NOW] |
| 7 | Conflicts are shown, not silently resolved | [NOW] |
| 8 | The mandatory access rules (DEC-007, DEC-009) are preserved | [NOW] |
| 9 | No content duplicates a source document wholesale. Sources are cited instead. | [NOW] |
| 10 | Reviewed and approved by the other developer in a pull request | [NOW] |
| 11 | Any MFW approval required is recorded with evidence (`DECISION_LOG.md` §3.1) | [NOW] |
| 12 | `CHANGELOG.md` line added | [NOW] |

## 5. DoD-TASK — Development Task

| # | Check | Available |
|---|---|---|
| 1 | Changes stay within the task's owned paths, or follow the shared-file protocol | [NOW] |
| 2 | Relies only on AGREED or APPROVED decisions. Otherwise the work is a spike on a `spike/` branch and is not merged as production code (`DEVELOPMENT_WORKFLOW.md` §13). | [NOW] |
| 3 | Follows `CODING_STANDARDS.md`. Formatting and analysis are clean. | [SCAFFOLD] |
| 4 | Unit and widget tests for the new behaviour and its failure paths pass, with requirement IDs in the test names | [SCAFFOLD] |
| 5 | Loading, empty and error states handled where the screen has them (RS FR-STATE-001 to 007) | [SCAFFOLD] |
| 6 | Nothing from the "never log" list in `CODING_STANDARDS.md` §6.2 is logged. No secrets or real personal data. | [NOW] |
| 7 | Backend or rule tests added for any server change, including refused cases | [BACKEND] |
| 8 | CI checks pass | [CI] |
| 9 | Pull request description complete (`DEVELOPMENT_WORKFLOW.md` §6.1), with test evidence | [NOW] |
| 10 | Reviewed and merged by the other developer | [NOW] |

## 6. DoD-FEAT — Feature

A feature is a set of tasks that together deliver one area, for example offline downloads. It is done when every task meets DoD-TASK and:

| # | Check | Available |
|---|---|---|
| 1 | Every RS requirement mapped to the feature is implemented, or is explicitly blocked by a recorded question | [SCAFFOLD] |
| 2 | Every related row in `ACCEPTANCE_CRITERIA.md` has been run, with recorded evidence, in ENV-TEST | [BACKEND] |
| 3 | Access rules verified for each access state in `API_AND_MODULE_CONTRACTS.md` §4.1 that applies | [BACKEND] |
| 4 | Behaviour matches the M2-approved screens | [SCAFFOLD] |
| 5 | Tested on at least one Android and one iOS device or emulator, and on the agreed devices before M4 | [DEVICES] |
| 6 | Integration contracts (`API_AND_MODULE_CONTRACTS.md` §10) for the feature pass | [BACKEND] |
| 7 | Accessibility baseline checked (`CODING_STANDARDS.md` §9, PROVISIONAL) | [SCAFFOLD] |
| 8 | User-facing documentation or administrator-guide notes drafted where relevant | [NOW] |

## 7. DoD-INT — Integration into `main` and Milestone Builds

| # | Check | Available |
|---|---|---|
| 1 | The branch is up to date with `main`, and re-checked after any later merge | [NOW] |
| 2 | Builds for Android and iOS from `main` | [SCAFFOLD] |
| 3 | Full automated test suite passes on `main` | [SCAFFOLD], [CI] |
| 4 | Every integration contract affected passes (IC-01 to IC-08) | [BACKEND] |
| 5 | No open defect of critical severity [S2 How acceptance testing works] | [NOW] |
| 6 | For a milestone build: the S2 "MFW approves when" condition can be demonstrated (`DEVELOPMENT_ROADMAP.md` §5) | [DEVICES] |
| 7 | `CHANGELOG.md` updated | [NOW] |

## 8. DoD-BUG — Bug Fix

| # | Check | Available |
|---|---|---|
| 1 | The defect is recorded with steps, expected and actual results, severity (S2 definitions), and the affected requirement or acceptance ID | [NOW] |
| 2 | A test reproduces the defect and fails before the fix | [SCAFFOLD] |
| 3 | The test passes after the fix. The related area is re-tested. | [SCAFFOLD] |
| 4 | For a security or data-exposure defect, the related SEC-CHK items are re-run | [BACKEND] |
| 5 | During acceptance testing: a reply within one working day, and MFW can check each fix within two working days [S2 How acceptance testing works] | [NOW] |
| 6 | Reviewed and merged as in DoD-TASK | [NOW] |

## 9. DoD-RC — Release Candidate

| # | Check | Available |
|---|---|---|
| 1 | Built from a release tag on `main` (S2 AC-11; DEC-015) | [CI] |
| 2 | Every row in `ACCEPTANCE_CRITERIA.md` has a recorded result (S2 AC-10) | [DEVICES] |
| 3 | Security checklist completed (`TESTING_STRATEGY.md` §9; S2 AC-10) | [BACKEND] |
| 4 | No critical or high defect open (S2 AC-10) | [NOW] |
| 5 | Android and iOS builds are signed through MFW's accounts | [STORE] |
| 6 | Store privacy details match MFW's privacy policy (S2 AC-11) | [STORE] |
| 7 | `APP_STORE_RELEASE_CHECKLIST.md` complete for both platforms | [STORE] |
| 8 | Backend and admin deployed to production as in `DEPLOYMENT_PLAN.md`, with smoke tests recorded | [BACKEND] |
| 9 | Known limitations listed | [NOW] |

## 10. DoD-HO — Production Handover

| # | Check | Available |
|---|---|---|
| 1 | MFW signs off acceptance testing (S2 M5) | [NOW] |
| 2 | Source code with history is in a repository owned by MFW (S2 AC-12; OQ-48) | [NOW] |
| 3 | Following the written documentation, the app builds and the backend deploys from a clean copy into a fresh project (S2 AC-12) | [BACKEND] |
| 4 | Credentials are held by MFW. A record of who holds each one is delivered. No secret values appear in it. [S2 Handover] | [STORE] |
| 5 | Technical documentation, administrator guide, training session, release package, test evidence and known limitations delivered [S2 Handover] | [NOW] |
| 6 | Both builds submitted, and MFW holds the confirmations (S2 AC-11) | [STORE] |
| 7 | The items in `MAINTENANCE_AND_HANDOVER.md` are complete or explicitly agreed as outstanding | [NOW] |

## 11. Evidence

| Evidence | Acceptable form |
|---|---|
| Test result | Test runner output or CI log, linked in the pull request |
| Manual test | Test case ID, device and OS version, build identifier, date, result, screenshot or screen recording where useful |
| Performance figure | Method, device, file used, repetitions, measured values |
| Security check | SEC-CHK ID, method, result, evidence location |
| MFW approval | The email or document, or a reference to it, recorded as in `DECISION_LOG.md` §3.1 |
| Review | The pull-request approval |

Test evidence must not contain real personal data or secrets (DEC-024).

## 12. Exceptions

A check may be waived only when both developers agree, the reason is recorded in the pull request, and an `OPEN_QUESTIONS.md` or `RISK_REGISTER.md` entry tracks the gap. Contractual criteria in S2 cannot be waived internally.
