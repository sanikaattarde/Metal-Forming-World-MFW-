# Sanika Attarde Implementation Roadmap: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Sanika Attarde Implementation Roadmap |
| File | `Documentation/SANIKA_IMPLEMENTATION_ROADMAP.md` |
| Assigned developer | Sanika Attarde (branch `SA`, workstream WS-A Platform and Publishing, PROPOSED under DEC-011) |
| Project | Metal Forming World (MFW) mobile application |
| Version | 0.2 |
| Last updated | 7 November 2026 |
| Status | Draft for review. Not approved. A planning document. It approves no decision, requirement or scope item. |
| Prepared in | Sanika Attarde's session, branch `SA`, on top of commit `bd2db98` |
| Authoritative module inventory | `Documentation/IMPLEMENTATION_MODULE_INVENTORY.md` v0.1. If this roadmap and the inventory differ, the inventory wins. |
| Companion roadmap | `Documentation/YUVRAJ_IMPLEMENTATION_ROADMAP.md` v0.1 |
| Approval required | Both developers. Yuvraj reviews this roadmap (task MOD20-P1-T04). |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 27 October 2026 | Initial draft. 67 tasks in 11 modules. |
| 0.2 | 7 November 2026 | Committed to the repository, unchanged apart from a status note after this table, the version, the date, and one wording fix (a tool name in the "Prepared in" row). The plan, its task IDs and its order of work are not changed. |
| 0.1a | 30 October 2026 | `MOD12-P2-T03` no longer calls OP-28, which is not built on the working position (found while preparing `SANIKA_WSA_IMPLEMENTATION_PLAN.md`, GAP-08). `MOD13-P1-T06` no longer lists device registrations among the deleted records, because the backend stores no device token (DM M3, TD-13). No other change. |

**Status note of 7 November 2026.** This document was written on 30 October 2026 on top of commit `bd2db98`, and it is committed here as a record of the plan. Apart from this note, the version, the date and a few wording fixes, it is unchanged. The sections below describe the repository, the open pull requests and the open decisions as they were on 30 October 2026, and are not updated. Since then the Flutter app scaffold (pull request 30) and the shared contracts and fakes (pull request 34) are on `main`; the backend and admin panel spikes are done, and their evidence reports are in `Documentation/test-evidence/` (emulator only, not merged); both developers' written notes are filed, and DEC-010 to DEC-015, DEC-022 and DEC-024 to DEC-030 are AGREED (`DECISION_LOG.md` sections 5.6 and 5.8); and the second-person reviews of issues 28, 29, 31 and 32 are recorded in pull requests 33 to 46. `README.md`, `CHANGELOG.md` and `DEVELOPMENT_ROADMAP.md` give the current state. The task IDs and the order of work stay as the plan.

## 2. Project Context

MFW is a Flutter app for Android and iOS, a backend on MFW's own cloud accounts, and a web admin panel, for MFW's magazine issues and news [S2 Product]. Readers browse a public catalogue and news. Opening or downloading a full issue needs a signed-in reader with full access. There is no guest reading (DEC-007, working position, mandatory). Issue PDFs are stored privately and released only after a server-side check (DEC-009, BASELINE). Admins upload and publish issues, control news posts and send notifications from the panel.

The scope baseline is S2 and S1, whose repository copies are unsigned (OQ-28). Items that rest on the S3 emails, such as Google Sign-In and the mandatory profile, are PROVISIONAL. The backend platform (DEC-003), admin technology (DEC-004) and file-delivery mechanism (DEC-020) are OPEN. S2 proposes Firebase and a React admin panel. This roadmap names them only as PROVISIONAL examples.

Delivery runs through milestones M1 to M5 [S2]. The working dates are the Charter's (PROVISIONAL, C-08): M2 4 November, M3 18 November, M4 2 December, M5 16 December 2026. `DEVELOPMENT_ROADMAP.md` §3 and §7 hold the week plan, which this roadmap does not change.

No application code exists (inventory section 2.2). Every task below is Not started unless stated.

## 3. Responsibilities

### 3.1 Modules

| Module | Role | Tasks here |
|---|---|---|
| MOD-20 Governance, client approvals and inputs | Owner (MFW contact, CH §14) | 7 |
| MOD-14 Backend platform, environments and configuration | Owner | 6 |
| MOD-13 Backend authorization, data rules, file grants and account deletion | Owner | 8 |
| MOD-02 Errors, logging and monitoring | Owner | 4 |
| MOD-03 Authentication and account lifecycle | Owner | 7 |
| MOD-04 Profile, settings and consent | Owner | 5 |
| MOD-11 Notifications | Owner | 6 |
| MOD-12 Admin and content management | Owner | 10 |
| MOD-16 Screen design and M2 prototype | Supporting (owns three tasks) | 3 |
| MOD-18 Release and store submission | Owner | 5 |
| MOD-19 Handover, backup and operations | Owner | 6 |
| MOD-00, MOD-01, MOD-05 to MOD-10, MOD-15, MOD-17 | Supporting and reviewer | 0 (see the Yuvraj roadmap) |

### 3.2 Interfaces Sanika Attarde provides

`AccessState` and `AuthService` (IC-01), `Result`, `AppFailure` and `messageFor`, backend operations OP-01 to OP-42 and their error scheme, the issue-file grant (IC-02), library rules (IC-04), the notification payload (IC-05), news controls (IC-06), catalogue publication (IC-07), account deletion (IC-08), configuration items CFG-01 to CFG-15, and `app/pubspec.yaml` (primary editor).

### 3.3 Deliverables

The M1 note and MFW's written records; agreed engineering decisions; ENV-TEST and ENV-PROD on MFW's accounts; access rules with tests; the admin panel; notification dispatch; signed builds submitted to both stores; the handover set (technical documentation, admin guide and training, credential record, repository transfer, clean-copy rebuild).

## 4. Prerequisites and Blockers

### 4.1 The first unblocker

DEC-010 to DEC-015 and DEC-025 to DEC-030 are PROPOSED, with the note that Sanika Attarde's written agreement is not filed. Until it is, `DECISION_LOG.md` §3.3 rule 4 keeps all dependent code to spikes, for both developers. Task MOD20-P1-T01 files it. It needs no one else.

### 4.2 Required decisions and approvals

| Item | Blocks | Who answers | MFW approval |
|---|---|---|---|
| DEC-003 backend platform (OQ-35) | MOD-13, MOD-14 beyond spikes, MOD03-P2-*, MOD11-P2-T01, MOD12-P2-* | Both developers; MFW if it differs from S2 or adds cost | Conditional |
| DEC-004 admin technology | MOD12-P1-T01 beyond a spike, MOD12-P2-* | Both developers; MFW if it differs from S2 | Conditional |
| DEC-020 file delivery (OQ-37) | MOD13-P1-T04 | Both developers | Only if it adds cost |
| DEC-023 environments (OQ-40) | MOD14-P2-T02 | Both developers and MFW | Yes |
| DEC-031 region (OQ-41, OQ-53) | MOD14-P2-T02, MOD14-P3-T01 | MFW and its legal adviser | Yes |
| DEC-006 Google Sign-In (OQ-04, OQ-05, OQ-06, OQ-29) | MOD03-P3-T02 | MFW | Yes |
| DEC-027 in-panel admin management (OQ-58, OQ-56) | MOD12-P3-T02 | MFW | Yes |
| DEC-028 crash reporting and usage events (OQ-23) | MOD02-P2-T01, MOD02-P2-T02 | MFW | Yes |
| DEC-029 retention (OQ-24) | MOD13-P1-T06 (records kept), MOD19-P1-T01 | MFW and its legal adviser | Yes |
| DEC-032 edition-update sign-up (OQ-31) | No task (dropped on the working position) | MFW | Yes |
| OQ-01, OQ-02, OQ-03, OQ-07, OQ-27 profile and consent | MOD04-P2-T01, MOD04-P2-T02 | MFW | Yes |
| OQ-09, OQ-18, OQ-19, OQ-55 notifications | MOD11-P2-T02, MOD11-P2-T03, MOD11-P2-T04 | MFW; both developers for OQ-55 | Yes, except OQ-55 |
| OQ-20, OQ-21, OQ-22, OQ-30, OQ-51 admin | MOD12-P2-T01, MOD12-P2-T02, MOD12-P2-T06, MOD12-P3-T01 | MFW | Yes |
| OQ-42, OQ-43, OQ-44, OQ-45 store | MOD18-* | MFW | Yes |
| OQ-46, OQ-47, OQ-48 backup, monitoring, transfer | MOD19-* | MFW | Yes |

### 4.3 External inputs (MFW)

Cloud project with billing in MFW's name; region decision; Apple Developer (organisation) and Google Play accounts; app name and identifiers; privacy policy and terms at a public address; brand assets; admin user list; store listing text; testers. All are reported not received where due (GS-Q35). MOD20-P2-T04 tracks them under S2's delay rule.

### 4.4 Dependencies on Yuvraj

| Needed from Yuvraj | For |
|---|---|
| MOD00-P1-T01 contracts folder | MOD02-P1-T01, MOD03-P1-T01, MOD04-P1-T01, MOD11-P1-T01 |
| MOD01-P1-T01 Flutter scaffold | Every app-side task here |
| MOD01-P2-T01 route guards | MOD03-P2-T03 integration (ICP-02) |
| MOD01-P3-T01 tap routing | MOD11-P3-T01 (ICP-07) |
| MOD06-P1-T02 resume spike | MOD13-P1-T04 mechanism choice |
| MOD06-P3-T02 device-side deletion rules | MOD03-P4-T01 (ICP-08) |
| MOD15-P1-T02 CI skeleton; MOD15-P2-T02 rule and admin gates; MOD15-P3-T01 release workflow | MOD13 tests in CI; MOD18-P1-T02 |
| MOD16-P1-T01 design tokens; MOD16-P1-T05 prototype | MOD16-P1-T03, MOD16-P1-T04, MOD16-P2-T01 |
| MOD07-P1-T02 reader test report | MOD16-P2-T01 |
| MOD17-P1-T01 fixtures; MOD17-P3-T01 M4 build; MOD17-P3-T05 acceptance build | Rule tests; MOD18-P2-T03 |
| MOD20-P1-T04 review of the planning documents | Agreement on this roadmap |

### 4.5 Missing inputs and open technical questions

Grant lifetime and resume on signed links (AR-01, CFG-06); App Check (OQ-52); the recent-sign-in window (OQ-56); rate-limit values (SC-18); whether token removal ends topic subscriptions (OQ-55); whether the Firebase console offers Mumbai for every service (DEC-031, NOT VERIFIED).

