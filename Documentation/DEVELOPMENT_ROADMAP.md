# Development Roadmap: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Development Roadmap |
| File | `Documentation/DEVELOPMENT_ROADMAP.md` |
| Phase | 3 — Development Planning and Collaboration (document 23) |
| Version | 0.1 |
| Status | Draft for review. Not approved. An internal planning document, not a contractual commitment. |
| Date | 23 October 2026 |
| Prepared in | Sanika Attarde's Claude Code session, branch `SA` |
| Approval required | Both developers. MFW approves milestones, not this plan. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `MFW_Statement_of_Work.pdf` (S2) "Deliverables and milestones" | Exists, issued, unsigned. Milestone content and approval conditions. |
| `MFW_Commercial_Proposal-2.pdf` (S1) "What we need from MFW" | Exists, issued, unsigned. Client inputs, set relative to project weeks. |
| `PROJECT_CHARTER.md` (CH) §12 | Exists, draft. Re-based dates (PROVISIONAL, C-08). |
| `REQUIREMENTS_SPECIFICATION.md` (RS) | Exists, draft |
| `TASK_OWNERSHIP_MATRIX.md`, `DECISION_LOG.md`, `OPEN_QUESTIONS.md`, `DEFINITION_OF_DONE.md`, `ACCEPTANCE_CRITERIA.md` | Exist, created in this task |
| `SYSTEM_ARCHITECTURE.md`, `TECH_STACK_DECISIONS.md` | Planned (Phase 2). Not created. Needed for M1. |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal. **INTERNAL ESTIMATE** marks an unvalidated planning figure that is not a commitment.

## 2. Purpose, Scope and Status

This roadmap turns the requirements into sequenced work packages, tasks, dependencies, internal estimates and measurable exit criteria.

**What is contractual and what is internal**

| Content | Nature |
|---|---|
| Milestones M1 to M5 and what MFW approves at each | Contractual baseline in S2 (unsigned copy). Not changed here. |
| Milestone dates | In conflict (C-08, DEC-017). Planned in relative weeks; dates shown with their source. |
| Work packages, tasks, sequence, estimates | Internal planning only. PROPOSED. |
| Six-week finish | An internal target only (CH §12). Not a commitment to MFW. |

Nothing in this document states that work is complete, that MFW has approved anything, or that resources are confirmed.

## 3. Schedule Basis

S1 and S2 set two-week milestone spacing: M2 at the end of Week 2, M3 at the end of Week 4, M4 at the end of Week 6, M5 at the end of Week 8 [S1 Milestone-based payment schedule; S2 Deliverables and milestones]. This roadmap uses those relative weeks. Week 1 starts on the project start date.

| Milestone | Relative timing | S1 and S2 date (unsigned baseline) | CH §12 planned date (PROVISIONAL, C-08) |
|---|---|---|---|
| M1 Kickoff | Start | Mon 16 Nov 2026 | 21 Oct 2026 |
| M2 Design approval | End of Week 2 | Fri 27 Nov 2026 | 4 Nov 2026 |
| M3 Core app and backend | End of Week 4 | Fri 11 Dec 2026 | 18 Nov 2026 |
| M4 Feature-complete build | End of Week 6 | Fri 25 Dec 2026 | 2 Dec 2026 |
| M5 Approval and store submission | End of Week 8 | Fri 8 Jan 2027 | 16 Dec 2026 |

Under S2, a one-working-day delay on a key client input moves later dates by one working day, and a delay of more than five working days is a schedule change agreed in writing [S2 Responsibilities]. M5 completes at submission, not at store approval [S2 Deliverables and milestones].

## 4. Current Status

Evidence from the repository on 23 October 2026.

| Item | State |
|---|---|
| Project week | If the CH start date (21 October 2026) applies, the project is in Week 1. If the S2 date applies, it has not started. (C-08) |
| Phase 1 documents | `PROJECT_CHARTER.md` and `REQUIREMENTS_SPECIFICATION.md` exist as v0.1 drafts. `SCOPE_AND_EXCLUSIONS.md`, `ASSUMPTIONS_AND_CONSTRAINTS.md` and `GLOSSARY.md` are planned but not created. |
| Phase 2 documents | None exist |
| Phase 3 and Phase 4 documents | Drafted in this task and committed on `SA`. Not merged to `main` and not reviewed. |
| Application code | None |
| M1 | No evidence of MFW's written approval of a requirements and architecture note. No architecture note exists. |
| MFW inputs (S1 "What we need from MFW") | The repository holds no record of any input being received, other than the S1 and S2 PDFs themselves |

