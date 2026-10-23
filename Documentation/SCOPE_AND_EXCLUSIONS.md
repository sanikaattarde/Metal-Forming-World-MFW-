# Scope and Exclusions: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document title | Scope and Exclusions |
| File | `SCOPE_AND_EXCLUSIONS.md`, in the same folder as `REQUIREMENTS_SPECIFICATION.md` |
| Project | Metal Forming World (MFW) mobile application |
| Version | 0.1 |
| Status | Draft for Review |
| Last updated | 23 October 2026 |
| Prepared by | MFW development team |
| Approval status | Not approved. No MFW or internal approval of this document has been recorded. |
| Related documents | [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) v0.1; [Assumptions and Constraints Register](ASSUMPTIONS_AND_CONSTRAINTS.md) v0.1; [Glossary](GLOSSARY.md) v0.1; `PROJECT_CHARTER.md` v0.1 |

**Purpose.** This document states what the MFW project includes, what it excludes, and what can be added only after MFW's separate written approval. It groups the requirements in the specification into scope items, and it links each item to its requirement IDs and acceptance criteria. It adds no requirements and changes no requirement status or acceptance criterion. Where scope is unsettled, it says so and points to the open question, conflict or register entry.

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft for internal review |

### 1.1 Source documents and authority

| Ref | Document | Evidence status | Authority in this document |
|---|---|---|---|
| S1 | MFW Mobile App Commercial Proposal, `MFW_Commercial_Proposal-2.pdf`, 17 October 2026 | Read for this document. The copy is unsigned. Its acceptance, approver and sign-off sections are blank. | Shows what the proposal says. Its formal acceptance is unverified (REG-002). |
| S2 | MFW Mobile App Statement of Work, `MFW_Statement_of_Work.pdf`, 17 October 2026 | Read for this document. The copy is unsigned. | Primary source for scope, exclusions, acceptance criteria and responsibilities. Its formal acceptance is unverified (REG-002). |
| S3 | Client emails received after S1 and S2 | Not available. Not in the repository. Known only through CH. | Not used as evidence. The amendments recorded in CH stay PROVISIONAL (REG-001). |
| CH | Project Charter, `PROJECT_CHARTER.md` v0.1, 22 October 2026 | Read for this document. Draft for review, unsigned. | Working summary. It does not override S1 or S2. |
| SPEC | [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) v0.1, 22 October 2026 | Read for this document. Draft for Review. | The detailed requirements reference. Requirement IDs, statuses and acceptance criteria are used exactly as written there. |

S1, S2 and CH are named by file name and not linked, because they are not in the folder where this document was prepared. Fees, payment amounts and personal names are left out, as in the specification. The reported revised commercial terms appear only in the register (REG-004), where they stay PROVISIONAL.

### 1.2 Status labels

This document uses the status legend in the specification (spec §1.2) without change.

| Status | Meaning |
|---|---|
| CONFIRMED | Stated in S1 or S2 and not changed by any later record. S1 and S2 are unsigned, so their formal acceptance is itself unverified (OQ-28). |
| PROVISIONAL | Recorded in CH as a client amendment [S3], but the S3 emails are not in the repository. It is not confirmed scope until the S3 record is filed or MFW confirms in writing (OQ-29). |
| ASSUMPTION | An S2 planning assumption, or a development-team proposal (DEV) that needs MFW's approval. |
| OPEN | A decision or clarification is needed. |
| CONFLICT | Available sources disagree. |

Rules used in this document:

- A scope item's status is the status of every requirement listed against it. Requirements with different statuses are placed in separate scope items.
- A scope item with no requirement ID is a deliverable or obligation stated directly in S1 or S2. It is CONFIRMED when S1 or S2 states it and no later record changes it, which is the specification's definition of CONFIRMED.
- Under the specification's legend, a scope position proposed by the development team without MFW's approval is labelled ASSUMPTION, and one that rests only on the missing S3 emails is labelled PROVISIONAL. Neither label means approved scope.

### 1.3 Identifiers and notation

| Prefix | Meaning | Defined in |
|---|---|---|
| SCP-nnn | In-scope item | Sections 3 to 11 |
| EXC-nn | Excluded item | Section 12 |
| CHG-nn | Item that needs separate written approval or a change request | Section 13 |
| REG-nnn | Register entry | [ASSUMPTIONS_AND_CONSTRAINTS.md](ASSUMPTIONS_AND_CONSTRAINTS.md) |
| FR, NFR, DATA, INT, BR | Requirement IDs | [REQUIREMENTS_SPECIFICATION.md](REQUIREMENTS_SPECIFICATION.md) Sections 5 to 9 |
| OQ, C, ASM, PAC | Open questions, conflicts, assumptions and proposed acceptance criteria | Specification Sections 10.2 and 12 |
| AC-1 to AC-12 | S2 acceptance criteria | S2; summarised in specification Section 10.1 |

Source references follow the notation in spec §1.4, for example "S2 Scope: Accounts", "S1 A-27" and "CH §17.3". "CH D1" to "CH D9" are the open decisions in CH §19.3, and "CH R1" to "CH R11" are the risks in CH §18. "Spec §n" is a section of the specification.

## 2. Product and Project Boundaries

### 2.1 Product boundary

| Component | What is inside the product | Source | Status |
|---|---|---|---|
| Android app | Reader app for Android phones and tablets | S2 Product; S2 Scope: Platform | CONFIRMED |
| iOS app | Reader app for iPhone and iPad | S2 Product; S2 Scope: Platform | CONFIRMED |
| One codebase | One Flutter codebase for both apps | S2 Scope: Platform; S2 Architecture: Mobile app; CH §19.1 | CONFIRMED |
| Backend services | Accounts, data, private file storage, server logic and notification delivery, on accounts MFW owns. The technology is not yet decided (SCP-072, C-05). | S2 Product; S2 Scope: Platform; CH §17.4 | CONFIRMED |
| Web admin panel | MFW's editorial tool and the product's only web interface | S2 Product; S2 Scope: Admin panel; S2 Not included | CONFIRMED |
| WordPress news integration | Reads news from MFW's existing WordPress site without changing the site | S2 Scope: News; S2 Not included | CONFIRMED |

The following are outside the product. The project uses them or depends on them but does not build or change them:

- MFW's WordPress site and the news written in it (EXC-12).
- Any tool MFW uses to send edition-update emails, if the sign-up is kept (EXC-15; C-02).
- Apple's and Google's platform services, push delivery and store review (REG-046, REG-048).
- MFW's privacy policy and terms of use, which MFW supplies (EXC-18; REG-024).

### 2.2 Project boundary

The engagement covers design, build, testing, deployment, store submission and handover of the app, backend and admin panel, followed by a 30-day warranty [S2 Responsibilities; S2 Handover; S2 Warranty]. It runs from M1 to M5. M5 is complete at store submission and does not wait for Apple or Google to finish their review [S2 Milestones]. The milestone dates are disputed between S1, S2 and CH (C-08). CH's dates are PROVISIONAL (REG-006).

### 2.3 Responsibility boundary

| Party | Inside its responsibility | Source |
|---|---|---|
| Development team | Design, build, test and deploy the app, backend and admin panel on MFW's accounts. Submit to Apple and Google. Hand over the source code and documentation. Commit work weekly with short notes. Tell MFW in writing as soon as a delay is expected. Correct defects at no charge during the build and the warranty. | S2 Responsibilities |
| MFW | Name an authorised approver and a deputy. Supply the inputs listed in S1. Send one consolidated feedback list per review round and review within the S2 periods. Own and pay for the cloud project, the Apple and Google accounts and any domain, and give the developers role-based access. Provide and enter production content. Supply the privacy policy and terms of use. CH §14 also records MFW as the party responsible for its readers' personal data. | S2 Responsibilities; CH §14 |
| External providers | Google and Apple provide platform services, push delivery and store review. MFW's WordPress host provides the website and its API. | CH §14; S2 Warranty |

S1 and S2 name one developer. CH records two developers working together [S3]. That arrangement is PROVISIONAL (REG-052).

### 2.4 Users in scope

The roles and access states are those in spec §3.2: logged-out visitor, signed-in reader with access incomplete, signed-in reader with full access, and administrator. No other roles are in scope, and editorial roles are excluded (EXC-07). The access matrix in spec §9.2 is the authoritative statement of who can do what. The [Glossary](GLOSSARY.md) explains how these terms relate to "guest", "registered user" and "verified user".

### 2.5 Scope baseline