## 5. Implementation Roadmap

**Conventions.**

- Task IDs follow inventory section 5. "Parent" is the `DEVELOPMENT_ROADMAP.md` task, or "New".
- "Type: Shared (ICP-nn)" marks a task whose acceptance needs Yuvraj's work. Otherwise "Own".
- Every task's Definition of done includes DoD-TASK (`DEFINITION_OF_DONE.md` §5): reviewed by Yuvraj, tests in the same pull request, quality gates green where they exist, documentation updated, `CHANGELOG.md` line. Feature tasks also meet DoD-FEAT (§6). "Done when" adds only what is specific.
- A task that depends on an OPEN or PROPOSED decision is done as a spike until the decision is AGREED, and is not called done until then.
- Requirement IDs are from RS. Operation IDs are the main IDs in `API_AND_BACKEND_CONTRACT.md`.

### Module MOD-20: Governance, Client Approvals and Inputs

#### MOD20-P1 Internal agreement

- Objective: turn PROPOSED engineering decisions into AGREED ones and review the design drafts, so code can leave spike status.
- Entry: none. This phase can start now.
- Completion and handoff: `DECISION_LOG.md` entries carry filed evidence; review comments are recorded; Yuvraj can merge non-spike work.
- Verification: the evidence rules of `DECISION_LOG.md` §3.1.

**MOD20-P1-T01 File written agreement on the PROPOSED engineering decisions**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-00.4 · Type: Own
- Objective: give DEC-010 to DEC-015, DEC-022, DEC-024 to DEC-030 and the DEC-011 split the evidence AGREED needs.
- Steps: (1) Read each entry and its TD row. (2) Approve the documentation pull request, or write a note that names each DEC accepted and any not accepted. (3) For any entry not accepted, record the objection on the entry. (4) File references (date, sender role, subject) to the S3 emails and signed S1 and S2 if held, without their text, because the repository is public.
- Dependencies: none.
- Inputs: `DECISION_LOG.md` §3.1, §5.3, §6; `TECHNOLOGY_DECISIONS.md` §10.5.
- Outputs: a review or note filed; a documentation pull request that sets each accepted entry to AGREED.
- Acceptance: every listed entry is AGREED with a link to the evidence, or stays PROPOSED with the objection written down.
- Tests: none (documentation). Yuvraj checks the links.
- Blocked by: none.
- Done when: DoD-DOC; `TASK_OWNERSHIP_MATRIX.md` §12 open items updated.

**MOD20-P1-T02 Review the architecture, data, contract and security drafts**
- Owner: Sanika Attarde · Support: Yuvraj (author) · Parent: T-00.3, T-00.6 · Type: Own
- Objective: a second-person review of `SYSTEM_ARCHITECTURE.md`, `TECHNOLOGY_DECISIONS.md`, `DATABASE_AND_DATA_MODEL.md`, `API_AND_BACKEND_CONTRACT.md` and `SECURITY_AND_ACCESS_CONTROL.md`.
- Steps: (1) Review each against RS and S2. (2) List differences with `API_AND_MODULE_CONTRACTS.md` (VR-04). (3) Record each difference as a conflict or open item in the document that holds it. (4) Move DEC-003 and DEC-004 to PROPOSED or AGREED with the options assessed.
- Dependencies: none.
- Inputs: the five documents; RS; S2.
- Outputs: review comments; documentation pull requests from the editor.
- Acceptance: review recorded on a pull request; DEC-003 and DEC-004 no longer OPEN without an assessment.
- Tests: none.
- Blocked by: none.
- Done when: DoD-DOC.

**MOD20-P1-T03 Review the reader, incident, coverage, screen and cloud drafts**
- Owner: Sanika Attarde · Support: Yuvraj (author) · Parent: T-00.7 · Type: Own
- Objective: a second-person review of `PDF_READER_AND_OFFLINE_DESIGN.md`, `SECURITY_INCIDENT_PROCEDURE.md`, `REQUIREMENT_COVERAGE_MATRIX.md`, `SCREEN_INVENTORY_AND_NAVIGATION.md` and `CLOUD_INFRASTRUCTURE_AND_COSTS.md`.
- Steps: (1) Review each. (2) For the cloud document, check the cost scenarios against OQ-53 once MFW answers. (3) Record findings on a pull request.
- Dependencies: none.
- Inputs: the five documents.
- Outputs: review comments.
- Acceptance: review recorded for each document.
- Tests: none.
- Blocked by: the single-provider cost model waits for DEC-003; the reader design for OQ-36 and OQ-37; the incident contacts for OQ-47.
- Done when: DoD-DOC.

#### MOD20-P2 MFW records, questions, M1 and inputs

- Objective: obtain MFW's written records and answers, the M1 approval and the inputs that unblock the rest of the plan.
- Entry: MOD20-P1-T02 started (the M1 note needs the reviewed architecture).
- Completion and handoff: answers recorded in `OPEN_QUESTIONS.md`, decisions updated, M1 approval filed. Each answer unblocks the tasks listed against it.
- Verification: every closed question has the evidence named in `OPEN_QUESTIONS.md`.

**MOD20-P2-T01 Obtain MFW's written records on the baseline**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-00.1 · Type: Own
- Objective: settle OQ-28, OQ-29, OQ-32, OQ-33, OQ-34 and OQ-59.
- Steps: (1) Ask MFW by email for the named approver and deputy, written confirmation of the CH §17.3 amendments, the commercial terms, two-developer delivery, and whether chat messages count as written approval. (2) File references to the replies.
- Dependencies: none.
- Inputs: `OPEN_QUESTIONS.md` §5.1, §5.2.
- Outputs: filed references; DEC-016 to DEC-019 updated.
- Acceptance: each question ANSWERED with its evidence, or recorded as still waiting with the date asked.
- Tests: none.
- Blocked by: MFW's reply.
- Done when: DoD-DOC.

**MOD20-P2-T02 Put the open product questions and change requests to MFW**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-00.2 · Type: Own
- Objective: get written answers to the P1 and P2 questions that block tasks, each with the team's proposed default.
- Steps: (1) Send OQ-01 to OQ-03, OQ-07 to OQ-13, OQ-16 to OQ-18, OQ-20 to OQ-27, OQ-30, OQ-31, OQ-39 to OQ-42, OQ-46, OQ-51, OQ-53, OQ-54, OQ-57 and OQ-58 with the working positions. (2) For OQ-58 (in-panel admin management) and OQ-31 (dropping the edition-update sign-up), ask whether MFW treats each as a clarification or a change. If a change, raise it under S2 Changes (CHG-02, CHG-09). (3) Ask for written confirmation of Google Sign-In scope (CHG-08) and acceptance of risk R9 (OQ-06). (4) Record each reply.
- Dependencies: none.
- Inputs: `OPEN_QUESTIONS.md`; `SCOPE_AND_EXCLUSIONS.md` §13; DEC-027, DEC-032.
- Outputs: question list sent; replies filed; change requests raised where MFW calls an item a change.
- Acceptance: every listed question is ANSWERED or recorded as waiting with the date sent.
- Tests: none.
- Blocked by: MFW's reply.
- Done when: DoD-DOC; affected tasks' "Blocked by" lines updated.

**MOD20-P2-T03 Send the M1 requirements and architecture note**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-00.5 · Type: Own
- Objective: meet S2 M1 with a written approval that names the note.
- Steps: (1) Assemble a short note from RS, `SYSTEM_ARCHITECTURE.md` and the decisions. (2) Send it to MFW's authorised approver. (3) Ask for an email approval that names the note (OQ-59). (4) File the reference.
- Dependencies: MOD20-P1-T02.
- Inputs: RS; architecture documents; DEC-003, DEC-004.
- Outputs: the M1 note; the filed approval.
- Acceptance: MFW's written approval naming the note is filed.
- Tests: none.
- Blocked by: OQ-28 (approver), MFW's reply.
- Done when: DoD-DOC.

**MOD20-P2-T04 Track MFW inputs and send delay notices**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (S2 Responsibilities) · Type: Own
- Objective: keep a dated record of each MFW input and apply S2's delay rule.
- Steps: (1) List each input from S1 "What we need from MFW" with its due date. (2) Record the date received. (3) When an input is late, tell MFW in writing and record the effect on later dates. (4) Raise a schedule change for a delay over five working days (CHG-11).
- Dependencies: none.
- Inputs: S1; `SCOPE_AND_EXCLUSIONS.md` §14; DEC-017.
- Outputs: the input record in `DEVELOPMENT_ROADMAP.md` §4; delay notices filed by reference.
- Acceptance: every input has a due date and a received date or a delay notice.
- Tests: none.
- Blocked by: none. Note: DEC-017 records YG's decision of 27 October 2026 to send no delay notice for M2. This task asks both developers to revisit that under S2.
- Done when: DoD-DOC.

### Module MOD-14: Backend Platform, Environments and Configuration

#### MOD14-P1 Repository hygiene and local spike

- Objective: protect secrets before any code exists, and prove the backend shape locally without creating cloud resources.
- Entry: none.
- Completion and handoff: `.gitignore` and configuration example merged; spike report shared with Yuvraj.
- Verification: secrets scan clean (QG-11 once it exists); spike tests run locally.

**MOD14-P1-T01 Add `.gitignore`, a configuration example and README stubs**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-01.2 · Type: Own
- Objective: keep secrets, build output and `.DS_Store` out of Git, and document how configuration is supplied.
- Steps: (1) Add a root `.gitignore` for Flutter, Node, IDE and OS files, service-account keys and local environment files. (2) Add a configuration example listing CFG-01 to CFG-15 by name with placeholder values only. (3) Add README sections for `app/`, `backend/` and `admin/` set-up.
- Dependencies: none.
- Inputs: `DEPLOYMENT_PLAN.md` CFG table; `CODING_STANDARDS.md` §3; SEC-CHK-09.
- Outputs: `.gitignore`; configuration example file; README updates.
- Acceptance: no credential or real configuration value in the repository; a new developer can see which values are needed and where they come from.
- Tests: manual secrets search; QG-11 once MOD15-P2-T01 exists.
- Blocked by: none.
- Done when: DoD-TASK.