## 5. Milestone Gates

The "MFW approves when" column restates S2 and is not changed here. The internal exit checks are PROPOSED.

| Gate | MFW approves when [S2] | Internal exit checks before asking MFW |
|---|---|---|
| M1 | MFW approves the requirements and architecture note in writing, names its approver and deputy, and supplies brand assets | `REQUIREMENTS_SPECIFICATION.md` agreed internally; `SYSTEM_ARCHITECTURE.md` and `TECH_STACK_DECISIONS.md` drafted; DEC-003 and DEC-004 at least AGREED; repository set up (WP-01, T-01.1 and T-01.2) |
| M2 | MFW approves the screens; the reader approach is confirmed, or an agreed alternative is recorded | Prototype covers every in-scope screen, including loading, empty and error states (RS ASM-13); reader test report on MFW's PDFs (T-02.3); P1 questions in `OPEN_QUESTIONS.md` answered or explicitly deferred |
| M3 | A tester can sign up, log in, browse the catalogue and open an issue in the reader on the demo build | Demo builds on Android and iOS test devices; WP-03 core tasks, WP-04 and the first reader from WP-05 meet DoD-FEAT (`DEFINITION_OF_DONE.md` §6) |
| M4 | Every feature in S2 is present, and no critical defect is open | All work packages up to WP-10 meet DoD-FEAT; admin panel live; notifications working end to end; internal test summary (T-11.4) |
| M5 | MFW signs off acceptance testing, and AC-11 and AC-12 are met | DoD-RC (`DEFINITION_OF_DONE.md` §9) and DoD-HO (§10) met; both builds submitted |

## 6. Work Packages

Estimates are **INTERNAL ESTIMATES** in developer-days. They are ranges, not validated, and are re-estimated by the owner at the start of each task. Owners follow `TASK_OWNERSHIP_MATRIX.md` §7 (PROPOSED).

### WP-00 Clarification and architecture approval (M1 gate)

Lead: Sanika Attarde. Support: Yuvraj. Estimate: 3–5 developer-days.

| Task | Description | Blocked by | Exit criterion |
|---|---|---|---|
| T-00.1 | Obtain MFW's written records: the S3 amendments (OQ-29), approver and deputy (OQ-28), commercial terms (OQ-32, OQ-33), two-developer delivery (OQ-34) | MFW response | Records filed or referenced. DEC-016 to DEC-019 updated. |
| T-00.2 | Put the P1 product questions to MFW: OQ-01 to OQ-03, OQ-08, OQ-09, OQ-12, OQ-13, OQ-16 to OQ-18, OQ-25, OQ-27, OQ-31 | MFW response | Each answer recorded in `OPEN_QUESTIONS.md` |
| T-00.3 | Draft `SYSTEM_ARCHITECTURE.md` and `TECH_STACK_DECISIONS.md` (Phase 2) | None | DEC-003 and DEC-004 move from OPEN to PROPOSED with options assessed |
| T-00.4 | Review and agree the Phase 3 and Phase 4 documents, DEC-010 to DEC-015, DEC-022 to DEC-024, and the task split (OQ-38) | None | AGREED, with pull-request review evidence |
| T-00.5 | Send the M1 requirements and architecture note to MFW | T-00.3 | MFW's written approval recorded (S2 M1) |

### WP-01 Repository and development setup

Lead: joint. Estimate: 2–4 developer-days.

| Task | Owner | Description | Blocked by | Exit criterion |
|---|---|---|---|---|
| T-01.1 | WS-B | Flutter app scaffold following `CODING_STANDARDS.md` §3 | OQ-50 (toolchain), DEC-013 and DEC-014 AGREED | An empty shell builds and runs on an Android emulator and an iOS simulator. `flutter analyze` is clean. |
| T-01.2 | WS-A | `.gitignore`, configuration example file, `README.md` files | None | A clean clone builds by following the README |
| T-01.3 | WS-A | Role-based access to MFW's cloud project(s) (RS NFR-SEC-012) | MFW input: cloud project with billing; DEC-023 and OQ-40 | Both developers have access through their own accounts |
| T-01.4 | WS-A | Backend project skeleton | DEC-003 | Deploys an empty project to ENV-TEST |
| T-01.5 | WS-B | CI skeleton with QG-01 to QG-06 (`CI_CD_AND_QUALITY_GATES.md`) | DEC-022, T-01.1 | Checks run on a pull request |
| T-01.6 | WS-A | Admin panel skeleton | DEC-004 | Builds and serves an admin sign-in page in ENV-TEST |

