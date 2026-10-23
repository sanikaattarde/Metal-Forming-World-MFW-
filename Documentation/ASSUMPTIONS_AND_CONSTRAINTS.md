# Assumptions and Constraints Register: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document title | Assumptions and Constraints Register |
| File | `ASSUMPTIONS_AND_CONSTRAINTS.md`, in the same folder as `REQUIREMENTS_SPECIFICATION.md` |
| Project | Metal Forming World (MFW) mobile application |
| Version | 0.2 |
| Status | Draft for Review |
| Last updated | 23 October 2026 |
| Prepared by | MFW development team |
| Approval status | Not approved. No MFW or internal approval of this document has been recorded. |
| Related documents | [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) v0.1; [Scope and Exclusions](SCOPE_AND_EXCLUSIONS.md) v0.1; [Glossary](GLOSSARY.md) v0.1; `PROJECT_CHARTER.md` v0.2 |

**Purpose.** This register records the project's assumptions, constraints, dependencies, open questions and conflicts in one place. For each entry it gives the evidence, the current status, what happens if the entry is wrong or stays unresolved, who owns it, and what evidence or decision would settle it. It does not answer any open question or resolve any conflict. It changes no requirement, status or acceptance criterion in the specification.

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft for internal review |
| 0.2 | 23 October 2026 | Remediation note on REG-001 (YG's statement about the S3 emails). No assumption, constraint, status or priority changed. |

### 1.1 Source documents and authority

| Ref | Document | Evidence status | Authority in this register |
|---|---|---|---|
| S1 | MFW Mobile App Commercial Proposal, `MFW_Commercial_Proposal-2.pdf`, 17 October 2026, 7 pages | Read for this register. Unsigned. Acceptance, approver and sign-off sections blank. | Shows what the proposal says. Its acceptance is unverified (REG-002). |
| S2 | MFW Mobile App Statement of Work, `MFW_Statement_of_Work.pdf`, 17 October 2026, 8 pages | Read for this register. Unsigned. | Shows what the SOW says. Its acceptance is unverified (REG-002). |
| S3 | Client emails received after S1 and S2 | Not available. Not in the repository. | Missing evidence. Not reconstructed from summaries or any other secondary record (REG-001). |
| CH | Project Charter, `PROJECT_CHARTER.md` v0.2, 22 October 2026 | Read for this register. Draft for review, unsigned. | Working summary. It does not override S1 or S2. |
| SPEC | [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) v0.1, 22 October 2026 | Read for this register. Draft for Review. | Detailed requirements reference. Its IDs, statuses and acceptance criteria are used as written. |

S1, S2 and CH are named by file name and not linked, because they are not in the folder where this register was prepared. Fee and payment amounts and personal names are left out. Where the revised commercial terms matter (REG-004), the register refers to the CH sections that hold them.

## 2. How to Read This Register

### 2.1 Entry types

| Type | Meaning |
|---|---|
| ASSUMPTION | An unverified working proposition. The project proceeds as if it holds, but it has not been checked. |
| CONSTRAINT | A documented limitation or obligation. |
| DEPENDENCY | An external input, service, decision or deliverable that the project needs. |
| OPEN | An unresolved question. A decision or clarification is needed. |
| CONFLICT | Statements that cannot all be true, which need a decision. |

### 2.2 Fields

| Field | Content |
|---|---|
| Type | One of the five types above |
| Status | The specification's status label (spec §1.2) for the position the entry records: CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN or CONFLICT. CONFLICT entries always have the status CONFLICT, OPEN entries OPEN, and ASSUMPTION entries ASSUMPTION. A CONSTRAINT or DEPENDENCY is CONFIRMED when S1 or S2 states it, PROVISIONAL when it rests on S3, ASSUMPTION when it is a development-team rule not yet agreed, and OPEN when it is not yet defined. |
| Description and evidence | What the entry says and the evidence for it. For OPEN and CONFLICT entries, the working position used until resolution, if there is one. |
| Source | Documents, sections and pages. Page numbers refer to the S1 and S2 PDFs (Section 2.5). |
| Confidence | See Section 2.3. |
| Impact if incorrect or unresolved | What goes wrong if the assumption fails, the constraint is misread, the dependency is late, or the question stays open. |
| Owner | A role, never a personal name (Section 2.4). |
| Resolution | The evidence, decision or approval that would settle the entry. |
| Due | Only a date or stage found in an actual project record. CH dates are PROVISIONAL (REG-006). The specification's "Needed by" milestones are labelled as proposals. "None recorded" means no record gives one. |
| Links | Requirement IDs, specification items, charter decisions (CH D1 to D9) and risks (CH R1 to R11), and scope items |
| Priority | See Section 2.3. |

### 2.3 Confidence and priority

**Confidence** rates the evidence. For an ASSUMPTION it rates how far the evidence supports the assumption. For a CONSTRAINT or DEPENDENCY it rates how firmly the item is documented. For an OPEN or CONFLICT entry it rates the working position used until resolution.

| Confidence | Meaning |
|---|---|
| High | Stated in S1 or S2, or verified directly in the repository. The unsigned status of S1 and S2 applies to every entry (REG-002). |
| Medium | An S2 planning assumption that S2 says is checked at M1, or a position recorded only in CH. |
| Low | Rests on the missing S3 emails or on a development-team inference with no source. |
| None | No working position has been adopted. A decision is needed first. |

| Priority | Meaning |
|---|---|
| P1 | Could block implementation of the affected features, a milestone, or delivery, if not resolved or met by its due point |
| P2 | Affects scope, acceptance, compliance, cost or schedule, but does not block current work |
| P3 | Recorded for awareness and monitoring |

### 2.4 Owner roles

| Role | Meaning |
|---|---|
| MFW | The client organisation, for inputs and accounts it supplies |
| MFW authorised approver | The person MFW names to approve in writing, with a deputy [S2 Responsibilities]. Not yet named (REG-002). |
| MFW legal adviser | MFW's adviser on privacy and data-protection law (CH §18 R10) |
| Contracting developer | The developer named in S1 and S2 as the party doing the work |
| Co-developer | The second developer recorded in CH §7 and §14 [S3] |
| Development team | Both developers together |

### 2.5 Identifiers and page references

Entries are numbered REG-001 onwards. The IDs do not include the entry type, so an entry keeps its ID when its type changes, for example when an OPEN question is decided and becomes a CONSTRAINT. IDs are never reused. Other ID families are defined in the specification (FR, NFR, DATA, INT, BR, OQ, C, ASM, PAC) and in [SCOPE_AND_EXCLUSIONS.md](SCOPE_AND_EXCLUSIONS.md) (SCP, EXC, CHG).

Section names follow the notation in spec §1.4. Page numbers for S1 and S2:

| Document | Page | Content |
|---|---|---|
| S1 | p.1 | Proposal at a glance; What MFW receives |
| S1 | p.2 | Investment; payment schedule; what MFW receives and approves at M1 to M4 |
| S1 | p.3 | M5; How payment works; Costs outside the fee; maintenance plans; first row of What we need from MFW |
| S1 | p.4 | Rest of What we need from MFW; Key terms; Project approval and sign-off |
| S1 | p.5 | How approval works; Acceptance of this proposal; Authorised approvers; Milestone sign-off record |
| S1 | p.6 to p.7 | Annex A lines 1 to 33 (p.6); lines 34 to 41 and the notes (p.7) |
| S2 | p.1 | Header table; Objectives; Scope included (Design to Admin panel) |
| S2 | p.2 | Scope included (Platform, Release); Scope not included |
| S2 | p.3 | Proposed technical architecture; Components |
| S2 | p.4 | How the main flows work; Why this design; milestones M1 to M4 |
| S2 | p.5 | M5; acceptance criteria AC-1 to AC-11 |
| S2 | p.6 | AC-12; How acceptance testing works; Responsibilities |
| S2 | p.7 | Assumptions and key risks; Defect or change; Change requests steps 1 to 3 |
| S2 | p.8 | Change request step 4; Handover; Warranty; Sign-off |

## 3. Register Summary

| ID | Title | Type | Status | Priority | Owner |
|---|---|---|---|---|---|
| REG-001 | S3 client emails are not in the repository | DEPENDENCY | OPEN | P1 | Development team; MFW authorised approver |
| REG-002 | S1 and S2 are unsigned and no approver is named | DEPENDENCY | OPEN | P1 | MFW |
| REG-003 | The charter calls the baseline approved and the S3 items confirmed | CONFLICT | CONFLICT | P2 | Development team |
| REG-004 | Revised fee, initial payment and payment schedule | CONFLICT | CONFLICT | P2 | Contracting developer; MFW authorised approver |
| REG-005 | Each stage starts after approval and payment | CONSTRAINT | CONFIRMED | P2 | MFW; contracting developer |
| REG-006 | Delivery schedule and milestone dates | CONFLICT | CONFLICT | P1 | Development team; MFW authorised approver |
| REG-007 | The M1 requirements and architecture note is not yet approved | DEPENDENCY | OPEN | P1 | Development team; MFW authorised approver |
| REG-008 | Client review periods and deemed approval | CONSTRAINT | CONFIRMED | P2 | MFW authorised approver |
| REG-009 | Late inputs move the dates | CONSTRAINT | CONFIRMED | P2 | MFW; development team |
| REG-010 | Brand assets | DEPENDENCY | CONFIRMED | P1 | MFW |
| REG-011 | MFW holds the rights to its content | ASSUMPTION | ASSUMPTION | P2 | MFW |
| REG-012 | Sample PDFs | DEPENDENCY | CONFIRMED | P1 | MFW |
| REG-013 | Launch content | DEPENDENCY | CONFIRMED | P2 | MFW |
| REG-014 | Admin user list and store listing text | DEPENDENCY | CONFIRMED | P2 | MFW |
| REG-015 | Testers from MFW's team | DEPENDENCY | CONFIRMED | P2 | MFW |
| REG-016 | MFW decisions on open questions | DEPENDENCY | OPEN | P1 | MFW authorised approver; development team |
| REG-017 | Google Sign-In | CONFLICT | CONFLICT | P1 | MFW authorised approver; development team |
| REG-018 | App Store risk of Google Sign-In without Sign in with Apple | OPEN | OPEN | P2 | MFW authorised approver |
| REG-019 | No guest reading and no public sample | CONFLICT | CONFLICT | P1 | MFW authorised approver |
| REG-020 | Email verification for Google accounts and account linking | OPEN | OPEN | P1 | Development team |
| REG-021 | Capabilities of logged-out visitors and readers with access incomplete | OPEN | OPEN | P2 | MFW authorised approver |
| REG-022 | Mandatory profile fields and age format | OPEN | OPEN | P1 | MFW authorised approver |
| REG-023 | Exact age without an age gate: legal review | OPEN | OPEN | P1 | MFW legal adviser |
| REG-024 | Privacy policy and terms of use | DEPENDENCY | CONFIRMED | P1 | MFW |
| REG-025 | Retention periods | OPEN | OPEN | P2 | MFW authorised approver |
| REG-026 | Edition-update email sign-up and subscriber CSV export | CONFLICT | CONFLICT | P1 | MFW authorised approver |
| REG-027 | Crash reporting and basic usage events | CONFLICT | CONFLICT | P2 | Development team; MFW authorised approver |
| REG-028 | "Online reading" in the charter | CONFLICT | CONFLICT | P2 | Development team; MFW authorised approver |
| REG-029 | Temporary reading copy or retained offline copy | OPEN | OPEN | P1 | MFW authorised approver; development team |
| REG-030 | Readers download an issue before reading it | ASSUMPTION | ASSUMPTION | P3 | Development team |
| REG-031 | PDF size and catalogue profile | ASSUMPTION | ASSUMPTION | P1 | MFW; development team |
| REG-032 | Upload size limit wording and the exact limit | CONFLICT | CONFLICT | P3 | MFW authorised approver; development team |
| REG-033 | Reader targets and reader approach confirmed at M2 | CONSTRAINT | CONFIRMED | P1 | Development team; MFW authorised approver |
| REG-034 | No content delivery network at launch | ASSUMPTION | ASSUMPTION | P2 | Development team |
| REG-035 | Firebase: proposed but named in contractual terms | CONFLICT | CONFLICT | P1 | Development team; MFW authorised approver |
| REG-036 | One Flutter codebase | CONSTRAINT | CONFIRMED | P3 | Development team |
| REG-037 | Cloud project in MFW's name with billing | DEPENDENCY | CONFIRMED | P1 | MFW |
| REG-038 | MFW owns the accounts; developers use role-based access | CONSTRAINT | CONFIRMED | P2 | MFW; development team |
| REG-039 | Third-party costs are paid by MFW directly | CONSTRAINT | CONFIRMED | P3 | MFW |
| REG-040 | No paid third-party component without written approval | CONSTRAINT | CONFIRMED | P2 | Development team; MFW authorised approver |
| REG-041 | Test strategy, test plan and security checklist | DEPENDENCY | CONFIRMED | P2 | Development team |
| REG-042 | WordPress API is on and reachable over HTTPS | ASSUMPTION | ASSUMPTION | P1 | MFW |
| REG-043 | WordPress details from MFW | DEPENDENCY | CONFIRMED | P1 | MFW |
| REG-044 | WordPress site unchanged; news written in WordPress | CONSTRAINT | CONFIRMED | P3 | Development team |
| REG-045 | Provider outages and operating system changes are not defects | CONSTRAINT | CONFIRMED | P3 | Development team; MFW |
| REG-046 | Push delivery through Apple and Google | DEPENDENCY | CONFIRMED | P2 | MFW; development team |
| REG-047 | Apple and Google developer accounts in MFW's name | DEPENDENCY | CONFIRMED | P1 | MFW |
| REG-048 | Store review outcome and timing | CONSTRAINT | CONFIRMED | P2 | Development team |
| REG-049 | Store policies as published today | ASSUMPTION | ASSUMPTION | P2 | Development team |
| REG-050 | Store privacy details and listing text | DEPENDENCY | CONFIRMED | P1 | MFW; development team |
| REG-051 | Custody of app signing credentials | OPEN | OPEN | P2 | Development team; MFW authorised approver |
| REG-052 | Two-developer arrangement and MFW's authorisation | CONFLICT | CONFLICT | P1 | Contracting developer; MFW authorised approver |
| REG-053 | Task split and document ownership | OPEN | OPEN | P1 | Development team |
| REG-054 | Branching and integration rule | CONSTRAINT | ASSUMPTION | P2 | Development team |
| REG-055 | Repository ownership and transfer to MFW | OPEN | OPEN | P2 | Contracting developer; MFW |
| REG-056 | A small editorial team uses one admin role | ASSUMPTION | ASSUMPTION | P3 | MFW |
| REG-057 | English only | CONSTRAINT | CONFIRMED | P3 | Development team |
| REG-058 | Development-team proposals awaiting approval | ASSUMPTION | ASSUMPTION | P2 | Development team; MFW authorised approver |
| REG-059 | Fixed scope and the change process | CONSTRAINT | CONFIRMED | P2 | Development team; MFW authorised approver |

Totals: 59 entries. By type: ASSUMPTION 8, CONSTRAINT 14, DEPENDENCY 16, OPEN 10, CONFLICT 11 (see Section 4 for each entry). By priority: P1 25, P2 26, P3 8.

## 4. Register Entries

### 4.1 Evidence, approval and commercial baseline

#### REG-001 S3 client emails are not in the repository

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | OPEN |
| Description and evidence | CH records client amendments received by email after S1 and S2 [S3]. The emails are not in the repository, and CH leaves their dates and senders "to be inserted from the emails". The specification therefore labels every amendment PROVISIONAL. CH §19.1 nevertheless lists the S3 items as confirmed facts (REG-003). This register does not reconstruct the emails from summaries or other secondary records. Reported by YG, not filed: the S3 client emails exist and support the amendments. They are not in the repository and were not seen by the reviewer. The items stay PROVISIONAL until the emails are filed or MFW confirms in writing. |
| Source | CH §1 (source table), §17.3, §19.1; spec §1.1, §1.2 |
| Confidence | High. The absence of the emails was checked in the repository on 23 October 2026. |
| Impact if incorrect or unresolved | No PROVISIONAL item can become CONFIRMED. The team may build or test features that MFW has not agreed in writing, or omit ones it has. The revised schedule and commercial terms stay unsupported (REG-004, REG-006). |
| Owner | Development team (filing the record); MFW authorised approver (confirmation) |
| Resolution | File the S3 emails, or MFW's written confirmation of each amendment, in the repository. Record the amendments formally, for example as a consolidated change record or an amended SOW (CH D7). |
| Due | CH §19.3 D7: before M2. M2 is 4 November 2026 in CH §12, a PROVISIONAL date. |
| Links | OQ-29; CH D7; FR-AUTH-005, FR-PROF-001, FR-PROF-002, FR-PROF-003, FR-PROF-004, FR-PROF-005, FR-SHR-002, FR-SHR-004, FR-USER-002, FR-USER-003, NFR-PRIV-001, NFR-PRIV-003, DATA-004, INT-AUTH-002, BR-001, BR-003 (PROVISIONAL); CHG-08 |
| Priority | P1 |

#### REG-002 S1 and S2 are unsigned and no approver is named

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | OPEN |
| Description and evidence | The S1 acceptance block, authorised-approver table and milestone sign-off record are blank. The S2 sign-off block is blank. CH §20 has no signatures. S2 requires MFW to name one authorised approver and one deputy, whose written approval (email is enough) counts for MFW. CH §7 records two MFW senders of the S3 emails, but whether they hold the approver roles is undecided (CH D1). S1 states that it is valid until 13 November 2026. The repository has no record of acceptance. |
| Source | S1 Acceptance of this proposal, Authorised approvers, Milestone sign-off record (p.5); S1 Key terms: Validity (p.4); S2 Sign-off (p.8); S2 Responsibilities (p.6); CH §7, §19.3 D1, §20 |
| Confidence | High. The blank sign-off sections were checked in the PDFs. |
| Impact if incorrect or unresolved | The formal acceptance of every CONFIRMED item is unverified. The M1 note and the project documents cannot be approved in writing. The S2 deemed-approval rule (REG-008) cannot run without a named approver. |
| Owner | MFW |
| Resolution | Signed or otherwise accepted copies of S1 and S2, or MFW's written acceptance, filed in the repository. The approver and deputy named in writing. |
| Due | S1: before kickoff. CH §12: before 21 October 2026, a PROVISIONAL date that has passed with no record in the repository. CH D1: before M1 approval. S1 validity ends 13 November 2026. |
| Links | OQ-28; CH D1; spec §14; REG-007, REG-008 |
| Priority | P1 |

#### REG-003 The charter calls the baseline approved and the S3 items confirmed

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | CH §17.1 says that S1, S2 and the S3 amendments "form the approved baseline", and CH §19.1 lists the S3 amendments under "Confirmed facts". The available evidence does not support either statement: S1 and S2 are unsigned (REG-002) and the S3 emails are missing (REG-001). Working position: the specification's labels, under which S1 and S2 items are CONFIRMED subject to OQ-28, and S3 items are PROVISIONAL. |
| Source | CH §17.1, §19.1; spec §1.2 |
| Confidence | High. The working position follows the documented evidence. |
| Impact if incorrect or unresolved | Readers of the charter may treat PROVISIONAL items as agreed and build or commit to them without written confirmation. |
| Owner | Development team |
| Resolution | Align the CH wording with the specification at the next charter revision, or file the evidence that makes the CH wording true. |
| Due | None recorded |
| Links | OQ-28, OQ-29; REG-001, REG-002 |
| Priority | P2 |

#### REG-004 Revised fee, initial payment and payment schedule

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | S1 states a fixed fee, a 30% advance and four milestone payments, and S2 restates the fixed fee. CH §13 and §17.3 record a higher revised fee, a different initial payment recorded as received, and a revised split of the milestone payments, all sourced to S3. CH §13 notes that the increase is not allocated to the S1 Annex A lines and that the S3 amendments are delivered within the revised fee. Whether the nil GST position in S1 applies at the revised fee is open (CH D6). The repository holds no invoice, receipt or signed amendment. Working position: none is adopted in the project documents. The revised terms are PROVISIONAL. The amounts are in S1 and CH §13 and are not repeated here. |
| Source | S1 Proposal at a glance (p.1); S1 Investment and payment schedule (p.2); S1 Key terms (p.4); S2 header table (p.1); CH §13, §17.3, §19.3 D6 |
| Confidence | None. No commercial position is adopted here. |
| Impact if incorrect or unresolved | Milestone invoices and approvals may be disputed. S2 starts each stage only after the milestone invoice is paid (REG-005), so a dispute can delay delivery. |
| Owner | Contracting developer; MFW authorised approver |
| Resolution | File the S3 record or a signed amendment that states the revised terms (CH D7). Confirm the tax position with MFW (CH D6). |
| Due | CH D7: before M2. CH D6: "Confirm with MFW", no date recorded. |
| Links | CH D6, D7; OQ-29; REG-001, REG-005, REG-006 |
| Priority | P2 |

#### REG-005 Each stage starts after approval and payment

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | Each milestone ends with a demonstration or delivery that MFW approves in writing. The next stage starts once the approval is given and the milestone invoice is paid. Each invoice is due seven days from its date. If an invoice stays unpaid, the developer may pause work and move the dates by the days paused. M5 does not wait for Apple or Google. |
| Source | S2 Deliverables and milestones (p.4); S1 How payment works (p.3); S1 Key terms: Invoices (p.4) |
| Confidence | High |
| Impact if incorrect or unresolved | Late approvals or payments move every later date (REG-006). |
| Owner | MFW; contracting developer |
| Resolution | None needed. Track approvals and invoices per milestone. |
| Due | At each milestone |
| Links | REG-004, REG-006, REG-008 |
| Priority | P2 |

### 4.2 Schedule, milestones and client inputs

#### REG-006 Delivery schedule and milestone dates

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | S1 and S2 set kickoff on 16 November 2026, M2 on 27 November, M3 on 11 December, M4 on 25 December 2026, store submission (M5) on 8 January 2027, and the acceptance test build on 28 December 2026. CH §12 and §17.3 record a start on 21 October 2026 with M1 on 21 October, M2 on 4 November, M3 on 18 November, M4 on 2 December and M5 on 16 December 2026, sourced to S3. CH also records a six-week internal target that is not a commitment to MFW. Working position: the CH dates, as PROVISIONAL (spec §11.1). On 23 October 2026, the CH date for M1 has passed and the repository holds no M1 approval (REG-007). |
| Source | S1 Proposal at a glance (p.1); S1 payment schedule (p.2); S2 header table (p.1); S2 milestones (p.4 to p.5); S2 Acceptance testing (p.6); CH §12, §17.3 |
| Confidence | Low. The CH dates rest on S3. |
| Impact if incorrect or unresolved | Every input date, review period and milestone date is uncertain. Planning against the wrong dates could miss the store submission date that MFW expects. |
| Owner | Development team; MFW authorised approver |
| Resolution | File the S3 record or MFW's written confirmation of the schedule (OQ-29). Record the status of M1. |
| Due | Spec §12.2 proposes before M2 for OQ-29 (proposal) |
| Links | C-08; OQ-29; CH R7; spec §11.1, §11.2; REG-001, REG-005, REG-007, REG-009 |
| Priority | P1 |

#### REG-007 The M1 requirements and architecture note is not yet approved

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | OPEN |
| Description and evidence | S2 makes a requirements and architecture note the M1 deliverable, which MFW approves in writing. MFW also names its approver and deputy and supplies brand assets at M1. The specification is a Draft for Review and can serve as the requirements part of the note. The architecture document has not been written, and the architecture is undecided (CH §17.4, D4). The repository holds no M1 approval. |
| Source | S2 Deliverables and milestones: M1 (p.4); S1 milestone table (p.2); spec §1; CH §11, §12, §17.4 |
| Confidence | High. The absence of an approval was checked in the repository. |
| Impact if incorrect or unresolved | Under S2, the next stage starts only after approval, so M2 work rests on an unapproved baseline. |
| Owner | Development team (deliver); MFW authorised approver (approve) |
| Resolution | Complete the architecture document, review the specification internally, and obtain MFW's written approval of the note. |
| Due | CH §12: M1 on 21 October 2026, a PROVISIONAL date that has passed. S2: M1 on 16 November 2026, superseded according to CH. |
| Links | CH D4; spec §1, §14; SCP-079; REG-002, REG-006, REG-035 |
| Priority | P1 |

#### REG-008 Client review periods and deemed approval

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | MFW reviews a milestone within three working days, a test build within two, and acceptance testing within five. MFW sends one consolidated feedback list per review round. If there is no reply, the developer sends a reminder, and after two more working days the deliverable is treated as approved. Written feedback always restarts the review. |
| Source | S2 Responsibilities (p.6); S1 What we need from MFW (p.4); S1 How approval works (p.5); CH §12 |
| Confidence | High |
| Impact if incorrect or unresolved | Slow or scattered feedback moves dates. Deemed approval needs a named approver to send reminders to (REG-002). |
| Owner | MFW authorised approver |
| Resolution | None needed. Apply at each review. |
| Due | At each review |
| Links | REG-002, REG-009 |
| Priority | P2 |

#### REG-009 Late inputs move the dates

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | A delay of one working day on a key item, such as brand assets, sample PDFs, WordPress access, the cloud project, store accounts or launch content, moves the later dates by one working day. A delay longer than five working days is a schedule change agreed in writing. |
| Source | S2 Responsibilities (p.6); S1 What we need from MFW (p.4); CH §12 |
| Confidence | High |
| Impact if incorrect or unresolved | With compressed CH dates (REG-006), late inputs quickly push M5. |
| Owner | MFW; development team |
| Resolution | Track inputs weekly (CH R7) and raise delays in writing. |
| Due | Continuous |
| Links | CH R7; CHG-11; REG-006, REG-010, REG-012, REG-037, REG-043, REG-047 |
| Priority | P2 |

#### REG-010 Brand assets

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | MFW supplies logo files, brand colours and fonts. S1 lists them among the inputs without which design cannot start. |
| Source | S1 What we need from MFW (p.3); S2 Deliverables and milestones: M1 (p.4); CH §12, §15 |
| Confidence | High |
| Impact if incorrect or unresolved | Design and M2 approval are blocked. |
| Owner | MFW |
| Resolution | Receipt of the assets, recorded in the project. |
| Due | S1: at kickoff. CH §12: 21 October 2026, a PROVISIONAL date that has passed. The repository holds no record of receipt. |
| Links | NFR-UX-001; SCP-003; REG-009 |
| Priority | P1 |

#### REG-011 MFW holds the rights to its content

| Field | Entry |
|---|---|
| Type | ASSUMPTION |
| Status | ASSUMPTION |
| Description and evidence | S2 assumes that MFW has the rights to all content, logos and images, and supplies the privacy policy. S1 asks MFW for written confirmation that it owns or may use the magazine content shown in the app. |
| Source | S2 Assumptions (p.7); S1 What we need from MFW (p.4); CH §12 |
| Confidence | Medium. S2 assumption, checked at M1. |
| Impact if incorrect or unresolved | Content shown in the app could breach third-party rights, and store review could raise it. |
| Owner | MFW |
| Resolution | MFW's written confirmation, filed in the repository. |
| Due | S1: before kickoff. CH §12: before 21 October 2026, a PROVISIONAL date that has passed. |
| Links | ASM-07; FR-PRIV-001, NFR-UX-001; REG-002 |
| Priority | P2 |

#### REG-012 Sample PDFs

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | MFW supplies two to three sample magazine PDFs, including the largest expected issue. S1 lists them among the inputs without which the reader work cannot start. |
| Source | S1 What we need from MFW (p.4); S2 Assumptions (p.7); CH §12 |
| Confidence | High |
| Impact if incorrect or unresolved | The reader test, the AC-2 targets and the M2 reader decision are blocked (REG-033). The file-size assumption cannot be checked (REG-031). |
| Owner | MFW |
| Resolution | Receipt of the files, kept outside the source repository if MFW requires. |
| Due | S1: end of Week 1. CH §12: 28 October 2026 (PROVISIONAL). |
| Links | NFR-PERF-001, NFR-PERF-002, NFR-STOR-001, FR-READ-006; REG-031, REG-033 |
| Priority | P1 |

#### REG-013 Launch content

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | MFW supplies and enters the launch content: the latest issue and four to six archive issues, with their details. Creating and entering content is excluded from the project. |
| Source | S1 What we need from MFW (p.4); S2 Not included (p.2); S2 Responsibilities (p.6); CH §12 |
| Confidence | High |
| Impact if incorrect or unresolved | AC-1 cannot be shown with real issues, and the app cannot launch with its catalogue. |
| Owner | MFW |
| Resolution | Content entered through the admin panel. |
| Due | S1: end of Week 4. CH §12: 18 November 2026 (PROVISIONAL). |
| Links | FR-MAG-004; SCP-027; EXC-16 |
| Priority | P2 |

#### REG-014 Admin user list and store listing text

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | MFW supplies the list of admin users and the store listing text. |
| Source | S1 What we need from MFW (p.4); CH §12 |
| Confidence | High |
| Impact if incorrect or unresolved | Admin accounts cannot be set up and store submission cannot be completed. |
| Owner | MFW |
| Resolution | Receipt of both items. How admin accounts are created is OQ-20. |
| Due | S1: Weeks 5 and 6. CH §12: 18 November to 2 December 2026 (PROVISIONAL). |
| Links | FR-USER-005, INT-STORE-001; OQ-20; REG-050 |
| Priority | P2 |

#### REG-015 Testers from MFW's team

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | MFW names testers for acceptance testing. S2 planned for year-end holidays in Weeks 6 and 7 of its own schedule. |
| Source | S1 What we need from MFW (p.4); S2 Risks (p.7); CH §12 |
| Confidence | High |
| Impact if incorrect or unresolved | Acceptance testing and sign-off cannot happen on time. |
| Owner | MFW |
| Resolution | Named testers and their availability, shared at kickoff as S2 proposes. |
| Due | CH §12: from 2 December 2026 (PROVISIONAL). S1: from 28 December 2026, superseded according to CH. |
| Links | NFR-REL-002; spec §10.1; SCP-082 |
| Priority | P2 |

#### REG-016 MFW decisions on open questions

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | OPEN |
| Description and evidence | The specification lists 31 open questions (OQ-01 to OQ-31). Many need MFW's decision before the M2 screens are approved. This entry tracks those that have no entry of their own in this register (Section 5.3). |
| Source | Spec §12.2 |
| Confidence | High. The questions are documented and unanswered. |
| Impact if incorrect or unresolved | Screens and features may be designed on guesses and need rework. |
| Owner | MFW authorised approver; development team |
| Resolution | A recorded decision for each question, with its date and decision-maker. |
| Due | Spec §12.2 proposes a milestone for each question (proposals) |
| Links | OQ-10, OQ-11, OQ-13, OQ-15, OQ-16, OQ-17, OQ-18, OQ-19, OQ-20, OQ-21, OQ-22, OQ-25, OQ-26 |
| Priority | P1 |

### 4.3 Authentication and access

#### REG-017 Google Sign-In

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | S1 A-27 and the S1 Annex A notes mark Google Sign-In "Not included (later phase)", and S2 Not included lists Google sign-in as a later-phase feature. CH §8 and §17.3 record it as in scope within the revised fee [S3]. CH §15 adds that it is configured in MFW's accounts. Working position: in scope, as PROVISIONAL (spec C-04). |
| Source | S1 Annex A line 27 and notes (p.6 to p.7); S2 Not included (p.2); CH §8, §15, §17.3 |
| Confidence | Low. Rests on S3. |
| Impact if incorrect or unresolved | Building Google Sign-In without a written record risks unpaid or disputed work. Not building it risks missing a client requirement. It also affects the profile flow (REG-022) and App Store review (REG-018). |
| Owner | MFW authorised approver (confirmation); development team (design) |
| Resolution | File the S3 record or MFW's written confirmation (OQ-29), and decide OQ-04 and OQ-05 (REG-020). |
| Due | None recorded. Spec §12.2 proposes before M2 for OQ-29 (proposal). |
| Links | C-04; OQ-29; FR-AUTH-005, INT-AUTH-002, FR-PROF-003 (PROVISIONAL); PAC-01; SCP-016; REG-018, REG-020 |
| Priority | P1 |

#### REG-018 App Store risk of Google Sign-In without Sign in with Apple

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | CH §18 R9 records that the iOS build offers Google Sign-In and email login but not Sign in with Apple, so Apple's review may require an equivalent privacy-preserving login option under App Store Review Guideline 4.8. CH records this as an accepted risk [S3]. The specification asks MFW to confirm that acceptance in writing (OQ-06). This register does not interpret the guideline. Working position: the risk is accepted, according to CH. |
| Source | CH §18 R9; spec §12.2 OQ-06 |
| Confidence | Low. The acceptance rests on S3. |
| Impact if incorrect or unresolved | Apple may reject the iOS build. Adding Sign in with Apple would then be a change request (CHG-06) and could delay public release. |
| Owner | MFW authorised approver |
| Resolution | MFW's written acceptance of the risk (OQ-06). |
| Due | Spec §12.2 proposes before M3 (proposal) |
| Links | OQ-06; CH R9; FR-AUTH-005; EXC-01; CHG-06; REG-017, REG-049 |
| Priority | P2 |

#### REG-019 No guest reading and no public sample

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | S2 Scope: Accounts includes "Guest browsing with a public sample", and S2 Flow 3 says "Guests see only a public sample". S1 prices "Guest browsing and protected content access" (A-28), lists guest browsing under What MFW receives, and describes Authentication as including "guest access". CH §9 and §17.3 record that the public sample is removed and there is no guest reading [S3]. Both positions let logged-out visitors browse issue metadata and read news. Sign-in and a verified email for full issues are CONFIRMED by S2 AC-3 (BR-002). Only the removal of the sample rests on S3. Working position: the CH position, as PROVISIONAL (spec C-01). |
| Source | S2 Scope: Accounts (p.1); S2 Flow 3 (p.4); S2 AC-3 (p.5); S1 What MFW receives (p.1); S1 Investment (p.2); S1 Annex A line 28 (p.6); CH §9, §17.3 |
| Confidence | Low. Rests on S3. |
| Impact if incorrect or unresolved | The M2 screens, the access rules and the AC-3 tests would follow the wrong position. |
| Owner | MFW authorised approver |
| Resolution | File the S3 record or MFW's written confirmation (OQ-29). |
| Due | Spec §12.2 proposes before M2 for OQ-29 (proposal) |
| Links | C-01; OQ-29; BR-001 (PROVISIONAL); BR-002 (CONFIRMED); FR-MAG-001, FR-NEWS-007; PAC-04; EXC-02 |
| Priority | P1 |

#### REG-020 Email verification for Google accounts and account linking

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | No source says whether email verification applies to Google accounts (OQ-04), or what happens when an email address registered with one sign-in method is used with the other (OQ-05). CH leaves both to the architecture and requirements documents (D5). No working position is adopted. |
| Source | CH §9 rule 2, §19.3 D4 and D5; spec §12.2 OQ-04, OQ-05 |
| Confidence | None |
| Impact if incorrect or unresolved | The authentication design for M3 cannot be finished, and BR-002 cannot be tested for Google accounts. |
| Owner | Development team, with MFW's approval |
| Resolution | A recorded decision in the architecture document, approved by MFW. |
| Due | CH D5: the architecture and requirements documents. No date recorded. |
| Links | OQ-04, OQ-05; CH D5; FR-AUTH-006, FR-AUTH-007 (OPEN); BR-002; SCP-017; REG-017, REG-035 |
| Priority | P1 |

#### REG-021 Capabilities of logged-out visitors and readers with access incomplete

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | The sources do not settle whether logged-out visitors can receive notifications and set preferences, share issues and articles, or sign up for edition-update emails (OQ-09), or whether a signed-in reader with access incomplete can use favourites (OQ-12). The access matrix in spec §9.2 marks these OPEN. |
| Source | Spec §9.2, §12.2 OQ-09, OQ-12; CH §7, §9 |
| Confidence | None |
| Impact if incorrect or unresolved | Screens, notification registration and the access rules may need rework after M2. |
| Owner | MFW authorised approver |
| Resolution | MFW's recorded decision on OQ-09 and OQ-12. |
| Due | Spec §12.2 proposes before M2 approval (proposal) |
| Links | OQ-09, OQ-12; FR-NOTIF-007 (OPEN); FR-SHR-001, FR-SHR-003, FR-BKM-003 (CONFIRMED); FR-EMAIL-001 (CONFLICT); DATA-007; SCP-059 |
| Priority | P2 |

### 4.4 Reader profile and personal data

#### REG-022 Mandatory profile fields and age format

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | CH records a mandatory reader profile with name, exact age, gender, occupation, domain of work "and related fields" [S3]. The final list, the format and allowed values of each field, whether exact age is stored as a number or a date of birth, and when Google Sign-In readers complete the profile are not decided (OQ-01, OQ-02, OQ-03). CH D2 expected the requirements document to set the list. The specification left it open. Working position: the five named fields, as PROVISIONAL. |
| Source | CH §8, §9 rules 4 and 5, §19.3 D2; spec §5.2, §7.2, §12.2 |
| Confidence | Low. Rests on S3. |
| Impact if incorrect or unresolved | The registration screens and data model cannot be finalised for M2 and M3. The privacy policy and store declarations cannot name the fields (REG-024). |
| Owner | MFW authorised approver, with the development team for the age format |
| Resolution | MFW's written field list with formats, and decisions on OQ-02 and OQ-03. |
| Due | CH D2: the requirements document. Spec §12.2 proposes before M2 approval (proposal). |
| Links | OQ-01, OQ-02, OQ-03; CH D2; FR-PROF-001, FR-PROF-002, FR-PROF-003, DATA-004, NFR-PRIV-001 (PROVISIONAL); PAC-02; SCP-018; REG-023, REG-024 |
| Priority | P1 |

#### REG-023 Exact age without an age gate: legal review

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | CH §9 records that age is collected with no age restriction and no parental-consent flow [S3]. CH §18 R10 notes that India's data protection rules on children's data are due to apply within months of launch, and asks MFW's legal adviser to confirm the approach. Working position: no age gate and no parental-consent flow, as PROVISIONAL (FR-PROF-005). This register makes no legal assessment. |
| Source | CH §9 rule 5, §18 R10; spec §5.2, §6.4 |
| Confidence | Low. Rests on S3, and no legal review is recorded. |
| Impact if incorrect or unresolved | A compliance problem for MFW as the party responsible for reader data. Rework if an age gate is needed later (CHG-07). |
| Owner | MFW legal adviser; MFW authorised approver |
| Resolution | The legal adviser's written outcome, recorded under OQ-07. |
| Due | Spec §12.2 proposes before the profile is built (M3) (proposal) |
| Links | OQ-07; CH R10; FR-PROF-005 (PROVISIONAL); NFR-PRIV-006 (OPEN); SCP-021; CHG-07 |
| Priority | P1 |

#### REG-024 Privacy policy and terms of use

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | MFW supplies the privacy policy and terms of use at a public web address, and the developers implement consent and deletion. The privacy details declared in both stores must match MFW's policy (AC-11). CH §9 adds that the policy must name the profile fields collected and their purpose. How consent is recorded is OQ-27. |
| Source | S2 Not included (p.2); S2 Responsibilities (p.6); S2 AC-11 (p.5); S1 What we need from MFW (p.4); CH §9 rule 8, §18 R11 |
| Confidence | High |
| Impact if incorrect or unresolved | Consent at registration cannot be built against final text, and the store submissions cannot be completed. |
| Owner | MFW |
| Resolution | The policy and terms published at a public address, naming the approved profile fields (REG-022). |
| Due | S1: end of Week 4. CH §12: 18 November 2026 (PROVISIONAL). |
| Links | OQ-27; CH R11; FR-PRIV-001, FR-PRIV-002, NFR-PRIV-001, NFR-PRIV-002; SCP-009, SCP-013; REG-022, REG-050 |
| Priority | P1 |

#### REG-025 Retention periods

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | No source sets retention periods for accounts, profiles, inactive accounts, send records, consent records, crash data or exports, or says whether any record is kept after account deletion. CH places data retention in the architecture document (D4). |
| Source | CH §19.3 D4; spec §7.3, §12.2 OQ-24 |
| Confidence | None |
| Impact if incorrect or unresolved | The deletion behaviour (FR-PRIV-003) and PAC-06 cannot be finalised, and the privacy policy cannot state retention. |
| Owner | MFW authorised approver |
| Resolution | MFW's recorded decision on OQ-24. |
| Due | CH D4: the architecture document. Spec §12.2 proposes before M4 (proposal). |
| Links | OQ-24; CH D4; NFR-PRIV-005, DATA-017 (OPEN); FR-PRIV-003; PAC-06; SCP-078 |
| Priority | P2 |

#### REG-026 Edition-update email sign-up and subscriber CSV export

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | S2 Scope: Accounts includes an optional sign-up for edition-update emails, and S2 Architecture: Database stores an "update list". S2 Scope: Admin panel and AC-8 require a subscriber list with CSV export, and S2 Architecture: Admin panel says editors manage "subscribers". S1 prices "Email subscription and edition alerts" (A-19), "Profile, settings and subscription screens" (A-10) and "Subscriber management" (A-35), and its Annex A notes define "subscription" in lines 10 and 19 as the optional email update sign-up. CH §8 leaves the sign-up out and describes "a list of registered users with CSV export" [S3], and CH §17.3 does not list the sign-up's removal. S2 Flow 4 also uses "subscribed" for readers who opted into a notification category. Working position: none adopted. The S2 baseline is kept and marked CONFLICT, and the registered-user list is PROVISIONAL (spec C-02). This register does not drop, merge or approve either feature. |
| Source | S2 Scope: Accounts, Admin panel (p.1); S2 Architecture: Database, Admin panel (p.3); S2 Flow 4 (p.4); S2 AC-8 (p.5); S1 What MFW receives (p.1); S1 Annex A lines 10, 19, 35 and notes (p.6 to p.7); CH §8, §17.3 |
| Confidence | None |
| Impact if incorrect or unresolved | AC-8 cannot be tested against an agreed meaning. The sign-up screens, the stored list and the export may be built wrongly or left out. |
| Owner | MFW authorised approver |
| Resolution | MFW decides whether the sign-up is kept, dropped or merged into registration, and what "subscriber list" means in AC-8 (OQ-31). |
| Due | Spec §12.2 proposes before M2 approval (proposal) |
| Links | C-02; OQ-31; FR-EMAIL-001, FR-USER-001, DATA-010 (CONFLICT); FR-EMAIL-002, FR-EMAIL-003 (ASSUMPTION); FR-USER-002, FR-USER-003 (PROVISIONAL); PAC-11; SCP-022, SCP-067, SCP-068; EXC-15; CHG-09 |
| Priority | P1 |

#### REG-027 Crash reporting and basic usage events

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | S2 Scope: Platform includes "Crash reporting and basic usage events", S2 Flow 5 reports them, and S2 Architecture lists monitoring. CH §8 does not list them. CH records that per-user reading-activity tracking stays excluded [S2, S3]. Which events are recorded, and whether consent is needed first, is OQ-23. Working position: the S2 position, so NFR-OBS-001 and NFR-OBS-002 are CONFIRMED, limited by NFR-PRIV-003, which is PROVISIONAL (spec C-07). |
| Source | S2 Scope: Platform (p.2); S2 Architecture: Monitoring (p.3); S2 Flow 5 (p.4); CH §8, §10, §17.3 |
| Confidence | High. The working position is stated in S2. |
| Impact if incorrect or unresolved | Monitoring may be configured without an agreed event list, or record more than the privacy policy allows. |
| Owner | Development team (charter update); MFW authorised approver (OQ-23) |
| Resolution | Confirm the S2 position and update CH §8 at its next revision. Decide OQ-23. |
| Due | Spec §12.2 proposes before M3 for OQ-23 (proposal) |
| Links | C-07; OQ-23; NFR-OBS-001, NFR-OBS-002 (CONFIRMED); NFR-PRIV-003 (PROVISIONAL); DATA-014; PAC-09; SCP-076; EXC-06 |
| Priority | P2 |

### 4.5 Reading, downloads and PDF handling

#### REG-028 "Online reading" in the charter

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | CH §8 lists "Online reading" under interactive PDF reading without defining it. S2 Assumptions, S2 Flow 3 and S2 Not included say that readers download an issue in full before reading it, and that reading before the full download finishes is a later-phase feature. CH §18 R2 agrees with S2. Working position: the S2 position (FR-READ-002, CONFIRMED). |
| Source | CH §8, §18 R2; S2 Not included (p.2); S2 Flow 3 and Why this design (p.4); S2 Assumptions (p.7) |
| Confidence | High. The working position is stated in S2. |
| Impact if incorrect or unresolved | Readers of the charter may expect streaming or page-by-page reading, which is excluded (EXC-03). |
| Owner | Development team (charter wording); MFW authorised approver (confirmation) |
| Resolution | Clarify the CH §8 wording, and resolve OQ-08 (REG-029). |
| Due | None recorded |
| Links | C-03; OQ-08; FR-READ-002 (CONFIRMED); SCP-035; EXC-03; REG-029 |
| Priority | P2 |

#### REG-029 Temporary reading copy or retained offline copy

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | The specification reads S2 as using one complete downloaded copy for both reading and offline use, while CH §9 lists reading and downloading as separate capabilities. OQ-08 asks whether opening a full issue always keeps it on the device as an offline copy, or whether there is a temporary complete copy for reading and a separate action to keep the issue offline. Reading before the full download finishes is excluded in both cases. What happens to downloaded copies after sign-out, account deletion or unpublishing is a related question (OQ-11). No working position is adopted. |
| Source | Spec §5.6, §12.2 OQ-08, OQ-11; S2 Flow 3 (p.4); CH §9 |
| Confidence | None |
| Impact if incorrect or unresolved | The reader and download flows, storage use and the Downloads screen may be designed wrongly before M2. |
| Owner | MFW authorised approver, with the development team |
| Resolution | MFW's recorded decision on OQ-08 and OQ-11. |
| Due | Spec §12.2 proposes before M2 approval for OQ-08 and before M3 for OQ-11 (proposals) |
| Links | OQ-08, OQ-11; FR-READ-002, FR-DL-001, FR-DL-008 (CONFIRMED); FR-DL-010 (OPEN); ASM-09; CH R3; SCP-035, SCP-036, SCP-038; REG-028, REG-030 |
| Priority | P1 |

#### REG-030 Readers download an issue before reading it

| Field | Entry |
|---|---|
| Type | ASSUMPTION |
| Status | ASSUMPTION |
| Description and evidence | S2 assumes that readers download an issue before reading it. The fee and the plan rest on this assumption, which is checked at M1. |
| Source | S2 Assumptions (p.7); S2 Why this design (p.4) |
| Confidence | Medium |
| Impact if incorrect or unresolved | If MFW expects reading without a full download, that is excluded work (EXC-03) and a change request. |
| Owner | Development team |
| Resolution | MFW confirms at M1, or the developers raise it in writing under S2 Assumptions. |
| Due | S2: checked at M1 |
| Links | ASM-09; FR-READ-002; REG-028, REG-029, REG-034 |
| Priority | P3 |

#### REG-031 PDF size and catalogue profile

| Field | Entry |
|---|---|
| Type | ASSUMPTION |
| Status | ASSUMPTION |
| Description and evidence | S2 assumes that each issue is one PDF of up to 150 MB and about 120 pages, with five to twelve issues live at launch. These figures are checked at M1 with MFW's sample PDFs. |
| Source | S2 Assumptions (p.7); CH §15, §19.2 |
| Confidence | Medium |
| Impact if incorrect or unresolved | Larger or heavier files could miss the AC-2 targets, lengthen downloads and raise storage and transfer costs. S2 says extra work from a wrong assumption follows the change process. |
| Owner | MFW (sample files); development team (check) |
| Resolution | Test with the largest expected issue (REG-012) and record the result at M1. |
| Due | S2: checked at M1. Sample PDFs: S1 end of Week 1; CH §12 28 October 2026 (PROVISIONAL). |
| Links | ASM-01, ASM-02; NFR-STOR-001, NFR-STOR-002 (ASSUMPTION); CH R1, R2; SCP-041; REG-012, REG-032, REG-033 |
| Priority | P1 |

#### REG-032 Upload size limit wording and the exact limit

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | S2 Assumptions say "up to 150 MB". S2 Flow 1 says "within the size limit (150 MB by default)". CH §8 says "under 150 MB per issue". Whether a file of exactly 150 MB is accepted, and whether admins can change the limit, is OQ-30. Working position: the S2 wording (FR-ADMIN-007, CONFIRMED). |
| Source | S2 Assumptions (p.7); S2 Flow 1 (p.4); CH §8; spec C-06 |
| Confidence | High. The working position is stated in S2. |
| Impact if incorrect or unresolved | An edge case at exactly 150 MB could fail AC-8 or reject a real issue. |
| Owner | MFW authorised approver, with the development team |
| Resolution | MFW's recorded decision on OQ-30. |
| Due | Spec §12.2 proposes before M3 (proposal) |
| Links | C-06; OQ-30; FR-ADMIN-007 (CONFIRMED); NFR-SEC-008; SCP-062; REG-031 |
| Priority | P3 |

#### REG-033 Reader targets and reader approach confirmed at M2

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | AC-2 sets the only numeric targets: first page within 3 seconds on the mid-range test phone, sharp text at 300% zoom and no crash across twenty page turns. They are confirmed at the end of Week 2 after testing on MFW's sample PDFs. M2 delivers the reader test result, and the reader approach is confirmed or an agreed alternative recorded. A swipe-and-zoom reader is always built as the fallback, and no paid component is used without MFW's written approval. |
| Source | S2 Acceptance criteria introduction and AC-2 (p.5); S2 Deliverables and milestones: M2 (p.4); S2 Risks (p.7); CH §19.3 D3 |
| Confidence | High |
| Impact if incorrect or unresolved | Without the test on real PDFs, M2 cannot be approved and the reader choice may fail AC-2. |
| Owner | Development team (test); MFW authorised approver (M2 approval) |
| Resolution | The reader test on MFW's sample PDFs, recorded at M2. Mode switching is OQ-14. |
| Due | S2: end of Week 2. CH §12: M2 on 4 November 2026 (PROVISIONAL). |
| Links | CH D3, R1; OQ-14; NFR-PERF-001, NFR-PERF-002, NFR-REL-001, FR-READ-006, FR-READ-007 (CONFIRMED); FR-READ-008 (OPEN); SCP-032, SCP-034; REG-012, REG-040 |
| Priority | P1 |

#### REG-034 No content delivery network at launch

| Field | Entry |
|---|---|
| Type | ASSUMPTION |
| Status | ASSUMPTION |
| Description and evidence | S2's proposed architecture has no content delivery network at launch, so readers download a whole issue before reading it. Adding one is an architecture decision, and any added cost needs MFW's written approval. |
| Source | S2 Why this design (p.4); CH §17.4, §18 R2; spec §6.7 |
| Confidence | Medium |
| Impact if incorrect or unresolved | Download times for large issues may be long for distant readers, with more support questions about slow downloads. |
| Owner | Development team |
| Resolution | Decide in the architecture document (CH D4). |
| Due | CH D4: the architecture document. No date recorded. |
| Links | ASM-15; NFR-STOR-003 (ASSUMPTION); C-05; CH R2; CHG-05; REG-030, REG-035 |
| Priority | P2 |

### 4.6 Architecture, backend and costs

#### REG-035 Firebase: proposed but named in contractual terms

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | S2 presents Firebase under "Proposed technical architecture". Firebase also appears in S2's contractual wording: S2 Scope: Platform ("Backend on MFW's own Firebase project"), M3 ("running on MFW's Firebase project"), AC-12 ("a fresh Firebase project"), Responsibilities ("Own and pay for the Firebase project"), Assumptions and Warranty. S1 refers to Firebase in Investment, Annex A lines 21 to 25, What we need from MFW and Costs outside the fee. CH §11 and §17.4 state that the architecture is not approved and is decided in a recorded decision (D4). Working position: requirements are stated as capabilities. Firebase is the S2 baseline, and a different choice that changes M3, AC-12 or third-party cost needs MFW's written approval (spec C-05). |
| Source | S2 Scope: Platform (p.2); S2 Architecture (p.3); S2 Milestones: M3 (p.4); S2 AC-12 and Responsibilities (p.6); S2 Assumptions (p.7); S2 Warranty (p.8); S1 Investment (p.2); S1 Costs outside the fee (p.3); S1 What we need from MFW (p.4); S1 Annex A lines 21 to 25 (p.6); CH §11, §17.4, §19.3 D4 |
| Confidence | Medium. Firebase is the S2 baseline but is not approved. |
| Impact if incorrect or unresolved | The backend build for M3 cannot start on a settled platform. Choosing another platform without approval could breach M3 and AC-12 as written. |
| Owner | Development team (recorded decision agreed by both developers); MFW authorised approver (approval if the terms change) |
| Resolution | The architecture document records the decision. MFW approves it in writing if it changes M3, AC-12 or third-party cost. |
| Due | CH D4: the architecture document. No date recorded. |
| Links | C-05; CH D4; NFR-MAINT-002, NFR-MAINT-005, INT-AUTH-001, INT-FILE-001; spec §8, §11.1; SCP-072; CHG-04; REG-007, REG-020, REG-034, REG-037 |
| Priority | P1 |

#### REG-036 One Flutter codebase

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | The Android and iOS apps are built from one Flutter codebase. |
| Source | S2 Scope: Platform (p.2); S2 Architecture: Mobile app (p.3); S2 Why this design (p.4); CH §19.1 |
| Confidence | High |
| Impact if incorrect or unresolved | Not applicable. This is a settled constraint. |
| Owner | Development team |
| Resolution | None needed |
| Due | Not applicable |
| Links | NFR-COMP-001; SCP-001 |
| Priority | P3 |

#### REG-037 Cloud project in MFW's name with billing

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | MFW creates a cloud project in its own name with billing switched on. S1 names it "A Firebase and Google Cloud project" (C-05). S2 notes that the proposed storage and server logic need a pay-as-you-go plan billed to MFW. |
| Source | S1 What we need from MFW (p.4); S2 Why this design (p.4); S2 Responsibilities (p.6); CH §12, §15 |
| Confidence | High |
| Impact if incorrect or unresolved | Backend set-up, Google Sign-In configuration, push delivery and crash reporting are blocked. |
| Owner | MFW |
| Resolution | The project created and role-based access given to each developer (REG-038). |
| Due | S1: end of Week 1. CH §12: 28 October 2026 (PROVISIONAL). |
| Links | ASM-05; INT-AUTH-001, INT-AUTH-002, INT-FILE-001, INT-PUSH-001, NFR-OBS-001; SCP-071; REG-035, REG-038 |
| Priority | P1 |

#### REG-038 MFW owns the accounts; developers use role-based access

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | MFW owns and pays for the cloud project, the Apple and Google accounts and any domain. It gives the developers access through each platform's role-based access, not shared passwords. Credentials are held by MFW. The developers' access is removed when MFW asks after handover. |
| Source | S2 Responsibilities (p.6); S2 AC-12 (p.6); S2 Handover (p.8); S2 Assumptions (p.7) |
| Confidence | High |
| Impact if incorrect or unresolved | Shared passwords or developer-owned accounts would breach S2 and AC-12. |
| Owner | MFW; development team |
| Resolution | Each developer receives individual role-based access (REG-052). |
| Due | With each account (REG-037, REG-047) |
| Links | ASM-05; NFR-SEC-012; SCP-071, SCP-091; REG-051, REG-052 |
| Priority | P2 |

#### REG-039 Third-party costs are paid by MFW directly

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | Cloud usage, the Apple Developer Program, the Google Play Console, any approved licence and any domain are paid by MFW directly to each provider. The developer buys nothing on MFW's behalf, and nothing is marked up. Cloud usage is billed on actual use and is not quoted in advance. |
| Source | S1 Costs outside the fee (p.3); S1 Key terms: Third-party costs (p.4); S2 Not included (p.2) |
| Confidence | High |
| Impact if incorrect or unresolved | Unplanned costs could fall on the wrong party. |
| Owner | MFW |
| Resolution | None needed |
| Due | Not applicable |
| Links | NFR-STOR-003, NFR-MAINT-006; EXC-20; CHG-03, CHG-14 |
| Priority | P3 |

#### REG-040 No paid third-party component without written approval

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | No paid component is used unless MFW approves it in writing. S1 assumes no commercial flipbook licence, which would be bought only if needed and only after MFW approves the quotation in writing. CH §18 R1 records the licence risk of a third-party reader library. |
| Source | S2 Why this design (p.4); S2 Risks (p.7); S1 Costs outside the fee (p.3); CH §15, §18 R1 |
| Confidence | High |
| Impact if incorrect or unresolved | A reader library with licence terms or costs could be adopted without approval. |
| Owner | Development team; MFW authorised approver |
| Resolution | Record every third-party component and its licence in the technical documentation. |
| Due | Continuous. Reader decision at M2. |
| Links | NFR-MAINT-006; CH R1; SCP-075; CHG-03; REG-033 |
| Priority | P2 |

#### REG-041 Test strategy, test plan and security checklist

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | AC-10 requires a test plan with results for every criterion, the agreed test phones and a completed security checklist. The specification leaves the checklist contents to the test strategy, which CH lists as a later project document. That document has not been written. |
| Source | S2 AC-10 (p.5); CH §11; spec §11.3 |
| Confidence | High |
| Impact if incorrect or unresolved | AC-10 cannot be met, and the security checks have no agreed content. |
| Owner | Development team |
| Resolution | Write the test strategy, including the test plan and security checklist. |
| Due | None recorded. Acceptance testing starts with the test build (REG-006). |
| Links | NFR-SEC-010, NFR-REL-002, NFR-COMP-003; OQ-26; SCP-081 |
| Priority | P2 |

### 4.7 WordPress and external services

#### REG-042 WordPress API is on and reachable over HTTPS

| Field | Entry |
|---|---|
| Type | ASSUMPTION |
| Status | ASSUMPTION |
| Description and evidence | S2 assumes that MFW's WordPress API is switched on and reachable over HTTPS. S2 plans to confirm access in Week 1, test early and cache recent articles. |
| Source | S2 Assumptions and Risks (p.7); CH §15, §18 R5 |
| Confidence | Medium |
| Impact if incorrect or unresolved | The news features cannot work, and AC-7 cannot pass. |
| Owner | MFW (site and host) |
| Resolution | Confirm access in Week 1 using the details in REG-043. |
| Due | S2: confirmed in Week 1 and checked at M1 |
| Links | ASM-03; CH R5; INT-WP-001; SCP-056; REG-043 |
| Priority | P1 |

#### REG-043 WordPress details from MFW

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | MFW supplies the WordPress site address, confirmation that its API is reachable, and the news categories to show. |
| Source | S1 What we need from MFW (p.4); CH §12 |
| Confidence | High |
| Impact if incorrect or unresolved | The news list, category filter and post fields cannot be built or tested. |
| Owner | MFW |
| Resolution | Receipt of the details, recorded in the project. |
| Due | S1: end of Week 1. CH §12: 28 October 2026 (PROVISIONAL). |
| Links | INT-WP-001, INT-WP-003, INT-WP-004, INT-WP-005; SCP-050, SCP-056; REG-042 |
| Priority | P1 |

#### REG-044 WordPress site unchanged; news written in WordPress

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | The project makes no changes to the WordPress site. News is written in WordPress, and the admin panel adds app-level controls only. |
| Source | S2 Not included (p.2); S2 Assumptions (p.7); S1 Annex A notes (p.7); CH §3 |
| Confidence | High |
| Impact if incorrect or unresolved | Any WordPress change would be outside scope (EXC-12). |
| Owner | Development team |
| Resolution | None needed |
| Due | Not applicable |
| Links | INT-WP-002, FR-ADMIN-019, DATA-015; EXC-12 |
| Priority | P3 |

#### REG-045 Provider outages and operating system changes are not defects

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | A Firebase, Apple, Google or WordPress outage, a new operating system version, a change made by MFW, or a content error is not a defect. The developer helps diagnose it, and adapting the app is covered by a support plan or a change request. Notification delivery time depends on Apple and Google and is not guaranteed. |
| Source | S2 Warranty (p.8); S2 AC-9 (p.5) |
| Confidence | High |
| Impact if incorrect or unresolved | Disputes over whether a fault is a defect or a change. |
| Owner | Development team; MFW |
| Resolution | None needed |
| Due | Not applicable |
| Links | NFR-REL-003; spec §6.2; CHG-12 |
| Priority | P3 |

#### REG-046 Push delivery through Apple and Google

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | Notifications are delivered through the platform push services. On iOS this is Apple's push service, using MFW's Apple Developer Program account. |
| Source | S2 Architecture (p.3); S1 What we need from MFW (p.4); S2 Assumptions (p.7) |
| Confidence | High |
| Impact if incorrect or unresolved | iOS notifications cannot be tested without MFW's Apple account (REG-047). |
| Owner | MFW (accounts); development team (configuration) |
| Resolution | Accounts active and configured before notification testing at M4. |
| Due | With REG-047 |
| Links | ASM-05; INT-PUSH-001, INT-PUSH-002, NFR-REL-003; SCP-058; REG-047 |
| Priority | P2 |

### 4.8 App stores and release

#### REG-047 Apple and Google developer accounts in MFW's name

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | MFW enrols in the Apple Developer Program as an organisation and opens a Google Play account, both in its own name. Apple verification can take weeks, so enrolment starts in Week 1 and the developer guides each step. |
| Source | S1 What we need from MFW (p.4); S2 Risks (p.7); CH §12, §15, §18 R8 |
| Confidence | High |
| Impact if incorrect or unresolved | iOS push testing, store submission and the store link for sharing issues are blocked. |
| Owner | MFW |
| Resolution | Both accounts active, with role-based access for each developer. |
| Due | S1: enrolment in Week 1, active by end of Week 4. CH §12: active by 18 November 2026 (PROVISIONAL). |
| Links | ASM-05; CH R8; INT-STORE-001, INT-PUSH-002, FR-SHR-002; SCP-085; REG-046, REG-050 |
| Priority | P1 |

#### REG-048 Store review outcome and timing

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | Apple and Google decide store approval and its timing. M5 is complete at submission and does not wait for the review. No approval date is promised. A rejection caused by a defect is fixed and resubmitted at no charge. A rejection that needs input from MFW, such as privacy wording, is resubmitted at no charge once MFW supplies the input. |
| Source | S2 Not included (p.2); S2 Milestones: M5 (p.5); S2 Warranty (p.8); CH §12, §18 R8 |
| Confidence | High |
| Impact if incorrect or unresolved | Public release may come later than submission, which delays the start of the warranty. |
| Owner | Development team |
| Resolution | None needed. Follow the store guidelines and keep privacy details ready. |
| Due | Not applicable |
| Links | CH R8; INT-STORE-001; EXC-21; REG-049 |
| Priority | P2 |

#### REG-049 Store policies as published today

| Field | Entry |
|---|---|
| Type | ASSUMPTION |
| Status | ASSUMPTION |
| Description and evidence | S2 assumes that Apple and Google store policies are as published today. |
| Source | S2 Assumptions (p.7); CH §19.2 |
| Confidence | Medium |
| Impact if incorrect or unresolved | A policy change could require work outside scope, or block release. |
| Owner | Development team |
| Resolution | Check the current policies before submission. |
| Due | Before M5 |
| Links | ASM-08; spec §11.1; REG-018, REG-048 |
| Priority | P2 |

#### REG-050 Store privacy details and listing text

| Field | Entry |
|---|---|
| Type | DEPENDENCY |
| Status | CONFIRMED |
| Description and evidence | Store listings carry text approved by MFW, and the privacy details declared in both stores must match MFW's privacy policy. The release package handed to MFW includes the listing text, screenshots and privacy inputs. |
| Source | S2 AC-11 (p.5); S2 Handover (p.8); S1 What we need from MFW (p.4) |
| Confidence | High |
| Impact if incorrect or unresolved | AC-11 fails, and store review may reject the app. |
| Owner | MFW (text and policy); development team (declarations) |
| Resolution | MFW approves the listing text, and the declarations are checked against the policy before submission. |
| Due | Listing text: S1 Weeks 5 and 6, CH §12 18 November to 2 December 2026 (PROVISIONAL). Policy: REG-024. |
| Links | NFR-PRIV-002, INT-STORE-001; SCP-085, SCP-088; REG-014, REG-024 |
| Priority | P1 |

#### REG-051 Custody of app signing credentials

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | S2 requires signed Android and iOS builds from tagged source code (AC-11), credentials held by MFW (AC-12) and a handover record of who holds each credential. No source says who creates and holds the app signing credentials during the build, or how they are transferred to MFW. This is a development-team observation (DEV). No working position is adopted. |
| Source | S2 AC-11 (p.5); S2 AC-12 (p.6); S2 Handover (p.8); S2 Responsibilities (p.6) |
| Confidence | None |
| Impact if incorrect or unresolved | Signing credentials held outside MFW's control could block later releases, or fail AC-12. |
| Owner | Development team, with MFW's approval |
| Resolution | Record the custody arrangement in the release documentation and the handover record. |
| Due | None recorded |
| Links | NFR-MAINT-003, NFR-SEC-012; SCP-084, SCP-088; REG-038 |
| Priority | P2 |

### 4.9 Team, repository and handover

#### REG-052 Two-developer arrangement and MFW's authorisation

| Field | Entry |
|---|---|
| Type | CONFLICT |
| Status | CONFLICT |
| Description and evidence | S1 and S2 name one developer, S2 Responsibilities is written in the first person ("I will"), and S2 Risks says "This is a one-person project". S2 gives "the developer" role-based access to MFW's accounts. CH §7, §14 and §17.3 record a contracting developer working with a co-developer [S3]. The detailed task split is pending (CH D9). S1 Key terms state that each side keeps the other's non-public information confidential. This register makes no legal assessment of that term. Working position: two developers, as PROVISIONAL. |
| Source | S1 Proposal at a glance (p.1); S1 Key terms: Confidentiality (p.4); S2 header table (p.1); S2 Responsibilities (p.6); S2 Risks (p.7); CH §7, §14, §17.3, §19.3 D9 |
| Confidence | Low. Rests on S3. |
| Impact if incorrect or unresolved | The co-developer's access to MFW's accounts and content may lack MFW's written authorisation. Responsibility for delivery may be unclear to MFW. |
| Owner | Contracting developer (request); MFW authorised approver (confirmation) |
| Resolution | MFW's written confirmation of the delivery team and of role-based access for each developer, filed with the S3 record (OQ-29). |
| Due | CH D7: before M2, for the formal record of the S3 amendments |
| Links | OQ-29; CH D7, D9, R6; NFR-SEC-012; REG-001, REG-038, REG-053 |
| Priority | P1 |

#### REG-053 Task split and document ownership

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | CH records that the detailed task split between the two developers is pending and will be set out in a task assignment document (D9). CH §18 R6 records the risk of parallel-development conflicts on one codebase and one cloud project. Which developer owns, writes and reviews each project document is not recorded. No working position is adopted. |
| Source | CH §14, §18 R6, §19.3 D9 |
| Confidence | None |
| Impact if incorrect or unresolved | Duplicated or conflicting work, and documents changed by both developers without review. |
| Owner | Development team |
| Resolution | The task assignment document, including document ownership and review. |
| Due | CH D9: the task assignment document. No date recorded. |
| Links | CH D9, R6; REG-052, REG-054 |
| Priority | P1 |

#### REG-054 Branching and integration rule

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | ASSUMPTION |
| Description and evidence | CH §17.5 proposes that `main` is the stable integration branch, that work is done on each developer's own branch, and that changes reach `main` only through a reviewed integration by the other developer. Detailed procedures are left to the development workflow document, which has not been written. This is a development-team rule in a draft charter, not a client requirement, so it is labelled ASSUMPTION until both developers agree it. |
| Source | CH §17.5, §18 R6 |
| Confidence | Medium. Recorded only in CH. |
| Impact if incorrect or unresolved | Unreviewed changes on `main`, or lost work between branches. |
| Owner | Development team |
| Resolution | Agree the rule in the development workflow document. |
| Due | None recorded |
| Links | CH R6; REG-053, REG-055 |
| Priority | P2 |

#### REG-055 Repository ownership and transfer to MFW

| Field | Entry |
|---|---|
| Type | OPEN |
| Status | OPEN |
| Description and evidence | S2 requires weekly commits "to MFW's repository" and, at handover, source code with history in a repository owned by MFW (AC-12). S1 Key terms pass ownership of the code, admin panel and designs to MFW when the final invoice is paid. CH D8 records that the repository is currently owned by the contracting developer, and the repository's remote is hosted under that developer's account. The order of final payment and repository transfer is not recorded. On 23 October 2026 the repository holds documentation only, with no application code. Working position: the repository stays with the contracting developer until a transfer before M5 (CH D8). |
| Source | S2 Responsibilities (p.6); S2 AC-12 (p.6); S2 Handover (p.8); S1 Key terms: Ownership (p.4); CH §14, §19.3 D8 |
| Confidence | Medium. The current ownership was checked in the repository. The transfer plan is recorded only in CH. |
| Impact if incorrect or unresolved | AC-12 fails if MFW does not own the repository at handover. Until then, S2's "MFW's repository" wording is not met. |
| Owner | Contracting developer; MFW |
| Resolution | Agree when and how the repository moves to an MFW-owned account, and record it. |
| Due | CH D8: before M5. M5 is 16 December 2026 in CH §12, a PROVISIONAL date. |
| Links | CH D8; NFR-MAINT-001, NFR-MAINT-002; DATA-016; SCP-086, SCP-089; REG-054 |
| Priority | P2 |

### 4.10 Other scope assumptions and constraints

#### REG-056 A small editorial team uses one admin role

| Field | Entry |
|---|---|
| Type | ASSUMPTION |
| Status | ASSUMPTION |
| Description and evidence | S2 assumes that a small editorial team uses one admin role. The single admin role itself is CONFIRMED (FR-ADMIN-004), and editorial roles are excluded. What remains an assumption is that one role suits MFW's team. S2 Architecture: Accounts mentions "admin roles" in the plural, which is a wording difference only. |
| Source | S2 Assumptions (p.7); S2 Not included (p.2); S2 Architecture: Accounts (p.3); CH §7 |
| Confidence | Medium |
| Impact if incorrect or unresolved | A request for several roles would be a change request (EXC-07). |
| Owner | MFW |
| Resolution | MFW confirms at M1. |
| Due | S2: checked at M1 |
| Links | ASM-06; FR-ADMIN-004 (CONFIRMED); SCP-060; EXC-07 |
| Priority | P3 |

#### REG-057 English only

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | All app and admin panel text is in English. Other languages are excluded. |
| Source | S2 Assumptions (p.7); S2 Not included (p.2) |
| Confidence | High |
| Impact if incorrect or unresolved | Any other language would be a change request. |
| Owner | Development team |
| Resolution | None needed |
| Due | Not applicable |
| Links | ASM-04; NFR-UX-003; SCP-004; EXC-17 |
| Priority | P3 |

#### REG-058 Development-team proposals awaiting approval

| Field | Entry |
|---|---|
| Type | ASSUMPTION |
| Status | ASSUMPTION |
| Description and evidence | The specification adds development-team proposals that MFW has not approved: the assumptions ASM-10 to ASM-14, the requirements labelled ASSUMPTION with a DEV source, and the proposed acceptance criteria PAC-01 to PAC-11. They are not contractual until MFW approves them in writing. |
| Source | Spec §1.2, §10.2, §12.1, §14.3 |
| Confidence | Low. Development-team inferences. |
| Impact if incorrect or unresolved | Work built on an unapproved proposal may need rework, and PROVISIONAL items have no agreed acceptance test. |
| Owner | Development team (submit); MFW authorised approver (approve) |
| Resolution | MFW's written approval or rejection of each proposal, recorded in the specification. |
| Due | With the specification's approval (spec §14) |
| Links | ASM-10, ASM-11, ASM-12, ASM-13, ASM-14; PAC-01, PAC-02, PAC-03, PAC-04, PAC-05, PAC-06, PAC-07, PAC-08, PAC-09, PAC-10, PAC-11; CHG-10 |
| Priority | P2 |

#### REG-059 Fixed scope and the change process

| Field | Entry |
|---|---|
| Type | CONSTRAINT |
| Status | CONFIRMED |
| Description and evidence | The fee is fixed for the scope in S2. Anything that is not a defect against an acceptance criterion is a change. Changes need a written request from MFW's approver, an impact assessment within two working days, and MFW's written approval before work starts. The original scope and dates stand until then. |
| Source | S2 Defect or change and Change requests (p.7 to p.8); S1 Key terms: Fee (p.4); CH §17.2 |
| Confidence | High |
| Impact if incorrect or unresolved | Unapproved changes would be unpaid and would move dates without agreement. |
| Owner | Development team; MFW authorised approver |
| Resolution | None needed. Apply to every change. |
| Due | Not applicable |
| Links | Spec §14.3; CHG-01, CHG-02; REG-002 |
| Priority | P2 |

## 5. Cross-Reference to the Specification and Charter

### 5.1 Specification assumptions

| Spec item | Register entry |
|---|---|
| ASM-01, ASM-02 | REG-031 |
| ASM-03 | REG-042 |
| ASM-04 | REG-057 |
| ASM-05 | REG-037, REG-038, REG-046, REG-047 |
| ASM-06 | REG-056 |
| ASM-07 | REG-011 |
| ASM-08 | REG-049 |
| ASM-09 | REG-030 |
| ASM-10, ASM-11, ASM-12, ASM-13, ASM-14 | REG-058 |
| ASM-15 | REG-034 |

### 5.2 Specification conflicts

| Spec item | Register entry |
|---|---|
| C-01 | REG-019 |
| C-02 | REG-026 |
| C-03 | REG-028 |
| C-04 | REG-017 |
| C-05 | REG-035 |
| C-06 | REG-032 |
| C-07 | REG-027 |
| C-08 | REG-006 |

### 5.3 Specification open questions

| Spec item | Register entry |
|---|---|
| OQ-01, OQ-02, OQ-03 | REG-022 |
| OQ-04, OQ-05 | REG-020 |
| OQ-06 | REG-018 |
| OQ-07 | REG-023 |
| OQ-08, OQ-11 | REG-029 |
| OQ-09, OQ-12 | REG-021 |
| OQ-10, OQ-13, OQ-15, OQ-16, OQ-17, OQ-18, OQ-19, OQ-20, OQ-21, OQ-22, OQ-25, OQ-26 | REG-016 |
| OQ-14 | REG-033 |
| OQ-23 | REG-027 |
| OQ-24 | REG-025 |
| OQ-27 | REG-024 |
| OQ-28 | REG-002 |
| OQ-29 | REG-001 |
| OQ-30 | REG-032 |
| OQ-31 | REG-026 |

### 5.4 Charter decisions and risks

| Charter item | Register entry |
|---|---|
| D1 Approver and deputy | REG-002 |
| D2 Profile fields | REG-022 |
| D3 Reader approach | REG-033 |
| D4 Architecture, authentication design and data retention | REG-020, REG-025, REG-035 |
| D5 Verified email for Google accounts | REG-020 |
| D6 Tax position at the revised fee | REG-004 |
| D7 Formal record of the S3 amendments | REG-001 |
| D8 Repository transfer | REG-055 |
| D9 Task split | REG-053 |
| R1 Reader performance and licence | REG-033, REG-040 |
| R2 Large PDFs and no content delivery network | REG-031, REG-034 |
| R3 Offline content handling | REG-029 |
| R4 Protected-content access | REG-019 |
| R5 WordPress API | REG-042 |
| R6 Parallel development | REG-052, REG-053, REG-054 |
| R7 Compressed timeline | REG-006, REG-009 |
| R8 Store accounts and review | REG-047, REG-048 |
| R9 App Store Review Guideline 4.8 | REG-018 |
| R10 Minors' data | REG-023 |
| R11 Personal data collection | REG-024 |

## 6. Maintenance Rules

- **Updating an entry.** Change the fields, add a line to the change history, and keep the ID. Cite the evidence for the change.
- **Resolving an entry.** Record the decision or evidence, its date and the decision-maker in the Resolution field, and set the Status to the label the evidence supports. Update the specification first if a requirement changes, then the scope document and this register in the same revision.
- **Never delete.** A resolved or withdrawn entry stays in the register, marked "Resolved" or "Withdrawn" in its title, with the reason.
- **No reconstruction.** Missing evidence stays missing. An entry is not resolved from memory, summaries or secondary records.
- **Dates.** Add a due date only when a project record supports it.
- **Consistency.** Requirement statuses are owned by the specification. A status quoted here must match the specification.
