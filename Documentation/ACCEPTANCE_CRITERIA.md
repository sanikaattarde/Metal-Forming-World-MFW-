# Acceptance Criteria: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Acceptance Criteria |
| File | `Documentation/ACCEPTANCE_CRITERIA.md` |
| Phase | 4 — Testing, Release and Risk Management (document 31) |
| Version | 0.1 |
| Status | Draft for review. Not approved. No criterion has been tested. |
| Date | 23 October 2026 |
| Prepared in | Sanika Attarde's Claude Code session, branch `SA` |
| Approval required | Both developers for the verification detail. MFW in writing for every PAC criterion before it becomes contractual. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft. AC-1 to AC-12 broken into verification checks. PAC-01 to PAC-11 carried from RS. PAC-12 to PAC-15 proposed. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `MFW_Statement_of_Work.pdf` (S2) "Acceptance criteria", "Deliverables and milestones", "How acceptance testing works" | Exists, issued, unsigned. **The S2 text is authoritative.** |
| `REQUIREMENTS_SPECIFICATION.md` (RS) §10, §13 | Exists, draft. Summary of AC-1 to AC-12 and the PAC-01 to PAC-11 proposals. |
| `TESTING_STRATEGY.md`, `TEST_DATA_AND_FIXTURES.md` | Exist, created in this task |
| `OPEN_QUESTIONS.md` | Exists, created in this task. Questions linked below. |
| `DEFINITION_OF_DONE.md`, `API_AND_MODULE_CONTRACTS.md` | Exist, created in this task |

## 2. Purpose, Scope and Status

This matrix makes each acceptance criterion testable and traceable. It covers authentication, catalogue, reading, downloads, bookmarks and favourites, news, notifications, admin workflows, security, performance, release and handover.

**Rules**

1. The S2 criteria AC-1 to AC-12 keep their IDs and wording. The rows **AC-n.m** split each criterion into separate checks, quoting or closely following the S2 text. **They do not add or change contractual conditions.** If a check and the S2 text ever differ, S2 prevails.
2. PAC-01 to PAC-11 are the RS §10.2 proposals, unchanged in meaning.
3. PAC-12 to PAC-15 are new proposals.
4. No PAC is contractual until MFW approves it in writing.
5. No result is recorded. Section 9 is the place for results once testing starts.

## 3. How to Read the Matrix

| Column | Meaning |
|---|---|
| ID | AC-n.m (verification check of S2 AC-n), PAC-nn (proposed criterion), or M1 to M5 (milestone condition) |
| Source | Contract or requirement reference |
| Criterion | The user-visible result |
| Preconditions | Build, environment, data (fixtures in `TEST_DATA_AND_FIXTURES.md`) and access state |
| Verification | T test, D demonstration, I inspection, R review (RS §1.4), with the steps |
| Pass condition | The observable expected result |
| Priority | **P1** contractual (S2). **P2** proposed, needed for a PROVISIONAL working requirement. **P3** proposed hardening. |
| Status | CONFIRMED (S2 text, unsigned baseline), PROVISIONAL (relies on S3), BLOCKED (waits on a question), CONFLICT, PROPOSED (not approved) |
| Clarification | The approval or question that affects the row |

The build for every row is the acceptance build in ENV-TEST unless the row says otherwise. Devices are the agreed S2 AC-10 set (OQ-26).

## 4. Milestone Approval Conditions

These restate S2 "Deliverables and milestones". Dates are in conflict (C-08; `DEVELOPMENT_ROADMAP.md` §3).

| ID | MFW approves when [S2] | Verification | Status | Clarification |
|---|---|---|---|---|
| M1 | MFW approves the requirements and architecture note in writing, names its approver and deputy, and supplies brand assets | R | CONFIRMED | OQ-28, OQ-35 |
| M2 | MFW approves the screens. The reader approach is confirmed, or an agreed alternative is recorded. | R, D | CONFIRMED | OQ-36 |
| M3 | A tester can sign up, log in, browse the catalogue and open an issue in the reader on the demo build. The full AC-1 to AC-3 apply at acceptance testing. | D | CONFIRMED | — |
| M4 | Every feature in S2 is present, and no critical defect is open | D, I | CONFIRMED | — |
| M5 | MFW signs off acceptance testing, and the handover checks AC-11 and AC-12 are met | R | CONFIRMED | OQ-48 |