- S1 and S2 are the issued baseline. Both copies are unsigned, so their acceptance is unverified (REG-002).
- The client amendments recorded in CH §17.3 are PROVISIONAL because the S3 emails are missing (REG-001).
- CH §17.1 calls S1, S2 and the S3 amendments "the approved baseline", and CH §19.1 lists the S3 items as confirmed facts. No signed or filed record supports that wording. This document follows the specification's labels (REG-003).
- Nothing outside this baseline is committed to MFW [CH §17.1].

## 3. In-Scope Mobile Application Features

This section covers items that apply across the app. Feature areas are in Sections 4 to 8.

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-001 | Apps for Android and iOS built from one Flutter codebase | NFR-COMP-001 | S2 Product; S2 Scope: Platform; CH §19.1 | CONFIRMED |
| SCP-002 | A home screen, with its content set in the M2 screen designs | FR-MAG-006 | S1 A-2; S2 Scope: Design | CONFIRMED |
| SCP-003 | UI/UX design on MFW's branding, with screens approved by MFW before development | NFR-UX-001, NFR-UX-002 | S2 Scope: Design; S2 Milestones (M2); S1 A-1 | CONFIRMED |
| SCP-004 | English-only text in the app and the admin panel | NFR-UX-003 | S2 Assumptions; S2 Not included | CONFIRMED |
| SCP-005 | Support for phones and tablets, in portrait and landscape orientation | NFR-COMP-002 | S2 Scope: Reader; S2 AC-2 | CONFIRMED |
| SCP-006 | Loading, empty, no-network, low-storage, failed-download, WordPress-unreachable and admin result states, designed and approved with the M2 screens | FR-STATE-001, FR-STATE-002, FR-STATE-003, FR-STATE-004, FR-STATE-005, FR-STATE-006, FR-STATE-007 | DEV (ASM-13) | ASSUMPTION |
| SCP-007 | An accessibility baseline | NFR-UX-004 | DEV; OQ-25 | OPEN |
| SCP-008 | Minimum supported Android and iOS versions | NFR-COMP-004 | DEV; OQ-26 | OPEN |
| SCP-009 | MFW's privacy policy and terms of use can be opened from inside the app | FR-PRIV-002 | DEV; S2 AC-11 | ASSUMPTION |

## 4. In-Scope Authentication and Account Features

### 4.1 Email accounts and account lifecycle

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-010 | Registration with email and password, a verification email, sign-in, and reset of a forgotten password | FR-AUTH-001, FR-AUTH-002, FR-AUTH-003, FR-AUTH-004 | S2 Scope: Accounts; S2 AC-3; S1 A-26, A-29 | CONFIRMED |
| SCP-011 | An authentication service that supports these functions, account deletion and a separate admin role, and the reader account data it holds | INT-AUTH-001, DATA-003 | S2 Architecture: Accounts; S2 Scope: Accounts; S2 AC-3 | CONFIRMED |
| SCP-012 | Sign-out | FR-AUTH-008 | DEV (ASM-11); S1 A-29 | ASSUMPTION |
| SCP-013 | Reader consent to MFW's privacy policy and terms of use at registration | FR-PRIV-001 | S2 Not included; CH §9 | CONFIRMED |
| SCP-014 | In-app account deletion that removes the reader's data | FR-AUTH-009, FR-PRIV-003 | S2 Scope: Accounts; S2 AC-3; S2 Architecture: Server logic | CONFIRMED |
| SCP-015 | A confirmation step before account deletion, and a record of the reader's consent | FR-PRIV-004, DATA-012 | DEV | ASSUMPTION |

### 4.2 Google Sign-In

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-016 | Registration and sign-in with Google Sign-In on Android and iOS, configured in accounts MFW owns | FR-AUTH-005, INT-AUTH-002 | S3 via CH §8, §15, §17.3 (C-04) | PROVISIONAL |
| SCP-017 | A rule for an email address used with both sign-in methods, and a rule for email verification of Google accounts | FR-AUTH-006, FR-AUTH-007 | DEV; CH §9, §19.3 D5; OQ-04, OQ-05 | OPEN |

S1 A-27, the S1 Annex A notes and S2 Not included place Google Sign-In in a later phase. CH records it as moved into scope [S3]. The conflict (C-04) and the App Store risk of offering it without Sign in with Apple (OQ-06) are tracked in REG-017 and REG-018.

### 4.3 Mandatory reader profile

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-018 | A mandatory reader profile that includes name, exact age, gender, occupation and domain of work; registration complete only with every mandatory field; the same profile for Google Sign-In readers; profile completion before a full issue opens; age collected with no age gate or parental-consent flow; only the approved fields collected | FR-PROF-001, FR-PROF-002, FR-PROF-003, FR-PROF-004, FR-PROF-005, BR-003, DATA-004, NFR-PRIV-001 | S3 via CH §8, §9, §17.3 | PROVISIONAL |
| SCP-019 | A profile screen where a signed-in reader sees their account and profile information | FR-PROF-006 | S1 A-10 | CONFIRMED |
| SCP-020 | A reader can update their own profile, and readers can read and change only their own profile and notification preferences | FR-PROF-007, NFR-SEC-006 | DEV; S1 A-10; S2 Rationale | ASSUMPTION |
| SCP-021 | Review by MFW's legal adviser of collecting exact age without an age gate or parental-consent flow, before release | NFR-PRIV-006 | CH §18 R10; OQ-07 | OPEN |

The final field list, formats and age storage are OPEN (OQ-01, OQ-02, OQ-03; REG-022). The legal position on minors is OPEN (OQ-07; REG-023). An age gate would be a change request (CHG-07).

### 4.4 Edition-update email sign-up (unresolved)

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-022 | An optional sign-up for edition-update emails, and the stored edition-update list | FR-EMAIL-001, DATA-010 | S2 Scope: Accounts; S2 Architecture: Database; S1 A-10, A-19; S1 Annex A notes | CONFLICT |
| SCP-023 | A user who signed up can withdraw from the edition-update list | FR-EMAIL-002 | DEV | ASSUMPTION |

S1 and S2 include the optional sign-up, and S1 defines "subscription" in Annex A lines 10 and 19 as that sign-up. CH §8 leaves the sign-up out and describes a registered-user list with CSV export instead, and CH §17.3 does not list the sign-up's removal as an amendment. This conflict (C-02) is not resolved here. The sign-up is not dropped, not merged into registration and not approved. It stays in scope with the status CONFLICT, together with the subscriber CSV export (SCP-067), until MFW decides (OQ-31; CHG-09; REG-026). If it is kept, the product does not send the emails itself (EXC-15).

### 4.5 Access rules

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-024 | Opening or downloading a full issue requires sign-in and, for email accounts, a verified email address. A user without access sees a sign-in prompt instead of the issue. | BR-002, FR-AUTH-010 | S2 AC-3; CH §9 | CONFIRMED |
| SCP-025 | A notification or link that leads to a full issue follows the same access rules | BR-005 | DEV; S2 AC-3 | ASSUMPTION |

Authentication for full issues is CONFIRMED by S2 AC-3. What rests on S3 is the removal of the public sample (EXC-02, BR-001) and the profile condition (SCP-018, BR-003). What logged-out visitors can do with notifications, sharing and the edition-update sign-up, and whether readers with access incomplete can use favourites, are OPEN (OQ-09, OQ-12; REG-021).

## 5. In-Scope Magazine Catalogue, Reader, Online Reading and Offline Downloads

### 5.1 Catalogue and magazine metadata

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-026 | A catalogue of published issues shown to every user, including logged-out visitors | FR-MAG-001 | S2 Scope: Accounts; CH §9 | CONFIRMED |
| SCP-027 | Each issue shows its cover, title, publication date, description and category. The catalogue presents the latest issue and an archive, with four to six archive issues at launch. An issue details screen offers the read or download action. | FR-MAG-002, FR-MAG-003, FR-MAG-004, FR-MAG-005 | S2 AC-1; S2 Scope: Reader; S1 A-5; S1 What MFW receives | CONFIRMED |
| SCP-028 | Issues published or unpublished in the admin panel appear or disappear in the app after a refresh, without an app update | FR-MAG-007, FR-MAG-008 | S2 AC-1; S2 AC-8 | CONFIRMED |
| SCP-029 | The complete list of public metadata fields shown to logged-out visitors | FR-MAG-009 | CH §9; OQ-13 | OPEN |
| SCP-030 | Issue and category data, including file size and publication state | DATA-001, DATA-002 | S2 Scope: Discovery; S2 Scope: Admin panel; S2 AC-1; S2 AC-4; S2 Flow 1 | CONFIRMED |

