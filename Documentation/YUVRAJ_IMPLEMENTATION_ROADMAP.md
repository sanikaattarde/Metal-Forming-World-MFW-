# Yuvraj Implementation Roadmap: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Yuvraj Implementation Roadmap |
| File | `Documentation/YUVRAJ_IMPLEMENTATION_ROADMAP.md` |
| Assigned developer | Yuvraj (branch `YG`, workstream WS-B Reader Experience, PROPOSED under DEC-011) |
| Project | Metal Forming World (MFW) mobile application |
| Version | 0.2 |
| Last updated | 7 November 2026 |
| Status | Draft for review. Not approved. A planning document. It approves no decision, requirement or scope item. Drafted in Sanika Attarde's session, so Yuvraj has not yet reviewed it (task MOD20-P1-T04). |
| Prepared in | Sanika Attarde's session, branch `SA`, on top of commit `bd2db98` |
| Authoritative module inventory | `Documentation/IMPLEMENTATION_MODULE_INVENTORY.md` v0.1. If this roadmap and the inventory differ, the inventory wins. |
| Companion roadmap | `Documentation/SANIKA_IMPLEMENTATION_ROADMAP.md` v0.1 |
| Approval required | Both developers |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 27 October 2026 | Initial draft. 58 tasks in 12 modules. |
| 0.2 | 7 November 2026 | Committed to the repository, unchanged apart from a status note after this table, the version, the date, and one wording fix (a tool name in the "Prepared in" row). The plan, its task IDs and its order of work are not changed. |

**Status note of 7 November 2026.** This document was written on 30 October 2026 on top of commit `bd2db98`, and it is committed here as a record of the plan. Apart from this note, the version, the date and a few wording fixes, it is unchanged. The sections below describe the repository, the open pull requests and the open decisions as they were on 30 October 2026, and are not updated. Since then the Flutter app scaffold (pull request 30) and the shared contracts and fakes (pull request 34) are on `main`; the backend and admin panel spikes are done, and their evidence reports are in `Documentation/test-evidence/` (emulator only, not merged); both developers' written notes are filed, and DEC-010 to DEC-015, DEC-022 and DEC-024 to DEC-030 are AGREED (`DECISION_LOG.md` sections 5.6 and 5.8); and the second-person reviews of issues 28, 29, 31 and 32 are recorded in pull requests 33 to 46. `README.md`, `CHANGELOG.md` and `DEVELOPMENT_ROADMAP.md` give the current state. The task IDs and the order of work stay as the plan.

## 2. Project Context

MFW is a Flutter app for Android and iOS, a backend on MFW's own cloud accounts, and a web admin panel, for MFW's magazine issues and news [S2 Product]. Readers browse a public catalogue and news. Opening or downloading a full issue needs a signed-in reader with full access. There is no guest reading (DEC-007, working position, mandatory). A full issue is read only from a complete, verified copy on the device (FR-READ-002). Reading before the download finishes is excluded (EXC-03).

The scope baseline is S2 and S1, whose repository copies are unsigned (OQ-28). The reader library is chosen after the M2 reader test (DEC-005). The reading model, a temporary copy for Read and a kept copy for Download, is PROPOSED (DEC-033) and waits for MFW's written answer (OQ-08). The file-delivery mechanism is OPEN (DEC-020). Riverpod and go_router are PROPOSED (DEC-013, DEC-014). YG has accepted them, and Sanika Attarde's written agreement is not yet filed.

Delivery runs through milestones M1 to M5 [S2]. The working dates are the Charter's (PROVISIONAL, C-08): M2 4 November, M3 18 November, M4 2 December, M5 16 December 2026. `DEVELOPMENT_ROADMAP.md` §3 and §7 hold the week plan, which this roadmap does not change.

No application code exists (inventory section 2.2). Every task below is Not started unless stated.

## 3. Responsibilities

### 3.1 Modules

| Module | Role | Tasks here |
|---|---|---|
| MOD-00 Shared domain models and interfaces | Owner of the folder and first drafts | 1 |
| MOD-01 App shell, navigation and platform services | Owner | 6 |
| MOD-05 Catalogue, search and home | Owner | 6 |
| MOD-06 Issue access and downloads | Owner | 10 |
| MOD-07 Reader | Owner | 7 |
| MOD-08 Bookmarks and favourites | Owner | 5 |
| MOD-09 News from WordPress | Owner | 4 |
| MOD-10 Sharing | Owner | 1 |
| MOD-15 CI and quality gates | Owner | 5 |
| MOD-16 Screen design and M2 prototype | Owner (Sanika Attarde owns three tasks) | 3 |
| MOD-17 Integration, testing and acceptance | Owner | 9 |
| MOD-20 Governance | Supporting (owns one review task) | 1 |
| MOD-02 to MOD-04, MOD-11 to MOD-14, MOD-18, MOD-19 | Supporting and reviewer | 0 (see the Sanika Attarde roadmap) |

### 3.2 Interfaces Yuvraj provides

The `app/lib/contracts/` folder and the first drafts of its files; the route table, guards and `AppNavigator`; `ConnectivityService`; `CatalogueRepository` and `applyQuery`; `DownloadManager`, `DownloadStatus` and `openLocal` (IC-03); `PdfRenderer` and `ReaderController`; `LibraryRepository`; `NewsRepository`; `ShareService`; the CI pipeline; test fixtures; the M2 prototype. Yuvraj writes the consumer checks for IC-01 to IC-07 and the device checks of IC-08.

### 3.3 Deliverables

The Flutter app's reader experience on Android and iOS; the reader test report for M2; the prototype; the CI pipeline; the M3 demo build, the M4 integration build, the internal test summary and the acceptance test build.

## 4. Prerequisites and Blockers

### 4.1 The first unblocker

DEC-013, DEC-014 and OQ-50 are PROPOSED. Until Sanika Attarde files a written agreement (MOD20-P1-T01), the Flutter scaffold and everything on it are spikes (`DECISION_LOG.md` §3.3 rule 4). The scaffold pull request itself can carry that agreement, as `DEVELOPMENT_ROADMAP.md` §4.1 proposes.

### 4.2 Required decisions and approvals

| Item | Blocks | Who answers | MFW approval |
|---|---|---|---|
| DEC-013, DEC-014, OQ-50 Riverpod, go_router, toolchain | MOD01-P1-T01 as final, and everything on it | Both developers | No |
| DEC-005, OQ-36 reader library | MOD07-P2-T01 and later | Both developers after the test; MFW at M2 | Yes, at M2 and for any paid licence |
| OQ-14 reader modes | MOD07-P2-T02 | Team, with MFW's approval | Yes |
| DEC-020, OQ-37 file delivery | MOD06-P2-T02, MOD06-P2-T03 | Both developers | Only if it adds cost |
| DEC-008, DEC-033, OQ-08 reading model | MOD06-P3-T01 | MFW | Yes |
| OQ-11 kept copies after sign-out, deletion, unpublishing | MOD06-P3-T02 | MFW | Yes |
| OQ-10 offline catalogue and library | MOD05-P2-T05, MOD08-P2-T04 | Team, with MFW's approval | Yes |
| OQ-12 favourites for incomplete access | MOD08-P2-T02 | MFW | Yes |
| OQ-13 public fields, segment and edition | MOD05-P2-T01, MOD05-P2-T02 | MFW | Yes |
| OQ-15 store link for sharing | MOD10-P1-T01 | MFW with the team | Yes |
| OQ-16, OQ-17, OQ-39 news offline, breaking, site | MOD09-* | MFW | Yes |
| OQ-25 accessibility baseline | MOD16-P1-*, MOD17-P3-T02 | MFW | Yes |
| OQ-26 devices and versions | MOD07-P3-T01, MOD17-P1-T02 | MFW with the team | Yes |
| DEC-022 CI service and cost | MOD15-* | Both developers; MFW if billed to MFW | Conditional |

### 4.3 External inputs (MFW)

Brand assets (logo, colours, fonts); two or three sample PDFs, including the largest expected issue, with an approved place to keep them (DEC-024); the WordPress site address and categories; test devices or an agreed device list; testers for acceptance. Sanika Attarde requests and tracks them (MOD20-P2-T04).

### 4.4 Dependencies on Sanika Attarde

| Needed from Sanika Attarde | For |
|---|---|
| MOD20-P1-T01 written agreement | Every non-spike task |
| MOD03-P1-T01 `AccessState` contract | MOD01-P2-T01 |
| MOD02-P1-T01 failure mapping and logger | Error states in every feature |
| MOD03-P2-T03 access state implementation | ICP-02 |
| MOD13-P1-T04 issue-file grant | MOD06-P2-T02, MOD06-P2-T03 (ICP-03) |
| MOD13-P1-T02 library rules | MOD08-P2-T03 (ICP-05) |
| MOD13-P1-T03 public reads; MOD12-P2-T03 publishing | MOD05-P2-T04 (ICP-04) |
| MOD12-P2-T04 news controls | MOD09-P2-T03 (ICP-06) |
| MOD11-P1-T01 payload; MOD11-P2-T01 push set-up | MOD01-P3-T01 (ICP-07) |
| MOD13-P1-T05 deleted-issue list | MOD06-P3-T02 |
| MOD03-P4-T01 deletion flow, which calls MOD-06's removal | The IC-08 device check in MOD06-P3-T02 (ICP-08) |
| MOD14-P2-T03 ENV-TEST; MOD14-P1-T01 configuration example | MOD01-P2-T04, MOD17-P2-T01 |
| MOD16-P1-T03, MOD16-P1-T04 screens | MOD16-P1-T05 |
| MOD16-P2-T01 M2 approval | Final screens in MOD05, MOD06, MOD07, MOD08, MOD09 |
| MOD18-P1-T02 signing | MOD15-P3-T01 |

