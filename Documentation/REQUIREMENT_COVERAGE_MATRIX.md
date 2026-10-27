# Requirement Coverage Matrix: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Requirement Coverage Matrix |
| File | `Documentation/REQUIREMENT_COVERAGE_MATRIX.md` |
| Version | 0.2 |
| Status | Draft for review. Not approved. **DERIVED: this matrix repeats what other documents say and is not a source of truth. Nothing has been tested.** |
| Date | 27 October 2026 |
| Audience | The two developers, when they plan tests and review the acceptance criteria. |
| Proposed owner | Yuvraj (WS-B), PROPOSED and not agreed. Reviewer: Sanika Attarde (WS-A). |
| Approval required | Both developers. MFW only if a candidate check later becomes a numbered PAC row, because a PAC row is not contractual until MFW approves it in writing. |
| Sources | RS §13 (requirements, status and verification); `ACCEPTANCE_CRITERIA.md` §5, §6, §8; `TESTING_STRATEGY.md` §7, §8, §9, §16; `SECURITY_AND_ACCESS_CONTROL.md` §6.3; `API_AND_BACKEND_CONTRACT.md` §3 to §6; `API_AND_MODULE_CONTRACTS.md` §6, §7 |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 24 October 2026 | Initial draft. Read from the documents of commit 5a436a3 (pull request 3, which has since reached `main` by a direct push on 2026-10-25, with no review by a person; see `CHANGELOG.md`, Repository History), so the identifiers it cites are those of that commit. |
| 0.2 | 27 October 2026 | Rows for FR-ADMIN-004, FR-USER-001, FR-USER-005, FR-PRIV-003, FR-DL-010 and NFR-COMP-003 updated by hand for the positions of 26 and 27 October 2026 (PAC-19 and PAC-20 added, OP-13 withdrawn, OP-33 and the edition-update rows dropped on the working position). The matrix was not regenerated, so other rows still show the identifiers of the earlier documents. The stale sentence about pull request 3 in section 6 is corrected. No requirement status changed. |

### 1.1 Related documents

| Document | Status on 24 October 2026 |
|---|---|
| `REQUIREMENTS_SPECIFICATION.md` (RS) §13 | Exists, draft. **Owns** the requirement list, each status and each verification method. This matrix does not replace it |
| `ACCEPTANCE_CRITERIA.md` | Exists (draft). **Owns** the AC and PAC rows |
| `TESTING_STRATEGY.md`, `TEST_DATA_AND_FIXTURES.md` | Exist (draft). Own the test plans and fixtures |
| `SECURITY_AND_ACCESS_CONTROL.md` | Exists (draft). Owns the security controls (SC-nn) and tests (ST-nn) |
| `API_AND_BACKEND_CONTRACT.md`, `API_AND_MODULE_CONTRACTS.md` | Exist (draft). Own the operations (OP-nn) and modules (MOD-nn) |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal in this document. In RS terms it is an ASSUMPTION (DEV). **NOT TESTED** means that no test has been written or run.

## 2. Purpose, Scope, Method and Limits

**Purpose.** The chain from a requirement to evidence is defined in `TESTING_STRATEGY.md` §13: requirement, then acceptance row, then test suite, then evidence record. The acceptance criteria are traced to the specification by area (`ACCEPTANCE_CRITERIA.md` §8). This matrix goes one step further and shows, for each requirement, which rows and plans name it, so that a requirement with no test is visible.

**Scope.** The 166 functional and non-functional requirements (FR-* and NFR-*) listed in RS §13. Interface, data and business-rule requirements (INT, DATA, BR) are out of scope for this version.

```text
How the matrix was made
├── The requirement list, status and verification method are read from RS §13
├── An AC or PAC row "names" a requirement when the requirement's ID is in the row's Source cell
├── A test plan "names" it when its ID is in TESTING_STRATEGY §7, §8, §9 or §16, in a security checklist item (SEC-CHK-nn), or in a security control whose tests are ST-nn
├── A design anchor is an operation (OP-nn), a module (MOD-nn) or a security control (SC-nn) whose block or row names the requirement
└── Ranges such as "FR-PROF-002 to 007" are expanded. Everything else is a literal match
```

**Limits.** These limits mean the matrix can understate coverage. It cannot show that a row tests a requirement well.

- A requirement covered only in the prose of a criterion, and not in the Source cell, is not seen as named.
- Data-model entities and the architecture document are not scanned for design anchors. A requirement with no anchor here may still be anchored there.
- A row that names a requirement is taken to cover it. Whether its pass condition is enough is a review question and not a matter of identifiers.
- The program that read the documents is not part of the repository, because this is a documentation stage with no tooling. The rules above are complete enough to repeat the reading by search (RC-03).

### 2.1 States

| State | Meaning |
|---|---|
| COVERED | An AC or PAC row names the requirement in its Source cell |
| RS CLAIM | RS §13 says an AC family or PAC verifies the requirement, but no row names it. The link is claimed and not shown at row level |
| PLAN ONLY | A test plan, a security checklist item or a security test names it, and no AC or PAC row does |
| REVIEW | RS §13 gives only inspection, demonstration or review as the method, and no row names it. A test row is not expected by RS's own method |
| AREA ONLY | RS §13 expects a test, no row or plan names the requirement, and its RS area appears in the coverage table of `ACCEPTANCE_CRITERIA.md` §8 |
| NO ROW | RS §13 expects a test, no row or plan names the requirement, and its area is not in that coverage table |