### 5.2 PDF reader

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-031 | A full issue opens only for a signed-in reader, with a verified email address for email accounts | FR-READ-001 | S2 AC-3; S2 Architecture: File storage; CH §9 | CONFIRMED |
| SCP-032 | Page turns by swipe and tap, pinch zoom to 300%, a page-turn effect, a plain swipe mode built as the fallback, two pages side by side on tablets and in landscape, and an error with a retry option for a damaged file | FR-READ-003, FR-READ-004, FR-READ-005, FR-READ-006, FR-READ-007, FR-READ-009, FR-READ-010 | S2 Scope: Reader; S2 AC-2; S2 Rationale; S2 Risks; S1 What MFW receives | CONFIRMED |
| SCP-033 | Whether a reader can switch between the page-turn and swipe modes, and which mode is the default | FR-READ-008 | DEV; CH §5; OQ-14 | OPEN |
| SCP-034 | Reader targets: first page of a downloaded sample issue within 3 seconds on the mid-range test phone, sharp text at 300% zoom, and twenty page turns in a row without a crash | NFR-PERF-001, NFR-PERF-002, NFR-REL-001 | S2 AC-2 | CONFIRMED |

S2 confirms the AC-2 targets at the end of Week 2, after testing on MFW's sample PDFs, and the reader approach is confirmed at M2 (CH D3; REG-033).

### 5.3 Reading and download model

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-035 | A full issue is read from a complete copy downloaded to the device. Reading before the download finishes is not provided. | FR-READ-002 | S2 Assumptions; S2 Flow 3; S2 Not included; CH §18 R2 | CONFIRMED |

The terms below are easily confused. The table records where each one stands. It does not decide OQ-08 or C-03.

| Behaviour | Position | References |
|---|---|---|
| Reading from a complete copy downloaded to the device | In scope (SCP-035, CONFIRMED) | FR-READ-002; S2 Flow 3 |
| Reading an issue before its full download finishes, from server-prepared page images | Excluded (EXC-03, CONFIRMED) | S2 Not included |
| "Online reading", as listed in CH §8 | Unresolved. CH §8 lists it without a definition. S2 provides no reading before the full download, and no requirement adopts the term. | C-03; REG-028 |
| A complete copy kept only for reading, with a separate action to keep the issue for offline use | Unresolved. One of the two options in OQ-08. | OQ-08; REG-029 |
| A complete copy that stays on the device for offline reading whenever a full issue is opened | Unresolved. The other option in OQ-08. The specification reads S2 as using one downloaded copy for both reading and offline use (spec §5.6). | OQ-08; REG-029 |

### 5.4 Offline downloads

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-036 | Download of an issue to the app's private storage by a reader with full access, with no download for logged-out visitors or unverified readers; file size shown before the download; a warning on mobile data; progress; resume after a network break; full reading with no network; a Downloads screen; deletion that frees the storage space | FR-DL-001, FR-DL-002, FR-DL-003, FR-DL-004, FR-DL-005, FR-DL-006, FR-DL-007, FR-DL-008, FR-DL-009 | S2 Flow 3; S2 Scope: Reader; S2 AC-3; S2 AC-4; S1 A-9 | CONFIRMED |
| SCP-037 | Offline access to the Downloads screen and downloaded issues, and the data kept on the device (downloaded issue files and previously loaded articles) | NFR-OFF-001, DATA-013 | S2 AC-4; S2 Flow 3; S2 AC-7 | CONFIRMED |
| SCP-038 | What happens to downloaded issues when the reader signs out, deletes the account, or the issue is unpublished | FR-DL-010 | DEV; OQ-11 | OPEN |
| SCP-039 | Whether catalogue metadata, bookmarks and favourites are available offline | NFR-OFF-002 | DEV; OQ-10 | OPEN |

### 5.5 Content protection and file profile

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-040 | The backend enforces access to full issue files and refuses direct requests from users without access. PDFs are stored privately, downloads are kept in app-private storage, and files are released over HTTPS only to readers with full access. | NFR-SEC-002, NFR-SEC-003, NFR-SEC-004, INT-FILE-001 | S2 AC-3; S2 Flow 1; S2 Flow 3; S2 Architecture: File storage | CONFIRMED |
| SCP-041 | The product handles PDFs of up to 150 MB and about 120 pages, and five to twelve issues at launch. S2's proposed architecture has no content delivery network at launch. | NFR-STOR-001, NFR-STOR-002, NFR-STOR-003 | S2 Assumptions; S2 Flow 1; S2 Rationale | ASSUMPTION |

The upload limit of 150 MB by default is CONFIRMED in SCP-062 (FR-ADMIN-007). The file profile in SCP-041 is an S2 assumption, checked at M1 with MFW's sample PDFs (REG-031). Every edition is free to registered readers (EXC-10).

## 6. In-Scope Bookmarks, Favourites, Sharing, Search and Filtering

### 6.1 Bookmarks and favourites

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-042 | Page bookmarks that open the issue at the bookmarked page; favourite issues that update at once; both stored with the account, shown on a second device and private to each reader; list screens for both | FR-BKM-001, FR-BKM-002, FR-BKM-003, FR-BKM-004, FR-BKM-005, FR-BKM-006, NFR-SEC-005, DATA-005, DATA-006 | S2 Scope: Reader; S2 AC-5; S2 Rationale; S1 A-9 | CONFIRMED |
| SCP-043 | A reader can remove a bookmark | FR-BKM-007 | DEV | ASSUMPTION |
| SCP-044 | Whether bookmarks and favourites can be viewed and changed offline, and how offline changes are synchronised | FR-BKM-008 | DEV; OQ-10 | OPEN |

### 6.2 Sharing

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-045 | Sharing an issue or a news article through the device's share sheet, with its title and a link | FR-SHR-001, FR-SHR-003 | S2 Scope: Reader; S2 AC-6; S1 A-16 | CONFIRMED |
| SCP-046 | The shared link is the app's store listing for an issue, and the article's public WordPress address for a news article | FR-SHR-002, FR-SHR-004 | S3 via CH §8, §17.3 | PROVISIONAL |
| SCP-047 | Sharing never sends the issue PDF file | FR-SHR-006 | DEV; S2 Flow 3; S2 Not included | ASSUMPTION |

Shared links do not open the app directly (EXC-08). Which store link is shared is OQ-15. Whether logged-out visitors can share is OQ-09.

### 6.3 Search and filters

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-048 | Search by title, description and category, and filters by category, industry segment, year and edition | FR-SRCH-001, FR-SRCH-002, FR-SRCH-003, FR-SRCH-004, FR-SRCH-005 | S2 Scope: Discovery; S2 AC-1; CH §8 | CONFIRMED |
| SCP-049 | Search and filters are available to logged-out visitors and operate on public metadata | FR-SRCH-006 | DEV (ASM-14); CH §9 | ASSUMPTION |

AC-1 does not name the industry filter, which PAC-07 proposes to cover. The meanings of "industry segment" and "edition" as filters are OPEN (OQ-13). Search inside the text of PDF pages is excluded (EXC-23).

## 7. In-Scope WordPress News Integration and Offline Article Handling

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-050 | A news list of the latest WordPress posts with image, title, date and category; article pages; a category filter; new posts shown after a refresh | FR-NEWS-001, FR-NEWS-002, FR-NEWS-003, FR-NEWS-004 | S2 Scope: News; S2 AC-7; S1 A-7 | CONFIRMED |
| SCP-051 | The news list and articles are available to logged-out visitors | FR-NEWS-007 | S2 Scope: Accounts; S2 AC-3; S3 via CH §17.3 | CONFIRMED |
| SCP-052 | Articles already loaded stay readable with no network connection, with a notice that the app is offline | FR-NEWS-005 | S2 Scope: News; S2 AC-7 | CONFIRMED |
| SCP-053 | Whether articles are kept for offline reading by an explicit save action or automatically, and how many are kept | FR-NEWS-006 | S2 Scope: News; S2 AC-7; OQ-16 | OPEN |
| SCP-054 | A post hidden in the admin panel does not appear in the app after a refresh | FR-NEWS-008 | S2 AC-8; S1 Annex A notes | CONFIRMED |
| SCP-055 | How a post marked as breaking is presented in the app | FR-NEWS-009 | S1 Annex A notes; OQ-17 | OPEN |
| SCP-056 | News read through the WordPress site's API over HTTPS, only from the news categories MFW selects, in small pages with recent articles cached; the post fields used; WordPress stays the master source of news; the product keeps only cached posts and the app-level news controls | INT-WP-001, INT-WP-003, INT-WP-004, INT-WP-005, DATA-009, DATA-015 | S2 Scope: News; S2 Flow 2; S2 Assumptions; S2 Rationale; S1 What we need from MFW | CONFIRMED |