### 4.5 Missing inputs and open technical questions

Resume on the candidate mechanism is unproven (AR-01). The team has no low-cost Android phone, older iPhone or tablet (R25), so AC-2 and AC-10 results on the S2 device set cannot yet be produced. GitHub Actions availability and macOS runner cost for this repository are NOT VERIFIED (DEC-022). The two-page spread needs a tablet or landscape test (FR-READ-009).

## 5. Implementation Roadmap

**Conventions.**

- Task IDs follow inventory section 5. "Parent" is the `DEVELOPMENT_ROADMAP.md` task, or "New".
- "Type: Shared (ICP-nn)" marks a task whose acceptance needs Sanika Attarde's work. Otherwise "Own".
- Every task's Definition of done includes DoD-TASK (`DEFINITION_OF_DONE.md` §5): reviewed by Sanika Attarde, tests in the same pull request, quality gates green where they exist, documentation updated, `CHANGELOG.md` line. Feature tasks also meet DoD-FEAT (§6). "Done when" adds only what is specific.
- A task that depends on an OPEN or PROPOSED decision is done as a spike until the decision is AGREED, and is not called done until then.
- MFW's confidential sample PDFs are never committed (DEC-024).

### Module MOD-00: Shared Domain Models and Interfaces

#### MOD00-P1 Contracts baseline

- Objective: one set of Dart models and interfaces both developers build against.
- Entry: MOD01-P1-T01 scaffold exists (as a spike if DEC-013 is not yet AGREED).
- Completion and handoff: ICP-01 accepted; Sanika Attarde takes over the WS-A files.
- Verification: contracts compile; fakes have unit tests.

**MOD00-P1-T01 Create the contracts folder, initial models and fakes**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: New (`DEVELOPMENT_ROADMAP.md` §4.1 item 2) · Type: Shared (ICP-01)
- Objective: `app/lib/contracts/` with the models of `API_AND_MODULE_CONTRACTS.md` §5 and their fakes.
- Steps: (1) Create `IssueSummary`, `IssueCategory`, `IssueFileGrant`, `DownloadedIssue`, `Bookmark`, `Favourite`, `NewsPost`, `NewsControl`, `NotificationTarget` and `NotificationPreferences`. (2) Draft `AccessState`, `Result` and `AppFailure` for Sanika Attarde to take over (VR-01). (3) Add fakes in `app/test/fakes/`. (4) Keep contracts free of Flutter UI and backend SDK imports (`CODING_STANDARDS.md` §3 rule 3).
- Dependencies: MOD01-P1-T01.
- Inputs: `API_AND_MODULE_CONTRACTS.md` §4, §5.
- Outputs: contract files; fakes; tests that name FR and AC IDs.
- Acceptance: everything compiles; both developers approve under the shared-file protocol.
- Tests: unit tests on fakes.
- Blocked by: DEC-013 (spike until AGREED).
- Done when: DoD-TASK; ICP-01 accepted.

### Module MOD-01: App Shell, Navigation and Platform Services

#### MOD01-P1 Scaffold

- Objective: an empty Flutter app that builds on both platforms with the agreed structure.
- Entry: none (spike); DEC-013, DEC-014 and OQ-50 AGREED for final.
- Completion and handoff: everyone builds features in the agreed folders.
- Verification: build output on an Android emulator and an iOS simulator.

**MOD01-P1-T01 Create the Flutter scaffold**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-01.1 · Type: Own
- Objective: `app/` as in `CODING_STANDARDS.md` §3, with Riverpod and go_router.
- Steps: (1) Pin the current stable Flutter and its matching Dart, and record them in `DEPENDENCY_REGISTER.md`. (2) Create the folders and feature layout. (3) Add Riverpod and go_router after their register entries. (4) Add `analysis_options.yaml`. (5) Ask Sanika Attarde to record agreement to DEC-013, DEC-014 and OQ-50 in the pull request.
- Dependencies: MOD14-P1-T01 (`.gitignore`) preferred, not required.
- Inputs: DEC-002, DEC-013, DEC-014; OQ-50.
- Outputs: `app/` scaffold.
- Acceptance: builds and runs on an Android emulator and an iOS simulator; `flutter analyze` and `dart format` are clean.
- Tests: command output in the pull request.
- Blocked by: DEC-013, DEC-014, OQ-50 (spike until AGREED).
- Done when: DoD-TASK.

#### MOD01-P2 Routes, theme, network and configuration

- Objective: the shell every feature plugs into.
- Entry: MOD01-P1-T01 and MOD00-P1-T01 merged; MOD03-P1-T01 merged for the guards.
- Completion and handoff: features register routes; IC-01 passes (ICP-02).
- Verification: guard unit tests; shell widget tests.

**MOD01-P2-T01 Route table, access guards and the not-found screen**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-03.4 (WS-B part) · Type: Shared (ICP-02)
- Objective: routes that open or download a full issue need `fullAccess`; other states go to sign-in, verification or profile completion (FR-AUTH-010, FR-PROF-004, BR-001 to BR-003).
- Steps: (1) Declare the routes of §6.1 in go_router. (2) Add a redirect that reads `watchAccessState`. (3) Add SCR-A-22 for unknown routes. (4) Write the IC-01 consumer check with FX-USR-01 to FX-USR-05.
- Dependencies: MOD03-P1-T01; MOD01-P1-T01.
- Inputs: DEC-007, DEC-014; IC-01.
- Outputs: router; guard tests; IC-01 check.
- Acceptance: each access state reaches the right screen; IC-01 passes against Sanika Attarde's implementation.
- Tests: unit tests for each guard decision; widget test of the shell.
- Blocked by: DEC-014 (spike until AGREED).
- Done when: DoD-FEAT; ICP-02 accepted.

**MOD01-P2-T02 Theme and branding**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-02.1 (part) · Type: Own
- Objective: MFW's logo, colours and fonts in one theme (NFR-UX-001), English only (NFR-UX-003).
- Steps: (1) Turn the design tokens (MOD16-P1-T01) into a Flutter theme. (2) Follow the device text size (OQ-25 proposed baseline).
- Dependencies: MOD16-P1-T01.
- Inputs: MFW brand assets.
- Outputs: theme code.
- Acceptance: matches the approved design.
- Tests: widget golden or screenshot comparison, recorded.
- Blocked by: MFW brand assets.
- Done when: DoD-TASK.

**MOD01-P2-T03 Connectivity service and HTTPS client**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: New (§6.1) · Type: Own
- Objective: connection type for the mobile-data warning (FR-DL-004) and an HTTP wrapper that allows HTTPS only (NFR-SEC-001).
- Steps: (1) Implement `ConnectivityService`. (2) Implement the HTTP wrapper with timeouts mapped to `FailureCode`. (3) Disable cleartext on both platforms with Sanika Attarde (shared platform folders).
- Dependencies: MOD02-P1-T01.
- Inputs: SEC-CHK-01.
- Outputs: `app/lib/core/network/`; tests.
- Acceptance: SEC-CHK-01 passes; connection types reported correctly.
- Tests: unit tests with fakes; manual check on a device.
- Blocked by: none.
- Done when: DoD-TASK.

**MOD01-P2-T04 App-side environment configuration**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: New (`DEPLOYMENT_PLAN.md` CFG) · Type: Own
- Objective: the app loads its non-secret values (CFG-03, CFG-04, CFG-07, CFG-08) per environment.
- Steps: (1) Read values from build-time configuration. (2) Provide ENV-LOCAL, ENV-TEST and ENV-PROD flavours. (3) Document them.
- Dependencies: MOD14-P1-T01.
- Inputs: CFG table.
- Outputs: `app/lib/core/config/`.
- Acceptance: switching environment needs no code change; no secret in the repository.
- Tests: unit tests.
- Blocked by: none.
- Done when: DoD-TASK.

#### MOD01-P3 Notification taps

- Objective: a tapped notification opens its issue or article with access rules applied.
- Entry: MOD11-P1-T01 merged.
- Completion and handoff: IC-05 passes (ICP-07).
- Verification: FX-NTF-01 to FX-NTF-08.

**MOD01-P3-T01 Route notification taps through `AppNavigator`**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-10.4 · Type: Shared (ICP-07)
- Objective: FR-NOTIF-005 and BR-005.
- Steps: (1) Implement `AppNavigator.openIssue` and `openArticle`. (2) Forward `watchOpened` targets. (3) Apply the guards. (4) Write the IC-05 check over FX-NTF-01 to FX-NTF-08.
- Dependencies: MOD11-P1-T01; MOD01-P2-T01.
- Inputs: IC-05.
- Outputs: code; IC-05 check.
- Acceptance: AC-9.3 and IC-05 pass.
- Tests: unit tests per payload; device test with a real push after MOD11-P2-T01.
- Blocked by: MFW's Apple account for the iOS device test.
- Done when: DoD-FEAT; ICP-07 accepted.

