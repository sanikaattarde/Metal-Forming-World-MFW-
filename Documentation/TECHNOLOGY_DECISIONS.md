# Technology Decisions: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document title | Technology Decisions |
| File | `TECHNOLOGY_DECISIONS.md`, in the same folder as `REQUIREMENTS_SPECIFICATION.md` |
| Project | Metal Forming World (MFW) mobile application |
| Version | 0.2 |
| Status | Draft for Review |
| Last updated | 23 October 2026 |
| Prepared by | MFW development team |
| Approval status | Not approved. No MFW or internal approval of this document has been recorded. Every decision below is PROPOSED or OPEN, except TD-01, which S2 and the charter confirm, and TD-15 and TD-19, which the development team accepted in the second interview (GS-Q19, GS-Q28). That status is not MFW's approval (Section 1.2). |
| Related documents | [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) v0.1; [Scope and Exclusions](SCOPE_AND_EXCLUSIONS.md) v0.1; [Assumptions and Constraints Register](ASSUMPTIONS_AND_CONSTRAINTS.md) v0.1; [Glossary](GLOSSARY.md) v0.1; [System Architecture](SYSTEM_ARCHITECTURE.md) v0.2; [Database and Data Model](DATABASE_AND_DATA_MODEL.md) v0.2; [API and Backend Contract](API_AND_BACKEND_CONTRACT.md) v0.1; [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) v0.1; `PROJECT_CHARTER.md` v0.1 |

**Purpose.** This document records the technology choices for the MFW mobile app, its backend and its admin panel, in the form of architecture decision records. For each material choice it states the problem, the realistic options, the evaluation criteria, the recommendation, the evidence, the conditions for approval and the triggers for review. It separates choosing a technology from configuring a provider, and it separates decisions that must be made before implementation from decisions that can wait.

**What this document is not.** It is not an approval. A recommendation here is not an approved decision. Charter §17.4 says the architecture, the authentication provider, the reader library and the data model are not approved by the charter. Each is decided in a recorded decision, agreed by both developers. A decision that adds third-party cost, changes scope or touches the contract also needs MFW's written approval before it is implemented. This document contains no application code, no cloud configuration and no credentials.

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft for internal review. Revised the same day: a tree replaces the decision summary table in Section 8.1, and a proof plan for resumable signed-URL downloads is added to TD-09 and referred to in AOQ-07. TD-15 gains enforcement tests and a revised security note, and AOQ-17 is added. No decision, status or requirement changed. |
| 0.2 | 23 October 2026 | Revised after the second interview (GS-Q17 to GS-Q33, GS-D13 to GS-D20) and a read-only review of MFW's website (WEB). TD-15 and TD-19 take the status accepted by the development team, with MFW written approval pending. TD-15 drops the role claim and makes admin reads function-only (GS-Q20), and AOQ-17 is answered by that proposal. TD-19 gains an undo and an immediate option, and no longer disables sign-in during the window. TD-09 gains an approval condition on the website's public PDFs (AOQ-18). New: PRC-04 (the update gate), AOQ-18 to AOQ-20, and not-verified items 22 and 23. No requirement status in the specification changed. |

### 1.1 Sources and authority

| Ref | Source | Evidence status | Authority in this document |
|---|---|---|---|
| S1 | MFW Mobile App Commercial Proposal, `MFW_Commercial_Proposal-2.pdf`, 17 October 2026 | Read. The copy is unsigned. | Shows what the proposal says. Its formal acceptance is unverified (REG-002). |
| S2 | MFW Mobile App Statement of Work, `MFW_Statement_of_Work.pdf`, 17 October 2026 | Read. The copy is unsigned. | Source of the proposed architecture and the acceptance criteria. Its formal acceptance is unverified (REG-002). |
| S3 | Client emails received after S1 and S2 | Not available. Not in the repository. Known only through the charter. | Not used as evidence. Amendments recorded in the charter stay PROVISIONAL (REG-001). |
| CH | `PROJECT_CHARTER.md` v0.1, 22 October 2026 | Read. Draft for review, unsigned. | Working summary. It does not override S1 or S2. |
| SPEC | [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) v0.1 | Read. Draft for Review. | Requirement IDs, statuses and acceptance criteria are used exactly as written there. |
| GS | The architecture questioning session held on 23 October 2026 with a member of the development team, run with the `/grill-me` skill | Answers recorded as GS-Q1 to GS-Q16 in Section 10. A second session on the same day, with the same skill, produced GS-Q17 to GS-Q33 and the defaults GS-D13 to GS-D20. | Development-team positions. They are not MFW approvals, and the other developer has not yet agreed them (charter §17.4, REG-052). |
| WEB | MFW's public website, https://metalformingworld.com/, read on 23 October 2026 | Observed. Not an approved source. | A reference for the WordPress contract and the taxonomy seed values. It does not change scope (INT-WP-002) and is not MFW's approval. |
| VS | Vendor documentation and pricing pages, read on 23 October 2026 | Listed in Section 9 with the way each was read. | Evidence for vendor facts. Pages can change, and some were read only in part. |

S1, S2 and CH are named by file name and not linked, because they are not in this folder. Fees, payment amounts and personal names are left out of this document, as in the specification. Vendor prices appear only where Section 9 shows they were read from the vendor's page.

### 1.2 Status vocabulary

Two vocabularies are used, and they are kept apart.

**Decision status (architecture decision record).**

| Status | Meaning |
|---|---|
| accepted | Settled by a source that confirms it. Only TD-01 qualifies. |
| accepted by the development team | The developer who ran the interview recorded the choice as accepted (GS-Q30). The requirement label stays PROVISIONAL, MFW's written approval is pending, and the other developer's agreement is not recorded (REG-052, AR-12). It is not CONFIRMED and it is not an approval. Used for TD-15 and TD-19. |
| proposed | The development team recommends it. It is not approved. |
| open | No recommendation is possible yet, or the recommendation depends on an open question. |
| rejected | Considered and not chosen. It is kept so the reasoning is not lost. |
| superseded | Replaced by a later decision. None yet. |

**Evidence label (project convention, spec §1.2).** CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN and CONFLICT mean what the specification says. A decision's evidence label says how well its requirement basis is established. It does not say that the technology is approved.

### 1.3 Identifiers

| Prefix | Meaning | Defined in |
|---|---|---|
| TD-nn | Technology decision | Section 5 of this document |
| AOQ-nn | New architecture open question, not in the specification's OQ list | Section 8 |
| AR-nn | Architecture risk | [System Architecture](SYSTEM_ARCHITECTURE.md) §14 |
| INV-nn | Data invariant in the enforcement register | [Database and Data Model](DATABASE_AND_DATA_MODEL.md) §10.8 |
| PRC-nn | Proposed requirement change that needs MFW's written approval | Section 8 |
| VS-nn | Vendor source | Section 9 |
| GS-Qn | Answer given in the architecture questioning session | Section 10 |
| GS-Dn | A default confirmed after a questioning session | Section 10 |
| OP-nn, CT-nn | Operation and contract test | [API and Backend Contract](API_AND_BACKEND_CONTRACT.md) |
| SC-nn, ST-nn | Security control and security test | [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) |
| WEB | An observation on MFW's website | Section 1.1 |
| FR, NFR, DATA, INT, BR | Requirement IDs | [REQUIREMENTS_SPECIFICATION.md](REQUIREMENTS_SPECIFICATION.md) Sections 5 to 9 |
| OQ, C, ASM, PAC, AC | Open questions, conflicts, assumptions, proposed criteria, S2 criteria | Specification Sections 10 and 12 |
| SCP, EXC, CHG | Scope items, exclusions and change items | [SCOPE_AND_EXCLUSIONS.md](SCOPE_AND_EXCLUSIONS.md) |
| REG | Register entries | [ASSUMPTIONS_AND_CONSTRAINTS.md](ASSUMPTIONS_AND_CONSTRAINTS.md) |

"CH D1" to "CH D9" are the open decisions in CH §19.3. "CH R1" to "CH R11" are the risks in CH §18. The TD, AOQ, AR, PRC, VS, GS and INV families are new in this set of documents. They do not collide with any earlier identifier.

## 2. Purpose and Decision-Making Principles

| Ref | Principle | Basis |
|---|---|---|
| P1 | Be proportionate. The design target is a small app. Fewer than 1,000 monthly active users is recorded as an ASSUMPTION from the development team's brief, because CH §6 says no volume target was agreed. | GS brief; CH §6 |
| P2 | Prefer the smallest number of moving parts. No microservices, no Kubernetes, no distributed system and no paid managed service unless a documented requirement needs it. | S2 Rationale; GS-Q1 |
| P3 | Label evidence. Distinguish what a source confirms from what is reported, assumed, open or in conflict. | Spec §1.2 |
| P4 | A recommendation is not an approval. Approval needs both developers, and MFW's written approval where cost, scope or the contract change. | CH §17.4; REG-052; REG-035 |
| P5 | Keep the cost of changing provider low. The app reaches backend services through a thin data layer, and the logical data model does not depend on one vendor. | NFR-MAINT-005 (ASSUMPTION) |
| P6 | Private by default, and collect the least personal data that serves the purpose. | NFR-PRIV-001 (PROVISIONAL); NFR-SEC-003 (CONFIRMED) |
| P7 | MFW owns the accounts. Developers use role-based access and never shared passwords. | NFR-SEC-012 (CONFIRMED) |
| P8 | No paid third-party component without MFW's written approval. | NFR-MAINT-006 (CONFIRMED) |
| P9 | Keep technology selection apart from provider-specific configuration. Configuration values are not set in this document. | Section 6 |
| P10 | Decide early what is expensive to change later, such as data location, and defer what is cheap to change. | Section 7 |

## 3. Evaluation Criteria

The same criteria are applied to every decision in Section 5. They are not weighted numerically, because the evidence does not support a scoring scheme. Each record states which criteria drove its recommendation.

| Ref | Criterion | What it asks |
|---|---|---|
| EC-1 | Fit | Does it meet the requirements in the traceability row, including the acceptance criteria? |
| EC-2 | Proportion | Can two developers build and run it in the available time, and is it no bigger than the app needs? |
| EC-3 | Cost to MFW | What third-party cost does MFW pay, and what are the limits of any free allowance? MFW pays third-party costs directly [S1 Costs outside the fee]. |
| EC-4 | Security and privacy | Does it enforce access on the backend, limit personal data and support deletion? |
| EC-5 | Operability | Can a small editorial team and a part-time maintainer run it? |
| EC-6 | Handover | Can any competent Flutter and Firebase developer maintain it, as S2 promises? |
| EC-7 | Lock-in | How costly is it to leave the vendor, and what limits the damage? |
| EC-8 | Contract alignment | Does it match the S2 and S1 wording, or does it need MFW's approval? |
| EC-9 | Maturity and currency | Is it maintained, and is the version current? Evidence is in Section 9. |
| EC-10 | Team skill | Does the team know it? The team's skills are not recorded in any source. This criterion is used only where GS records an answer. |

## 4. Technology Inventory

The inventory covers every capability the brief names. "Decide by" uses the spec's stage wording, because the milestone dates are PROVISIONAL (C-08).

| TD | Capability | Proposed choice | Decision status | Evidence label | Decide by |
|---|---|---|---|---|---|
| TD-01 | Mobile framework and language | Flutter, with Dart | accepted | CONFIRMED | Settled |
| TD-02 | State management and navigation | Riverpod and go_router | proposed | ASSUMPTION | Before M3 |
| TD-03 | Backend platform baseline | Firebase, as the S2 baseline | proposed | CONFLICT (C-05) | Before any cloud project is created |
| TD-04 | Server-side language and runtime | TypeScript on Node.js, in Cloud Functions for Firebase | proposed | ASSUMPTION | Before M3 |
| TD-05 | API style and contract format | Direct database access under security rules for per-user data, callable functions for privileged actions, no public REST API | proposed | ASSUMPTION | Before M3 |
| TD-06 | Authentication | Firebase Authentication with email and password, and Google Sign-In | proposed | PROVISIONAL (FR-AUTH-005, C-04) | Architecture document, then M2 |
| TD-07 | Primary database | Cloud Firestore, with a logical model that is independent of the vendor | proposed | CONFLICT (C-05) | Before any database is created |
| TD-08 | File and object storage | Cloud Storage for Firebase | proposed | CONFLICT (C-05) | Before any bucket is created |
| TD-09 | PDF delivery and access control | Function-issued short-lived signed URLs | proposed | CONFIRMED basis (NFR-SEC-002), proposed mechanism | Before M3 |
| TD-10 | PDF reader library | Open until the M2 reader test | open | CONFIRMED process (FR-READ-006) | M2 |
| TD-11 | Client download manager | A resumable HTTP download client, product to be chosen in a spike | open | ASSUMPTION | Before M3 |
| TD-12 | WordPress integration | Direct read of the WordPress REST API from the app, with device caching | proposed | CONFIRMED basis (INT-WP-001) | Before M2 approval |
| TD-13 | Push notifications | Firebase Cloud Messaging, with one topic per category | proposed | CONFIRMED basis (INT-PUSH-001) | Before M3 |
| TD-14 | Admin panel | React web app on Firebase Hosting | proposed | CONFIRMED in S2, OPEN in the charter | Before M3 |
| TD-15 | Admin roles and role management | Two roles, in-panel management, function-only admin reads and an audit log | accepted by the development team | CONFLICT (PRC-01) | Before M2 approval |
| TD-16 | Logging, monitoring and crash reporting | Crashlytics on, Analytics collection off until OQ-23 | proposed | CONFLICT (C-07) | Before M3 |
| TD-17 | Testing and CI/CD | Automated checks on every change, manual production deploys | proposed | ASSUMPTION | Before M3 |
| TD-18 | Environments, deployment and secrets | Development and production projects, plus a throwaway project for the AC-12 proof | proposed | ASSUMPTION | Before any cloud project is created |
| TD-19 | Account deletion, retention and backups | A grace window with undo, an immediate option, a scheduled purge, and managed backups | accepted by the development team | CONFIRMED basis (FR-PRIV-003), PRC-02 | Before M4 |
| TD-20 | Offline data and synchronisation | Database offline cache, with queued writes | proposed | OPEN (OQ-10) | Before M2 approval |
| TD-21 | Search and filters | Run on the device over the cached catalogue | proposed | ASSUMPTION (FR-SRCH-007) | Before M2 approval |
| TD-22 | Data location | Not chosen | open | OPEN (AOQ-01) | Before any cloud project is created |

## 5. Decision Records

