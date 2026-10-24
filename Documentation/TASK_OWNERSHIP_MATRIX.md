# Task Ownership Matrix: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Task Ownership Matrix |
| File | `Documentation/TASK_OWNERSHIP_MATRIX.md` |
| Phase | 3 — Development Planning and Collaboration (document 22) |
| Version | 0.3 |
| Status | Draft for review. Not approved. Every assignment is PROPOSED (DEC-011). |
| Date | 24 October 2026 |
| Approval required | Both developers (CH §19.3 D9; OQ-38). No MFW approval. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. Document map, retired names and unwritten documents added (section 13). Phase 2 document ownership updated for the five design drafts. Stale statements corrected. |
| 0.3 | 24 October 2026 | Tracking edit, see `CHANGELOG.md`. The document map (section 13.1) lists the four documents added on 24 October 2026 and `README.md`. Section 13.3 no longer lists `PDF_READER_AND_OFFLINE_DESIGN.md` as unwritten. Section 8.2 records the proposed editors of the new documents. No decision, requirement or status label changed. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `PROJECT_CHARTER.md` (CH) §7, §14, §19.3 D9 | Exists, draft. Names the developers and branches. Says the task split is pending. |
| `API_AND_MODULE_CONTRACTS.md` | Exists (draft). Module definitions MOD-00 to MOD-13. |
| `CODING_STANDARDS.md` §3 | Exists (draft). The project structure behind the paths below. |
| `DEVELOPMENT_ROADMAP.md` | Exists (draft). Work packages WP-00 to WP-12. |
| `DEVELOPMENT_WORKFLOW.md` §8 | Exists (draft). The shared-file protocol. |
| `ACCEPTANCE_CRITERIA.md` | Exists (draft) |
| Document map and retired names | Section 13 of this document |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal. In RS terms it is an ASSUMPTION (DEV).

## 2. Purpose, Scope and Status

This matrix proposes who owns each module, work package, shared file and document, so that the two developers can work in parallel with clear boundaries.

**What this document is not**

- It is not evidence of current work. No application code exists, and neither developer has open work recorded in the repository.
- It does not assign the other developer's active files. There are none.
- Each assignment is a proposal, to be agreed by both developers (DEC-011). Equal effort is not the basis of ownership. Module seams and the need for few cross-owner edits are.

## 3. Verified Identities

| Developer | Branch | Repository evidence | Role evidence | Classification |
|---|---|---|---|---|
| Sanika Attarde | `SA` | Git `user.name` in this checkout is "Sanika Attarde". The GitHub account `sanikaattarde` owns the remote and authored `3e642e0`. | Named as the developer in S1 and S2 (unsigned copies). CH §7 and §14 (draft): contracting developer and repository owner. | Identity CONFIRMED from repository evidence. Roles PROVISIONAL (draft CH). |
| Yuvraj | `YG` | Git author name `YuvrajGaykhe` on `8941964` | CH §7 and §14 (draft): "Developer YG (Yuvraj)", co-developer | Git identity CONFIRMED. Role PROVISIONAL (draft CH; S3 not filed, OQ-34). |

This document uses the name forms CH uses: "Sanika Attarde" and "Yuvraj".

## 4. Ownership Rules

1. **Primary owner.** The only developer who routinely edits a module's paths, and who answers for its quality.
2. **Reviewer.** The other developer. Reviews every pull request into `main` (CH §17.5; `DEVELOPMENT_WORKFLOW.md` §6).
3. **Shared or high-risk files** (Section 8) have one primary editor. Anyone else changes them only through the shared-file protocol (`DEVELOPMENT_WORKFLOW.md` §8).
4. **Contracts.** The provider of an interface defines it and maintains its fake (`CODING_STANDARDS.md` §10). The consumer may propose changes.
5. **Testing.** The owner writes the module's unit and widget tests. The consumer of an integration contract writes the check that proves it (Section 6, "Integration responsibility").
6. **Changing ownership.** Follow Section 11. Never take over a file by editing it.