### Module MOD-05: Catalogue, Search and Home

#### MOD05-P1 Contract and data

- Objective: catalogue contract, fake and seeded issues so the screens can be built before the backend exists.
- Entry: MOD00-P1-T01 merged.
- Completion and handoff: fake and fixtures on `main`.
- Verification: unit tests.

**MOD05-P1-T01 `CatalogueRepository` contract, fake and twelve seeded issues**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-04.1 (part) · Type: Own
- Objective: a catalogue fake with twelve synthetic issues (NFR-STOR-002 upper bound).
- Steps: (1) Write the interface as in §6.5. (2) Write the fake. (3) Add twelve synthetic issues across categories, segments, years and editions.
- Dependencies: MOD00-P1-T01.
- Inputs: OQ-13 working position; DEC-024.
- Outputs: contract; fake; fixture data.
- Acceptance: the fake returns published issues only and never a file location.
- Tests: unit tests.
- Blocked by: DEC-013 (spike until AGREED).
- Done when: DoD-TASK.

#### MOD05-P2 Screens and behaviour

- Objective: the public catalogue, issue details, search, filters and home.
- Entry: MOD05-P1 done; M2 screens approved for final layout.
- Completion and handoff: IC-07 passes (ICP-04).
- Verification: AC-1.1 to AC-1.4, PAC-07.

**MOD05-P2-T01 Catalogue list and issue details**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-04.1 · Type: Own
- Objective: every user sees published issues with cover, title, date, description and category, and an issue details screen with Read and Download (FR-MAG-001 to FR-MAG-005).
- Steps: (1) Build SCR-A-11 and SCR-A-12. (2) Show the category on both (FR-MAG-003). (3) Show the actions by access state.
- Dependencies: MOD05-P1-T01; MOD16-P2-T01.
- Inputs: AC-1.1; OQ-13.
- Outputs: screens; tests.
- Acceptance: AC-1.1 passes; the candidate check for FR-MAG-003 passes.
- Tests: widget tests for loading, empty and error states.
- Blocked by: OQ-13 (public field list).
- Done when: DoD-FEAT.

**MOD05-P2-T02 Search and filters on the device**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-04.2 · Type: Own
- Objective: search by title, description and category, and filter by category, segment, year and edition, on metadata only (FR-SRCH-001 to FR-SRCH-007, DEC-030).
- Steps: (1) Implement `applyQuery`. (2) Build the search and filter controls. (3) Keep them available while signed out.
- Dependencies: MOD05-P2-T01.
- Inputs: AC-1.2, AC-1.3, PAC-07.
- Outputs: code; tests.
- Acceptance: AC-1.2, AC-1.3 and PAC-07 pass.
- Tests: unit tests for each filter and for search.
- Blocked by: OQ-13 (segment and edition meaning).
- Done when: DoD-FEAT.

**MOD05-P2-T03 Home screen**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-04.3 · Type: Own
- Objective: the home screen from the M2 design (FR-MAG-006).
- Steps: (1) Build SCR-A-10. (2) Link to the catalogue, latest issue and news.
- Dependencies: MOD05-P2-T01; MOD16-P2-T01.
- Inputs: approved design.
- Outputs: screen; tests.
- Acceptance: matches the approved design.
- Tests: widget tests.
- Blocked by: M2 approval.
- Done when: DoD-FEAT.

**MOD05-P2-T04 Refresh and publication changes**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-04.4 · Type: Shared (ICP-04)
- Objective: a published issue appears and an unpublished one disappears after pull-to-refresh, with no app update (FR-MAG-007, FR-MAG-008).
- Steps: (1) Add pull-to-refresh. (2) Show "no longer available" for an unpublished issue. (3) Write the IC-07 check.
- Dependencies: MOD05-P2-T01; MOD12-P2-T03; MOD13-P1-T03.
- Inputs: IC-07.
- Outputs: code; IC-07 check.
- Acceptance: AC-1.4, AC-8.7 and IC-07 pass.
- Tests: IC-07 in ENV-TEST.
- Blocked by: DEC-003 (through the backend).
- Done when: DoD-FEAT; ICP-04 accepted.

**MOD05-P2-T05 Catalogue offline behaviour**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: New (NFR-OFF-002, TD-20) · Type: Own
- Objective: whatever OQ-10 decides for the catalogue offline.
- Steps: (1) Cache the last catalogue if OQ-10 allows. (2) Show the offline notice.
- Dependencies: MOD05-P2-T04.
- Inputs: OQ-10; TD-20.
- Outputs: code; tests.
- Acceptance: behaviour matches the agreed answer to OQ-10.
- Tests: widget tests with the network off.
- Blocked by: OQ-10.
- Done when: DoD-FEAT.

### Module MOD-06: Issue Access and Downloads

#### MOD06-P1 Contract and resume spike

- Objective: the download contract with a fake transport, and evidence that resume works for a near-limit file.
- Entry: MOD00-P1-T01 merged.
- Completion and handoff: spike evidence handed to Sanika Attarde for DEC-020 and MOD13-P1-T04.
- Verification: fake-transport tests; spike report.

**MOD06-P1-T01 `DownloadManager` contract and a fake transport**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-06.2 (part) · Type: Own
- Objective: the §6.6 interface, `DownloadStatus`, and a transport fake that simulates breaks (FX-NET-*).
- Steps: (1) Write the interface and states. (2) Write a fake transport for each FX-NET scenario. (3) Keep the copy-kind parameter out until OQ-08 (§6.6 rule 5).
- Dependencies: MOD00-P1-T01.
- Inputs: §6.6; `TEST_DATA_AND_FIXTURES.md` FX-NET-*.
- Outputs: contract; fake; tests.
- Acceptance: every FX-NET scenario drives the expected status sequence.
- Tests: unit tests.
- Blocked by: DEC-013 (spike until AGREED).
- Done when: DoD-TASK.

**MOD06-P1-T02 Resume spike on a near-limit file**
- Owner: Yuvraj · Support: Sanika Attarde (server side) · Parent: T-02.4 · Type: Shared (ICP-03)
- Objective: show that a download of a file near 150 MB resumes after a network break without restarting (FR-DL-006, AR-01).
- Steps: (1) Generate a synthetic file near 150 MB. (2) Serve it with byte ranges, first from a local test server, then through the candidate mechanism when Sanika Attarde's spike allows. (3) Break the network mid-download and resume. (4) Re-request an expired grant and continue from the same offset. (5) Report.
- Dependencies: MOD06-P1-T01; MOD14-P1-T02 for the candidate mechanism.
- Inputs: TD-09; TD-11; DEC-020.
- Outputs: spike report.
- Acceptance: evidence that the download resumes from the bytes held, or a recorded failure that makes FR-DL-006 a requirement-level risk.
- Tests: the spike's own runs, recorded.
- Blocked by: none for the local test server; DEC-003 and DEC-020 for the real mechanism.
- Done when: report reviewed by Sanika Attarde.

#### MOD06-P2 Download pipeline

- Objective: an authorized, complete, verified copy in app-private storage, with every check S2 lists.
- Entry: MOD06-P1 done; MOD13-P1-T04 in ENV-TEST for real downloads.
- Completion and handoff: IC-02 passes (ICP-03).
- Verification: AC-4.1, AC-4.3 to AC-4.7.

**MOD06-P2-T01 Download preparation: size, mobile data and free space**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-06.2 · Type: Own
- Objective: show the size first, warn on mobile data and refuse when storage is short (FR-DL-003, FR-DL-004, FR-STATE-004).
- Steps: (1) Implement `prepare`. (2) Build SCR-A-13's prompt. (3) Show the low-storage state.
- Dependencies: MOD06-P1-T01; MOD01-P2-T03.
- Inputs: AC-4.4, AC-4.5.
- Outputs: code; tests.
- Acceptance: AC-4.4 and AC-4.5 pass.
- Tests: unit and widget tests.
- Blocked by: none.
- Done when: DoD-FEAT.

**MOD06-P2-T02 Download with progress through the grant**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-06.2 · Type: Shared (ICP-03)
- Objective: download to app-private storage with progress, only with a grant from OP-11 (FR-DL-001, FR-DL-002, FR-DL-005, NFR-SEC-004).
- Steps: (1) Request the grant. (2) Map refused states to prompts. (3) Download into app-private storage. (4) Show progress. (5) Write the IC-02 check.
- Dependencies: MOD06-P2-T01; MOD13-P1-T04.
- Inputs: IC-02; SEC-CHK-04.
- Outputs: code; IC-02 check.
- Acceptance: AC-4.1, SEC-CHK-04 and IC-02 pass.
- Tests: unit tests with the fake; IC-02 in ENV-TEST.
- Blocked by: DEC-020; DEC-003.
- Done when: DoD-FEAT; ICP-03 accepted.

