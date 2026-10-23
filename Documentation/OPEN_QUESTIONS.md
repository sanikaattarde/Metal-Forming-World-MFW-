# Open Questions: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Open Questions |
| File | `Documentation/OPEN_QUESTIONS.md` |
| Phase | 4 — Testing, Release and Risk Management (document 40) |
| Version | 0.2 |
| Status | Draft for review. Not approved. **Every question is OPEN. None has been answered.** |
| Date | 23 October 2026 |
| Approval required | Both developers for the register. Each answer needs the evidence listed against it. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Consolidated register. OQ-01 to OQ-31 carried from RS §12.2 with their IDs. CH D1 to D9 mapped. OQ-32 to OQ-50 added. |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. OQ-51 to OQ-57 added (AOQ crosswalk, section 7). OQ-20 and OQ-25 wording restored. Reported statements recorded as notes on OQ-08 and OQ-29. Backup and monitoring questions marked as proposed additions. No question is answered. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `REQUIREMENTS_SPECIFICATION.md` (RS) §12.2, §12.3 | Exists, draft. Original wording of OQ-01 to OQ-31 and conflicts C-01 to C-08. |
| `PROJECT_CHARTER.md` (CH) §19.3 | Exists, draft. Open decisions D1 to D9. |
| `DECISION_LOG.md` | Exists (draft). Decisions waiting on these questions. |
| `RISK_REGISTER.md`, `DEVELOPMENT_ROADMAP.md`, `ACCEPTANCE_CRITERIA.md` | Exist (draft) |

## 2. Purpose, Scope and Status

This is the single, actionable register of unresolved questions about client approvals, commercial terms, architecture, authentication, profile, content, reading and downloads, news, notifications, administration, privacy, platforms, store compliance, environments and backup, and ownership.

**Relationship to the sources.**

- RS §12.2 holds the original full wording of OQ-01 to OQ-31. This register keeps their IDs and meaning, and summarises them.
- CH §19.3 D1 to D9 are mapped in Section 4.
- Once both developers agree, this register becomes the working copy. RS §12.2 and CH §19.3 stay as the original record and could be pointed here at their next revision. That is a Phase 1 change, not made in this task.

## 3. Fields and Priorities

| Field | Meaning |
|---|---|
| Priority | **P1**: blocks work due before M2, or settles a contractual or legal position. **P2**: blocks M3 or M4 work. **P3**: needed for M5, handover, or later. |
| Blocks | Work that cannot be finished until the question is answered: requirement IDs, roadmap tasks, acceptance rows, decisions |
| Decision owner | Who answers. "MFW" means MFW's authorised approver or deputy. |
| Evidence | What must be filed or referenced before the question is closed |
| Status | OPEN, ANSWERED (the evidence is recorded, but the documents are not yet updated), or CLOSED (the affected documents are updated). Conflicts are flagged with their C-nn ID. |

**Closing a question**

1. Record the answer and its evidence here.
2. Create or update the related `DECISION_LOG.md` entry where a decision results.
3. Update every affected document.
4. Set the status to CLOSED.

## 4. Charter Open Decisions Mapped

| CH §19.3 | Topic | Question IDs |
|---|---|---|
| D1 | MFW approver and deputy | OQ-28 |
| D2 | Profile fields and collection | OQ-01, OQ-02, OQ-03 |
| D3 | Reader approach and licensing | OQ-36, OQ-14 |
| D4 | Architecture, authentication design, data retention | OQ-35, OQ-37, OQ-04, OQ-05, OQ-24 |
| D5 | Verified email for Google accounts | OQ-04 |
| D6 | GST at the revised fee | OQ-33 |
| D7 | Formal record of the S3 amendments | OQ-29 |
| D8 | Repository transfer to MFW | OQ-48 |
| D9 | Task split between the developers | OQ-38 |

## 5. Register