The project makes no changes to the WordPress site (EXC-12). The behaviour when the site cannot be reached is part of SCP-006. The WordPress inputs and the API assumption are REG-042 and REG-043.

## 8. In-Scope Push Notifications and Notification Controls

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-057 | An explanation before the system permission prompt; a choice of notification categories, changeable later in settings; delivery only to devices that opted in and chose the category; tapping a notification opens the linked issue or article; categories covering new issues, expo specials and major news | FR-NOTIF-001, FR-NOTIF-002, FR-NOTIF-003, FR-NOTIF-004, FR-NOTIF-005, FR-NOTIF-006 | S2 Scope: Notifications; S2 AC-9; S1 What MFW receives; S1 A-10 | CONFIRMED |
| SCP-058 | Delivery through the Android and iOS platform push services, with iOS delivery through MFW's Apple Developer Program account; stored category choices and device registrations; delivery time not guaranteed | INT-PUSH-001, INT-PUSH-002, DATA-007, NFR-REL-003 | S2 Architecture: Notifications; S2 AC-9; S1 What we need from MFW | CONFIRMED |
| SCP-059 | Whether logged-out visitors can receive notifications and set preferences | FR-NOTIF-007 | CH §7; S2 Scope: Notifications; OQ-09 | OPEN |

The final category list is OQ-18. Sending from the admin panel is in Section 9 (SCP-065, SCP-066). Scheduled notifications, audience segments and delivery statistics are excluded (EXC-04).

## 9. In-Scope Administration and Content Management

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-060 | A web admin panel, the product's only web interface, with sign-in that refuses wrong passwords and accounts without the admin role; one admin role with the same permissions for every admin | FR-ADMIN-001, FR-ADMIN-002, FR-ADMIN-003, FR-ADMIN-004, DATA-011 | S2 Product; S2 Scope: Admin panel; S2 AC-8; S2 Assumptions; S1 A-30, A-31 | CONFIRMED |
| SCP-061 | The measures that make admin sign-in secure, and how admin accounts are created and removed | NFR-SEC-011, FR-USER-005 | S2 Scope: Admin panel; S1 What we need from MFW; OQ-20 | OPEN |
| SCP-062 | Upload of an issue's PDF and cover image, with checks enforced by backend logic that reject a file that is not a genuine PDF and a PDF over the size limit of 150 MB by default | FR-ADMIN-005, FR-ADMIN-006, FR-ADMIN-007, NFR-SEC-008 | S2 Scope: Admin panel; S2 Flow 1; S2 AC-8; S1 A-32 | CONFIRMED |
| SCP-063 | Checks on cover images, and whether an admin can permanently delete an issue or replace its PDF | FR-ADMIN-008, FR-ADMIN-012 | S2 Scope: Admin panel; DEV; OQ-21, OQ-22 | OPEN |
| SCP-064 | Entry and editing of issue details, maintenance of categories, and publishing and unpublishing, with only admin accounts able to change the catalogue and news controls | FR-ADMIN-009, FR-ADMIN-010, FR-ADMIN-011, NFR-SEC-007 | S2 Scope: Admin panel; S2 Scope: Discovery; S2 AC-1; S2 AC-8; S2 Rationale; S1 A-33 | CONFIRMED |
| SCP-065 | App-level news controls: hide a WordPress post in the app, mark it as breaking, and send it as a breaking-news notification | FR-ADMIN-013, FR-ADMIN-014, FR-ADMIN-015 | S1 Annex A notes; S1 A-34; S2 Scope: Notifications; S2 AC-8 | CONFIRMED |
| SCP-066 | Sending a push notification to a chosen category, linked to an issue or article; sending limited to admins; a send log with one record per send | FR-ADMIN-016, FR-ADMIN-017, FR-ADMIN-018, DATA-008 | S2 Scope: Notifications; S2 AC-9; S1 A-36 | CONFIRMED |
| SCP-067 | Export of the subscriber list to CSV | FR-USER-001 | S2 Scope: Admin panel; S2 AC-8; S1 A-35; S1 Annex A notes | CONFLICT |
| SCP-068 | A list of registered users with their profile information, viewable in the admin panel and exportable to CSV | FR-USER-002, FR-USER-003 | S3 via CH §6, §8, §16 | PROVISIONAL |
| SCP-069 | Exports that contain personal data are available only to admin accounts | NFR-PRIV-004 | DEV; S2 Scope: Admin panel; S2 AC-8 | ASSUMPTION |
| SCP-070 | The web browsers supported for the admin panel | NFR-COMP-005 | DEV; OQ-26 | OPEN |

S2 AC-8 requires "the subscriber list" to export to CSV. Whether that means the edition-update list (SCP-022) or the registered-user list (SCP-068) is part of C-02 and OQ-31. Both items stay as recorded until MFW decides (REG-026). A readership analytics dashboard (EXC-05), news authoring in the panel (EXC-12) and editorial roles (EXC-07) are excluded. The administrator guide and training are in Section 11 (SCP-087).

## 10. In-Scope Backend, Cloud, Monitoring and Operational Requirements

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-071 | Backend services for accounts, data, private file storage, server logic and notification delivery on accounts MFW owns, with developer access through each platform's role-based access and credentials held by MFW | NFR-SEC-012 | S2 Product; S2 Scope: Platform; S2 Responsibilities; S2 AC-12 | CONFIRMED |
| SCP-072 | The backend technology. S2 proposes Firebase, and S2 M3 and AC-12 name it, but the architecture has not been approved. | None | S2 Architecture; S2 Scope: Platform; S2 Milestones (M3); S2 AC-12; CH §17.4; C-05 | CONFLICT |
| SCP-073 | HTTPS for all network traffic | NFR-SEC-001 | S2 Rationale; S2 Assumptions | CONFIRMED |
| SCP-074 | A thin data layer in the app, to limit the cost of changing backend provider later | NFR-MAINT-005 | S2 Rationale | ASSUMPTION |
| SCP-075 | No paid third-party component without MFW's written approval | NFR-MAINT-006 | S2 Rationale; S1 Costs outside the fee | CONFIRMED |
| SCP-076 | Crash reporting and basic usage events from the Android and iOS apps, on MFW's accounts | NFR-OBS-001, NFR-OBS-002, DATA-014 | S2 Scope: Platform; S2 Flow 5; S2 Architecture: Monitoring | CONFIRMED |
| SCP-077 | MFW owns its brand, content and reader data | DATA-016 | S1 Key terms | CONFIRMED |
| SCP-078 | Retention periods for accounts, profiles, inactive accounts, send records, consent records, crash data and exports | NFR-PRIV-005, DATA-017 | CH §19.3 D4; OQ-24 | OPEN |

CH §8 does not list crash reporting or usage events. The specification keeps the S2 position (C-07; REG-027). Usage events may not record which reader opened which issue or page (EXC-06). Cloud usage is billed to MFW on actual use (REG-039). Naming Firebase in SCP-072 does not approve it.

## 11. In-Scope Testing, Deployment, App-Store Submission and Handover

These items are deliverables and obligations stated in S1 and S2. Most have no requirement ID because the specification covers only their product-facing parts (spec §2.2).

### 11.1 Testing and acceptance

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-079 | A requirements and architecture note, delivered at M1 for MFW's written approval | None | S2 Milestones (M1); S1 What MFW receives and approves at each milestone | CONFIRMED |
| SCP-080 | An interactive prototype and the reader test result on MFW's PDFs at M2; a demo build at M3; test builds with an internal test summary at M4 | None | S2 Milestones | CONFIRMED |
| SCP-081 | A test plan run with results recorded for every acceptance criterion, on the device set agreed at M1; a completed security checklist; no critical or high defect open when acceptance testing starts | NFR-COMP-003, NFR-SEC-010, NFR-REL-002 | S2 AC-10; S2 Acceptance testing | CONFIRMED |
| SCP-082 | Acceptance testing as set out in S2: a test build and test script; five working days for MFW to test; a reply to each item within one working day; fix checks within two working days; sign-off when no critical or high defect is open | None | S2 Acceptance testing | CONFIRMED |