**MOD14-P1-T02 Local emulator and deny-by-default rule spike**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-01.4 (spike part) · Type: Own
- Objective: show locally that the proposed platform (TD-03, PROPOSED) can enforce the access rules, before DEC-003 is decided.
- Steps: (1) On a spike branch, set up the platform's local emulator. (2) Write rules that deny by default. (3) Add sample tests for an owner-only record, an admin-only write and `getIssueFile`'s checks. (4) Write a short report: what worked, what did not, cost or set-up surprises.
- Dependencies: none.
- Inputs: `SECURITY_AND_ACCESS_CONTROL.md` SC-01 to SC-08; `API_AND_BACKEND_CONTRACT.md` OP-10, OP-11.
- Outputs: spike branch; spike report in the pull request.
- Acceptance: tests run locally; no cloud resource created; work labelled a spike.
- Tests: the spike's own rule tests.
- Blocked by: none (spike). Final work waits for DEC-003.
- Done when: report reviewed by Yuvraj. Not merged as final.

#### MOD14-P2 Test environment

- Objective: give both developers ENV-TEST on MFW's accounts with a deployable backend skeleton.
- Entry: DEC-003 AGREED (and approved by MFW if required); MFW's cloud project received; DEC-023 and OQ-40 answered; region decided (DEC-031).
- Completion and handoff: Yuvraj can point the app at ENV-TEST.
- Verification: an empty skeleton deploys and answers a health check.

**MOD14-P2-T01 Set up role-based access to MFW's cloud project**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-01.3 · Type: Own
- Objective: both developers reach MFW's project through their own accounts and roles (NFR-SEC-012).
- Steps: (1) Ask MFW to grant each developer a named role. (2) Confirm least privilege. (3) Record who holds what, without values (HO-04).
- Dependencies: MOD20-P2-T04 (cloud project received).
- Inputs: S2 Responsibilities; SEC-CHK-14.
- Outputs: access granted; credential-holder record updated.
- Acceptance: each developer signs in with their own account; no shared password.
- Tests: SEC-CHK-14 check recorded.
- Blocked by: MFW cloud project; DEC-023; OQ-40.
- Done when: DoD-TASK.

**MOD14-P2-T02 Check the region and create ENV-TEST resources**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (DEC-031, TD-22) · Type: Own
- Objective: create the test environment in the agreed region, which cannot be changed later.
- Steps: (1) Check that the console offers the agreed region for the database, functions and storage. (2) Record the result. (3) Create ENV-TEST resources. (4) Record CFG-01 and CFG-02. (5) Record the TD-18 versus DEC-023 environment difference (VR-03) and which model was used.
- Dependencies: MOD14-P2-T01.
- Inputs: DEC-031; `CLOUD_INFRASTRUCTURE_AND_COSTS.md`; `DEPLOYMENT_PLAN.md` §4.
- Outputs: ENV-TEST resources; configuration record.
- Acceptance: resources exist in the agreed region; values recorded without secrets.
- Tests: manual check of the region in the console, recorded.
- Blocked by: DEC-031 (OQ-41); OQ-53 cost ceiling; OQ-40.
- Done when: DoD-TASK.

**MOD14-P2-T03 Deploy the backend skeleton to ENV-TEST**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-01.4 · Type: Own
- Objective: an empty, deployable `backend/` with configuration per environment.
- Steps: (1) Create the `backend/` layout chosen under DEC-003 and DEC-025. (2) Add environment configuration loading for CFG-01 to CFG-06 and CFG-13, with no secret in the repository. (3) Add a deploy script for ENV-TEST. (4) Deploy and record the output.
- Dependencies: MOD14-P2-T02.
- Inputs: DEC-003, DEC-025; `CODING_STANDARDS.md` §3.
- Outputs: `backend/` skeleton; deploy script; deploy evidence.
- Acceptance: deploys to ENV-TEST; a health check answers; a clean clone deploys by the README.
- Tests: deploy run recorded; unit test of configuration loading.
- Blocked by: DEC-003.
- Done when: DoD-TASK.

#### MOD14-P3 Production environment

- Objective: ENV-PROD on MFW's accounts, ready for the release.
- Entry: MOD14-P2 complete; MFW approves the production cost and region.
- Completion and handoff: production deploy procedure written and rehearsed; MOD-18 can release.
- Verification: deploy procedure followed once, end to end.

**MOD14-P3-T01 Create ENV-PROD and write the production deploy procedure**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (`DEPLOYMENT_PLAN.md` §7) · Type: Own
- Objective: a production environment and a written, repeatable deployment.
- Steps: (1) Create ENV-PROD resources in the agreed region. (2) Apply access rules and configuration. (3) Write the deploy and rollback steps. (4) Rehearse a deploy of the release candidate.
- Dependencies: MOD14-P2-T03; MOD13-P2-T01.
- Inputs: `DEPLOYMENT_PLAN.md` §7.1 to §7.7.
- Outputs: ENV-PROD; deploy procedure in the repository.
- Acceptance: the procedure deploys the release candidate; no test data in production (DEC-024).
- Tests: rehearsal recorded; rule tests run against the deployed rules.
- Blocked by: DEC-003; DEC-031; MFW's cost approval.
- Done when: DoD-TASK; procedure part of the handover set (HO-02).

### Module MOD-13: Backend Authorization, Data Rules, File Grants and Account Deletion

#### MOD13-P1 Build the rules and operations

- Objective: enforce every access rule on the server, with allowed and refused tests for each.
- Entry: MOD14-P2-T03 deployed (rules can be written against the emulator earlier as a spike).
- Completion and handoff: Yuvraj's modules can call the operations in ENV-TEST.
- Verification: rule tests in the same pull request as each rule (`TASK_OWNERSHIP_MATRIX.md` §8.1).

**MOD13-P1-T01 Owner-only rules for profile, consent and preferences**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.6 · Type: Own
- Objective: a reader reads and changes only their own profile, consent record and notification preferences (NFR-SEC-006).
- Steps: (1) Write rules for OP-06, OP-09 and OP-10 records. (2) Add allowed and refused tests for each access state. (3) Validate profile fields on the server against the configured list.
- Dependencies: MOD14-P2-T03.
- Inputs: `DATABASE_AND_DATA_MODEL.md`; SC-06; FX-USR-01 to FX-USR-05.
- Outputs: rules; rule tests.
- Acceptance: SEC-CHK-05 rule tests pass for profile and preferences.
- Tests: rule unit tests (QG-08).
- Blocked by: DEC-003.
- Done when: DoD-TASK.

**MOD13-P1-T02 Owner-only rules for bookmarks and favourites**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-07.1 · Type: Shared (ICP-05)
- Objective: reader A cannot read or change reader B's bookmarks or favourites (NFR-SEC-005).
- Steps: (1) Write rules for OP-07 and OP-08. (2) Decide with Yuvraj whether the server also refuses a new bookmark below full access. RS §9.2 says bookmarks need full access, but OP-07 lists only ownership and the page number as checks, and rules do not look up account status. (3) Leave favourites for incomplete access configurable until OQ-12. (4) Add tests.
- Dependencies: MOD14-P2-T03.
- Inputs: SC-05; IC-04.
- Outputs: rules; tests.
- Acceptance: SEC-CHK-05 passes; IC-04 server side ready for Yuvraj's check.
- Tests: rule tests with two readers.
- Blocked by: DEC-003; OQ-12 for favourites only.
- Done when: DoD-TASK; ICP-05 passes.

**MOD13-P1-T03 Admin-only writes and public reads**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-09.3 (server part) · Type: Shared (ICP-04)
- Objective: only admins change issues, categories, segments and news controls; anyone reads published issues, categories, news controls and notification categories (NFR-SEC-007).
- Steps: (1) Write rules for OP-01, OP-02, OP-04 and OP-05 reads and OP-15 to OP-18, OP-21 to OP-23 writes. (2) Read the current role record on each privileged call and refuse if it cannot be read (SC-02, SC-03). (3) Never return a file location in a public read. (4) Add tests, including a removed admin (SEC-CHK-18).
- Dependencies: MOD14-P2-T03.
- Inputs: SC-02 to SC-05; DEC-027.
- Outputs: rules; tests.
- Acceptance: SEC-CHK-06 and SEC-CHK-18 rule tests pass.
- Tests: rule tests for reader, admin and removed admin.
- Blocked by: DEC-003.
- Done when: DoD-TASK.

**MOD13-P1-T04 Issue-file grant (OP-11 getIssueFile)**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-06.1 · Type: Shared (ICP-03)
- Objective: release an issue file only to a reader with full access, through a short-lived grant (DEC-009).
- Steps: (1) Implement OP-11 with its checks: signed in, email verified for email accounts, profile complete (PROVISIONAL, BR-003), issue published. (2) Return an opaque grant with expiry, size and content hash. (3) Set the lifetime from CFG-06. (4) Never use long-lived bearer links (DEC-009 constraint). (5) Add refused-state tests mapping to the error scheme.
- Dependencies: MOD13-P1-T01; MOD06-P1-T02 (resume evidence).
- Inputs: DEC-020; TD-09; IC-02; `API_AND_BACKEND_CONTRACT.md` OP-11.
- Outputs: OP-11; tests.
- Acceptance: PAC-13, SEC-CHK-02 and SEC-CHK-03 pass; IC-02 server side ready.
- Tests: function tests for each refused state; a direct request without a grant is refused.
- Blocked by: DEC-003; DEC-020 (OQ-37).
- Done when: DoD-FEAT; ICP-03 passes.

**MOD13-P1-T05 Deleted-issue list (OP-03)**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (DEC-033, OQ-11, OQ-21) · Type: Own
- Objective: let the app remove a kept copy of a permanently deleted issue when it next goes online.
- Steps: (1) Implement OP-03 as a public list of deleted issue IDs. (2) Add an entry when MOD12-P3-T01 deletes an issue. (3) Test.
- Dependencies: MOD13-P1-T03.
- Inputs: `DATABASE_AND_DATA_MODEL.md` §7; DEC-033.
- Outputs: OP-03; tests.
- Acceptance: a deleted issue appears on the list; no personal data on it.
- Tests: function tests.
- Blocked by: OQ-21; OQ-11.
- Done when: DoD-TASK.

**MOD13-P1-T06 Immediate account deletion (OP-12)**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.5 (server part) · Type: Shared (ICP-08)
- Objective: delete the account and the reader's data at once, retrying any failed step until it finishes (FR-PRIV-003, DEC-029).
- Steps: (1) Implement OP-12 for a signed-in reader with a recent sign-in if the provider needs it. (2) Delete the account, profile, consent record, bookmarks, favourites and notification preferences. The backend stores no device token (DM M3, TD-13), so none is deleted here; topic subscriptions are removed by the app (F-03). (3) Retry failed steps idempotently. (4) Keep only what OQ-24 allows. (5) Test.
- Dependencies: MOD13-P1-T01; MOD13-P1-T02.
- Inputs: DEC-029; SC-17; IC-08.
- Outputs: OP-12; tests.
- Acceptance: AC-3.7 server part, PAC-06 and SEC-CHK-11 pass.
- Tests: function test checks that no listed record remains.
- Blocked by: DEC-003; OQ-24 for retained records.
- Done when: DoD-FEAT; ICP-08 server check passes.