### 5.1 Client approvals and evidence

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-28 | Are signed or formally accepted copies of S1 and S2 available? Who are MFW's authorised approver and deputy? | P1 | Every CONFIRMED item's contractual standing; all approvals; M1 | CH D1; DEP-01; DEP-13 | MFW | Signed copies, or written acceptance, plus named people | OPEN |
| OQ-29 | Can the S3 client emails, or MFW's written confirmation, be filed so that PROVISIONAL items can be confirmed? How are the amendments recorded formally? This covers guest reading (C-01), Google Sign-In (C-04), the schedule (C-08), the profile, sharing links and the registered-user export. | P1 | Every PROVISIONAL requirement; DEC-006, DEC-007, DEC-017, DEC-019; T-03.2, T-03.3, T-09.5 | CH D7; RS §12.3; R20 | Development team and MFW | The filed emails (with MFW's consent), or a written confirmation. Reported by YG, not filed: the S3 client emails exist and support the amendments. They are not in the repository and were not seen by the reviewer. The items stay PROVISIONAL until the emails are filed or MFW confirms in writing. | OPEN (CONFLICT C-01, C-04, C-08) |
| OQ-34 | Does MFW accept two-developer delivery, and how is it recorded, given that S2 names one developer and lists a one-person risk? | P1 | DEC-018; the S2 responsibilities wording | CH §17.3; DEP-14 | MFW | A written record, or an amended SOW | OPEN (CONFLICT) |

### 5.2 Commercial

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-32 | Which commercial baseline applies: S1 (₹85,000 fee, ₹25,500 advance, M5 ₹12,750) or CH §13 (₹91,000 fee, ₹28,000 received, M5 ₹16,250)? Note: S1's maintenance figures disagree internally. ₹312.50 an hour for 8 hours is ₹2,500, and S1 lists ₹5,000 for the 8-hour plan (`MAINTENANCE_AND_HANDOVER.md` section 13). No conclusion is drawn here. | P1 | DEC-016; invoices; `MAINTENANCE_AND_HANDOVER.md` §13 | S1; CH §13, §17.3; R13 | MFW and Sanika Attarde | A signed revised proposal or MFW's written confirmation, plus a payment record | OPEN (CONFLICT) |
| OQ-33 | Does S1's nil-GST position apply at the revised fee? | P1 | Invoicing | CH D6 | MFW and Sanika Attarde (with tax advice as needed) | Written confirmation | OPEN |
| OQ-53 | What is MFW's monthly cloud cost ceiling, and what volume should the design assume? | P1 | DEC-003, DEC-031; cost scenarios in `TECHNOLOGY_DECISIONS.md` (TD-03, TD-08, TD-22) | AOQ-11; REG-037 | MFW | Written decision | OPEN |

### 5.3 Architecture and technology

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-35 | Which backend platform, admin technology and data model are approved? Is the S2 Firebase proposal kept? | P1 | DEC-003, DEC-004; WP-01 backend tasks; most of WP-03, WP-06, WP-09; ENV-TEST; CI QG-08 and QG-09; deployment; backup | CH D4; RS C-05; R12 | Both developers; MFW if it differs from S2 or adds cost | AGREED entry, plus MFW's approval of the M1 note | OPEN (CONFLICT C-05) |
| OQ-36 | Which PDF reader library is used, under what licence, and does it meet the AC-2 targets on MFW's PDFs? | P1 | DEC-005; T-02.3, T-05.1 | CH D3; DEP-45; R1 | Both developers; MFW at M2, and for any paid licence | Reader test report; licence record | OPEN |
| OQ-37 | How are protected issue files delivered (authenticated download, short-lived signed authorization, or authenticated byte-range endpoint), with what grant lifetime, and how is resume achieved for files up to 150 MB? | P1 | DEC-020; OP-FILE-01; T-02.4, T-06.1, T-06.3; CFG-06 | DEC-009; RS FR-DL-006, NFR-SEC-002; R4 | Both developers | AGREED entry; spike evidence from T-02.4 | OPEN |
| OQ-50 | Which Flutter and Dart versions are pinned, and on what upgrade policy? | P1 | T-01.1; QG-01, QG-02 behaviour; DEP-35 | DEC-002 | Both developers | AGREED entry; versions recorded in the repository | OPEN |
| OQ-52 | Is App Check enabled for callable functions, and at what cost and setup? Applies only if the backend is Firebase (DEC-003). | P2 | DEC-026; abuse and throttling checks in `TESTING_STRATEGY.md` section 9 | AOQ-10; TD-05; TD-09 | Both developers | AGREED entry; spike evidence | OPEN |