The date of the test build differs between S2 and CH (C-08; REG-006).

### 11.2 Deployment and app-store submission

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-083 | Deployment of the backend and admin panel on MFW's accounts | None | S2 Responsibilities; S1 A-38 | CONFIRMED |
| SCP-084 | Signed Android and iOS release builds made from tagged source code | NFR-MAINT-003 | S2 AC-11 | CONFIRMED |
| SCP-085 | Store listings with text approved by MFW, store privacy details that match MFW's privacy policy, and submission of both builds through MFW's own store accounts, with the confirmations given to MFW | NFR-PRIV-002, INT-STORE-001 | S2 AC-11; S2 Scope: Release; S1 What MFW receives; S1 A-39, A-40 | CONFIRMED |

M5 is complete at submission, and store approval is not guaranteed (EXC-21; REG-048).

### 11.3 Handover and warranty

| ID | Scope item | Requirements | Source | Status |
|---|---|---|---|---|
| SCP-086 | Source code for the app, backend and admin panel, with its history, in a repository owned by MFW; a build of the app and a deployment of the backend from a clean copy, following the written documentation; technical documentation covering set-up, deployment steps, the data model, security rules and third-party licences | NFR-MAINT-001, NFR-MAINT-002, NFR-MAINT-004 | S2 AC-12; S2 Handover | CONFIRMED |
| SCP-087 | A short administrator guide and a live training session of up to two hours | None | S2 Handover; S2 Scope: Release | CONFIRMED |
| SCP-088 | The release package (store listing text and screenshots, and the privacy inputs), test evidence, a record of who holds each credential, and a list of known limitations | None | S2 Handover | CONFIRMED |
| SCP-089 | Weekly commits to MFW's repository with short written notes, and written notice to MFW as soon as a delay is expected | None | S2 Responsibilities | CONFIRMED |
| SCP-090 | Defect correction at no charge during the build and the 30-day warranty. The warranty starts when the app first becomes publicly available in a store, using the later date if the stores differ, and ends no later than 60 days after submission. | None | S2 Warranty; S2 Responsibilities; S1 Key terms | CONFIRMED |
| SCP-091 | Removal of the developers' access to MFW's accounts when MFW asks after handover | None | S2 Handover | CONFIRMED |

The repository is not yet owned by MFW, and S2's weekly commits are described as going to "MFW's repository" (CH D8; REG-055). AC-12 names "a fresh Firebase project" (C-05; REG-035).

## 12. Explicit Exclusions

The items below are not in scope. Each one can be added later only through the change process (CHG-01). The list follows S2 Not included and spec §2.3. No exclusion has been added because a feature seemed expensive or unnecessary. The three exclusions that are not stated in S2 keep the specification's labels: two rest on S3 (PROVISIONAL) and one is a development-team proposal (ASSUMPTION).

| ID | Excluded item | Requirements | Source | Status |
|---|---|---|---|---|
| EXC-01 | Sign in with Apple | None | S2 Not included; CH §17.3 | CONFIRMED |
| EXC-02 | Guest reading and a public sample issue. Logged-out visitors cannot open any issue content. | BR-001 | S3 via CH §9, §17.3. S2 included a public sample (C-01). | PROVISIONAL |
| EXC-03 | Reading an issue before its full download finishes (server-prepared page images) | None | S2 Not included | CONFIRMED |
| EXC-04 | Scheduled notifications, audience segments, and delivery and open statistics | None | S2 Not included | CONFIRMED |
| EXC-05 | A readership analytics dashboard | FR-USER-004 | S2 Not included; CH §10 | CONFIRMED |
| EXC-06 | Per-user reading-activity tracking. Usage events do not record which reader opened which issue or page. | NFR-PRIV-003 | S3 via CH §10, §17.3; S2 Not included | PROVISIONAL |
| EXC-07 | Editorial roles, draft and review, scheduled publishing, and an audit log | None | S2 Not included | CONFIRMED |
| EXC-08 | Shared links that open the app directly | FR-SHR-005 | S2 Not included | CONFIRMED |
| EXC-09 | Lead capture forms and sponsor placement slots | None | S2 Not included | CONFIRMED |
| EXC-10 | Payments, subscriptions and paywalls. Every edition is free to registered readers. | BR-004 | S2 Not included; CH §9 | CONFIRMED |
| EXC-11 | A public web version of the reader | None | S2 Not included | CONFIRMED |
| EXC-12 | Changes to the WordPress site, and writing or editing news in the admin panel | INT-WP-002, FR-ADMIN-019 | S2 Not included; S2 Assumptions; CH §3 | CONFIRMED |
| EXC-13 | Marketplace and community features, AI features, advertising platforms and enterprise analytics | None | S2 Not included | CONFIRMED |
| EXC-14 | Integrations with CRM, email-marketing, accounting or ticketing systems | None | S2 Not included | CONFIRMED |
| EXC-15 | The product sending edition-update emails. If the sign-up is kept, MFW sends the emails using the exported list. | FR-EMAIL-003 | DEV (ASM-12); S2 Not included; S2 AC-8 | ASSUMPTION |
| EXC-16 | Creating or preparing content, and entering production issues, news and notifications. MFW's team does this. | None | S2 Not included | CONFIRMED |
| EXC-17 | Languages other than English | None | S2 Not included | CONFIRMED |
| EXC-18 | Writing legal documents, including the privacy policy and terms of use. MFW supplies them, and the developers implement consent and deletion. | None | S2 Not included | CONFIRMED |
| EXC-19 | Copy protection beyond login gating and private storage. There is no DRM. | NFR-SEC-009 | S2 Not included; CH §9 | CONFIRMED |
| EXC-20 | Third-party charges, an independent penetration test, and devices outside the agreed test list | None | S2 Not included | CONFIRMED |
| EXC-21 | A guarantee of store approval or its timing | None | S2 Not included | CONFIRMED |
| EXC-22 | Support after the 30-day warranty | None | S2 Not included | CONFIRMED |
| EXC-23 | Search inside the text of PDF pages | FR-SRCH-007 | DEV (ASM-10); S2 Scope: Discovery | ASSUMPTION |

Google Sign-In is listed in S1 and S2 as a later-phase item, but CH records it as moved into scope [S3]. It is therefore not listed as an exclusion. It is in scope as PROVISIONAL (SCP-016), and the conflict is C-04.

## 13. Items Requiring Separate Written Approval or a Change Request

These items are not part of the current scope commitment. The last column gives the status of the current position that the item would change. This section approves nothing.

| ID | Item | Approval route | Source | Status of current position |
|---|---|---|---|---|
| CHG-01 | Adding any item excluded in Section 12 | Change request under S2 Changes | S2 Not included; S2 Changes | CONFIRMED |
| CHG-02 | A new feature, different behaviour after approval, or a redesign of an approved screen | Change request | S2 Changes | CONFIRMED |
| CHG-03 | A paid third-party component, such as a commercial flipbook licence | MFW approves the quotation in writing before anything is bought | S1 Costs outside the fee; S2 Rationale; NFR-MAINT-006 | CONFIRMED |
| CHG-04 | A backend architecture that differs from the S2 proposal and changes M3, AC-12 or third-party cost | MFW's written approval before it is implemented | CH §17.4; spec §11.1; C-05 | CONFLICT |
| CHG-05 | A content delivery network | Architecture decision. Any added cost needs MFW's written approval. | NFR-STOR-003; CH §17.4 | ASSUMPTION |
| CHG-06 | Sign in with Apple, including where Apple's review requires an equivalent sign-in option | Change request | S2 Not included; CH §18 R9; OQ-06 | CONFIRMED |
| CHG-07 | An age gate or a parental-consent flow | Change request | CH §18 R10; FR-PROF-005; OQ-07 | PROVISIONAL |
| CHG-08 | Confirming the S3 amendments as agreed scope: Google Sign-In, no guest reading, the mandatory profile, the registered-user list, the share link targets, the limit on usage events and the revised schedule | Filing of the S3 record or MFW's written confirmation, and a formal record of the amendments (CH D7) | OQ-29; CH §19.3 D7 | PROVISIONAL |
| CHG-09 | Keeping, dropping or merging the optional edition-update email sign-up, and deciding what the AC-8 "subscriber list" means | MFW's written decision (OQ-31). This document does not decide whether the outcome is handled as a clarification or as a change request. | C-02; OQ-31 | CONFLICT |
| CHG-10 | Development-team proposals: requirements labelled ASSUMPTION, ASM-10 to ASM-14, and PAC-01 to PAC-11 | MFW's written approval | Spec §1.2, §10.2, §14.3 | ASSUMPTION |
| CHG-11 | A delay of more than five working days on a key MFW input | Schedule change agreed in writing | S2 Responsibilities | CONFIRMED |
| CHG-12 | Adapting the app to a provider outage, a new operating system version, a change made by MFW, or a content error | Support plan or change request | S2 Warranty | CONFIRMED |
| CHG-13 | Maintenance after the 30-day warranty | Optional maintenance plan, or occasional work billed per day, on the terms in S1 | S1 Costs outside the fee; S2 Not included | CONFIRMED |
| CHG-14 | A custom domain for the admin panel | Optional. MFW decides and pays the registrar directly. | S1 Costs outside the fee | CONFIRMED |