**MOD13-P1-T07 Rate and size limits**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (SC-18) · Type: Own
- Objective: each class of operation has a rate or size limit (SEC-CHK-19).
- Steps: (1) List operation classes. (2) Propose values for review. (3) Apply them. (4) Map `RATE_LIMITED` to the app's failure code with Yuvraj.
- Dependencies: MOD13-P1-T04.
- Inputs: SC-18; OQ-52.
- Outputs: limits; tests.
- Acceptance: a request over the limit is refused with `RATE_LIMITED`.
- Tests: function tests.
- Blocked by: DEC-003; values not set; OQ-52 for App Check.
- Done when: DoD-TASK.

#### MOD13-P2 Verification

- Objective: one set of rule evidence for the M4 security checklist.
- Entry: MOD13-P1 tasks done.
- Completion and handoff: evidence handed to Yuvraj for MOD17-P3-T03.
- Verification: full matrix run in ENV-TEST.

**MOD13-P2-T01 Run and record the full allowed and refused rule matrix**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-11.3 (input) · Type: Own
- Objective: evidence that every operation allows and refuses correctly for each access state.
- Steps: (1) Run all rule tests for FX-USR-01 to FX-USR-05, an admin and a removed admin. (2) Record results against SEC-CHK-02 to SEC-CHK-06, SEC-CHK-11 and SEC-CHK-18.
- Dependencies: MOD13-P1-T01 to MOD13-P1-T07.
- Inputs: `TESTING_STRATEGY.md` §9.
- Outputs: evidence record.
- Acceptance: every item passed or logged as a defect.
- Tests: the rule suite (QG-08).
- Blocked by: DEC-003.
- Done when: evidence filed for MOD17-P3-T03.

### Module MOD-02: Errors, Logging and Monitoring

#### MOD02-P1 Failure mapping and logger

- Objective: one way to turn failures into messages and to log without personal data.
- Entry: MOD00-P1-T01 merged.
- Completion and handoff: every app module can import the failure types and logger.
- Verification: unit tests.

**MOD02-P1-T01 Implement failure mapping and the redacting logger**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (VR-02) · Type: Shared (ICP-01)
- Objective: `Result`, `AppFailure`, `FailureCode`, `messageFor` and `AppLogger`.
- Steps: (1) Take over Yuvraj's first drafts of `Result` and `AppFailure` in contracts. (2) Implement `messageFor` for every code, with the M2 wording as placeholders. (3) Decide the mapping of `GONE` and `RATE_LIMITED` with Yuvraj. (4) Implement `AppLogger` with redaction of emails, tokens and grant links.
- Dependencies: MOD00-P1-T01.
- Inputs: `API_AND_MODULE_CONTRACTS.md` §4.2, §6.2; `CODING_STANDARDS.md` §6.2.
- Outputs: `app/lib/core/errors/`, `app/lib/core/logging/`; tests.
- Acceptance: every `FailureCode` has a message; redaction tests pass (SEC-CHK-10).
- Tests: unit tests.
- Blocked by: DEC-013 (spike until AGREED).
- Done when: DoD-TASK; ICP-01 passes.

#### MOD02-P2 Monitoring

- Objective: crash reporting and usage events on MFW's accounts, within the privacy limits.
- Entry: DEC-003 AGREED; DEC-028 AGREED.
- Completion and handoff: crash reports reach MFW's console with no reader identity.
- Verification: forced-crash check on each platform.

**MOD02-P2-T01 Add crash reporting with no user identifier**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (NFR-OBS-001) · Type: Own
- Objective: crashes from both apps reach MFW's crash service, with no reader identity (DATA-014).
- Steps: (1) Implement `CrashReporter` with the chosen provider in a `core` adapter. (2) Do not set a user ID. (3) Configure CFG-11 per environment. (4) Add the `DEPENDENCY_REGISTER.md` entry first.
- Dependencies: MOD02-P1-T01; MOD14-P2-T03.
- Inputs: DEC-028; TD-16.
- Outputs: adapter; configuration.
- Acceptance: the NO ROW candidate check for NFR-OBS-001 passes: a forced crash in a test build appears in MFW's service with no reader identity.
- Tests: forced crash on Android and iOS, recorded.
- Blocked by: DEC-003; DEC-028; C-07.
- Done when: DoD-TASK.

**MOD02-P2-T02 Add the usage-event allowlist, off until OQ-23**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (NFR-OBS-002) · Type: Own
- Objective: usage events only from an approved list, never recording which reader opened which issue or page (NFR-PRIV-003).
- Steps: (1) Implement `UsageEvents` that rejects events not on the list. (2) Keep collection off by configuration. (3) Turn it on only after OQ-23 sets the list and consent.
- Dependencies: MOD02-P1-T01.
- Inputs: PAC-09; OQ-23.
- Outputs: `UsageEvents` implementation; tests.
- Acceptance: PAC-09 passes; collection is off in every build until OQ-23 is answered.
- Tests: unit tests for rejection.
- Blocked by: OQ-23; C-07.
- Done when: DoD-TASK.

**MOD02-P2-T03 Log server security events without personal data**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (DEC-028, SC-16) · Type: Own
- Objective: refused requests, admin changes and grant issues are logged on the server for diagnosis, with no personal data, token or signed link.
- Steps: (1) Define the event list. (2) Log from MOD-13 and MOD-12 operations. (3) Test redaction.
- Dependencies: MOD13-P1-T04.
- Inputs: SC-16; SEC-CHK-10.
- Outputs: server logging; tests.
- Acceptance: SEC-CHK-10 passes on server logs.
- Tests: function tests inspect log output.
- Blocked by: DEC-003.
- Done when: DoD-TASK.

### Module MOD-03: Authentication and Account Lifecycle

#### MOD03-P1 Contract

- Objective: publish the authentication contract and fake so Yuvraj can build guards before the provider exists.
- Entry: MOD00-P1-T01 merged.
- Completion and handoff: `AuthService`, `AuthSession` and `AccessState` with a fake are on `main` (ICP-01).
- Verification: the fake drives every access state in unit tests.

**MOD03-P1-T01 Define `AuthService`, `AuthSession` and `AccessState` with a fake**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.4 (contract part) · Type: Shared (ICP-01)
- Objective: a stable IC-01 provider interface.
- Steps: (1) Take over Yuvraj's first draft of `AccessState`. (2) Write `AuthService` and `AuthSession` as in `API_AND_MODULE_CONTRACTS.md` §6.3. (3) Write `FakeAuthService` in `app/test/fakes/` that can emit each state. (4) Open the pull request under the shared-file protocol.
- Dependencies: MOD00-P1-T01.
- Inputs: `API_AND_MODULE_CONTRACTS.md` §4.1, §6.3.
- Outputs: `app/lib/features/auth/auth.dart`; fake; tests.
- Acceptance: the fake emits `signedOut`, `emailUnverified`, `profileIncomplete` and `fullAccess`; Yuvraj approves.
- Tests: unit tests on the fake.
- Blocked by: DEC-013 (spike until AGREED).
- Done when: DoD-TASK; ICP-01 passes.

#### MOD03-P2 Email accounts

- Objective: email registration, verification, sign-in, reset, sign-out and the access state, end to end in ENV-TEST.
- Entry: MOD03-P1 done; MOD14-P2-T03 deployed; M2 screens approved for these flows.
- Completion and handoff: IC-01 passes with Yuvraj's guards (ICP-02).
- Verification: AC-3.1, AC-3.3, AC-3.4, AC-3.6 and PAC-17 in ENV-TEST.

**MOD03-P2-T01 Email registration and verification**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.1 · Type: Own
- Objective: register with email and password and verify the address (FR-AUTH-001, FR-AUTH-002).
- Steps: (1) Implement `registerWithEmail` against the identity provider. (2) Send the verification email. (3) Implement `resendVerificationEmail` and `reloadVerificationStatus`. (4) Build SCR-A-02 and SCR-A-03 to the M2 design. (5) Tell the visitor when an account already exists for the address (PROPOSED in §6.3).
- Dependencies: MOD03-P1-T01; MOD14-P2-T03; MOD16-P2-T01.
- Inputs: INT-AUTH-001; SC-21; FX-USR-01, FX-USR-02.
- Outputs: data and presentation code; tests.
- Acceptance: AC-3.1 passes; PAC-17 registration rows pass.
- Tests: unit tests with a fake provider; widget tests of each form state; integration test register then verify.
- Blocked by: DEC-003.
- Done when: DoD-FEAT.

**MOD03-P2-T02 Email sign-in, password reset and sign-out**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.1 · Type: Own
- Objective: sign in, reset a forgotten password and sign out (FR-AUTH-003, FR-AUTH-004, FR-AUTH-008).
- Steps: (1) Implement `signInWithEmail` with one message for any wrong email or password. (2) Implement `sendPasswordReset` with the same message whether or not the address exists. (3) Implement `signOut`. (4) Build SCR-A-01 and SCR-A-04.
- Dependencies: MOD03-P2-T01.
- Inputs: SC-21; SEC-CHK-17.
- Outputs: code; tests.
- Acceptance: AC-3.6 and SEC-CHK-17 pass. The candidate check for FR-AUTH-008 passes: after sign-out, opening a full issue shows the sign-in prompt.
- Tests: unit and widget tests; integration test.
- Blocked by: DEC-003.
- Done when: DoD-FEAT.

**MOD03-P2-T03 Compute `AccessState` and the sign-in prompts**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.4 · Type: Shared (ICP-02)
- Objective: `watchAccessState` emits the right state from the session and profile status (FR-AUTH-010, BR-002, BR-003).
- Steps: (1) Combine `watchSession` with MOD-04's `watchStatus` in the order of §4.1. (2) Leave Google accounts' verification to OQ-04. (3) Support Yuvraj's guard tests with FX-USR-01 to FX-USR-05.
- Dependencies: MOD03-P2-T01; MOD04-P1-T01; MOD01-P2-T01.
- Inputs: IC-01.
- Outputs: implementation; tests.
- Acceptance: AC-3.3 and AC-3.4 pass; IC-01 passes.
- Tests: unit tests for each state; Yuvraj's IC-01 check.
- Blocked by: DEC-003; OQ-04 for Google accounts only.
- Done when: DoD-FEAT; ICP-02 passes.