**MOD06-P2-T03 Resume after a network break**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-06.3 · Type: Shared (ICP-03)
- Objective: a stopped download resumes from the bytes held, in the foreground only (FR-DL-006, DEC-020 position of 27 October 2026).
- Steps: (1) Move to `WaitingForNetwork` on a break. (2) Continue from `receivedBytes`. (3) Re-request an expired grant. (4) Resume the next time the app is open if the reader left.
- Dependencies: MOD06-P2-T02; MOD06-P1-T02.
- Inputs: AC-4.3; FX-NET-*; OQ-54.
- Outputs: code; tests.
- Acceptance: AC-4.3 passes with the near-limit file.
- Tests: unit tests with breaks; device test with airplane mode.
- Blocked by: DEC-020; OQ-54 for background behaviour.
- Done when: DoD-FEAT.

**MOD06-P2-T04 Integrity check and failed-download handling**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-06.4 · Type: Own
- Objective: a partial or mismatched file is never listed and gives a retry (FR-STATE-006, FR-READ-010).
- Steps: (1) Check size and `contentHash` after transfer. (2) Delete on mismatch and report `fileCorrupt`. (3) Repair partial files at app start (`PDF_READER_AND_OFFLINE_DESIGN.md` §4.4).
- Dependencies: MOD06-P2-T02.
- Inputs: §6.6 rules 3 and 4.
- Outputs: code; tests.
- Acceptance: PAC-10 failed-download row passes; no partial file listed.
- Tests: unit tests with corrupted fixtures.
- Blocked by: none.
- Done when: DoD-FEAT.

**MOD06-P2-T05 Downloads screen and deletion**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-06.4 · Type: Own
- Objective: list kept copies, open them offline, and delete one to free its space (FR-DL-008, FR-DL-009, NFR-OFF-001).
- Steps: (1) Build SCR-A-15. (2) Implement `delete` and `listDownloaded`. (3) Make the screen work with no network.
- Dependencies: MOD06-P2-T04.
- Inputs: AC-4.6, AC-4.7.
- Outputs: screen; tests.
- Acceptance: AC-4.6 and AC-4.7 pass.
- Tests: widget tests; device storage check.
- Blocked by: none.
- Done when: DoD-FEAT.

#### MOD06-P3 Copy kinds, lifecycle and offline opening

- Objective: the Read and Download behaviour and the kept-copy rules, once MFW answers.
- Entry: MOD06-P2 done.
- Completion and handoff: IC-03 passes; IC-08 device checks pass (ICP-08).
- Verification: AC-4.2, PAC-14, PAC-20.

