# Sanika Attarde WS-A First-Build Plan: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Sanika Attarde WS-A First-Build Plan |
| File | `Documentation/SANIKA_WSA_IMPLEMENTATION_PLAN.md` |
| Assigned developer | Sanika Attarde (workstream WS-A, PROPOSED under DEC-011) |
| Version | 0.2 |
| Last updated | 7 November 2026 |
| Status | Draft for review. Not approved. A plan. It approves no decision, requirement or scope item and starts no task. |
| Source of the task list | Sanika Attarde's WS-A list of 30 October 2026. It matches the WS-A half of `DEVELOPMENT_ROADMAP.md` section 4.3, which is on Yuvraj's open pull request 6 and has not been reviewed by Sanika Attarde |
| Builds on | `SANIKA_IMPLEMENTATION_ROADMAP.md` v0.1 (task IDs), `IMPLEMENTATION_MODULE_INVENTORY.md` v0.1 (module IDs). Both are in this repository since version 0.2 of this plan |
| Repository evidence | `origin/main` at `8083595`, fetched on 30 October 2026, plus the open branches `docs/yg-remaining-docs` (pull request 6) and `docs/sa-contracts-segments-and-ownership` (pull request 7) |
| Estimates | None. The repository gives none for these tasks, and this plan adds none |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 30 October 2026 | First draft. |
| 0.2 | 7 November 2026 | Committed to the repository, unchanged apart from a status note after this table, the version, the date, and two wording fixes (a tool name in the PRE-01 row, and the statement that two companion documents are untracked). The plan, its task IDs and its order of work are not changed. |

**Status note of 7 November 2026.** This document was written on 30 October 2026 on top of commit `bd2db98`, and it is committed here as a record of the plan. Apart from this note, the version, the date and a few wording fixes, it is unchanged. The sections below describe the repository, the open pull requests and the open decisions as they were on 30 October 2026, and are not updated. Since then the Flutter app scaffold (pull request 30) and the shared contracts and fakes (pull request 34) are on `main`; the backend and admin panel spikes are done, and their evidence reports are in `Documentation/test-evidence/` (emulator only, not merged); both developers' written notes are filed, and DEC-010 to DEC-015, DEC-022 and DEC-024 to DEC-030 are AGREED (`DECISION_LOG.md` sections 5.6 and 5.8); and the second-person reviews of issues 28, 29, 31 and 32 are recorded in pull requests 33 to 46. `README.md`, `CHANGELOG.md` and `DEVELOPMENT_ROADMAP.md` give the current state. The task IDs and the order of work stay as the plan. On the toolchain (PRE-01), Flutter 3.47.9 (revision `c197ca5`) was installed on Sanika Attarde's machine on 7 November 2026, and on `main` `flutter pub get --enforce-lockfile`, `dart format`, `flutter analyze` and `flutter test` (94 tests) pass. A Java runtime and the platform's command-line tool were not installed in that pass.

## 2. Summary

1. **Nothing in the list is built.** `origin/main` holds `README.md` and 37 files in `Documentation/`. There is no `app/`, `backend/` or `admin/`, no `.gitignore`, no CI workflow and no other branch with code. The list is therefore 13 items to build and 6 items to hold.
2. **One item is already done.** Sanika Attarde's written agreement is filed (`DECISION_LOG.md` v0.4 section 5.4, pull request 4, merged 29 October 2026, commit `78e879a`). It is one half of the evidence. Yuvraj's half is not filed, so no entry is AGREED.
3. **Every line of code is spike work.** DEC-003 (backend), DEC-004 (admin technology) and DEC-020 (file delivery) are OPEN, and the 14 decisions Sanika Attarde accepted are still PROPOSED. `DEVELOPMENT_WORKFLOW.md` section 13 keeps a spike on a `spike/` branch, never merged as production code. Only its findings merge, as a document. This plan says where each item gets promoted afterwards.
4. **The local machine is not ready.** Node.js (v26.0.0) and npm (11.12.1) are installed. The Firebase command-line tool, Flutter, Dart and a Java runtime are not. The emulators for rules tests need a Java runtime (to be confirmed when set up). Installing them is Sanika Attarde's action; this plan installs nothing.
5. **Ten gaps are added.** They are in section 5 (GAP-01 to GAP-10). The largest three: no MOD-13 task builds the admin record and last-admin guard, although account deletion and every privileged call need it; no MOD-13 task covers `requestUpload` and `onUploadFinalized`; and `T-09.3` and `T-09.4` need three earlier pieces (admin sign-in, the admin-only writes, and an accepted file revision to publish) that the list leaves out.
6. **The list's "no blockers" is true for MFW's inputs, not for sequence.** None of the items in the list needs an MFW answer or input to start. Several need an earlier task of the list to be finished first (section 6).
7. **Recommended order:** foundations (`.gitignore`, toolchain, emulator spike), then MOD-13 in the order of section 8, with the React admin skeleton in parallel. The Dart modules (MOD-02, MOD-03, MOD-11) wait for Yuvraj's scaffold and contracts folder, so contracts and fakes go first because Yuvraj is waiting for them.

## 3. Repository Review

| Check | Finding | Source |
|---|---|---|
| Code on `main` | None. Top level is `Documentation/` and `README.md` | `git ls-tree origin/main` |
| Code on any remote branch | None. `SA`, `YG`, `docs/yg-reconcile-merged-set` add nothing outside `Documentation/`. `docs/yg-remaining-docs` changes `CHANGELOG.md`, `DEVELOPMENT_ROADMAP.md` and `README.md` only | `git diff --name-status origin/main...<branch>` |
| `.gitignore`, CI, configuration example | None. An untracked `.DS_Store` already sits in the repository root | `git status`, tree listing |
| Pull requests | 1 to 5 merged. 6 (Yuvraj, roadmap section 4.3) and 7 (contracts fixes) are open with no review | `gh pr list` |
| Written agreement | Sanika Attarde's positions are on `main` (section 5.4). Pull requests 4 and 5 were merged with no approving review | `DECISION_LOG.md`; `gh pr list` |
| Decisions this work rests on | DEC-003, DEC-004, DEC-020: OPEN. DEC-010 to DEC-015, DEC-022, DEC-024 to DEC-030: PROPOSED, one side filed | `DECISION_LOG.md` |
| Specified, not built | Rules and operations: `API_AND_BACKEND_CONTRACT.md` OP-01 to OP-42. Data: `DATABASE_AND_DATA_MODEL.md`. Access rules: `SECURITY_AND_ACCESS_CONTROL.md` SC-01 to SC-21. App contracts: `API_AND_MODULE_CONTRACTS.md` section 6 | the documents |
| Fixtures | FX-USR, FX-ISS, FX-LIB, FX-NTF, FX-PDF, FX-ADM are PLANNED in `TEST_DATA_AND_FIXTURES.md`. None exists as a file. FX-USR-10 and FX-USR-11 are BLOCKED | `TEST_DATA_AND_FIXTURES.md` |
| Quality gates | QG-08 (backend and rule tests) names no command, because DEC-003 is open. QG-09 likewise | `CI_CD_AND_QUALITY_GATES.md` |
| Local toolchain | `node` v26.0.0, `npm` 11.12.1. `firebase`, `flutter`, `dart`: not found. No Java runtime | shell checks, 30 October 2026 |
| Runtime fit | `TECHNOLOGY_DECISIONS.md` (VS-13) lists Node.js 20 and 22 as supported function runtimes. v26 is not on that list. Whether a newer release is accepted is NOT VERIFIED | `TECHNOLOGY_DECISIONS.md` TD-04 |