## 5. Contractual Criteria (S2 AC-1 to AC-12)

### AC-1 Browsing and search

| ID | Source | Criterion | Preconditions | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|---|
| AC-1.1 | S2 AC-1; RS FR-MAG-002, FR-MAG-004 | Catalogue shows the latest issue and four to six archive issues | Launch content loaded (MFW) or FX-ISS-01 to FX-ISS-07; signed out | T: open the catalogue; inspect each issue | Every issue shows cover, title, date and description | P1 | CONFIRMED | Launch content is an MFW input |
| AC-1.2 | S2 AC-1; RS FR-SRCH-001 | Search returns the right issues | FX-ISS set | T: search by a title word, a description word and a category name | Only the matching issues are listed, each time | P1 | CONFIRMED | Metadata only (RS FR-SRCH-007) |
| AC-1.3 | S2 AC-1; RS FR-SRCH-002, FR-SRCH-004, FR-SRCH-005 | Category, year and edition filters return the right issues | FX-ISS set | T: apply each filter alone and in combination | Only the matching issues are listed | P1 | CONFIRMED | Meaning of "edition": OQ-13 |
| AC-1.4 | S2 AC-1; RS FR-MAG-007 | A newly published issue appears without an app update | App open on the catalogue; admin publishes FX-ISS-08 | T: pull to refresh | FX-ISS-08 appears. No app update needed. | P1 | CONFIRMED | — |

### AC-2 Reader

| ID | Source | Criterion | Preconditions | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|---|
| AC-2.1 | S2 AC-2; RS NFR-PERF-001 | First page appears quickly | Sample issue downloaded; mid-range test phone; full access (FX-USR-01) | T: open the issue; time per `TESTING_STRATEGY.md` §8.1 | First page within 3 seconds | P1 | CONFIRMED. The target is confirmed at the end of Week 2 [S2]. | Method and repetitions agreed in T-02.3; OQ-26 (device) |
| AC-2.2 | S2 AC-2; RS FR-READ-003, FR-READ-004 | Pages turn by swipe and by tap | Issue open | T: swipe both ways; tap the turn zones | Pages advance and go back each time | P1 | CONFIRMED | — |
| AC-2.3 | S2 AC-2; RS FR-READ-005, NFR-PERF-002 | Zoom to 300% keeps text sharp | Issue open on the test phone | T and I: pinch to 300% on agreed text-heavy pages | Text is sharp to the tester | P1 | CONFIRMED | "Sharp" is judged by inspection |
| AC-2.4 | S2 AC-2; RS FR-READ-009 | Two pages side by side on tablets and in landscape | Tablet (if available); phone in landscape | T: open an issue in each case | Two pages are shown together | P1 | CONFIRMED | Tablet model: OQ-26 |
| AC-2.5 | S2 AC-2; RS NFR-REL-001 | Reading is stable | Issue open | T: 20 consecutive page turns on each test device | No crash | P1 | CONFIRMED | — |
| AC-2.6 | S2 AC-2; RS FR-READ-010 | A damaged file is handled | FX-PDF-10 or FX-PDF-11 placed as the local file | T: open it | An error with a retry option; no crash | P1 | CONFIRMED | — |
| AC-2.7 | S2 Scope included: Reader; S1 What MFW receives; RS FR-READ-006, FR-READ-007 | Page-turn effect and plain swipe mode are both available | Issue open | D: show both modes | Both modes work | P1 | CONFIRMED (scope item; not in the AC-2 text) | Switching and default: OQ-14. Reader approach confirmed at M2. |

### AC-3 Accounts

"Guests" in S2 AC-3 is read as logged-out visitors (C-01).