#### MOD03-P3 Google Sign-In (PROVISIONAL)

- Objective: Google Sign-In on Android and iOS behind the same interface.
- Entry: MOD03-P2 done; app identifiers decided (OQ-42).
- Completion and handoff: PAC-01 and PAC-12 pass, or the feature stays behind configuration until MFW confirms scope.
- Verification: PAC-01, PAC-12.

**MOD03-P3-T01 Account-linking spike**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.2 (spike part) · Type: Own
- Objective: prove the TD-06 rule: one account per email, Google's verified result trusted, linking only to a verified password account (AOQ-08, AOQ-09).
- Steps: (1) On a spike branch, try each case of FX-USR-11 on the emulator. (2) Record the provider's actual behaviour. (3) Report.
- Dependencies: MOD14-P1-T02.
- Inputs: TD-06; OQ-04; OQ-05.
- Outputs: spike report.
- Acceptance: each case's behaviour recorded.
- Tests: the spike's own tests.
- Blocked by: none (spike).
- Done when: report reviewed by Yuvraj.

**MOD03-P3-T02 Google Sign-In on Android and iOS**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.2 · Type: Own
- Objective: register and sign in with Google (FR-AUTH-005, INT-AUTH-002).
- Steps: (1) Configure CFG-09 in MFW's accounts. (2) Implement `signInWithGoogle`, including cancellation. (3) Apply the agreed linking rule. (4) Route new Google readers to profile completion (OQ-03 working position).
- Dependencies: MOD03-P3-T01; MOD18-P1-T01.
- Inputs: PAC-01; PAC-12.
- Outputs: code; configuration.
- Acceptance: PAC-01 and PAC-12 pass.
- Tests: unit tests with a fake; manual on both platforms.
- Blocked by: OQ-29 (scope), OQ-04, OQ-05, OQ-06, OQ-42; MFW's OAuth set-up.
- Done when: DoD-FEAT.

#### MOD03-P4 Account deletion in the app

- Objective: the reader deletes the account from settings and the device is cleaned up.
- Entry: MOD13-P1-T06 deployed.
- Completion and handoff: IC-08 passes (ICP-08).
- Verification: AC-3.7, PAC-06.

**MOD03-P4-T01 In-app account deletion flow**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.5 (app part) · Type: Shared (ICP-08)
- Objective: delete the account in the app with a confirmation, then clear local user data (FR-AUTH-009, FR-PRIV-004).
- Steps: (1) Build SCR-A-08 with a confirmation. (2) Call OP-12. (3) Clear local user data. (4) Trigger MOD-06's kept-copy removal and MOD-11's token removal.
- Dependencies: MOD13-P1-T06; MOD04-P2-T04; MOD06-P3-T02; MOD11-P2-T04.
- Inputs: IC-08; SC-17.
- Outputs: code; tests.
- Acceptance: AC-3.7 and PAC-06 pass; IC-08 passes.
- Tests: widget test of confirmation; integration test of deletion.
- Blocked by: DEC-003.
- Done when: DoD-FEAT; ICP-08 passes.

### Module MOD-04: Profile, Settings and Consent

#### MOD04-P1 Contract

- Objective: the profile contract with a configurable field list.
- Entry: MOD00-P1-T01 merged.
- Completion and handoff: `ProfileRepository` and fake on `main`.
- Verification: unit tests.

**MOD04-P1-T01 Define `ProfileRepository`, `ReaderProfile` and `ConsentRecord` with a fake**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.3 (contract part) · Type: Own
- Objective: a profile contract whose fields come from configuration, so OQ-01 can change them without code changes.
- Steps: (1) Write the interfaces as in §6.4. (2) Make the field list data-driven, with the five fields of the working position. (3) Write the fake.
- Dependencies: MOD00-P1-T01.
- Inputs: OQ-01, OQ-02 working positions.
- Outputs: contract files; fake.
- Acceptance: the fake reports `incomplete` and `complete`.
- Tests: unit tests.
- Blocked by: DEC-013 (spike until AGREED).
- Done when: DoD-TASK.

#### MOD04-P2 Profile, consent and settings screens

- Objective: capture the mandatory profile and consent, show and edit the profile, and host settings.
- Entry: MOD04-P1 done; MOD13-P1-T01 deployed; M2 screens approved.
- Completion and handoff: `ProfileStatus` feeds `AccessState` (MOD03-P2-T03).
- Verification: PAC-02, PAC-08.

**MOD04-P2-T01 Complete-profile screen and validation**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.3 · Type: Own
- Objective: registration is complete only with every mandatory field (FR-PROF-001 to FR-PROF-005).
- Steps: (1) Build SCR-A-05 from the configured field list. (2) Validate each field, including whole-number age 1 to 120 (OQ-02 working position). (3) Save through OP-10. (4) Show no age gate (FR-PROF-005).
- Dependencies: MOD04-P1-T01; MOD13-P1-T01; MOD16-P2-T01.
- Inputs: PAC-02; FX-USR-10.
- Outputs: code; tests.
- Acceptance: PAC-02 passes with the configured list.
- Tests: unit tests per field; widget tests.
- Blocked by: OQ-01, OQ-02, OQ-03 (final list); OQ-07 (legal confirmation before release).
- Done when: DoD-FEAT.

**MOD04-P2-T02 Consent capture and policy links**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.3 · Type: Own
- Objective: record consent at registration and link MFW's policy and terms (FR-PRIV-001, FR-PRIV-002, DATA-012).
- Steps: (1) Add the consent action to registration. (2) Store what was agreed and when through OP-10. (3) Open CFG-07 addresses from settings.
- Dependencies: MOD04-P2-T01.
- Inputs: PAC-08; CFG-07.
- Outputs: code; tests.
- Acceptance: PAC-08 passes.
- Tests: widget and unit tests.
- Blocked by: OQ-27; MFW's policy and terms at a public address.
- Done when: DoD-FEAT.

**MOD04-P2-T03 Profile screen and editing**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-03.3 · Type: Own
- Objective: show and edit the reader's own profile (FR-PROF-006, FR-PROF-007).
- Steps: (1) Build SCR-A-06. (2) Allow editing with the same validation. (3) Save through OP-10.
- Dependencies: MOD04-P2-T01.
- Inputs: OP-06, OP-10.
- Outputs: code; tests.
- Acceptance: the candidate check for FR-PROF-007 passes: a changed field shows on a second device.
- Tests: widget tests; manual second-device check.
- Blocked by: OQ-01 for the final fields.
- Done when: DoD-FEAT.

**MOD04-P2-T04 Settings screen**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (§6.4 responsibilities) · Type: Own
- Objective: one settings screen hosting notification preferences, reader mode (MOD-07), sign-out and delete account.
- Steps: (1) Build SCR-A-07. (2) Embed MOD-11's preferences widget. (3) Add an entry point for Yuvraj's reader-mode setting. (4) Link sign-out and SCR-A-08.
- Dependencies: MOD03-P2-T02; MOD16-P2-T01.
- Inputs: `SCREEN_INVENTORY_AND_NAVIGATION.md` SCR-A-07.
- Outputs: code; tests.
- Acceptance: matches the approved design; each entry opens its target.
- Tests: widget tests.
- Blocked by: none beyond the M2 designs.
- Done when: DoD-FEAT.

### Module MOD-11: Notifications

#### MOD11-P1 Contract

- Objective: the notification contract and payload, so Yuvraj can build tap routing.
- Entry: MOD00-P1-T01 merged.
- Completion and handoff: contract and FX-NTF fixtures on `main`.
- Verification: unit tests.

**MOD11-P1-T01 Define `NotificationService`, `NotificationTarget` and the payload**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-10.4 (contract part) · Type: Shared (ICP-07)
- Objective: a stable IC-05 provider interface.
- Steps: (1) Write the interfaces as in §6.11. (2) Fix the payload: title, body, `type`, `targetId`, `sendId`, no personal data. (3) Add FX-NTF-01 to FX-NTF-08 with Yuvraj.
- Dependencies: MOD00-P1-T01.
- Inputs: §6.11; SEC-CHK-16.
- Outputs: contract; fake; fixtures.
- Acceptance: Yuvraj approves; fixtures parse.
- Tests: unit tests.
- Blocked by: DEC-013 (spike until AGREED).
- Done when: DoD-TASK.

#### MOD11-P2 Delivery, preferences and dispatch

- Objective: notifications reach opted-in devices by category and are logged.
- Entry: MOD14-P2-T03 deployed; MFW's Apple account active.
- Completion and handoff: a test notification reaches both platforms; Yuvraj can test taps.
- Verification: AC-9.1, AC-9.2, AC-9.4, AC-9.5.

**MOD11-P2-T01 Set up push in MFW's accounts**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-10.1 · Type: Own
- Objective: delivery through Android and iOS push services (INT-PUSH-001, INT-PUSH-002).
- Steps: (1) Configure the push provider. (2) Add the iOS credential (CFG-10) in MFW's Apple account. (3) Send a test to an Android and an iOS device.
- Dependencies: MOD14-P2-T03; MOD18-P1-T01.
- Inputs: TD-13.
- Outputs: configuration; evidence of a test delivery.
- Acceptance: a test notification reaches both devices.
- Tests: manual, recorded.
- Blocked by: DEC-003; Apple Developer account active (S1: end of Week 4).
- Done when: DoD-TASK.

**MOD11-P2-T02 Permission explanation, categories and device registration**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-10.2 · Type: Own
- Objective: explain before the system prompt, let the reader choose and change categories (FR-NOTIF-001 to FR-NOTIF-003, FR-NOTIF-006, FR-NOTIF-007).
- Steps: (1) Build SCR-A-20 and SCR-A-21. (2) Read categories from OP-05. (3) Save preferences through OP-09; register the device for logged-out visitors as a device subscription (OQ-09 working position).
- Dependencies: MOD11-P2-T01; MOD13-P1-T01.
- Inputs: OQ-09, OQ-18 working positions.
- Outputs: code; tests.
- Acceptance: AC-9.1 passes; the candidate check for FR-NOTIF-003 passes: after changing categories, only the new choice arrives.
- Tests: widget tests; manual delivery test.
- Blocked by: OQ-09; OQ-18.
- Done when: DoD-FEAT.