### WP-02 Design and reader validation (M2 gate)

Lead: WS-B. Support: WS-A. Estimate: 7–10 developer-days.

| Task | Owner | Description | Blocked by | Exit criterion |
|---|---|---|---|---|
| T-02.1 | WS-B, with WS-A for its screens | App screens and interactive prototype | MFW brand assets; OQ-01, OQ-13, OQ-16, OQ-17 for content | Prototype covers every in-scope screen and state |
| T-02.2 | WS-A | Admin panel screens | OQ-20, OQ-22, OQ-31 | Screens cover RS §5.12 and §5.13 |
| T-02.3 | WS-B | Reader test on MFW's sample PDFs: first-page time, sharpness at 300% zoom, 20 page turns on the mid-range test phone; candidate libraries assessed, including licence (DEC-005) | MFW sample PDFs; test phone (OQ-26) | Reader test report filed. DEC-005 PROPOSED. AC-2 targets confirmed or adjusted with MFW (S2 AC-2). |
| T-02.4 | WS-B, with WS-A | Spike: resume of a near-limit download using the candidate file mechanism (DEC-020) | DEC-003 | Evidence that a download resumes after a network break without restarting |
| T-02.5 | Sanika Attarde | Present the designs and reader result to MFW | T-02.1 to T-02.3 | MFW's written approval recorded (S2 M2) |

### WP-03 Authentication, profile and account lifecycle

Owner: WS-A. Estimate: 6–9 developer-days.

| Task | Description | Blocked by | Exit criterion |
|---|---|---|---|
| T-03.1 | Email registration, verification, sign-in, password reset, sign-out, sign-in prompt (RS FR-AUTH-001 to 004, 008, 010) | DEC-003 | AC-3.1, AC-3.3, AC-3.4, AC-3.6 pass in ENV-TEST |
| T-03.2 | Google Sign-In (RS FR-AUTH-005) | OQ-29 (scope confirmation; may be built as PROVISIONAL), OQ-04, OQ-05; OAuth set-up in MFW's accounts | PAC-01 and PAC-12 pass |
| T-03.3 | Mandatory profile and consent (RS FR-PROF-001 to 007, FR-PRIV-001, FR-PRIV-002) | OQ-01, OQ-02, OQ-03, OQ-07, OQ-27 | PAC-02 and PAC-08 pass |
| T-03.4 | `AccessState` and route guards, with WS-B | T-03.1 | IC-01 passes |
| T-03.5 | Account deletion (RS FR-AUTH-009, FR-PRIV-003, FR-PRIV-004; OP-ACC-01) | OQ-24 | AC-3.7 and PAC-06 pass |
| T-03.6 | Server access rules for profiles and preferences (MOD-13) | DEC-003 | SEC-CHK-05 rule tests pass |

### WP-04 Catalogue, search and home

Owner: WS-B. Estimate: 3–5 developer-days.

| Task | Description | Blocked by | Exit criterion |
|---|---|---|---|
| T-04.1 | Catalogue and issue details (RS FR-MAG-001 to 005) | OQ-13 | AC-1.1 passes |
| T-04.2 | Search and filters (RS FR-SRCH-001 to 007) | OQ-13 | AC-1.2, AC-1.3 and PAC-07 pass |
| T-04.3 | Home screen (RS FR-MAG-006) | M2 designs | Matches the approved design |
| T-04.4 | Refresh and publication changes (RS FR-MAG-007, FR-MAG-008) | T-09.3, or seeded data | AC-1.4 and IC-07 pass |

### WP-05 Reader

Owner: WS-B. Estimate: 7–10 developer-days.