| ID | Source | Criterion | Preconditions | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|---|
| AC-3.1 | S2 AC-3; RS FR-AUTH-001, FR-AUTH-002 | A new reader registers and gets a verification email | New synthetic address in the team test mailbox (FX-USR pattern) | T: register with email and password | Account created; verification email received | P1 | CONFIRMED | Profile step also applies (PROVISIONAL, PAC-02) |
| AC-3.2 | S2 AC-3; RS FR-READ-001 | After verification the reader can open a full issue | AC-3.1 done; email verified; profile complete (BR-003, PROVISIONAL) | T: open a full issue | The issue opens | P1 | CONFIRMED | OQ-29 for the profile condition |
| AC-3.3 | S2 AC-3; RS FR-AUTH-010, BR-002 | A logged-out visitor is asked to sign in | Signed out | T: try to open and to download an issue | A sign-in prompt; no issue content | P1 | CONFIRMED | C-01, DEC-007 |
| AC-3.4 | S2 AC-3; RS FR-AUTH-010 | An unverified reader is asked to verify | FX-USR-02 signed in | T: try to open and to download an issue | A prompt; no issue content | P1 | CONFIRMED | — |
| AC-3.5 | S2 AC-3; RS NFR-SEC-002 | A direct request for the PDF is refused | Signed out, and separately as FX-USR-02 | T: request the issue file directly, without the app's grant flow (SEC-CHK-02) | Refused; no file content returned | P1 | CONFIRMED | Mechanism: DEC-020 |
| AC-3.6 | S2 AC-3; RS FR-AUTH-004 | Password reset works | FX-USR-01 | T: request a reset, set a new password, sign in | Sign-in succeeds with the new password | P1 | CONFIRMED | — |
| AC-3.7 | S2 AC-3; RS FR-AUTH-009, FR-PRIV-003 | Deleting the account removes the reader's data | FX-USR-07 with bookmarks, favourites and preferences | T: delete in the app; then inspect the server | The account cannot sign in. No profile, bookmarks, favourites or preferences remain. | P1 | CONFIRMED | Records kept after deletion: OQ-24 |

### AC-4 Offline downloads

| ID | Source | Criterion | Preconditions | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|---|
| AC-4.1 | S2 AC-4; RS FR-DL-005 | Download shows progress | FX-USR-01; Wi-Fi | T: start a download | Progress is visible and advances to completion | P1 | CONFIRMED | — |
| AC-4.2 | S2 AC-4; RS FR-DL-007 | A downloaded issue reads fully in airplane mode | Issue downloaded | T: enable airplane mode; open and page through to the last page | Every page opens | P1 | CONFIRMED | Reading model: OQ-08 |
| AC-4.3 | S2 AC-4; RS FR-DL-006 | A download resumes after a network break | Download of FX-PDF-05 in progress | T: FX-NET-01 at around 50%; restore the network | Continues from the previous progress, not from zero, and completes | P1 | CONFIRMED | Mechanism: DEC-020 |
| AC-4.4 | S2 AC-4; RS FR-DL-003 | File size is shown before download | Issue details screen | I | Size shown, and matches the file | P1 | CONFIRMED | Shown before sign-in? OQ-13 |
| AC-4.5 | S2 AC-4; RS FR-DL-004 | Warning on mobile data | Device on mobile data only | T: start a download | Warning appears before the download starts | P1 | CONFIRMED | — |
| AC-4.6 | S2 AC-4; RS FR-DL-009 | Deleting a download frees its space | Issue downloaded; note the app's storage in OS settings | T: delete from the Downloads screen; re-check storage | Storage drops by about the file size | P1 | CONFIRMED | — |
| AC-4.7 | S2 Flow 3; RS FR-DL-008 | Downloads screen lists downloaded issues | Two issues downloaded | I | Both listed; partial downloads not listed | P1 | CONFIRMED (S2 flow; not in the AC-4 text) | — |

### AC-5 Bookmarks and favourites