## 4. Status of the Requested Items

Status words: **Done**; **Specified, not built** (a design exists, no code); **Not started**; **Gap** (no task builds it yet); **Waits** (held on purpose).

| # | Item in the list | Roadmap tasks | Status | Note |
|---|---|---|---|---|
| 0 | File the written agreement | `MOD20-P1-T01` | **Done** on Sanika Attarde's side | Section 5.4 covers DEC-010 to DEC-015, DEC-022, DEC-024 to DEC-030 and the work split (DEC-011). Yuvraj's evidence is missing |
| 1 | Emulator tests: deny-by-default rules | `MOD14-P1-T02`, `MOD13-P1-T03` | Specified, not built | SC-05; `DATABASE_AND_DATA_MODEL.md` section 19 |
| 2 | Emulator tests: own-records-only access (`T-03.6`, `T-07.1`) | `MOD13-P1-T01`, `MOD13-P1-T02` | Specified, not built | SC-06; NFR-SEC-005, NFR-SEC-006 |
| 3 | `saveProfile` (OP-10) | `MOD13-P1-T01` | Specified, not built | Field list is configuration (OQ-01 to OQ-03 working position) |
| 4 | `getIssueFile` (OP-11) with its checks | `MOD13-P1-T04` | Specified, not built | The contract has check 0 plus six ordered checks (seven in all). DEC-020 is OPEN |
| 5 | `requestUpload` (OP-19) and `onUploadFinalized` (OP-40) | None in MOD-13. Backend part of `MOD12-P2-T02` | **Gap** | New `MOD13-P1-T09` (GAP-02) |
| 6 | Admin record with the last-admin guard | None in MOD-13. Parts of `MOD12-P1-T02` and `MOD12-P3-T02` | **Gap** | New `MOD13-P1-T08` (GAP-01) |
| 7 | Account deletion (`T-03.5`), provisional | `MOD13-P1-T06` | Specified, not built | DEC-029 is PROPOSED. OQ-24 is open |
| 8 | MOD-03 email only, `T-03.1` | `MOD03-P1-T01`, `MOD03-P2-T01` to `MOD03-P2-T03` | Not started | Needs the scaffold. Also needs `MOD04-P1-T01` (GAP-05) |
| 9 | MOD-02 message mapping, log redaction, event allowlist | `MOD02-P1-T01`, `MOD02-P2-T02` | Not started | Needs the scaffold and the shared-file agreement (PRE-05) |
| 10 | MOD-12 skeleton with sign-in page, `T-01.6` | `MOD12-P1-T01` | Not started | Needs no scaffold |
| 11 | MOD-12 publish and unpublish, `T-09.3` | `MOD12-P2-T03` | Not started | Needs `MOD12-P2-T01` and `MOD13-P1-T03` first (GAP-04) |
| 12 | MOD-12 news controls, `T-09.4` | `MOD12-P2-T04` | Not started | Same prerequisites. No dispatch (step 3 of the roadmap task is left out) |
| 13 | MOD-11 preferences only, `T-10.2` | `MOD11-P2-T02` (partly), `MOD11-P1-T01` | Not started | Device registration and push are left out (F-03, OQ-55) |
| W1 | MOD-04 profile | `MOD04-P2-*` | Waits | OQ-01 to OQ-03 |
| W2 | Google Sign-In, `T-03.2` | `MOD03-P3-T02` | Waits | OQ-04, OQ-05, OQ-29 |
| W3 | Upload, `T-09.2` (panel side) | `MOD12-P2-T02` | Waits | OQ-22, OQ-30 |
| W4 | Export, `T-09.5` | `MOD12-P2-T06` | Waits | OQ-29, OQ-31, OQ-51 |
| W5 | Delete and replace, `T-09.6` | `MOD12-P3-T01` | Waits | OQ-21 |
| W6 | Admin management, `T-09.7` | `MOD12-P3-T02` | Waits | OQ-58 |

## 5. Gaps and Hidden Prerequisites Added by This Plan

Proposed task IDs continue the existing numbering in `SANIKA_IMPLEMENTATION_ROADMAP.md`. They are additions for Yuvraj's review (`MOD20-P1-T04`). None is estimated.