| Task | Description | Blocked by | Exit criterion |
|---|---|---|---|
| T-05.1 | Integrate the chosen library behind `PdfRenderer` | DEC-005 AGREED | Opens FX-PDF-01 to FX-PDF-04 |
| T-05.2 | Page-turn and swipe modes, tap and swipe page turns (RS FR-READ-003, 004, 006, 007) | OQ-14 | AC-2.2 and AC-2.7 pass |
| T-05.3 | Zoom to 300% and two-page spread (RS FR-READ-005, FR-READ-009) | None | AC-2.3 and AC-2.4 pass |
| T-05.4 | Damaged-file handling (RS FR-READ-010) | None | AC-2.6 passes |
| T-05.5 | Performance tuning on the test devices (RS NFR-PERF-001, NFR-PERF-002, NFR-REL-001) | OQ-26 devices | AC-2.1 and AC-2.5 pass |

### WP-06 Issue access and offline downloads

Owner: WS-B. Support: WS-A. Estimate: 5–8 developer-days.

| Task | Owner | Description | Blocked by | Exit criterion |
|---|---|---|---|---|
| T-06.1 | WS-A | OP-FILE-01 on the server (DEC-009) | DEC-003, DEC-020 | PAC-13 and SEC-CHK-02 pass |
| T-06.2 | WS-B | Download with size display, mobile-data warning, progress and free-space check (RS FR-DL-003 to 005, FR-STATE-004) | T-06.1 | AC-4.1, AC-4.4 and AC-4.5 pass |
| T-06.3 | WS-B | Resume after a network break (RS FR-DL-006) | T-02.4 | AC-4.3 passes |
| T-06.4 | WS-B | Integrity check, Downloads screen and deletion (RS FR-DL-008, FR-DL-009) | None | AC-4.6 and AC-4.7 pass |
| T-06.5 | WS-B | Offline opening (RS FR-DL-007); behaviour after sign-out, deletion or unpublishing (FR-DL-010) | OQ-08, OQ-11 | AC-4.2 and PAC-14 pass |

### WP-07 Bookmarks and favourites

Owner: WS-B. Support: WS-A. Estimate: 2–3 developer-days.

| Task | Owner | Description | Blocked by | Exit criterion |
|---|---|---|---|---|
| T-07.1 | WS-A | Server rules for own records only (RS NFR-SEC-005) | DEC-003 | SEC-CHK-05 passes |
| T-07.2 | WS-B | Bookmarks (RS FR-BKM-001, 002, 006, 007) | T-05.1 | AC-5.1 passes |
| T-07.3 | WS-B | Favourites (RS FR-BKM-003) | OQ-12 | AC-5.2 passes |
| T-07.4 | WS-B | Second device and isolation between readers (RS FR-BKM-004, FR-BKM-005) | T-07.1 | AC-5.3, AC-5.4 and IC-04 pass |

### WP-08 News and sharing

Owner: WS-B. Estimate: 4–6 developer-days.

| Task | Description | Blocked by | Exit criterion |
|---|---|---|---|
| T-08.1 | WordPress client and fixtures (RS INT-WP-001 to 005) | OQ-39 | Fixture tests pass; one live read from MFW's site recorded |
| T-08.2 | News list, article and category filter (RS FR-NEWS-001 to 004) | T-08.1 | AC-7.1, AC-7.2, AC-7.3 and AC-7.5 pass |
| T-08.3 | Offline reading of loaded articles (RS FR-NEWS-005, FR-NEWS-006) | OQ-16 | AC-7.4 passes |
| T-08.4 | Apply news controls (RS FR-NEWS-008, FR-NEWS-009) | T-09.4, OQ-17 | AC-8.8 and IC-06 pass |
| T-08.5 | Sharing (RS FR-SHR-001 to 006) | OQ-15 | AC-6.1, AC-6.2 and PAC-05 pass |

### WP-09 Admin panel and content pipeline

Owner: WS-A. Estimate: 7–10 developer-days.

| Task | Description | Blocked by | Exit criterion |
|---|---|---|---|
| T-09.1 | Admin sign-in and role (RS FR-ADMIN-002 to 004) | DEC-004, OQ-20 | AC-8.1 and AC-8.2 pass |
| T-09.2 | Upload and validation (RS FR-ADMIN-005 to 008, NFR-SEC-008) | OQ-22, OQ-30 | AC-8.3 to AC-8.5 pass |
| T-09.3 | Issue details, categories, publish and unpublish (RS FR-ADMIN-009 to 011) | None | AC-8.6, AC-8.7 and IC-07 pass |
| T-09.4 | News controls (RS FR-ADMIN-013 to 015) | None | AC-8.8 passes |
| T-09.5 | Registered-user list and export (PROVISIONAL); subscriber export | OQ-29, OQ-31 | AC-8.9 and PAC-03 pass |
| T-09.6 | Deleting an issue or replacing its file | OQ-21 | Behaviour matches the OQ-21 decision |