### 5.4 Authentication and profile

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-01 | What is the final mandatory profile field list, with the format and allowed values of each field? Is "prefer not to say" offered? What do "related fields" include? | P1 | RS FR-PROF-002, DATA-004, NFR-PRIV-001; T-03.3; PAC-02 | CH D2 | MFW | Written field list | OPEN |
| OQ-02 | Is exact age stored as a number or as a date of birth, and how does it stay current? | P1 | RS FR-PROF-002, DATA-004; FX-USR-10 | CH D2 | MFW, with the development team | Written decision | OPEN |
| OQ-03 | When does a Google Sign-In reader complete the profile: straight after the first sign-in, or before the first full issue? | P1 | RS FR-PROF-003; PAC-01 | CH D2 | MFW | Written decision | OPEN |
| OQ-04 | Does email verification apply to Google accounts, and if so, how? | P1 | RS FR-AUTH-007, BR-002; `AccessState` for Google accounts; PAC-12 | CH D4, D5; DEC-006 | Development team, with MFW's approval | AGREED and approved entry | OPEN |
| OQ-05 | What happens when an address already registered with email and password is used for Google Sign-In, or the reverse? | P1 | RS FR-AUTH-006; PAC-12; FX-USR-11 | CH D4, D5 | Development team, with MFW's approval | AGREED and approved entry | OPEN |
| OQ-06 | Does MFW confirm in writing that it accepts the guideline 4.8 risk of offering Google Sign-In without Sign in with Apple? | P2 | RS FR-AUTH-005; IOS-12 | CH R9; R9 | MFW | Written acceptance | OPEN |
| OQ-07 | Does MFW's legal adviser confirm the approach to collecting exact age with no age gate or parental-consent flow? | P1 | RS FR-PROF-005, NFR-PRIV-006; COM-09; AND-12; IOS-14 | CH R10; R10 | MFW and its legal adviser | Written legal confirmation | OPEN |

### 5.5 Catalogue, content and sharing

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-13 | What is the complete list of public issue metadata, including whether file size and page count show before sign-in? What do "industry segment" and "edition" mean for filtering? | P1 | RS FR-MAG-009, FR-SRCH-003, FR-SRCH-005, DATA-001; T-04.1, T-04.2; PAC-07 | — | MFW | Written decision | OPEN |
| OQ-15 | Which store link is shared for an issue (one for both stores, or one per platform), and what is shared before the listings are live? | P2 | RS FR-SHR-002; PAC-05; CFG-08 | — | MFW, with the development team | Written decision | OPEN |
| OQ-57 | Are the issue PDFs on MFW's website meant to stay publicly downloadable? If so, what is the sign-in requirement in the app meant to achieve? If not, who changes the website, given that the project does not change WordPress (S2 "Scope not included")? Observed 23 October 2026: three issue PDFs were downloadable without sign-in (checked by header only; the other issues were not opened). | P1 | Wording of the M1 requirements and architecture note; DEC-009 and R4 wording; what MFW expects the sign-in to protect. It blocks no design work | NFR-SEC-009; DEC-007; DEC-009; R4; AOQ-18; AR-19; AR-20 | MFW's authorised approver (not yet named, OQ-28) | MFW's written answer | OPEN |

### 5.6 Reading and downloads

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-08 | Does opening a full issue always keep it as an offline copy, or is there a temporary copy for reading and a separate action to keep it offline? | P1 | RS FR-READ-002, FR-DL-001, FR-DL-008; DEC-008; T-06.5 | RS C-03 | MFW, with the development team | Written decision. Reported by YG, not filed: opening an issue keeps the full copy until the reader deletes it. Source, date and wording are not in the repository. Working position: a full issue opens only from a complete local copy (DEC-008). The status stays OPEN until the written decision is filed. | OPEN (CONFLICT C-03) |
| OQ-10 | Are catalogue metadata, bookmarks and favourites available offline? Can bookmarks and favourites be changed offline and synchronised later? | P1 | RS FR-BKM-008, NFR-OFF-002; DEP-55 | — | Development team, with MFW's approval | AGREED and approved entry | OPEN |
| OQ-11 | What happens to downloaded issues when the reader signs out, deletes the account, or the issue is unpublished? | P2 | RS FR-DL-010, DATA-013; PAC-14; T-06.5 | — | MFW | Written decision | OPEN |
| OQ-12 | Can a signed-in reader without full access use favourites? | P1 | RS FR-BKM-003; OP-LIB-05 | — | MFW | Written decision | OPEN |
| OQ-14 | Can the reader switch between page-turn and swipe modes, and which is the default? | P1 | RS FR-READ-008; T-05.2 | CH D3 | Development team, with MFW's approval | M2 decision record | OPEN |
| OQ-54 | Must a download continue while the app is in the background or the screen is locked? | P1 | RS FR-DL-005, FR-DL-006; TD-11; DEC-020 | AOQ-12 | MFW, with the development team | Written decision | OPEN |

