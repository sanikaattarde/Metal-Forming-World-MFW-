# Decision Log: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Decision Log |
| File | `Documentation/DECISION_LOG.md` |
| Phase | 3 — Development Planning and Collaboration (document 28) |
| Version | 0.4 |
| Status | Draft for review. Not approved. |
| Date | 27 October 2026 |
| Approval required | Both developers for this log's structure. Individual entries follow Section 3. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft. 24 entries recorded. No entry is AGREED or APPROVED. |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. DEC-025 to DEC-031 added, with the TD crosswalk. Approver lines that read as a record of agreement reworded. Status notes for reported, unfiled agreement and for S3. No entry is AGREED or APPROVED. |
| 0.3 | 27 October 2026 | Positions from the questioning session of 26 and 27 October 2026 recorded (`TECHNOLOGY_DECISIONS.md` section 10.5, GS-Q35 to GS-Q65). DEC-027 now states one Admin role with in-panel add and remove, and PRC-01 is withdrawn. DEC-029 states immediate deletion only, and PRC-02 is withdrawn. DEC-008 records a reported two-action reading model that conflicts with the earlier record. DEC-031 records a region proposal. DEC-032 and DEC-033 added. Position rows added to DEC-005, DEC-006, DEC-011, DEC-013, DEC-014, DEC-016, DEC-017, DEC-019 and DEC-020. Section 5.3 added. No entry is AGREED or APPROVED. |
| 0.4 | 27 October 2026 | Section 5.4 added: Sanika Attarde's written positions on 14 PROPOSED entries (task MOD20-P1-T01 in `SANIKA_IMPLEMENTATION_ROADMAP.md`). It is one half of the evidence section 3.1 needs. No entry changes status, and no entry is AGREED or APPROVED. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `Documentation/PROJECT_CHARTER.md` (CH) | Exists. Draft v0.1, not approved. |
| `Documentation/REQUIREMENTS_SPECIFICATION.md` (RS) | Exists. Draft v0.1, not approved. |
| `Documentation/MFW_Statement_of_Work.pdf` (S2) | Exists. Issued 17 October 2026. The copy is unsigned. |
| `Documentation/MFW_Commercial_Proposal-2.pdf` (S1) | Exists. Issued 17 October 2026. The copy is unsigned. |
| S3, client emails after S1 and S2 | Not in the repository. Known only through CH. |
| `Documentation/OPEN_QUESTIONS.md` | Exists (draft). Holds the questions behind OPEN entries. |
| `Documentation/RISK_REGISTER.md` | Exists (draft). |
| `Documentation/DEVELOPMENT_WORKFLOW.md`, `TASK_OWNERSHIP_MATRIX.md`, `API_AND_MODULE_CONTRACTS.md`, `CODING_STANDARDS.md`, `DEVELOPMENT_ROADMAP.md`, `CI_CD_AND_QUALITY_GATES.md`, `DEPLOYMENT_PLAN.md`, `TEST_DATA_AND_FIXTURES.md` | Exist (draft). They cite entries in this log. |
| `SYSTEM_ARCHITECTURE.md`, `TECHNOLOGY_DECISIONS.md`, `DATABASE_AND_DATA_MODEL.md`, `API_AND_BACKEND_CONTRACT.md`, `SECURITY_AND_ACCESS_CONTROL.md` | Exist on `main` (drafts, merged by pull request #2, merge commit 6e85734). `TECHNOLOGY_DECISIONS.md` was planned as `TECH_STACK_DECISIONS.md` and `DATABASE_AND_DATA_MODEL.md` as `DATABASE_DESIGN.md`. The document map is in `TASK_OWNERSHIP_MATRIX.md` section 13. |

## 2. Purpose and Scope

CH §17.4 states that the architecture, authentication provider, reader library and data model are decided "in a recorded decision, agreed by both developers", and that a decision which adds third-party cost, changes scope or touches the contract is approved by MFW in writing before it is implemented. Before this file, the repository held no such record.

This log is that record. It holds decisions and proposed decisions. It does not hold:

- Questions. These are in `OPEN_QUESTIONS.md`. An OPEN entry here points to the question that must be answered.
- Risks. These are in `RISK_REGISTER.md`.
- Requirements. These stay in RS.

An entry in this log approves nothing by existing. Its status says what evidence exists.

## 3. Status Model

### 3.1 Decision status

| Status | Meaning | Evidence needed to set it |
|---|---|---|
| OPEN | A decision is needed and no option is agreed. A working position may be stated so planning can continue. | Link to the question or conflict |
| PROPOSED | A specific option is proposed by the development team. | Proposer and date |
| AGREED | Both developers agree. This is enough for an internal decision that adds no third-party cost, scope or contract change. | Link to the approving pull-request review, or a written note from both developers |
| APPROVED | MFW's authorised approver or deputy approved in writing. Email is enough [S2 Responsibilities]. Required whenever CH §17.4 applies. | Filed copy of, or reference to, MFW's written approval, with the approver's name |
| BASELINE | The position stated in the issued S1 or S2. Formal acceptance of S1 and S2 is unverified because the repository copies are unsigned (OQ-28). | S1 or S2 reference |
| SUPERSEDED | Replaced by a later entry | ID of the replacing entry |
| WITHDRAWN | Dropped without replacement | Reason |

### 3.2 Evidence class

Each entry also carries the evidence class used in RS §1.2: CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN or CONFLICT.

### 3.3 Rules

1. No entry is set to AGREED or APPROVED without the evidence in Section 3.1.
2. "Recorded" is the date the entry was written into this file. A decision date is given only when evidence shows it.
3. Entries are never deleted and IDs are never reused. A change to an AGREED or APPROVED decision is a new entry that supersedes the old one.
4. Code that depends on an OPEN or PROPOSED decision is limited to spikes and prototypes (`DEVELOPMENT_WORKFLOW.md` §13, `DEFINITION_OF_DONE.md` §5).
5. This file is a shared, high-risk document. Its primary editor and review rule are in `TASK_OWNERSHIP_MATRIX.md` §8.
6. Where YG reports an agreement between the developers that is not filed, the entry stays PROPOSED and carries this note: "Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed." The note is not evidence under section 3.1. It is replaced by AGREED when the evidence is filed.
7. S3 facts stay PROVISIONAL (RS §1.2) until the S3 emails are filed or MFW confirms in writing. YG's statement about the emails is recorded as a note and does not change the evidence class.

## 4. Decision Process

1. **Raise.** Add an entry with status OPEN or PROPOSED in a documentation pull request.
2. **Assess.** Record the options, consequences, third-party cost, and affected documents and modules.
3. **Agree.** The other developer reviews the pull request. When both developers approve, set AGREED and cite the review.
4. **Approve with MFW where required.** If CH §17.4 applies, the contracting developer (Sanika Attarde, CH §14) sends the decision to MFW's approver. Set APPROVED only when the written reply is filed or referenced.
5. **Propagate.** Update every affected document in the same or a follow-up pull request, and add a `CHANGELOG.md` entry.

## 5. Index

| ID | Title | Status | Evidence class | MFW approval needed |
|---|---|---|---|---|
| DEC-001 | Decision log as the CH §17.4 record | PROPOSED | ASSUMPTION | No |
| DEC-002 | Mobile framework: Flutter, one codebase | BASELINE | CONFIRMED | Already in S2 |
| DEC-003 | Backend platform | OPEN | PROVISIONAL, CONFLICT C-05 | Yes, if it differs from S2 or adds cost |
| DEC-004 | Admin panel technology and hosting | OPEN | PROVISIONAL | Yes, if it differs from S2 or adds cost |
| DEC-005 | PDF reader approach and library | OPEN | CONFIRMED approach, OPEN library | Yes, at M2, and for any paid licence |
| DEC-006 | Sign-in methods | OPEN | CONFIRMED and PROVISIONAL, CONFLICT C-04 | Yes |
| DEC-007 | Access rule for full issues; no guest reading | OPEN (working position mandatory) | CONFIRMED and PROVISIONAL, CONFLICT C-01 | Yes |
| DEC-008 | Reading model: online reading or complete local copy | OPEN | CONFLICT C-03 | Yes |
| DEC-009 | Content protection and protected file access | BASELINE | CONFIRMED | Already in S2 |
| DEC-010 | Branching and integration model | PROPOSED | ASSUMPTION | No |
| DEC-011 | Two workstreams and proposed developer mapping | PROPOSED | ASSUMPTION | No |
| DEC-012 | Repository layout | PROPOSED | ASSUMPTION | No |
| DEC-013 | Flutter state management | PROPOSED | ASSUMPTION | No |
| DEC-014 | Navigation and route guarding | PROPOSED | ASSUMPTION | No |
| DEC-015 | Commit, changelog and version conventions | PROPOSED | ASSUMPTION | No |
| DEC-016 | Commercial baseline | OPEN | CONFLICT | Yes (MFW record) |
| DEC-017 | Schedule baseline | OPEN | CONFLICT C-08 | Yes (MFW record) |
| DEC-018 | Delivery team composition | OPEN | CONFLICT | Yes (MFW record) |
| DEC-019 | Evidence status of the S3 amendments | OPEN | CONFLICT | Yes (MFW record) |
| DEC-020 | Protected issue-file delivery mechanism | OPEN | OPEN | Only if it adds cost |
| DEC-021 | News retrieval path | OPEN | CONFIRMED (S2 Flow 2), OPEN alternative | Only if it adds cost |
| DEC-022 | CI service | PROPOSED | ASSUMPTION | Only if it adds cost to MFW |
| DEC-023 | Environment model | PROPOSED | ASSUMPTION | Yes (cloud cost billed to MFW) |
| DEC-024 | Test data policy | PROPOSED | ASSUMPTION | No |
| DEC-025 | Server-side language and runtime | PROPOSED | ASSUMPTION | No |
| DEC-026 | API style, operation catalogue and error scheme | PROPOSED | ASSUMPTION | No |
| DEC-027 | Admin roles and role management | PROPOSED (one Admin role with in-panel add and remove; PRC-01 withdrawn) | One role CONFIRMED. In-panel add and remove: PROPOSED, not in S2 (OQ-58) | Yes, to confirm in-panel add and remove and the narrow record (OQ-20, OQ-58) |
| DEC-028 | Logging, monitoring and crash reporting | PROPOSED | CONFLICT C-07 | Yes (C-07, OQ-23) |
| DEC-029 | Account deletion, retention and backups | PROPOSED (immediate deletion; PRC-02 withdrawn) | Immediate deletion CONFIRMED (FR-PRIV-003). Retention periods OPEN | Yes, for retention (MFW and its legal adviser, OQ-24) |
| DEC-030 | Search and filters | PROPOSED | ASSUMPTION | No |
| DEC-031 | Data location | OPEN (region proposal recorded) | OPEN (OQ-41) | Yes (MFW and its legal adviser) |
| DEC-032 | Subscriber list and the edition-update sign-up | PROPOSED | CONFLICT C-02 | Yes (MFW's written agreement to drop a feature S1 and S2 list) |
| DEC-033 | Reading and downloading: temporary and kept copies | PROPOSED | CONFLICT C-03 (MFW's answer reported, not filed) | Yes (MFW's written answer, OQ-08) |

### 5.1 Charter open decisions

The charter's open decisions (CH §19.3) are tracked here and in `OPEN_QUESTIONS.md`. The question text stays with the question. This log records the decision when one is made.

| CH decision | Tracked as |
|---|---|
| D1 Approver and deputy | OQ-28 |
| D2 Profile fields and collection | OQ-01, OQ-02, OQ-03 |
| D3 Reader approach and licensing | DEC-005, OQ-36, OQ-14 |
| D4 Architecture, authentication design, data retention | DEC-003, DEC-004, DEC-020, OQ-35, OQ-24 |
| D5 Verified email for Google accounts | DEC-006, OQ-04 |
| D6 GST at the revised fee | DEC-016, OQ-33 |
| D7 Formal record of the S3 amendments | DEC-019, OQ-29 |
| D8 Repository transfer to MFW | OQ-48 |
| D9 Task split between the developers | DEC-011, OQ-38 |

### 5.2 Technology decisions (TD-nn) and these entries

`TECHNOLOGY_DECISIONS.md` holds the options and the reasoning behind a decision. This log holds the decision and its status. No ID is renumbered.

| TD | Topic | Entry here |
|---|---|---|
| TD-01 | Flutter | DEC-002 |
| TD-02 | State management and navigation | DEC-013, DEC-014 |
| TD-03 | Backend platform | DEC-003 |
| TD-04 | Server-side language and runtime | DEC-025 |
| TD-05 | API style and contract format | DEC-026 |
| TD-06 | Authentication | DEC-006 |
| TD-07, TD-08, TD-13 | Database, storage, push | DEC-003 (part) |
| TD-09 | PDF delivery and access | DEC-009, DEC-020 |
| TD-10 | Reader library | DEC-005 |
| TD-11 | Download manager | DEC-020 (part) |
| TD-12 | WordPress | DEC-021 |
| TD-14 | Admin panel | DEC-004 |
| TD-15 | Admin roles and role management | DEC-027 |
| TD-16 | Logging, monitoring, crash reporting | DEC-028 |
| TD-17 | Testing and CI | DEC-022 |
| TD-18 | Environments | DEC-023 |
| TD-19 | Account deletion, retention, backups | DEC-029 |
| TD-20 | Offline data | DEC-008 (part) |
| TD-21 | Search and filters | DEC-030 |
| TD-22 | Data location | DEC-031 |

### 5.3 Positions recorded on 26 and 27 October 2026

A questioning session on those dates, with the same skill as before, recorded the positions below. The full record is in `TECHNOLOGY_DECISIONS.md` section 10.5 (GS-Q35 to GS-Q65). Every position was given by YG. No entry changes status because of it. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. Where a position is about MFW, it is reported by YG and no MFW record is filed.

| Position | Entry | Record |
|---|---|---|
| Sanika agrees verbally and will put it in writing. Not filed | DEC-010 to DEC-015, DEC-025 to DEC-030 | GS-Q38 |
| The workstream split is accepted by YG. Both developers are reported as full time | DEC-011 | GS-Q53 |
| Riverpod and go_router are accepted by YG | DEC-013, DEC-014 | GS-Q58 |
| The TD-06 rule for Google accounts is accepted by YG | DEC-006 | GS-Q41 |
| One Admin role with equal permissions, with in-panel add and remove | DEC-027 | GS-Q44, GS-Q45, GS-Q51 |
| Immediate account deletion | DEC-029 | GS-Q50 |
| Region proposal: everything in Mumbai, after checking that the console offers it | DEC-031 | GS-Q52 |
| Reading model: a temporary copy for Read and a kept copy for Download (reported, not filed) | DEC-008, DEC-033 | GS-Q43 |
| The registered-user list is the one admin CSV, and the edition-update sign-up is dropped | DEC-032 | GS-Q49 |
| Downloads run in the foreground only and resume later | DEC-020 | GS-Q60 |
| The reader opens in the page-turn mode and the reader can switch | DEC-005 | GS-Q55 |
| S3 summary in the Charter is faithful, the approver and deputy are named, and signed or accepted S1 and S2 are held (all reported, none filed) | DEC-019 | GS-Q35 to GS-Q37 |
| No action on the M2 date and no delay notice | DEC-017 | GS-Q64 |

### 5.4 Written positions of Sanika Attarde, 27 October 2026

Sanika Attarde gave these positions in chat on 27 October 2026, one decision at a time, and they are recorded here at their instruction. This section is Sanika Attarde's written note under section 3.1.

**What this section is and is not**

- It replaces the reported, unfiled verbal agreement (GS-Q38) with a filed position by Sanika Attarde.
- Section 3.1 needs a written note from both developers, or an approving pull-request review. This section is one side only. The other side is Yuvraj's approving review of the pull request that carries this section, or Yuvraj's own written note.
- No entry changes status because of it. When both sides are filed, the entry is set to AGREED in a follow-up edit that cites the review (section 4, step 3).
- It does not cover DEC-001, DEC-023, DEC-032, DEC-033 or any OPEN entry. They stay as recorded.
- It records no MFW approval. Where an entry needs MFW, the condition column says what is still outstanding.

| Entry | Subject | Position of Sanika Attarde | Condition or limit |
|---|---|---|---|
| DEC-010 | Branching and integration model | Accepts, as a convention. | No branch protection is turned on. `main` is unprotected on GitHub, so nothing enforces the rule. Pull requests 1, 2 and 3 each reached `main` with no approving review by a person. |
| DEC-011 | Two workstreams | Accepts as recorded: WS-A for Sanika Attarde, WS-B for Yuvraj. | Availability of both developers is still to be filed (OQ-38). |
| DEC-012 | Repository layout | Accepts one repository with `app/`, `backend/` and `admin/`, kept public. | Secrets, reader data and MFW's sample PDFs stay out of Git (DEC-024). S1 passes the code to MFW when the final invoice is paid. Until then the code is publicly visible. |
| DEC-013 | Flutter state management | Accepts Riverpod. | Flutter and Dart versions are pinned at the scaffold (OQ-50). A `DEPENDENCY_REGISTER.md` entry comes before the package. |
| DEC-014 | Navigation and route guarding | Accepts go_router. | Same as DEC-013. |
| DEC-015 | Commit, changelog and version conventions | Accepts. | None. |
| DEC-022 | CI service | Accepts GitHub Actions, conditional on the cost check in task MOD15-P1-T01. | Plan limits and macOS runner cost are NOT VERIFIED. If any cost would fall to MFW, MFW approves it first. |
| DEC-024 | Test data policy | Accepts. | MFW still confirms where its sample PDFs may be kept. |
| DEC-025 | Server-side language and runtime | Accepts TypeScript on Node.js, and confirms Sanika Attarde's own TypeScript skills for the backend and admin panel they own. | Depends on DEC-003. Yuvraj's skills are not recorded here. |
| DEC-026 | API style, operation catalogue and error scheme | Accepts the style, the OP-nn catalogue and the category-plus-reason error scheme. | Four design points stay open: device tokens or topics, one upload call or staged, publish and unpublish as one operation or two, and a single-issue read. They are settled in the backend spike. App Check is OQ-52. Depends on DEC-003. |
| DEC-027 | Admin roles and role management | Accepts as an internal position: one Admin role, with in-panel add and remove. | In-panel add and remove is not built as agreed scope until MFW confirms it in writing (OQ-58). The first admin created by the developers is needed either way. |
| DEC-028 | Logging, monitoring and crash reporting | Accepts as an internal position. | MFW's confirmation of C-07 and its answer to OQ-23 are still needed. |
| DEC-029 | Account deletion, retention and backups | Accepts as an internal position: immediate deletion. | MFW and its legal adviser still decide retention and the purged-identifier list (OQ-24). |
| DEC-030 | Search and filters | Accepts. | MFW answers OQ-13. |

## 6. Entries

### DEC-001 Decision log as the CH §17.4 record

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION (development-team proposal) |
| Context | CH §17.4 requires recorded decisions agreed by both developers. No decision record existed at commit `8941964`. |
| Options considered | (a) This Markdown file in the repository. (b) GitHub issues or discussions. (c) Email only. |
| Proposal and rationale | (a). It is versioned with the code, is reviewed in the same pull requests, and moves with the repository when it is transferred to MFW (S2 AC-12). |
| Approver and evidence | Requires agreement by both developers (evidence as in section 3.1). No MFW approval: process only, with no cost or scope effect. |
| Affects | All project documents |
| Follow-up | Both developers review. At its next revision, CH §17.4 could point to this file. That is a Phase 1 change and is not made here. |

### DEC-002 Mobile framework: Flutter, one codebase

| Field | Detail |
|---|---|
| Status | BASELINE. Recorded 23 October 2026. |
| Evidence class | CONFIRMED: S2 Scope included: Platform; S2 Proposed technical architecture, Components: Mobile app; S1 What MFW receives; CH §19.1; RS NFR-COMP-001 |
| Context | S2 gives the reason: one build serves Android and iOS, which suits the budget and the eight-week plan. |
| Decision | The Android and iOS apps are built from one Flutter codebase. |
| Not decided | Flutter and Dart versions (OQ-50) |
| Affects | `CODING_STANDARDS.md`; app modules MOD-00 to MOD-11 in `API_AND_MODULE_CONTRACTS.md` |
| Follow-up | Pin the toolchain versions and record them in `DEPENDENCY_REGISTER.md`. |

### DEC-003 Backend platform

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | PROVISIONAL (S2 proposal). CONFLICT C-05. |
| Context | S2 "Proposed technical architecture" proposes Firebase Authentication, Cloud Firestore, Cloud Storage for Firebase, Cloud Functions, Firebase Cloud Messaging, and Firebase Crashlytics and Analytics. CH §11 and §17.4 state that the architecture is not approved. S2 M3 ("running on MFW's Firebase project") and S2 AC-12 ("a fresh Firebase project") name Firebase, and S1 Annex A lines 21–25 price Firebase set-up. |
| Options considered (evidence) | Firebase, as proposed in S2. An AWS-based design, which S2 "Why this design" says was considered and judged to need more parts and time with no benefit at launch volumes. |
| Working position | Contracts in `API_AND_MODULE_CONTRACTS.md` are technology-neutral. Firebase appears only in examples labelled PROVISIONAL. No backend code is written as final. |
| Decision | None |
| Approver and evidence | Requires agreement by both developers. Requires approval by MFW if the choice differs from S2, changes the S2 M3 or AC-12 wording, or adds third-party cost (CH §17.4). |
| Affects | `SYSTEM_ARCHITECTURE.md`, `TECHNOLOGY_DECISIONS.md`, `DATABASE_AND_DATA_MODEL.md`; MOD-03, MOD-04, MOD-06, MOD-08, MOD-11, MOD-12, MOD-13; `DEPLOYMENT_PLAN.md`; `BACKUP_AND_RECOVERY.md`; `CI_CD_AND_QUALITY_GATES.md` |
| Follow-up | OQ-35. The M1 "requirements and architecture note" [S2 Milestones] depends on this decision. |

### DEC-004 Admin panel technology and hosting

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | PROVISIONAL (S2 proposal) |
| Context | S2 Components: Admin panel proposes a React web app on Firebase Hosting. The admin panel is the only web interface (RS FR-ADMIN-001). A custom domain is optional, at MFW's cost [S1 Costs outside the fee]. |
| Options considered (evidence) | React on Firebase Hosting (S2). No other option is recorded in the sources. |
| Options to assess (not yet assessed) | Flutter web, which would share Dart models with the app. This is listed for assessment only. |
| Decision | None |
| Approver and evidence | Requires agreement by both developers. Requires approval by MFW if the choice differs from S2 or adds cost. |
| Affects | MOD-12; `CODING_STANDARDS.md` §15; `DEPLOYMENT_PLAN.md` |
| Follow-up | OQ-35 |

### DEC-005 PDF reader approach and library

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | CONFIRMED approach; OPEN library (CH §19.3 D3) |
| Context | S2 "Why this design" describes a native page-turn reader with a plain swipe mode as its fallback. S2 Risks and RS FR-READ-007 state that a swipe-and-zoom reader is always built as the fallback. No paid component is used without MFW's written approval (RS NFR-MAINT-006). S2 M2 requires the result of the reader test on MFW's PDFs, and MFW confirms the reader approach or records an alternative. |
| Options considered | None assessed in the repository. The test needs MFW's sample PDFs (CH §12 inputs). |
| Working position | MOD-07 places the rendering library behind an interface, so the library can change after the M2 test without changing other modules. |
| Position of 27 October 2026 | The reader opens in the page-turn mode, the reader can switch to the plain swipe mode in settings, and the choice is remembered on the device (GS-Q55, OQ-14). The library is still open. The developers have a mid-range Android phone and a current iPhone. They have no low-cost Android phone, no older iPhone and no tablet (GS-Q54, OQ-26). |
| Decision | None |
| Approver and evidence | Requires agreement by both developers after the reader test. Requires approval by MFW at M2 [S2 Milestones], and in writing for any paid licence [S1 Costs outside the fee]. |
| Affects | MOD-07; `DEPENDENCY_REGISTER.md`; WP-02 and WP-05 in `DEVELOPMENT_ROADMAP.md` |
| Follow-up | OQ-36, OQ-14 |

### DEC-006 Sign-in methods

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | Email and password: CONFIRMED (S2 Scope included: Accounts; RS FR-AUTH-001 to FR-AUTH-004). Google Sign-In: PROVISIONAL, CONFLICT C-04 (S1 Annex A line 27 and S2 "Later-phase features" exclude it; CH §8 and §17.3 record it as in scope [S3]). Sign in with Apple: excluded, CONFIRMED (S2; CH §17.3), with risk R9. |
| Working position | Plan and build both email and password, and Google Sign-In (RS FR-AUTH-005), behind the MOD-03 interface. How verification applies to Google accounts (OQ-04) and the rule for an email address used with both methods (OQ-05) stay open. |
| Position of 27 October 2026 | YG accepts the TD-06 rule as the working default: one account per email address, Google's verified-email result is trusted, and Google links to a password account only when that account's email is verified (GS-Q41). It stays PROPOSED. The linking spike (AOQ-08, AOQ-09) and MFW's approval are still needed. |
| Decision | None beyond the S2 baseline for email and password |
| Approver and evidence | MFW's written confirmation of Google Sign-In scope (OQ-29) and written acceptance of risk R9 (OQ-06) |
| Affects | MOD-03, MOD-04; `APP_STORE_RELEASE_CHECKLIST.md`; PAC-01 and PAC-12 in `ACCEPTANCE_CRITERIA.md` |
| Follow-up | OQ-04, OQ-05, OQ-06, OQ-29 |

### DEC-007 Access rule for full issues; no guest reading

| Field | Detail |
|---|---|
| Status | OPEN for client confirmation. The working position is mandatory for all planning and implementation. Recorded 23 October 2026. |
| Evidence class | Sign-in plus verified email for email accounts: CONFIRMED (S2 AC-3; RS BR-002). No guest reading and no public sample: PROVISIONAL, CONFLICT C-01 (S2 Scope included: Accounts, S2 Flow 3 and S1 Annex A line 28 include guest browsing with a public sample; CH §9 and §17.3 remove it [S3]). Complete mandatory profile: PROVISIONAL (RS BR-003). |
| Working position | Opening or downloading a full issue requires a signed-in reader with full access as defined in RS §9.2. There is no guest reading and no public sample issue. Logged-out visitors see public issue metadata and news only. The backend enforces the rule; app screens alone are not enough (CH §18 R4). |
| Decision | None beyond the S2 baseline for sign-in and verification |
| Approver and evidence | MFW's written confirmation (OQ-29) |
| Affects | MOD-01 (route guards), MOD-03, MOD-04, MOD-06, MOD-07, MOD-13; AC-3, PAC-02, PAC-04 |
| Follow-up | OQ-29, OQ-04, OQ-13 |

### DEC-008 Reading model: online reading or complete local copy

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | CONFLICT C-03 |
| Context | S2 Assumptions and S2 Flow 3 say readers download an issue before reading it, and S2 "Scope not included" excludes reading before the full download finishes. RS FR-READ-002 (CONFIRMED) follows S2. CH §8 lists "Online reading". |
| Working position | A full issue opens only from a complete local copy obtained through an authorized download (MOD-06). Page-by-page streaming is not planned. Read opens a temporary complete copy, and Download keeps a copy for offline use (DEC-033). |
| Reported answer (not filed) | Version 0.2 recorded a reported answer from MFW: opening an issue keeps the full copy until the reader deletes it. On 27 October 2026 YG reported a later MFW answer: two actions, a Read that opens a temporary complete copy and a separate Download that keeps it. YG gave no date or channel for it (GS-Q43). The two reports disagree and neither is filed. The status stays OPEN until the written decision is filed (OQ-08). S2 AC-4 (progress, offline reading, resume after a network break, deleting a download frees its space) remains a requirement to test. |
| Decision | None |
| Approver and evidence | MFW's answer to OQ-08 |
| Affects | MOD-06, MOD-07; AC-2, AC-4 |
| Follow-up | OQ-08 |

### DEC-009 Content protection and protected file access

| Field | Detail |
|---|---|
| Status | BASELINE. Recorded 23 October 2026. |
| Evidence class | CONFIRMED: S2 "Scope not included" (login gating and private storage only, no DRM); S2 Components: File storage; S2 AC-3; RS NFR-SEC-002, NFR-SEC-003, NFR-SEC-004, NFR-SEC-009 |
| Decision (baseline) | Issue PDFs are stored privately. Each release of issue-file content is authorized on the server for the requesting reader. No public, permanent or guessable address gives access to an issue file. Downloaded copies are kept in the app's private storage. There is no DRM. |
| Scope of this rule | The rule covers the app's copy of an issue only. The same issues are publicly downloadable from MFW's website (three issue PDFs checked by header on 23 October 2026, observed, not an approved source). Sign-in in the app neither protects nor removes the website copy, and unpublishing in the app does not remove it. MFW has not decided whether the website copies stay public (OQ-57). |
| Constraint proposed for planning | If the chosen storage service can issue long-lived bearer download links (for example, Firebase Storage download URLs that carry a token), such links are not used for issue PDFs. This constraint is PROPOSED and is checked under SEC-CHK-03 in `TESTING_STRATEGY.md`. |
| Affects | MOD-06, MOD-13; `TESTING_STRATEGY.md` §9; PAC-13 |
| Follow-up | DEC-020 and OQ-37 choose the mechanism. |

### DEC-010 Branching and integration model

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION. Based on CH §17.5 (draft). |
| Context | CH §17.5 says `main` is the stable integration branch, work is done on `SA` and `YG`, and changes reach `main` only through a reviewed integration by the other developer. Commit `8941964` reached `main` with no pull request visible in local Git metadata. GitHub branch protection is not verified. |
| Options considered | (a) `SA` and `YG` as pull-request sources, with optional short-lived topic branches. (b) Topic branches only, retiring `SA` and `YG`. (c) Direct commits to `main`, which contradicts CH §17.5. |
| Proposal and rationale | (a), with merge commits. Details and rationale are in `DEVELOPMENT_WORKFLOW.md`. |
| Approver and evidence | Requires agreement by both developers |
| Affects | `DEVELOPMENT_WORKFLOW.md`, `CLAUDE_CODE_WORKING_RULES.md`, `CI_CD_AND_QUALITY_GATES.md` |

### DEC-011 Two workstreams and proposed developer mapping

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION. CH §19.3 D9 is open. |
| Proposal | WS-A Platform and Publishing, and WS-B Reader Experience, as defined in `TASK_OWNERSHIP_MATRIX.md`. Proposed mapping: WS-A to Sanika Attarde (`SA`), WS-B to Yuvraj (`YG`). The mapping can be swapped as a whole without changing module boundaries. |
| Approver and evidence | Requires agreement by both developers. No MFW approval. |
| Position of 27 October 2026 | YG accepts the mapping, and reports that both developers are full time (GS-Q53). Sanika's agreement is reported as verbal, to be put in writing (GS-Q38). It stays PROPOSED until her note or approving PR review is filed. |
| Affects | `TASK_OWNERSHIP_MATRIX.md`, `DEVELOPMENT_ROADMAP.md`, `RISK_REGISTER.md` owners |
| Follow-up | OQ-38 |

### DEC-012 Repository layout

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION |
| Context | Current evidence is one shared GitHub repository. S2 Handover requires the source code for the app, backend and admin panel in a repository owned by MFW. S2 M1 mentions "repositories set up", in the plural. |
| Options considered | One repository with `Documentation/`, `app/`, `backend/` and `admin/`; or separate repositories per component. |
| Proposal and rationale | One repository. It gives one history and one transfer at handover, and cross-module pull requests stay simple. The internal layouts of `backend/` and `admin/` are blocked by DEC-003 and DEC-004. |
| Approver and evidence | Requires agreement by both developers |
| Affects | `CODING_STANDARDS.md` §3, `TASK_OWNERSHIP_MATRIX.md` §6, `CI_CD_AND_QUALITY_GATES.md` |

### DEC-013 Flutter state management

| Field | Detail |
|---|---|
| Status | PROPOSED for discussion. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION |
| Options considered | Riverpod; Bloc or Cubit; Provider with ChangeNotifier |
| Criteria | Logic can be tested without widgets. Fakes can be injected for every interface in `API_AND_MODULE_CONTRACTS.md`. Streams are supported (authentication state, download progress). Each developer's familiarity is not recorded and should be weighed. |
| Proposal and rationale | Riverpod. Provider overrides make it straightforward to inject fakes in tests and to replace backend implementations behind the module interfaces, which supports RS NFR-MAINT-005. |
| Approver and evidence | Requires agreement by both developers. The licence is recorded in `DEPENDENCY_REGISTER.md` before the package is added. |
| Position of 27 October 2026 | YG accepts Riverpod (GS-Q58). Sanika's written agreement is not filed. The Flutter and Dart versions are still to be pinned when the scaffold is created (OQ-50). |
| Affects | `CODING_STANDARDS.md` §5 |

### DEC-014 Navigation and route guarding

| Field | Detail |
|---|---|
| Status | PROPOSED for discussion. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION |
| Options considered | go_router; the Navigator 2.0 API used directly; auto_route |
| Proposal and rationale | go_router. Its declarative route table and redirect hook suit the access gate in DEC-007, and routes addressed by issue or article ID support notification taps (RS FR-NOTIF-005). Shared links that open the app are out of scope (RS FR-SHR-005), so no app-link domain set-up is planned. |
| Approver and evidence | Requires agreement by both developers |
| Position of 27 October 2026 | YG accepts go_router (GS-Q58). Sanika's written agreement is not filed. |
| Affects | MOD-01; `CODING_STANDARDS.md` §5 |

### DEC-015 Commit, changelog and version conventions

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION |
| Proposal | Conventional Commits for commit messages (`DEVELOPMENT_WORKFLOW.md` §11). `CHANGELOG.md` keeps an "Unreleased" section, and version sections appear only once release tags exist. App versions use `MAJOR.MINOR.PATCH+BUILD`, and release tags use `vMAJOR.MINOR.PATCH`. S2 AC-11 requires signed builds made from tagged source code. |
| Approver and evidence | Requires agreement by both developers |
| Affects | `DEVELOPMENT_WORKFLOW.md`, `CHANGELOG.md`, `CI_CD_AND_QUALITY_GATES.md`, `APP_STORE_RELEASE_CHECKLIST.md` |

### DEC-016 Commercial baseline

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | CONFLICT |
| Context | S1 (unsigned): fixed fee ₹85,000; 30% advance ₹25,500; M2 ₹12,750, M3 ₹17,000, M4 ₹17,000, M5 ₹12,750; no GST [S1 Proposal at a glance; Milestone-based payment schedule]. CH §13 and §17.3 [S3]: fee ₹91,000; ₹28,000 received; M2 ₹12,750, M3 ₹17,000, M4 ₹17,000, M5 ₹16,250. Neither S3 nor any invoice or receipt is in the repository. GST at the revised fee is CH §19.3 D6. |
| Working position | None. Phase 3 and Phase 4 documents make no commercial commitment and quote figures only with their source. |
| Position of 27 October 2026 | YG reports that signed or accepted copies of S1 and S2 are held. Nothing is filed (GS-Q35). The status and the figures stay as recorded. |
| Reported by YG | Order of authority: the Charter's fee and payment schedule take precedence over S1 and S2 for the points S3 amends (CH §1). The S3 client emails exist and support the amendments, per YG. They are not in the repository and were not seen by the reviewer. The status stays OPEN and the figures stay PROVISIONAL. |
| Approver and evidence | A signed revised proposal, or MFW's written confirmation, plus a payment record |
| Follow-up | OQ-32, OQ-33 |

### DEC-017 Schedule baseline

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | CONFLICT C-08 |
| Context | S1 and S2: kickoff 16 November 2026, store submission 8 January 2027. CH §12 [S3]: start 21 October 2026; M2 4 November, M3 18 November, M4 2 December, M5 16 December 2026. Six weeks is an internal target, not a commitment (CH §12). |
| Working position | `DEVELOPMENT_ROADMAP.md` plans in weeks relative to the project start, using the S2 two-week milestone cadence, and shows the CH dates as PROVISIONAL. Following YG's order of authority (the Charter's dates take precedence over S1 and S2 for the points S3 amends), the CH dates are the working baseline for planning. They stay PROVISIONAL and the conflict stays open. YG states that the S3 client emails exist and support these amendments. They are not in the repository and were not seen by the reviewer. |
| Position of 27 October 2026 | YG decided to take no action on the M2 date and to send MFW no delay notice. On the CH dates, the brand assets were due on 21 October 2026 and the sample PDFs, the WordPress details and the cloud project on 28 October 2026, and YG reports that none has arrived (GS-Q35, GS-Q64). S2 says the developer tells MFW in writing as soon as a delay is expected, and moves later dates by one working day for each working day a key input is late. The decision is recorded as an accepted risk under R7 and R15. No date is changed here. |
| Follow-up | OQ-29 |

### DEC-018 Delivery team composition

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | CONFLICT |
| Context | S2 names one developer and lists "This is a one-person project" among its risks. CH §7, §14 and §17.3 record two developers [S3]. Repository evidence shows commits by two authors: `3e642e0` (sanikaattarde) and `8941964` (YuvrajGaykhe). |
| Working position | Two developers |
| Follow-up | OQ-34 |

### DEC-019 Evidence status of the S3 amendments

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | CONFLICT |
| Context | CH §17.1 calls S1, S2 and the S3 amendments "the approved baseline", and CH §19.1 lists the S3 items as confirmed facts. RS §1.2 classifies the same items as PROVISIONAL until the S3 emails are filed. |
| Working position | Phase 3 and Phase 4 documents follow RS: S3 items are PROVISIONAL. |
| Reported by YG | The S3 client emails exist and support the amendments. They are not in the repository and were not seen by the reviewer. The items stay PROVISIONAL until the emails are filed or MFW confirms in writing. |
| Position of 27 October 2026 | YG states that CH section 17.3 is a faithful summary of the S3 emails, that the emails add nothing the table omits, and that MFW named its authorised approver and deputy. YG did not say which person holds which role (GS-Q36, GS-Q37). Nothing is filed, so the items stay PROVISIONAL. A reference (date, sender role, subject) can be filed without the text, because the repository is public. |
| Follow-up | OQ-29. At its next revision, CH should align its wording. That is a Phase 1 change and is not made here. |

### DEC-020 Protected issue-file delivery mechanism

| Field | Detail |
|---|---|
| Status | OPEN. Depends on DEC-003. Recorded 23 October 2026. |
| Evidence class | OPEN |
| Options (technology-neutral) | (a) A download through an authenticated SDK, evaluated against storage access rules. (b) A short-lived download authorization bound to the reader, issued by server logic after an access check (for example, a signed URL with a short expiry). (c) An authenticated streaming endpoint that serves byte ranges. |
| Constraints | DEC-009. Resume after a network break without restarting (RS FR-DL-006, S2 AC-4). Files of up to 150 MB (RS FR-ADMIN-007). A profile-completeness check if BR-003 is confirmed. No CDN at launch (RS ASM-15). |
| Working position | The MOD-06 operation `requestIssueFile` returns an opaque grant with an expiry. The mechanism is chosen in the architecture document, and resume behaviour is proven in the WP-02 spike. |
| Position of 27 October 2026 | Downloads run while the app is open. If the reader leaves, the download pauses and resumes from the bytes held. No background-download plugin is planned for the first release (GS-Q60, OQ-54). |
| Follow-up | OQ-37 |

### DEC-021 News retrieval path

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. |
| Evidence class | CONFIRMED S2 position (S2 Flow 2; S2 Components: News); OPEN alternative |
| Options | (a) The app reads MFW's WordPress REST API directly and applies news controls (hidden, breaking) read from the backend (RS DATA-009), as in S2. (b) A backend proxy or cache in front of WordPress. |
| Working position | (a), per S2. MOD-09 keeps the WordPress client behind an interface so that (b) remains possible. |
| Follow-up | OQ-39; risk R5 |

### DEC-022 CI service

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION |
| Context | The repository is hosted on GitHub. No CI exists (no `.github/` directory, verified 23 October 2026). iOS build checks need macOS runners. |
| Proposal | GitHub Actions, as described in `CI_CD_AND_QUALITY_GATES.md`. Runner minutes, cost and feature availability depend on the account plan and repository visibility, and are not verified. |
| Approver and evidence | Requires agreement by both developers. Requires MFW approval if any cost is billed to MFW. |
| Follow-up | Verify plan limits before adoption. |

### DEC-023 Environment model

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION |
| Context | S2 refers to "MFW's own Firebase project" in the singular. Cloud usage is billed to MFW [S1 Costs outside the fee]. Testing against production data conflicts with the test-data policy (DEC-024). |
| Proposal | Three environments: ENV-LOCAL, ENV-TEST (a separate non-production project in MFW's name) and ENV-PROD, as in `DEPLOYMENT_PLAN.md` §4. |
| Approver and evidence | Requires agreement by both developers, and approval by MFW, because a second project may add cost billed to MFW |
| Follow-up | OQ-40 |

### DEC-024 Test data policy

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. |
| Evidence class | ASSUMPTION |
| Proposal | All test identities and test data are synthetic. MFW's sample PDFs are treated as confidential [S1 Key terms: Confidentiality], are not committed to Git, and are kept only in a location MFW approves. Credentials for test accounts are never committed. Details are in `TEST_DATA_AND_FIXTURES.md`. |
| Approver and evidence | Requires agreement by both developers. MFW confirms where its sample PDFs may be stored. |

### DEC-025 Server-side language and runtime

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. Mirrors TD-04. |
| Evidence class | ASSUMPTION |
| Context | S2 places upload checks, publishing, notification sending and account deletion in server logic and names no language. The design adds file access issuing, admin role management and a scheduled purge. |
| Proposal | TypeScript on Node.js, using a supported release at implementation time. The release is a configuration choice and is not set here. It also matches the admin panel language (TD-14). |
| Approver and evidence | Requires agreement by both developers. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. The developers also confirm their TypeScript skills (TD-04, EC-10). |
| Affects | `TECHNOLOGY_DECISIONS.md` TD-04; `DEPENDENCY_REGISTER.md`; `CODING_STANDARDS.md` |
| Follow-up | Depends on DEC-003. |

### DEC-026 API style, operation catalogue and error scheme

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. Mirrors TD-05. |
| Evidence class | ASSUMPTION |
| Context | Two operation catalogues exist: the 31 technology-neutral operations in `API_AND_MODULE_CONTRACTS.md` section 8 (OP-AREA-nn) and the 42 operations in `API_AND_BACKEND_CONTRACT.md` (OP-nn). They use different names, groupings and error vocabularies. |
| Proposal | Direct database access under rules for per-user data, callable functions for privileged actions, no public REST API (TD-05). One operation catalogue, in `API_AND_BACKEND_CONTRACT.md`, with the OP-nn identifiers as the main ones and the OP-AREA-nn identifiers as aliases. One error scheme: a category plus a reason code, in upper-case names. Open design differences are listed in the catalogue and are not decided here: device tokens or topics, one upload call or staged upload, publish and unpublish as one operation or two, and a single-issue read. |
| Approver and evidence | Requires agreement by both developers. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. No MFW approval: an engineering rule with no cost or scope effect. |
| Affects | `API_AND_BACKEND_CONTRACT.md`; `API_AND_MODULE_CONTRACTS.md` sections 4.2 and 8; `SECURITY_AND_ACCESS_CONTROL.md`; `TESTING_STRATEGY.md` |
| Follow-up | OQ-52 (App Check) |

### DEC-027 Admin roles and role management

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. Revised 27 October 2026. Mirrors TD-15. |
| Evidence class | One Admin role with the same permissions for every admin: CONFIRMED (RS FR-ADMIN-004). In-panel add and remove of admins, and the narrow record of who added or removed whom: PROPOSED. S2 does not list them, and S2 excludes an audit log (EXC-07), so MFW must say whether they are a clarification or a change (OQ-20, OQ-58). |
| Context | S2 excludes editorial roles and an audit log. How admin accounts are created and removed is OQ-20, and deleting or replacing an issue is OQ-21. Both are OPEN for MFW. The two-role model PRC-01 (Super Admin and Content Admin) was proposed on 23 October 2026. |
| Proposal | One Admin role, and every admin has the same permissions (GS-Q44). The developers create the first admin securely at set-up and hand access to MFW. After that any admin can add an admin, by granting the role to a registered reader whose email is verified, and can remove an admin, in the admin panel and without a developer. Removal asks for a confirmation that names the person. The last remaining admin cannot be removed, including when two admins act at once. Add and remove need a recent sign-in. A small record keeps who added or removed whom, and when, and nothing else. The server reads the current role record on each privileged call and refuses if it cannot, so a removed admin is refused on the next call. There is a test for a removed admin. A replacement file is validated before the old one is removed. There are no Super Admin and Content Admin roles. PRC-01 is withdrawn. Its guard record, request identifier, session-ending and first-admin steps carry over to the single role. Its wider audit set, role-specific permissions, Super-Admin-only exports and Super-Admin-only issue deletion do not. |
| Not decided | Whether MFW treats in-panel add and remove, and the narrow record, as a clarification or as a change request (OQ-58). The effort for in-panel add and remove has not been estimated. The 7 to 11 person-day figure in `TECHNOLOGY_DECISIONS.md` was for PRC-01 and does not apply. The window for a recent sign-in (AOQ-14). |
| Approver and evidence | Requires agreement by both developers. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. Requires MFW's written confirmation of in-panel add and remove before it is built as agreed scope (CH §17.4, S2 Changes). |
| Affects | `API_AND_BACKEND_CONTRACT.md`; `SECURITY_AND_ACCESS_CONTROL.md`; `DATABASE_AND_DATA_MODEL.md`; `SYSTEM_ARCHITECTURE.md`; `TESTING_STRATEGY.md`; `ACCEPTANCE_CRITERIA.md` |
| Follow-up | OQ-20, OQ-21, OQ-51, OQ-56, OQ-58 |

### DEC-028 Logging, monitoring and crash reporting

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. Mirrors TD-16. |
| Evidence class | CONFLICT C-07 (S2 includes crash reporting and basic usage events; the Charter omits them) |
| Context | Usage events must not record which reader opened which issue or page (NFR-PRIV-003, PROVISIONAL). Analytics adds device identifiers and may need consent (OQ-23). |
| Proposal | Crash reporting on with no user identifier. Analytics collection off until OQ-23 sets a short list of non-identifying events and the consent design is agreed. Function logs record security events without personal data. |
| Approver and evidence | Requires agreement by both developers. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. Requires MFW's confirmation of C-07 and its answer to OQ-23. |
| Affects | `TECHNOLOGY_DECISIONS.md` TD-16; `TESTING_STRATEGY.md` section 9; `APP_STORE_RELEASE_CHECKLIST.md` |
| Follow-up | OQ-23, OQ-44 |

### DEC-029 Account deletion, retention and backups

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. Revised 27 October 2026. Mirrors TD-19. |
| Evidence class | Immediate deletion: CONFIRMED (RS FR-PRIV-003 and S2 AC-3.7: the account and the reader's data are deleted). Retention periods and records kept after deletion: OPEN (OQ-24). |
| Context | Immediate deletion is the S2 wording. A grace window with undo (PRC-02) was proposed on 23 October 2026 and departs from the wording of FR-PRIV-003. Apple and Google rules on a grace window are not verified. |
| Proposal | Deletion is immediate: the reader confirms, then the account and the reader's data are removed at once, and a step that fails is retried until it finishes (GS-Q50). There is no grace window, no undo, no pending-deletion state and no purge window. PRC-02 is withdrawn. Backups keep deleted data until they expire, and a restore re-applies deletions. That needs a short-lived list of purged identifiers, which is a privacy question for MFW (OQ-24). |
| Approver and evidence | Requires agreement by both developers. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. Requires MFW's decision and its legal adviser's view on retention and on the purged-identifier list (OQ-24). |
| Affects | `DATABASE_AND_DATA_MODEL.md`; `SECURITY_AND_ACCESS_CONTROL.md`; `API_AND_BACKEND_CONTRACT.md`; `BACKUP_AND_RECOVERY.md` section 9; `ACCEPTANCE_CRITERIA.md` |
| Follow-up | OQ-24, OQ-45, OQ-46 |

### DEC-030 Search and filters

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 23 October 2026. Mirrors TD-21. |
| Evidence class | ASSUMPTION (RS FR-SRCH-007) |
| Context | Users search issue metadata (not PDF text) and filter by category, industry segment, year and edition. The catalogue holds the latest issue and four to six archive issues at launch. |
| Proposal | Search and filters run on the device over the cached catalogue. This stops being right if the archive grows to about one hundred issues. |
| Approver and evidence | Requires agreement by both developers. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. MFW answers OQ-13 (the meaning of "industry segment" and "edition"). |
| Affects | `TECHNOLOGY_DECISIONS.md` TD-21; MOD-04 |
| Follow-up | OQ-13 |

### DEC-031 Data location

| Field | Detail |
|---|---|
| Status | OPEN. Recorded 23 October 2026. Mirrors TD-22. |
| Evidence class | OPEN |
| Context | A database location and a bucket location are chosen when each is created and cannot be changed afterwards (TECHNOLOGY_DECISIONS section 9, VS-21 and VS-23). No source requires a location. The legal position on where personal data is held was not assessed. |
| Working position | None. The proposal to put to MFW, which is not a decision, is to keep everything in Mumbai (asia-south1): the database, the functions and the PDF bucket (GS-Q52). A Mumbai bucket has no free download allowance, so egress is billed from the first byte (`CLOUD_INFRASTRUCTURE_AND_COSTS.md` section 10). Whether the Firebase console offers Mumbai for these services is NOT VERIFIED and is checked before anything is created. The earlier leaning was Mumbai for the database and functions, with the bucket decided after MFW saw the cost scenarios. MFW and its legal adviser decide. |
| Approver and evidence | MFW's written decision, with its legal adviser for personal data (OQ-41). Billing in MFW's name, the plan and the region are not approved. |
| Affects | `TECHNOLOGY_DECISIONS.md` TD-22; `DEPLOYMENT_PLAN.md`; `BACKUP_AND_RECOVERY.md` section 6 |
| Follow-up | OQ-41, OQ-53 |

### DEC-032 Subscriber list and the edition-update sign-up

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 27 October 2026. |
| Evidence class | CONFLICT C-02. S1 and S2 include an optional sign-up for edition-update emails and a subscriber list with a CSV export (S2 Scope: Accounts, Scope: Admin panel, AC-8). CH section 8 describes a list of registered users with a CSV export and leaves the sign-up out. |
| Context | AC-8 requires "the subscriber list" to export to CSV. S1 defines "subscription" in Annex A lines 10 and 19 as the optional email-update sign-up. CH section 17.3 does not list the removal of the sign-up as an amendment. |
| Options considered | (a) The registered-user export only, with no edition-update sign-up. (b) Both lists. (c) The edition-update list only, as S2 reads literally. |
| Proposal and rationale | (a) (GS-Q49). One CSV of registered readers with their profile fields meets AC-8 on that reading and gives MFW the visibility that objective O6 asks for. Registration already captures the email address, and MFW can write to its registered readers with its own tools (EXC-14). Any admin can export it (DEC-027). |
| Effect on scope | The sign-up is a feature that S1 and S2 list. Dropping it removes a deliverable, so it needs MFW's written agreement. It is not decided here, and until MFW agrees the requirements keep FR-EMAIL-001, FR-USER-001 and DATA-010 as CONFLICT. |
| Approver and evidence | Requires agreement by both developers. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. Requires MFW's written agreement (OQ-31). |
| Affects | `REQUIREMENTS_SPECIFICATION.md` FR-EMAIL-001 to FR-EMAIL-003, FR-USER-001, DATA-010; `DATABASE_AND_DATA_MODEL.md`; `API_AND_BACKEND_CONTRACT.md` OP-33; `SCREEN_INVENTORY_AND_NAVIGATION.md` SCR-A-23 and SCR-W-10; `ACCEPTANCE_CRITERIA.md` AC-8.9 and PAC-11 |
| Follow-up | OQ-31 |

### DEC-033 Reading and downloading: temporary and kept copies

| Field | Detail |
|---|---|
| Status | PROPOSED. Recorded 27 October 2026. |
| Evidence class | CONFLICT C-03 for the reading model. A full issue is read from a complete downloaded copy: CONFIRMED (FR-READ-002). MFW's answer on keeping the copy is reported by YG, twice, in two different forms, and is not filed (OQ-08). |
| Context | DEC-008 records the reading model. Version 0.2 of this log recorded a reported answer that opening an issue keeps the copy. On 27 October 2026 YG reported a later answer from MFW that there are two actions. YG gave no date or channel (GS-Q43). |
| Proposal | Read downloads the whole file, opens it once it is complete and verified, and removes it when the reader leaves the issue. Download does the same and keeps the copy in app-private storage, listed on the Downloads screen, until the reader deletes it. Both follow the same access checks and the same size, mobile-data and free-space steps. Reading before the download finishes is not provided (EXC-03). Downloads run in the foreground and resume later (DEC-020). For a kept copy: sign-out hides it until the same reader signs in again, account deletion removes it, unpublishing leaves it, and permanent deletion removes it when the app is online and sees the issue on the deleted-issue list. These four rules carry over from GS-Q24 and were not asked again (OQ-11). |
| Not decided | What Read does when the reader leaves while the file is still downloading. Whether a reader who taps Download while a temporary copy is open converts the copy or downloads again. Both are for the reader design (`PDF_READER_AND_OFFLINE_DESIGN.md`). |
| Approver and evidence | Requires agreement by both developers. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. Requires MFW's written answer to OQ-08 and OQ-11. |
| Affects | `PDF_READER_AND_OFFLINE_DESIGN.md`; `DATABASE_AND_DATA_MODEL.md` MA-4 and section 7; `SYSTEM_ARCHITECTURE.md` section 7.5; MOD-06, MOD-07; AC-4 |
| Follow-up | OQ-08, OQ-11 |