**MOD11-P2-T03 Dispatch by category and the send log**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-10.3 (server part) · Type: Own
- Objective: an admin send reaches only devices that chose the category and is logged (FR-NOTIF-004, FR-ADMIN-016 to FR-ADMIN-018).
- Steps: (1) Implement OP-25, OP-26 and OP-27. (2) Check the admin role on the server. (3) Write one send record per send (DATA-008). (4) Test.
- Dependencies: MOD11-P2-T01; MOD13-P1-T03.
- Inputs: OQ-19.
- Outputs: functions; tests.
- Acceptance: AC-9.2, AC-9.4 and AC-9.5 pass.
- Tests: function tests; manual delivery test.
- Blocked by: DEC-003; OQ-19 for the log fields.
- Done when: DoD-FEAT.

**MOD11-P2-T04 Remove tokens on sign-out and deletion**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (OQ-55, TD-13) · Type: Own
- Objective: a signed-out or deleted reader's device stops receiving reader-specific notifications.
- Steps: (1) Test on the emulator whether token removal ends topic subscriptions. (2) Implement removal in OP-12 and on sign-out. (3) Record the result for OQ-55.
- Dependencies: MOD11-P2-T02; MOD13-P1-T06.
- Inputs: OQ-55.
- Outputs: code; spike evidence.
- Acceptance: after sign-out or deletion the device is unregistered as the agreed answer to OQ-55 says.
- Tests: function test; manual check.
- Blocked by: OQ-55 (AGREED entry).
- Done when: DoD-TASK.

#### MOD11-P3 End-to-end acceptance

- Objective: notifications pass AC-9 end to end with Yuvraj's tap routing.
- Entry: MOD11-P2 done; MOD01-P3-T01 merged.
- Completion and handoff: ICP-07 accepted.
- Verification: AC-9.1 to AC-9.7.

**MOD11-P3-T01 Run notification acceptance end to end**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (IC-05) · Type: Shared (ICP-07)
- Objective: evidence for AC-9 on both platforms.
- Steps: (1) Send each FX-NTF payload from the panel. (2) With Yuvraj, check each tap's screen or prompt for each access state. (3) Record results.
- Dependencies: MOD11-P2-T03; MOD12-P2-T05; MOD01-P3-T01.
- Inputs: AC-9; FX-NTF-01 to FX-NTF-08.
- Outputs: evidence record.
- Acceptance: AC-9.1 to AC-9.7 pass, or defects are logged.
- Tests: manual on devices, recorded.
- Blocked by: DEC-003; Apple account.
- Done when: ICP-07 accepted.

### Module MOD-12: Admin and Content Management

#### MOD12-P1 Skeleton and first admin

- Objective: an admin panel that serves a sign-in page and a secure way to create the first admin.
- Entry: none for the spike; DEC-004 for the final skeleton.
- Completion and handoff: panel skeleton in ENV-TEST; first-admin step documented.
- Verification: build and serve; bootstrap test.

**MOD12-P1-T01 Admin panel skeleton with a sign-in page**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-01.6 · Type: Own
- Objective: an `admin/` project that builds and serves a sign-in page.
- Steps: (1) Create `admin/` with the technology under DEC-004 (React, TD-14, PROPOSED), as a spike until agreed. (2) Add build and test scripts for QG-09. (3) Serve SCR-W-01 in ENV-TEST.
- Dependencies: MOD14-P2-T03 for ENV-TEST.
- Inputs: TD-14; DEC-004.
- Outputs: `admin/` skeleton.
- Acceptance: builds and serves the sign-in page in ENV-TEST.
- Tests: build check; one smoke test.
- Blocked by: DEC-004 (spike until AGREED).
- Done when: DoD-TASK.

**MOD12-P1-T02 First-admin bootstrap step**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-09.1 (part); OP-42 · Type: Own
- Objective: create the first admin securely from MFW's admin list, and recover if no admin is left (SC-14). Needed whatever OQ-58 decides.
- Steps: (1) Write a developer-run step that grants the admin role to a named, verified account, recorded with who and when. (2) Write the recovery step. (3) Document both in `DEPLOYMENT_PLAN.md` §7.5 by pull request. (4) Test in ENV-TEST.
- Dependencies: MOD13-P1-T03.
- Inputs: OP-42; SC-13, SC-14; DEC-027.
- Outputs: script or procedure; documentation; test evidence.
- Acceptance: the step creates exactly one admin from a verified account; no credential in the repository.
- Tests: function or script test in ENV-TEST.
- Blocked by: DEC-003; MFW's admin list (S1: Weeks 5 and 6) for production.
- Done when: DoD-TASK. If MFW declines in-panel management (OQ-58), this step is also how later admins are added from MFW's list.

#### MOD12-P2 Admin sign-in and content operations

- Objective: MFW's editors run the catalogue, news controls, notifications and reader list without developer help.
- Entry: MOD12-P1 done; DEC-004 AGREED; MOD13-P1-T03 deployed; admin screens approved at M2.
- Completion and handoff: IC-06 and IC-07 pass with Yuvraj's checks (ICP-04, ICP-06).
- Verification: AC-8.1 to AC-8.9, PAC-03.

**MOD12-P2-T01 Admin sign-in and role check**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-09.1 · Type: Own
- Objective: wrong passwords and non-admin accounts are refused (FR-ADMIN-002 to FR-ADMIN-004, NFR-SEC-011).
- Steps: (1) Sign in through the identity provider. (2) Call OP-14 and refuse non-admins. (3) Apply the secure-login measures OQ-20 sets (working position: password, verified email, recent-sign-in check, no second factor). (4) End the session when the role is removed.
- Dependencies: MOD12-P1-T01; MOD12-P1-T02.
- Inputs: SC-01 to SC-04; SEC-CHK-08.
- Outputs: code; tests.
- Acceptance: AC-8.1, AC-8.2 and SEC-CHK-08 pass.
- Tests: component tests; manual sign-in tests.
- Blocked by: DEC-004; OQ-20; OQ-56.
- Done when: DoD-FEAT.

**MOD12-P2-T02 Staged upload with server-side validation**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-09.2 · Type: Own
- Objective: upload a PDF and cover; the backend rejects a non-PDF or an oversized file (FR-ADMIN-005 to FR-ADMIN-008, NFR-SEC-008).
- Steps: (1) Implement OP-19 to a holding area. (2) Implement OP-40 to validate after upload: real PDF, size limit CFG-05, cover rules. (3) Move only valid files. (4) Show OP-20 job status on SCR-W-04 with clear messages (FR-STATE-007).
- Dependencies: MOD12-P2-T01; MOD13-P1-T03.
- Inputs: FX-PDF-06 to FX-PDF-09; FX-ADM-*; OQ-22; OQ-30.
- Outputs: functions; panel screens; tests.
- Acceptance: AC-8.3 to AC-8.5 and SEC-CHK-07 pass.
- Tests: function tests with the upload fixtures; component tests.
- Blocked by: DEC-003; OQ-22 (cover rules); OQ-30 (exact limit, MB meaning, protected PDFs).
- Done when: DoD-FEAT.

**MOD12-P2-T03 Issue details, categories, segments and publishing**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-09.3 · Type: Shared (ICP-04)
- Objective: enter and edit issue details, maintain categories and segments, publish and unpublish (FR-ADMIN-009 to FR-ADMIN-011).
- Steps: (1) Build SCR-W-02, SCR-W-03 and SCR-W-05. (2) Call OP-15 to OP-18, OP-21 and OP-22. OP-28 is not built on the working position (GS-Q47, GS-Q56). (3) Seed the 16 industry segments (OQ-13 working position). (4) Refuse deleting a category in use.
- Dependencies: MOD12-P2-T02.
- Inputs: IC-07; OQ-13.
- Outputs: screens; tests.
- Acceptance: AC-8.6 and AC-8.7 pass; IC-07 passes with Yuvraj's check.
- Tests: component tests; IC-07.
- Blocked by: DEC-004; OQ-13 for the lists.
- Done when: DoD-FEAT; ICP-04 passes.

**MOD12-P2-T04 News controls**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-09.4 · Type: Shared (ICP-06)
- Objective: hide a WordPress post in the app, mark it as breaking and send it as a breaking-news notification (FR-ADMIN-013 to FR-ADMIN-015).
- Steps: (1) Build SCR-W-06 listing posts through OP-24. (2) Save controls through OP-23. (3) Start a breaking-news send through MOD11-P2-T03.
- Dependencies: MOD12-P2-T01; MOD13-P1-T03.
- Inputs: IC-06; OQ-17; OQ-39.
- Outputs: screen; functions; tests.
- Acceptance: AC-8.8 and AC-9.7 pass; IC-06 passes.
- Tests: component tests; IC-06.
- Blocked by: DEC-004; OQ-39 (WordPress address); OQ-17 for the breaking presentation.
- Done when: DoD-FEAT; ICP-06 passes.

**MOD12-P2-T05 Send-notification and send-log screens**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-10.3 (panel part) · Type: Own
- Objective: admins send a category notification linked to an issue or article and see the log.
- Steps: (1) Build SCR-W-07 and SCR-W-08. (2) Call OP-25 to OP-27. (3) Validate inputs before sending.
- Dependencies: MOD11-P2-T03; MOD12-P2-T01.
- Inputs: AC-9.
- Outputs: screens; tests.
- Acceptance: AC-9.4 and AC-9.5 pass from the panel.
- Tests: component tests.
- Blocked by: DEC-004; OQ-18; OQ-19.
- Done when: DoD-FEAT.

**MOD12-P2-T06 Registered-user list and CSV export (PROVISIONAL)**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-09.5 · Type: Own
- Objective: admins view registered readers with profile fields and export them to CSV (FR-USER-002, FR-USER-003, NFR-PRIV-004).
- Steps: (1) Implement OP-31 with cursor paging and OP-32. (2) Escape formula injection in the CSV. (3) Build SCR-W-09.
- Dependencies: MOD12-P2-T01; MOD13-P1-T01.
- Inputs: PAC-03; SEC-CHK-12; OQ-51.
- Outputs: functions; screen; tests.
- Acceptance: PAC-03 and SEC-CHK-12 pass. AC-8.9 is met only if MFW reads "subscriber list" as this list (OQ-31).
- Tests: function tests including formula-injection rows.
- Blocked by: OQ-29 (S3 confirmation); OQ-31; OQ-51.
- Done when: DoD-FEAT.

#### MOD12-P3 Decisions MFW has not made

- Objective: build the admin features that wait on MFW only after MFW answers.
- Entry: the named question answered in writing.
- Completion and handoff: features match the written answer.
- Verification: PAC-19; the OQ-21 decision.