## 5. Workstreams and Proposed Mapping

| Workstream | Scope | Proposed owner | Status |
|---|---|---|---|
| WS-A Platform and Publishing | Authentication, profile and consent, backend authorization and account deletion, admin panel and content pipeline, notifications, errors and monitoring, store release and handover | Sanika Attarde (`SA`) | PROPOSED |
| WS-B Reader Experience | App shell and navigation, catalogue and search, issue downloads, reader, bookmarks and favourites, news, sharing, test coordination and CI | Yuvraj (`YG`) | PROPOSED |

**Why this split.** Each workstream holds whole modules, so cross-owner edits are limited to the contracts in `API_AND_MODULE_CONTRACTS.md` §10. WS-A holds the parts that depend most on MFW's accounts (cloud project, store accounts, Google Sign-In configuration), which the contracting developer coordinates with MFW (CH §14).

The mapping of people to workstreams can be swapped as a whole without changing any boundary.

## 6. Module Ownership Matrix

All rows: status PROPOSED; approval by both developers (DEC-011).

| MOD | Module | Primary owner | Reviewer | Paths (`CODING_STANDARDS.md` §3) | Depends on | Shared contracts | Testing responsibility | Integration responsibility |
|---|---|---|---|---|---|---|---|---|
| MOD-00 | Shared domain models and interfaces | Joint: per file, the workstream of the module that writes the model (`API_AND_MODULE_CONTRACTS.md` §5) | The other workstream | `app/lib/contracts/`, `app/test/fakes/` | None | All | The provider maintains each fake | Both |
| MOD-01 | App shell, navigation, platform services | WS-B | WS-A | `app/lib/main.dart`, `app/lib/app/`, `app/lib/core/config/`, `app/lib/core/network/` | MOD-03 | IC-01, IC-05 | Route-guard unit tests; shell widget tests | Consumer for IC-01 and IC-05 |
| MOD-02 | Errors, logging, monitoring | WS-A | WS-B | `app/lib/core/errors/`, `app/lib/core/logging/` | None | `AppFailure`, `Result`, logger | Message mapping, redaction, event allowlist (PAC-09) | Provider for all modules |
| MOD-03 | Authentication and account lifecycle | WS-A | WS-B | `app/lib/features/auth/` | MOD-04, MOD-13, DEC-003 | IC-01, IC-08 | Auth flows; AC-3; PAC-01; PAC-12 | Provider for IC-01 |
| MOD-04 | Profile, settings, consent | WS-A | WS-B | `app/lib/features/profile/` | MOD-11, MOD-13 | IC-01, IC-08 | Validation; PAC-02; PAC-08 | Provider for IC-01 |
| MOD-05 | Catalogue, search, home | WS-B | WS-A | `app/lib/features/catalogue/` | OP-CAT-01 to 03 | IC-07 | AC-1; PAC-07 | Consumer for IC-07 |
| MOD-06 | Issue access and downloads (app) | WS-B | WS-A | `app/lib/features/downloads/` | MOD-01, MOD-03, OP-FILE-01 | IC-02, IC-03, IC-08 | AC-4; PAC-13; PAC-14 | Consumer for IC-02; provider for IC-03 |
| MOD-07 | Reader | WS-B | WS-A | `app/lib/features/reader/` | MOD-06, MOD-08, DEC-005 | IC-03 | AC-2; device performance tests | Consumer for IC-03 |
| MOD-08 | Bookmarks and favourites (app) | WS-B | WS-A | `app/lib/features/library/` | OP-LIB-01 to 05 | IC-04 | AC-5 | Consumer for IC-04 |
| MOD-09 | News from WordPress | WS-B | WS-A | `app/lib/features/news/` | WordPress API, OP-NWS-01 | IC-06 | AC-7; WordPress fixtures | Consumer for IC-06 |
| MOD-10 | Sharing | WS-B | WS-A | `app/lib/features/sharing/` | MOD-05, MOD-09 | None | AC-6; PAC-05 | None |
| MOD-11 | Notifications (app and dispatch) | WS-A | WS-B | `app/lib/features/notifications/`; dispatch in `backend/` (layout blocked by DEC-003) | MOD-01, MOD-12 | IC-05 | AC-9 | Provider for IC-05 |
| MOD-12 | Admin and content management | WS-A | WS-B | `admin/` (blocked by DEC-004); content operations in `backend/` | MOD-13 | IC-06, IC-07 | AC-8; PAC-03 | Provider for IC-06 and IC-07 |
| MOD-13 | Backend authorization, data rules, account deletion | WS-A | WS-B | Access rules and account operations in `backend/` (blocked by DEC-003) | DEC-003, DEC-020 | IC-02, IC-04, IC-08 | Allowed and refused rule tests; SEC-CHK-02 to 06; SEC-CHK-11 | Provider for IC-02, IC-04 and IC-08 |

