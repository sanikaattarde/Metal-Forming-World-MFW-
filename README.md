# Metal-Forming-World-MFW-

Documentation for the Metal Forming World (MFW) mobile application: a Flutter app for Android and iOS, a backend, and a web admin panel for MFW's magazine issues and news.

**State of this repository.** Early development. `app/` holds the Flutter app scaffold, the shared contracts, the theme and the WordPress news client, with tests that run on each pull request that changes `app/` (`.github/workflows/pr.yml`). `backend/` holds the Firestore and Storage access rules and the Cloud Functions, and `admin/` the admin panel, each with tests on the local emulators. There is no cloud project, no deployment and no store submission. Every document is a draft. MFW has not approved any document, and the proposal and the statement of work are unsigned copies (OQ-28). Where a document says a decision is agreed or approved, it follows the evidence rules in [Documentation/DECISION_LOG.md](Documentation/DECISION_LOG.md) section 3.1.

**This repository is public.** Do not commit credentials, reader data, or the details of a security incident (see [Documentation/SECURITY_INCIDENT_PROCEDURE.md](Documentation/SECURITY_INCIDENT_PROCEDURE.md) section 5).

## Where to start

```text
Reading order
├── 1 What the project is:    PROJECT_CHARTER, REQUIREMENTS_SPECIFICATION, SCOPE_AND_EXCLUSIONS, GLOSSARY
├── 2 What is decided, open, risky:  DECISION_LOG, OPEN_QUESTIONS, RISK_REGISTER, ASSUMPTIONS_AND_CONSTRAINTS
├── 3 How it is designed:     SYSTEM_ARCHITECTURE, TECHNOLOGY_DECISIONS, DATABASE_AND_DATA_MODEL,
│                             API_AND_BACKEND_CONTRACT, API_AND_MODULE_CONTRACTS, SECURITY_AND_ACCESS_CONTROL,
│                             PDF_READER_AND_OFFLINE_DESIGN, SCREEN_INVENTORY_AND_NAVIGATION,
│                             CLOUD_INFRASTRUCTURE_AND_COSTS
├── 4 How the two developers work:  DEVELOPMENT_ROADMAP, TASK_OWNERSHIP_MATRIX, DEVELOPMENT_WORKFLOW,
│                             CODING_STANDARDS, DEFINITION_OF_DONE
├── 5 How it is tested:       ACCEPTANCE_CRITERIA, TESTING_STRATEGY, TEST_DATA_AND_FIXTURES, CI_CD_AND_QUALITY_GATES,
│                             REQUIREMENT_COVERAGE_MATRIX
└── 6 How it is released and handed over:  DEPLOYMENT_PLAN, BACKUP_AND_RECOVERY, APP_STORE_RELEASE_CHECKLIST,
                              MAINTENANCE_AND_HANDOVER, SECURITY_INCIDENT_PROCEDURE, DEPENDENCY_REGISTER
```

[Documentation/CHANGELOG.md](Documentation/CHANGELOG.md) records what changed and when. [Documentation/TASK_OWNERSHIP_MATRIX.md](Documentation/TASK_OWNERSHIP_MATRIX.md) section 13 says which document is the home of each topic.

## Set-up

| Folder | On `main` | Set-up |
|---|---|---|
| `app/` | The Flutter app: the scaffold, the shared contracts, the theme and the WordPress news client, with their tests | [app/README.md](app/README.md) |
| `backend/` | The Firestore and Storage access rules and the Cloud Functions on Firebase (DEC-003, AGREED), with their tests on the local emulators (MOD-13) | [backend/README.md](backend/README.md) |
| `admin/` | The admin panel: a React web app for Firebase Hosting (DEC-004, AGREED), with its tests on the local emulators (MOD12) | [admin/README.md](admin/README.md) |
| `config/` | `config.example.env`: the configuration items CFG-01 to CFG-15 by name, with placeholder values and where each value comes from | Below |

**`backend/`.** The access rules and the Cloud Functions in TypeScript on Node.js (DEC-025) run on the developer's machine against the Firebase Local Emulator Suite (ENV-LOCAL, DEC-023), with no login and no cloud project: `npm ci`, `npm --prefix functions ci` and `npm test` in `backend/`, with Node.js 22 or later and Java 21 or later (DEP-79 to DEP-83). ENV-TEST and ENV-PROD wait for MFW's cloud access (`Documentation/CLOUD_ACCESS_SETUP_CHECKLIST.md`) and MFW's answer to OQ-40.

