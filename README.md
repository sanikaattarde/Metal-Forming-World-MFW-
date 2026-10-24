# Metal-Forming-World-MFW-

Documentation for the Metal Forming World (MFW) mobile application: a Flutter app for Android and iOS, a backend, and a web admin panel for MFW's magazine issues and news.

**State of this repository.** Documentation stage only. There is no application code, no build, no deployment and no store submission. Every document is a draft. MFW has not approved any document, and the proposal and the statement of work are unsigned copies (OQ-28). Where a document says a decision is agreed or approved, it follows the evidence rules in [Documentation/DECISION_LOG.md](Documentation/DECISION_LOG.md) section 3.1.

**This repository is public.** Do not commit credentials, reader data, or the details of a security incident (see [Documentation/SECURITY_INCIDENT_PROCEDURE.md](Documentation/SECURITY_INCIDENT_PROCEDURE.md) section 5).

## Where to start

```text
Reading order
├── 1 What the project is:    PROJECT_CHARTER, REQUIREMENTS_SPECIFICATION, SCOPE_AND_EXCLUSIONS, GLOSSARY
├── 2 What is decided, open, risky:  DECISION_LOG, OPEN_QUESTIONS, RISK_REGISTER, ASSUMPTIONS_AND_CONSTRAINTS
├── 3 How it is designed:     SYSTEM_ARCHITECTURE, TECHNOLOGY_DECISIONS, DATABASE_AND_DATA_MODEL,
│                             API_AND_BACKEND_CONTRACT, API_AND_MODULE_CONTRACTS, SECURITY_AND_ACCESS_CONTROL,
│                             PDF_READER_AND_OFFLINE_DESIGN, SCREEN_INVENTORY_AND_NAVIGATION
├── 4 How the two developers work:  DEVELOPMENT_ROADMAP, TASK_OWNERSHIP_MATRIX, DEVELOPMENT_WORKFLOW,
│                             CODING_STANDARDS, DEFINITION_OF_DONE
├── 5 How it is tested:       ACCEPTANCE_CRITERIA, TESTING_STRATEGY, TEST_DATA_AND_FIXTURES, CI_CD_AND_QUALITY_GATES,
│                             REQUIREMENT_COVERAGE_MATRIX
└── 6 How it is released and handed over:  DEPLOYMENT_PLAN, BACKUP_AND_RECOVERY, APP_STORE_RELEASE_CHECKLIST,
                              MAINTENANCE_AND_HANDOVER, SECURITY_INCIDENT_PROCEDURE, DEPENDENCY_REGISTER
```

[Documentation/CHANGELOG.md](Documentation/CHANGELOG.md) records what changed and when. [Documentation/TASK_OWNERSHIP_MATRIX.md](Documentation/TASK_OWNERSHIP_MATRIX.md) section 13 says which document is the home of each topic.

## Index of documents

- **Authoritative** means a document is the single home of that topic in this repository. It does not mean approved.
- **Derived** means the document repeats what others say and is not a source of truth.
- **Proposed owner** is taken from `TASK_OWNERSHIP_MATRIX.md` section 8.2. No owner is agreed. "Interim" means the document was drafted in that developer's session and no editor has been chosen.
- **Version** is read from each document's own control table.