AREA ONLY and NO ROW are the two states that need action. They carry a candidate check. A candidate check is PROPOSED, has no AC or PAC number, and is not contractual.

## 3. Summary

```text
Requirements: 166 (121 FR, 45 NFR)
├── COVERED     95
├── RS CLAIM    19
├── PLAN ONLY   11
├── REVIEW      33
├── AREA ONLY    5
└── NO ROW       3
```

| RS area | Requirements | COVERED | RS CLAIM | PLAN ONLY | REVIEW | AREA ONLY | NO ROW |
|---|---|---|---|---|---|---|---|
| 5.1 Authentication and account lifecycle | 10 | 9 | 0 | 0 | 0 | 1 | 0 |
| 5.2 Mandatory reader profile | 7 | 1 | 3 | 0 | 2 | 1 | 0 |
| 5.3 Public catalogue and magazine metadata | 9 | 4 | 1 | 0 | 3 | 1 | 0 |
| 5.4 Search, filters, categories, years and editions | 7 | 5 | 1 | 1 | 0 | 0 | 0 |
| 5.5 Magazine reading experience | 10 | 8 | 1 | 0 | 1 | 0 | 0 |
| 5.6 PDF handling and offline downloads | 10 | 8 | 2 | 0 | 0 | 0 | 0 |
| 5.7 Bookmarks and favourites | 8 | 5 | 0 | 0 | 2 | 1 | 0 |
| 5.8 News and WordPress integration | 9 | 6 | 1 | 0 | 2 | 0 | 0 |
| 5.9 Sharing | 6 | 4 | 0 | 1 | 1 | 0 | 0 |
| 5.10 Push notifications and notification preferences | 7 | 3 | 1 | 0 | 2 | 1 | 0 |
| 5.11 Edition-update email sign-up | 3 | 2 | 0 | 0 | 1 | 0 | 0 |
| 5.12 Admin panel and content management | 19 | 12 | 2 | 0 | 5 | 0 | 0 |
| 5.13 User administration and reporting | 5 | 3 | 0 | 0 | 2 | 0 | 0 |
| 5.14 Error, empty, loading and recovery states | 7 | 7 | 0 | 0 | 0 | 0 | 0 |
| 5.15 Account privacy, consent and deletion | 4 | 3 | 0 | 1 | 0 | 0 | 0 |
| 6.1 and 6.2 Performance and reliability | 5 | 5 | 0 | 0 | 0 | 0 | 0 |
| 6.3 Security and access control | 12 | 4 | 1 | 6 | 1 | 0 | 0 |
| 6.4 Privacy and data minimisation | 6 | 2 | 1 | 1 | 2 | 0 | 0 |
| 6.5 Accessibility and usability | 4 | 0 | 0 | 0 | 4 | 0 | 0 |
| 6.6 Compatibility and supported devices | 5 | 1 | 2 | 0 | 2 | 0 | 0 |
| 6.7 Storage and bandwidth | 3 | 0 | 0 | 0 | 1 | 0 | 2 |
| 6.8 Maintainability and observability | 8 | 3 | 2 | 1 | 1 | 0 | 1 |
| 6.9 Offline behaviour | 2 | 0 | 1 | 0 | 1 | 0 | 0 |
| **All** | **166** | **95** | **19** | **11** | **33** | **5** | **3** |

```text
Flagged for a candidate check (AREA ONLY and NO ROW): 8
└── FR-AUTH-008, FR-PROF-007, FR-MAG-003, FR-BKM-007, FR-NOTIF-003, NFR-STOR-001, NFR-STOR-002, NFR-OBS-001

RS CLAIM, with no row-level link: 19
└── FR-PROF-002, FR-PROF-003, FR-PROF-004, FR-MAG-001, FR-SRCH-006, FR-READ-002, FR-DL-001, FR-DL-002, FR-NEWS-007, FR-NOTIF-002, FR-ADMIN-009, FR-ADMIN-016, NFR-SEC-007, NFR-PRIV-004, NFR-COMP-001, NFR-COMP-002, NFR-MAINT-004, NFR-OBS-002, NFR-OFF-001
```

**What the summary shows.**

```text
Findings (from the tables below)
├── Eight requirements are expected to have a test by RS §13, and no row, plan or security test names them (AREA ONLY and NO ROW)
│   ├── FR-MAG-003 is CONFIRMED from S1, yet the pass condition of AC-1.1 lists only cover, title, date and description
│   └── NFR-STOR-001: the largest and near-limit files are used in AC-2.1 and AC-4.3, but those rows do not name the requirement
├── Nineteen requirements are RS CLAIM: RS §13 cites an AC family or PAC and no row names them. This is a documentation fix: name the requirement in the row, or correct RS §13
│   └── Example: FR-NOTIF-002 (choose categories) cites AC-9. AC-9.2 tests delivery to a device that chose a category, and the choice is only its precondition
├── Thirty-three requirements are verified by review, inspection or demonstration. Most wait on an open question (OQ-nn) or on the M2 designs
└── Six of the twelve NFR-SEC items are PLAN ONLY: the security checklist (SEC-CHK-nn) names them and no acceptance row does
```

## 4. How to Read the Tables