**MOD12-P3-T01 Unpublish, replace or permanently delete an issue**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-09.6 · Type: Own
- Objective: whatever OQ-21 allows, with a replacement validated before the old file is removed.
- Steps: (1) Implement replacement as a new revision through OP-19 and OP-40. (2) If allowed, implement OP-30 for an unpublished issue with a typed confirmation, adding the issue to OP-03. (3) Test.
- Dependencies: MOD12-P2-T03; MOD13-P1-T05.
- Inputs: OQ-21 working position (GS-Q45).
- Outputs: functions; screens; tests.
- Acceptance: behaviour matches MFW's written answer to OQ-21.
- Tests: function and component tests.
- Blocked by: OQ-21.
- Done when: DoD-FEAT.

**MOD12-P3-T02 In-panel admin management (pending OQ-58)**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-09.7 · Type: Own
- Objective: any admin finds a registered, verified reader by email, adds them as an admin, and removes an admin, with the last-admin guard and a narrow change record (DEC-027).
- Steps: (1) Implement OP-34, OP-35, OP-37, OP-38 and OP-39. (2) Require a recent sign-in (OQ-56). (3) Refuse removing the last admin, including two admins acting at once (SC-10, SC-11). (4) Record only who added or removed whom, and when. (5) Build SCR-W-11 with a confirmation that names the person. (6) Test a removed admin.
- Dependencies: MOD12-P2-T01; MOD12-P1-T02.
- Inputs: PAC-19; SC-09 to SC-13.
- Outputs: functions; screen; tests.
- Acceptance: PAC-19 passes.
- Tests: function tests including concurrent removal; component tests.
- Blocked by: **OQ-58 (MFW's written answer, and a change request if MFW calls it a change)**; OQ-56; DEC-003; DEC-004. Not estimated.
- Done when: DoD-FEAT. If MFW declines, close the task as "Not in scope" and use MOD12-P1-T02 for later admins.

### Module MOD-16: Screen Design and M2 Prototype (Sanika Attarde's tasks)

The module owner is Yuvraj. Sanika Attarde owns the three tasks below. The phase descriptions are in the Yuvraj roadmap.

**MOD16-P1-T03 Account, profile, settings and notification screens**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-02.1 (part) · Type: Shared (ICP-09)
- Objective: designs for SCR-A-01 to SCR-A-08, SCR-A-20 and SCR-A-21, with loading, empty and error states (SCR-A-09 is withdrawn).
- Steps: (1) Use Yuvraj's design tokens. (2) Draw each screen and state. (3) Hand the frames to Yuvraj for the prototype.
- Dependencies: MOD16-P1-T01.
- Inputs: `SCREEN_INVENTORY_AND_NAVIGATION.md`; OQ-01; OQ-09; OQ-18.
- Outputs: screen designs.
- Acceptance: every listed screen and state is drawn; reviewed by Yuvraj.
- Tests: design review against the inventory.
- Blocked by: MFW brand assets.
- Done when: frames in the prototype.

**MOD16-P1-T04 Admin panel screens**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-02.2 · Type: Own
- Objective: designs for SCR-W-01 to SCR-W-09; SCR-W-11 drawn and marked pending OQ-58. SCR-W-10 and SCR-W-12 are not drawn.
- Steps: (1) Draw each screen with result states (FR-STATE-007). (2) Mark SCR-W-11 as pending MFW's answer.
- Dependencies: MOD16-P1-T01.
- Inputs: `SCREEN_INVENTORY_AND_NAVIGATION.md`; OQ-20; OQ-22; OQ-31.
- Outputs: admin designs.
- Acceptance: covers RS §5.12 and §5.13 as scoped.
- Tests: design review.
- Blocked by: MFW brand assets; OQ-20, OQ-22.
- Done when: reviewed by Yuvraj.

**MOD16-P2-T01 Present the designs and reader result to MFW**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-02.5 · Type: Shared (ICP-09)
- Objective: MFW's written M2 approval of the screens and the reader approach.
- Steps: (1) Send the prototype and reader test report. (2) Run the review. (3) Collect one consolidated feedback list. (4) File the written approval.
- Dependencies: MOD16-P1-T05; MOD07-P1-T02.
- Inputs: S2 M2.
- Outputs: filed M2 approval; feedback list.
- Acceptance: MFW's written approval is filed, or an agreed alternative is recorded.
- Tests: none.
- Blocked by: MFW's review.
- Done when: DoD-DOC; ICP-09 accepted.

### Module MOD-18: Release and Store Submission

#### MOD18-P1 Identifiers and signing

- Objective: app identifiers, store records and signing in MFW's accounts.
- Entry: OQ-42 answered; store accounts active.
- Completion and handoff: tagged signed builds possible.
- Verification: QG-13.

**MOD18-P1-T01 App identifiers and store records**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (AND-01 to AND-03, IOS-01, IOS-02) · Type: Own
- Objective: the app name, Android application ID and iOS bundle ID, and the app records in MFW's store accounts.
- Steps: (1) Propose reverse-domain identifiers based on MFW's site (OQ-42). (2) Get MFW's written confirmation. (3) Create the records. (4) Record CFG-15.
- Dependencies: MOD20-P2-T02.
- Inputs: `APP_STORE_RELEASE_CHECKLIST.md`.
- Outputs: identifiers; store records.
- Acceptance: identifiers confirmed in writing; records exist.
- Tests: none.
- Blocked by: OQ-42; MFW's Apple and Google accounts.
- Done when: DoD-TASK.

**MOD18-P1-T02 Signing and a tagged release build**
- Owner: Sanika Attarde · Support: Yuvraj (pipeline) · Parent: T-12.2 · Type: Shared (ICP-12)
- Objective: signed Android and iOS builds from a release tag (NFR-MAINT-003, AC-11.1).
- Steps: (1) Set up signing in MFW's accounts, keys held by MFW. (2) Give the pipeline access without putting secrets in the repository. (3) Build from a tag with Yuvraj's workflow.
- Dependencies: MOD18-P1-T01; MOD15-P3-T01.
- Inputs: QG-13; DEC-015.
- Outputs: signed builds; credential record updated.
- Acceptance: AC-11.1 passes.
- Tests: build from a tag, recorded.
- Blocked by: signing set-up in MFW's accounts.
- Done when: DoD-RC items for signing met.

#### MOD18-P2 Listing and submission

- Objective: listings approved by MFW and both builds submitted.
- Entry: MOD17-P3-T05 sign-off; MOD18-P1 done.
- Completion and handoff: confirmations held by MFW (HO-12).
- Verification: AC-11.2 to AC-11.4.

**MOD18-P2-T01 Store listings, screenshots and privacy declarations**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-12.1 · Type: Own
- Objective: listing text approved by MFW and privacy details that match MFW's policy (NFR-PRIV-002).
- Steps: (1) Build the data-collection inventory. (2) Prepare Apple App Privacy and Google Data safety answers with MFW (OQ-44). (3) Take screenshots. (4) Get MFW's approval of the text.
- Dependencies: MOD17-P3-T04.
- Inputs: MFW's listing text; OQ-44.
- Outputs: listing package (HO-08).
- Acceptance: AC-11.2 and AC-11.3 pass.
- Tests: review against the checklist.
- Blocked by: OQ-44; MFW listing text.
- Done when: DoD-DOC.

**MOD18-P2-T02 Reviewer access and the deletion web link**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (COM-05, AND-10, IOS-13) · Type: Own
- Objective: store reviewers can sign in, and Google Play's deletion-request link exists.
- Steps: (1) If MFW approves (OQ-43), create a reviewer account held by MFW. (2) Confirm MFW publishes the deletion page on its own site (OQ-45 working position).
- Dependencies: MOD14-P3-T01.
- Inputs: OQ-43; OQ-45.
- Outputs: reviewer account details held by MFW; link recorded.
- Acceptance: both items ready before submission.
- Tests: sign-in with the reviewer account in production.
- Blocked by: OQ-43; OQ-45.
- Done when: DoD-TASK.

**MOD18-P2-T03 Submit both builds and send the confirmations**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-12.3 · Type: Shared (ICP-12)
- Objective: both builds submitted through MFW's store accounts (INT-STORE-001, AC-11.4).
- Steps: (1) Submit the signed builds. (2) Send the confirmations to MFW. (3) Record the submission date for the warranty.
- Dependencies: MOD18-P1-T02; MOD18-P2-T01; MOD18-P2-T02; MOD17-P3-T05.
- Inputs: AC-11.
- Outputs: submission confirmations.
- Acceptance: AC-11.4 passes; M5 condition met at submission.
- Tests: none.
- Blocked by: MFW's store accounts.
- Done when: DoD-RC; confirmations held by MFW.

### Module MOD-19: Handover, Backup and Operations

#### MOD19-P1 Backup and monitoring

- Objective: proposed backup and monitoring access, only as MFW decides.
- Entry: MOD14-P2 done; OQ-46 and OQ-47 answered.
- Completion and handoff: restore tested once; MFW holds alert access.
- Verification: restore evidence.

**MOD19-P1-T01 Configure backups and test one restore**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (HO-14, `BACKUP_AND_RECOVERY.md`) · Type: Own
- Objective: backups as MFW decides, and one restore into ENV-TEST that re-applies deletions.
- Steps: (1) Configure managed backups. (2) Restore into ENV-TEST. (3) Re-apply deletions from the purged-identifier list if OQ-24 allows it. (4) Record.
- Dependencies: MOD14-P3-T01.
- Inputs: OQ-46; DEC-029.
- Outputs: backup configuration; restore record.
- Acceptance: a restore completes and deleted readers stay deleted.
- Tests: restore rehearsal, recorded.
- Blocked by: OQ-46 (a proposed addition, not an S2 deliverable); OQ-24; DEC-003.
- Done when: DoD-TASK; HO-14 met.

**MOD19-P1-T02 Monitoring access and incident contacts for MFW**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: New (HO-13, OQ-47) · Type: Own
- Objective: MFW receives crash and service alerts and has named incident contacts.
- Steps: (1) Give MFW access to crash and log consoles. (2) Record contacts in `SECURITY_INCIDENT_PROCEDURE.md` by pull request.
- Dependencies: MOD02-P2-T01.
- Inputs: OQ-47.
- Outputs: access granted; contacts recorded.
- Acceptance: HO-13 met.
- Tests: a test alert reaches MFW's contact.
- Blocked by: OQ-47.
- Done when: DoD-TASK.

#### MOD19-P2 Handover

- Objective: everything S2 AC-12 and Handover require.
- Entry: MOD18-P2-T03 submitted.
- Completion and handoff: MFW agrees the handover at M5.
- Verification: AC-12.1 to AC-12.3; DoD-HO.

**MOD19-P2-T01 Technical documentation**
- Owner: Sanika Attarde · Support: Yuvraj (app parts) · Parent: T-12.4 (part) · Type: Own
- Objective: set-up, deployment, data model, security rules and third-party licences (NFR-MAINT-004, HO-02, HO-11).
- Steps: (1) Collect each section from its owner. (2) Check the steps on a clean machine. (3) Export the dependency list with licences.
- Dependencies: MOD14-P3-T01.
- Inputs: `MAINTENANCE_AND_HANDOVER.md`; `DEPENDENCY_REGISTER.md`.
- Outputs: documentation set.
- Acceptance: HO-02 and HO-11 met.
- Tests: Yuvraj follows the set-up steps once.
- Blocked by: none beyond earlier tasks.
- Done when: DoD-DOC.

**MOD19-P2-T02 Administrator guide and training**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-12.4 (part) · Type: Own
- Objective: a short admin guide and live training of up to two hours (HO-06, HO-07).
- Steps: (1) Write the guide, including adding admins (in the panel, or by the bootstrap step if MFW declined OQ-58). (2) Run the session. (3) Record attendance.
- Dependencies: MOD12-P2-T06.
- Inputs: S2 Handover.
- Outputs: guide; training record.
- Acceptance: HO-06 and HO-07 met.
- Tests: none.
- Blocked by: MFW's availability.
- Done when: DoD-DOC.

**MOD19-P2-T03 Credential record, known limitations and warranty records**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-12.5 · Type: Own
- Objective: who holds each credential, the known limitations, and the warranty dates (HO-04, HO-05, HO-10, HO-15, HO-16).
- Steps: (1) List every credential and its holder, without values. (2) List known limitations and outstanding issues. (3) Record the warranty start and end. (4) Remove the developers' access when MFW asks (SCP-091).
- Dependencies: MOD18-P2-T03.
- Inputs: `MAINTENANCE_AND_HANDOVER.md`.
- Outputs: records.
- Acceptance: HO-04, HO-05, HO-10, HO-15 and HO-16 met.
- Tests: none.
- Blocked by: none.
- Done when: DoD-DOC.

**MOD19-P2-T04 Repository transfer and clean-copy rebuild**
- Owner: Sanika Attarde · Support: Yuvraj · Parent: T-12.6 · Type: Shared (ICP-12)
- Objective: MFW owns the repository with full history, and a clean copy builds the app and deploys the backend to a fresh project (AC-12).
- Steps: (1) Agree the method and order with MFW (OQ-48). (2) Transfer. (3) With Yuvraj, rebuild from a clean clone into a fresh project following the documentation. (4) Record.
- Dependencies: MOD19-P2-T01.
- Inputs: OQ-48; AC-12.
- Outputs: transferred repository; rebuild record.
- Acceptance: AC-12.1 to AC-12.3 pass.
- Tests: the clean-copy rebuild.
- Blocked by: OQ-48; final invoice (S1).
- Done when: DoD-HO.

## 6. Integration Checkpoints

Copied from inventory section 10 for the checkpoints that involve Sanika Attarde. The inventory wins if they differ.

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

Taken from `TESTING_STRATEGY.md`, `CI_CD_AND_QUALITY_GATES.md` and `DEFINITION_OF_DONE.md`. No coverage percentage or performance figure is added here.

| Level | What Sanika Attarde owns |
|---|---|
| Unit tests | Auth, profile, consent, notification and error-mapping logic with fakes (QG-03) |
| Widget and UI tests | SCR-A-01 to SCR-A-08, SCR-A-20, SCR-A-21; admin panel component tests (QG-09) |
| API and backend tests | Allowed and refused rule tests for every operation and access state; function tests for OP-11, OP-12, OP-19, OP-40, OP-25 to OP-27, OP-31, OP-32, OP-34 to OP-39 (QG-08) |
| Integration tests | Server sides of IC-01, IC-02, IC-04, IC-05, IC-06, IC-07; the server check of IC-08 |
| Security tests | SEC-CHK-02, SEC-CHK-03, SEC-CHK-05 to SEC-CHK-08, SEC-CHK-10 to SEC-CHK-12, SEC-CHK-14, SEC-CHK-16 to SEC-CHK-19 evidence for MOD17-P3-T03 |
| Regression | Re-run the rule suite and auth flows for every change to `backend/` rules or `auth.dart` |
| Performance | None owned. Grant issue time and upload validation time are recorded, not judged. |
| CI gates | QG-08 and QG-09 suites provided to Yuvraj's pipeline; QG-11 must stay clean |
| Manual acceptance | AC-3, AC-8, AC-9, AC-11, AC-12; PAC-01, PAC-02, PAC-03, PAC-06, PAC-08, PAC-12, PAC-13, PAC-17, PAC-19 |

## 8. Delivery Checklist

- [ ] MOD20-P1-T01 filed: the PROPOSED engineering decisions are AGREED or have recorded objections.
- [ ] Every task in section 5 meets its "Done when" line, with evidence linked in its pull request.
- [ ] Every rule change merged with its rule tests (QG-08 green).
- [ ] ICP-01 to ICP-12 accepted, with results recorded.
- [ ] No task that waits on an MFW answer was built as final before the answer was filed.
- [ ] No excluded item (EXC-01 to EXC-23) and no dropped item (edition-update sign-up) was built.
- [ ] No credential or reader data in the repository (SEC-CHK-09, QG-11).
- [ ] `DEPENDENCY_REGISTER.md` has an entry for every package added; no paid component without MFW's written approval.
- [ ] `CHANGELOG.md` and the affected documents updated for each merged change.
- [ ] DoD-RC and DoD-HO met; MFW holds the store confirmations and the repository.

## 9. Outstanding Decisions

| ID | Question (short) | Why it matters | Blocks | Who answers | MFW approval |
|---|---|---|---|---|---|
| DEC-003 / OQ-35 | Backend platform | Every backend task | MOD13-*, MOD14-P2-*, MOD14-P3-T01, MOD03-P2-*, MOD11-P2-*, MOD12-P2-* | Both developers; MFW if it differs from S2 or adds cost | Conditional |
| DEC-004 | Admin technology | The panel's code | MOD12-P1-T01 (final), MOD12-P2-* | Both developers; MFW if it differs from S2 | Conditional |
| DEC-020 / OQ-37 | File delivery and grant lifetime | OP-11 and resume | MOD13-P1-T04 | Both developers | Only if it adds cost |
| DEC-023 / OQ-40 | Separate test project | ENV-TEST | MOD14-P2-T01, MOD14-P2-T02 | Both developers and MFW | Yes |
| DEC-031 / OQ-41, OQ-53 | Region and cost ceiling | Cannot change after creation | MOD14-P2-T02, MOD14-P3-T01 | MFW and its legal adviser | Yes |
| DEC-006 / OQ-04, OQ-05, OQ-06, OQ-29 | Google Sign-In scope and rules | Feature scope | MOD03-P3-T02 | MFW; both developers for the rule | Yes |
| DEC-027 / OQ-58, OQ-56 | In-panel admin management | Not in S2 or S1 | MOD12-P3-T02 | MFW | Yes, and a change request if MFW calls it a change |
| OQ-20 | Secure admin login measures | Admin sign-in | MOD12-P2-T01 | MFW with the team | Yes |
| OQ-21 | Delete or replace an issue | Safeguards | MOD12-P3-T01, MOD13-P1-T05 | MFW | Yes |
| OQ-22, OQ-30 | Cover rules; size limit | Upload validation | MOD12-P2-T02 | MFW with the team | Yes |
| OQ-31 / DEC-032 | Edition-update sign-up | Dropping an S2 item | No task; MOD12-P2-T06 acceptance wording | MFW | Yes |
| OQ-51 | Who sees the reader list | Export | MOD12-P2-T06 | MFW | Yes |
| OQ-01, OQ-02, OQ-03, OQ-07, OQ-27 | Profile fields, age, consent | Profile and consent | MOD04-P2-T01, MOD04-P2-T02 | MFW; legal adviser for OQ-07 | Yes |
| OQ-09, OQ-18, OQ-19 | Notifications for visitors, categories, log fields | Notification behaviour | MOD11-P2-T02, MOD11-P2-T03 | MFW | Yes |
| OQ-55 | Token removal and topics | Clean-up | MOD11-P2-T04 | Both developers | No |
| DEC-028 / OQ-23 | Usage events and consent | Analytics | MOD02-P2-T01, MOD02-P2-T02 | MFW | Yes |
| DEC-029 / OQ-24 | Retention | Deletion and backups | MOD13-P1-T06, MOD19-P1-T01 | MFW and its legal adviser | Yes |
| OQ-42, OQ-43, OQ-44, OQ-45 | Store identifiers, reviewer account, privacy declarations, deletion link | Release | MOD18-* | MFW | Yes |
| OQ-46, OQ-47, OQ-48 | Backup, monitoring contacts, repository transfer | Handover | MOD19-* | MFW | Yes |
| OQ-28, OQ-29, OQ-34, OQ-59 | Approver, S3 record, two developers, chat approvals | Every approval | MOD20-P2-* | MFW | Yes |

## 10. Handover Requirements

For another developer to continue Sanika Attarde's work:

- **Code and tests.** Each module's code under the paths in `CODING_STANDARDS.md` §3, with its tests in the same pull request. Rule tests runnable locally on the emulator with one command, documented in `backend/README`.
- **Configuration.** The configuration example (MOD14-P1-T01) lists every CFG item, where its value lives, and who holds it. No secret is in the repository.
- **Environments.** ENV-TEST and ENV-PROD set-up and deploy steps (MOD14-P2-T03, MOD14-P3-T01), including the region and the reason for it.
- **Decisions.** Every decision taken during the work recorded in `DECISION_LOG.md` with its evidence; every MFW answer filed by reference in `OPEN_QUESTIONS.md`.
- **Admin access.** The first-admin and recovery steps (MOD12-P1-T02), and whether MFW manages admins in the panel (OQ-58).
- **Open work.** Each unfinished task's state recorded in its pull request or in `DEVELOPMENT_ROADMAP.md` §4, with what blocks it.
- **Credentials.** The credential-holder record (HO-04), without values.
- **Ownership change.** Follows `TASK_OWNERSHIP_MATRIX.md` §11.