| Document | Purpose | Role | Version | Proposed owner | Approval needed |
|---|---|---|---|---|---|
| [MFW_Commercial_Proposal-2.pdf](Documentation/MFW_Commercial_Proposal-2.pdf) | S1, the commercial proposal | Source | Issued, unsigned (OQ-28) | None (issued document) | Not applicable |
| [MFW_Statement_of_Work.pdf](Documentation/MFW_Statement_of_Work.pdf) | S2, the statement of work | Source | Issued, unsigned (OQ-28) | None (issued document) | Not applicable |
| [PROJECT_CHARTER](Documentation/PROJECT_CHARTER.md) | Project framing, stakeholders, governance | Authoritative: framing | 0.2 | Yuvraj (proposed, not agreed) | Not stated in the document |
| [REQUIREMENTS_SPECIFICATION](Documentation/REQUIREMENTS_SPECIFICATION.md) | Functional and non-functional requirements | Authoritative: requirements | 0.1 | Yuvraj (proposed, not agreed) | Not stated in the document |
| [SCOPE_AND_EXCLUSIONS](Documentation/SCOPE_AND_EXCLUSIONS.md) | What is in scope, excluded, or needs a change request | Authoritative: scope | 0.1 | Not assigned | Not stated in the document |
| [ASSUMPTIONS_AND_CONSTRAINTS](Documentation/ASSUMPTIONS_AND_CONSTRAINTS.md) | Assumptions, constraints and dependencies | Authoritative: assumptions | 0.2 | Not assigned | Not stated in the document |
| [GLOSSARY](Documentation/GLOSSARY.md) | Terms used in the documents | Supporting | 0.1 | Not assigned | Not stated in the document |
| [DECISION_LOG](Documentation/DECISION_LOG.md) | Decisions and the evidence each status needs | Authoritative: decisions | 0.2 | Sanika (interim) | Both developers for the structure |
| [OPEN_QUESTIONS](Documentation/OPEN_QUESTIONS.md) | Questions for MFW and for the developers | Authoritative: questions | 0.2 | Sanika (interim) | Both developers |
| [RISK_REGISTER](Documentation/RISK_REGISTER.md) | Risks, ratings and owners | Authoritative: risks | 0.2 | Sanika (interim) | Both developers; MFW for risks it must accept |
| [SYSTEM_ARCHITECTURE](Documentation/SYSTEM_ARCHITECTURE.md) | Components, data flows, trust boundaries | Authoritative: logical architecture | 0.3 | Joint | Both developers; MFW for cost, scope or contract effects |
| [TECHNOLOGY_DECISIONS](Documentation/TECHNOLOGY_DECISIONS.md) | Technology options and proposed choices | Authoritative: technology options | 0.3 | Joint | Both developers; MFW for cost, scope or contract effects |
| [DATABASE_AND_DATA_MODEL](Documentation/DATABASE_AND_DATA_MODEL.md) | Data, relationships, retention | Authoritative: data model | 0.3 | Yuvraj (proposed, not agreed) | Both developers; MFW for cost, scope or contract effects |
| [API_AND_BACKEND_CONTRACT](Documentation/API_AND_BACKEND_CONTRACT.md) | The single catalogue of backend operations | Authoritative: backend operations | 0.2 | Yuvraj (proposed, not agreed) | Both developers; MFW for cost, scope or contract effects |
| [API_AND_MODULE_CONTRACTS](Documentation/API_AND_MODULE_CONTRACTS.md) | App modules, integration contracts, app-side errors | Authoritative: app modules | 0.2 | Sanika (interim) | Both developers |
| [SECURITY_AND_ACCESS_CONTROL](Documentation/SECURITY_AND_ACCESS_CONTROL.md) | Access rules, threats, controls, security tests | Authoritative: access and security | 0.2 | Yuvraj (proposed, not agreed) | Both developers; MFW for cost, scope or contract effects |
| [PDF_READER_AND_OFFLINE_DESIGN](Documentation/PDF_READER_AND_OFFLINE_DESIGN.md) | Device-side reader and offline design | Authoritative: reader and offline (proposed) | 0.1 | Yuvraj (proposed, not agreed) | Both developers; MFW at M2 for the reader approach |
| [SCREEN_INVENTORY_AND_NAVIGATION](Documentation/SCREEN_INVENTORY_AND_NAVIGATION.md) | Screens and states the requirements imply; input to the M2 designs | Authoritative: screen list (proposed) | 0.1 | Yuvraj for app, Sanika for admin (proposed) | Both developers; MFW approves the screens at M2 |
| [DEVELOPMENT_ROADMAP](Documentation/DEVELOPMENT_ROADMAP.md) | Work packages, tasks, internal estimates | Planning, not a commitment | 0.3 | Sanika (interim) | Both developers; MFW approves milestones, not the plan |
| [TASK_OWNERSHIP_MATRIX](Documentation/TASK_OWNERSHIP_MATRIX.md) | Who owns what, and the document map | Authoritative: ownership and map | 0.3 | Sanika (interim) | Both developers |
| [DEVELOPMENT_WORKFLOW](Documentation/DEVELOPMENT_WORKFLOW.md) | Branches, reviews, merges | Authoritative: process | 0.2 | Sanika (interim) | Both developers. No MFW approval |
| [CODING_STANDARDS](Documentation/CODING_STANDARDS.md) | Coding rules and on-device storage rules | Authoritative: standards | 0.2 | Sanika (interim) | Both developers |
| [DEFINITION_OF_DONE](Documentation/DEFINITION_OF_DONE.md) | What done means for each kind of work | Authoritative: done | 0.2 | Sanika (interim) | Both developers |
| (see the document map) | Working rules for AI-assisted drafting. Named in the document map, `TASK_OWNERSHIP_MATRIX.md` section 13.1 | Supporting | 0.2 | Sanika (interim) | Both developers |
| [DEPENDENCY_REGISTER](Documentation/DEPENDENCY_REGISTER.md) | Packages, services and accounts, with licences | Authoritative: dependencies | 0.2 | Sanika (interim) | Both developers; MFW for any paid component |
| [CHANGELOG](Documentation/CHANGELOG.md) | Record of changes to the repository | Record | 0.3 | Sanika (interim) | None stated |
| [ACCEPTANCE_CRITERIA](Documentation/ACCEPTANCE_CRITERIA.md) | S2 criteria AC-1 to AC-12 as checks, and proposed PAC rows | Authoritative: acceptance rows | 0.2 | Sanika (interim) | Both developers; MFW in writing for each PAC row |
| [TESTING_STRATEGY](Documentation/TESTING_STRATEGY.md) | Test levels, plans, security checklist | Authoritative: test plans | 0.2 | Sanika (interim); move to Yuvraj proposed | Both developers |
| [TEST_DATA_AND_FIXTURES](Documentation/TEST_DATA_AND_FIXTURES.md) | Test users, files and network scenarios | Authoritative: fixtures | 0.2 | Sanika (interim); move to Yuvraj proposed | Both developers; MFW for where its sample PDFs are stored |
| [CI_CD_AND_QUALITY_GATES](Documentation/CI_CD_AND_QUALITY_GATES.md) | Planned checks on each change | Authoritative: quality gates (planned) | 0.2 | Sanika (interim); move to Yuvraj proposed | Both developers; MFW if a cost is billed to MFW |
| [REQUIREMENT_COVERAGE_MATRIX](Documentation/REQUIREMENT_COVERAGE_MATRIX.md) | Which rows and plans name each requirement | Derived, not a source of truth | 0.1 | Yuvraj (proposed, not agreed) | Both developers |
| [DEPLOYMENT_PLAN](Documentation/DEPLOYMENT_PLAN.md) | Environments, configuration, release sequence | Authoritative: deployment (planned) | 0.2 | Sanika (interim) | Both developers; MFW for environments and costs |
| [BACKUP_AND_RECOVERY](Documentation/BACKUP_AND_RECOVERY.md) | Proposed backup, restore and escalation | Authoritative: backup (proposed) | 0.2 | Sanika (interim) | Both developers, then MFW for cost and data obligations |
| [APP_STORE_RELEASE_CHECKLIST](Documentation/APP_STORE_RELEASE_CHECKLIST.md) | What must be true before store submission | Authoritative: store release | 0.2 | Sanika (interim) | Both developers; MFW for the listing and submission |
| [MAINTENANCE_AND_HANDOVER](Documentation/MAINTENANCE_AND_HANDOVER.md) | Handover items, warranty, after the warranty | Authoritative: handover | 0.2 | Sanika (interim) | Both developers; MFW agrees the handover at M5 |
| [SECURITY_INCIDENT_PROCEDURE](Documentation/SECURITY_INCIDENT_PROCEDURE.md) | Steps for security incidents | Authoritative: security incidents (proposed) | 0.1 | Sanika (proposed, not agreed) | Both developers; MFW for contacts; MFW's legal adviser for legal matters |

## Status labels

The labels CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN and CONFLICT are defined in [Documentation/REQUIREMENTS_SPECIFICATION.md](Documentation/REQUIREMENTS_SPECIFICATION.md) section 1.2. The evidence needed for AGREED, APPROVED and ANSWERED is in `DECISION_LOG.md` section 3.1. NOT VERIFIED means that nothing has checked the claim.