| ID | Source | Criterion | Preconditions | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|---|
| AC-5.1 | S2 AC-5; RS FR-BKM-001, FR-BKM-002 | A bookmark opens the issue at its page | FX-USR-01; issue open at page 7 | T: bookmark; close; open the bookmark | Opens at page 7 | P1 | CONFIRMED | — |
| AC-5.2 | S2 AC-5; RS FR-BKM-003 | Favourites update at once | FX-USR-01 | T: mark and unmark a favourite | The change shows immediately | P1 | CONFIRMED | Incomplete access: OQ-12 |
| AC-5.3 | S2 AC-5; RS FR-BKM-004 | Both appear on a second device | FX-LIB-01 on device A | T: sign in as the same reader on device B | Same bookmarks and favourites | P1 | CONFIRMED | Offline changes: OQ-10 |
| AC-5.4 | S2 AC-5; RS FR-BKM-005, NFR-SEC-005 | A reader cannot see another reader's items | FX-LIB-01 (reader A) and FX-LIB-02 (reader B) | T: as B, inspect lists and attempt direct reads of A's records (SEC-CHK-05) | B sees none of A's items; direct reads refused | P1 | CONFIRMED | — |

### AC-6 Sharing

| ID | Source | Criterion | Preconditions | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|---|
| AC-6.1 | S2 AC-6; RS FR-SHR-001 | Sharing an issue opens the share sheet | Issue details | T: tap share | Share sheet with the title and a link | P1 | CONFIRMED | Link target: PAC-05, OQ-15. Logged-out: OQ-09. |
| AC-6.2 | S2 AC-6; RS FR-SHR-003 | Sharing an article opens the share sheet | Article open | T: tap share | Share sheet with the title and a link | P1 | CONFIRMED | — |

### AC-7 News

| ID | Source | Criterion | Preconditions | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|---|
| AC-7.1 | S2 AC-7; RS FR-NEWS-001 | News list shows the latest posts | MFW's site reachable (OQ-39), or FX-WP-01 | T: open News | Posts show image, title, date and category, newest first | P1 | CONFIRMED | — |
| AC-7.2 | S2 AC-7; RS FR-NEWS-004 | A new post appears after a refresh | A new post published on WordPress (by MFW), or a fixture update | T: refresh | The new post is listed | P1 | CONFIRMED | Needs MFW cooperation on the live site |
| AC-7.3 | S2 AC-7; RS FR-NEWS-003 | Category filters work | At least two categories with posts | T: select each category | Only that category's posts | P1 | CONFIRMED | Categories selected by MFW (RS INT-WP-003) |
| AC-7.4 | S2 AC-7; RS FR-NEWS-005 | Loaded articles stay readable offline, with a notice | Articles opened online | T: airplane mode; open the same articles | Readable, with an offline notice | P1 | CONFIRMED | Save model: OQ-16 |
| AC-7.5 | S2 Scope included: News; RS FR-NEWS-002 | An article page shows the post's content | Online | T: open an article | Content shown; scripts do not run (SEC-CHK-15) | P1 | CONFIRMED (scope item) | Embedded media: OQ-16 |

### AC-8 Admin panel

| ID | Source | Criterion | Preconditions | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|---|
| AC-8.1 | S2 AC-8; RS FR-ADMIN-002 | A wrong password is refused | FX-USR-08 (admin) | T: sign in with a wrong password | Refused | P1 | CONFIRMED | Further measures: OQ-20 |
| AC-8.2 | S2 AC-8; RS FR-ADMIN-003 | A non-admin account is refused | FX-USR-01 (reader) | T: sign in to the admin panel; call an admin operation directly (SEC-CHK-06) | Both refused | P1 | CONFIRMED | — |
| AC-8.3 | S2 AC-8; RS FR-ADMIN-005 | A valid PDF uploads | FX-ADM-01 | T: upload the PDF, cover and details | Issue created, unpublished, with a success message | P1 | CONFIRMED | — |
| AC-8.4 | S2 AC-8; RS FR-ADMIN-006 | A renamed non-PDF is rejected | FX-PDF-08, FX-PDF-09 | T: upload each | Rejected with a clear message | P1 | CONFIRMED | — |
| AC-8.5 | S2 AC-8; RS FR-ADMIN-007 | An oversized file is rejected | FX-PDF-07; FX-PDF-06 as the boundary | T: upload each | FX-PDF-07 rejected with a clear message. FX-PDF-06 handled as OQ-30 decides. | P1 | CONFIRMED (boundary BLOCKED) | OQ-30 |
| AC-8.6 | S2 AC-8; RS FR-ADMIN-010 | Categories show correctly in the app | Admin creates or renames a category | T: refresh the app | The change shows | P1 | CONFIRMED | — |
| AC-8.7 | S2 AC-8; RS FR-ADMIN-011, FR-MAG-008 | Publishing and unpublishing show correctly | FX-ISS-08 | T: publish, refresh, unpublish, refresh | Appears, then disappears | P1 | CONFIRMED | Downloaded copies after unpublishing: OQ-11 |
| AC-8.8 | S2 AC-8; RS FR-ADMIN-013, FR-NEWS-008 | Hidden news posts are not shown | A post visible in the app | T: hide it in the admin panel; refresh the app | The post is gone | P1 | CONFIRMED | — |
| AC-8.9 | S2 AC-8; RS FR-USER-001 | The subscriber list exports to CSV | FX-USR set with sign-ups | T: export | CSV with the expected rows and only the approved fields | P1 | **CONFLICT C-02** | What "subscriber list" means: OQ-31 |