### 5.7 News and WordPress

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-16 | Are news articles kept offline by an explicit save action or automatically? How many are kept? How is embedded media shown? | P1 | RS FR-NEWS-005, FR-NEWS-006; T-08.3 | — | MFW, with the development team | Written decision | OPEN |
| OQ-17 | How is a post marked as breaking shown in the app? | P1 | RS FR-NEWS-009, FR-ADMIN-014; T-08.4 | — | MFW | Written decision | OPEN |
| OQ-39 | What is MFW's WordPress site address? Is the REST API reachable over HTTPS without being blocked by security plugins or firewalls? Which categories are shown? | P1 | RS INT-WP-001, INT-WP-003; T-08.1; CFG-03, CFG-04 | RS ASM-03; DEP-04; R5 | MFW | Address and categories in writing; a successful read-only test | OPEN |

### 5.8 Notifications

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-09 | Can logged-out visitors receive push notifications and set preferences, share issues and articles, and sign up for edition-update emails? | P1 | RS FR-NOTIF-007, FR-SHR-001, FR-SHR-003, FR-EMAIL-001, DATA-007; OP-NTF-01, OP-EML-01 | — | MFW | Written decision | OPEN |
| OQ-18 | What is the final list of notification categories, and can admins add or change categories? | P1 | RS FR-NOTIF-006; CFG-13; T-10.2 | — | MFW | Written list | OPEN |
| OQ-19 | Which fields does the notification send log record? | P2 | RS FR-ADMIN-018, DATA-008; AC-9.4 | — | Development team, with MFW's approval | AGREED and approved entry | OPEN |
| OQ-55 | Does the app removing its notification token also end its topic subscriptions, on sign-out and on account deletion? | P2 | TD-13; DEC-029; RS FR-NOTIF-006 | AOQ-13 | Both developers | AGREED entry; spike evidence | OPEN |