| Column | Contents |
|---|---|
| ID, Requirement, Status | From RS §13. The status is RS's (CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN, CONFLICT) |
| AC or PAC | The rows that name the requirement. "RS:" means RS §13 cites an AC family or PAC and no row names it. "none" means neither |
| Test plan | `TESTING_STRATEGY.md` sections (as "TS 7.5"), security checklist items (SEC-CHK-nn) and security tests (ST-nn) that name the requirement. A plan that names only the AC row, for example §7.5 naming AC-4.3, is not shown |
| Design | Operations (OP-nn), modules (MOD-nn) and security controls (SC-nn) that name the requirement |
| State | One of the six states in Section 2.1 |
| Note | The RS method for REVIEW, the cited family for RS CLAIM, or a PROPOSED check for AREA ONLY and NO ROW |

Lists longer than a few items show the first items and a count, for example "(+3)". The full set is in the documents named in the column.

## 5. The Matrix

### 5.1 Authentication and account lifecycle

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-AUTH-001 | Register with email and password | CONFIRMED | AC-3.1, PAC-17 | ST-21 | MOD-03, SC-21 | COVERED | - |
| FR-AUTH-002 | Verification email after email registration | CONFIRMED | AC-3.1, PAC-17 | ST-21 | MOD-03, SC-21 | COVERED | - |
| FR-AUTH-003 | Sign in with email and password | CONFIRMED | PAC-17 | ST-21 | MOD-03, SC-21 | COVERED | - |
| FR-AUTH-004 | Reset a forgotten password | CONFIRMED | AC-3.6, PAC-17 | ST-21 | MOD-03, SC-21 | COVERED | - |
| FR-AUTH-005 | Register and sign in with Google Sign-In | PROVISIONAL | PAC-01 | none | MOD-03 | COVERED | - |
| FR-AUTH-006 | Rule for an email used with both sign-in methods | OPEN | PAC-12 | none | none | COVERED | - |
| FR-AUTH-007 | Email verification for Google accounts | OPEN | PAC-12 | none | none | COVERED | - |
| FR-AUTH-008 | Sign out | ASSUMPTION | none | none | MOD-03 | AREA ONLY | PROPOSED check: sign out, then try to open a full issue. Expect the sign-in prompt. What happens to downloads follows OQ-11 |
| FR-AUTH-009 | Delete account in the app | CONFIRMED | AC-3.7 | ST-14 | OP-12, OP-13, MOD-03, SC-17 | COVERED | - |
| FR-AUTH-010 | Sign-in prompt when a full issue is refused | CONFIRMED | AC-3.3, AC-3.4 | none | OP-11, MOD-01 | COVERED | - |

### 5.2 Mandatory reader profile

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-PROF-001 | Registration needs every mandatory profile field | PROVISIONAL | PAC-02 | none | OP-02, OP-10, MOD-04 | COVERED | - |
| FR-PROF-002 | Mandatory fields: name, exact age, gender, occupation, domain of work | PROVISIONAL | RS: PAC-02 | none | OP-10, MOD-04 | RS CLAIM | RS §13 cites PAC-02. No row names this requirement |
| FR-PROF-003 | Google Sign-In readers complete the same profile | PROVISIONAL | RS: PAC-01 | none | OP-10, MOD-04 | RS CLAIM | RS §13 cites PAC-01. No row names this requirement |
| FR-PROF-004 | Profile completion prompt before a full issue | PROVISIONAL | RS: PAC-02 | none | OP-10, OP-11, MOD-01, MOD-04 | RS CLAIM | RS §13 cites PAC-02. No row names this requirement |
| FR-PROF-005 | Age collected with no age gate or parental consent | PROVISIONAL | none | none | OP-10, MOD-04 | REVIEW | RS method: R: MFW legal review (OQ-07) |
| FR-PROF-006 | Profile screen | CONFIRMED | none | none | OP-06, OP-10, MOD-04 | REVIEW | RS method: D |
| FR-PROF-007 | Reader can update profile fields | ASSUMPTION | none | none | OP-10, MOD-04 | AREA ONLY | PROPOSED check: change one profile field, then sign in on a second device. Expect the new value, validated as OQ-01 decides |

### 5.3 Public catalogue and magazine metadata

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-MAG-001 | Catalogue visible to every user | CONFIRMED | RS: AC-1, PAC-04 | none | OP-01, MOD-05 | RS CLAIM | RS §13 cites AC-1, PAC-04. No row names this requirement |
| FR-MAG-002 | Cover, title, date and description per issue | CONFIRMED | AC-1.1 | none | OP-01, OP-16, MOD-05 | COVERED | - |
| FR-MAG-003 | Category shown per issue | CONFIRMED | none | none | OP-01, OP-16, MOD-05 | AREA ONLY | PROPOSED check: expect each issue's category on the catalogue entry and on issue details. AC-1.1 does not list category in its pass condition |
| FR-MAG-004 | Latest issue and archive; four to six archive issues at launch | CONFIRMED | AC-1.1 | none | OP-01, OP-16, MOD-05 | COVERED | - |
| FR-MAG-005 | Issue details screen | CONFIRMED | none | none | OP-01, OP-16, MOD-05 | REVIEW | RS method: D |
| FR-MAG-006 | Home screen | CONFIRMED | none | none | OP-01, MOD-01, MOD-05 | REVIEW | RS method: D against the M2 designs |
| FR-MAG-007 | Published issue appears after pull-to-refresh | CONFIRMED | AC-1.4 | none | OP-01, OP-21, MOD-05 | COVERED | - |
| FR-MAG-008 | Unpublished issue disappears after refresh | CONFIRMED | AC-8.7 | none | OP-01, OP-15, OP-21, MOD-05 | COVERED | - |
| FR-MAG-009 | Public metadata field list | OPEN | none | none | OP-01 | REVIEW | RS method: R: resolve OQ-13 |