## 7. Work Package Ownership

Work packages are defined in `DEVELOPMENT_ROADMAP.md` §6. All rows are PROPOSED.

| WP | Work package | Lead | Support | Approval needed |
|---|---|---|---|---|
| WP-00 | Clarification and architecture approval | Sanika Attarde (MFW contact, CH §14) | Yuvraj (architecture drafting) | MFW, at M1 |
| WP-01 | Repository and development setup | Joint. App scaffold: WS-B. Cloud access and backend skeleton: WS-A. | — | Both developers |
| WP-02 | Design and reader validation | WS-B (app screens, reader test) | WS-A (auth, profile, settings and notification screens; admin screens) | MFW, at M2 |
| WP-03 | Authentication, profile, account lifecycle | WS-A | WS-B (route guards) | Both developers |
| WP-04 | Catalogue, search, home | WS-B | — | Both developers |
| WP-05 | Reader | WS-B | — | Both developers. MFW for the reader approach at M2. |
| WP-06 | Issue access and offline downloads | WS-B | WS-A (OP-FILE-01) | Both developers |
| WP-07 | Bookmarks and favourites | WS-B | WS-A (server rules) | Both developers |
| WP-08 | News and sharing | WS-B | WS-A (news controls) | Both developers |
| WP-09 | Admin panel and content pipeline | WS-A | — | Both developers |
| WP-10 | Notifications | WS-A | WS-B (tap routing) | Both developers |
| WP-11 | Integration, hardening, testing | WS-B (test coordination) | WS-A | MFW, through acceptance testing |
| WP-12 | Release, acceptance, handover | WS-A | WS-B | MFW, at M5 |

## 8. Shared and High-Risk Files and Documents

### 8.1 Code and configuration (all PROPOSED; none of these paths exist yet)

| Path | Why high-risk | Primary editor | Change rule |
|---|---|---|---|
| `app/lib/contracts/` | Every module depends on it | Per file, the writing module's workstream | Shared-file protocol; both developers review |
| Authentication interfaces: `app/lib/features/auth/auth.dart` and `AccessState` | Gates every protected screen | WS-A | Shared-file protocol; both developers review |
| `app/lib/main.dart`, `app/lib/app/` (entry point, routes, dependency wiring) | Every feature registers here | WS-B | Other features ask for route or wiring changes in a small pull request |
| `app/pubspec.yaml`, `app/pubspec.lock` | Dependency changes affect everyone | WS-A | Needs a `DEPENDENCY_REGISTER.md` entry first. The lock file is regenerated, never hand-merged. |
| `app/analysis_options.yaml` | Changes the rules for all code | WS-B | Both developers agree |
| `app/android/`, `app/ios/` | Signing, sign-in and push configuration; app identifiers | WS-A | Shared-file protocol |
| `app/test/fakes/` | Used by every test suite | Per file, the interface's owner | Shared-file protocol |
| `app/integration_test/` | Cross-feature flows | The owner of the flow's main module | Shared-file protocol for shared helpers |
| `backend/` access rules and configuration | Security boundary (DEC-009) | WS-A | Rule tests in the same pull request |
| `admin/` | Single admin surface | WS-A | Normal review |
| `.github/` (CI, planned) | Gates every merge | WS-B | Both developers agree |
| `.gitignore` | Protects secrets | WS-A | Normal review |
| `README.md` (root) | Entry point for MFW at handover | Sanika Attarde (repository owner) | Normal review |