| ID | Finding | What the plan does |
|---|---|---|
| GAP-01 | The list asks for the admin record and the last-admin guard under MOD-13, but no MOD-13 task builds them. The roadmap puts bootstrap in `MOD12-P1-T02` and add/remove in `MOD12-P3-T02` (waits for OQ-58). The guard is needed earlier: OP-12 refuses `LAST_ADMIN`, and every privileged call reads the role record | New `MOD13-P1-T08`: the admin record, the guard record and the rule (INV-03), without the in-panel add and remove |
| GAP-02 | The list asks for OP-19 and OP-40 under MOD-13, and also holds `T-09.2`. The roadmap has both operations only inside `MOD12-P2-T02` | New `MOD13-P1-T09`: the backend operations only. The panel side of `T-09.2` and the open rules (cover, exact limit) stay in `MOD12-P2-T02` and wait |
| GAP-03 | The three fixed notification categories (GS-Q47) and the segments are "seeded by the developers", but no task writes the seed | New `MOD13-P1-T10`: seed definitions for the three categories now; the segment list is added when OQ-13 is answered |
| GAP-04 | `T-09.3` and `T-09.4` list no prerequisites, but the roadmap needs `MOD12-P2-T01` (admin sign-in and role check, OP-14) and `MOD13-P1-T03` (admin-only writes). OP-21 refuses `NO_ACCEPTED_FILE`, so publish needs an accepted revision, which comes from `MOD13-P1-T09` or a fixture | Both are added before the panel tasks, in the order of section 8 |
| GAP-05 | `MOD03-P2-T03` combines the session with MOD-04's profile status. MOD-04 is held, but its contract and fake (`MOD04-P1-T01`) are not the held part. The field list is configuration, so OQ-01 does not block it | `MOD04-P1-T01` is added to the MOD-03 block. The MOD-04 screens (`MOD04-P2-*`) stay held |
| GAP-06 | `MOD11-P2-T02` depends on `MOD11-P2-T01` (push set-up in MFW's Apple account). The list leaves push out | `MOD11-P2-T02` is split: the preference screens and the permission explanation are built behind a permission interface with a fake. Device registration and the real permission call wait for `T-10.1` and F-03. `MOD11-P1-T01` (contract and fixtures) is added because Yuvraj's tap routing needs it |
| GAP-07 | `getIssueFile` needs a file-delivery mechanism, and DEC-020 is OPEN. The roadmap also depends on Yuvraj's resume evidence (`MOD06-P1-T02`) | The seven checks are built and tested behind a grant-issuer interface with a test stub. The real signed-link issuer waits for DEC-020 |
| GAP-08 | `MOD12-P2-T03` step 2 in the roadmap calls OP-28, but OP-28 is "not built on the working position" (GS-Q47, GS-Q56; SCR-W-05) | Corrected in the roadmap by this plan's change. This plan does not call OP-28 |
| GAP-09 | QG-08 and QG-09 name no command, and nothing runs the rule tests in CI | `MOD15-P2-T02` (Yuvraj) is told the spike's single run command. No CI is set up here |
| GAP-10 | Deny-by-default has no list to deny against. Every collection, path and operation needs an owner and an actor row first | Step B2.1 builds that inventory from `DATABASE_AND_DATA_MODEL.md` section 19 and `API_AND_BACKEND_CONTRACT.md` before any rule is written |

### 5.1 Plan-level prerequisites

| ID | Prerequisite | Who | Status |
|---|---|---|---|
| PRE-01 | **Toolchain.** A Java runtime, the platform's command-line tool and emulator suite, a Node.js release the function runtime supports (20 or 22 per VS-13), and later Flutter and Dart at the versions pinned by OQ-50 | Sanika Attarde installs. This plan installs nothing | Not ready |
| PRE-02 | **Dependency register.** Each package gets a `DEPENDENCY_REGISTER.md` entry before it is installed (DEC-013 condition; `CODING_STANDARDS.md`). That includes the rules-test library, the functions test library, a PDF-parsing library for OP-40, the React packages and the Dart auth packages | Sanika Attarde, reviewed by Yuvraj | Open |
| PRE-03 | **Spike branches and promotion.** Code goes on `spike/sa-*` branches and is not merged as production code. Each block ends with a spike report that merges as a document. Promotion (a `feat/sa-*` branch and a pull request) needs the relevant decision AGREED, Yuvraj's filed evidence, and Yuvraj's review (`DEFINITION_OF_DONE.md` section 5 check 2) | Both | Open |
| PRE-04 | **Yuvraj's scaffold and contracts folder.** `MOD01-P1-T01` (Flutter scaffold) and `MOD00-P1-T01` (`app/lib/contracts/`). Every Dart task here waits for them | Yuvraj | Not started |
| PRE-05 | **Where `Result` and `AppFailure` live.** To be agreed with Yuvraj in writing before `MOD02-P1-T01`. See section 11, point 1 | Both | Open |

## 6. Ground Rules for Every Block

1. **Label.** Every branch, pull request title, test file header and code comment for this work carries "spike" until the decisions in PRE-03 are AGREED. Account deletion also carries "PROVISIONAL" (DEC-029, OQ-24). Google, export and anything resting on the S3 emails also carry "PROVISIONAL".
2. **No invented values.** Where a value is OPEN, it is configuration with a placeholder clearly named as a placeholder, never a constant that looks decided. The open values here: grant lifetime (CFG-06, OQ-37), upload limit unit and boundary (CFG-05, OQ-30), recent-sign-in window (OQ-56), rate limits (SC-18), age bounds (OQ-07).
3. **Tests in the same change as the rule.** One allowed and one refused test for each rule (`TASK_OWNERSHIP_MATRIX.md` section 8.1). A pass on an emulator is recorded as "emulator only". For concurrency and token cases, `TECHNOLOGY_DECISIONS.md` says an emulator pass alone is not a pass, so those cases are re-run when ENV-TEST exists.
4. **No cloud resource.** Emulators and a throwaway local project name only. No MFW credential, no real configuration value, no reader data, no MFW sample PDF (DEC-024). Test PDFs are generated.
5. **Public repository.** Nothing in a fixture, log, test name or report names a real person or contact, or carries a credential.
6. **Shared files.** Anything in `app/lib/contracts/` or `API_AND_MODULE_CONTRACTS.md` goes in its own small pull request, announced in a draft first, reviewed by both (`DEVELOPMENT_WORKFLOW.md` section 8).
7. **Definition of done.** Each task meets DoD-TASK or DoD-FEAT, but is not called done while it depends on an OPEN or PROPOSED decision. It is "spike complete".
8. **Change log.** One line in `CHANGELOG.md` per merged change.

## 7. Dependency Map

```text
B0 Agreement follow-up                          [no code; any time]
B1 Foundations
├── MOD14-P1-T01 .gitignore, config example     [first; protects a public repository]
├── PRE-01 toolchain                            [Sanika Attarde]
└── MOD14-P1-T02 emulator and rules spike       [after PRE-01]
B2 MOD-13 backend (needs only B1)
├── B2.1 access inventory                       [GAP-10]
├── B2.2 deny-by-default + owner-only rules     [MOD13-P1-T01, T02; T-03.6, T-07.1]
├── B2.3 saveProfile                            [MOD13-P1-T01]
├── B2.4 admin record and guard                 [MOD13-P1-T08]
├── B2.5 admin-only writes, public reads        [MOD13-P1-T03]   needs B2.4
├── B2.6 getIssueFile                           [MOD13-P1-T04]   needs B2.3, B2.5 fixtures
├── B2.7 seed definitions                       [MOD13-P1-T10]
├── B2.8 upload operations                      [MOD13-P1-T09]   needs B2.4, B2.5
├── B2.9 account deletion, PROVISIONAL          [MOD13-P1-T06]   needs B2.2, B2.4
└── B2.10 evidence and hand-off                 [MOD13-P2-T01, emulator part]
B3 MOD-12 admin skeleton (parallel with B2; needs B1 only)
└── MOD12-P1-T01 skeleton and sign-in page      [T-01.6]
B4 Dart contracts and MOD-02, MOD-03            [needs PRE-04, PRE-05]
├── B4.1 contracts and fakes                    [MOD03-P1-T01, MOD04-P1-T01, MOD11-P1-T01]
├── B4.2 MOD-02                                 [MOD02-P1-T01, MOD02-P2-T02]
└── B4.3 MOD-03 email                           [MOD03-P2-T01..T03; needs B2.3 for profile status; emulator from B1]
B5 MOD-12 content (needs B2.4, B2.5, B2.8, B3)
├── MOD12-P2-T01 admin sign-in and role check   [GAP-04]
├── MOD12-P2-T03 publish and unpublish          [T-09.3]
└── MOD12-P2-T04 news controls                  [T-09.4; OP-24 against a fixture]
B6 MOD-11 preferences                           [needs B4.1, B2.2, B2.7]
└── MOD11-P2-T02 (preference part)              [T-10.2]
Waits: W1 to W6 (section 10)
```

## 8. Block Plans

### B0 Written agreement follow-up (`MOD20-P1-T01`)

- **Status.** Done on Sanika Attarde's side. `DECISION_LOG.md` section 5.4 names DEC-010 to DEC-015, DEC-022, DEC-024 to DEC-030 and the DEC-011 work split, with conditions. It is a written note under section 3.1.
- **What it does not do.** It changes no status. DEC-003, DEC-004 and DEC-020 are not in it and stay OPEN. Section 3.1 also needs Yuvraj's approving pull-request review or written note. Pull request 4 was merged with no review.
- **Steps.**
  1. Ask Yuvraj to file one of: an approving review on a pull request that carries section 5.4, or a written note naming each entry accepted or not accepted. Say which entries (the 14 in section 5.4).
  2. When it is filed, open a documentation pull request that sets each accepted entry to AGREED and cites the evidence (`DECISION_LOG.md` section 4, step 3).
  3. Leave an entry PROPOSED, with the objection written down, if Yuvraj does not accept it.
- **Not done by this plan.** No entry is set to AGREED, and no approval is implied.
- **Done when.** Each of the 14 entries is AGREED with a link to both sides, or PROPOSED with an objection.

### B1 Foundations

**MOD14-P1-T01 `.gitignore`, configuration example, README stubs.** Branch `chore/sa-gitignore-and-config-example`. This is not a spike: it changes no behaviour, and it protects the public repository, so it goes first.

1. `.gitignore` covering: macOS (`.DS_Store`, which is already untracked here), IDE folders, Flutter and Dart output, `node_modules`, build output, emulator logs and exported emulator data, service-account key files, `.env` files and local configuration. Check each pattern against what the emulator tooling writes when it is first run.
2. A configuration example listing CFG-01 to CFG-15 by name, with placeholder values only (`DEPLOYMENT_PLAN.md` CFG table).
3. README sections for `app/`, `backend/` and `admin/` set-up, written as "to be completed when the folder exists".
4. Manual secrets search before the pull request (QG-11 does not exist yet).

- **Acceptance.** No credential or real value in the diff; a new developer can see which values are needed.
- **Review.** Yuvraj. Small and dedicated.

**PRE-01 Toolchain (Sanika Attarde).** Install a Java runtime, the platform's command-line tool, and a function-runtime Node.js release (20 or 22). Flutter and Dart can wait for the scaffold (OQ-50 pins the version). Record the versions in the spike report. Confirm in the platform documentation which Java version the emulators need and whether Node.js 26 is accepted, because both are NOT VERIFIED here.

**MOD14-P1-T02 Emulator and rules spike.** Branch `spike/sa-backend-rules`.

1. Create the spike folder (`backend/` is the layout name under DEC-012; its internal layout is a spike choice, recorded in the report).
2. Configure the Auth, database, file-storage and functions emulators on fixed local ports. Use a throwaway local project name that cannot match any MFW project, so nothing can reach a cloud resource. Confirm in the documentation that this form of project name keeps the emulators offline; it is NOT VERIFIED here.
3. Add one command that runs all rule and function tests against the emulators from a clean start. Tell Yuvraj the command (GAP-09).
4. Add the test-data loader: a script that seeds fixtures into the emulators. Fixtures are generated files, with no real reader.
5. Write the report skeleton: what worked, what did not, set-up surprises, and which of the unproven assumptions in section 12 were tested.

- **Acceptance.** The command runs from a clean checkout on Sanika Attarde's machine and ends with passing sample tests. No cloud resource exists.
- **Done when.** The report is reviewed by Yuvraj. The branch is not merged as production code.

### B2 MOD-13 backend authorization, data rules and operations

All of B2 is a spike on `spike/sa-backend-rules` (or topic branches cut from it, one per step, named `spike/sa-<topic>`). The test layout puts one test file beside each rule or function.

**Access states used in every test.** Signed-out; `emailUnverified` (FX-USR-02); `profileIncomplete` (FX-USR-03); `fullAccess` (FX-USR-01); a second reader B; an admin; a removed admin; a disabled or deleting account. FX-USR-04 and FX-USR-05 (Google) are not used.

#### B2.1 Access inventory (GAP-10)

1. From `DATABASE_AND_DATA_MODEL.md` section 19 (access by entity and actor) and section 9, list each entity with actor access: anyone, owning reader, admins, functions only.
2. From `API_AND_BACKEND_CONTRACT.md`, list each operation with its caller class and checks.
3. Mark every conflict between the two as a finding in the spike report, not as a silent choice.
4. The result is the table the deny-by-default tests are written against.

#### B2.2 Deny-by-default and owner-only rules (`MOD13-P1-T01`, `MOD13-P1-T02`; `T-03.6`, `T-07.1`)

| Rule group | Allowed test | Refused tests |
|---|---|---|
| Unlisted collection or path (SC-05) | none | Signed-out, reader, admin: read and write refused |
| Public data (published issue, categories, segments, notification categories, news controls, deleted-issue list, public configuration) | Anyone reads | Anyone writes; reads of an unpublished issue |
| Functions-only entities (unpublished issue, upload job, send records, role and guard records, private configuration) | none from a client | All client reads and writes, including an admin's (GS-Q20) |
| Reader profile, user record, consent record | Owner reads | Another reader; signed-out; owner writes directly (writes go through functions) |
| Bookmarks, favourites, notification preferences | Owner reads and writes | Reader B; signed-out; an admin (the matrix says "No") |
| Private issue-file path | none | Every direct client read, with and without sign-in (DM section 9 rule 4; SEC-CHK-02, SEC-CHK-03) |
| Adding a bookmark or favourite | The owner. OP-07 and OP-08 list ownership and the page number as their checks | Reader B; signed-out. Whether the server also refuses creation below full access is an open design point (finding A-4 in the access inventory): RS section 9.2 says bookmarks need full access, but OP-07 lists no access-state check and rules do not look up account status. Favourites below full access: OQ-12 |

- **Steps.** (1) Write the rules for OP-06 to OP-09 records and OP-01, OP-02, OP-04, OP-05 reads. (2) Write the tests above with two readers (FX-LIB-01). (3) Confirm no rule trusts a token claim for admin data (SC-04): include a test that signs in with a forged `admin` claim and is still refused.
- **Known behaviour to record, not to hide.** `SECURITY_AND_ACCESS_CONTROL.md` says rules do not look up the account status, so a reader whose account is deleting can still use the direct operations on their own records, while every function is refused with `ACCOUNT_CLOSED`. The tests assert that documented behaviour and name it; they do not assert a refusal the design does not give.
- **Acceptance.** SEC-CHK-05 passes on the emulator, and `MOD13-P1-T02` shows reader A cannot read or change reader B's records. Recorded as "emulator only".

#### B2.3 `saveProfile` (OP-10, `MOD13-P1-T01`)

1. Function `saveProfile` with `request_id`, the configured profile fields and, on the first call, the accepted policy and terms versions.
2. Validate on the server: values trimmed, within length, in format; field list read from configuration, with the five fields of the working position (name, exact age as a whole number, gender, occupation, domain of work; GS-Q40). Age is checked against the sanity range of 1 to 120 from the working position (`DATABASE_AND_DATA_MODEL.md` section 4.3, OQ-02). That is not an age gate: there is no minimum age (FR-PROF-005). OQ-02 and OQ-07 stay open, and FX-USR-10 is BLOCKED.
3. Accepted versions must equal the current versions in configuration.
4. On the first call create the user record with the caller's identifier; write the profile and the consent record. Do not copy the email address.
5. Return the profile status (complete, or the names of missing fields). A repeat with the same `request_id` is harmless; the profile is replaced and the consent record stays unique per user, document and version.
6. Refusals: `INVALID_ARGUMENT` naming the fields; `FAILED_PRECONDITION` `ACCOUNT_CLOSED`; `UNAUTHENTICATED`.

- **Tests.** Valid save; each invalid field; missing fields reported by name; wrong policy version; repeat is harmless; email not stored; signed-out refused; deleting account refused; reader cannot write the profile directly (B2.2).
- **Acceptance.** AC-3 profile rows and SEC-CHK-05 for profile records, emulator only.
- **Marked PROVISIONAL.** The mandatory profile rests on the S3 emails (BR-003).

#### B2.4 Admin record and last-admin guard (new `MOD13-P1-T08`, GAP-01)

1. Records: `ADMIN_ROLE` (`user_id`, `is_active`, `granted_by`, `granted_at`, `revoked_at`) and the guard record that holds `active_admin_count` (`DATABASE_AND_DATA_MODEL.md` section 4.17 and section 10.8). Functions only; no client access.
2. A shared server function that every privileged operation calls first. It reads the current role record and the account status on each call, refuses on any failure to read, and trusts no claim (SC-02, SC-03, SC-04; INV-08).
3. One internal "remove admin" step that runs inside a single transaction with the guard record and refuses when the active count would fall below one (INV-03, SC-10). Used first by OP-12 (`LAST_ADMIN`), and later by OP-37.
4. A repair function that recomputes the count and reports any difference (the hourly maintenance task, OP-41).
5. A test-only way to create the first admin in the emulator. The real bootstrap step (OP-42, `MOD12-P1-T02`) is not built here; it waits for DEC-003 and MFW's admin list.

- **Not built until OQ-58:** OP-34, OP-35, OP-37, OP-38, OP-39, the change record (`ADMIN_AUDIT_EVENT`), INV-04, INV-06, INV-07. See section 11, point 3 for the bootstrap record.
- **Tests.** Removing the last admin is refused. Two simultaneous removals with two admins left: exactly one succeeds (emulator only; not a pass for concurrency until ENV-TEST). A disabled or deleting account counts as not active. A removed admin is refused on the very next call (SEC-CHK-18). A reader session on an admin operation is refused (FX-ADM-05, SEC-CHK-06). Role record unreadable: refused, nothing written (SC-03). Forged claim: refused (SC-04). The repair function reports a deliberate mismatch.
- **Acceptance.** SEC-CHK-06 and SEC-CHK-18, emulator only. INV-03 holds in every test.

#### B2.5 Admin-only writes and public reads (`MOD13-P1-T03`)

Not named in the list, but `T-09.3` needs it (GAP-04), and it is the server half of `T-09.3`.

1. Functions for OP-15 to OP-18 and OP-21 to OP-23. Each starts with the B2.4 check. OP-28 is not built (GAP-08).
2. OP-21 refuses `NO_ACCEPTED_FILE` unless the issue has an accepted revision (INV-02).
3. A public read never returns a file location.
4. Refuse deleting a category in use.

- **Tests.** Reader, admin and removed admin for each operation; publish without an accepted file; a public read contains no file location; category in use.
- **Acceptance.** SEC-CHK-06 and SEC-CHK-18 rule tests, emulator only.

#### B2.6 `getIssueFile` (OP-11, `MOD13-P1-T04`)

The contract has check 0 and six ordered checks. All seven are built. Check 4 is gated by a configuration switch (BR-003, PROVISIONAL), and check 3 for Google accounts follows OQ-04 and AOQ-09, so only the password-account path is tested.

| # | Check | Refusal |
|---|---|---|
| 0 | The identifier is on the deleted-issue list | `GONE` |
| 1 | The caller is signed in | `UNAUTHENTICATED` |
| 2 | The account is active and not being deleted | `FAILED_PRECONDITION` `ACCOUNT_CLOSED` |
| 3 | The email is verified (password accounts) | `EMAIL_NOT_VERIFIED` |
| 4 | The profile is complete, only when the gate is on | `PROFILE_INCOMPLETE` |
| 5 | The issue exists and is published | `ISSUE_NOT_AVAILABLE` |
| 6 | A current file revision exists | `NO_CURRENT_FILE` |

- **Steps.** (1) Implement the checks in that order. (2) Put grant creation behind a grant-issuer interface (GAP-07). A test stub returns an opaque grant (`url`, `expires_at`, `revision`, `size_bytes`, `checksum_sha256`). The real signed-link issuer is not built. (3) The lifetime comes from configuration (CFG-06), with a placeholder in the test configuration. (4) Read the deleted-issue list from its collection; the writer (OP-30) waits for OQ-21, and a test seeds an entry. (5) Add a server log wrapper that refuses to log a grant, and a test that reads the captured log output (SC-16; the full `MOD02-P2-T03` finishes later).
- **Tests.** One refused test per check, with the order proved (an input that fails two checks returns the earlier one); an allowed `fullAccess` reader gets the five fields; a repeat call returns a new grant; the grant is not stored and not in the log; a direct read of the private path without a grant is refused, and so is a guessed storage path (B2.2). Rate limiting (`RATE_LIMITED`) is not in this block (`MOD13-P1-T07` waits).
- **Acceptance.** PAC-13, SEC-CHK-02 and SEC-CHK-03 on the emulator, for the cases the stub can show. SEC-CHK-02 also lists "another reader's grant" and "an expired grant". Those need a real signed link, and emulator signed-link fidelity "was not researched" (`TECHNOLOGY_DECISIONS.md`), so they are not claimed. They go on the re-run list in B2.10.
- **Waits.** The signed-link issuer, the link lifetime value, and Range/resume behaviour wait for DEC-020 and Yuvraj's `MOD06-P1-T02`.

#### B2.7 Seed definitions (new `MOD13-P1-T10`, GAP-03)

1. A seed file for the three fixed notification categories with stable identifiers: new issues, expo specials, major news (GS-Q47). Public data only.
2. The segment list is added when OQ-13 is answered. The roadmap's 16-segment working position is not seeded here.
3. A loader that puts the seed into the emulator, reused by the tests and by B6.

- **Acceptance.** OP-05 returns exactly the three categories; a client cannot change them.

#### B2.8 `requestUpload` and `onUploadFinalized` (new `MOD13-P1-T09`, GAP-02)

1. **OP-19.** Inputs: `request_id`, kind (`pdf`; a cover is not built, see below), `issue_id`, declared size, content type. Checks: the issue exists; the declared size is within the limit from configuration (CFG-05, 150 MB default; the unit and boundary are OQ-30); the content type is allowed. Returns a job identifier and a short-lived upload address into the holding area. Writes the upload job as pending. A repeat with the same `request_id` returns the same job. Refusals: `INVALID_ARGUMENT`, `NOT_FOUND`, `RATE_LIMITED` (not built).
2. **OP-20.** Returns the job status and the rejection reason.
3. **OP-40.** Triggered when a file arrives. (1) Re-check the uploader's current role (INV-08). (2) Check the file is a genuine PDF and within the limit, not by its name alone. (3) Move it to the private path and remove it from the holding area. (4) In one transaction mark the old revision superseded, write the new revision as current, set the size and page count, and mark the job accepted (INV-01). A rejected file marks the job rejected with `NOT_A_PDF`, `OVER_LIMIT` or `UPLOADER_NOT_AUTHORISED`, and removes the object.
4. **Not built.** Cover upload and `COVER_INVALID` wait for OQ-22. Protected PDFs and the exact size rule wait for OQ-30. The panel screens (SCR-W-03, SCR-W-04) stay in `MOD12-P2-T02`.
5. A replacement keeps the old file until the new one is validated (GS-Q45).

- **Tests.** A text file named `.pdf`: `NOT_A_PDF`. Oversize: `OVER_LIMIT`. Role removed between request and finalise: `UPLOADER_NOT_AUTHORISED`. A valid generated PDF: accepted, revision incremented, old one superseded and still present. Failure after the move leaves an orphan that the maintenance step removes. A reader calling OP-19 is refused. Repeat `request_id`.
- **Fixtures.** Generated PDFs (FX-PDF-06 to FX-PDF-09). No MFW PDF (DEC-024).
- **Acceptance.** SEC-CHK-07 on the emulator: a direct upload that bypasses the interface is still validated. A PDF-parsing library needs a register entry first (PRE-02).
- **Marked** as the backend half of `T-09.2`, which stays held as a feature.

#### B2.9 Account deletion (OP-12, `MOD13-P1-T06`, `T-03.5` server part), PROVISIONAL

Built on the working position of immediate deletion (DEC-029, PROPOSED; GS-Q50). OQ-24 (records kept) is open, so the build keeps nothing and says so.

1. Input: `request_id` and a confirmation flag. Checks: authenticated; the caller's own account; not already deleting. If the caller is an admin, the B2.4 guard applies and `LAST_ADMIN` is returned.
2. One transaction: mark the user as deleting and take the account out of the active admin count.
3. Then end sessions; delete the profile, consent record, bookmarks, favourites, notification preferences and the user record; delete the sign-in account. The backend stores no device token (`DATABASE_AND_DATA_MODEL.md` M3; TD-13), so there are no device records to delete here. Removing the push-topic subscriptions is app side (OP-12, "After"). The app-side contract's `registerDevice` assumes stored registrations, which is the open F-03 difference.
4. A repeat is harmless. A deletion that stops part-way is finished by the daily cleanup (OP-41). A server operation for an account marked deleting is refused with `ACCOUNT_CLOSED`.
5. The app side (`MOD03-P4-T01`), the kept-copy removal and the token removal (`MOD11-P2-T04`) wait for Yuvraj's work and OQ-55.

- **Tests.** After deletion no listed record remains for the user, and the sign-in account is gone (SEC-CHK-11, PAC-06). Failure injected after each step, then the cleanup finishes it. Repeat is harmless. A deleting account is refused on OP-10 and OP-11. The last admin is refused. Another reader's records are untouched.
- **Label.** The words "PROVISIONAL (DEC-029, OQ-24)" appear in the function header, the test names and the pull request title.

#### B2.10 Evidence and hand-off (`MOD13-P2-T01`, emulator part)

1. Run the full suite. Record results against SEC-CHK-02 to SEC-CHK-06, SEC-CHK-07, SEC-CHK-11 and SEC-CHK-18, each marked "emulator only".
2. List the cases that must be re-run on ENV-TEST: the concurrency cases (B2.4), token handling, real signed links (including another reader's grant and an expired grant from SEC-CHK-02), and any rate-limit case.
3. Tell Yuvraj the run command (for QG-08) and publish the report as a document pull request.

- **Acceptance.** Every item passed or logged as a defect. The report states what the emulator could not show.

### B3 MOD-12 admin skeleton (`MOD12-P1-T01`, `T-01.6`)

Branch `spike/sa-admin-skeleton`. Runs in parallel with B2. Needs only B1.

1. Create `admin/` with the technology TD-14 proposes (React). TD-14 names no build tool. The spike picks one, records why, and flags it for DEC-004. A register entry comes first (PRE-02).
2. Add build and test scripts and one smoke test (QG-09 has no command; report the one used to Yuvraj).
3. Build SCR-W-01 (admin sign-in) against the Auth emulator. It shows the same message for a wrong password and a non-admin account. The role check itself is `MOD12-P2-T01` in B5.
4. Placeholder visuals. No brand assets (not received), no M2 design.
5. Serving in ENV-TEST is not possible yet; the acceptance is a local build and serve.

- **Acceptance.** The sign-in page builds and serves locally; the smoke test passes. Not final until DEC-004 is AGREED.

### B4 Dart contracts, MOD-02 and MOD-03

**Entry.** PRE-04 (scaffold and contracts folder) and PRE-05 (file agreement). Without them no Dart package can be created. Branches `spike/sa-<topic>` cut from Yuvraj's scaffold. Dependency register entries come before each package (PRE-02).

#### B4.1 Contracts and fakes first (shared files, ICP-01, ICP-07)

Yuvraj is waiting for these, so they go first. Each is its own small pull request under the shared-file protocol.

| Task | Content | Test |
|---|---|---|
| `MOD03-P1-T01` | `AuthService`, `AuthSession`, `AccessState` as in `API_AND_MODULE_CONTRACTS.md` sections 4.1 and 6.3; `FakeAuthService` in `app/test/fakes/` that can emit `signedOut`, `emailUnverified`, `profileIncomplete`, `fullAccess` | The fake emits each state; Yuvraj approves |
| `MOD04-P1-T01` (GAP-05) | `ProfileRepository`, `ReaderProfile`, `ConsentRecord` with a data-driven field list and a fake that reports `incomplete` and `complete` | Unit tests. The MOD-04 screens stay held |
| `MOD11-P1-T01` (GAP-06) | `NotificationService`, `NotificationTarget`, the payload (title, body, `type`, `targetId`, `sendId`, no personal data) and FX-NTF-01 to FX-NTF-08 with Yuvraj | Fixtures parse |

#### B4.2 MOD-02 errors and logging (`MOD02-P1-T01`, `MOD02-P2-T02`)

Proposed layout (to agree under PRE-05):

```text
app/lib/contracts/        Result, Ok, Err, AppFailure, FailureCode      [shared; Yuvraj drafts, Sanika Attarde approves]
app/lib/core/errors/      messageFor
app/lib/core/logging/     AppLogger, redaction, UsageEvents, CrashReporter interface
```

1. **Agree the location** of `Result`, `AppFailure` and `FailureCode` in writing with Yuvraj (section 11, point 1).
2. **Message mapping.** `messageFor(AppFailure)` for every `FailureCode`. Wording is placeholder until the M2 designs. It never shows raw exception text. The mapping of `GONE` and `RATE_LIMITED` is decided with Yuvraj. Tests: iterate every code, assert a non-empty message, and assert that no exception text passes through.
3. **Log redaction.** `AppLogger` removes: email addresses; token-shaped strings; the query and fragment of any URL, which covers signed grant links; and the value of any context key on a deny list (for example email, token, password, authorization, url). Tests: each rule, a string that must not change, and a check that the original secret never appears in the output (SEC-CHK-10).
4. **Event allowlist (PAC-09).** `UsageEvents.record` accepts only event types on a closed list, and only allowed properties. The list ships **empty**, and collection is off by configuration, because the approved list is OQ-23. Tests use a test-only list. An event carrying both a reader identity and an issue or page is rejected. Tests: unknown event rejected; unknown property rejected; reader and issue together rejected; collection off means nothing recorded.
5. **Crash reporting.** The interface only, with a no-op implementation. The adapter waits for DEC-028, C-07 and DEC-003 (`MOD02-P2-T01`).

- **Acceptance.** Every `FailureCode` has a message; redaction tests pass; PAC-09 passes with the test list. ICP-01 passes with Yuvraj's use.

#### B4.3 MOD-03 email authentication (`MOD03-P2-T01` to `T03`, `T-03.1`)

Against the Auth emulator from B1. No Google, no deletion screen.

1. **Registration and verification (`T01`).** `registerWithEmail`, `resendVerificationEmail`, `reloadVerificationStatus`. Tell the visitor when an account already exists (PROPOSED in section 6.3). SCR-A-02 and SCR-A-03 as plain functional screens. In the emulator, retrieve the verification code from the emulator rather than a mailbox; how, is NOT VERIFIED here.
2. **Sign-in, reset, sign-out (`T02`).** One message for a wrong email or a wrong password. The reset gives the same message whether or not the address exists (SC-21, SEC-CHK-17). `signOut`. SCR-A-01 and SCR-A-04.
3. **Access state (`T03`).** `watchAccessState` combines the session with MOD-04's `watchStatus` in the order of section 4.1. A Riverpod provider (DEC-013, PROPOSED). Google accounts' verification stays open (OQ-04). Tests for FX-USR-01 to FX-USR-03.
4. **Tests.** Unit tests with the fake provider; widget tests for each form state; an integration test, register then verify, against the emulator (QG-07 form). Rate-limit behaviour (SC-21) is not testable on the emulator and is recorded as untested until ENV-TEST.
5. **Guards.** The integration with Yuvraj's route guards (ICP-02, `MOD01-P2-T01`) waits for Yuvraj's work; until then the fake drives every state.

- **Acceptance.** AC-3.1, AC-3.3, AC-3.4, AC-3.6, SEC-CHK-17 on the emulator; the PAC-17 rows. Spike complete, not done, until DEC-003 and DEC-013 are AGREED.

### B5 MOD-12 content operations (`T-09.3`, `T-09.4`)

**Entry.** B2.4, B2.5, B2.8 (or a fixture with an accepted revision) and B3.

1. **`MOD12-P2-T01` admin sign-in and role check (GAP-04).** Spike version. Sign in through the Auth emulator, call OP-14, refuse a non-admin, end the session when the role is removed. Secure-login measures follow the OQ-20 working position (password, verified email, recent-sign-in check, no second factor). The recent-sign-in window is OQ-56 and is configuration.
2. **`MOD12-P2-T03` publish and unpublish (`T-09.3`).** SCR-W-02 issues list, SCR-W-03 issue editor (details, publish, unpublish), SCR-W-05 categories. Calls OP-15 to OP-18, OP-21 and OP-22. The upload control in SCR-W-03 is left out (W3). Categories only; segments and notification categories are seeded (GAP-08). Refuse deleting a category in use.
3. **`MOD12-P2-T04` news controls (`T-09.4`).** SCR-W-06 lists posts through OP-24 and saves controls through OP-23. OP-24 runs on the server, not in the browser, so it needs a test double for the WordPress site and a configurable base URL, because MFW has not given its address (OQ-39). No live read. The breaking-news send (step 3 of the roadmap task) is left out because dispatch is not built.
4. **Tests.** Component tests; function tests for OP-24 against the double (unavailable site returns `UNAVAILABLE`); IC-06 and IC-07 checks with Yuvraj's side later (ICP-04, ICP-06).

- **Acceptance.** AC-8.6, AC-8.7 and AC-8.8 locally. AC-9.7 (breaking send) is not claimed. Spike until DEC-004 is AGREED.

### B6 MOD-11 notification preferences (`MOD11-P2-T02`, preference part, `T-10.2`)

**Entry.** B4.1 (`MOD11-P1-T01`), B2.2 (owner-only preferences), B2.7 (three categories).

1. **Permission explanation (SCR-A-20).** Explains what the app sends before any system prompt (FR-NOTIF-001). The system prompt itself sits behind a permission interface with a fake; the real platform call needs the push set-up (`MOD11-P2-T01`), which waits for the Apple account.
2. **Categories (SCR-A-21).** Reads the three fixed categories from OP-05 and saves the choice through OP-09 (GS-Q47). Admins cannot change the list.
3. **Logged-out visitors.** The working position is that a visitor can accept notifications and choose categories (GS-Q46, OQ-09 stays open). Device registration and topic subscription are not built, because F-03 (device tokens or topics) and OQ-55 are unresolved. The screens show the visitor path behind a configuration switch, off by default, and the preference save is signed-in only.
4. **Tests.** Widget tests for each state (permission not asked, granted, denied; categories loaded, saved, failed); the saved choice reaches OP-09 for the signed-in owner; another reader's preferences are not reachable (B2.2).

- **Acceptance.** AC-9.1 and the candidate check for FR-NOTIF-003 on the app side. "Only the new choice arrives" cannot be shown without dispatch, and is not claimed.
- **Not built.** Dispatch (OP-25 to OP-27), send log, push provider set-up, token removal.

## 9. Branch and Pull Request Plan (PROPOSED)

Names follow `<type>/<initials>-<topic>`. Nothing here is created by this plan.

| Order | Branch | Content | Merges to `main`? |
|---|---|---|---|
| 1 | `chore/sa-gitignore-and-config-example` | MOD14-P1-T01 | Yes, after Yuvraj's review |
| 2 | `docs/sa-wsa-plan` | This plan and the roadmap fix (GAP-08), with the inventory and roadmaps if wanted | Yes, as documents |
| 3 | `spike/sa-backend-rules` | MOD14-P1-T02, B2.1 to B2.9 | **No.** The findings merge as `docs/sa-backend-spike-report` |
| 4 | `spike/sa-admin-skeleton` | B3, then B5 | **No.** Report as a document |
| 5 | `feat/sa-contracts-auth` and similar | B4.1 contracts and fakes | Yes, as shared-file pull requests, once the scaffold exists. Contracts carry no behaviour, so they can merge before DEC-013 if both agree; that is a decision for both developers |
| 6 | `spike/sa-errors-logging` | B4.2 | No until DEC-013 is AGREED. Then promoted |
| 7 | `spike/sa-email-auth` | B4.3 | No until DEC-003 and DEC-013 are AGREED |
| 8 | `spike/sa-notification-preferences` | B6 | No until DEC-003 and DEC-013 are AGREED |

Promotion for rows 3, 4, 6, 7 and 8: after the decision is AGREED with both sides' evidence, cut `feat/sa-<topic>` from the spike, clean it, and open a pull request for Yuvraj's review. Nothing is promoted on Sanika Attarde's agreement alone.

## 10. Held Items and What Releases Them

| Item | Tasks | Held by | Released when | Note |
|---|---|---|---|---|
| MOD-04 profile screens | `MOD04-P2-*` | OQ-01 to OQ-03, OQ-07, OQ-27 | MFW answers in writing | The contract and fake (`MOD04-P1-T01`) are built in B4.1 |
| Google Sign-In, `T-03.2` | `MOD03-P3-T01` (spike), `MOD03-P3-T02` | OQ-04, OQ-05, OQ-06, OQ-29, OQ-42; MFW's OAuth set-up; FX-USR-11 is BLOCKED | MFW confirms scope and accounts | The account-linking spike (`MOD03-P3-T01`) has no blocker and can be added after B4.3 if wanted |
| Upload, `T-09.2` | `MOD12-P2-T02` (panel side) | OQ-22, OQ-30 | MFW answers cover rules, the exact limit and protected PDFs | Backend operations are built in B2.8 |
| Export, `T-09.5` | `MOD12-P2-T06` | OQ-29, OQ-31, OQ-51 | MFW confirms the S3 scope | PROVISIONAL |
| Delete and replace, `T-09.6` | `MOD12-P3-T01`, `MOD13-P1-T05` writer | OQ-21 | MFW answers in writing | The deleted-issue read exists in B2.6 |
| Admin management, `T-09.7` | `MOD12-P3-T02` | OQ-58 (and OQ-56) | MFW confirms in writing, and a change request if MFW calls it one | The record and guard are built in B2.4 |
| Not in the list, kept in the roadmap | `MOD13-P1-T05`, `T07`; `MOD11-P2-T01`, `T03`, `T04`; `MOD03-P3`, `MOD03-P4`; `MOD02-P2-T01` | Various | Per `SANIKA_IMPLEMENTATION_ROADMAP.md` | None is started by this plan |

## 11. Points for Sanika Attarde and Yuvraj to Settle

1. **Where `Result`, `AppFailure` and `FailureCode` live.** Recommendation: `app/lib/contracts/`. Every interface in that folder returns `Result<...>`, so the types must not depend on `core/`, which would turn the dependency around. `messageFor`, the logger and the allowlist stay in `core/errors/` and `core/logging/` (module map, `API_AND_MODULE_CONTRACTS.md` section 3). The module map does not say where `CrashReporter` and `UsageEvents` live; recommendation: `core/logging/`. This needs both developers' agreement (VR-01).
2. **Contracts for MOD-04 and MOD-11.** Recommendation: build `MOD04-P1-T01` and `MOD11-P1-T01` now, because the access state and tap routing need them, and hold only the screens.
3. **Bootstrap record against OQ-58.** OP-42 says "the change record holds the written reference". The data model says the change record falls away if MFW declines in-panel management. Recommendation: build the role and guard records now (B2.4), hold the change record, and settle in writing how the bootstrap step is recorded before `MOD12-P1-T02`.
4. **Pull request 6.** Its section 4.3 is the source of this list, and it says Sanika Attarde has not reviewed it. Reviewing it would put the list under review before the work starts.
5. **Toolchain.** PRE-01 needs Sanika Attarde. Until then B1 steps 2 to 5 and everything after it cannot run.
6. **Promotion of contracts before DEC-013.** Row 5 of section 9 proposes merging contracts and fakes early. `DECISION_LOG.md` section 3.3 rule 4 says code that depends on a PROPOSED decision is limited to spikes. Contract files that import no Riverpod or router code may fit, but that is for both developers to decide.

## 12. Unverified Assumptions and Risks

| ID | Assumption | Where it matters | How the plan tests it |
|---|---|---|---|
| UA-1 | The emulators enforce rules the way production does for the cases used | All of B2 | Marked "emulator only"; re-run list in B2.10 |
| UA-2 | Concurrency cases (two removals at once) behave on the emulator as in production | B2.4 | Re-run on ENV-TEST; not claimed before |
| UA-3 | The emulator can issue and enforce signed links closely enough | B2.6 | Not claimed; grant issuer is a stub. `TECHNOLOGY_DECISIONS.md` says this was not researched |
| UA-4 | A local project name of the "demo" kind keeps the emulators from touching any cloud project | B1 | Check in the documentation at set-up |
| UA-5 | Node.js 26 can be used, or Node.js 20 or 22 must be installed | PRE-01 | Check at set-up |
| UA-6 | Account-linking, token revocation timing and transaction limits behave as assumed (F-05) | B2.4, B2.9, B4.3 | The spike report records what was observed |
| UA-7 | A circular dependency: the platform decision (DEC-003) is made partly from this spike, and the spike assumes the platform | All spikes | Findings merge as documents so DEC-003 can be decided on evidence |
| UA-8 | The Auth emulator exposes a way to read verification codes | B4.3 | Check at set-up |
| UA-9 | Rate limiting (SC-18, SC-21) cannot be tested on the emulator | B4.3, B2.6 | Recorded as untested |
| UA-10 | **Tested, and false.** The Functions emulator does not verify a sign-in token: forged, unsigned and expired tokens passed sign-in (`backend/spike/04-save-profile-notes.md`, B-1) | Every function in B2 | No emulator result shows that a bad token is refused. It goes on the re-run list for ENV-TEST in B2.10 |

## 13. What This Plan Does Not Do

1. It writes no application code, installs nothing, creates no branch, and makes no commit or push.
2. It sets no decision to AGREED or APPROVED, and records no MFW approval.
3. It does not change a requirement, scope item, date or estimate.
4. It does not start any waiting item.