**`admin/`.** A static single-page app in React and TypeScript, run locally against the same emulators. It holds no secret: every privileged operation is checked again on the backend (TD-14).

**Configuration.** Copy `config/config.example.env` to `config/<environment>.env` and fill in the values from the source named beside each item. Everything in `config/` except the example is ignored by Git. The app reads the file at build time with `--dart-define-from-file` (see `app/README.md`). Server-side secrets are never kept in a file: they live in the provider's secret store in MFW's account (`Documentation/DEPLOYMENT_PLAN.md` section 5). Never commit a real value, key or credential: this repository is public.

## Index of documents

- **Authoritative** means a document is the single home of that topic in this repository. It does not mean approved.
- **Derived** means the document repeats what others say and is not a source of truth.
- **Proposed owner** is taken from `TASK_OWNERSHIP_MATRIX.md` section 8.2. No owner is agreed. "Interim" means the document was drafted in that developer's session and no editor has been chosen.
- **Version** is read from each document's own control table.

| Document | Purpose | Role | Version | Proposed owner | Approval needed |
|---|---|---|---|---|---|
| [MFW_Commercial_Proposal-2.pdf](Documentation/MFW_Commercial_Proposal-2.pdf) | S1, the commercial proposal | Source | Issued, unsigned (OQ-28) | None (issued document) | Not applicable |
| [MFW_Statement_of_Work.pdf](Documentation/MFW_Statement_of_Work.pdf) | S2, the statement of work | Source | Issued, unsigned (OQ-28) | None (issued document) | Not applicable |
| [PROJECT_CHARTER](Documentation/PROJECT_CHARTER.md) | Project framing, stakeholders, governance | Authoritative: framing | 0.3 | Yuvraj (proposed, not agreed) | Not stated in the document |
| [REQUIREMENTS_SPECIFICATION](Documentation/REQUIREMENTS_SPECIFICATION.md) | Functional and non-functional requirements | Authoritative: requirements | 0.2 | Yuvraj (proposed, not agreed) | Not stated in the document |
| [SCOPE_AND_EXCLUSIONS](Documentation/SCOPE_AND_EXCLUSIONS.md) | What is in scope, excluded, or needs a change request | Authoritative: scope | 0.2 | Not assigned | Not stated in the document |
| [ASSUMPTIONS_AND_CONSTRAINTS](Documentation/ASSUMPTIONS_AND_CONSTRAINTS.md) | Assumptions, constraints and dependencies | Authoritative: assumptions | 0.3 | Not assigned | Not stated in the document |
| [GLOSSARY](Documentation/GLOSSARY.md) | Terms used in the documents | Supporting | 0.2 | Not assigned | Not stated in the document |
| [DECISION_LOG](Documentation/DECISION_LOG.md) | Decisions and the evidence each status needs | Authoritative: decisions | 0.17 | Sanika (interim) | Both developers for the structure |
| [OPEN_QUESTIONS](Documentation/OPEN_QUESTIONS.md) | Questions for MFW and for the developers | Authoritative: questions | 0.15 | Sanika (interim) | Both developers |
| [MFW_QUESTIONS_2026-11-08](Documentation/MFW_QUESTIONS_2026-11-08.md) | Five questions for MFW's written answer, with a draft email | Request: not sent | 0.1 | Yuvraj (proposed, not agreed) | Both developers, before it is sent |
| [RISK_REGISTER](Documentation/RISK_REGISTER.md) | Risks, ratings and owners | Authoritative: risks | 0.9 | Sanika (interim) | Both developers; MFW for risks it must accept |
| [SYSTEM_ARCHITECTURE](Documentation/SYSTEM_ARCHITECTURE.md) | Components, data flows, trust boundaries | Authoritative: logical architecture | 0.6 | Joint | Both developers; MFW for cost, scope or contract effects |
| [TECHNOLOGY_DECISIONS](Documentation/TECHNOLOGY_DECISIONS.md) | Technology options and proposed choices | Authoritative: technology options | 0.9 | Joint | Both developers; MFW for cost, scope or contract effects |
| [DATABASE_AND_DATA_MODEL](Documentation/DATABASE_AND_DATA_MODEL.md) | Data, relationships, retention | Authoritative: data model | 0.7 | Yuvraj (proposed, not agreed) | Both developers; MFW for cost, scope or contract effects |
| [API_AND_BACKEND_CONTRACT](Documentation/API_AND_BACKEND_CONTRACT.md) | The single catalogue of backend operations | Authoritative: backend operations | 0.7 | Yuvraj (proposed, not agreed) | Both developers; MFW for cost, scope or contract effects |
| [API_AND_MODULE_CONTRACTS](Documentation/API_AND_MODULE_CONTRACTS.md) | App modules, integration contracts, app-side errors | Authoritative: app modules | 0.20 | Sanika (interim) | Both developers |
| [SECURITY_AND_ACCESS_CONTROL](Documentation/SECURITY_AND_ACCESS_CONTROL.md) | Access rules, threats, controls, security tests | Authoritative: access and security | 0.7 | Yuvraj (proposed, not agreed) | Both developers; MFW for cost, scope or contract effects |
| [PDF_READER_AND_OFFLINE_DESIGN](Documentation/PDF_READER_AND_OFFLINE_DESIGN.md) | Device-side reader and offline design | Authoritative: reader and offline (proposed) | 0.5 | Yuvraj (proposed, not agreed) | Both developers; MFW at M2 for the reader approach |
| [SCREEN_INVENTORY_AND_NAVIGATION](Documentation/SCREEN_INVENTORY_AND_NAVIGATION.md) | Screens and states the requirements imply; input to the M2 designs | Authoritative: screen list (proposed) | 0.4 | Yuvraj for app, Sanika for admin (proposed) | Both developers; MFW approves the screens at M2 |
| [BRAND_REFERENCE](Documentation/BRAND_REFERENCE.md) | The colours, fonts and type scale read from MFW's website, the reference for the app and admin designs; not confirmed by MFW | Reference: observed values (OQ-63) | 0.1 | Yuvraj (proposed, not agreed) | Both developers; MFW confirms the values |
| [DESIGN_TOKENS](Documentation/DESIGN_TOKENS.md) | The colour, type, spacing and shape tokens taken from the brand reference, their contrast check, the app theme and the bundled typefaces | Authoritative: design tokens (proposed) | 0.1 | Yuvraj (proposed, not agreed) | Sanika Attarde for the WS-A screens; MFW approves the look at M2 |
| [design/ACCOUNT_SCREEN_DESIGNS](Documentation/design/ACCOUNT_SCREEN_DESIGNS.md) | 23 frames of the account, profile, settings and notification screens (SCR-A-01 to SCR-A-08, SCR-A-20, SCR-A-21) with their states, drawn on the app's theme, for the prototype | Design: not the M2 designs | 0.1 | Sanika (proposed, not agreed) | Both developers; MFW at M2 |
| [design/READER_SCREEN_DESIGNS](Documentation/design/READER_SCREEN_DESIGNS.md) | 28 frames of the reader-side screens (SCR-A-10 to SCR-A-19, SCR-A-22) with their states, drawn on the app's theme, for the prototype | Design: not the M2 designs | 0.1 | Yuvraj (proposed, not agreed) | Sanika Attarde reviews them; MFW approves the screens at M2 |
| [CLOUD_INFRASTRUCTURE_AND_COSTS](Documentation/CLOUD_INFRASTRUCTURE_AND_COSTS.md) | Candidate clouds and a parameterised cost model; no provider chosen | Authoritative: cloud cost model (proposed) | 0.4 | Yuvraj (proposed, not agreed) | Both developers; MFW for the provider, region, cost ceiling and any CDN |
| [DEVELOPMENT_ROADMAP](Documentation/DEVELOPMENT_ROADMAP.md) | Work packages, tasks, internal estimates | Planning, not a commitment | 0.14 | Sanika (interim) | Both developers; MFW approves milestones, not the plan |
| [SANIKA_IMPLEMENTATION_ROADMAP](Documentation/SANIKA_IMPLEMENTATION_ROADMAP.md) | Sanika Attarde's tasks by module (task IDs MODnn-Pn-Tnn), as planned on 30 October 2026 | Planning, not a commitment | 0.2 | Sanika (interim) | Both developers |
| [SANIKA_WSA_IMPLEMENTATION_PLAN](Documentation/SANIKA_WSA_IMPLEMENTATION_PLAN.md) | The WS-A first-build plan: blocks B0 to B6, gaps and held items, as planned on 30 October 2026 | Planning, not a commitment | 0.2 | Sanika (interim) | Both developers |
| [YUVRAJ_IMPLEMENTATION_ROADMAP](Documentation/YUVRAJ_IMPLEMENTATION_ROADMAP.md) | Yuvraj Gaykhe's tasks by module, as planned on 30 October 2026 | Planning, not a commitment | 0.3 | Sanika (interim) | Both developers |
| [IMPLEMENTATION_MODULE_INVENTORY](Documentation/IMPLEMENTATION_MODULE_INVENTORY.md) | The inventory of modules MOD-00 to MOD-20 and the task ID format, as planned on 30 October 2026 | Planning, not a commitment | 0.2 | Sanika (interim) | Both developers |
| [YUVRAJ_DECISION_POSITIONS](Documentation/YUVRAJ_DECISION_POSITIONS.md) | Yuvraj Gaykhe's written positions on DEC-001, DEC-021, DEC-031, DEC-032 and DEC-033, and the evidence of the already AGREED entries (MOD20-P1-T01) | Record: one developer's note, changes no status | 0.1 | Yuvraj | Both developers; MFW where an entry needs it |
| [TASK_OWNERSHIP_MATRIX](Documentation/TASK_OWNERSHIP_MATRIX.md) | Who owns what, and the document map | Authoritative: ownership and map | 0.9 | Sanika (interim) | Both developers |
| [DEVELOPMENT_WORKFLOW](Documentation/DEVELOPMENT_WORKFLOW.md) | Branches, reviews, merges | Authoritative: process | 0.4 | Sanika (interim) | Both developers. No MFW approval |
| [CODING_STANDARDS](Documentation/CODING_STANDARDS.md) | Coding rules and on-device storage rules | Authoritative: standards | 0.6 | Sanika (interim) | Both developers |
| [DEFINITION_OF_DONE](Documentation/DEFINITION_OF_DONE.md) | What done means for each kind of work | Authoritative: done | 0.4 | Sanika (interim) | Both developers |
| (see the document map) | Working rules for AI-assisted drafting. Named in the document map, `TASK_OWNERSHIP_MATRIX.md` section 13.1 | Supporting | 0.3 | Sanika (interim) | Both developers |
| [DEPENDENCY_REGISTER](Documentation/DEPENDENCY_REGISTER.md) | Packages, services and accounts, with licences | Authoritative: dependencies | 0.15 | Sanika (interim) | Both developers; MFW for any paid component |
| [CHANGELOG](Documentation/CHANGELOG.md) | Record of changes to the repository | Record | 0.60 | Sanika (interim) | None stated |
| [ACCEPTANCE_CRITERIA](Documentation/ACCEPTANCE_CRITERIA.md) | S2 criteria AC-1 to AC-12 as checks, and proposed PAC rows | Authoritative: acceptance rows | 0.6 | Sanika (interim) | Both developers; MFW in writing for each PAC row |
| [TESTING_STRATEGY](Documentation/TESTING_STRATEGY.md) | Test levels, plans, security checklist | Authoritative: test plans | 0.10 | Sanika (interim); move to Yuvraj proposed | Both developers |
| [TEST_DATA_AND_FIXTURES](Documentation/TEST_DATA_AND_FIXTURES.md) | Test users, files and network scenarios | Authoritative: fixtures | 0.9 | Sanika (interim); move to Yuvraj proposed | Both developers; MFW for where its sample PDFs are stored |
| [CI_CD_AND_QUALITY_GATES](Documentation/CI_CD_AND_QUALITY_GATES.md) | Planned checks on each change | Authoritative: quality gates (planned) | 0.10 | Sanika (interim); move to Yuvraj proposed | Both developers; MFW if a cost is billed to MFW |
| [REQUIREMENT_COVERAGE_MATRIX](Documentation/REQUIREMENT_COVERAGE_MATRIX.md) | Which rows and plans name each requirement | Derived, not a source of truth | 0.4 | Yuvraj (proposed, not agreed) | Both developers |
| [test-evidence/BACKEND_RULES_EMULATOR_EVIDENCE](Documentation/test-evidence/BACKEND_RULES_EMULATOR_EVIDENCE.md) | Backend spike results on the local emulators against eight SEC-CHK items, and the cases to run again on ENV-TEST | Record: test evidence, emulator only | 0.1 | Sanika (interim) | Both developers |
| [test-evidence/PDF_LIBRARY_SIMULATOR_EVIDENCE](Documentation/test-evidence/PDF_LIBRARY_SIMULATOR_EVIDENCE.md) | Simulator results of the pdfrx and pdfx comparison harness, with two damaged files, and what to repeat on the test phone | Record: test evidence, simulator and debug build only | 0.1 | Yuvraj (proposed, not agreed) | Both developers |
| [test-evidence/ADMIN_PANEL_SPIKE_EVIDENCE](Documentation/test-evidence/ADMIN_PANEL_SPIKE_EVIDENCE.md) | Admin panel spike results on the local emulators: the sign-in, issue, category and news screens, against AC-8 and five SEC-CHK items | Record: test evidence, emulator only | 0.1 | Sanika (interim) | Both developers |
| [test-evidence/SCAFFOLD_RUN_EVIDENCE](Documentation/test-evidence/SCAFFOLD_RUN_EVIDENCE.md) | The T-01.1 run of the app scaffold on an iOS simulator and an Android emulator, with two screenshots | Record: test evidence, simulator and emulator, debug builds | 0.1 | Yuvraj (proposed, not agreed) | Both developers |
| [test-evidence/READER_PHONE_TEST_KIT](Documentation/test-evidence/READER_PHONE_TEST_KIT.md) | Steps, rules for MFW's PDFs and result tables for the T-02.3 reader test on the test phones | Plan: not run | 0.1 | Yuvraj (proposed, not agreed) | Both developers |
| [test-evidence/DOWNLOAD_RESUME_SPIKE_EVIDENCE](Documentation/test-evidence/DOWNLOAD_RESUME_SPIKE_EVIDENCE.md) | Resume spike results on an iOS simulator and an Android emulator: four tests against a local range server and through the Firebase Storage emulator, with a 150,000,000 byte synthetic file | Record: test evidence, simulator and emulator, debug builds | 0.1 | Yuvraj (proposed, not agreed) | Both developers |
| [test-evidence/PROTOTYPE_WALKTHROUGH_RECORD](Documentation/test-evidence/PROTOTYPE_WALKTHROUGH_RECORD.md) | The T-02.1 low-fi prototype walked against the screen inventory, with a design critique and the Figma copy of the screens, and the branded prototype on the app's theme (MOD16-P1-T05) | Record: walk-through of a spike prototype, not the M2 design | 0.1 | Yuvraj (proposed, not agreed) | Both developers |
| [test-evidence/WORDPRESS_PUBLIC_SITE_EVIDENCE](Documentation/test-evidence/WORDPRESS_PUBLIC_SITE_EVIDENCE.md) | A read-only check of MFW's public website and REST API, and what MFW still confirms | Record: test evidence, public data only | 0.2 | Yuvraj (proposed, not agreed) | Both developers |
| [DEPLOYMENT_PLAN](Documentation/DEPLOYMENT_PLAN.md) | Environments, configuration, release sequence | Authoritative: deployment (planned) | 0.6 | Sanika (interim) | Both developers; MFW for environments and costs |
| [CLOUD_ACCESS_SETUP_CHECKLIST](Documentation/CLOUD_ACCESS_SETUP_CHECKLIST.md) | What to confirm and do when MFW grants cloud access, and what can be built locally before then | Plan: not started | 0.1 | Yuvraj (proposed, not agreed) | Both developers; MFW for the provider, projects, region and cost |
| [BACKUP_AND_RECOVERY](Documentation/BACKUP_AND_RECOVERY.md) | Proposed backup, restore and escalation | Authoritative: backup (proposed) | 0.6 | Sanika (interim) | Both developers, then MFW for cost and data obligations |
| [APP_STORE_RELEASE_CHECKLIST](Documentation/APP_STORE_RELEASE_CHECKLIST.md) | What must be true before store submission | Authoritative: store release | 0.4 | Sanika (interim) | Both developers; MFW for the listing and submission |
| [MAINTENANCE_AND_HANDOVER](Documentation/MAINTENANCE_AND_HANDOVER.md) | Handover items, warranty, after the warranty | Authoritative: handover | 0.4 | Sanika (interim) | Both developers; MFW agrees the handover at M5 |
| [SECURITY_INCIDENT_PROCEDURE](Documentation/SECURITY_INCIDENT_PROCEDURE.md) | Steps for security incidents | Authoritative: security incidents (proposed) | 0.4 | Sanika (proposed, not agreed) | Both developers; MFW for contacts; MFW's legal adviser for legal matters |

## Status labels

The labels CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN and CONFLICT are defined in [Documentation/REQUIREMENTS_SPECIFICATION.md](Documentation/REQUIREMENTS_SPECIFICATION.md) section 1.2. The evidence needed for AGREED, APPROVED and ANSWERED is in `DECISION_LOG.md` section 3.1. NOT VERIFIED means that nothing has checked the claim.