For CHG-06, Sign in with Apple stays excluded. MFW's acceptance of the review risk of offering Google Sign-In without it is OPEN (OQ-06; REG-018).

## 14. Dependencies on Client Inputs, External Services, Accounts and Approvals

Each dependency is described in full in the register. Dates come only from project records. The CH dates are PROVISIONAL (C-08). The S1 timings are relative to kickoff.

| Dependency | Needed by (recorded) | Scope items affected | Register |
|---|---|---|---|
| Signed or accepted S1 and S2, and a named MFW approver and deputy | S1: before kickoff. CH §12: before 21 October 2026. | Every scope item | REG-002 |
| The S3 emails, or MFW's written confirmation of each amendment | CH D7: before M2 | SCP-016, SCP-018, SCP-046, SCP-068, EXC-02, EXC-06 | REG-001 |
| Logo files, brand colours and fonts | S1: kickoff. CH §12: 21 October 2026. | SCP-003 | REG-010 |
| Written confirmation that MFW owns or may use the content | S1: before kickoff. CH §12: before 21 October 2026. | SCP-003, SCP-027 | REG-011 |
| Two to three sample PDFs, including the largest expected issue | S1: end of Week 1. CH §12: 28 October 2026. | SCP-032, SCP-034, SCP-041 | REG-012 |
| WordPress site address, API confirmation and the news categories to show | S1: end of Week 1. CH §12: 28 October 2026. | SCP-050 to SCP-056 | REG-042, REG-043 |
| A cloud project in MFW's name with billing switched on | S1: end of Week 1. CH §12: 28 October 2026. | SCP-011, SCP-016, SCP-040, SCP-058, SCP-071, SCP-076 | REG-037 |
| Apple Developer Program (organisation) and Google Play accounts in MFW's name | S1: enrolment in Week 1, active by end of Week 4. CH §12: active by 18 November 2026. | SCP-046, SCP-058, SCP-085 | REG-047 |
| Privacy policy and terms of use at a public address | S1: end of Week 4. CH §12: 18 November 2026. | SCP-009, SCP-013, SCP-018, SCP-085 | REG-024 |
| Launch content: the latest issue and four to six archive issues, with details | S1: end of Week 4. CH §12: 18 November 2026. | SCP-027 | REG-013 |
| Admin user list and store listing text | S1: Weeks 5 and 6. CH §12: 18 November to 2 December 2026. | SCP-061, SCP-085 | REG-014 |
| Testers from MFW's team | CH §12: from 2 December 2026 | SCP-082 | REG-015 |
| MFW's decisions on open questions and conflicts | Spec §12.2 proposes a milestone for each | Every OPEN and CONFLICT scope item | REG-016 |
| Review by MFW's legal adviser of age collection | Spec §12.2 proposes before the profile is built (M3) | SCP-018, SCP-021 | REG-023 |
| Apple and Google push delivery and store review; MFW's WordPress host | Not scheduled. Outside the team's control. | SCP-050, SCP-058, SCP-085 | REG-045, REG-046, REG-048 |
| Architecture document (internal) | CH D4 and D5: the architecture document | SCP-017, SCP-072, SCP-074 | REG-020, REG-035 |
| Reader test on MFW's sample PDFs (internal) | S2: end of Week 2, with the result at M2 | SCP-032, SCP-033, SCP-034 | REG-033 |
| Test strategy, test plan and security checklist (internal) | None recorded | SCP-081 | REG-041 |

## 15. Scope Traceability

The table below links every scope item to its requirements and acceptance criteria. The acceptance criteria come from the "Source" column of the scope item and from the "Verification" column of the traceability matrix in spec §13 for each listed requirement. They are copied, not changed. "None" in the criteria columns means the requirements are verified by test, demonstration, inspection or review as shown in spec §13, or only after an open question or conflict is resolved.