**MOD06-P3-T01 Read and Download copy kinds (pending OQ-08)**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-06.5 (part) · Type: Own
- Objective: on the working position, Read opens a temporary complete copy removed when the reader leaves, and Download keeps it (DEC-033).
- Steps: (1) Add the copy kind to `start` once OQ-08 is answered. (2) Remove temporary copies on leaving, and at the next start after a crash. (3) Decide with Sanika Attarde the two cases DEC-033 leaves open.
- Dependencies: MOD06-P2-T05.
- Inputs: DEC-033; `PDF_READER_AND_OFFLINE_DESIGN.md` §4.
- Outputs: code; tests.
- Acceptance: PAC-20 passes for the answer MFW gives.
- Tests: unit tests of the state machine; device test.
- Blocked by: **OQ-08 (MFW's written answer; two unfiled reports conflict)**.
- Done when: DoD-FEAT.

**MOD06-P3-T02 Kept-copy lifecycle after sign-out, deletion and unpublishing**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-06.5 · Type: Shared (ICP-08)
- Objective: FR-DL-010 as OQ-11 decides. Working position: sign-out hides kept copies until the same reader signs in; account deletion removes them; unpublishing leaves them; permanent deletion removes them when OP-03 lists the issue.
- Steps: (1) Implement each rule behind a removal call that the account-deletion and sign-out flows can use. (2) Read OP-03 when online. (3) Write the IC-08 device check.
- Dependencies: MOD06-P2-T05; MOD13-P1-T05.
- Inputs: OQ-11; PAC-14; IC-08.
- Outputs: code; IC-08 device check.
- Acceptance: PAC-14 passes; the IC-08 device part passes once Sanika Attarde's deletion flow (MOD03-P4-T01) calls the removal.
- Tests: unit tests per rule; integration test.
- Blocked by: OQ-11; OQ-21 for permanent deletion.
- Done when: DoD-FEAT; ICP-08 device check accepted.

**MOD06-P3-T03 Offline opening and `openLocal`**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-06.5 · Type: Own
- Objective: a downloaded issue opens in full with no network, and `openLocal` returns only complete, verified files (FR-DL-007, IC-03).
- Steps: (1) Implement `openLocal`. (2) Hand the file to MOD-07. (3) Write the IC-03 check.
- Dependencies: MOD06-P2-T04; MOD07-P2-T01.
- Inputs: IC-03; AC-4.2.
- Outputs: code; IC-03 check.
- Acceptance: AC-4.2 and IC-03 pass.
- Tests: device test in airplane mode.
- Blocked by: DEC-005 (through MOD-07).
- Done when: DoD-FEAT.

### Module MOD-07: Reader

#### MOD07-P1 Reader test

- Objective: choose a library on evidence and give MFW the reader result at M2 (S2 M2).
- Entry: none for the spike; MFW's sample PDFs and an approved place to keep them for the test.
- Completion and handoff: report to Sanika Attarde for the M2 presentation (ICP-09); DEC-005 PROPOSED.
- Verification: measured results against AC-2.

**MOD07-P1-T01 Compare candidate reader libraries**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-02.3 (spike part) · Type: Own
- Objective: an early comparison of candidates (pdfrx and pdfx named in `DEVELOPMENT_ROADMAP.md` §4.1), including licences.
- Steps: (1) On a spike branch, open public website PDFs and a generated 150 MB, 120-page PDF in each candidate. (2) Measure first-page time, sharpness at 300% and 20 page turns on the mid-range Android phone and the current iPhone. (3) Record each licence. (4) Report. Do not use MFW's confidential samples here.
- Dependencies: MOD01-P1-T01.
- Inputs: AC-2; NFR-MAINT-006; `PDF_READER_AND_OFFLINE_DESIGN.md` §7, §9.
- Outputs: spike report.
- Acceptance: each candidate measured on both phones, with its licence recorded.
- Tests: the spike's measured runs.
- Blocked by: none (spike).
- Done when: report reviewed by Sanika Attarde.

**MOD07-P1-T02 Reader test on MFW's sample PDFs**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-02.3 · Type: Shared (ICP-09)
- Objective: the S2 M2 reader result on MFW's own PDFs.
- Steps: (1) Run the MOD07-P1-T01 measurements on MFW's samples. (2) Write the reader test report. (3) Propose DEC-005 and any change to the AC-2 targets with MFW (S2 AC-2).
- Dependencies: MOD07-P1-T01.
- Inputs: MFW's sample PDFs; OQ-26.
- Outputs: reader test report.
- Acceptance: report filed; DEC-005 PROPOSED; AC-2 targets confirmed or adjusted with MFW.
- Tests: measured runs on the available devices; the missing devices recorded as a limit (R25).
- Blocked by: MFW sample PDFs; MFW's approval of where they are kept (DEC-024); OQ-26 devices.
- Done when: report delivered for MOD16-P2-T01.

#### MOD07-P2 Reader features

- Objective: every S2 reader feature behind `PdfRenderer`.
- Entry: DEC-005 AGREED after the M2 test; MOD06-P3-T03 or a local fixture file for opening.
- Completion and handoff: IC-03 passes with MOD-06.
- Verification: AC-2.2 to AC-2.4, AC-2.6, AC-2.7.

**MOD07-P2-T01 Integrate the chosen library behind `PdfRenderer`**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-05.1 · Type: Own
- Objective: the chosen library wrapped so it can change without touching other modules.
- Steps: (1) Add the `DEPENDENCY_REGISTER.md` entry. (2) Implement `PdfRenderer` and `PdfDocumentHandle`. (3) Open FX-PDF-01 to FX-PDF-04.
- Dependencies: MOD07-P1-T02.
- Inputs: DEC-005; §6.7.
- Outputs: `app/lib/features/reader/`.
- Acceptance: opens FX-PDF-01 to FX-PDF-04.
- Tests: widget tests with fixtures.
- Blocked by: DEC-005.
- Done when: DoD-TASK.

**MOD07-P2-T02 Page-turn and swipe modes**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-05.2 · Type: Own
- Objective: swipe and tap page turns, the page-turn effect and the plain swipe fallback, with a remembered mode switch (FR-READ-003, FR-READ-004, FR-READ-006 to FR-READ-008).
- Steps: (1) Implement both modes. (2) Open in page-turn mode and allow switching in settings (OQ-14 working position). (3) Remember the choice on the device. (4) Build SCR-A-14.
- Dependencies: MOD07-P2-T01; MOD04-P2-T04 for the settings entry.
- Inputs: AC-2.2, AC-2.7.
- Outputs: code; tests.
- Acceptance: AC-2.2 and AC-2.7 pass.
- Tests: widget tests of controls.
- Blocked by: OQ-14.
- Done when: DoD-FEAT.

**MOD07-P2-T03 Zoom to 300% and the two-page spread**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-05.3 · Type: Own
- Objective: pinch zoom to 300% with sharp text, and two pages on tablets and in landscape (FR-READ-005, FR-READ-009, NFR-COMP-002).
- Steps: (1) Render at a resolution that keeps text sharp at 300%. (2) Show two pages when width allows.
- Dependencies: MOD07-P2-T01.
- Inputs: AC-2.3, AC-2.4.
- Outputs: code; tests.
- Acceptance: AC-2.3 and AC-2.4 pass.
- Tests: device tests in portrait and landscape; a tablet test when one is available.
- Blocked by: a tablet for the full AC-2.4 check (R25).
- Done when: DoD-FEAT.

**MOD07-P2-T04 Damaged-file handling**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-05.4 · Type: Own
- Objective: a damaged file shows an error with a retry (FR-READ-010).
- Steps: (1) Return `fileCorrupt` from `open`. (2) Offer a retry that re-downloads through MOD-06.
- Dependencies: MOD07-P2-T01.
- Inputs: FX-PDF-10, FX-PDF-11; AC-2.6.
- Outputs: code; tests.
- Acceptance: AC-2.6 passes.
- Tests: widget tests with damaged fixtures.
- Blocked by: none.
- Done when: DoD-FEAT.

#### MOD07-P3 Performance

- Objective: the AC-2 targets on the agreed devices.
- Entry: MOD07-P2 done; device set agreed (MOD17-P1-T02).
- Completion and handoff: results recorded for MOD17-P3-T02.
- Verification: AC-2.1, AC-2.3, AC-2.5.

**MOD07-P3-T01 Tune and measure reader performance**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-05.5 · Type: Own
- Objective: first page within 3 seconds on the mid-range test phone, sharp text at 300%, twenty page turns without a crash (NFR-PERF-001, NFR-PERF-002, NFR-REL-001).
- Steps: (1) Measure on each agreed device with the largest sample and the near-limit file. (2) Tune caching and render resolution. (3) Record results.
- Dependencies: MOD07-P2-T02; MOD07-P2-T03; MOD17-P1-T02.
- Inputs: AC-2; FX-PDF-04, FX-PDF-05.
- Outputs: measurement record.
- Acceptance: AC-2.1, AC-2.3 and AC-2.5 pass on the agreed devices.
- Tests: device measurements, recorded.
- Blocked by: OQ-26 devices (R25).
- Done when: DoD-FEAT; results attached to MOD17-P3-T02.

### Module MOD-08: Bookmarks and Favourites

#### MOD08-P1 Contract

- Objective: the library contract and fake.
- Entry: MOD00-P1-T01 merged.
- Completion and handoff: fake on `main`.
- Verification: unit tests.

**MOD08-P1-T01 `LibraryRepository` contract and fake**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-07.2 (part) · Type: Own
- Objective: the §6.8 interface with a fake.
- Steps: (1) Write the interface. (2) Write the fake, with idempotent `setFavourite`.
- Dependencies: MOD00-P1-T01.
- Inputs: §6.8.
- Outputs: contract; fake.
- Acceptance: the fake supports add, remove, list and favourite.
- Tests: unit tests.
- Blocked by: DEC-013 (spike until AGREED).
- Done when: DoD-TASK.

#### MOD08-P2 Features

- Objective: bookmarks and favourites stored with the account, private, on a second device.
- Entry: MOD08-P1 done; MOD13-P1-T02 in ENV-TEST.
- Completion and handoff: IC-04 passes (ICP-05).
- Verification: AC-5.1 to AC-5.4.

**MOD08-P2-T01 Bookmarks**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-07.2 · Type: Own
- Objective: add a bookmark from the reader, list bookmarks, open at the page, remove one (FR-BKM-001, FR-BKM-002, FR-BKM-006, FR-BKM-007).
- Steps: (1) Add the bookmark action to the reader. (2) Build SCR-A-16. (3) Open the reader at the bookmarked page. (4) Remove.
- Dependencies: MOD08-P1-T01; MOD07-P2-T01.
- Inputs: AC-5.1.
- Outputs: code; tests.
- Acceptance: AC-5.1 passes; the candidate check for FR-BKM-007 passes.
- Tests: widget tests; integration test.
- Blocked by: DEC-003 (through the backend).
- Done when: DoD-FEAT.

**MOD08-P2-T02 Favourites**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-07.3 · Type: Own
- Objective: mark and unmark favourites, updating at once (FR-BKM-003).
- Steps: (1) Add the favourite control. (2) Build SCR-A-17. (3) Apply OQ-12's answer for incomplete access.
- Dependencies: MOD08-P1-T01.
- Inputs: AC-5.2.
- Outputs: code; tests.
- Acceptance: AC-5.2 passes.
- Tests: widget tests.
- Blocked by: OQ-12.
- Done when: DoD-FEAT.

**MOD08-P2-T03 Second device, isolation and deletion**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-07.4 · Type: Shared (ICP-05, ICP-08)
- Objective: items appear on a second device, readers cannot see each other's, and nothing is left after account deletion (FR-BKM-004, FR-BKM-005).
- Steps: (1) Write the IC-04 check with two readers and two devices. (2) Check local library data is cleared after deletion (IC-08 device part).
- Dependencies: MOD08-P2-T01; MOD08-P2-T02; MOD13-P1-T02.
- Inputs: IC-04; IC-08.
- Outputs: IC-04 check; IC-08 device check.
- Acceptance: AC-5.3, AC-5.4, SEC-CHK-05 and IC-04 pass.
- Tests: integration tests.
- Blocked by: DEC-003.
- Done when: DoD-FEAT; ICP-05 accepted.

**MOD08-P2-T04 Offline bookmarks and favourites**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: New (FR-BKM-008, TD-20) · Type: Own
- Objective: whatever OQ-10 decides for viewing and changing the library offline.
- Steps: (1) Cache and queue writes if OQ-10 allows. (2) Test synchronisation.
- Dependencies: MOD08-P2-T03.
- Inputs: OQ-10; TD-20.
- Outputs: code; tests.
- Acceptance: behaviour matches the agreed answer to OQ-10.
- Tests: tests with the network off and back on.
- Blocked by: OQ-10.
- Done when: DoD-FEAT.

### Module MOD-09: News from WordPress

#### MOD09-P1 WordPress client

- Objective: a tested WordPress client that can run before the site details arrive.
- Entry: MOD00-P1-T01 merged.
- Completion and handoff: fixtures and client on `main`.
- Verification: fixture tests; one recorded live read.

**MOD09-P1-T01 WordPress client and fixtures**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-08.1 · Type: Own
- Objective: read posts, one post and categories over HTTPS, in small pages, from MFW-selected categories only (INT-WP-001, INT-WP-003 to INT-WP-005).
- Steps: (1) Implement `NewsRepository` against the WordPress REST routes in §9.1. (2) Add FX-WP fixtures. (3) Record one live read of MFW's public API without storing content.
- Dependencies: MOD00-P1-T01; MOD01-P2-T03.
- Inputs: OQ-39; CFG-03, CFG-04.
- Outputs: client; fixtures; tests.
- Acceptance: fixture tests pass; one live read recorded.
- Tests: unit tests with fixtures.
- Blocked by: OQ-39 for the live read only.
- Done when: DoD-TASK.

#### MOD09-P2 News screens and controls

- Objective: the news list, articles, filters, offline reading and controls.
- Entry: MOD09-P1 done; M2 screens approved.
- Completion and handoff: IC-06 passes (ICP-06).
- Verification: AC-7.1 to AC-7.5, AC-8.8.

**MOD09-P2-T01 News list, article page and category filter**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-08.2 · Type: Own
- Objective: FR-NEWS-001 to FR-NEWS-004 and FR-NEWS-007, with the WordPress-unreachable state (FR-STATE-005).
- Steps: (1) Build SCR-A-18 and SCR-A-19. (2) Render article HTML without scripts (SEC-CHK-15). (3) Add the category filter and refresh. (4) Show the unreachable state.
- Dependencies: MOD09-P1-T01; MOD16-P2-T01.
- Inputs: AC-7.1, AC-7.2, AC-7.3, AC-7.5.
- Outputs: screens; tests.
- Acceptance: those AC rows and SEC-CHK-15 pass.
- Tests: widget tests with fixtures.
- Blocked by: OQ-39 for live data.
- Done when: DoD-FEAT.

**MOD09-P2-T02 Offline articles and Save**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-08.3 · Type: Own
- Objective: loaded articles readable offline with a notice; a Save button keeps an article (FR-NEWS-005, FR-NEWS-006, OQ-16 working position).
- Steps: (1) Cache recently opened articles with rotation. (2) Add Save and removal. (3) Show the offline notice.
- Dependencies: MOD09-P2-T01.
- Inputs: AC-7.4; OQ-16.
- Outputs: code; tests.
- Acceptance: AC-7.4 passes.
- Tests: tests with the network off.
- Blocked by: OQ-16 (number kept, media handling).
- Done when: DoD-FEAT.

**MOD09-P2-T03 Apply hidden and breaking controls**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-08.4 · Type: Shared (ICP-06)
- Objective: hidden posts disappear and breaking posts are shown as OQ-17 decides (FR-NEWS-008, FR-NEWS-009).
- Steps: (1) Read controls through OP-04. (2) Filter hidden posts. (3) Mark breaking posts. (4) Write the IC-06 check.
- Dependencies: MOD09-P2-T01; MOD12-P2-T04.
- Inputs: IC-06; OQ-17.
- Outputs: code; IC-06 check.
- Acceptance: AC-8.8 and IC-06 pass.
- Tests: IC-06 in ENV-TEST.
- Blocked by: OQ-17 for the breaking presentation; DEC-003.
- Done when: DoD-FEAT; ICP-06 accepted.

### Module MOD-10: Sharing

#### MOD10-P1 Share sheet

- Objective: share issues and articles with a title and link.
- Entry: MOD05-P2-T01 and MOD09-P2-T01 merged.
- Completion and handoff: none.
- Verification: AC-6.1, AC-6.2, PAC-05.

**MOD10-P1-T01 Share an issue or an article**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-08.5 · Type: Own
- Objective: FR-SHR-001 to FR-SHR-006: title and store link for an issue, title and WordPress address for an article, never the PDF, no app links.
- Steps: (1) Implement `ShareService`. (2) Read store links from CFG-08. (3) Add share actions to issue details and the article page.
- Dependencies: MOD05-P2-T01; MOD09-P2-T01.
- Inputs: OQ-15; OQ-09.
- Outputs: code; tests.
- Acceptance: AC-6.1, AC-6.2 and PAC-05 pass; the shared content never includes a file.
- Tests: unit tests of the shared text; manual share on both platforms.
- Blocked by: OQ-15; OQ-09 for logged-out sharing.
- Done when: DoD-FEAT.

### Module MOD-15: CI and Quality Gates

#### MOD15-P1 CI skeleton

- Objective: checks on every pull request from the first app code.
- Entry: MOD01-P1-T01 merged.
- Completion and handoff: QG-01 to QG-06 run on pull requests.
- Verification: a pull request shows the checks.

**MOD15-P1-T01 Verify GitHub Actions availability and macOS runner cost**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-01.5 (part) · Type: Own
- Objective: settle what DEC-022 leaves NOT VERIFIED.
- Steps: (1) Check the account plan and repository visibility. (2) Record runner minutes and macOS cost. (3) Tell Sanika Attarde if any cost would fall to MFW.
- Dependencies: none.
- Inputs: DEC-022.
- Outputs: a recorded finding in `CI_CD_AND_QUALITY_GATES.md` by pull request.
- Acceptance: availability and cost recorded with their source.
- Tests: none.
- Blocked by: none.
- Done when: DoD-DOC.

**MOD15-P1-T02 CI skeleton with QG-01 to QG-06**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-01.5 · Type: Own
- Objective: formatting, analysis, unit and widget tests, coverage report, and Android and iOS build checks on each pull request.
- Steps: (1) Add `.github/` workflows. (2) Run QG-01 to QG-06. (3) Make QG-01 to QG-03 required, as `CI_CD_AND_QUALITY_GATES.md` proposes.
- Dependencies: MOD15-P1-T01; MOD01-P1-T01.
- Inputs: `CI_CD_AND_QUALITY_GATES.md`.
- Outputs: workflows.
- Acceptance: checks run on a pull request.
- Tests: a test pull request with a failing format check.
- Blocked by: DEC-022 (spike until AGREED).
- Done when: DoD-TASK.

#### MOD15-P2 Further gates

- Objective: licence, secrets and documentation checks, then integration, rule and admin gates.
- Entry: MOD15-P1 done.
- Completion and handoff: Sanika Attarde's suites run in CI.
- Verification: each gate runs on a pull request.

**MOD15-P2-T01 Licence, secrets and documentation checks**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: New (QG-10 to QG-12) · Type: Own
- Objective: QG-10 dependency and licence check, QG-11 secrets scan, QG-12 documentation checks.
- Steps: (1) Add each gate. (2) Tune false positives. (3) Document how to run each locally.
- Dependencies: MOD15-P1-T02.
- Inputs: SEC-CHK-09, SEC-CHK-13; NFR-MAINT-006.
- Outputs: workflows.
- Acceptance: each gate runs; QG-11 fails on a planted test secret.
- Tests: test pull requests.
- Blocked by: DEC-022.
- Done when: DoD-TASK.

**MOD15-P2-T02 Integration, rule and admin gates**
- Owner: Yuvraj · Support: Sanika Attarde (suites) · Parent: New (QG-07 to QG-09) · Type: Shared (ICP-11)
- Objective: QG-07 app integration tests, QG-08 backend rule tests, QG-09 admin panel build and tests.
- Steps: (1) Run integration tests on an emulator in CI. (2) Run Sanika Attarde's rule suite on the emulator. (3) Build and test `admin/`.
- Dependencies: MOD15-P1-T02; MOD13-P1-T01; MOD12-P1-T01.
- Inputs: `CI_CD_AND_QUALITY_GATES.md`.
- Outputs: workflows.
- Acceptance: all three gates run on a pull request.
- Tests: test pull requests.
- Blocked by: DEC-003; DEC-004.
- Done when: DoD-TASK.

#### MOD15-P3 Release pipeline

- Objective: signed builds from a release tag.
- Entry: MOD18-P1-T01 identifiers exist.
- Completion and handoff: Sanika Attarde builds the release from a tag (MOD18-P1-T02).
- Verification: QG-13.

**MOD15-P3-T01 Release workflow (QG-13)**
- Owner: Yuvraj · Support: Sanika Attarde (signing) · Parent: T-12.2 (pipeline part) · Type: Shared (ICP-12)
- Objective: a workflow that builds signed Android and iOS releases from a `vMAJOR.MINOR.PATCH` tag (DEC-015).
- Steps: (1) Trigger on release tags. (2) Read signing material from MFW-held secrets, never from the repository. (3) Produce build artefacts.
- Dependencies: MOD15-P1-T02; MOD18-P1-T01.
- Inputs: QG-13; AC-11.1.
- Outputs: workflow.
- Acceptance: a tag produces signed builds once Sanika Attarde connects the signing.
- Tests: a dry run with test signing.
- Blocked by: signing set-up in MFW's accounts.
- Done when: DoD-TASK; ICP-12 pipeline part accepted.

### Module MOD-16: Screen Design and M2 Prototype

#### MOD16-P1 Designs and prototype

- Objective: every in-scope screen and state, on MFW's branding, in one interactive prototype (S2 M2, NFR-UX-001, NFR-UX-002).
- Entry: MFW brand assets received. Content questions answered or working positions used (OQ-01, OQ-13, OQ-16, OQ-17).
- Completion and handoff: prototype ready for Sanika Attarde's M2 presentation (ICP-09).
- Verification: review against `SCREEN_INVENTORY_AND_NAVIGATION.md`. Sanika Attarde's tasks in this phase: MOD16-P1-T03 and MOD16-P1-T04.

**MOD16-P1-T01 Design tokens from MFW's brand**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-02.1 (part) · Type: Own
- Objective: colours, type and spacing tokens both developers draw with.
- Steps: (1) Extract tokens from MFW's logo, colours and fonts. (2) Check contrast against the proposed accessibility baseline (OQ-25). (3) Share.
- Dependencies: none.
- Inputs: MFW brand assets.
- Outputs: token set.
- Acceptance: Sanika Attarde can draw the account, settings, notification and admin screens with it.
- Tests: contrast check, recorded.
- Blocked by: MFW brand assets; OQ-25.
- Done when: tokens shared.

**MOD16-P1-T02 Reader-experience screens**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-02.1 (part) · Type: Own
- Objective: designs for SCR-A-10 to SCR-A-19 and SCR-A-22, with loading, empty, no-network, low-storage, failed-download and WordPress-unreachable states (FR-STATE-001 to FR-STATE-006). SCR-A-23 is not drawn.
- Steps: (1) Draw each screen and state. (2) Draw the Read and Download actions as the working position, marked pending OQ-08.
- Dependencies: MOD16-P1-T01.
- Inputs: `SCREEN_INVENTORY_AND_NAVIGATION.md`; OQ-13; OQ-16; OQ-17.
- Outputs: designs.
- Acceptance: every listed screen and state drawn; PAC-10 states covered.
- Tests: review against the inventory.
- Blocked by: MFW brand assets.
- Done when: reviewed by Sanika Attarde.

**MOD16-P1-T05 Assemble the interactive prototype**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-02.1 · Type: Shared (ICP-09)
- Objective: one prototype covering every in-scope screen and state (RS ASM-13).
- Steps: (1) Combine MOD16-P1-T02, MOD16-P1-T03 and MOD16-P1-T04. (2) Link the flows. (3) Check against the screen inventory.
- Dependencies: MOD16-P1-T02; MOD16-P1-T03; MOD16-P1-T04.
- Inputs: `DEVELOPMENT_ROADMAP.md` §5 M2 exit checks.
- Outputs: prototype.
- Acceptance: covers every in-scope screen and state.
- Tests: walk-through against the inventory, recorded.
- Blocked by: MFW brand assets.
- Done when: handed to Sanika Attarde for MOD16-P2-T01.

#### MOD16-P2 M2 approval

- Objective: MFW's written approval of the screens and reader approach.
- Entry: MOD16-P1-T05 and MOD07-P1-T02 done.
- Completion and handoff: final screens are fixed; changes after this are change requests (CHG-02).
- Verification: filed approval. Task: MOD16-P2-T01, owned by Sanika Attarde.

### Module MOD-17: Integration, Testing and Acceptance

#### MOD17-P1 Test foundations

- Objective: fixtures, an agreed device set and clean coverage records before features land.
- Entry: none.
- Completion and handoff: fixtures usable by both developers.
- Verification: fixture tests; recorded device list.

**MOD17-P1-T01 Build the test fixtures**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: New (`TEST_DATA_AND_FIXTURES.md`) · Type: Own
- Objective: FX-USR, FX-PDF (generated), FX-NET, FX-WP, FX-NTF and FX-ADM fixtures, all synthetic (DEC-024).
- Steps: (1) Create each fixture family. (2) Generate PDFs, including a near-limit and damaged ones. (3) Keep MFW's samples outside Git. (4) Keep test credentials out of the repository.
- Dependencies: MOD01-P1-T01.
- Inputs: `TEST_DATA_AND_FIXTURES.md`; DEC-024.
- Outputs: fixtures; README on their use.
- Acceptance: every fixture named in the AC and PAC rows exists or is listed as waiting.
- Tests: fixtures load in a unit test.
- Blocked by: none.
- Done when: DoD-TASK.

**MOD17-P1-T02 Agree the test device set**
- Owner: Yuvraj · Support: Sanika Attarde (sends it to MFW) · Parent: New (OQ-26, S2 AC-10) · Type: Own
- Objective: a written device and version list for AC-10, and a plan for the devices the team lacks (R25).
- Steps: (1) Propose minimum Android and iOS versions and models. (2) List what the team has and lacks. (3) Ask MFW through Sanika Attarde to agree the list or supply devices.
- Dependencies: none.
- Inputs: OQ-26; NFR-COMP-003, NFR-COMP-004.
- Outputs: device list recorded in `TESTING_STRATEGY.md` §6 by pull request.
- Acceptance: MFW's written agreement filed.
- Tests: none.
- Blocked by: MFW's answer to OQ-26.
- Done when: DoD-DOC.

**MOD17-P1-T03 Close the coverage gaps and regenerate the matrix**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: New (RC-01 to RC-04, VR-05) · Type: Own
- Objective: every requirement that RS expects to test has a row or a planned check.
- Steps: (1) Propose rows for the eight AREA ONLY and NO ROW requirements. (2) Name the RS CLAIM requirements in their rows. (3) Regenerate `REQUIREMENT_COVERAGE_MATRIX.md`, removing the withdrawn OP-13.
- Dependencies: none.
- Inputs: `REQUIREMENT_COVERAGE_MATRIX.md` §6.
- Outputs: documentation pull request; new PAC rows proposed for MFW.
- Acceptance: no requirement left in AREA ONLY or NO ROW without a proposed check.
- Tests: none.
- Blocked by: MFW's written approval for any new PAC row.
- Done when: DoD-DOC.

#### MOD17-P2 M3 demo

- Objective: the S2 M3 condition on Android and iOS test devices.
- Entry: MOD03-P2, MOD05-P2-T01, MOD06-P2-T02 and MOD07-P2-T01 in ENV-TEST.
- Completion and handoff: demo build to Sanika Attarde for MFW (ICP-10).
- Verification: end-to-end run, recorded.

**MOD17-P2-T01 End-to-end M3 flow and demo build**
- Owner: Yuvraj · Support: Sanika Attarde (backend deploy) · Parent: New (S2 M3) · Type: Shared (ICP-10)
- Objective: a tester signs up, logs in, browses the catalogue and opens an issue in the reader on the demo build.
- Steps: (1) Write the integration test for the flow in `app/integration_test/`. (2) Build Android and iOS test builds against ENV-TEST. (3) Run on the test devices. (4) Record.
- Dependencies: MOD03-P2-T03; MOD05-P2-T01; MOD06-P2-T02; MOD07-P2-T01; MOD14-P2-T03.
- Inputs: S2 M3.
- Outputs: integration test; demo builds; run record.
- Acceptance: the flow passes on both platforms.
- Tests: the integration test (QG-07).
- Blocked by: DEC-003; DEC-005; DEC-020.
- Done when: DoD-INT for the demo build; ICP-10 accepted when MFW's approval is filed.

#### MOD17-P3 M4, regression and acceptance

- Objective: the S2 M4 build, test summary and acceptance testing.
- Entry: all feature modules meet DoD-FEAT.
- Completion and handoff: MFW signs off acceptance; MOD-18 submits.
- Verification: results for every AC and PAC row.

**MOD17-P3-T01 Feature freeze and the M4 integration build**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-11.1 · Type: Shared (ICP-11)
- Objective: a build cut from `main` with every IC passing (DoD-INT).
- Steps: (1) Announce the freeze. (2) Run IC-01 to IC-08. (3) Cut the build.
- Dependencies: every IC check task.
- Inputs: `DEFINITION_OF_DONE.md` §7.
- Outputs: M4 build; IC run record.
- Acceptance: every IC passes.
- Tests: full IC run.
- Blocked by: every blocker of the feature tasks.
- Done when: DoD-INT; ICP-11 accepted.

**MOD17-P3-T02 Full regression on the agreed devices**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-11.2 · Type: Own
- Objective: results for every criterion in `ACCEPTANCE_CRITERIA.md` on the agreed devices (S2 AC-10).
- Steps: (1) Run each AC and PAC row. (2) Run the candidate checks from MOD17-P1-T03, including NFR-STOR-001 and NFR-STOR-002. (3) Inspect the negative requirements (FR-EMAIL-003, FR-USER-004, FR-SHR-005, BR-004). (4) Log defects.
- Dependencies: MOD17-P3-T01; MOD17-P1-T02.
- Inputs: `ACCEPTANCE_CRITERIA.md`.
- Outputs: results record.
- Acceptance: every row has a result.
- Tests: the rows themselves.
- Blocked by: OQ-26 devices.
- Done when: results filed.

**MOD17-P3-T03 Run the security checklist**
- Owner: Yuvraj · Support: Sanika Attarde (server evidence) · Parent: T-11.3 · Type: Shared (ICP-11)
- Objective: every SEC-CHK item recorded as passed or logged as a defect (NFR-SEC-010, AC-10.3).
- Steps: (1) Collect the module evidence, including MOD13-P2-T01. (2) Run the remaining app-side items. (3) Record.
- Dependencies: MOD13-P2-T01; MOD17-P3-T01.
- Inputs: `TESTING_STRATEGY.md` §9.
- Outputs: completed checklist.
- Acceptance: SEC-CHK-01 to SEC-CHK-19 each recorded.
- Tests: the checklist items.
- Blocked by: none beyond earlier tasks.
- Done when: checklist filed.

**MOD17-P3-T04 Internal test summary for M4**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: T-11.4 · Type: Own
- Objective: the S2 M4 test summary.
- Steps: (1) Summarise results, defects and limits, including missing devices.
- Dependencies: MOD17-P3-T02; MOD17-P3-T03.
- Inputs: results records.
- Outputs: test summary.
- Acceptance: filed and shared with MFW by Sanika Attarde.
- Tests: none.
- Blocked by: none.
- Done when: DoD-DOC.

**MOD17-P3-T05 Acceptance test build and script**
- Owner: Yuvraj · Support: Sanika Attarde (MFW contact) · Parent: T-11.5 · Type: Shared (ICP-11)
- Objective: S2 acceptance testing: a build and script to MFW, five working days for MFW, a reply to each item within one working day, fix checks within two.
- Steps: (1) Prepare the script from the AC rows. (2) Check no critical or high defect is open (AC-10.4). (3) Hand the build to MFW through Sanika Attarde. (4) Triage and fix.
- Dependencies: MOD17-P3-T04.
- Inputs: S2 acceptance testing; NFR-REL-002.
- Outputs: acceptance build; script; triage record.
- Acceptance: MFW signs off with no critical or high defect open.
- Tests: MFW's acceptance run.
- Blocked by: MFW's testers.
- Done when: sign-off filed.

### Module MOD-20: Governance (Yuvraj's task)

The module owner is Sanika Attarde. The phase description is in the Sanika Attarde roadmap.

**MOD20-P1-T04 Review the three planning documents**
- Owner: Yuvraj · Support: Sanika Attarde · Parent: New · Type: Shared (ICP-01)
- Objective: Yuvraj's review of `IMPLEMENTATION_MODULE_INVENTORY.md`, this roadmap and `SANIKA_IMPLEMENTATION_ROADMAP.md`, which were drafted in Sanika Attarde's session.
- Steps: (1) Check owners, tasks and dependencies. (2) Answer VR-01 (MOD-00 ownership). (3) Record agreement or changes on the pull request.
- Dependencies: none.
- Inputs: the three documents.
- Outputs: review on the pull request.
- Acceptance: review recorded; agreed changes made in the inventory first.
- Tests: none.
- Blocked by: none.
- Done when: DoD-DOC.

## 6. Integration Checkpoints

Copied from inventory section 10 for the checkpoints that involve Yuvraj. The inventory wins if they differ.

| ID | Modules | Contract | Integration test | Responsible | Accepted when |
|---|---|---|---|---|---|
| ICP-01 | MOD00-P1-T01, MOD02-P1-T01, MOD03-P1-T01 | Contracts, `AccessState`, `Result`, `AppFailure` | Contracts and fakes compile; unit tests | Yuvraj (folder); Sanika Attarde (WS-A files) | Both developers approve under the shared-file protocol |
| ICP-02 | MOD03-P2-T03, MOD01-P2-T01 | IC-01 | FX-USR-01 to FX-USR-05 reach the expected screen | Yuvraj writes the check; Sanika Attarde provides | IC-01 passes in ENV-TEST |
| ICP-03 | MOD13-P1-T04, MOD06-P1-T02, MOD06-P2-T02, MOD06-P2-T03 | IC-02, OP-11 | Grant for full access only; resume with a new grant | Yuvraj writes the check; Sanika Attarde provides | IC-02, PAC-13, SEC-CHK-02 pass |
| ICP-04 | MOD12-P2-T03, MOD13-P1-T03, MOD05-P2-T04 | IC-07 | Publish and unpublish after a refresh | Yuvraj writes the check | IC-07, AC-1.4, AC-8.7 pass |
| ICP-05 | MOD13-P1-T02, MOD08-P2-T03 | IC-04 | Isolation; second device | Yuvraj writes the check | IC-04, AC-5.3, AC-5.4, SEC-CHK-05 pass |
| ICP-06 | MOD12-P2-T04, MOD09-P2-T03 | IC-06 | Hidden post disappears after a refresh | Yuvraj writes the check | IC-06, AC-8.8 pass |
| ICP-07 | MOD11-P1-T01, MOD11-P2-T01, MOD11-P3-T01, MOD01-P3-T01 | IC-05 | FX-NTF-01 to FX-NTF-08 open the right screen | Yuvraj writes the check; Sanika Attarde runs the send | IC-05, AC-9.3 pass |
| ICP-08 | MOD13-P1-T06, MOD03-P4-T01, MOD06-P3-T02, MOD08-P2-T03, MOD11-P2-T04 | IC-08 | Server holds none of the FR-PRIV-003 data; app clears local data | Sanika Attarde (server check); Yuvraj (device checks) | IC-08, AC-3.7, PAC-06, SEC-CHK-11 pass |
| ICP-09 | MOD16-P1-T05, MOD07-P1-T02, MOD16-P2-T01 | Screens and reader report | Prototype review | Yuvraj assembles; Sanika Attarde presents | MFW's written M2 approval filed |
| ICP-10 | MOD17-P2-T01 | Sign up, sign in, browse, open an issue | End to end on test devices | Yuvraj; Sanika Attarde deploys the backend | S2 M3 shown; MFW's approval filed |
| ICP-11 | MOD17-P3-T01 | Every IC | DoD-INT | Yuvraj; Sanika Attarde for backend deploy | Build from `main` with every IC passing |
| ICP-12 | MOD15-P3-T01, MOD18-P1-T02, MOD18-P2-T03, MOD19-P2-T04 | Signed tagged builds; clean-copy rebuild | QG-13; AC-11; AC-12 | Sanika Attarde | DoD-RC and DoD-HO met |

## 7. Testing and Quality Gates

Taken from `TESTING_STRATEGY.md`, `CI_CD_AND_QUALITY_GATES.md` and `DEFINITION_OF_DONE.md`. No coverage percentage or performance figure is added here beyond S2's AC-2 targets.

| Level | What Yuvraj owns |
|---|---|
| Unit tests | Guards, `applyQuery`, download state machine with FX-NET, reader controller, library and news repositories (QG-03) |
| Widget and UI tests | SCR-A-10 to SCR-A-19, SCR-A-22, with loading, empty and error states (PAC-10) |
| API tests | Consumer checks of IC-01 to IC-07 against ENV-TEST; WordPress fixture tests |
| Integration tests | `app/integration_test/` flows, including the M3 flow (QG-07) |
| Security tests | SEC-CHK-01, SEC-CHK-04, SEC-CHK-09, SEC-CHK-13, SEC-CHK-15; running the whole checklist (MOD17-P3-T03) |
| Regression | Full AC and PAC run on the agreed devices (MOD17-P3-T02); re-run affected rows for each fix |
| Performance | AC-2.1, AC-2.3, AC-2.5 on the agreed devices (MOD07-P3-T01); NFR-STOR-001 and NFR-STOR-002 checks recorded |
| CI gates | QG-01 to QG-07 and QG-10 to QG-13 pipelines; QG-08 and QG-09 run Sanika Attarde's suites |
| Manual acceptance | AC-1, AC-2, AC-4 to AC-7, AC-10; PAC-04, PAC-05, PAC-07, PAC-10, PAC-14, PAC-20; acceptance testing with MFW |

## 8. Delivery Checklist

- [ ] Scaffold merged with DEC-013, DEC-014 and OQ-50 AGREED.
- [ ] Every task in section 5 meets its "Done when" line, with evidence linked in its pull request.
- [ ] IC-01 to IC-07 consumer checks and the IC-08 device checks written and passing.
- [ ] Reader test report delivered for M2, with the missing devices recorded.
- [ ] No full issue opens or downloads without `fullAccess` in any route, including notification taps.
- [ ] No MFW sample PDF, test credential or reader data in the repository.
- [ ] QG-01 to QG-13 running as agreed; required gates green on `main`.
- [ ] No excluded item built: no page streaming, no app links, no PDF search, no guest reading.
- [ ] `CHANGELOG.md` and affected documents updated for each merged change.
- [ ] M3 demo, M4 build, test summary and acceptance build delivered.

## 9. Outstanding Decisions

| ID | Question (short) | Why it matters | Blocks | Who answers | MFW approval |
|---|---|---|---|---|---|
| DEC-013, DEC-014, OQ-50 | Riverpod, go_router, toolchain | Everything is a spike until agreed | MOD01-P1-T01 and all later app tasks | Both developers | No |
| DEC-005 / OQ-36 | Reader library and licence | Reader features | MOD07-P2-*, MOD07-P3-T01 | Both developers; MFW at M2 | Yes |
| OQ-14 | Reader modes and default | Reader controls | MOD07-P2-T02 | Team with MFW | Yes |
| DEC-020 / OQ-37 | File delivery and resume | Downloads | MOD06-P2-T02, MOD06-P2-T03 | Both developers | Only if it adds cost |
| DEC-008, DEC-033 / OQ-08 | Temporary and kept copies | Read and Download | MOD06-P3-T01 | MFW | Yes |
| OQ-11 | Kept copies after sign-out, deletion, unpublishing | Lifecycle | MOD06-P3-T02 | MFW | Yes |
| OQ-54 | Background downloads | Resume behaviour | MOD06-P2-T03 | MFW with the team | Yes |
| OQ-10 | Offline catalogue and library | Offline behaviour | MOD05-P2-T05, MOD08-P2-T04 | Team with MFW | Yes |
| OQ-12 | Favourites for incomplete access | Library rules | MOD08-P2-T02 | MFW | Yes |
| OQ-13 | Public fields, segment, edition | Catalogue and filters | MOD05-P2-T01, MOD05-P2-T02 | MFW | Yes |
| OQ-15, OQ-09 | Store link; sharing while signed out | Sharing | MOD10-P1-T01 | MFW | Yes |
| OQ-16, OQ-17, OQ-39 | News offline, breaking, site details | News | MOD09-* | MFW | Yes |
| OQ-25 | Accessibility baseline | Design and tests | MOD16-P1-*, MOD17-P3-T02 | MFW | Yes |
| OQ-26 | Devices and versions | AC-2, AC-10 | MOD07-P3-T01, MOD17-P1-T02, MOD17-P3-T02 | MFW with the team | Yes |
| DEC-022 | CI service and cost | Pipelines | MOD15-* | Both developers; MFW if billed | Conditional |
| VR-01 | MOD-00 accountable owner | Contract ownership | MOD00-P1-T01 | Both developers | No |

## 10. Handover Requirements

For another developer to continue Yuvraj's work:

- **Code and tests.** Each module's code under the paths in `CODING_STANDARDS.md` §3, with its tests in the same pull request. Every feature imported only through its public file.
- **Running the app.** `app/README` explains the Flutter and Dart versions, flavours for ENV-LOCAL, ENV-TEST and ENV-PROD, and how to run tests and integration tests.
- **Fixtures.** `TEST_DATA_AND_FIXTURES.md` and the fixture README say what each fixture is for and where MFW's samples are kept (never in Git).
- **CI.** Each workflow documented in `CI_CD_AND_QUALITY_GATES.md`, with how to run the gates locally.
- **Reader.** The reader test report, the library choice and its licence, and the measured results per device.
- **Open work.** Each unfinished task's state recorded in its pull request or in `DEVELOPMENT_ROADMAP.md` §4, with what blocks it.
- **Ownership change.** Follows `TASK_OWNERSHIP_MATRIX.md` §11.