### AC-9 Notifications

| ID | Source | Criterion | Preconditions | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|---|
| AC-9.1 | S2 AC-9; RS FR-NOTIF-001 | The app explains notifications before the system prompt | Fresh install | T: first launch through to the permission step | Explanation shown before the OS prompt | P1 | CONFIRMED | — |
| AC-9.2 | S2 AC-9; RS FR-NOTIF-004 | A category notification reaches only devices that chose it | Device A opted into "new issues"; device B not | T: admin sends to "new issues" | A receives it; B does not | P1 | CONFIRMED | Categories: OQ-18 |
| AC-9.3 | S2 AC-9; RS FR-NOTIF-005, BR-005 | Tapping opens the linked issue or article | FX-NTF-01, FX-NTF-02; also FX-NTF-07 while signed out | T: tap each | Opens the target. For FX-NTF-07, a sign-in prompt instead of the issue. | P1 | CONFIRMED (BR-005 is an ASSUMPTION) | — |
| AC-9.4 | S2 AC-9; RS FR-ADMIN-018 | The send log records each send | Two sends | I: open the send log | Both recorded | P1 | CONFIRMED | Fields: OQ-19 |
| AC-9.5 | S2 AC-9; RS FR-ADMIN-017 | Only admins can send | FX-USR-01 | T: attempt a send directly (SEC-CHK-06) | Refused | P1 | CONFIRMED | — |
| AC-9.6 | S2 AC-9; RS NFR-REL-003 | Delivery time is not guaranteed | — | I: delivery times are recorded, not judged | Recorded | P1 | CONFIRMED | — |

### AC-10 Testing

| ID | Source | Criterion | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|
| AC-10.1 | S2 AC-10 | A test plan is run, with results recorded for every criterion | I: Section 9 and the evidence records | Every AC and approved PAC row has a recorded result | P1 | CONFIRMED | — |
| AC-10.2 | S2 AC-10; RS NFR-COMP-003 | The test phones are agreed at M1 | R | Device list recorded (`TESTING_STRATEGY.md` §6) | P1 | CONFIRMED | OQ-26 |
| AC-10.3 | S2 AC-10; RS NFR-SEC-010 | The security checklist is completed | I | Every SEC-CHK item in `TESTING_STRATEGY.md` §9 is recorded | P1 | CONFIRMED (checklist contents PROPOSED) | Both developers agree the checklist |
| AC-10.4 | S2 AC-10; RS NFR-REL-002 | No critical or high defect is open when acceptance testing starts | I: defect list | Zero open critical or high defects | P1 | CONFIRMED | — |

### AC-11 Release

| ID | Source | Criterion | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|
| AC-11.1 | S2 AC-11; RS NFR-MAINT-003 | Signed Android and iOS builds are made from tagged source code | I: tag, build logs, signatures | Both builds trace to one release tag and are signed | P1 | CONFIRMED | Signing set-up in MFW's accounts |
| AC-11.2 | S2 AC-11 | Store listings carry text approved by MFW | R | MFW's written approval recorded | P1 | CONFIRMED | — |
| AC-11.3 | S2 AC-11; RS NFR-PRIV-002 | The privacy details in both stores match MFW's privacy policy | I | Side-by-side comparison, with no mismatch | P1 | CONFIRMED | OQ-44 |
| AC-11.4 | S2 AC-11; RS INT-STORE-001 | Both builds are submitted, and MFW receives the confirmations | I | Submission confirmations held by MFW | P1 | CONFIRMED | Store accounts: OQ-42 |