Each record uses the same fields. "Approval needed from" names the role that must approve, using the roles in the register: MFW authorised approver, Contracting developer, Co-developer and Development team (both developers). Vendor facts carry a VS reference from Section 9. A fact marked NOT VERIFIED was looked for and not found on an official page, and it is not relied on.

### TD-01 Mobile framework and language

| Field | Entry |
|---|---|
| Technology or capability | Flutter, with the Dart language, as one codebase for Android and iOS |
| Decision status | accepted |
| Evidence label | CONFIRMED |
| Problem and context | The app must run on Android and iOS from one codebase within the budget and the plan [S2 Rationale]. |
| Options considered | Flutter. React Native. Two native apps. A web app (excluded, because a public web version is out of scope). |
| Evaluation criteria used | EC-1, EC-2, EC-8 |
| Advantages and disadvantages | Flutter gives one codebase and the same reader behaviour on both platforms [S2 Rationale]. Two native apps would double the effort. React Native is not named in any source. The cost is plugin upkeep: the Firebase plugins published new major versions about a week before this document (VS-42), so versions must be pinned and tested. |
| Cost and operational implications | No licence cost for the framework is recorded in S1 or S2. Store accounts are MFW's [S1 Costs outside the fee]. |
| Security and privacy implications | Downloaded issues are kept in the app's private storage (NFR-SEC-004, CONFIRMED). |
| Vendor lock-in and migration | Dart code does not move to another framework. The logical data model and the server contracts do not depend on the framework. |
| Recommendation | Flutter. The latest stable release listed when this document was written is 3.47.0 (VS-43). The Dart version that goes with it was NOT VERIFIED. The version is pinned when implementation starts. |
| Evidence and requirement traceability | NFR-COMP-001 (CONFIRMED); spec §11.1; CH §19.1; S2 Scope: Platform; REG-036 |
| Conditions for approval | None. The sources confirm it. |
| Review triggers | The reader test on MFW's PDFs fails on the low-cost device with no acceptable fallback (CH R1). A plugin the design depends on is abandoned. |
| Approval needed from | None beyond the sources. |
| Decide by | Settled |

### TD-02 State management and navigation