| Scope item | Section | Requirements | S2 acceptance criteria | Proposed criteria (PAC) | Status |
|---|---|---|---|---|---|
| SCP-001 | 3 | NFR-COMP-001 | AC-10 | None | CONFIRMED |
| SCP-002 | 3 | FR-MAG-006 | None | None | CONFIRMED |
| SCP-003 | 3 | NFR-UX-001, NFR-UX-002 | None | None | CONFIRMED |
| SCP-004 | 3 | NFR-UX-003 | None | None | CONFIRMED |
| SCP-005 | 3 | NFR-COMP-002 | AC-2 | None | CONFIRMED |
| SCP-006 | 3 | FR-STATE-001, FR-STATE-002, FR-STATE-003, FR-STATE-004, FR-STATE-005, FR-STATE-006, FR-STATE-007 | None | PAC-10 | ASSUMPTION |
| SCP-007 | 3 | NFR-UX-004 | None | None | OPEN |
| SCP-008 | 3 | NFR-COMP-004 | None | None | OPEN |
| SCP-009 | 3 | FR-PRIV-002 | AC-11 | PAC-08 | ASSUMPTION |
| SCP-010 | 4.1 | FR-AUTH-001, FR-AUTH-002, FR-AUTH-003, FR-AUTH-004 | AC-3 | None | CONFIRMED |
| SCP-011 | 4.1 | INT-AUTH-001, DATA-003 | AC-3, AC-8 | None | CONFIRMED |
| SCP-012 | 4.1 | FR-AUTH-008 | None | None | ASSUMPTION |
| SCP-013 | 4.1 | FR-PRIV-001 | None | PAC-08 | CONFIRMED |
| SCP-014 | 4.1 | FR-AUTH-009, FR-PRIV-003 | AC-3 | PAC-06 | CONFIRMED |
| SCP-015 | 4.1 | FR-PRIV-004, DATA-012 | None | None | ASSUMPTION |
| SCP-016 | 4.2 | FR-AUTH-005, INT-AUTH-002 | None | PAC-01 | PROVISIONAL |
| SCP-017 | 4.2 | FR-AUTH-006, FR-AUTH-007 | None | PAC-01 | OPEN |
| SCP-018 | 4.3 | FR-PROF-001, FR-PROF-002, FR-PROF-003, FR-PROF-004, FR-PROF-005, BR-003, DATA-004, NFR-PRIV-001 | None | PAC-01, PAC-02 | PROVISIONAL |
| SCP-019 | 4.3 | FR-PROF-006 | None | None | CONFIRMED |
| SCP-020 | 4.3 | FR-PROF-007, NFR-SEC-006 | None | None | ASSUMPTION |
| SCP-021 | 4.3 | NFR-PRIV-006 | None | None | OPEN |
| SCP-022 | 4.4 | FR-EMAIL-001, DATA-010 | None | PAC-11 | CONFLICT |
| SCP-023 | 4.4 | FR-EMAIL-002 | None | PAC-11 | ASSUMPTION |
| SCP-024 | 4.5 | BR-002, FR-AUTH-010 | AC-3 | None | CONFIRMED |
| SCP-025 | 4.5 | BR-005 | AC-3 | None | ASSUMPTION |
| SCP-026 | 5.1 | FR-MAG-001 | AC-1 | PAC-04 | CONFIRMED |
| SCP-027 | 5.1 | FR-MAG-002, FR-MAG-003, FR-MAG-004, FR-MAG-005 | AC-1 | None | CONFIRMED |
| SCP-028 | 5.1 | FR-MAG-007, FR-MAG-008 | AC-1, AC-8 | None | CONFIRMED |
| SCP-029 | 5.1 | FR-MAG-009 | None | None | OPEN |
| SCP-030 | 5.1 | DATA-001, DATA-002 | AC-1, AC-4 | None | CONFIRMED |
| SCP-031 | 5.2 | FR-READ-001 | AC-3 | None | CONFIRMED |
| SCP-032 | 5.2 | FR-READ-003, FR-READ-004, FR-READ-005, FR-READ-006, FR-READ-007, FR-READ-009, FR-READ-010 | AC-2 | None | CONFIRMED |
| SCP-033 | 5.2 | FR-READ-008 | None | None | OPEN |
| SCP-034 | 5.2 | NFR-PERF-001, NFR-PERF-002, NFR-REL-001 | AC-2 | None | CONFIRMED |
| SCP-035 | 5.3 | FR-READ-002 | AC-2, AC-4 | None | CONFIRMED |
| SCP-036 | 5.4 | FR-DL-001, FR-DL-002, FR-DL-003, FR-DL-004, FR-DL-005, FR-DL-006, FR-DL-007, FR-DL-008, FR-DL-009 | AC-3, AC-4 | None | CONFIRMED |
| SCP-037 | 5.4 | NFR-OFF-001, DATA-013 | AC-4, AC-7 | None | CONFIRMED |
| SCP-038 | 5.4 | FR-DL-010 | None | None | OPEN |
| SCP-039 | 5.4 | NFR-OFF-002 | None | None | OPEN |
| SCP-040 | 5.5 | NFR-SEC-002, NFR-SEC-003, NFR-SEC-004, INT-FILE-001 | AC-3 | None | CONFIRMED |
| SCP-041 | 5.5 | NFR-STOR-001, NFR-STOR-002, NFR-STOR-003 | None | None | ASSUMPTION |
| SCP-042 | 6.1 | FR-BKM-001, FR-BKM-002, FR-BKM-003, FR-BKM-004, FR-BKM-005, FR-BKM-006, NFR-SEC-005, DATA-005, DATA-006 | AC-5 | PAC-01 | CONFIRMED |
| SCP-043 | 6.1 | FR-BKM-007 | None | None | ASSUMPTION |
| SCP-044 | 6.1 | FR-BKM-008 | None | None | OPEN |
| SCP-045 | 6.2 | FR-SHR-001, FR-SHR-003 | AC-6 | None | CONFIRMED |
| SCP-046 | 6.2 | FR-SHR-002, FR-SHR-004 | None | PAC-05 | PROVISIONAL |
| SCP-047 | 6.2 | FR-SHR-006 | None | None | ASSUMPTION |
| SCP-048 | 6.3 | FR-SRCH-001, FR-SRCH-002, FR-SRCH-003, FR-SRCH-004, FR-SRCH-005 | AC-1 | PAC-07 | CONFIRMED |
| SCP-049 | 6.3 | FR-SRCH-006 | None | PAC-04 | ASSUMPTION |
| SCP-050 | 7 | FR-NEWS-001, FR-NEWS-002, FR-NEWS-003, FR-NEWS-004 | AC-7 | None | CONFIRMED |
| SCP-051 | 7 | FR-NEWS-007 | AC-3 | PAC-04 | CONFIRMED |
| SCP-052 | 7 | FR-NEWS-005 | AC-7 | None | CONFIRMED |
| SCP-053 | 7 | FR-NEWS-006 | AC-7 | None | OPEN |
| SCP-054 | 7 | FR-NEWS-008 | AC-8 | None | CONFIRMED |
| SCP-055 | 7 | FR-NEWS-009 | None | None | OPEN |
| SCP-056 | 7 | INT-WP-001, INT-WP-003, INT-WP-004, INT-WP-005, DATA-009, DATA-015 | AC-7 | None | CONFIRMED |
| SCP-057 | 8 | FR-NOTIF-001, FR-NOTIF-002, FR-NOTIF-003, FR-NOTIF-004, FR-NOTIF-005, FR-NOTIF-006 | AC-9 | None | CONFIRMED |
| SCP-058 | 8 | INT-PUSH-001, INT-PUSH-002, DATA-007, NFR-REL-003 | AC-9 | None | CONFIRMED |
| SCP-059 | 8 | FR-NOTIF-007 | None | None | OPEN |
| SCP-060 | 9 | FR-ADMIN-001, FR-ADMIN-002, FR-ADMIN-003, FR-ADMIN-004, DATA-011 | AC-8 | None | CONFIRMED |
| SCP-061 | 9 | NFR-SEC-011, FR-USER-005 | None | None | OPEN |
| SCP-062 | 9 | FR-ADMIN-005, FR-ADMIN-006, FR-ADMIN-007, NFR-SEC-008 | AC-8 | None | CONFIRMED |
| SCP-063 | 9 | FR-ADMIN-008, FR-ADMIN-012 | None | None | OPEN |
| SCP-064 | 9 | FR-ADMIN-009, FR-ADMIN-010, FR-ADMIN-011, NFR-SEC-007 | AC-1, AC-8 | None | CONFIRMED |
| SCP-065 | 9 | FR-ADMIN-013, FR-ADMIN-014, FR-ADMIN-015 | AC-8 | None | CONFIRMED |
| SCP-066 | 9 | FR-ADMIN-016, FR-ADMIN-017, FR-ADMIN-018, DATA-008 | AC-9 | None | CONFIRMED |
| SCP-067 | 9 | FR-USER-001 | AC-8 | None | CONFLICT |
| SCP-068 | 9 | FR-USER-002, FR-USER-003 | None | PAC-03 | PROVISIONAL |
| SCP-069 | 9 | NFR-PRIV-004 | AC-8 | PAC-03 | ASSUMPTION |
| SCP-070 | 9 | NFR-COMP-005 | None | None | OPEN |
| SCP-071 | 10 | NFR-SEC-012 | AC-12 | None | CONFIRMED |
| SCP-072 | 10 | None | AC-12 | None | CONFLICT |
| SCP-073 | 10 | NFR-SEC-001 | None | None | CONFIRMED |
| SCP-074 | 10 | NFR-MAINT-005 | None | None | ASSUMPTION |
| SCP-075 | 10 | NFR-MAINT-006 | None | None | CONFIRMED |
| SCP-076 | 10 | NFR-OBS-001, NFR-OBS-002, DATA-014 | None | PAC-09 | CONFIRMED |
| SCP-077 | 10 | DATA-016 | None | None | CONFIRMED |
| SCP-078 | 10 | NFR-PRIV-005, DATA-017 | None | None | OPEN |
| SCP-079 | 11.1 | None | None | None | CONFIRMED |
| SCP-080 | 11.1 | None | None | None | CONFIRMED |
| SCP-081 | 11.1 | NFR-COMP-003, NFR-SEC-010, NFR-REL-002 | AC-10 | None | CONFIRMED |
| SCP-082 | 11.1 | None | None | None | CONFIRMED |
| SCP-083 | 11.2 | None | None | None | CONFIRMED |
| SCP-084 | 11.2 | NFR-MAINT-003 | AC-11 | None | CONFIRMED |
| SCP-085 | 11.2 | NFR-PRIV-002, INT-STORE-001 | AC-11 | None | CONFIRMED |
| SCP-086 | 11.3 | NFR-MAINT-001, NFR-MAINT-002, NFR-MAINT-004 | AC-12 | None | CONFIRMED |
| SCP-087 | 11.3 | None | None | None | CONFIRMED |
| SCP-088 | 11.3 | None | None | None | CONFIRMED |
| SCP-089 | 11.3 | None | None | None | CONFIRMED |
| SCP-090 | 11.3 | None | None | None | CONFIRMED |
| SCP-091 | 11.3 | None | None | None | CONFIRMED |
| EXC-01 | 12 | None | None | None | CONFIRMED |
| EXC-02 | 12 | BR-001 | None | PAC-04 | PROVISIONAL |
| EXC-03 | 12 | None | None | None | CONFIRMED |
| EXC-04 | 12 | None | None | None | CONFIRMED |
| EXC-05 | 12 | FR-USER-004 | None | None | CONFIRMED |
| EXC-06 | 12 | NFR-PRIV-003 | None | PAC-09 | PROVISIONAL |
| EXC-07 | 12 | None | None | None | CONFIRMED |
| EXC-08 | 12 | FR-SHR-005 | None | None | CONFIRMED |
| EXC-09 | 12 | None | None | None | CONFIRMED |
| EXC-10 | 12 | BR-004 | None | None | CONFIRMED |
| EXC-11 | 12 | None | None | None | CONFIRMED |
| EXC-12 | 12 | INT-WP-002, FR-ADMIN-019 | None | None | CONFIRMED |
| EXC-13 | 12 | None | None | None | CONFIRMED |
| EXC-14 | 12 | None | None | None | CONFIRMED |
| EXC-15 | 12 | FR-EMAIL-003 | AC-8 | None | ASSUMPTION |
| EXC-16 | 12 | None | None | None | CONFIRMED |
| EXC-17 | 12 | None | None | None | CONFIRMED |
| EXC-18 | 12 | None | None | None | CONFIRMED |
| EXC-19 | 12 | NFR-SEC-009 | None | None | CONFIRMED |
| EXC-20 | 12 | None | None | None | CONFIRMED |
| EXC-21 | 12 | None | None | None | CONFIRMED |
| EXC-22 | 12 | None | None | None | CONFIRMED |
| EXC-23 | 12 | FR-SRCH-007 | None | None | ASSUMPTION |