### 5.4 Search, filters, categories, years and editions

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-SRCH-001 | Search by title, description and category | CONFIRMED | AC-1.2 | none | OP-01, MOD-05 | COVERED | - |
| FR-SRCH-002 | Category filter | CONFIRMED | AC-1.3 | none | OP-01, MOD-05 | COVERED | - |
| FR-SRCH-003 | Industry segment filter | CONFIRMED | PAC-07 | none | OP-01, OP-28, MOD-05 | COVERED | - |
| FR-SRCH-004 | Year filter | CONFIRMED | AC-1.3 | none | OP-01, MOD-05 | COVERED | - |
| FR-SRCH-005 | Edition filter | CONFIRMED | AC-1.3 | none | OP-01, MOD-05 | COVERED | - |
| FR-SRCH-006 | Search and filters for logged-out visitors | ASSUMPTION | RS: PAC-04 | none | MOD-05 | RS CLAIM | RS §13 cites PAC-04. No row names this requirement |
| FR-SRCH-007 | Search covers metadata only | ASSUMPTION | none | TS 7.3 | MOD-05 | PLAN ONLY | In a test plan or security test. No AC or PAC row |

### 5.5 Magazine reading experience

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-READ-001 | Full issue only for signed-in, verified readers | CONFIRMED | AC-3.2 | none | OP-11 | COVERED | - |
| FR-READ-002 | Read from a complete downloaded copy | CONFIRMED | RS: AC-2, AC-4 | none | none | RS CLAIM | RS §13 cites AC-2, AC-4. No row names this requirement |
| FR-READ-003 | Swipe to turn pages | CONFIRMED | AC-2.2 | none | MOD-07 | COVERED | - |
| FR-READ-004 | Tap to turn pages | CONFIRMED | AC-2.2 | none | MOD-07 | COVERED | - |
| FR-READ-005 | Pinch zoom to 300% | CONFIRMED | AC-2.3 | none | MOD-07 | COVERED | - |
| FR-READ-006 | Page-turn effect, confirmed at M2 | CONFIRMED | AC-2.7 | none | MOD-07 | COVERED | - |
| FR-READ-007 | Plain swipe mode as the fallback | CONFIRMED | AC-2.7 | none | MOD-07 | COVERED | - |
| FR-READ-008 | Switching between reader modes | OPEN | none | none | none | REVIEW | RS method: R: resolve OQ-14 |
| FR-READ-009 | Two pages on tablets and in landscape | CONFIRMED | AC-2.4 | none | MOD-07 | COVERED | - |
| FR-READ-010 | Damaged file error with retry | CONFIRMED | AC-2.6 | none | MOD-06, MOD-07 | COVERED | - |

### 5.6 PDF handling and offline downloads

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-DL-001 | Download an issue to private storage | CONFIRMED | RS: AC-4 | none | MOD-06 | RS CLAIM | RS §13 cites AC-4. No row names this requirement |
| FR-DL-002 | No download without sign-in and a verified email | CONFIRMED | RS: AC-3 | none | OP-11 | RS CLAIM | RS §13 cites AC-3. No row names this requirement |
| FR-DL-003 | File size shown before download | CONFIRMED | AC-4.4 | none | MOD-06 | COVERED | - |
| FR-DL-004 | Mobile-data warning before download | CONFIRMED | AC-4.5 | none | MOD-01, MOD-06 | COVERED | - |
| FR-DL-005 | Download progress | CONFIRMED | AC-4.1 | none | MOD-06 | COVERED | - |
| FR-DL-006 | Resume after a network break | CONFIRMED | AC-4.3 | none | MOD-06 | COVERED | - |
| FR-DL-007 | Read a downloaded issue offline | CONFIRMED | AC-4.2 | none | MOD-06 | COVERED | - |
| FR-DL-008 | Downloads screen | CONFIRMED | AC-4.7 | none | MOD-06 | COVERED | - |
| FR-DL-009 | Delete a download and free its space | CONFIRMED | AC-4.6 | none | MOD-06 | COVERED | - |
| FR-DL-010 | Downloads after sign-out, deletion or unpublishing | OPEN | PAC-14, PAC-20 | none | OP-03, MOD-06 | COVERED | - |

### 5.7 Bookmarks and favourites

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-BKM-001 | Bookmark a page | CONFIRMED | AC-5.1 | none | OP-07, MOD-08 | COVERED | - |
| FR-BKM-002 | Open a bookmark at its page | CONFIRMED | AC-5.1 | none | OP-07, MOD-08 | COVERED | - |
| FR-BKM-003 | Mark and unmark favourites | CONFIRMED | AC-5.2 | none | OP-08, MOD-08 | COVERED | - |
| FR-BKM-004 | Bookmarks and favourites on a second device | CONFIRMED | AC-5.3 | none | OP-07, OP-08, MOD-08 | COVERED | - |
| FR-BKM-005 | Bookmarks and favourites are private | CONFIRMED | AC-5.4 | none | OP-07, OP-08 | COVERED | - |
| FR-BKM-006 | Bookmark and favourite list screens | CONFIRMED | none | none | OP-07, OP-08, MOD-08 | REVIEW | RS method: D |
| FR-BKM-007 | Remove a bookmark | ASSUMPTION | none | none | OP-07, MOD-08 | AREA ONLY | PROPOSED check: remove a bookmark, then look at the list and at a second device. Expect it gone on both |
| FR-BKM-008 | Offline bookmarks and favourites | OPEN | none | none | OP-07 | REVIEW | RS method: R: resolve OQ-10 |