### AC-12 Handover

| ID | Source | Criterion | Verification | Pass condition | Priority | Status | Clarification |
|---|---|---|---|---|---|---|---|
| AC-12.1 | S2 AC-12; RS NFR-MAINT-001 | Source code with history is in a repository owned by MFW | I | The repository is under MFW's ownership, with full history | P1 | CONFIRMED | Repository is currently under the `sanikaattarde` account: OQ-48 |
| AC-12.2 | S2 AC-12; RS NFR-MAINT-002 | Following the written documentation, the developer builds the app and deploys the backend from a clean copy into a fresh project | D | Build and deployment succeed from a clean clone into a fresh project | P1 | CONFIRMED. S2 names a "fresh Firebase project" (C-05). | DEC-003 |
| AC-12.3 | S2 AC-12; RS NFR-SEC-012 | Credentials are held by MFW | I: credential-holder record | MFW holds every credential. The record contains no secret values. | P1 | CONFIRMED | — |

## 6. Proposed Criteria

PAC-01 to PAC-11 are from RS §10.2. They are summarised here, and RS holds the full text.

| ID | Source | Criterion (summary) | Verification | Priority | Status | Clarification |
|---|---|---|---|---|---|---|
| PAC-01 | RS §10.2; FR-AUTH-005 | A new reader registers with Google on Android and iOS, completes the profile, opens a full issue, and sees the same items on a second device | T | P2 | PROPOSED; PROVISIONAL (C-04) | OQ-03, OQ-04, OQ-29 |
| PAC-02 | RS §10.2; FR-PROF-001, BR-003 | Registration needs every mandatory field. An incomplete profile is prompted before a full issue opens. | T | P2 | PROPOSED; PROVISIONAL | OQ-01, OQ-02, OQ-29 |
| PAC-03 | RS §10.2; FR-USER-002, FR-USER-003 | Admin sees and exports registered users with profile fields; non-admins cannot | T | P2 | PROPOSED; PROVISIONAL | OQ-01, OQ-29 |
| PAC-04 | RS §10.2; BR-001 | A logged-out visitor can browse, search, filter and read news, but cannot open or download any issue content, including any sample | T | P2 | PROPOSED; PROVISIONAL (C-01) | OQ-29 |
| PAC-05 | RS §10.2; FR-SHR-002, FR-SHR-004 | Issue shares link to the store listing; article shares link to the WordPress address | T | P2 | PROPOSED; PROVISIONAL | OQ-15, OQ-29 |
| PAC-06 | RS §10.2; FR-PRIV-003 | After deletion, the reader cannot sign in and is absent from the admin list and new exports | T | P2 | PROPOSED | OQ-24 |
| PAC-07 | RS §10.2; FR-SRCH-003 | The industry-segment filter returns the right issues | T | P3 | PROPOSED | OQ-13 |
| PAC-08 | RS §10.2; FR-PRIV-001, FR-PRIV-002 | Registration links the policy and terms and requires agreement. Both can be opened later. | T | P2 | PROPOSED | OQ-27 |
| PAC-09 | RS §10.2; NFR-PRIV-003 | No configured usage event records which reader opened which issue or page | I | P2 | PROPOSED; PROVISIONAL | OQ-23 |
| PAC-10 | RS §10.2; FR-STATE-001 to 007 | Loading, empty and error states match the screens approved at M2 | D | P3 | PROPOSED | ASM-13 |
| PAC-11 | RS §10.2; FR-EMAIL-001, FR-EMAIL-002 | If kept: opt in, appear in the export, opt out, disappear | T | P3 | PROPOSED; CONFLICT C-02 | OQ-31 |
| PAC-12 | New. RS FR-AUTH-006, FR-AUTH-007 | The rule for an email address used with both sign-in methods, and the verification rule for Google accounts, behave as decided. Test with FX-USR-11. | T | P2 | PROPOSED; BLOCKED | OQ-04, OQ-05 |
| PAC-13 | New. RS NFR-SEC-002; DEC-009 | An issue-file request is refused when signed out, unverified, profile incomplete, using another reader's grant, using an expired grant, or using a guessed storage path. A valid grant for a full-access reader succeeds. (SEC-CHK-02, SEC-CHK-03) | T | P2 | PROPOSED | DEC-020, OQ-37 |
| PAC-14 | New. RS FR-DL-010 | Downloaded issues after sign-out, account deletion, or unpublishing behave as decided | T | P2 | PROPOSED; BLOCKED | OQ-11 |
| PAC-15 | New. Store policy | If confirmed as required, readers can request account deletion through a web link outside the app, as declared to Google Play | I | P2 | PROPOSED; BLOCKED | OQ-45 |