### 5.9 Administration

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-20 | How are admin accounts created and removed (set up by the developers from MFW's admin list, or managed in the panel), and what does "secure login" include (password rules, two-step verification, session expiry)? Under the one-role baseline the first admin is a named step. A two-role model (Super Admin and Content Admin) with in-panel management is the labelled change PRC-01 (DEC-027), which applies only if MFW approves it. | P2 | RS FR-USER-005, NFR-SEC-011, DATA-011; T-09.1; SEC-CHK-08 | DEP-10 | MFW, with the development team | Written decision | OPEN |
| OQ-21 | Can an admin permanently delete an issue or replace its PDF, and what happens to copies already downloaded? | P2 | RS FR-ADMIN-012; OP-ADM-11; T-09.6 | — | MFW | Written decision | OPEN |
| OQ-22 | What formats, dimensions and maximum size apply to cover images? | P2 | RS FR-ADMIN-008; FX-ADM-02, FX-ADM-03 | — | MFW, with the development team | Written decision | OPEN |
| OQ-30 | Is a PDF of exactly 150 MB accepted, and can admins change the limit? **Added in Phase 4:** does "MB" mean 10⁶ or 2²⁰ bytes, and are password-protected PDFs rejected at upload? | P2 | RS FR-ADMIN-007; AC-8.5; FX-PDF-06, FX-PDF-12; CFG-05 | RS C-06 | MFW, with the development team | Written decision | OPEN (CONFLICT C-06) |
| OQ-31 | Is the optional edition-update email sign-up kept, dropped, or merged into registration? Does the S2 AC-8 "subscriber list" mean the edition-update list or the registered-user list? | P1 | RS FR-EMAIL-001, FR-USER-001, DATA-010; AC-8.9; PAC-11; OP-ADM-10 | RS C-02 | MFW | Written decision | OPEN (CONFLICT C-02) |
| OQ-51 | Which roles may see the registered-reader list and export it? Under the one-role baseline every admin can (RS FR-USER-002, FR-USER-003, PROVISIONAL). "Super Admin only" is inferred under PRC-01. | P1 | RS FR-USER-002, FR-USER-003, NFR-PRIV-004; OP-ADM-08, OP-ADM-09 (OP-31, OP-32) | AOQ-05; DEC-027 | MFW | Written decision | OPEN |
| OQ-56 | How recent must a sign-in be before an admin can change roles? Applies only if PRC-01 is approved. | P2 | DEC-027 (PRC-01 only) | AOQ-14; TD-15 | Both developers, with MFW's approval of PRC-01 | AGREED entry | OPEN (conditional on PRC-01) |

### 5.10 Privacy and data

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-23 | Which basic usage events are recorded, and is consent needed before recording them? | P2 | RS NFR-OBS-002, NFR-PRIV-003, DATA-014; PAC-09; CFG-11 | DEP-29 | MFW, with the development team | Written event list | OPEN |
| OQ-24 | What are the retention periods for accounts, profiles, inactive accounts, send records, consent records, crash data and exports? Is any record kept after account deletion? | P1 | RS NFR-PRIV-005, DATA-017, FR-PRIV-003; PAC-06; `BACKUP_AND_RECOVERY.md` §9 | CH D4 | MFW | Written retention policy | OPEN |
| OQ-27 | How is consent recorded (a checkbox or equivalent action), and are the accepted policy version and date stored? | P1 | RS FR-PRIV-001, DATA-012; PAC-08 | — | MFW | Written decision | OPEN |
| OQ-41 | In which cloud region are the backend data and backups held? | P1 | CFG-02; `BACKUP_AND_RECOVERY.md` §6 | DEC-003 | MFW, with the development team | Written decision | OPEN |

### 5.11 Platforms and accessibility

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-25 | Which accessibility baseline applies? Proposed for decision: app interface text follows the device's text-size setting, controls have screen-reader labels, and text and controls have enough colour contrast. The baseline would not apply to the PDF page content. The original wording is in RS OQ-25, with values in `CODING_STANDARDS.md` §9. | P1 | RS NFR-UX-004; TS-10 | — | MFW | Written decision | OPEN |
| OQ-26 | What are the minimum Android and iOS versions, the test device models, and the supported admin browsers? | P1 | RS NFR-COMP-003 to 005; `TESTING_STRATEGY.md` §6; AC-10.2; AND-07; IOS-06 | — | MFW, with the development team | Written device and version list at M1 | OPEN |

### 5.12 Store compliance

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-42 | What are the app name, Android application ID and iOS bundle ID? Are the Apple and Google accounts organisation accounts in MFW's name, and what is their enrolment status? | P1 | CFG-09, CFG-15; Google Sign-In set-up (T-03.2); AND-01 to AND-03; IOS-01, IOS-02 | DEP-06, DEP-07; R8 | MFW, with the development team | Written identifiers; account access confirmed | OPEN |
| OQ-43 | Will MFW approve a production demo account for store reviewers, and who creates and holds it? | P3 | COM-05; AND-15; IOS-13; SM-03; FX-USR-12 | — | MFW | Written approval | OPEN |
| OQ-44 | Who prepares the store privacy declarations (Apple App Privacy, Google Play Data safety), and from which data-collection inventory? | P3 | AC-11.3; AND-09; IOS-10 | RS NFR-PRIV-002; R11 | MFW, with the development team | Declarations approved by MFW | OPEN |
| OQ-45 | If Google Play requires a web link for account-deletion requests, where does it live, given that public web pages and WordPress changes are excluded? | P2 | AND-10; PAC-15 | RS INT-WP-002; S2 "Scope not included"; R18 | MFW | Written decision; verification of the current policy | OPEN |

### 5.13 Environments, backup and operations

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-40 | Will MFW provide a separate non-production cloud project for testing, at its cost? | P1 | DEC-023; ENV-TEST; T-01.3, T-01.4; TS-05, TS-06 | R17; DEP-05 | MFW | Written approval and project access | OPEN |
| OQ-46 | What backup and recovery does MFW expect (RPO, RTO, scope, cost)? Does MFW keep master copies of issue PDFs? S1 and S2 do not mention backup or restore, so these are proposed additions and not S2 deliverables. | P2 | `BACKUP_AND_RECOVERY.md` §4 and §5; release step 4; HO-14 | R19 | MFW | Written decision | OPEN |
| OQ-47 | Who at MFW receives incident reports and monitoring alerts, through which channel, and what is the support contact for the stores? S1 and S2 do not mention monitoring access, so it is a proposed addition and not an S2 deliverable. | P3 | `DEPLOYMENT_PLAN.md` §7.7; `MAINTENANCE_AND_HANDOVER.md` §10; COM-10 | — | MFW | Named contacts | OPEN |

### 5.14 Ownership, handover and team

| ID | Question | Priority | Blocks | Related | Decision owner | Evidence needed | Status |
|---|---|---|---|---|---|---|---|
| OQ-38 | Do both developers agree the workstream split and the proposed mapping, and what is each developer's availability? | P1 | DEC-011; `TASK_OWNERSHIP_MATRIX.md`; `DEVELOPMENT_ROADMAP.md` §8 | CH D9; R21 | Both developers | AGREED entry, with availability recorded | OPEN |
| OQ-48 | How and when is the repository transferred to MFW, given that S1 passes ownership when the final invoice is paid and S2 AC-12 requires an MFW-owned repository at handover? | P2 | AC-12.1; HO-01; T-12.6 | CH D8; DEP-60 | MFW and Sanika Attarde | Written agreement on method and order | OPEN |
| OQ-49 | Will MFW take a maintenance plan after the warranty? | P3 | `MAINTENANCE_AND_HANDOVER.md` §13 | S1 Costs outside the fee | MFW | Written choice | OPEN |

## 6. Summary

| Priority | Count | IDs |
|---|---|---|
| P1 | 38 | OQ-01 to OQ-05, OQ-07 to OQ-10, OQ-12 to OQ-14, OQ-16 to OQ-18, OQ-24 to OQ-29, OQ-31 to OQ-42, OQ-50, OQ-51, OQ-53, OQ-54, OQ-57 |
| P2 | 15 | OQ-06, OQ-11, OQ-15, OQ-19 to OQ-23, OQ-30, OQ-45, OQ-46, OQ-48, OQ-52, OQ-55, OQ-56 |
| P3 | 4 | OQ-43, OQ-44, OQ-47, OQ-49 |
| **Total** | **57** | All OPEN |

Questions waiting on MFW, which the contracting developer sends (`TASK_OWNERSHIP_MATRIX.md` §10), make up most of the P1 list. Sending them early is task T-00.2 in `DEVELOPMENT_ROADMAP.md`.

## 7. Architecture Questions (AOQ-nn)

`TECHNOLOGY_DECISIONS.md` section 8.2 holds 20 architecture questions, AOQ-01 to AOQ-20. This register is the single list that MFW's questions are taken from, so each AOQ maps to an OQ here. Where no OQ existed, a new one was added (OQ-51 to OQ-57) and the AOQ number stays as an alias. No AOQ or OQ number is changed.

| AOQ | Topic | OQ |
|---|---|---|
| AOQ-01 | Cloud region | OQ-41 |
| AOQ-02, AOQ-04, AOQ-19 | Deletion window, audit retention, deleted-issue list | OQ-24 (and OQ-11, OQ-21) |
| AOQ-03, AOQ-17 | Second factor for admins, revoked admin reads | OQ-20 |
| AOQ-05 | Who sees and exports the registered-reader list | OQ-51 (new) |
| AOQ-06 | Web link for deletion requests | OQ-45 |
| AOQ-07 | Signed-URL lifetime and resume | OQ-37 |
| AOQ-08 | Account linking | OQ-05 |
| AOQ-09 | Verified email for Google | OQ-04 |
| AOQ-10 | App Check | OQ-52 (new) |
| AOQ-11 | MFW's monthly cloud cost ceiling | OQ-53 (new) |
| AOQ-12 | Background downloads | OQ-54 (new) |
| AOQ-13 | Notification token and topic subscriptions | OQ-55 (new) |
| AOQ-14 | How recent a sign-in a role change needs (PRC-01 only) | OQ-56 (new) |
| AOQ-15 | Who owns and pays for the development project | OQ-40 |
| AOQ-16 | Industry-segment list | OQ-13 |
| AOQ-18 | Website PDFs: stay public, and what the sign-in is for | OQ-57 (new) |
| AOQ-20 | Cover image rules for unpublished issues | OQ-22 |