### 5.8 News and WordPress integration

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-NEWS-001 | News list with image, title, date and category | CONFIRMED | AC-7.1 | none | MOD-09 | COVERED | - |
| FR-NEWS-002 | Article page | CONFIRMED | AC-7.5 | none | MOD-09 | COVERED | - |
| FR-NEWS-003 | News category filter | CONFIRMED | AC-7.3 | none | MOD-09 | COVERED | - |
| FR-NEWS-004 | New post appears after refresh | CONFIRMED | AC-7.2 | none | MOD-09 | COVERED | - |
| FR-NEWS-005 | Loaded articles readable offline with a notice | CONFIRMED | AC-7.4 | none | MOD-09 | COVERED | - |
| FR-NEWS-006 | How articles are kept for offline reading | OPEN | none | none | none | REVIEW | RS method: R: resolve OQ-16 |
| FR-NEWS-007 | News available to logged-out visitors | CONFIRMED | RS: PAC-04 | none | MOD-09 | RS CLAIM | RS §13 cites PAC-04. No row names this requirement |
| FR-NEWS-008 | Hidden posts not shown | CONFIRMED | AC-8.8 | none | OP-04, MOD-09 | COVERED | - |
| FR-NEWS-009 | Presentation of breaking posts | OPEN | none | none | OP-04, OP-23 | REVIEW | RS method: R: resolve OQ-17 |

### 5.9 Sharing

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-SHR-001 | Share an issue with title and link | CONFIRMED | AC-6.1 | none | MOD-10 | COVERED | - |
| FR-SHR-002 | Issue link points to the store listing | PROVISIONAL | PAC-05 | none | MOD-10 | COVERED | - |
| FR-SHR-003 | Share an article with title and link | CONFIRMED | AC-6.2 | none | MOD-10 | COVERED | - |
| FR-SHR-004 | Article link is the WordPress address | PROVISIONAL | PAC-05 | none | MOD-10 | COVERED | - |
| FR-SHR-005 | Shared links do not open the app | CONFIRMED | none | none | MOD-10 | REVIEW | RS method: I |
| FR-SHR-006 | Sharing never sends the PDF | ASSUMPTION | none | TS 7.10 | MOD-10 | PLAN ONLY | In a test plan or security test. No AC or PAC row |

### 5.10 Push notifications and notification preferences

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-NOTIF-001 | Explain notifications before the system prompt | CONFIRMED | AC-9.1 | none | MOD-11 | COVERED | - |
| FR-NOTIF-002 | Choose notification categories | CONFIRMED | RS: AC-9 | none | OP-05, OP-09, MOD-11 | RS CLAIM | RS §13 cites AC-9. No row names this requirement |
| FR-NOTIF-003 | Change category choices in settings | CONFIRMED | none | none | OP-09, MOD-11 | AREA ONLY | PROPOSED check: change the category choices after the first choice, then send to the old and the new category. Expect only the new choice to arrive |
| FR-NOTIF-004 | Category notifications reach only opted-in devices | CONFIRMED | AC-9.2 | none | MOD-11 | COVERED | - |
| FR-NOTIF-005 | Tap opens the linked issue or article | CONFIRMED | AC-9.3 | none | MOD-01, MOD-11 | COVERED | - |
| FR-NOTIF-006 | Categories: new issues, expo specials, major news | CONFIRMED | none | none | OP-05, OP-28 | REVIEW | RS method: I against the OQ-18 decision |
| FR-NOTIF-007 | Notifications for logged-out visitors | OPEN | none | none | OP-09 | REVIEW | RS method: R: resolve OQ-09 |

### 5.11 Edition-update email sign-up

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-EMAIL-001 | Optional edition-update email sign-up | CONFLICT | PAC-11 | none | OP-33 | COVERED | Dropped on the working position (GS-Q49) |
| FR-EMAIL-002 | Withdraw from the edition-update list | ASSUMPTION | PAC-11 | none | none | COVERED | Dropped on the working position (GS-Q49) |
| FR-EMAIL-003 | No email sending or email-marketing integration | ASSUMPTION | none | none | none | REVIEW | RS method: I |