## 7. Ambiguous or Conflicting Criteria

| Criterion | Issue | Effect | Resolved by |
|---|---|---|---|
| AC-3 "Guests" | S2 included guest browsing with a public sample. The working position has no guest reading (C-01). | Rows test logged-out visitors. PAC-04 adds the "no sample" check. | OQ-29 |
| AC-8 "subscriber list" | Edition-update list or registered-user list? (C-02) | AC-8.9 cannot be passed until defined | OQ-31 |
| AC-8 oversized file | "Up to" versus "under" 150 MB, and whether MB means 10⁶ or 2²⁰ bytes (C-06) | The boundary file FX-PDF-06 has no agreed expected result | OQ-30 |
| AC-2 targets | Confirmed at the end of Week 2 after tests on MFW's PDFs [S2] | The targets may be adjusted with MFW | T-02.3 |
| AC-12 "fresh Firebase project" | The architecture is not approved (C-05) | The wording may need amending if DEC-003 differs | OQ-35 |
| AC-3 and the profile | S2 AC-3 has no profile step. BR-003 adds one (PROVISIONAL). | AC-3.2 includes the profile precondition, marked PROVISIONAL | OQ-29 |
| AC-4 and online reading | CH §8 "online reading" versus S2 download-first (C-03) | AC-4.2 assumes a complete local copy | OQ-08 |

## 8. Coverage Check

| RS area | Covered by |
|---|---|
| §5.1 Authentication | AC-3.1 to AC-3.7, PAC-01, PAC-12 |
| §5.2 Mandatory profile | PAC-02, PAC-03 |
| §5.3 Catalogue | AC-1.1, AC-1.4, AC-8.7, PAC-04 |
| §5.4 Search and filters | AC-1.2, AC-1.3, PAC-07 |
| §5.5 Reading | AC-2.1 to AC-2.7, AC-3.2 |
| §5.6 Downloads | AC-4.1 to AC-4.7, PAC-13, PAC-14 |
| §5.7 Bookmarks and favourites | AC-5.1 to AC-5.4 |
| §5.8 News | AC-7.1 to AC-7.5, AC-8.8 |
| §5.9 Sharing | AC-6.1, AC-6.2, PAC-05 |
| §5.10 Notifications | AC-9.1 to AC-9.6 |
| §5.11 Edition-update emails | AC-8.9, PAC-11 (CONFLICT) |
| §5.12 Admin | AC-8.1 to AC-8.8 |
| §5.13 User administration | AC-8.9, PAC-03, PAC-06 |
| §5.14 States | PAC-10 |
| §5.15 Privacy and deletion | AC-3.7, PAC-06, PAC-08, PAC-15 |
| §6.3 Security | AC-3.5, AC-5.4, AC-8.2, AC-9.5, AC-10.3, PAC-13 |
| §6.1 and §6.2 Performance and reliability | AC-2.1, AC-2.3, AC-2.5, AC-10.4 |
| §6.6 Compatibility | AC-10.2 |
| §6.8 Maintainability | AC-11.1, AC-12.1 to AC-12.3 |

## 9. Results Record

No criterion has been run. Results are recorded here, or in linked evidence reports (`TESTING_STRATEGY.md` §13), once testing starts.

| ID | Build | Device and OS | Date | Tester | Result | Evidence | Defects |
|---|---|---|---|---|---|---|---|
| — | — | — | — | — | Not run | — | — |