### 8.2 Documents

| Document | Primary editor | Reviewer | Rule |
|---|---|---|---|
| `PROJECT_CHARTER.md`, `REQUIREMENTS_SPECIFICATION.md` | **Not agreed.** Both were committed by YuvrajGaykhe in `8941964`; who drafted them is not recorded. PROPOSED: Yuvraj, pending confirmation. | Sanika Attarde | Both developers review every change. Section numbers and requirement IDs are never renumbered (`DEVELOPMENT_WORKFLOW.md` §12). |
| `MFW_Statement_of_Work.pdf`, `MFW_Commercial_Proposal-2.pdf` | None. These are issued documents. | — | Never edited. A newer issued version is added beside the old one by the contracting developer, with a `CHANGELOG.md` entry. |
| Phase 2 documents | `SYSTEM_ARCHITECTURE.md` and `TECHNOLOGY_DECISIONS.md` are joint. `DATABASE_AND_DATA_MODEL.md`, `API_AND_BACKEND_CONTRACT.md` and `SECURITY_AND_ACCESS_CONTROL.md` exist as drafts written in Yuvraj's session; the primary editor is **not agreed**, PROPOSED: Yuvraj, pending confirmation. `PDF_READER_AND_OFFLINE_DESIGN.md` exists as a draft (24 October 2026); the primary editor is **not agreed**, PROPOSED: Yuvraj. `CLOUD_INFRASTRUCTURE_AND_COSTS.md` is not written; an editor is assigned when it is created. | Both | Both developers review every change |
| `API_AND_MODULE_CONTRACTS.md` | Sanika Attarde (interim: drafted in Sanika Attarde's session) | Yuvraj | Both developers approve every change (`API_AND_MODULE_CONTRACTS.md` §12). |
| `DECISION_LOG.md` | Sanika Attarde (interim) | Yuvraj | Anyone may add an entry in a pull request. Status changes need the evidence in `DECISION_LOG.md` §3.1. |
| `CHANGELOG.md` | Sanika Attarde (interim) | Yuvraj | Each pull request adds its own line. On a conflict, keep both lines. |
| `OPEN_QUESTIONS.md` | Sanika Attarde (interim; MFW contact) | Yuvraj | Anyone may add a question. Only evidence closes one. |
| `RISK_REGISTER.md` | Sanika Attarde (interim) | Yuvraj | Anyone may add a risk. Rating changes are reviewed. |
| `DEPENDENCY_REGISTER.md` | Sanika Attarde (interim; also edits `pubspec.yaml`) | Yuvraj | An entry is added before any dependency |
| Other Phase 3 and Phase 4 documents | Sanika Attarde (interim) | Yuvraj | Normal review |
| Documents added on 24 October 2026 | **Not agreed.** PROPOSED: `REQUIREMENT_COVERAGE_MATRIX.md` and the app screens of `SCREEN_INVENTORY_AND_NAVIGATION.md`: Yuvraj. `SECURITY_INCIDENT_PROCEDURE.md` and the admin panel screens of the inventory: Sanika Attarde. | The other developer | Both developers review every change |

"Interim" means the document was drafted in Sanika Attarde's session on 23 October 2026, and the team has not yet chosen an editor. **PROPOSED rebalancing after review:** Yuvraj becomes primary editor of `TESTING_STRATEGY.md`, `TEST_DATA_AND_FIXTURES.md` and `CI_CD_AND_QUALITY_GATES.md`, matching WS-B's lead on WP-11 and CI.

## 9. Acceptance Criteria Ownership

The criteria are defined in S2 and detailed in `ACCEPTANCE_CRITERIA.md`. All rows are PROPOSED.

| Criterion | Owner | Supporting workstream |
|---|---|---|
| AC-1 Browsing and search | WS-B | WS-A (publishing) |
| AC-2 Reader | WS-B | — |
| AC-3 Accounts | WS-A | WS-B (sign-in prompts in the reader and downloads) |
| AC-4 Offline downloads | WS-B | WS-A (file authorization) |
| AC-5 Bookmarks and favourites | WS-B | WS-A (data rules) |
| AC-6 Sharing | WS-B | — |
| AC-7 News | WS-B | WS-A (hidden posts) |
| AC-8 Admin panel | WS-A | — |
| AC-9 Notifications | WS-A | WS-B (tap routing) |
| AC-10 Testing | WS-B (coordination) | WS-A |
| AC-11 Release | WS-A | WS-B |
| AC-12 Handover | WS-A | WS-B |

## 10. MFW-Facing Responsibilities

| Responsibility | Holder | Evidence |
|---|---|---|
| Sending the M1 note, milestone approval requests, change-request replies and delay notices to MFW | Sanika Attarde, as the named developer | S1 and S2 name Sanika Attarde as the developer (unsigned copies). CH §14 (draft). |
| Commercial matters: invoices and payment schedule | Sanika Attarde | S1 "How payment works". Figures in conflict: OQ-32. |
| Demonstrations at milestones | Both developers | PROPOSED |
| Holding MFW's credentials | MFW. Developers get role-based access only. | S2 Responsibilities; RS NFR-SEC-012 |

## 11. Changing Ownership

1. Propose the change in a pull request to this document.
2. Both developers approve. Record the change in the change history.
3. Hand over any open draft pull requests explicitly.
4. If either developer is unavailable for longer than a few days, the other may take over a module only after the absent developer agrees, or, if they cannot be reached, after recording the takeover here.

## 12. Open Items

| Item | Reference |
|---|---|
| Both developers agree the workstreams and mapping | DEC-011; OQ-38 |
| Each developer's availability is not recorded, so capacity cannot be checked | OQ-38; `DEVELOPMENT_ROADMAP.md` §8 |
| Primary editor of CH and RS | Section 8.2 |
| Two-developer delivery recorded with MFW | OQ-34; DEC-018 |

## 13. Document Map

This section records which document is the home of each topic, which planned names were retired, and which documents are still unwritten. It changes no document name and moves no content. The choices are PROPOSED. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed.

### 13.1 Canonical home of each topic

```text
Sources (never edited here)
├── MFW_Commercial_Proposal-2.pdf (S1), MFW_Statement_of_Work.pdf (S2)   issued, unsigned copies
└── S3, client emails after S1 and S2                                     not in the repository

Framing and requirements
├── PROJECT_CHARTER                  project framing; S3 amendments listed in section 17.3
├── REQUIREMENTS_SPECIFICATION       requirements, original OQ-01 to OQ-31, conflicts C-01 to C-08
├── SCOPE_AND_EXCLUSIONS             scope, exclusions, change candidates (CHG-nn)
├── ASSUMPTIONS_AND_CONSTRAINTS      assumptions and constraints (REG-nnn)
└── GLOSSARY                         terms

Registers (one canonical register per family)
├── DECISION_LOG                     decisions (DEC-nnn); TECHNOLOGY_DECISIONS holds the options behind them (TD-nn)
├── OPEN_QUESTIONS                   questions (OQ-nn); architecture questions AOQ-nn map to it (section 7 there)
└── RISK_REGISTER                    risks (R-nn); architecture risks AR-nn map to it (section 7 there)

Design
├── SYSTEM_ARCHITECTURE              logical architecture
├── TECHNOLOGY_DECISIONS             technology options, proposed choices, proposed requirement changes (PRC-nn)
├── DATABASE_AND_DATA_MODEL          data model
├── API_AND_BACKEND_CONTRACT         the single catalogue of backend operations (OP-nn) and their errors
├── API_AND_MODULE_CONTRACTS         app modules (MOD-nn), integration contracts (IC-nn), app-side errors
├── SECURITY_AND_ACCESS_CONTROL      access rules, threats, controls, security tests
├── PDF_READER_AND_OFFLINE_DESIGN    device-side reader and offline design (draft 0.1, 24 October 2026)
└── SCREEN_INVENTORY_AND_NAVIGATION  screens and states the requirements imply; input to the M2 designs (draft 0.1)

Plans, tests and process
├── DEVELOPMENT_ROADMAP, TASK_OWNERSHIP_MATRIX, DEVELOPMENT_WORKFLOW, CODING_STANDARDS, DEFINITION_OF_DONE
├── ACCEPTANCE_CRITERIA, TESTING_STRATEGY, TEST_DATA_AND_FIXTURES, CI_CD_AND_QUALITY_GATES
├── DEPENDENCY_REGISTER, DEPLOYMENT_PLAN, BACKUP_AND_RECOVERY, MAINTENANCE_AND_HANDOVER
├── APP_STORE_RELEASE_CHECKLIST, CLAUDE_CODE_WORKING_RULES
├── SECURITY_INCIDENT_PROCEDURE      security incident steps (draft 0.1)
├── REQUIREMENT_COVERAGE_MATRIX      which rows and plans name each requirement; derived, not a source (draft 0.1)
└── CHANGELOG

Entry point
└── README.md (repository root)      document index, derived from this section
```

Section 8 of `API_AND_MODULE_CONTRACTS.md` (the 31-operation table) stays until the catalogue in `API_AND_BACKEND_CONTRACT.md` is agreed. Its operation IDs are aliases of the catalogue's IDs (see the alias table in `API_AND_BACKEND_CONTRACT.md`).

### 13.2 Retired planned names

Earlier documents named four documents that were not yet written. Documents with different names now exist. The old names stay here so any old reference still resolves.

| Planned name (retired) | Document that exists |
|---|---|
| `TECH_STACK_DECISIONS` | `TECHNOLOGY_DECISIONS.md` |
| `DATABASE_DESIGN` | `DATABASE_AND_DATA_MODEL.md` |
| `API_SPECIFICATION` | `API_AND_BACKEND_CONTRACT.md` (backend operations). App-side contracts are in `API_AND_MODULE_CONTRACTS.md` |
| `AUTHENTICATION_AND_AUTHORIZATION` | `SECURITY_AND_ACCESS_CONTROL.md` |

The change is of names only. It does not make the content of either set authoritative, and it does not mean the contents agree. Where they differ, the difference is recorded as a conflict or an open item in the document that holds it.

### 13.3 Planned, not written

| Document | Purpose | Status |
|---|---|---|
| `CLOUD_INFRASTRUCTURE_AND_COSTS.md` | Cloud cost model once DEC-003 is decided (R14) | Not written. BLOCKED by DEC-003. Cost scenarios already exist in `TECHNOLOGY_DECISIONS.md` section 9 and `SYSTEM_ARCHITECTURE.md` section 13 |

`PDF_READER_AND_OFFLINE_DESIGN.md` was planned here and was written as a draft on 24 October 2026 (version 0.1, not reviewed). It is listed in section 13.1. Its review is part of T-00.7 in `DEVELOPMENT_ROADMAP.md`.

### 13.4 Numbers in document control

The Phase 3 and Phase 4 documents carry the numbers 21 to 40 in their document-control tables. No document in the repository is assigned the numbers 1 to 20, and the numbers do not define an order of reading or approval. The four documents added on 24 October 2026 carry no number.