### 5.12 Admin panel and content management

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-ADMIN-001 | Admin panel is the only web interface | CONFIRMED | none | none | none | REVIEW | RS method: I |
| FR-ADMIN-002 | Admin sign-in refuses wrong passwords | CONFIRMED | AC-8.1 | TS 9, SEC-CHK-08, ST-01 | MOD-12, SC-01 | COVERED | - |
| FR-ADMIN-003 | Non-admin accounts refused | CONFIRMED | AC-8.2 | TS 9, SEC-CHK-06, SEC-CHK-18, ST-02 (+1) | OP-14, OP-35, MOD-12, SC-02 (+1) | COVERED | - |
| FR-ADMIN-004 | One admin role | CONFIRMED | PAC-19 | ST-02 (+1) | OP-35, OP-37, MOD-12, SC-09 | COVERED | Updated by hand for GS-Q44 |
| FR-ADMIN-005 | Upload PDF and cover | CONFIRMED | AC-8.3 | none | OP-19, MOD-12 | COVERED | - |
| FR-ADMIN-006 | Reject non-PDF files | CONFIRMED | AC-8.4 | ST-13 | OP-20, OP-40, MOD-12, SC-08 | COVERED | - |
| FR-ADMIN-007 | Reject PDFs over the size limit | CONFIRMED | AC-8.5 | none | OP-19, OP-40, MOD-12 | COVERED | - |
| FR-ADMIN-008 | Cover image checks | OPEN | none | none | OP-19, OP-40, MOD-12 | REVIEW | RS method: R: resolve OQ-22 |
| FR-ADMIN-009 | Enter and edit issue details | CONFIRMED | RS: AC-1, AC-8 | none | OP-15, OP-16, MOD-12 | RS CLAIM | RS §13 cites AC-1, AC-8. No row names this requirement |
| FR-ADMIN-010 | Create and maintain categories | CONFIRMED | AC-8.6 | none | OP-17, MOD-12 | COVERED | - |
| FR-ADMIN-011 | Publish and unpublish issues | CONFIRMED | AC-8.7 | none | OP-21, MOD-12 | COVERED | - |
| FR-ADMIN-012 | Delete an issue or replace its PDF | OPEN | none | none | OP-19, OP-30, OP-40 | REVIEW | RS method: R: resolve OQ-21 |
| FR-ADMIN-013 | Hide a WordPress post | CONFIRMED | AC-8.8 | none | OP-23, OP-24, MOD-12 | COVERED | - |
| FR-ADMIN-014 | Mark a post as breaking | CONFIRMED | AC-9.7 | TS 7.8 | OP-23, OP-24, MOD-12 | COVERED | - |
| FR-ADMIN-015 | Send a post as a breaking-news notification | CONFIRMED | AC-9.7 | TS 7.8 | OP-24, OP-25, MOD-12 | COVERED | - |
| FR-ADMIN-016 | Send a category notification | CONFIRMED | RS: AC-9 | none | OP-25, MOD-11, MOD-12 | RS CLAIM | RS §13 cites AC-9. No row names this requirement |
| FR-ADMIN-017 | Only admins send notifications | CONFIRMED | AC-9.5 | none | OP-25, MOD-11, MOD-12 | COVERED | - |
| FR-ADMIN-018 | Send log | CONFIRMED | AC-9.4 | none | OP-25, OP-27, MOD-11, MOD-12 | COVERED | - |
| FR-ADMIN-019 | No news authoring in the admin panel | CONFIRMED | none | none | MOD-09, MOD-12 | REVIEW | RS method: I |

### 5.13 User administration and reporting

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-USER-001 | Export the subscriber list to CSV | CONFLICT | AC-8.9 | none | OP-33, MOD-12 | COVERED | Dropped on the working position (GS-Q49) |
| FR-USER-002 | View registered users with profiles | PROVISIONAL | PAC-03 | ST-15 | OP-31, MOD-12, SC-15 | COVERED | - |
| FR-USER-003 | Export registered users to CSV | PROVISIONAL | PAC-03 | ST-15 | OP-32, MOD-12, SC-15 | COVERED | - |
| FR-USER-004 | No readership analytics dashboard | CONFIRMED | none | none | MOD-12 | REVIEW | RS method: I |
| FR-USER-005 | Admin account creation and removal | OPEN | PAC-19 | ST-07 (+1) | OP-34, OP-35, OP-37 to OP-39, OP-42, SC-09 | COVERED | Updated by hand for GS-Q44. Waiting for OQ-58 |

### 5.14 Error, empty, loading and recovery states

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-STATE-001 | Loading indicator | ASSUMPTION | PAC-10 | none | none | COVERED | - |
| FR-STATE-002 | Empty states | ASSUMPTION | PAC-10 | TS 7.3 | none | COVERED | - |
| FR-STATE-003 | No-network message with retry | ASSUMPTION | PAC-10 | none | none | COVERED | - |
| FR-STATE-004 | Not enough storage for a download | ASSUMPTION | PAC-10 | TS 7.5 | MOD-06 | COVERED | - |
| FR-STATE-005 | WordPress unreachable | ASSUMPTION | PAC-10 | TS 7.7 | MOD-09 | COVERED | - |
| FR-STATE-006 | Failed download with retry | ASSUMPTION | PAC-10 | none | MOD-06 | COVERED | - |
| FR-STATE-007 | Admin panel result messages | ASSUMPTION | PAC-10 | none | OP-20, MOD-12 | COVERED | - |

### 5.15 Account privacy, consent and deletion

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| FR-PRIV-001 | Consent at registration | CONFIRMED | PAC-08 | TS 8.3 | OP-10, MOD-04 | COVERED | - |
| FR-PRIV-002 | Policy and terms reachable in the app | ASSUMPTION | PAC-08 | none | MOD-04 | COVERED | - |
| FR-PRIV-003 | Account deletion removes reader data | CONFIRMED | AC-3.7, PAC-06 | TS 8.3, TS 9, SEC-CHK-11, ST-14 | OP-12, OP-41, MOD-13 (+1) | COVERED | OP-13 is withdrawn (GS-Q50) |
| FR-PRIV-004 | Confirm before account deletion | ASSUMPTION | none | ST-14 | OP-12, MOD-04, SC-17 | PLAN ONLY | In a test plan or security test. No AC or PAC row |