| Field | Entry |
|---|---|
| Technology or capability | flutter_riverpod for state and dependency injection, and go_router for navigation |
| Decision status | proposed |
| Evidence label | ASSUMPTION (a default applied under GS-D1, because the team's preference is not recorded) |
| Problem and context | The app has about fifteen screens and a thin data layer that limits the cost of changing provider (NFR-MAINT-005, ASSUMPTION). |
| Options considered | State: flutter_riverpod, Bloc, Provider. Navigation: go_router, a hand-built Navigator 2 setup, auto_route. |
| Evaluation criteria used | EC-2, EC-6, EC-9, EC-10 |
| Advantages and disadvantages | Riverpod keeps dependencies explicit and testable, which suits the repository pattern for the data layer. go_router is listed as feature-complete on its package page (VS-42). Both are widely used, which helps handover. The cost is a learning curve if neither developer knows Riverpod. |
| Cost and operational implications | flutter_riverpod 3.4.3 is under the MIT licence and go_router 18.1.1 under BSD-3-Clause, so no paid component is involved (VS-42, NFR-MAINT-006). |
| Security and privacy implications | None specific. |
| Vendor lock-in and migration | The state layer touches every screen, so a later change is costly. It is not a vendor lock-in. |
| Recommendation | Riverpod and go_router. Apply as a default and replace it if the developers prefer another approach before the first screen is built. |
| Evidence and requirement traceability | NFR-MAINT-005 (ASSUMPTION); NFR-COMP-001 (CONFIRMED); FR-STATE-001 to FR-STATE-007 (ASSUMPTION) |
| Conditions for approval | Both developers agree before the first screen is built. |
| Review triggers | A developer prefers Bloc. Shared links that open the app become in scope (excluded today, EXC-08 and FR-SHR-005). |
| Approval needed from | Development team |
| Decide by | Before M3 |

### TD-03 Backend platform baseline

| Field | Entry |
|---|---|
| Technology or capability | Firebase as the backend platform: accounts, database, files, server logic, push and hosting in one cloud project owned by MFW |
| Decision status | proposed |
| Evidence label | CONFLICT (C-05) |
| Problem and context | S2 proposes Firebase and names it in M3 and AC-12. S1 A-21 to A-25 refer to it. CH §11 and §17.4 say the architecture is not approved. A different choice that changes M3, AC-12 or third-party cost needs MFW's written approval (CHG-04). |
| Options considered | A: Firebase (the S2 baseline). B: a PostgreSQL-based managed backend such as Supabase. C: a custom API on a major cloud with managed PostgreSQL and object storage. D: self-hosting on MFW's existing WordPress host. |
| Evaluation criteria used | EC-1, EC-2, EC-3, EC-5, EC-7, EC-8 |
| Advantages and disadvantages | A matches the S1 and S2 wording, so it needs no contract change. It has one console, official Flutter plugins (VS-42) and a database cache for offline use (VS-18). Its disadvantages are Google-specific data and sign-in models, usage-based cost, and no free Storage allowance outside three US regions (VS-01). B gives SQL integrity and easier export, but it departs from S2 and its prices and limits were not researched (NOT VERIFIED). C is the most flexible and has the most parts. S2 judged an AWS-based design to need more parts and more time with no benefit at launch volumes [S2 Rationale]. D is rejected: the host's capacity is unknown (REG-042), the project may not change the WordPress site (INT-WP-002) and files up to 150 MB would load a shared site. |
| Cost and operational implications | Cloud Storage and Cloud Functions need the pay-as-you-go plan (VS-02, VS-03), so MFW must switch on billing in its own project (REG-037). Usage is billed to MFW and is not quoted in S1. The cost drivers and verified figures are in Section 9 and in [System Architecture](SYSTEM_ARCHITECTURE.md) §13. |
| Security and privacy implications | Access rules are written in the provider's rules language and tested. Privileged server code uses the Admin SDK and bypasses rules, so every function must check the caller. Data location is chosen once (TD-22). |
| Vendor lock-in and migration | High for the database model and for sign-in accounts. Limits: a thin data layer in the app (NFR-MAINT-005), a data model that is independent of the vendor ([Database and Data Model](DATABASE_AND_DATA_MODEL.md)), and PDFs that stay in a standard object store. A migration path for password accounts was not researched (NOT VERIFIED). |
| Recommendation | A, as the proposed baseline. Each Firebase service is labelled proposed and not approved. This follows GS-Q1. |
| Evidence and requirement traceability | C-05; REG-035; CHG-04; SCP-072 (CONFLICT); NFR-MAINT-002 (CONFIRMED); NFR-MAINT-005 (ASSUMPTION); S2 Architecture; S2 Rationale; S1 A-21 to A-25 |
| Conditions for approval | Both developers agree (CH §17.4). MFW supplies a cloud project in its name with billing on (REG-037). MFW is shown the usage-based cost drivers. MFW approves in writing if the final choice changes M3, AC-12 or third-party cost. |
| Review triggers | A vendor price or plan change that alters Section 9. A reader or load test that shows a limit. MFW refuses Google services. Legal advice on data location (AOQ-01). |
| Approval needed from | Development team, and MFW authorised approver if terms or cost change |
| Decide by | Before any cloud project is created |

### TD-04 Server-side language and runtime

| Field | Entry |
|---|---|
| Technology or capability | TypeScript on Node.js, in Cloud Functions for Firebase |
| Decision status | proposed |
| Evidence label | ASSUMPTION |
| Problem and context | S2 places upload checks, publishing, notification sending and account deletion in server logic. This design adds access issuing for PDFs, admin role management and a scheduled purge (TD-09, TD-15, TD-19). That is roughly ten functions. S2 names no language. |
| Options considered | TypeScript on Node.js. Python. |
| Evaluation criteria used | EC-2, EC-6, EC-10 |
| Advantages and disadvantages | The documentation lists Node.js 20 and 22 and Python 3.10 to 3.13 as supported, and says TypeScript is supported (VS-13). TypeScript matches the admin panel language (TD-14), so one language covers the server and the admin side. Node 18 is described as deprecated since early 2025 (VS-13), so a supported version must be chosen. |
| Cost and operational implications | The no-cost allowance is 2 million invocations a month, then USD 0.40 per million. Compute allowances and the outbound-network price are in Section 9 (VS-01). Expected invocations are far below the allowance. |
| Security and privacy implications | Functions use elevated credentials, so each one authenticates the caller, validates input and avoids logging personal data. Dependencies are pinned and audited. |
| Vendor lock-in and migration | Low for the language. The trigger and callable wrappers are Firebase-specific. |
| Recommendation | TypeScript on Node.js, using a supported release at implementation time. This follows GS-Q2. The release is a configuration choice and is not set here. |
| Evidence and requirement traceability | FR-ADMIN-006, FR-ADMIN-007, NFR-SEC-008 (upload checks on the backend); FR-PRIV-003; FR-ADMIN-015, FR-ADMIN-016; S2 Architecture: Server logic |
| Conditions for approval | The developers confirm TypeScript skills (EC-10). |
| Review triggers | The chosen runtime is deprecated. A skills gap appears. |
| Approval needed from | Development team |
| Decide by | Before M3 |

### TD-05 API style and contract format

| Field | Entry |
|---|---|
| Technology or capability | Direct database access under security rules for per-user and catalogue data. Callable functions for privileged or multi-step actions. Read-only WordPress REST. No public REST API. |
| Decision status | proposed |
| Evidence label | ASSUMPTION |
| Problem and context | The app and the admin panel must read and write data and trigger privileged actions, with access enforced on the backend (NFR-SEC-002, NFR-SEC-005, NFR-SEC-007). |
| Options considered | A: the hybrid above. B: every call through a custom REST or GraphQL API, with the database closed to clients. C: direct database access only, with no functions. |
| Evaluation criteria used | EC-2, EC-4, EC-7 |
| Advantages and disadvantages | A needs the least code. The offline cache works for direct access (VS-18). Callable functions carry the caller's sign-in context (VS-15). The cost is that rules are code that must be tested, and logic is split between rules and functions. B is more portable and needs much more code, and it gives up the offline cache. C cannot safely validate uploads, issue file access, send notifications or delete accounts. |
| Cost and operational implications | The hybrid keeps function use to privileged actions, which stays within the no-cost allowance at the assumed scale (VS-01). |
| Security and privacy implications | Rules deny by default and allow only each reader's own data. Functions check the caller on every call. App Check can protect callable functions from clients that are not the real app (VS-15, VS-16). Its cost and setup were not researched (AOQ-10). |
| Vendor lock-in and migration | Medium. The callable contract is a set of operation records ([API and Backend Contract](API_AND_BACKEND_CONTRACT.md)), so a later API can reuse them. |
| Recommendation | A. There is no OpenAPI document, because no public REST API exists. The contracts are operation records in the API and Backend Contract (GS-D13), and the TypeScript functions and the React admin panel can share types. Changes to a contract follow the compatibility policy in that document, Section 9, which the development team accepted (GS-Q29). |
| Evidence and requirement traceability | NFR-SEC-002, NFR-SEC-005, NFR-SEC-007, NFR-SEC-008 (CONFIRMED); NFR-MAINT-005 (ASSUMPTION); S2 Rationale: Security |
| Conditions for approval | Rules and functions are covered by automated tests that run without a production project (TD-17). |
| Review triggers | The provider changes (TD-03). A second client needs a public API. |
| Approval needed from | Development team |
| Decide by | Before M3 |

### TD-06 Authentication

| Field | Entry |
|---|---|
| Technology or capability | Firebase Authentication, with email and password, and Google Sign-In |
| Decision status | proposed |
| Evidence label | PROVISIONAL (FR-AUTH-005, C-04) |
| Problem and context | Readers register and sign in with email and password, and with Google. Full access needs a verified email address. Accounts can be deleted from the app. The reader and admin identities need one trusted source. S2 excludes Google Sign-In, and the charter records it as in scope [S3] (C-04). |
| Options considered | A: Firebase Authentication. B: the same product upgraded to Identity Platform, which adds multi-factor sign-in. C: another provider such as Auth0, Clerk, Supabase Auth or Cognito (not researched). D: custom authentication (rejected, because password handling would be a new security burden). |
| Evaluation criteria used | EC-1, EC-3, EC-4, EC-7, EC-8 |
| Advantages and disadvantages | A is named in S2 and supports every INT-AUTH-001 capability. Its no-cost limit is 50,000 monthly active users (VS-01). Multi-factor sign-in, by SMS or TOTP, needs the upgrade in option B, and its rates were NOT VERIFIED (VS-32, VS-33). The documentation says accounts are linked automatically when criteria are met, that a password account without a verified email is untrusted, and that Google counts as trusted only for Gmail addresses (VS-25). Linking a credential that already belongs to another account is documented as failing, and unlinking and signing in again creates a separate account (VS-26). The outcome for each combination, and whether Google sign-in sets the verified-email state, were NOT VERIFIED (AOQ-08, AOQ-09). |
| Cost and operational implications | No sign-in cost is expected at the assumed scale (VS-01). Phone sign-in is billed per SMS and is not used. |
| Security and privacy implications | The provider holds the email, name and user identifier, and the app keeps only the identifier (GS-Q5). The linking rule below protects against taking over an account through an unverified email. Apple's guideline 4.8 expects an equivalent sign-in option when a third-party sign-in is offered, unless an exemption applies (VS-40). MFW has been recorded as accepting that risk [S3 via CH §18 R9], and the proposal here does not change it (OQ-06, CHG-06). |
| Vendor lock-in and migration | High for user identifiers and password hashes. A migration route was not researched (NOT VERIFIED). |
| Recommendation | A, with this proposed rule for OQ-04 and OQ-05: one account per email address, trust the provider's verified-email result for Google, and link Google to an existing password account only when that account's email is verified. Otherwise the reader verifies first. This follows GS-Q1 and GS-Q3. Multi-factor sign-in for admins stays OPEN (AOQ-03). |
| Evidence and requirement traceability | FR-AUTH-001 to FR-AUTH-004, FR-AUTH-009, FR-AUTH-010 (CONFIRMED); FR-AUTH-005 (PROVISIONAL); FR-AUTH-006, FR-AUTH-007 (OPEN); INT-AUTH-001 (CONFIRMED); INT-AUTH-002 (PROVISIONAL); BR-002 (CONFIRMED); OQ-04, OQ-05, OQ-06; C-04; REG-017, REG-018, REG-020 |
| Conditions for approval | MFW confirms Google Sign-In in writing (OQ-29) and accepts the App Store risk (OQ-06). A spike tests each linking combination and the Google verified-email state (AOQ-08, AOQ-09). MFW approves OQ-04 and OQ-05 in writing, as the specification requires. |
| Review triggers | Apple requires an equivalent sign-in option. Linking errors appear for non-Gmail Google accounts. Pricing or plan limits change. |
| Approval needed from | MFW authorised approver, for OQ-04, OQ-05 and OQ-06. Development team, for the provider. |
| Decide by | Architecture document, then before M2 approval |

### TD-07 Primary database

| Field | Entry |
|---|---|
| Technology or capability | Cloud Firestore, with a logical relational model that does not depend on the vendor |
| Decision status | proposed |
| Evidence label | CONFLICT (C-05) |
| Problem and context | The product stores issues, categories, each reader's app records, profiles, bookmarks, favourites, notification preferences, send records, news controls, admin roles and an audit log (DATA-001 to DATA-012). Access is enforced by rules, and bookmarks and favourites follow a reader to a second device (FR-BKM-004). |
| Options considered | A: Cloud Firestore. B: managed PostgreSQL, for example Cloud SQL or a PostgreSQL-based backend service. C: Firebase Realtime Database (older product, not researched, not named in S2). |
| Evaluation criteria used | EC-1, EC-2, EC-3, EC-4, EC-7, EC-8 |
| Advantages and disadvantages | A needs no server, enforces per-user access through rules, caches data on the device and queues offline writes (VS-18). In this design the database engine is not assumed to enforce references or uniqueness, so rules, functions and the data layer do, which is to be confirmed in the implementation spike. A document is limited to 1 MiB (VS-17), which is a reason never to store PDFs in the database (TD-08). B gives constraints, joins and easy export. It needs an API layer (TD-05, option B), and its cost and limits were not researched (NOT VERIFIED). |
| Cost and operational implications | The Standard edition no-cost daily allowance is 1 GiB stored, 50,000 reads, 20,000 writes and 20,000 deletes, with 10 GiB a month of network egress (VS-01). The design aims to stay inside it and checks this by measuring reads in test builds. The Mumbai price per 100,000 reads and writes was NOT VERIFIED. Scheduled backups and point-in-time recovery have no no-cost allowance (VS-17, VS-19, VS-20). |
| Security and privacy implications | Rules deny by default. Server code uses the Admin SDK, which bypasses rules, so it must apply its own checks. Personal data is limited to the profile fields in [Database and Data Model](DATABASE_AND_DATA_MODEL.md). |
| Vendor lock-in and migration | High for the physical model. The logical model in the data-model document is relational and portable. The registered-user export is produced by a function, so no vendor-specific query is exposed to the admin panel. |
| Recommendation | A, with the logical model first and the Firestore mapping marked provisional. This follows GS-Q1 and GS-Q14. |
| Evidence and requirement traceability | DATA-001 to DATA-012, with the statuses in the specification and in [Database and Data Model](DATABASE_AND_DATA_MODEL.md) §15.1; FR-BKM-004 (CONFIRMED); NFR-MAINT-005 (ASSUMPTION); S2 Architecture: Database |
| Conditions for approval | The data location is chosen (TD-22). The security rules pass automated tests (TD-17). MFW approves in writing if the final choice changes M3, AC-12 or cost (CHG-04). |
| Review triggers | The catalogue or user count outgrows the no-cost allowance. A need for relational reporting appears. A vendor price change. |
| Approval needed from | Development team, and MFW authorised approver if terms or cost change |
| Decide by | Before any database is created |

### TD-08 File and object storage

| Field | Entry |
|---|---|
| Technology or capability | Cloud Storage for Firebase, with a private path for PDFs and a public-read path for cover images |
| Decision status | proposed |
| Evidence label | CONFLICT (C-05) |
| Problem and context | Issue PDFs are up to about 150 MB and 120 pages, with five to twelve issues live (NFR-STOR-001, NFR-STOR-002, ASSUMPTION), roughly 2 GB in total. PDFs must be private (NFR-SEC-003). Covers are public metadata (FR-MAG-002). There is no content delivery network at launch (NFR-STOR-003). |
| Options considered | A: Cloud Storage for Firebase. B: a Google Cloud Storage bucket used without the Firebase layer. C: another object store such as an S3-compatible service (not researched). D: PDFs in database rows (rejected: a document is limited to 1 MiB, VS-17). |
| Evaluation criteria used | EC-1, EC-3, EC-4, EC-7 |
| Advantages and disadvantages | A and B are the same storage service. A adds rules and Firebase tooling. Storage for Firebase now requires the pay-as-you-go plan (VS-03). Its no-cost allowance is 5 GB-months stored, 100 GB a month downloaded, 5,000 uploads and 50,000 downloads a month, but only for buckets in us-central1, us-west1 and us-east1 (VS-01). A Mumbai bucket has no such allowance, so it is billed from the first byte. |
| Cost and operational implications | Mumbai Standard storage is USD 0.000027397 per GiB-hour, about USD 0.02 per GiB-month. Internet egress to Asia destinations is USD 0.12 per GiB for the first 10 TiB a month, and Class B operations cost USD 0.0004 per 1,000 for single-region Standard (VS-04). Soft delete is on by default with seven-day retention, and soft-deleted objects keep accruing storage charges until it expires (VS-05). Object versioning is not on by default and would add cost if enabled (VS-06). |
| Security and privacy implications | Clients have no read access to the private path. Files are released only through TD-09. Uploads go to a holding path and are validated by a function before they move to the private path (FR-ADMIN-006, FR-ADMIN-007, NFR-SEC-008). A non-expiring download link from the provider's SDK is not used for private files (VS-10). |
| Vendor lock-in and migration | Low to medium. PDFs and covers are ordinary objects, and signed URLs have equivalents in other object stores. |
| Recommendation | A. The location is open (TD-22). |
| Evidence and requirement traceability | NFR-SEC-002, NFR-SEC-003 (CONFIRMED); NFR-STOR-001 to NFR-STOR-003 (ASSUMPTION); INT-FILE-001 (CONFIRMED); FR-ADMIN-005 to FR-ADMIN-007 (CONFIRMED); DATA-001 (CONFIRMED); R2 |
| Conditions for approval | The location is chosen. MFW is shown the egress cost driver. Soft-delete behaviour is documented in the privacy inputs (TD-19). |
| Review triggers | Monthly download volume nears or passes the point where egress matters to MFW (AOQ-11). A content delivery network is requested (CHG-05). |
| Approval needed from | Development team, and MFW authorised approver if cost changes |
| Decide by | Before any bucket is created |

### TD-09 PDF delivery and access control

| Field | Entry |
|---|---|
| Technology or capability | A callable function that checks the reader and returns a short-lived signed URL for the issue file |
| Decision status | proposed |
| Evidence label | CONFIRMED basis (NFR-SEC-002), proposed mechanism |
| Problem and context | The backend must refuse a direct file request from a logged-out reader or from a reader with an unverified email (NFR-SEC-002, AC-3). The file is up to 150 MB, so a download must resume after a network break (FR-DL-006). When BR-003 is confirmed, a complete profile is also required. Under the working assumption of one action (GS-Q6), opening an issue downloads it and keeps it. The same issues may be public on MFW's website, so the sign-in gate controls the app's copy only (AOQ-18, GS-Q32). |
| Options considered | A: function-issued V4 signed URLs. B: direct download through the Storage SDK under Storage rules. C: stream the file through a function. |
| Evaluation criteria used | EC-1, EC-4, EC-5, EC-7 |
| Advantages and disadvantages | A puts the access decision in one function. A signed URL expires, and its longest lifetime is seven days (VS-07). The signing identity needs the Service Account Token Creator role and the Service Account Credentials API, plus read permission on the object (VS-08). The Range header on object downloads is documented for resuming an interrupted download (VS-09). Whether a signed URL honours Range was NOT VERIFIED (AR-01). B avoids a function, but Storage rules may read at most two Firestore documents per evaluation, each read is billed (VS-11), and the use of the verified-email claim in Storage rules was NOT VERIFIED (VS-12). The provider's download links are described as non-expiring (VS-10). C hits function time and egress limits at this file size. |
| Cost and operational implications | One function call per download, well inside the allowance (VS-01). The bytes travel from storage to the reader, not through the function. |
| Security and privacy implications | Storage rules deny every client read of the private path. The function reads the sign-in account's verified-email state and the app profile before it signs. The URL is a bearer link for its lifetime, so the lifetime is short. A default of 60 minutes is proposed as a configuration value for M3 testing (ASSUMPTION), and a resumed download asks for a fresh URL. Requests are logged without personal data. |
| Vendor lock-in and migration | Low. Signed URLs are a general object-store feature. |
| Recommendation | A, following GS-Q7. |
| Evidence and requirement traceability | NFR-SEC-002, NFR-SEC-003, FR-READ-001, FR-DL-001, FR-DL-002, FR-DL-006, BR-002, INT-FILE-001 (CONFIRMED); BR-003 (PROVISIONAL); BR-005 (ASSUMPTION); AC-3, AC-4; CH R2, R4 |
| Conditions for approval | The TD-09 proof plan below passes: resumed download on a signed URL for a 150 MB file on a real Android device and a real iPhone, with the expiry, refresh, authorisation and log checks (AR-01, AOQ-07). MFW grants the signing role through role-based access (NFR-SEC-012). The profile gate is a configuration flag until BR-003 is confirmed. MFW confirms in writing what the app's sign-in gate is for, given that the same PDFs may be public on its website (AOQ-18). |
| Review triggers | Resume fails on a signed URL. Egress cost grows. A content delivery network is added (CHG-05). |
| Approval needed from | Development team |
| Decide by | Before M3 |

**Proof plan for TD-09 (proposed, not run).** This plan is the condition for approval above. Every step is proposed and every outcome is open. AR-01 and AOQ-07 refer to it as the TD-09 proof plan.

```text
TD-09 proof plan: resumable signed-URL downloads       [proposed plan; nothing has been run; outcome open]
├── Purpose
│   ├── Show whether a 150 MB private PDF downloads, and resumes after a break, through a function-issued
│   │   signed URL. The requirement FR-DL-006 (CONFIRMED) is settled and AC-4 tests it. Only the mechanism
│   │   is open
│   └── Until the plan passes, resumable signed-URL download is a proposed design with an open validation
│       item, not a proven capability
├── Before it can start
│   ├── Even a test project is a cloud project, so the items in Section 7.1 apply first: the billing route
│   │   (TD-03) and the owner and payer (AOQ-15)
│   ├── The test uses a throwaway project and bucket. Its location is chosen for the test only and does not
│   │   decide TD-22 (VS-21, VS-23). The location used is recorded with the results
│   ├── Whether a test project may be created before TD-22 is settled is open, because Section 7.1 is
│   │   written for any cloud resource
│   └── The test file is a fictional PDF of about 150 MB. No real MFW content or reader data is used
├── Equipment
│   ├── A real Android device and a real iPhone, not emulators
│   ├── A way to cut and restore the network, and to switch between Wi-Fi and mobile data
│   └── The candidate download clients for TD-11: a plain HTTP client and, if useful, a package
├── A. Server check, with no device
│   ├── A1 A signed URL answers a Range request from the middle of the file with a partial response and a
│   │   matching content range
│   ├── A2 A second, newly issued URL for the same revision continues the same object, because a revision
│   │   path is never overwritten
│   └── A3 A request with no signature, a changed signature, or an expired URL is refused
├── B. Device download, on Android and then on the iPhone
│   ├── B1 A full download completes, and the size and checksum match (FR-READ-010 (CONFIRMED))
│   ├── B2 Cut the network at about half-way. The transfer continues from the bytes already held, so the
│   │   byte count after the break is about the missing part and not the whole file
│   ├── B3 Switch from Wi-Fi to mobile data during a download and check the same
│   ├── B4 Close the app during a download and reopen it. The partial file and its registry row are used
│   └── B5 Each client is compared on B1 to B4, which also answers TD-11
├── C. Expiry and refresh
│   ├── C1 Expiry between a break and the resume. The resume request is refused, the app asks for a new URL
│   │   and continues without starting again
│   ├── C2 Expiry while a request is in flight. Record whether the transfer finishes or is cut. Nothing is
│   │   assumed, and System Architecture §11.1 is written as proposed until this is known
│   ├── C3 Sign-in token expiry during a long download. The function accepts the refreshed token
│   ├── C4 A disabled or pending-deletion account is refused when the app asks for a new URL
│   └── C5 Use short lifetimes for C1 and C2, then choose the production lifetime from slow-network runs.
│       The 60 minute default is an ASSUMPTION (AOQ-07)
├── D. Authorisation
│   ├── D1 getIssueFile refuses on each of the six checks in System Architecture §7.4: signed out, closed
│   │   account, unverified email, incomplete profile when the gate is on (BR-003 (PROVISIONAL)),
│   │   unpublished issue, and no current file
│   ├── D2 A new URL cannot be obtained for an unpublished or unauthorised issue
│   ├── D3 A direct read of the private path with no URL is refused, for signed-out and signed-in clients
│   ├── D4 D1 to D3 are automated against the emulators where possible, then repeated once on the test
│   │   project, because how closely the emulators reproduce signed URLs was not researched
│   └── D5 Recorded as a known limit and not tested away. A URL issued before an unpublish or a deletion
│       stays valid until it expires (System Architecture §8.4)
├── E. Logs
│   ├── E1 Force a refusal, a timeout and a cancel. Then search the app logs, the crash reports and the
│   │   function logs for the URL and its signature. Expect none (System Architecture §12.1, T12)
│   └── E2 Check the error text of each client, because download libraries often put the full URL in an
│       exception message
├── Result to record
│   ├── Which of A to E passed, with the device, the operating system version, the client, the project
│   │   location and the date
│   ├── A failure is recorded as a failure. A pass is recorded for the tested combinations only
│   └── On a pass, TD-09 can move from proposed to accepted when both developers agree and record it
│       (CH §17.4). Until then it stays proposed
└── If it fails
    ├── Test option B, the Storage SDK under rules. VS-11 and VS-12 are unverified for that option
    └── If B also fails, take the effect on FR-DL-006 and AC-4, and options such as smaller PDFs (AR-09),
        to MFW. Nothing is decided here
```

### TD-10 PDF reader library

| Field | Entry |
|---|---|
| Technology or capability | The Flutter library that renders issue pages, with a page-turn effect and a swipe-and-zoom fallback |
| Decision status | open |
| Evidence label | CONFIRMED process (FR-READ-006) |
| Problem and context | The reader must show the first page within 3 seconds, keep text sharp at 300% zoom, survive twenty page turns and show two pages on tablets and in landscape (NFR-PERF-001, NFR-PERF-002, NFR-REL-001, FR-READ-009). The approach is confirmed at M2 after a test on MFW's PDFs (CH D3). No paid component is used without MFW's written approval (NFR-MAINT-006). |
| Options considered | Candidates only. pdfrx 2.10.0 (MIT licence, built on PDFium, its readme asks for Flutter 3.47 and Dart 3.13 or later). pdfx 2.11.0 (MIT). The Syncfusion PDF viewer (commercial package, VS-42). A page-turn widget over rendered page images (none researched). |
| Evaluation criteria used | EC-1, EC-3, EC-9 |
| Advantages and disadvantages | The two MIT-licensed packages need no licence approval. Syncfusion's licence has a Community option for organisations with less than USD 1,000,000 in yearly revenue and fewer than five developers, and a commercial licence otherwise (VS-42). The summary was not checked against the full licence text, and MFW's eligibility is not known. |
| Cost and operational implications | None for the MIT candidates. A paid licence would be a third-party cost that MFW pays and approves in writing (CHG-03, REG-040). |
| Security and privacy implications | The reader works on a local file in private storage and sends nothing out. |
| Vendor lock-in and migration | Medium. The reader sits behind an interface so a library can be replaced. |
| Recommendation | None yet. Shortlist pdfrx and pdfx for the M2 test. Leave Syncfusion out unless MFW approves its licence terms. |
| Evidence and requirement traceability | FR-READ-003 to FR-READ-007, FR-READ-009 (CONFIRMED); FR-READ-008 (OPEN); NFR-PERF-001, NFR-PERF-002, NFR-REL-001, NFR-MAINT-006 (CONFIRMED); CH D3; REG-033, REG-040; CH R1 |
| Conditions for approval | The M2 reader test on MFW's largest sample PDF meets the targets on the low-cost Android phone and the older iPhone (NFR-COMP-003). |
| Review triggers | The test fails. A candidate's licence or maintenance changes. |
| Approval needed from | MFW authorised approver, at M2 |
| Decide by | M2 |

### TD-11 Client download manager

| Field | Entry |
|---|---|
| Technology or capability | The client component that downloads the issue file with progress, resume and a size check |
| Decision status | open |
| Evidence label | ASSUMPTION |
| Problem and context | A reader sees the size before the download, gets a warning on mobile data, sees progress, and the download resumes after a network break (FR-DL-003 to FR-DL-006). S2 does not say whether a download must continue while the app is in the background (AOQ-12). |
| Options considered | background_downloader 9.6.4 (BSD-3-Clause, Android and iOS, no web). A plain HTTP client with Range handling written by the team. A platform download service through a plugin. |
| Evaluation criteria used | EC-1, EC-2, EC-9 |
| Advantages and disadvantages | A package reduces the code the team must write and test. Its behaviour with signed URLs that expire must be proven. A hand-written client gives full control and more code to maintain. |
| Cost and operational implications | None for the licences listed (VS-42). |
| Security and privacy implications | Files go to the app's private storage (NFR-SEC-004). Signed URLs are never logged or stored beyond use. |
| Vendor lock-in and migration | Low. |
| Recommendation | Decide in the M3 spike. Compare the package with a plain client on a 150 MB file, with airplane-mode toggling, as AC-4 requires. |
| Evidence and requirement traceability | FR-DL-003, FR-DL-004, FR-DL-005, FR-DL-006, FR-DL-007, NFR-SEC-004 (CONFIRMED); AC-4; AR-01 |
| Conditions for approval | The spike passes. MFW answers AOQ-12. |
| Review triggers | The package drops iOS or Android support. |
| Approval needed from | Development team |
| Decide by | Before M3 |

### TD-12 WordPress integration

| Field | Entry |
|---|---|
| Technology or capability | The app reads news from MFW's WordPress REST API, caches it on the device, and merges small per-post control records kept by the backend |
| Decision status | proposed |
| Evidence label | CONFIRMED basis (INT-WP-001) |
| Problem and context | WordPress stays the master source of news (DATA-015). The project does not change the site (INT-WP-002). Requests must be paged and cached so the site is not overloaded (INT-WP-004). Admins can hide a post, mark it breaking and send it as a notification (FR-ADMIN-013 to FR-ADMIN-015). A hidden post is hidden only in the app, because it stays public on the website. On 23 October 2026 the site's public API answered requests, but the host's capacity is still unknown (WEB, REG-042). |
| Options considered | A: the app calls WordPress directly, and functions read WordPress only for the admin post picker and notification triggers. B: a backend cache that fetches posts and serves the app. C: a mirror of all posts in the database. |
| Evaluation criteria used | EC-1, EC-2, EC-5, EC-8 |
| Advantages and disadvantages | A has the fewest parts and duplicates no news. The documentation shows a default of 10 posts and a maximum of 100 per request, headers with the total count and page count, parameters that embed related items and limit the fields returned, and a modified-after filter (VS-41). The weakness is that the app depends on the site being reachable, which the device cache and FR-STATE-005 soften. B is more robust against a slow site and adds a copy of the news and more cost. C conflicts with "news stays in WordPress" and is rejected. Whether a browser admin panel may call the site directly was not researched (cross-origin rules), so the admin panel reads posts through a function. |
| Cost and operational implications | No new service. Function calls for the post picker are few. |
| Security and privacy implications | News is public data read over HTTPS. The app sends no credentials and no personal data to the site. Post content is HTML from MFW's site, and it is rendered with a sanitising renderer. |
| Vendor lock-in and migration | Low. The control record is keyed by the WordPress post identifier. |
| Recommendation | A, following GS-Q8. |
| Evidence and requirement traceability | INT-WP-001 to INT-WP-005, FR-NEWS-001 to FR-NEWS-005, FR-NEWS-007, FR-NEWS-008, DATA-009, DATA-015, FR-ADMIN-013 to FR-ADMIN-015, AC-7, AC-8 (all CONFIRMED); FR-NEWS-006, FR-NEWS-009 (OPEN); REG-042, REG-043; CH R5 |
| Conditions for approval | MFW confirms that the API is reachable and names the news categories (REG-042, REG-043, INT-WP-003). MFW decides OQ-16 and OQ-17. |
| Review triggers | The host throttles or blocks the app (CH R5), which would move the design to option B. |
| Approval needed from | Development team |
| Decide by | Before M2 approval |

### TD-13 Push notifications

| Field | Entry |
|---|---|
| Technology or capability | Firebase Cloud Messaging with one topic per notification category |
| Decision status | proposed |
| Evidence label | CONFIRMED basis (INT-PUSH-001) |
| Problem and context | A notification sent to a category reaches only devices that opted in and chose that category (FR-NOTIF-004). iPhones are reached through Apple's push service (INT-PUSH-001). Whether logged-out visitors may receive notifications is OPEN (OQ-09). |
| Options considered | A: one topic per category, with the device subscribed to the topics the reader chose. B: device tokens stored per user, with sends to the tokens of users who chose a category. C: a mix. |
| Evaluation criteria used | EC-1, EC-2, EC-4 |
| Advantages and disadvantages | A stores no device tokens on the server, which limits personal data. One app instance can follow at most 2,000 topics, and subscription changes are limited to 3,000 a second per project (VS-34), far above this app's need. The trade-off is no per-device delivery record, so the send log records each send and not each recipient. Subscriptions are not migrated when a registration changes (VS-35). The effect of deleting a token on its topic subscriptions was NOT VERIFIED (AOQ-13). B gives per-user control and stores device identifiers that need clean-up. Inactive Android registrations are removed after 270 days (VS-37). |
| Cost and operational implications | Cloud Messaging is listed as no-cost (VS-01). iPhone delivery needs an APNs authentication key from MFW's Apple Developer account (VS-36, INT-PUSH-002). |
| Security and privacy implications | Only admins can send (FR-ADMIN-017), through a function that checks the caller. A signed-in reader's category choices are saved with the user record so they follow a new device. On sign-out and on account deletion the app removes its subscriptions. A send is recorded as pending before it is sent and then marked accepted or failed, and only an admin retries a failed or unknown one (GS-Q27). Whether the push service delivers a repeated send twice is NOT VERIFIED (Section 9.4, item 22). |
| Vendor lock-in and migration | Medium. The category model is ours, and only the delivery call is provider-specific. |
| Recommendation | A, following GS-Q9. |
| Evidence and requirement traceability | FR-NOTIF-001 to FR-NOTIF-006, FR-ADMIN-015 to FR-ADMIN-018, DATA-007, DATA-008, INT-PUSH-001, INT-PUSH-002 (CONFIRMED); FR-NOTIF-007 (OPEN); NFR-REL-003 (CONFIRMED); AC-9; OQ-09, OQ-18, OQ-19 |
| Conditions for approval | A spike shows that unsubscribing works on sign-out and on deletion (AOQ-13). MFW provides the APNs key through its Apple account. |
| Review triggers | MFW wants per-recipient delivery records, audience segments or scheduled sends (excluded, EXC-04). |
| Approval needed from | Development team |
| Decide by | Before M3 |

### TD-14 Admin panel

| Field | Entry |
|---|---|
| Technology or capability | A React web application served from Firebase Hosting |
| Decision status | proposed |
| Evidence label | CONFIRMED in S2 (FR-ADMIN-001), OPEN in the charter (C-05) |
| Problem and context | MFW's editors manage issues, categories, news controls, notifications and, if approved, admin users, without developer help (O5). The admin panel is the product's only web interface (FR-ADMIN-001). |
| Options considered | A: a React web app on Firebase Hosting. B: Flutter Web. C: a low-code admin tool. D: the provider's console alone, which cannot apply business rules. |
| Evaluation criteria used | EC-1, EC-2, EC-6, EC-8, EC-10 |
| Advantages and disadvantages | A matches S2 and shares TypeScript with the server (TD-04). B would give one UI language, and it departs from S2's wording. Hosting's no-cost allowance is 10 GB stored and 360 MB a day transferred, then USD 0.026 per GB and USD 0.15 per GB (VS-01), which is ample for an editor-only site. |
| Cost and operational implications | A custom domain is optional and paid by MFW to the registrar (CHG-14). |
| Security and privacy implications | The panel's role checks are a convenience for the interface only. Every privileged operation is checked again on the backend (TD-15, NFR-SEC-007). No secret is placed in the client bundle. |
| Vendor lock-in and migration | Low. A static single-page app moves to any static host. |
| Recommendation | A, following GS-Q2. The build tool and library versions are configuration and are chosen at implementation time. |
| Evidence and requirement traceability | FR-ADMIN-001 to FR-ADMIN-007, FR-ADMIN-009 to FR-ADMIN-011, FR-ADMIN-013 to FR-ADMIN-019, NFR-SEC-007 (CONFIRMED); FR-ADMIN-008, FR-ADMIN-012, NFR-SEC-011, NFR-COMP-005 (OPEN); S2 Architecture: Admin panel |
| Conditions for approval | The supported browser list is set (OQ-26). |
| Review triggers | The developers prefer one UI language. The editors' needs outgrow a simple panel. |
| Approval needed from | Development team |
| Decide by | Before M3 |

### TD-15 Admin roles and role management

| Field | Entry |
|---|---|
| Technology or capability | Two admin roles, in-panel admin management, backend role checks on every privileged operation, and an audit log of role changes |
| Decision status | accepted by the development team (GS-Q19) |
| Evidence label | CONFLICT (PRC-01) |
| Problem and context | The intended requirement from GS-Q11 is that a Super Admin can grant admin access to existing registered users, change their permissions and revoke access from the panel. A Content Admin manages issues, PDF uploads, metadata, news and content, and notifications, but cannot grant or revoke admin privileges. The last Super Admin cannot be removed or demoted. Sensitive role changes need appropriate authentication. A second factor stays OPEN. This conflicts with FR-ADMIN-004 (one admin role, CONFIRMED), ASM-06, SCP-060 and EXC-07, which excludes editorial roles and an audit log. The second interview fixed the permissions: a Content Admin can replace a PDF and unpublish but cannot delete an issue permanently, which only a Super Admin can do, after the issue is unpublished (GS-Q21, GS-Q22). The audit set is wider than a log of role changes (GS-Q26). The first Super Admin, and any recovery, are created by a controlled two-person step (GS-Q33). |
| Options considered | A: one role, with admin access granted by a developer-run script from MFW's admin list. This is the S2-compatible position. B: the two-role model with in-panel management and an audit log. C: a separate sign-in project for admins. |
| Evaluation criteria used | EC-1, EC-2, EC-4, EC-8 |
| Advantages and disadvantages | B removes the need for a developer when an editor joins or leaves and gives an audit trail. It adds build effort, a second privileged code path and a scope change. A is the smallest build. C is overkill at this scale. |
| Cost and operational implications | About 7 to 11 additional person-days compared with option A. This is a development-team estimate and not evidence. The formal figure comes from the S2 impact assessment, within two working days of MFW's written request [S2 Changes]. The estimate breaks down as: server functions for grant, revoke, role change and user search, 1.5 to 2 days; last-Super-Admin guard, 0.5; audit log write and view, 1 to 1.5; panel screens, 2 to 3; re-authentication and token revocation, 1; backend role checks on every privileged function plus tests, 2 to 3. Option A still needs a one-off step to create the first Super Admin, so the difference is smaller than the full cost of B. The estimate does not include the guard record, the count repair task, the wider audit set (GS-Q26), the deleted-issue record, the bootstrap procedure or the enforcement tests below. It is to be revised, and it is not an approved change order. |
| Security and privacy implications | The server-side role record is the source of truth. No role is copied into the sign-in claims (GS-Q20). Every privileged function, including every privileged read, reads the role record and the account status on each call and fails closed if it cannot, and rules give admins no direct read of admin data. A changed claim would reach a signed-in device only when its token refreshes, which can take up to about an hour (VS-27, VS-28), and that is why no claim is trusted. Ending the target's sessions after the commit signs the person out (VS-28). A guard record that every role change reads and writes in the same transaction stops the last Super Admin being removed, including under concurrent requests (INV-03). AOQ-17 is answered by this design: admin reads go through functions. Whether a read made right after the commit always sees the change is NOT VERIFIED (Section 9.4, item 21). Role changes need a recent sign-in. The ID token carries the time the user authenticated (VS-30), and the documentation names sensitive actions that require a recent sign-in and gives no time window, so the window is a configuration value (AOQ-14, VS-31). The audit log is append-only, written only by functions, and holds identifiers and actions, not extra personal data. It covers the audit set in GS-Q26, and its retention is OPEN (AOQ-04). Super Admin only access to personal-data exports is inferred from the roles you listed (AOQ-05). Multi-factor sign-in needs the Identity Platform upgrade, with rates NOT VERIFIED (VS-32, VS-33, AOQ-03). |
| Vendor lock-in and migration | Medium. The role model is ours. Claims and token revocation are provider-specific. |
| Recommendation | B as the intended requirement, recorded as a proposed change that MFW must approve (PRC-01). Until MFW approves it, the S2-compatible option A stays the contracted position. This follows GS-Q11. |
| Evidence and requirement traceability | FR-ADMIN-002, FR-ADMIN-003, FR-ADMIN-017, NFR-SEC-007 (CONFIRMED); FR-ADMIN-004 (CONFIRMED, conflicts); FR-USER-005, NFR-SEC-011 (OPEN); FR-USER-002, FR-USER-003 (PROVISIONAL); NFR-SEC-006 (ASSUMPTION); DATA-011 (CONFIRMED); EXC-07; CHG-01; REG-056; OQ-20; AOQ-03, AOQ-04, AOQ-05, AOQ-14; GS-Q19 to GS-Q22, GS-Q26, GS-Q33 |
| Conditions for approval | MFW approves PRC-01 in writing through the S2 change process, before any work starts (CHG-01). Both developers agree. AOQ-17 is closed by the function-only admin reads (GS-Q20). The enforcement tests below are accepted as part of the build. The glossary is updated, because it defines one admin role and says "Content administrator" is not a project term. |
| Review triggers | MFW declines the change. MFW wants more roles. A second factor is required. |
| Approval needed from | MFW authorised approver, and Development team |
| Decide by | Before M2 approval |

**Enforcement tests for TD-15 (proposed, not written).** These tests apply only if PRC-01 is approved. They check the rules in Database and Data Model §10.8. Every test is proposed and none exists. The wider set is in [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) §14 (ST-01 to ST-20).

```text
TD-15 enforcement tests                 [proposed; none written; all depend on PRC-01]
├── Where they run
│   ├── Rules tests and function tests on the local emulators, on every change (TD-17)
│   └── The concurrency and token cases once on a test project as well, because how closely the emulators
│       reproduce transaction conflicts and token behaviour was not researched
├── Server-side validation (INV-04, INV-06, INV-07)
│   ├── Each change function refuses: a caller who is not a Super Admin by the record, a stale sign-in, a revoked
│   │   token, an unknown, disabled or pending-deletion target, and an unknown role value
│   └── Force the audit write to fail. The role record, the audit event and the guard record are unchanged
├── Partial updates (INV-04, INV-09)
│   └── Fail the session revocation after the commit. The change stands, a retry follows, and every function
│       refuses the person in the meantime
├── Client edits (INV-05)
│   ├── As a signed-out user, a reader, a Content Admin and a Super Admin, read and write the role, audit and
│   │   guard records and an unlisted collection. Every attempt is refused
│   └── Write extra fields to a bookmark, a favourite and notification preferences. The extra fields are refused
├── Last Super Admin under concurrency (INV-03)
│   ├── Two Super Admins demote each other at once, many times. Exactly one request succeeds each time and the
│   │   count never falls below 1
│   ├── A sole Super Admin demotes themself, revokes themself, deletes their account, and has the account
│   │   disabled. Each is refused, or reported when it happens outside the app
│   ├── A grant and a revoke for the same person at once. One outcome, and one audit event per success
│   ├── The same request sent twice (INV-07). One audit event
│   └── After every run: the guard count equals the number of active Super Admin records, and the number of
│       audit events equals the number of successful changes
├── Old tokens (INV-08)
│   ├── Revoke an admin, then call every privileged function with a token issued before. All refuse
│   ├── Try the direct reads under rules with that token. All are refused, because rules give admins no direct read (GS-Q20)
│   └── Finish an upload after the uploader is revoked. It is rejected or held
└── Result to record
    ├── Pass or fail for each case, with the emulator or project used and the date
    └── A pass on the emulators alone is not a pass for the concurrency cases
```

### TD-16 Logging, monitoring and crash reporting

| Field | Entry |
|---|---|
| Technology or capability | Firebase Crashlytics on, Firebase Analytics collection off until OQ-23 is decided, and function logs for server errors |
| Decision status | proposed |
| Evidence label | CONFLICT (C-07) |
| Problem and context | S2 includes crash reporting and basic usage events (NFR-OBS-001, NFR-OBS-002). The charter omits them (C-07). Usage events must not record which reader opened which issue or page (NFR-PRIV-003, PROVISIONAL). Analytics adds device identifiers and may need consent (OQ-23). The store privacy details must match MFW's policy (NFR-PRIV-002). |
| Options considered | A: Crashlytics on with no user identifier, and Analytics included but with collection off. B: both on from the start. C: Crashlytics only. D: a third-party tool such as Sentry (not researched). |
| Evaluation criteria used | EC-1, EC-4, EC-8 |
| Advantages and disadvantages | A keeps the S2 scope and defers the privacy decision, and the switch is configuration. B collects device identifiers before the consent question is settled. C drops a stated scope item and needs MFW's approval. Crashlytics, Analytics and Cloud Messaging are listed as no-cost with no quota stated (VS-01). The Crashlytics plugin supports Android and iOS (VS-42). |
| Cost and operational implications | No cost is expected. |
| Security and privacy implications | Crash reports carry device and app details and must not carry reader identity. Server logs record security-relevant events such as access grants and errors without personal data. The audit log for role changes is separate (TD-15). |
| Vendor lock-in and migration | Low to medium. |
| Recommendation | A, following GS-Q10. Analytics is switched on only after OQ-23 sets a short list of non-identifying events and the consent design is agreed. |
| Evidence and requirement traceability | NFR-OBS-001, NFR-OBS-002, NFR-PRIV-002 (CONFIRMED); NFR-PRIV-003 (PROVISIONAL); C-07; OQ-23; REG-027; AC-11 |
| Conditions for approval | MFW confirms C-07 and decides OQ-23. |
| Review triggers | MFW wants fuller analytics. A store privacy review asks about device identifiers. |
| Approval needed from | MFW authorised approver, for C-07 and OQ-23 |
| Decide by | Before M3 |

### TD-17 Testing and CI/CD

| Field | Entry |
|---|---|
| Technology or capability | Automated checks on every change, and production deployments made by a developer under MFW's role-based access |
| Decision status | proposed |
| Evidence label | ASSUMPTION |
| Problem and context | S2 requires a test plan with results for every acceptance criterion, a security checklist, and signed builds made from tagged source code (AC-10, AC-11, NFR-SEC-010, NFR-MAINT-003). Two developers share one codebase, and changes reach `main` only through a reviewed integration (CH §17.5, REG-054). Credentials stay with MFW (AC-12, NFR-SEC-012). |
| Options considered | A: a hosted CI service runs analysis, unit and widget tests, and rules and function tests against local emulators. Production deployments are made by a developer. B: full continuous deployment to production through a stored service account key. C: manual checks only. |
| Evaluation criteria used | EC-2, EC-4, EC-6 |
| Advantages and disadvantages | A catches regressions without putting production credentials in a CI system. B would need a long-lived key, which conflicts with credentials held by MFW and raises the custody question in REG-051. C risks regressions between two developers. |
| Cost and operational implications | The CI product and its minutes and limits were NOT VERIFIED. The repository is hosted on GitHub, so its built-in CI is a likely candidate. The local emulator suite was not researched in this pass. |
| Security and privacy implications | No production credential in CI. Test data is fictional. Dependencies are pinned and audited. |
| Vendor lock-in and migration | Low. |
| Recommendation | A. The CI product is open. |
| Evidence and requirement traceability | AC-10, AC-11, AC-12, NFR-REL-002, NFR-SEC-010, NFR-SEC-012, NFR-MAINT-002, NFR-MAINT-003 (CONFIRMED); REG-051, REG-054; CH R6 |
| Conditions for approval | Both developers agree the workflow, and the development workflow document is written. |
| Review triggers | CI cost or limits change. The repository moves to MFW (REG-055). |
| Approval needed from | Development team |
| Decide by | Before M3 |

### TD-18 Environments, deployment and secrets

| Field | Entry |
|---|---|
| Technology or capability | A development project and a production project, plus a throwaway project used once to prove the clean-copy deployment |
| Decision status | proposed |
| Evidence label | ASSUMPTION |
| Problem and context | Two developers share one cloud project (CH R6). MFW owns and pays for the production project (REG-037, REG-038). AC-12 requires a clean copy of the code to deploy the backend into a fresh project. Real reader data must not sit in a development project. |
| Options considered | A: development and production, plus a throwaway project for AC-12. B: development, staging and production. C: production only, with local emulators. |
| Evaluation criteria used | EC-2, EC-3, EC-4 |
| Advantages and disadvantages | A keeps test data fictional and costs little. B adds upkeep for a small team. C risks testing against live data. Each project that uses Cloud Storage or Cloud Functions needs the pay-as-you-go plan (VS-02, VS-03), so each needs billing. Cloud Scheduler is free for three jobs per Google account and costs USD 0.10 per job a month after that (VS-14), and this design needs one job for the purge (TD-19). The count is per account in that source, so the count per billing account was NOT VERIFIED. |
| Cost and operational implications | Who owns and pays for the development project is open (AOQ-15). Third-party costs are paid by MFW directly [S1 Costs outside the fee]. |
| Security and privacy implications | Secrets are never committed. The app's Firebase configuration identifiers are not secrets but are project-specific. No service account key is stored in the repository or in CI. The secret store for server settings was not researched, so it is chosen at implementation time. Developers use role-based access and never shared passwords (NFR-SEC-012). |
| Vendor lock-in and migration | Low. |
| Recommendation | A, following GS-Q12. The throwaway project proves AC-12 by deploying from a clean copy using only the written documentation. |
| Evidence and requirement traceability | AC-12, NFR-MAINT-002, NFR-MAINT-004, NFR-SEC-012 (CONFIRMED); REG-037, REG-038, REG-051; CH R6 |
| Conditions for approval | MFW agrees who owns and pays for the development project (AOQ-15). |
| Review triggers | A staging need appears. MFW wants a separate staging copy for acceptance testing. |
| Approval needed from | MFW authorised approver, for any cost or ownership; Development team |
| Decide by | Before any cloud project is created |

### TD-19 Account deletion, retention and backups

| Field | Entry |
|---|---|
| Technology or capability | A server-side deletion workflow with a grace window and a scheduled purge, plus managed database backups |
| Decision status | accepted by the development team (GS-Q28) |
| Evidence label | CONFIRMED basis (FR-PRIV-003), changed by PRC-02 |
| Problem and context | A reader can delete the account from inside the app, and deleting it removes the reader's data (FR-AUTH-009, FR-PRIV-003, AC-3). Retention periods are MFW's decision (OQ-24, NFR-PRIV-005, DATA-017). The deletion of an edition-update sign-up depends on whether that feature is kept (OQ-31, CONFLICT). |
| Options considered | A: delete everything at once. B: soft delete, then a scheduled purge after a window. C: keep records and strip identifiers. |
| Evaluation criteria used | EC-1, EC-4, EC-8 |
| Advantages and disadvantages | B gives an undo window and a controlled purge, but it keeps personal data for longer than A, which sits uneasily with the wording of FR-PRIV-003 and AC-3. Apple expects deletion to be started inside the app, allows confirmation steps and does not accept deactivation alone. The extracted text of its guideline says scheduled deletion is acceptable only if an immediate option also exists, and that is to be re-checked against the live page (VS-38, AR-02). Google Play expects an in-app path and a web link where a reader can ask for deletion, and allows retention only for security, fraud or regulatory reasons that are disclosed (VS-39, AOQ-06). C conflicts with AC-3. |
| Cost and operational implications | One scheduled job and one purge function. The Admin SDK can disable and delete users, and batch deletion does not trigger deletion functions, so users are deleted one at a time (VS-29). Scheduled database backups allow one daily and one weekly schedule, keep at most 14 weeks, and are billed by storage. Point-in-time recovery keeps seven days and has no no-cost allowance (VS-19, VS-20). The rates were NOT VERIFIED. Deleted storage objects persist for seven days by default (VS-05). |
| Security and privacy implications | At the request, the app asks the reader to confirm (FR-PRIV-004). The server then signs the reader out everywhere, marks the account as pending deletion, removes any edition-update entry at once if that feature exists, and hides the reader from admin lists and exports. The sign-in account is not disabled during the window, so the reader can sign in to undo, and every server operation except the undo and a deletion request is refused. An immediate option skips the window. The app removes its notification subscriptions on the device. After the window, the purge removes the profile, bookmarks, favourites, preferences and the sign-in account. Deleted data can remain in backups until they expire, and the privacy inputs say so. A restore must re-apply deletions, which needs a short-lived list of purged identifiers that outlives the backup retention. Whether such a list is acceptable is a privacy question for MFW (AOQ-02). Whether consent records and audit entries outlive the person is also open (OQ-24, AOQ-04). |
| Vendor lock-in and migration | Low. The workflow is ours. |
| Recommendation | B, following GS-Q13 and GS-Q28, with a configurable window, an undo during the window, and an immediate-delete option. The window length, whether the immediate option stays, and the backup retention are open (AOQ-02). |
| Evidence and requirement traceability | FR-AUTH-009, FR-PRIV-003, AC-3 (CONFIRMED); FR-PRIV-004 (ASSUMPTION); NFR-PRIV-005, DATA-017 (OPEN); OQ-24, OQ-31; REG-025, REG-026; PRC-02; AR-02; AOQ-02, AOQ-04, AOQ-06 |
| Conditions for approval | MFW and its adviser agree the window and the disclosure in the privacy policy. The store rules are re-checked on the live pages. MFW approves PRC-02. |
| Review triggers | A store rejects the flow. MFW prefers immediate deletion. |
| Approval needed from | MFW authorised approver and legal adviser; Development team |
| Decide by | Before M4 |

### TD-20 Offline data and synchronisation

| Field | Entry |
|---|---|
| Technology or capability | The database's on-device cache, with offline reads and queued offline writes |
| Decision status | proposed |
| Evidence label | OPEN (OQ-10) |
| Problem and context | Only downloaded issues and already-loaded articles are confirmed offline (NFR-OFF-001, FR-NEWS-005). Whether the catalogue, bookmarks and favourites work offline, and how offline changes synchronise, is open (OQ-10, FR-BKM-008, NFR-OFF-002). |
| Options considered | A: the cache plus queued writes. B: offline reads only. C: online only apart from the confirmed items. |
| Evaluation criteria used | EC-1, EC-2, EC-4 |
| Advantages and disadvantages | The cache is on by default on Android and Apple platforms, offline writes are held locally and sent when the device reconnects, and the last write wins (VS-18). That gives A almost for free. The cost is extra test cases and a default cache size that was shown only in an Apple sample comment (Android was NOT VERIFIED), so the size is set explicitly. |
| Cost and operational implications | None beyond testing. |
| Security and privacy implications | The cache is app-private. It is cleared on sign-out and on account deletion. |
| Vendor lock-in and migration | Medium. The data layer hides it (NFR-MAINT-005). |
| Recommendation | A, following GS-Q14. Bookmarks need an open issue, so adding one offline suits a downloaded issue. |
| Evidence and requirement traceability | FR-BKM-004 (CONFIRMED); FR-BKM-008, NFR-OFF-002 (OPEN); NFR-OFF-001 (CONFIRMED); FR-STATE-003 (ASSUMPTION); OQ-10 |
| Conditions for approval | MFW approves the answer to OQ-10 (owner: development team with MFW approval). |
| Review triggers | Conflicts across devices cause user-visible problems. |
| Approval needed from | MFW authorised approver, for OQ-10 |
| Decide by | Before M2 approval |

### TD-21 Search and filters

| Field | Entry |
|---|---|
| Technology or capability | Search and filters run on the device over the cached catalogue |
| Decision status | proposed |
| Evidence label | ASSUMPTION (FR-SRCH-007) |
| Problem and context | Users search by title, description and category and filter by category, industry segment, year and edition (FR-SRCH-001 to FR-SRCH-005). Search covers issue metadata only, not the text inside PDFs (FR-SRCH-007). The catalogue holds the latest issue and four to six archive issues at launch (FR-MAG-004). |
| Options considered | A: the app fetches the whole catalogue and filters it on the device. B: server-side queries with database indexes. C: a hosted search service. |
| Evaluation criteria used | EC-2, EC-3 |
| Advantages and disadvantages | A needs no index and no search service, and it works offline. It stops being right if the archive grows to hundreds of issues. B adds index setup. C is unnecessary at this size. |
| Cost and operational implications | One small read of the catalogue per refresh. |
| Security and privacy implications | Logged-out visitors can search public metadata only (FR-SRCH-006, ASSUMPTION). |
| Vendor lock-in and migration | Low. |
| Recommendation | A. |
| Evidence and requirement traceability | FR-SRCH-001 to FR-SRCH-005, FR-MAG-004, AC-1 (CONFIRMED); FR-SRCH-006, FR-SRCH-007 (ASSUMPTION); OQ-13 |
| Conditions for approval | MFW answers OQ-13, which sets the meaning of "industry segment" and "edition". |
| Review triggers | The archive exceeds about one hundred issues. |
| Approval needed from | Development team |
| Decide by | Before M2 approval |

### TD-22 Data location

| Field | Entry |
|---|---|
| Technology or capability | The region of the database, the file bucket and the server functions |
| Decision status | open |
| Evidence label | OPEN (AOQ-01) |
| Problem and context | A database location and a bucket location are chosen when each is created. The Firebase pages say neither can be changed afterwards (VS-21, VS-23). Google Cloud's own page says a bucket can be relocated only if Storage Intelligence is configured (VS-24), so the location is treated as fixed. Mumbai (asia-south1) is listed as a Firestore region and as a Cloud Storage region (VS-21, VS-24). The Firebase page that lists locations for both services did not list Mumbai (VS-22), so Mumbai availability for resources created through Firebase is to be confirmed before anything is created. The Firebase no-cost Storage allowance applies only to buckets in us-central1, us-west1 and us-east1 (VS-01). |
| Options considered | A: everything in Mumbai. B: personal data in Mumbai and the PDF bucket in a US region that has the no-cost allowance. C: everything in a US region. |
| Evaluation criteria used | EC-3, EC-4, EC-7 |
| Advantages and disadvantages | A is close to Indian readers and keeps personal data in India, and a Mumbai bucket pays from the first byte (TD-08). B uses the 100 GB a month no-cost download allowance for the largest cost driver, and PDFs are not personal data, but downloads cross continents. C is the cheapest and is farthest from the readers and from the personal data. The legal position on where personal data is held was not assessed, and no source requires a location. Functions should sit in the same region as the database for latency. |
| Cost and operational implications | See Section 9 and [System Architecture](SYSTEM_ARCHITECTURE.md) §13. |
| Security and privacy implications | Data location is a privacy and legal matter for MFW and its adviser. |
| Vendor lock-in and migration | A wrong choice is expensive to undo, which is why it is decided before any resource is created. |
| Recommendation | None yet. The development team's leaning, which is not a decision, is to keep the database and functions in Mumbai and to decide the PDF bucket after MFW has seen the egress cost scenarios and answered the cost-ceiling question (AOQ-11). |
| Evidence and requirement traceability | AOQ-01; AOQ-11; REG-037; NFR-STOR-003 (ASSUMPTION); CH R2 |
| Conditions for approval | MFW and its adviser confirm there is no constraint on location. MFW has seen the cost scenarios. |
| Review triggers | A legal requirement on data location appears. Pricing changes. |
| Approval needed from | MFW authorised approver, and legal adviser for personal data |
| Decide by | Before any cloud project is created |

## 6. Technology Selection and Provider-Specific Configuration

This document selects technologies. It does not configure them. The values below are left unset on purpose, because they belong to implementation and, in several cases, to MFW's accounts. Nothing here creates a project, a database, a bucket or a credential.

| Capability | Selection decision | Provider-specific configuration, not set here |
|---|---|---|
| Backend platform | TD-03 | Project identifier, billing account, plan, IAM roles, region (TD-22) |
| Database | TD-07 | Database edition, location, indexes, security rules text, backup schedule, point-in-time recovery on or off, offline cache size |
| File storage | TD-08 | Bucket names, location, storage class, soft-delete retention, versioning, cross-origin settings, lifecycle rules |
| PDF delivery | TD-09 | Signing service account and its roles, signed-URL lifetime, App Check enforcement |
| Authentication | TD-06 | Enabled sign-in providers, authorised domains, password policy, email templates, account-linking setting, multi-factor setting, OAuth client identifiers |
| Server logic | TD-04 | Runtime version, region, memory and CPU, maximum instances, secrets |
| Push | TD-13 | APNs key, topic names, notification channels, sender identifiers |
| Admin panel hosting | TD-14 | Site identifiers, custom domain, response headers, caching |
| Monitoring | TD-16 | Crashlytics settings, the Analytics collection flag, data-retention settings |
| CI/CD | TD-17 | Workflow definitions, runner types, CI secrets |

## 7. Decision Timing

Stage names follow the specification. The milestone dates behind them are PROVISIONAL (C-08), so no calendar date is stated here.

### 7.1 Must be resolved before any cloud resource is created

| Item | Why it cannot wait |
|---|---|
| TD-03 route to approval | Creating a project commits MFW to billing and to a location. |
| TD-22 and AOQ-01 data location | A location cannot be changed after creation (VS-21, VS-23). |
| TD-18 and AOQ-15 development project owner and payer | The first project to be created must have a known owner and payer. |
| REG-037 cloud project in MFW's name, with billing on | S2 and S1 make this an MFW input. |

### 7.2 Before M2 approval

TD-12 WordPress integration, TD-15 and PRC-01 admin roles, TD-20 offline behaviour, TD-21 search. OQ-01, OQ-02, OQ-03, OQ-08, OQ-09, OQ-10, OQ-13, OQ-16, OQ-17, OQ-18 and OQ-27 from the specification. AOQ-04, AOQ-05, AOQ-11, AOQ-12, AOQ-16 and AOQ-17.

### 7.3 Before M3

TD-02, TD-04, TD-05, TD-09, TD-11, TD-13, TD-14, TD-16 and TD-17. The spikes in AOQ-07, AOQ-08, AOQ-09, AOQ-10 and AOQ-13. AOQ-03, AOQ-14, AOQ-18, AOQ-19 and AOQ-20. PRC-04. OQ-06, OQ-07, OQ-11, OQ-19, OQ-20, OQ-21, OQ-22, OQ-23 and OQ-30 from the specification. OQ-04 and OQ-05 are answered in the architecture document, which this document proposes for approval.

### 7.4 Before M4

TD-19, AOQ-02 and AOQ-06. OQ-24 and OQ-15 from the specification.

### 7.5 Can be deferred

The CI product, the build tool and library versions, the React framework version, the secret store, backup schedule details once TD-19 is approved, the Analytics event list after OQ-23, and any content delivery network (CHG-05). Deferring these does not change a decision above.

## 8. Decision Summary and Unresolved Items

### 8.1 Decision summary

```text
Technology decisions (22)
├── Accepted (1)
│   └── TD-01 Mobile framework: Flutter
│       └── Blocks implementation: no
├── Accepted by the development team (2), MFW written approval pending
│   ├── TD-15 Admin roles: two roles, in-panel management, function-only admin reads
│   │   └── Blocks implementation: yes for the admin design, until MFW approves PRC-01
│   └── TD-19 Deletion and backups: grace window with undo, immediate option, scheduled purge
│       └── Blocks implementation: no for build, yes before release (AR-02)
├── Open (3)
│   ├── TD-10 Reader library: open
│   │   └── Blocks implementation: yes, until the M2 reader test
│   ├── TD-11 Download manager: open
│   │   └── Blocks implementation: no, a spike before M3
│   └── TD-22 Data location: open
│       └── Blocks implementation: yes
└── Proposed, not approved (16)
    ├── Client (4)
    │   ├── TD-02 State and navigation: Riverpod and go_router
    │   │   └── Blocks implementation: no, but needed before the first screen
    │   ├── TD-12 WordPress: direct read with device cache
    │   │   └── Blocks implementation: no
    │   ├── TD-20 Offline data: database cache with queued writes
    │   │   └── Blocks implementation: no
    │   └── TD-21 Search: on-device
    │       └── Blocks implementation: no
    ├── Backend (6)
    │   ├── TD-03 Backend platform: Firebase
    │   │   └── Blocks implementation: yes, until both developers agree and MFW's billing is in place
    │   ├── TD-04 Server language: TypeScript on Node.js
    │   │   └── Blocks implementation: no
    │   ├── TD-05 API style: hybrid, no public REST API
    │   │   └── Blocks implementation: no
    │   ├── TD-07 Database: Cloud Firestore
    │   │   └── Blocks implementation: yes, until the location is chosen
    │   ├── TD-08 File storage: Cloud Storage for Firebase
    │   │   └── Blocks implementation: yes, until the location is chosen
    │   └── TD-09 PDF delivery: signed URLs from a function
    │       └── Blocks implementation: yes, until the resume spike passes
    ├── Identity and admin (2)
    │   ├── TD-06 Authentication: Firebase Authentication
    │   │   └── Blocks implementation: yes, until AOQ-08 and AOQ-09 are tested and OQ-06 is answered
    │   └── TD-14 Admin panel: React on Firebase Hosting
    │       └── Blocks implementation: no
    └── Operations (4)
        ├── TD-13 Push: topics per category
        │   └── Blocks implementation: no, a spike before M3
        ├── TD-16 Monitoring: Crashlytics on, Analytics off
        │   └── Blocks implementation: no
        ├── TD-17 Testing and CI/CD: automated checks, manual production deploys
        │   └── Blocks implementation: no
        └── TD-18 Environments: development and production, plus a throwaway project
            └── Blocks implementation: yes, until AOQ-15 is answered
```

### 8.2 New architecture open questions (AOQ)

These are questions that the specification does not list. They are new in this set of documents. Owners and stages are proposals.

| ID | Question | Related | Owner | Needed by |
|---|---|---|---|---|
| AOQ-01 | In which region should the database, the file bucket and the functions sit? | TD-22; REG-037 | MFW authorised approver, with legal adviser and development team | Before any cloud project is created |
| AOQ-02 | What are the deletion grace window, whether an immediate-delete option is offered, the backup retention, and whether a short-lived list of purged identifiers may be kept? | TD-19; OQ-24; PRC-02 | MFW authorised approver and legal adviser | Before M4 |
| AOQ-03 | Is a second factor required for admin sign-in, and is the Identity Platform upgrade accepted, given that its rates were NOT VERIFIED? | TD-15; NFR-SEC-011; OQ-20 | MFW authorised approver, with development team | Before M3 |
| AOQ-04 | How long is the admin audit log kept, and what happens to its entries when an admin account is deleted? | TD-15; PRC-01; OQ-24 | MFW authorised approver | Before M2 approval |
| AOQ-05 | Which roles may see the registered-user list and export it? Super Admin only is inferred. | TD-15; FR-USER-002; FR-USER-003; NFR-PRIV-004 | MFW authorised approver | Before M2 approval |
| AOQ-06 | Where does the web link for account-deletion requests live, if the store requires one? | TD-19; VS-39 | MFW authorised approver, with development team | Before M4 |
| AOQ-07 | What signed-URL lifetime works on slow connections, and does resume work with a signed URL on a 150 MB file? Open until the TD-09 proof plan has been run on a real Android device and a real iPhone. | TD-09; TD-11; AR-01 | Development team | Before M3 |
| AOQ-08 | What is the outcome of each account-linking combination, including non-Gmail Google accounts and unverified password accounts? | TD-06; OQ-04; OQ-05 | Development team | Before M3 |
| AOQ-09 | Does Google sign-in set the verified-email state? | TD-06; OQ-04 | Development team | Before M3 |
| AOQ-10 | Is App Check enabled for callable functions, and at what cost and setup? | TD-05; TD-09 | Development team | Before M3 |
| AOQ-11 | What is MFW's monthly cloud cost ceiling, and what volume should the design assume? | TD-03; TD-08; TD-22 | MFW authorised approver | Before M2 approval |
| AOQ-12 | Must a download continue while the app is in the background or the screen is locked? | TD-11; FR-DL-005; FR-DL-006 | MFW authorised approver, with development team | Before M2 approval |
| AOQ-13 | Does the app removing its notification token also end its topic subscriptions, on sign-out and on deletion? | TD-13; TD-19 | Development team | Before M3 |
| AOQ-14 | How recent must a sign-in be before an admin can change roles? | TD-15 | Development team, with MFW approval | Before M3 |
| AOQ-15 | Who owns and pays for the development project? | TD-18; REG-037; REG-038 | MFW authorised approver | Before any cloud project is created |
| AOQ-16 | Is the industry-segment list set up by the developers, or maintained in the admin panel? What do the values mean? | OQ-13; TD-21 | MFW authorised approver, with development team | Before M2 approval |
| AOQ-17 | How are the admin-only reads (unpublished issue metadata, upload jobs, the send log) protected against a revoked admin who still holds an older token? Answered by proposal: admin reads go only through functions that check the role record on each call, and the role claim is dropped (GS-Q20). The answer is accepted by the development team and is pending MFW's approval of PRC-01. | TD-15; TD-07; AR-06; INV-08 | Development team | Before M2 approval |
| AOQ-18 | Are the issue PDFs on MFW's website meant to stay public, and what is the app's sign-in gate for? Only the April-May 2026 PDF was tested. | TD-09; GS-Q32; NFR-SEC-009; AR-19 | MFW authorised approver | Before M3 |
| AOQ-19 | How long is the deleted-issue list kept, given devices that stay offline for a long time? | GS-Q25; OQ-11; OQ-21; OQ-24 | MFW authorised approver, with development team | Before M3 |
| AOQ-20 | Is a cover image for an unpublished issue held privately until the issue is published? | TD-08; GS-D7 | Development team | Before M3 |

### 8.3 Proposed requirement changes (PRC)

A PRC records a position that departs from, or adds to, a requirement or exclusion in the specification. Each needs MFW's written approval through the S2 change process before work starts (CHG-01, CHG-10). Until then the specification's text stands.

| ID | Proposed change | Departs from | Status | Approval route |
|---|---|---|---|---|
| PRC-01 | Two admin roles (Super Admin and Content Admin), in-panel admin management, revocation, an audit log of role changes, and re-authentication for sensitive role changes. About 7 to 11 additional person-days compared with a script-granted single role (development-team estimate). The audit log now covers the wider audit set (GS-Q26), which the estimate does not cover. Team-accepted (GS-Q19). | FR-ADMIN-004 (CONFIRMED), ASM-06, SCP-060, EXC-07 | OPEN | S2 change request (CHG-01) |
| PRC-02 | Account deletion with a grace window, an undo, an immediate option and a scheduled purge, and not an immediate purge only. Team-accepted (GS-Q28). | The wording of FR-PRIV-003 (CONFIRMED) and AC-3 | OPEN | MFW and legal adviser (OQ-24), then change process if wording changes |
| PRC-03 | A working mandatory profile list: full name, email taken from sign-in, mobile number, company, job title, industry segment, country, and age or date of birth. City and areas of interest are optional. Gender is left out. The development team kept this list (GS-Q23). | FR-PROF-002 (PROVISIONAL), which lists name, exact age, gender, occupation and domain of work | ASSUMPTION | MFW's answer to OQ-01, OQ-02 and OQ-07 (CHG-08, CHG-10) |
| PRC-04 | A minimum supported app version and an update-required screen (the update gate), with a compatibility policy for the backend contract. The gate adds to S2 scope, which lists no forced-update screen. Effort is not estimated. Team-accepted (GS-Q29). | Adds to S2 scope | ASSUMPTION | MFW's written agreement through the S2 change process. The compatibility policy alone is an engineering rule of the development team |

### 8.4 Open specification questions this document depends on

OQ-01, OQ-02, OQ-03 (profile). OQ-04, OQ-05, OQ-06 (sign-in). OQ-07 (legal review of age). OQ-08, OQ-11, OQ-21 (reading, offline copies and file replacement). OQ-09 (logged-out capabilities). OQ-10 (offline data). OQ-13 (public metadata and segments). OQ-16, OQ-17 (news). OQ-18, OQ-19 (notifications). OQ-20 (admin accounts). OQ-23 (usage events). OQ-24 (retention). OQ-27 (consent record). OQ-31 (edition-update sign-up). This document does not answer them for MFW. Where it proposes a working position, the position is labelled PROVISIONAL, ASSUMPTION or PRC.

## 9. Vendor Evidence and Research Limitations

### 9.1 How the pages were read

All vendor pages were read on 23 October 2026. A research assistant read most pages with a page-reading tool. That tool returns the first part of a long page as verbatim text and a model-written summary of the rest. The Google Cloud storage pricing page was read in the built-in browser pane, with the region selector set to Mumbai and the figures read by script. The codes in the table show how each page was read.

| Code | Meaning |
|---|---|
| V | Verbatim page text |
| S | Summary of the part of a long page past the verbatim cut-off. Re-check before relying on it. |
| B | Read in the built-in browser pane |
| X | Extracted from a long policy page by the reading tool. Re-check on the live page. |
| R | Relayed in a research report. Re-check before relying on it. |

### 9.2 Vendor sources

| VS | URL | Supports | Read as |
|---|---|---|---|
| VS-01 | https://firebase.google.com/pricing | Plan names, no-cost allowances for Storage, Functions, Hosting, Authentication, Firestore, Cloud Messaging, Crashlytics and Analytics. The page says the Storage allowance applies only to buckets in us-central1, us-west1 and us-east1, and it describes limits as enforced daily in one place and monthly in another. | V |
| VS-02 | https://firebase.google.com/docs/projects/billing/firebase-pricing-plans | Cloud Functions available only on the pay-as-you-go plan. The page also lists Storage quotas under the no-cost plan, which conflicts with VS-03, the newer source. | V |
| VS-03 | https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024 | Cloud Storage requires the pay-as-you-go plan from 3 February 2026 | S |
| VS-04 | https://cloud.google.com/storage/pricing | Mumbai (asia-south1) Standard storage rate, internet egress rates, operation prices | B |
| VS-05 | https://docs.cloud.google.com/storage/docs/soft-delete | Soft delete default retention and cost | V |
| VS-06 | https://docs.cloud.google.com/storage/docs/object-versioning | Versioning behaviour and cost | V |
| VS-07 | https://docs.cloud.google.com/storage/docs/access-control/signed-urls | Signed URL maximum lifetime | V |
| VS-08 | https://docs.cloud.google.com/storage/docs/access-control/signing-urls-with-helpers | Roles needed to sign | V |
| VS-09 | https://docs.cloud.google.com/storage/docs/xml-api/reference-headers | Range header on object downloads | V |
| VS-10 | https://firebase.google.com/docs/storage/admin/start | Non-expiring download URLs from the Admin SDK | S |
| VS-11 | https://firebase.google.com/docs/storage/security/rules-conditions | Storage rules reading Firestore, with limits | V and S |
| VS-12 | https://firebase.google.com/docs/rules/rules-and-auth | Token fields available in rules | S |
| VS-13 | https://firebase.google.com/docs/functions/get-started | Supported runtimes and TypeScript | S |
| VS-14 | https://firebase.google.com/docs/functions/schedule-functions | Cloud Scheduler job allowance and price | S |
| VS-15 | https://firebase.google.com/docs/functions/callable | Callable functions and the caller's sign-in context | S |
| VS-16 | https://firebase.google.com/docs/app-check | App Check for callable functions | S |
| VS-17 | https://firebase.google.com/docs/firestore/quotas | Document size and quota notes | S |
| VS-18 | https://firebase.google.com/docs/firestore/manage-data/enable-offline | Offline cache, queued writes, conflict rule | S |
| VS-19 | https://firebase.google.com/docs/firestore/backups (the same content is at https://docs.cloud.google.com/firestore/docs/backups) | Scheduled backups and retention | V |
| VS-20 | https://firebase.google.com/docs/firestore/pitr | Point-in-time recovery | S |
| VS-21 | https://firebase.google.com/docs/firestore/locations | Firestore locations and that the location cannot change | S |
| VS-22 | https://firebase.google.com/docs/projects/locations | Location choice for Storage and Firestore, and a note on default resources. Mumbai is not listed on this page. | V |
| VS-23 | https://firebase.google.com/docs/storage/locations | Storage bucket location cannot change | S |
| VS-24 | https://docs.cloud.google.com/storage/docs/locations | Cloud Storage regions including Mumbai, and relocation with Storage Intelligence | V |
| VS-25 | https://firebase.google.com/docs/auth/users | Verified emails, trusted providers and automatic linking | S |
| VS-26 | https://firebase.google.com/docs/auth/web/account-linking and https://firebase.google.com/docs/auth/flutter/federated-auth | Manual linking and federated sign-in | S |
| VS-27 | https://firebase.google.com/docs/auth/admin/custom-claims | Claims size and propagation | S |
| VS-28 | https://firebase.google.com/docs/auth/admin/manage-sessions | Token lifetime and revocation | S |
| VS-29 | https://firebase.google.com/docs/auth/admin/manage-users | Listing, disabling and deleting users | S |
| VS-30 | https://firebase.google.com/docs/auth/admin/verify-id-tokens | ID token claims including the authentication time | S |
| VS-31 | https://firebase.google.com/docs/auth/flutter/manage-users | Re-authentication for sensitive actions | S |
| VS-32 | https://firebase.google.com/docs/auth/flutter/multi-factor | SMS multi-factor needs Identity Platform | S |
| VS-33 | https://firebase.google.com/docs/auth/web/totp-mfa | TOTP multi-factor needs Identity Platform | S |
| VS-34 | https://firebase.google.com/docs/cloud-messaging/topic-messaging | Topic limits | V |
| VS-35 | https://firebase.google.com/docs/cloud-messaging/manage-topic-subscriptions (also reached as manage-topics) | Subscribing and unsubscribing | V |
| VS-36 | https://firebase.google.com/docs/cloud-messaging/flutter/client | APNs key before iOS use | V and S |
| VS-37 | https://firebase.google.com/docs/cloud-messaging/manage-tokens | Registration token lifetime | V |
| VS-38 | https://developer.apple.com/support/offering-account-deletion-in-your-app/ and https://developer.apple.com/app-store/review/guidelines/ | Apple's account-deletion rule | X |
| VS-39 | https://support.google.com/googleplay/android-developer/answer/13327111 | Google Play's account-deletion rule | X |
| VS-40 | https://developer.apple.com/app-store/review/guidelines/#login-services | Apple's login-services rule | X |
| VS-41 | https://developer.wordpress.org/rest-api/using-the-rest-api/pagination/ , https://developer.wordpress.org/rest-api/using-the-rest-api/global-parameters/ and https://developer.wordpress.org/rest-api/reference/posts/ | Paging, embed, fields and modified-after parameters | R |
| VS-42 | https://pub.dev/packages/ and each package's licence tab, for pdfrx, pdfx, syncfusion_flutter_pdfviewer, background_downloader, flutter_riverpod, go_router, firebase_auth, cloud_firestore, firebase_messaging and firebase_crashlytics | Versions, licences and platforms. Publish dates are shown as relative times, so exact dates were NOT VERIFIED. | R |
| VS-43 | https://docs.flutter.dev/release/release-notes | Latest stable Flutter release | R |

### 9.3 Vendor figures used in this set of documents

| Figure | Value | Source |
|---|---|---|
| Firebase plans | No-cost (Spark) and pay-as-you-go (Blaze) | VS-01 |
| Cloud Storage no-cost allowance, newer buckets | 5 GB-months stored, 100 GB a month downloaded, 5,000 upload operations and 50,000 download operations a month, only in us-central1, us-west1 and us-east1 | VS-01 |
| Cloud Functions | 2 million invocations a month free, then USD 0.40 per million. 400,000 GB-seconds and 200,000 CPU-seconds free. 5 GB outbound a month free, then USD 0.12 per GB. | VS-01 |
| Firebase Hosting | 10 GB stored free, then USD 0.026 per GB. 360 MB a day transferred free, then USD 0.15 per GB. | VS-01 |
| Authentication | 50,000 monthly active users no-cost in the tier the page lists. Most options are described as no-cost. A per-method figure for email and Google sign-in was NOT VERIFIED. | VS-01, VS-02 |
| Cloud Messaging, Crashlytics, Analytics | No-cost, no quota stated | VS-01 |
| Firestore Standard edition no-cost daily allowance | 1 GiB stored, 50,000 reads, 20,000 writes, 20,000 deletes, and 10 GiB a month of network egress | VS-01 |
| Firestore document size | 1 MiB | VS-17 |
| Firestore scheduled backups | One daily and one weekly schedule per database, retention up to 14 weeks, billed by storage | VS-19 |
| Firestore point-in-time recovery | Seven-day retention, no no-cost allowance | VS-20 |
| Cloud Storage Standard storage, Mumbai | USD 0.000027397 per GiB-hour. About USD 0.02 per GiB-month, derived at 730 hours. | VS-04 |
| Internet egress from Cloud Storage to Asia destinations excluding China | USD 0.12 per GiB for the first 10 TiB a month. The rate to worldwide destinations excluding Asia and Australia is the same for the same tier. | VS-04 |
| Class B operations, single-region Standard | USD 0.0004 per 1,000 | VS-04 |
| Soft delete | Default seven days, adjustable from 7 to 90, charged until it expires | VS-05 |
| V4 signed URL | Maximum lifetime 604,800 seconds (seven days) | VS-07 |
| Cloud Messaging topics | At most 2,000 topics per app instance. Subscription changes up to 3,000 a second per project. | VS-34 |
| Android registration clean-up | Inactive for 270 days | VS-37 |
| Cloud Scheduler | Three jobs per Google account free, then USD 0.10 per job a month | VS-14 |
| Cloud Functions runtimes | Node.js 20 and 22, Python 3.10 to 3.13, TypeScript supported. Node 18 deprecated. | VS-13 |
| ID token lifetime, claims size, user listing | One hour, 1,000 bytes, and 1,000 users per page | VS-27, VS-28, VS-29 |
| WordPress REST paging | Default 10 and maximum 100 posts per request | VS-41 |
| Apple Developer Program and Google Play registration | USD 99 a year and USD 25 once, from S1 Costs outside the fee | S1 (unsigned) |

### 9.4 Not verified

These were looked for and not found on an official page, or the page returned only a title. No decision above relies on them. Each is a condition or a spike where it matters.

1. The Mumbai price per 100,000 Firestore reads and writes.
2. The Cloud Functions compute unit prices on the Google Cloud pages (they returned only titles).
3. Identity Platform and multi-factor rates.
4. Backup and point-in-time recovery rates per GiB.
5. The Cloud Scheduler free-job count per billing account.
6. Whether a V4 signed URL honours the Range header (AR-01).
7. How the Admin SDK signs read URLs, and whether the default Functions service account may sign.
8. Use of the verified-email token field in Storage rules.
9. Whether a provider download token can be revoked.
10. The effect of deleting a registration token on topic subscriptions (AOQ-13).
11. The names of the account-linking settings, the outcome for each combination, and whether Google sign-in sets the verified-email state (AOQ-08, AOQ-09).
12. How soon issued ID tokens stop working after revocation, and a recent-sign-in time window.
13. The Android default offline cache size.
14. The Dart version that goes with Flutter 3.47.0.
15. Prices and limits for PostgreSQL-based or other alternatives, for CI services and for the emulator suite. These were not researched.
16. App Check cost and enforcement setup.
17. The full text of the Syncfusion licence.
18. Apple's and Google's policy pages were extracted by the reading tool and must be re-checked on the live pages (VS-38 to VS-40).
19. Whether bucket relocation applies to a Firebase bucket (VS-23 and VS-24 disagree).
20. How Firestore server transactions behave when two changes touch the same record at once, including retry and contention limits (INV-01, INV-03).
21. How many other documents Firestore security rules may read in one evaluation, what each read costs, and whether rules can see that a token was revoked (AOQ-17). VS-11 covers Storage rules only.
22. Whether the push service delivers a repeated send to the same topic twice (GS-Q27, INV-17).
23. Whether the app stores restrict or review a forced-update screen, or a sign-in wall for content that is public on the web (PRC-04, AR-20).

## 10. Questioning Record and Traceability

### 10.1 Answers recorded in the questioning session (GS)

The session was run on 23 October 2026 with the `/grill-me` skill. The skill's own text delegates to a separate `/grilling` skill that is not installed here, so the session followed the skill's description: one question at a time, down the decision tree. The answers are development-team positions. They are not MFW approvals, and the other developer has not yet agreed them. A second session on the same day (GS-Q17 to GS-Q33) used the same skill. Its text again only said to run a grilling session, so the session followed the user's written brief: one question at a time, with the options, the trade-offs and the effect on cost, scope, security and complexity stated for each.

| Ref | Question | Answer recorded | Used in |
|---|---|---|---|
| GS-Q1 | Backend baseline | Firebase as the proposed baseline, each service not approved | TD-03, TD-06, TD-07, TD-08 |
| GS-Q2 | Server language and admin stack | TypeScript Cloud Functions and a React admin panel | TD-04, TD-14 |
| GS-Q3 | Google accounts and linking | One account per email, trust Google's verified result, link only when verified | TD-06 |
| GS-Q4 | Profile fields | A working list: full name, email, mobile number, company, job title, industry segment, country, age or date of birth mandatory; city and areas of interest optional; gender left out and flagged; name and email prefilled; one shared segment list | PRC-03, [Database and Data Model](DATABASE_AND_DATA_MODEL.md) |
| GS-Q5 | Identity data location | Reference only. No stored email. | TD-06, TD-07 |
| GS-Q6 | Reading and offline copies | One action: opening downloads the file and keeps it. An earlier answer of two actions was replaced at the developer's request. | TD-09, TD-11, OQ-08 |
| GS-Q7 | Private PDF access | Function-issued signed URLs | TD-09 |
| GS-Q8 | WordPress news access | Direct from the app, with per-post controls | TD-12 |
| GS-Q9 | Push targeting | One topic per category | TD-13 |
| GS-Q10 | Crash reporting and usage events | Crashlytics on, Analytics collection off | TD-16 |
| GS-Q11 | Admin accounts and security | In-panel management, two roles, audit log, backend checks, last Super Admin protected, re-authentication, second factor open | TD-15, PRC-01 |
| GS-Q12 | Environments | Development and production, plus a throwaway project | TD-18 |
| GS-Q13 | Deletion and retention | Soft delete, then a scheduled purge | TD-19, PRC-02 |
| GS-Q14 | Offline behaviour | Cache with queued writes | TD-20 |
| GS-Q15 | Cost target | No ceiling known. Scenarios modelled, ceiling left open. | AOQ-11, [System Architecture](SYSTEM_ARCHITECTURE.md) §13 |
| GS-Q16 | Bookmarks when a PDF is replaced | Versioned files. Bookmarks store the issue, the page and the file revision. | [Database and Data Model](DATABASE_AND_DATA_MODEL.md) |
| GS-Q17 | The existing data model | Kept as the baseline and revised in place. Two new documents: the API and Backend Contract and the Security and Access Control | [Database and Data Model](DATABASE_AND_DATA_MODEL.md) |
| GS-Q18 | Vendor dependence of the new documents | A technology-neutral core with a separate Firebase mapping marked PROVISIONAL | [API and Backend Contract](API_AND_BACKEND_CONTRACT.md), [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) |
| GS-Q19 | Admin role model | Two roles, Super Admin and Content Admin. A Content Admin cannot grant or revoke admin rights | TD-15, PRC-01 |
| GS-Q20 | How a revoked admin loses reads | Admin reads only through functions that check the role record on each call. No role claim. Fail closed | TD-15, AOQ-17 |
| GS-Q21 | Replacing and deleting issue PDFs | Admins can replace a PDF and permanently delete an issue, with audit events. OQ-21 stays OPEN for MFW | TD-15, [Database and Data Model](DATABASE_AND_DATA_MODEL.md) |
| GS-Q22 | Who may delete an issue | Only a Super Admin, only after the issue is unpublished, with a typed confirmation and an audit event. A Content Admin may replace a PDF and unpublish | TD-15 |
| GS-Q23 | Mandatory profile fields | The GS-Q4 working list stays the mandatory set, marked ASSUMPTION. Gender is left out and flagged | PRC-03 |
| GS-Q24 | Downloaded copies | Unpublishing leaves copies. Permanent deletion makes the app remove its copy once it learns of the deletion. OQ-11 stays OPEN | [Database and Data Model](DATABASE_AND_DATA_MODEL.md) |
| GS-Q25 | How the app learns of a deletion | A minimal deleted-issue record (identifier and time), compared on the device. Retention OPEN. Identifiers are opaque, server-generated and never reused | AOQ-19, [Database and Data Model](DATABASE_AND_DATA_MODEL.md) |
| GS-Q26 | Audit set | Role changes, issue deletion, PDF replacement, publish and unpublish, reader-list views and exports, and denied privileged attempts by signed-in callers. Routine edits are not recorded. Retention OPEN | TD-15, AOQ-04 |
| GS-Q27 | Notification sends | Recorded as pending first, then marked accepted or failed. A crash leaves it unknown. Only an admin retries. Status means accepted by the push service | TD-13 |
| GS-Q28 | Account deletion | A grace window with undo and an immediate option. The window length is configuration and OPEN. PRC-02 stays OPEN | TD-19, PRC-02 |
| GS-Q29 | Contract changes | Additive by default, a record and an approval for breaking changes, and an update gate (a minimum app version) as a proposed addition to S2 scope | TD-05, PRC-04 |
| GS-Q30 | Labels | A team-accepted decision is labelled accepted by the development team, with the requirement label PROVISIONAL and MFW written approval pending. CONFIRMED is never used for it | Section 1.2 |
| GS-Q31 | Taxonomy | Industry segments from the website's 16 circulation industries, issue categories from the editorial calendar themes, Stamping and Tooling as search topics only, and news categories reused from WordPress. PROVISIONAL | [Database and Data Model](DATABASE_AND_DATA_MODEL.md) Appendix B |
| GS-Q32 | Website and app channels | The website stays public and the app requires authentication. The consequences are documented. The gate controls the app's copy only. MFW to confirm (AOQ-18) | TD-09, [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) |
| GS-Q33 | First Super Admin and recovery | MFW's authorised approver names the person in writing, one developer runs the documented step, the other verifies it, and an audit event holds the written reference. Recovery uses the same procedure | TD-15 |

### 10.2 Defaults applied after confirmation

A member of the development team confirmed these defaults at the end of the session. They were proposed and not asked. GS-D13 to GS-D20 were confirmed at the end of the second session.

| Ref | Default | Used in |
|---|---|---|
| GS-D1 | Riverpod and go_router | TD-02 |
| GS-D2 | No OpenAPI or public REST API. Server contracts are tables. | TD-05 |
| GS-D3 | Search and filters on the device over the cached catalogue | TD-21 |
| GS-D4 | CI runs checks. Production deployments are made by a developer under role-based access. No shared keys. Custody of signing credentials stays OPEN (REG-051). | TD-17 |
| GS-D5 | A consent record with the policy version and a timestamp, stored with the user record (DATA-012, OQ-27) | Data model |
| GS-D6 | The registered-user list and CSV exports are Super Admin only (inferred) | TD-15, AOQ-05 |
| GS-D7 | Cover images are public-read. PDFs are private. | TD-08 |
| GS-D8 | The reader library stays open until the M2 test. No paid library. | TD-10 |
| GS-D9 | Logged-out notifications, sharing and edition-update sign-up are supported by the design. MFW decides (OQ-09). | TD-13 |
| GS-D10 | Fewer than 1,000 monthly active users is an ASSUMPTION from the brief, with no source target | Section 2, AOQ-11 |
| GS-D11 | The deletion window is a configuration value, open under OQ-24 | TD-19, AOQ-02 |
| GS-D12 | Admin audit log retention is open | AOQ-04 |
| GS-D13 | The contract format is Markdown operation records. The neutral contract lists every operation, including direct owner-scoped access, and the Firebase mapping says which are functions | API and Backend Contract |
| GS-D14 | Every write carries a client request identifier, and the server de-duplicates. The audit event identifier is derived from it | API and Backend Contract, INV-07 |
| GS-D15 | Admin lists use cursor paging. The catalogue is fetched whole. WordPress paging follows the site | API and Backend Contract |
| GS-D16 | Neutral error categories, with a reason code, and a gone category for a deleted issue | API and Backend Contract |
| GS-D17 | Rate limits are stated per class of operation. The mechanism is OPEN (AOQ-10) and no number is invented | API and Backend Contract, Security and Access Control |
| GS-D18 | The issue lifecycle has two stored states, unpublished and published, plus the deleted-issue record. There is no draft, review or scheduled publishing (EXC-07) | Database and Data Model §17 |
| GS-D19 | Searching for a reader by email address is not in the audit set. Audit events hold no exported data. Denied entries are best effort | Security and Access Control §8 |
| GS-D20 | The panel learns the caller's role through a function and never authorises from it. The deleted-issue list is readable by anyone (ASSUMPTION) | API and Backend Contract, Database and Data Model §4.22 |

### 10.3 Traceability summary

| TD | Main requirements and open items |
|---|---|
| TD-01 | NFR-COMP-001 (CONFIRMED) |
| TD-02 | NFR-MAINT-005 (ASSUMPTION) |
| TD-03 | C-05; CHG-04; REG-035; NFR-MAINT-002 (CONFIRMED) |
| TD-04 | NFR-SEC-008 (CONFIRMED); FR-ADMIN-006 (CONFIRMED); FR-ADMIN-007 (CONFIRMED) |
| TD-05 | NFR-SEC-002 (CONFIRMED); NFR-SEC-005 (CONFIRMED); NFR-SEC-007 (CONFIRMED); GS-Q29 |
| TD-06 | FR-AUTH-005 (PROVISIONAL); INT-AUTH-001 (CONFIRMED); OQ-04; OQ-05; OQ-06 |
| TD-07 | DATA-001 (CONFIRMED); DATA-005 (CONFIRMED); NFR-MAINT-005 (ASSUMPTION) |
| TD-08 | NFR-SEC-003 (CONFIRMED); NFR-STOR-001 (ASSUMPTION); INT-FILE-001 (CONFIRMED) |
| TD-09 | NFR-SEC-002 (CONFIRMED); FR-DL-006 (CONFIRMED); BR-003 (PROVISIONAL); AOQ-18 |
| TD-10 | FR-READ-006 (CONFIRMED); NFR-PERF-001 (CONFIRMED); NFR-MAINT-006 (CONFIRMED) |
| TD-11 | FR-DL-005 (CONFIRMED); FR-DL-006 (CONFIRMED); AC-4 |
| TD-12 | INT-WP-001 (CONFIRMED); DATA-015 (CONFIRMED); OQ-16; OQ-17 |
| TD-13 | FR-NOTIF-004 (CONFIRMED); INT-PUSH-001 (CONFIRMED); OQ-09 |
| TD-14 | FR-ADMIN-001 (CONFIRMED); NFR-COMP-005 (OPEN) |
| TD-15 | FR-ADMIN-004 (CONFIRMED); EXC-07; PRC-01; OQ-20; AOQ-17; GS-Q19 to GS-Q22; GS-Q26; GS-Q33 |
| TD-16 | NFR-OBS-001 (CONFIRMED); NFR-PRIV-003 (PROVISIONAL); C-07; OQ-23 |
| TD-17 | AC-10; AC-12; NFR-SEC-012 (CONFIRMED); REG-051 |
| TD-18 | AC-12; REG-037; AOQ-15 |
| TD-19 | FR-PRIV-003 (CONFIRMED); PRC-02; OQ-24; OQ-31; GS-Q28 |
| TD-20 | FR-BKM-004 (CONFIRMED); NFR-OFF-002 (OPEN); OQ-10 |
| TD-21 | FR-SRCH-007 (ASSUMPTION); AC-1; OQ-13 |
| TD-22 | AOQ-01; AOQ-11 |

### 10.4 Review-gate items carried into this document

These five issues were checked before drafting. None has been resolved in the earlier documents, so their status is preserved and their dependencies are recorded here and in [System Architecture](SYSTEM_ARCHITECTURE.md) Appendix A.

| # | Issue | Dependency recorded |
|---|---|---|
| 1 | Reading model | The download-before-read rule has S2 support. Temporary versus retained copies is OPEN (OQ-08, REG-029). TD-09, TD-11 and TD-20 follow the working assumption in GS-Q6. |
| 2 | Registration consent | S2 says only that MFW supplies the policy and terms and the developers implement consent and deletion. FR-PRIV-001 is CONFIRMED in the specification on that basis. The mandatory timing and the reference to terms of use at registration are inferences (OQ-27). |
| 3 | Public news | S2 is silent on news for logged-out visitors. The charter says news is public [S3]. FR-NEWS-007 is CONFIRMED in the specification, and its evidence is weaker than that label. TD-12 treats news as public data. |
| 4 | Deletion and edition-update sign-up | FR-PRIV-003 mentions any edition-update sign-up while FR-EMAIL-001 is CONFLICT. TD-19 keeps that deletion conditional on OQ-31. |
| 5 | Privacy-risk mapping | Charter risk R11 covers the policy, consent and deletion only. The profile-field decisions (OQ-01, OQ-02) and the legal review (OQ-07, NFR-PRIV-006) sit with R10 and the register entries REG-022, REG-023 and REG-024. This set of documents maps R10 and R11 to all three. |