### WP-10 Notifications

Owner: WS-A. Support: WS-B. Estimate: 3–5 developer-days.

| Task | Owner | Description | Blocked by | Exit criterion |
|---|---|---|---|---|
| T-10.1 | WS-A | Push set-up in MFW's accounts (RS INT-PUSH-001, INT-PUSH-002) | Active Apple Developer account (S1: by the end of Week 4); DEC-003 | A test notification reaches an Android and an iOS test device |
| T-10.2 | WS-A | Permission explanation and preferences (RS FR-NOTIF-001 to 003) | OQ-09, OQ-18 | AC-9.1 passes |
| T-10.3 | WS-A | Dispatch, category targeting and send log (RS FR-NOTIF-004, FR-ADMIN-015 to 018) | OQ-19 | AC-9.2, AC-9.4 and AC-9.5 pass |
| T-10.4 | WS-B | Tap routing (RS FR-NOTIF-005, BR-005) | T-10.1 | AC-9.3 and IC-05 pass |

### WP-11 Integration, hardening and testing

Lead: WS-B. Support: WS-A. Estimate: 6–8 developer-days.

| Task | Description | Exit criterion |
|---|---|---|
| T-11.1 | Feature freeze and M4 integration build (DoD-INT) | Build cut from `main`, with every IC passing |
| T-11.2 | Full regression on the agreed device set (S2 AC-10) | Results recorded for every criterion in `ACCEPTANCE_CRITERIA.md` |
| T-11.3 | Security checklist (`TESTING_STRATEGY.md` §9) | Every SEC-CHK item recorded as passed, or as a logged defect |
| T-11.4 | Internal test summary (S2 M4) | Summary filed |
| T-11.5 | Acceptance test build and test script to MFW. MFW has five working days. Developers reply to each item within one working day [S2 How acceptance testing works]. | No critical or high defect open at the start (AC-10.4) |

### WP-12 Release, acceptance and handover

Lead: WS-A. Support: WS-B. Estimate: 3–5 developer-days.

| Task | Description | Blocked by | Exit criterion |
|---|---|---|---|
| T-12.1 | Store listings, screenshots and privacy declarations | OQ-42, OQ-44, MFW listing text | MFW approves the listing text (AC-11.2) |
| T-12.2 | Signed builds from a release tag | Signing set-up in MFW's accounts | AC-11.1 passes |
| T-12.3 | Submission to Apple and Google; confirmations sent to MFW | T-12.1, T-12.2 | AC-11.4 passes |
| T-12.4 | Technical documentation, administrator guide, training of up to two hours [S2 Handover] | None | Delivered |
| T-12.5 | Record of who holds each credential; list of known limitations [S2 Handover] | None | Delivered |
| T-12.6 | Repository transfer and clean-copy rebuild (S2 AC-12) | OQ-48 | AC-12.1 to AC-12.3 pass |

## 7. Week-by-Week Sequence

PROPOSED. Weeks are relative to the project start. ■ marks planned activity.

| WP | W1 | W2 | W3 | W4 | W5 | W6 | W7 | W8 |
|---|---|---|---|---|---|---|---|---|
| WP-00 Clarification, M1 | ■ | ■ | | | | | | |
| WP-01 Setup | ■ | ■ | | | | | | |
| WP-02 Design, reader test, M2 | ■ | ■ | | | | | | |
| WP-03 Authentication and profile | | ■ | ■ | ■ | | | | |
| WP-04 Catalogue | | | ■ | ■ | | | | |
| WP-05 Reader | | | ■ | ■ | ■ | | | |
| WP-06 Downloads | | | ■ | ■ | ■ | | | |
| WP-07 Bookmarks and favourites | | | | | ■ | | | |
| WP-08 News and sharing | | | ■ | ■ | ■ | | | |
| WP-09 Admin panel | | | ■ | ■ | ■ | ■ | | |
| WP-10 Notifications | | | | | ■ | ■ | | |
| WP-11 Integration and testing | | | | | | ■ | ■ | |
| WP-12 Release and handover | | | | | | | ■ | ■ |