### 6.1 and 6.2 Performance and reliability

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| NFR-PERF-001 | First page within 3 seconds on the mid-range test phone | CONFIRMED | AC-2.1 | none | MOD-07 | COVERED | - |
| NFR-PERF-002 | Sharp text at 300% zoom | CONFIRMED | AC-2.3 | none | MOD-07 | COVERED | - |
| NFR-REL-001 | Twenty page turns without a crash | CONFIRMED | AC-2.5 | none | MOD-07 | COVERED | - |
| NFR-REL-002 | No critical or high defect open | CONFIRMED | AC-10.4 | none | none | COVERED | - |
| NFR-REL-003 | Notification delivery time not guaranteed | CONFIRMED | AC-9.6 | TS 7.8 | none | COVERED | - |

### 6.3 Security and access control

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| NFR-SEC-001 | HTTPS for all traffic | CONFIRMED | none | TS 9, SEC-CHK-01, ST-01 | SC-01 | PLAN ONLY | In a test plan or security test. No AC or PAC row |
| NFR-SEC-002 | Backend refuses direct file requests | CONFIRMED | AC-3.5, PAC-13 | TS 9, SEC-CHK-02, ST-01, ST-12 | OP-11, SC-01, SC-07 | COVERED | - |
| NFR-SEC-003 | PDFs stored privately | CONFIRMED | none | TS 9, SEC-CHK-03, ST-12 | SC-07 | PLAN ONLY | In a test plan or security test. No AC or PAC row |
| NFR-SEC-004 | Downloads in app-private storage | CONFIRMED | none | TS 9, SEC-CHK-04 | none | PLAN ONLY | In a test plan or security test. No AC or PAC row |
| NFR-SEC-005 | Own bookmarks and favourites only | CONFIRMED | AC-5.4 | TS 9, SEC-CHK-05, ST-06 | OP-07, OP-08, MOD-08, SC-05 (+1) | COVERED | - |
| NFR-SEC-006 | Own profile and preferences only | ASSUMPTION | none | TS 9, SEC-CHK-05, ST-06 | OP-06, MOD-04, SC-06 | PLAN ONLY | In a test plan or security test. No AC or PAC row |
| NFR-SEC-007 | Only admins change the catalogue and news controls | CONFIRMED | RS: AC-8 | TS 9, SEC-CHK-06, SEC-CHK-18, ST-02 (+2) | OP-15, OP-16, OP-21, OP-40 (+2) | RS CLAIM | RS §13 cites AC-8. No row names this requirement |
| NFR-SEC-008 | Backend enforces upload checks | CONFIRMED | none | TS 9, SEC-CHK-07, ST-13 | OP-19, OP-40, SC-08 | PLAN ONLY | In a test plan or security test. No AC or PAC row |
| NFR-SEC-009 | Login gating and private storage only; no DRM | CONFIRMED | none | none | none | REVIEW | RS method: I |
| NFR-SEC-010 | Security checklist completed | CONFIRMED | AC-10.3 | TS 9 | none | COVERED | - |
| NFR-SEC-011 | Admin sign-in security measures | OPEN | none | TS 9, SEC-CHK-08 | OP-35, OP-39, OP-42 | PLAN ONLY | In a test plan or security test. No AC or PAC row |
| NFR-SEC-012 | Role-based access; MFW holds credentials | CONFIRMED | AC-12.3 | TS 9, SEC-CHK-14, ST-09, ST-19 | OP-42, SC-14, SC-19 | COVERED | - |

### 6.4 Privacy and data minimisation

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| NFR-PRIV-001 | Collect only approved profile fields | PROVISIONAL | none | TS 8.3 | none | PLAN ONLY | In a test plan or security test. No AC or PAC row |
| NFR-PRIV-002 | Store privacy details match MFW's policy | CONFIRMED | AC-11.3 | none | none | COVERED | - |
| NFR-PRIV-003 | No per-user reading tracking in usage events | PROVISIONAL | PAC-09 | TS 8.3, TS 9, SEC-CHK-10, ST-12 | MOD-02, MOD-08, SC-16 | COVERED | - |
| NFR-PRIV-004 | Personal-data exports for admins only | ASSUMPTION | RS: PAC-03 | TS 9, SEC-CHK-12, ST-15 | OP-31, OP-32, SC-15 | RS CLAIM | RS §13 cites PAC-03. No row names this requirement |
| NFR-PRIV-005 | Retention periods | OPEN | none | none | OP-12 | REVIEW | RS method: R: resolve OQ-24 |
| NFR-PRIV-006 | Legal review of age collection | OPEN | none | none | none | REVIEW | RS method: R: resolve OQ-07 |

### 6.5 Accessibility and usability

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| NFR-UX-001 | MFW branding | CONFIRMED | none | none | MOD-01 | REVIEW | RS method: I against the M2 designs |
| NFR-UX-002 | Screens approved before development | CONFIRMED | none | none | none | REVIEW | RS method: R: M2 approval record |
| NFR-UX-003 | English only | CONFIRMED | none | none | none | REVIEW | RS method: I |
| NFR-UX-004 | Accessibility baseline | OPEN | none | none | none | REVIEW | RS method: R: resolve OQ-25 |