**Coverage.** The 199 requirement IDs in the specification each appear exactly once in the Requirements column of Sections 3 to 12: 189 in the 91 in-scope items and 10 in the 23 exclusions. 24 items have no requirement ID because they are deliverables, obligations or exclusions stated directly in S1 or S2. Acceptance criteria AC-1 to AC-12 each trace to at least one scope item.

## 16. Open Scope Questions and Unresolved Conflicts

### 16.1 Conflicts

The positions below are the specification's (spec §12.3). This document does not change them.

| Conflict | Topic | Position used until resolved | Scope items | Register |
|---|---|---|---|---|
| C-01 | Guest reading | The CH position, as PROVISIONAL. Logged-out visitors still browse metadata and news. | EXC-02, SCP-026, SCP-051 | REG-019 |
| C-02 | Edition-update emails and the subscriber list | The S2 baseline is kept and marked CONFLICT. The registered-user list is added as PROVISIONAL. | SCP-022, SCP-023, SCP-067, SCP-068, EXC-15, CHG-09 | REG-026 |
| C-03 | "Online reading" | The S2 position: an issue is read from a complete downloaded copy. | SCP-035, EXC-03 | REG-028 |
| C-04 | Google Sign-In | The CH position, as PROVISIONAL. | SCP-016, SCP-017 | REG-017 |
| C-05 | Architecture status | Requirements stated as capabilities. Firebase is the S2 baseline. A different choice that changes M3, AC-12 or third-party cost needs MFW's written approval. | SCP-072, SCP-086, CHG-04 | REG-035 |
| C-06 | Upload size limit wording | The S2 wording: 150 MB by default. | SCP-062 | REG-032 |
| C-07 | Crash reporting and usage events | The S2 position, limited by the rule on usage events. | SCP-076, EXC-06 | REG-027 |
| C-08 | Schedule | The CH dates, as PROVISIONAL. | SCP-082, Section 14 | REG-006 |

### 16.2 Open questions that affect scope

| OQ | Scope question | Scope items | Register |
|---|---|---|---|
| OQ-01 | Final mandatory profile field list, formats and allowed values | SCP-018 | REG-022 |
| OQ-02 | Exact age as a number or a date of birth | SCP-018 | REG-022 |
| OQ-03 | When a Google Sign-In reader completes the profile | SCP-016, SCP-018 | REG-022 |
| OQ-04 | Email verification for Google accounts | SCP-017, SCP-024 | REG-020 |
| OQ-05 | One email address used with both sign-in methods | SCP-017 | REG-020 |
| OQ-06 | MFW's acceptance of the App Store risk of no Sign in with Apple | SCP-016, CHG-06 | REG-018 |
| OQ-07 | Legal position on collecting exact age without an age gate | SCP-018, SCP-021, CHG-07 | REG-023 |
| OQ-08 | A temporary reading copy or a retained offline copy | SCP-035, SCP-036 | REG-029 |
| OQ-09 | Logged-out notifications, sharing and edition-update sign-up | SCP-022, SCP-045, SCP-059 | REG-021 |
| OQ-10 | Offline catalogue, bookmarks and favourites | SCP-039, SCP-044 | REG-016 |
| OQ-11 | Downloads after sign-out, deletion or unpublishing | SCP-038 | REG-016 |
| OQ-12 | Favourites for readers with access incomplete | SCP-042 | REG-021 |
| OQ-13 | Public metadata fields; meaning of "industry segment" and "edition" | SCP-029, SCP-048 | REG-016 |
| OQ-14 | Reader mode switching and default | SCP-033 | REG-033 |
| OQ-15 | Which store link is shared for an issue | SCP-046 | REG-016 |
| OQ-16 | How news articles are kept offline | SCP-053 | REG-016 |
| OQ-17 | Presentation of breaking posts | SCP-055 | REG-016 |
| OQ-18 | Final notification categories | SCP-057 | REG-016 |
| OQ-19 | Send log fields | SCP-066 | REG-016 |
| OQ-20 | Admin account management and sign-in security | SCP-061 | REG-016 |
| OQ-21 | Deleting an issue or replacing its PDF | SCP-063 | REG-016 |
| OQ-22 | Cover image checks | SCP-063 | REG-016 |
| OQ-23 | Usage events list and consent | SCP-076, EXC-06 | REG-027 |
| OQ-24 | Retention periods | SCP-078, SCP-014 | REG-025 |
| OQ-25 | Accessibility baseline | SCP-007 | REG-016 |
| OQ-26 | Minimum OS versions, test device models, admin browsers | SCP-008, SCP-070, SCP-081 | REG-016 |
| OQ-27 | How consent is recorded | SCP-013, SCP-015 | REG-024 |
| OQ-28 | Signed S1 and S2, and the named approver and deputy | Every scope item | REG-002 |
| OQ-29 | Filing the S3 emails or MFW's written confirmation | Every PROVISIONAL scope item | REG-001 |
| OQ-30 | A PDF of exactly 150 MB, and an admin-configurable limit | SCP-062 | REG-032 |
| OQ-31 | The edition-update sign-up and the meaning of "subscriber list" | SCP-022, SCP-067, SCP-068 | REG-026 |

### 16.3 Further observations from this review

These points were found while comparing the specification with S1, S2 and CH. They are recorded here and in the register. The specification has not been edited.

| Observation | Effect | Register |
|---|---|---|
| S2 Flow 4 uses "subscribed" for readers who opted into a notification category. S2 Architecture: Admin panel says editors manage "subscribers". C-02 does not cite either use. | A further meaning of "subscriber" that the C-02 decision should take into account. Nothing is resolved here. | REG-026 |
| S1's Investment table describes Authentication as including "guest access". C-01 cites S1 A-28 but not this row. | Further S1 evidence for the guest position in C-01. | REG-019 |
| CH §17.1 calls the baseline "approved", and CH §19.1 lists the S3 items as confirmed facts. | CH wording is stronger than the evidence. This document follows the specification's labels. | REG-003 |
| S2 Architecture: Accounts mentions "admin roles", while S2 Assumptions and S2 Not included set one admin role. | FR-ADMIN-004 follows S2 Assumptions. The wording difference is recorded only. | REG-056 |
| S2 requires signed builds (AC-11), credentials held by MFW (AC-12) and a record of who holds each credential (S2 Handover), but no source says who creates and holds the app signing credentials during the build. | An open point for the release documentation. | REG-051 |

## 17. Change-Control Rules

- **Scope changes.** After approval, any change to scope follows S2 Changes. MFW's approver describes the change in writing. Within two working days the developers reply with the effort, the price, the effect on dates and any new third-party cost. MFW approves in writing, and no work starts before that. The original scope and dates stand until then [S2 Changes; CH §17.2].
- **Defects and changes.** A defect is a failure against an acceptance criterion and is fixed at no charge. Anything else is a change. A question that only clarifies the agreed scope is answered without a change request [S2 Changes].
- **Exclusions.** An item in Section 12 enters scope only through an approved change request (CHG-01). Removing an exclusion from this document without that approval is not allowed.
- **Status changes.** Requirement statuses are owned by the specification. This document never changes a status by itself. When the specification changes a status, this document and the register are updated in the same revision. A PROVISIONAL item becomes CONFIRMED only when the S3 record or MFW's written confirmation is filed and cited [spec §14.3].
- **Resolving OPEN and CONFLICT items.** A decision is recorded with its date, its decision-maker and the evidence. The specification is updated first, then this document and the register.
- **Versions.** Before approval, each change to this document gets a new version number and a line in the change history.
- **Identifiers.** SCP, EXC and CHG IDs are never reused. A removed item stays in its table marked "Withdrawn", with the reason.