M3 at the end of W4 needs sign-up, login, catalogue and a first reader. M4 at the end of W6 needs every feature. Acceptance testing runs in W7, followed by fixes and submission in W8.

## 8. Estimates and Capacity

| Work package | INTERNAL ESTIMATE (developer-days) |
|---|---|
| WP-00 | 3–5 |
| WP-01 | 2–4 |
| WP-02 | 7–10 |
| WP-03 | 6–9 |
| WP-04 | 3–5 |
| WP-05 | 7–10 |
| WP-06 | 5–8 |
| WP-07 | 2–3 |
| WP-08 | 4–6 |
| WP-09 | 7–10 |
| WP-10 | 3–5 |
| WP-11 | 6–8 |
| WP-12 | 3–5 |
| **Total** | **58–88** |

**Capacity check (illustrative, not a confirmed resource plan):**

- Eight weeks at five working days, with both developers full time, is 80 developer-days. Six weeks is 60.
- Neither developer's availability is recorded (OQ-38).
- The upper estimate exceeds full-time capacity over eight weeks. The six-week internal target fits only the lower estimate at full-time availability.
- Client review periods [S2 Responsibilities] and public holidays are not included.

Implication: the schedule depends on early answers to P1 questions, timely MFW inputs, and confirmed availability. See risks R7, R15 and R21 in `RISK_REGISTER.md`.

## 9. Blocked Tasks

| Task | Blocked by | Needed by (relative week) | Who unblocks |
|---|---|---|---|
| T-01.3, T-01.4, T-03.1, T-06.1, T-07.1 | DEC-003 (OQ-35); MFW cloud project | W1 to W2 | Both developers; MFW |
| T-01.6, T-09.1 | DEC-004 | W2 | Both developers |
| T-02.3, T-05.1 | MFW sample PDFs; DEC-005 (OQ-36) | W1 to W2 | MFW; WS-B |
| T-02.4, T-06.3 | DEC-020 (OQ-37) | W2 | Both developers |
| T-03.2 | OQ-04, OQ-05, OQ-29 | W2 | MFW; both developers |
| T-03.3 | OQ-01, OQ-02, OQ-03, OQ-07, OQ-27 | W2 | MFW |
| T-03.5 | OQ-24 | W4 | MFW |
| T-04.1, T-04.2 | OQ-13 | W2 | MFW |
| T-06.5 | OQ-08, OQ-11 | W3 | MFW |
| T-08.1 | OQ-39 | W1 | MFW |
| T-08.3, T-08.4 | OQ-16, OQ-17 | W3 | MFW |
| T-09.2, T-09.5, T-09.6 | OQ-22, OQ-30, OQ-31, OQ-21 | W3 to W4 | MFW |
| T-10.1 | Apple Developer account active | End of W4 [S1] | MFW |
| T-10.2, T-10.3 | OQ-09, OQ-18, OQ-19 | W4 | MFW; both developers |
| T-12.1 to T-12.3 | OQ-42, OQ-43, OQ-44, OQ-45 | W6 | MFW |
| T-12.6 | OQ-48 | W8 | MFW; Sanika Attarde |

## 10. Critical Path

1. MFW inputs: cloud project, sample PDFs, WordPress details. S1 expects these by the end of Week 1.
2. Architecture agreed (DEC-003) and M1 approved.
3. Backend skeleton (T-01.4), then authentication (WP-03) and OP-FILE-01 (T-06.1).
4. Downloads (WP-06), then reader performance on MFW's real PDFs (T-05.5).
5. Integration and acceptance testing (WP-11).
6. Release and submission (WP-12).

A parallel critical chain: the Apple organisation enrolment, which S1 says can take weeks, must be active by the end of Week 4 for push testing (T-10.1) and submission (T-12.3).

## 11. Maintaining This Roadmap

- Each work-package owner updates the estimates and status in a pull request when a task starts or finishes, with evidence as `DEFINITION_OF_DONE.md` requires.
- When DEC-017 is resolved, add confirmed dates beside the relative weeks. Do not remove the relative weeks.
- A slip in a client input is recorded with its date and its effect, under S2's delay rule.