### 6.6 Compatibility and supported devices

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| NFR-COMP-001 | Android and iOS from one codebase | CONFIRMED | RS: AC-10 | none | none | RS CLAIM | RS §13 cites AC-10. No row names this requirement |
| NFR-COMP-002 | Reader on phones and tablets, both orientations | CONFIRMED | RS: AC-2 | none | none | RS CLAIM | RS §13 cites AC-2. No row names this requirement |
| NFR-COMP-003 | Agreed test device set | CONFIRMED | AC-10.2 | none | none | COVERED | The team has a mid-range Android phone and a current iPhone only (GS-Q54, R25) |
| NFR-COMP-004 | Minimum OS versions | OPEN | none | none | none | REVIEW | RS method: R: resolve OQ-26 |
| NFR-COMP-005 | Admin panel browsers | OPEN | none | none | none | REVIEW | RS method: R: resolve OQ-26 |

### 6.7 Storage and bandwidth

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| NFR-STOR-001 | PDFs up to 150 MB and about 120 pages | ASSUMPTION | none | none | none | NO ROW | PROPOSED check: upload, publish, download and open the largest sample (FX-PDF-04) and the near-limit file (FX-PDF-05). AC-2.1 and AC-4.3 use these files but do not name this requirement |
| NFR-STOR-002 | Five to twelve issues at launch | ASSUMPTION | none | none | none | NO ROW | PROPOSED check: publish twelve issues and use the catalogue, search and filters. No threshold is set, so the result is recorded and not judged |
| NFR-STOR-003 | No content delivery network at launch (S2 proposal) | ASSUMPTION | none | none | none | REVIEW | RS method: R: architecture document |

### 6.8 Maintainability and observability

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| NFR-MAINT-001 | Source code in an MFW-owned repository | CONFIRMED | AC-12.1 | none | none | COVERED | - |
| NFR-MAINT-002 | Build and deploy from a clean copy | CONFIRMED | AC-12.2 | none | none | COVERED | - |
| NFR-MAINT-003 | Signed builds from tagged code | CONFIRMED | AC-11.1 | none | none | COVERED | - |
| NFR-MAINT-004 | Technical documentation contents | CONFIRMED | RS: AC-12 | none | none | RS CLAIM | RS §13 cites AC-12. No row names this requirement |
| NFR-MAINT-005 | Thin data layer | ASSUMPTION | none | none | none | REVIEW | RS method: R: architecture document |
| NFR-MAINT-006 | No paid component without approval | CONFIRMED | none | TS 9, SEC-CHK-13 | none | PLAN ONLY | In a test plan or security test. No AC or PAC row |
| NFR-OBS-001 | Crash reporting | CONFIRMED | none | none | MOD-02 | NO ROW | PROPOSED check: force a crash in a test build on each platform. Expect a report in MFW's crash service with no reader identity (DATA-014) |
| NFR-OBS-002 | Basic usage events | CONFIRMED | RS: PAC-09 | none | MOD-02 | RS CLAIM | RS §13 cites PAC-09. No row names this requirement |

### 6.9 Offline behaviour

| ID | Requirement | Status | AC or PAC | Test plan | Design | State | Note |
|---|---|---|---|---|---|---|---|
| NFR-OFF-001 | Downloads screen and downloaded issues offline | CONFIRMED | RS: AC-4 | none | none | RS CLAIM | RS §13 cites AC-4. No row names this requirement |
| NFR-OFF-002 | Offline catalogue, bookmarks and favourites | OPEN | none | none | none | REVIEW | RS method: R: resolve OQ-10 |

## 6. Open Items

These items are local to this document. They are not yet in the registers. Pull request 3 has reached `main` (by a direct push on 2026-10-25), so they are still to be registered in `OPEN_QUESTIONS.md`, with the owner and the evidence that would close each.

| Ref | Item | Owner | Depends on |
|---|---|---|---|
| RC-01 | Which of the eight candidate checks become rows, and where. S2 criteria are AC-1 to AC-12 and are not edited. A new row is a PAC row, which MFW must approve in writing before it is contractual | Both developers; MFW for PAC | `ACCEPTANCE_CRITERIA.md` §6 |
| RC-02 | For each RS CLAIM requirement, name it in the row that tests it, or correct RS §13. RS is not edited in this pass | Both developers | RS §13 |
| RC-03 | Who keeps this matrix in step with the documents, how often, and whether a reading program is kept in the repository | Both developers | `DEFINITION_OF_DONE.md` |
| RC-04 | Whether the AC-1.1 pass condition should list the category (FR-MAG-003, CONFIRMED from S1) | Both developers | S2 AC-1 |

No new question for MFW is raised here.

## 7. Traceability

```text
This document to its sources
├── RS §13: FR-AUTH, FR-PROF, FR-MAG, FR-SRCH, FR-READ, FR-DL, FR-BKM, FR-NEWS, FR-SHR, FR-NOTIF, FR-EMAIL, FR-ADMIN, FR-USER, FR-STATE, FR-PRIV
├── RS §13: NFR-PERF, NFR-REL, NFR-SEC, NFR-PRIV, NFR-UX, NFR-COMP, NFR-STOR, NFR-MAINT, NFR-OBS, NFR-OFF
├── Acceptance: AC-1 to AC-12 rows, PAC-01 to PAC-20
├── Tests: TESTING_STRATEGY §7, §8, §9, §16; SEC-CHK-nn; ST-nn; SC-nn
└── Design: OP-nn, MOD-nn
```
