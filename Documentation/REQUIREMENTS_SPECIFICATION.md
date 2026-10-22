# Requirements Specification: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document title | Requirements Specification |
| File | `REQUIREMENTS_SPECIFICATION.md`, in the project `Documentation` folder with `PROJECT_CHARTER.md` |
| Project | Metal Forming World (MFW) mobile application |
| Version | 0.1 |
| Status | Draft for Review |
| Last updated | 22 October 2026 |
| Prepared by | MFW development team |
| Approval status | Not approved. No MFW or internal approval of this document has been recorded. |
| Related document | `PROJECT_CHARTER.md` v0.1, Draft for review, 22 October 2026 |

**Purpose.** This document states the functional, non-functional, data, integration and acceptance requirements for the MFW mobile app, its backend services and its web admin panel. It is written so that MFW and the development team can review, test and approve each requirement. It describes what the product must do. It does not choose the architecture, the technology or the implementation plan.

**Relationship to M1.** S2 makes a "requirements and architecture note" the M1 deliverable that MFW approves in writing [S2 Milestones]. The charter treats this specification as a supporting project document, not a contractual deliverable [CH §11]. This document can serve as the basis for the requirements part of the M1 note. Architecture is covered by a separate document [CH §17.4].

**Intended audience.**
- MFW's authorised approver and deputy, who review the scope and approve the requirements.
- MFW's editorial team, who will use the admin panel.
- The development team, who design, build and test against these requirements.

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 22 October 2026 | Initial draft for internal review |

### 1.1 Source documents

| Ref | Document | File | Date | Evidence status | Use in this document |
|---|---|---|---|---|---|
| S1 | MFW Mobile App Commercial Proposal | `MFW_Commercial_Proposal-2.pdf` | 17 October 2026 | Available. The copy is unsigned. Its acceptance, approver and sign-off sections are blank. | Annex A scope lines and notes, inputs MFW supplies, ownership and third-party cost terms |
| S2 | MFW Mobile App Statement of Work | `MFW_Statement_of_Work.pdf` | 17 October 2026 | Available. The copy is unsigned. | Primary source for scope, exclusions, flows, acceptance criteria AC-1 to AC-12, assumptions and responsibilities |
| S3 | Client emails received after S1 and S2 | Not in the repository | Not recorded | Not available. Known only through the charter. | Amendments recorded in CH §17.3 |
| CH | Project Charter | `PROJECT_CHARTER.md` | 22 October 2026, v0.1 | Available. Draft for review, unsigned. | Working summary, amendments, open decisions D1 to D9, risks R1 to R11 |

All three files are in the project `Documentation` folder. Fees, payments and personal names are deliberately left out of this document. They are in S1 and CH.

### 1.2 Status legend

| Status | Meaning in this document |
|---|---|
| CONFIRMED | Stated in S1 or S2 and not changed by any later record. S1 and S2 are the issued baseline. The copies in the repository are unsigned, so their formal acceptance is itself unverified (OQ-28). |
| PROVISIONAL | Recorded in CH as a client amendment [S3], but the S3 emails are not in the repository. Used as the working position. It is not a confirmed client requirement until the S3 record is filed or MFW confirms in writing (OQ-29). |
| ASSUMPTION | An S2 planning assumption, or an inference by the development team (marked DEV) needed to make the requirements complete. A DEV inference is a proposal and needs approval. |
| OPEN | A decision or clarification is needed. Each one points to an open question in Section 12.2. |
| CONFLICT | Available sources disagree. Each one points to a conflict in Section 12.3. The requirement text states the position used until the conflict is resolved. |

### 1.3 Priority

No source assigns priorities to individual features. S2 states that M4 is approved when "every feature in this document is present" [S2 Milestones]. Every CONFIRMED functional requirement is therefore mandatory for M4. A PROVISIONAL requirement becomes mandatory once it is verified. An ASSUMPTION proposed by the development team has no priority until MFW approves it. An OPEN or CONFLICT item has no priority until it is resolved.

### 1.4 Reference notation

| Notation | Meaning |
|---|---|
| S1 A-n | S1 Annex A, line n |
| S1 Annex A notes | The notes under the S1 Annex A table |
| S1 What MFW receives, S1 What we need from MFW, S1 Costs outside the fee, S1 Key terms | The S1 section of that name |
| S2 Product | The Product row of the table on the first page of S2 |
| S2 Scope: X | Row X of the S2 "Scope included" table |
| S2 Not included | S2 "Scope not included", covering later-phase features and other exclusions |
| S2 Architecture: X | Row X of the S2 "Components" table under "Proposed technical architecture" |
| S2 Flow n | Item n of S2 "How the main flows work" |
| S2 Rationale | S2 "Why this design" |
| S2 Milestones | S2 "Deliverables and milestones" |
| S2 AC-n | S2 acceptance criterion n |
| S2 Acceptance testing | S2 "How acceptance testing works" |
| S2 Assumptions, S2 Risks | S2 "Assumptions and key risks" |
| S2 Responsibilities, S2 Changes, S2 Handover, S2 Warranty | The S2 section of that name |
| CH §n | Section n of `PROJECT_CHARTER.md` |
| S3 via CH §n | A client amendment recorded in the charter and not independently verified |
| DEV | An inference by the development team in this document |

Verification codes used in Section 13: **T** test, **D** demonstration, **I** inspection, **R** review and decision.

## 2. Purpose and Scope

### 2.1 Product overview

MFW publishes an industrial magazine as high-resolution PDF editions and publishes industry news on its existing WordPress website [CH §3; S2 Objectives]. The product gives readers an interactive way to read editions on Android and iOS phones and tablets, keep them for offline reading, read MFW's news and receive notifications. It gives MFW's editors a web admin panel to publish editions, control how news appears in the app and send notifications without developer help [S2 Objectives].

Logged-out visitors can browse public issue information and read news. Reading or downloading a full edition requires an account [S2 AC-3; CH §9]. The charter records that the client removed guest reading, added Google Sign-In and added a mandatory reader profile [S3 via CH §17.3]. Those amendments are PROVISIONAL in this document because the S3 emails are not in the repository.

### 2.2 In-scope platforms and components

| Component | What it covers | Source | Status |
|---|---|---|---|
| Android app | Reader app for Android phones and tablets | S2 Product; S2 Scope: Platform | CONFIRMED |
| iOS app | Reader app for iPhone and iPad | S2 Product; S2 Scope: Platform | CONFIRMED |
| Single codebase | One Flutter codebase for Android and iOS | S2 Scope: Platform; S2 Architecture: Mobile app; CH §19.1 | CONFIRMED |
| Backend services | Accounts, data, private file storage, server logic and notification delivery, on accounts MFW owns. The technology is decided in the architecture document. | S2 Product; S2 Scope: Platform; CH §17.4 | CONFIRMED |
| Web admin panel | MFW's editorial tool. It is the only web interface. | S2 Product; S2 Scope: Admin panel; S2 Not included | CONFIRMED |
| WordPress news integration | Reads news from MFW's existing WordPress site without changing the site | S2 Scope: News; S2 Not included | CONFIRMED |
| Release and handover | Signed builds, store submission, source code, documentation, administrator guide and training | S2 Scope: Release; S2 Handover; CH §11 | CONFIRMED |

Release and handover items are listed for completeness. This document covers only their product-facing requirements (NFR-MAINT-001 to NFR-MAINT-004 and NFR-PRIV-002).

### 2.3 Out of scope

The items below are not in the agreed scope. Any of them can be added later only through the S2 change process [S2 Not included; S2 Changes].

| Capability | Source | Status |
|---|---|---|
| Sign in with Apple | S2 Not included; CH §17.3 | CONFIRMED |
| Guest reading and a public sample issue | S3 via CH §9, §17.3. S2 had included a public sample (C-01). | PROVISIONAL |
| Reading an issue before its full download finishes (server-prepared page images) | S2 Not included | CONFIRMED |
| Scheduled notifications, audience segments, delivery and open statistics | S2 Not included | CONFIRMED |
| A readership analytics dashboard | S2 Not included | CONFIRMED |
| Per-user reading-activity tracking | S3 via CH §10, §17.3. Consistent with the S2 dashboard exclusion. | PROVISIONAL |
| Editorial roles, draft and review, scheduled publishing, audit log | S2 Not included | CONFIRMED |
| Shared links that open the app directly | S2 Not included | CONFIRMED |
| Lead capture forms and sponsor placement slots | S2 Not included | CONFIRMED |
| Payments, subscriptions and paywalls | S2 Not included | CONFIRMED |
| A public web version of the reader | S2 Not included | CONFIRMED |
| Changes to the WordPress site, and writing news in the admin panel | S2 Not included | CONFIRMED |
| Marketplace and community features, AI features, advertising platforms, enterprise analytics | S2 Not included | CONFIRMED |
| Integrations with CRM, email-marketing, accounting or ticketing systems | S2 Not included | CONFIRMED |
| Creating or entering production issues, news and notifications. MFW's team does this. | S2 Not included | CONFIRMED |
| Languages other than English | S2 Not included | CONFIRMED |
| Writing legal documents, including the privacy policy and terms of use | S2 Not included | CONFIRMED |
| Copy protection beyond login gating and private storage. There is no DRM. | S2 Not included | CONFIRMED |
| Third-party charges, an independent penetration test, devices outside the agreed test list | S2 Not included | CONFIRMED |
| A guarantee of store approval or its timing | S2 Not included | CONFIRMED |
| Support after the 30-day warranty | S2 Not included | CONFIRMED |
| Search inside the text of PDF pages | DEV (ASM-10). S2 Scope: Discovery names title, description and category only. | ASSUMPTION |

Google Sign-In was a later-phase item in S1 and S2. The charter records it as moved into scope [S3 via CH §17.3]. See FR-AUTH-005 and C-04.

## 3. Stakeholders and User Roles

### 3.1 Stakeholders

| Stakeholder | Interest in this document | Source |
|---|---|---|
| MFW authorised approver and deputy | Review and approve the requirements in writing. Names are not yet recorded (OQ-28). | S2 Responsibilities; CH §19.3 D1 |
| MFW editorial and admin team | Admin panel and content requirements | S2 Objectives; CH §7 |
| Readers | The people the app serves | S2 Objectives; CH §7 |
| Development team | Designs, builds and tests against these requirements | CH §14 |
| External providers | Google and Apple (platform services, sign-in, push delivery, store review) and MFW's WordPress host | CH §7, §14 |

### 3.2 User roles and access states

| Role or state | Definition | Source | Status |
|---|---|---|---|
| Logged-out visitor | Anyone using the app without being signed in | S2 Scope: Accounts; CH §9 | CONFIRMED |
| Signed-in reader, access incomplete | A signed-in reader whose email address is not yet verified (email accounts), or whose mandatory profile is incomplete | S2 AC-3; S3 via CH §9 | CONFIRMED for the unverified email. PROVISIONAL for the profile condition. |
| Signed-in reader, full access | A signed-in reader with a verified email address (email accounts) and a complete mandatory profile. How verification applies to Google accounts is OQ-04. | S2 AC-3; S3 via CH §9 | CONFIRMED for the verified email. PROVISIONAL for the profile condition. |
| Administrator | A member of MFW's editorial team with an admin account. There is one admin role. | S2 Assumptions; S2 Architecture: Accounts | CONFIRMED |

No other roles are in scope. Editorial roles and a draft-and-review workflow are excluded [S2 Not included]. In this document, "reader" means a signed-in user of the app and "user" means anyone using the app, signed in or not.

## 4. Product Context and Operating Assumptions

### 4.1 Business objectives

| Ref | Objective | Source | Status |
|---|---|---|---|
| O1 | Give readers an interactive digital edition of the magazine on Android and iOS | S2 Objectives; CH §6 | CONFIRMED |
| O2 | Let readers download issues and read them offline | S2 Objectives; CH §6 | CONFIRMED |
| O3 | Show MFW's industry news in the app without duplicating the WordPress site | S2 Objectives; CH §6 | CONFIRMED |
| O4 | Reach readers directly with notifications about new issues and expo announcements | S2 Objectives; CH §6 | CONFIRMED |
| O5 | Let MFW's editors run the app without developer help | S2 Objectives; CH §6 | CONFIRMED |
| O6 | Give MFW visibility of who registers and reads in the app, through registered users and their profile information. Per-user reading-activity tracking is not included. | S3 via CH §6, §17.3 | PROVISIONAL |

### 4.2 Context

- MFW does not have a mobile app today [CH §4].
- WordPress remains the place where news is written. The app reads news from it and the project does not change the site [S2 Scope: News; S2 Not included].
- MFW owns and pays for the backend cloud project, the Apple and Google accounts and any domain. Developers get role-based access [S2 Responsibilities].
- MFW creates and enters all production content [S2 Not included].
- MFW supplies the privacy policy and terms of use. The developers implement consent and deletion [S2 Not included].
- Every edition is free to registered readers [S2 Not included].

### 4.3 Definitions

| Term | Meaning in this document | Source |
|---|---|---|
| Issue | One magazine edition, held as one PDF file with a cover image and details | S2 Assumptions; S2 Flow 1 |
| Catalogue | The list of published issues shown in the app | S2 AC-1 |
| Public metadata | Issue information shown without sign-in: cover, title, description, category, publication date, and any other fields MFW approves (OQ-13) | CH §9 |
| Full issue | The complete PDF content of an issue | S2 AC-3 |
| Downloaded issue | A complete copy of an issue's PDF in the app's private storage on the device | S2 Flow 3 |
| Downloads screen | The screen that lists downloaded issues and lets the reader delete them | S2 Flow 3 |
| Bookmark | A saved reference to a page of an issue | S2 AC-5 |
| Favourite | An issue the reader has marked as a favourite | S2 AC-5 |
| News post | A post on MFW's WordPress site shown in the app | S2 Scope: News |
| App-level news control | An admin panel setting that hides a post in the app, marks it as breaking, or sends it as a notification | S1 Annex A notes |
| Notification category | A topic a reader can opt into, such as new issues, expo specials or major news | S2 Scope: Notifications; S1 What MFW receives |
| Send log | The admin panel's record of notifications sent | S2 AC-9 |
| Edition-update list | Email addresses of users who opted into edition-update emails | S2 Scope: Accounts; S2 Architecture: Database |
| Registered-user list | The admin view and export of registered readers with their profile information | S3 via CH §8 |

### 4.4 Operating assumptions

The S2 planning assumptions (ASM-01 to ASM-09) and the development-team assumptions in this document (ASM-10 to ASM-15) are listed in Section 12.1. S2 states that its assumptions are checked at M1 using the sample PDFs and WordPress access, and that any extra work caused by a wrong assumption follows the change process [S2 Assumptions].

## 5. Functional Requirements

Each requirement has a stable ID, the requirement, its source and its status. Verification methods and dependencies are in the traceability matrix in Section 13.

### 5.1 Authentication and account lifecycle

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-AUTH-001 | A visitor can register an account with an email address and a password. | S2 Scope: Accounts; S2 AC-3; S1 A-26 | CONFIRMED |
| FR-AUTH-002 | After an email registration, the system sends a verification email to the address given. | S2 Scope: Accounts; S2 AC-3 | CONFIRMED |
| FR-AUTH-003 | A reader with an email account can sign in with the email address and password. | S2 AC-3; S2 Milestones (M3) | CONFIRMED |
| FR-AUTH-004 | A reader with an email account can reset a forgotten password. | S2 Scope: Accounts; S2 AC-3; S1 A-29 | CONFIRMED |
| FR-AUTH-005 | A visitor can register and sign in with Google Sign-In on Android and iOS. | S3 via CH §8, §17.3. Conflicts with S1 A-27 and S2 Not included (C-04). | PROVISIONAL |
| FR-AUTH-006 | The product applies one defined rule when an email address already registered with one sign-in method is used with the other. The rule is set by OQ-05. | DEV; follows from FR-AUTH-001 and FR-AUTH-005 | OPEN |
| FR-AUTH-007 | Whether and how email verification applies to Google accounts is set by OQ-04. | CH §9, §19.3 D5 | OPEN |
| FR-AUTH-008 | A signed-in reader can sign out. | DEV (ASM-11); S1 A-29 | ASSUMPTION |
| FR-AUTH-009 | A signed-in reader can delete their account from inside the app. | S2 Scope: Accounts; S2 AC-3; S1 What MFW receives | CONFIRMED |
| FR-AUTH-010 | When a logged-out visitor or a reader with an unverified email tries to open or download a full issue, the app shows a sign-in prompt and does not open the issue. | S2 AC-3 | CONFIRMED |

### 5.2 Mandatory reader profile

All profile requirements below come from the S3 amendment recorded in the charter. They stay PROVISIONAL until the S3 record is filed or MFW confirms them in writing (OQ-29). Collecting these fields raises privacy, age-related and platform-policy questions that this document does not decide (OQ-01, OQ-02, OQ-07; CH §18 R10, R11).

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-PROF-001 | A reader's registration is complete only when every mandatory profile field has been provided. | S3 via CH §8, §9, §17.3 | PROVISIONAL |
| FR-PROF-002 | The mandatory profile fields include name, exact age, gender, occupation and domain of work. Any further fields, and each field's format and allowed values, are set by OQ-01 and OQ-02. | S3 via CH §8, §9 | PROVISIONAL |
| FR-PROF-003 | A reader who registers with Google Sign-In completes the same mandatory profile. When this happens is set by OQ-03. | S3 via CH §9; CH §19.3 D2 | PROVISIONAL |
| FR-PROF-004 | A signed-in reader whose profile is incomplete is asked to complete it when trying to open or download a full issue. The issue opens only after the profile is complete. | S3 via CH §9 | PROVISIONAL |
| FR-PROF-005 | Age is collected with no minimum-age restriction and no parental-consent flow. This position carries risk CH §18 R10 and is subject to OQ-07. | S3 via CH §9; CH §18 R10 | PROVISIONAL |
| FR-PROF-006 | The app has a profile screen where a signed-in reader can see their account and profile information. | S1 A-10 | CONFIRMED |
| FR-PROF-007 | A signed-in reader can update their profile fields. | DEV; S1 A-10; CH §8 | ASSUMPTION |

### 5.3 Public catalogue and magazine metadata

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-MAG-001 | The app shows the catalogue of published issues to every user, including logged-out visitors. | S2 Scope: Accounts; CH §9 | CONFIRMED |
| FR-MAG-002 | Each issue in the catalogue shows its cover, title, publication date and description. | S2 AC-1 | CONFIRMED |
| FR-MAG-003 | Each issue shows its category. | S1 What MFW receives; CH §8 | CONFIRMED |
| FR-MAG-004 | The catalogue presents the latest issue and an archive of earlier issues. At launch it holds the latest issue and four to six archive issues. | S2 Scope: Reader; S2 AC-1 | CONFIRMED |
| FR-MAG-005 | An issue details screen shows the issue's public metadata and the action to read or download the issue. | S1 A-5 | CONFIRMED |
| FR-MAG-006 | The app has a home screen. Its content is set in the M2 screen designs. | S1 A-2; S2 Scope: Design | CONFIRMED |
| FR-MAG-007 | An issue published in the admin panel appears in the app after a pull-to-refresh, without an app update. | S2 AC-1 | CONFIRMED |
| FR-MAG-008 | An issue unpublished in the admin panel no longer appears in the app after a refresh. | S2 AC-8 | CONFIRMED |
| FR-MAG-009 | The complete list of public metadata fields shown to logged-out visitors is set by OQ-13. | CH §9 | OPEN |

### 5.4 Search, filters, categories, years and editions

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-SRCH-001 | A user can search issues by title, description and category. | S2 Scope: Discovery; S2 AC-1 | CONFIRMED |
| FR-SRCH-002 | A user can filter issues by category. | S2 Scope: Discovery; S2 AC-1 | CONFIRMED |
| FR-SRCH-003 | A user can filter issues by industry segment. The meaning of "industry segment" is set by OQ-13. | S2 Scope: Discovery; CH §8 | CONFIRMED |
| FR-SRCH-004 | A user can filter issues by year. | S2 Scope: Discovery; S2 AC-1 | CONFIRMED |
| FR-SRCH-005 | A user can filter issues by edition. The meaning of "edition" is set by OQ-13. | S2 Scope: Discovery; S2 AC-1 | CONFIRMED |
| FR-SRCH-006 | Search and filters are available to logged-out visitors and operate on public metadata. | DEV (ASM-14); CH §9 | ASSUMPTION |
| FR-SRCH-007 | Search covers issue metadata only, not the text inside PDF pages. | DEV (ASM-10); S2 Scope: Discovery | ASSUMPTION |

### 5.5 Magazine reading experience

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-READ-001 | A full issue opens only for a signed-in reader. For email accounts, the email address must be verified. | S2 AC-3; S2 Architecture: File storage; CH §9 | CONFIRMED |
| FR-READ-002 | A full issue is read from a complete copy downloaded to the device. Reading an issue before its download finishes is not provided. | S2 Assumptions; S2 Flow 3; S2 Not included; CH §18 R2 | CONFIRMED |
| FR-READ-003 | The reader can turn pages by swiping. | S2 Scope: Reader; S2 AC-2 | CONFIRMED |
| FR-READ-004 | The reader can turn pages by tapping. | S2 AC-2 | CONFIRMED |
| FR-READ-005 | The reader can pinch to zoom a page up to 300%. | S2 Scope: Reader; S2 AC-2 | CONFIRMED |
| FR-READ-006 | The reader offers a page-turn effect. The reader approach is confirmed at M2 after the reader test on MFW's PDFs, or an agreed alternative is recorded. | S2 Scope: Reader; S2 Milestones (M2); S1 What MFW receives; CH §19.3 D3 | CONFIRMED |
| FR-READ-007 | The reader offers a plain swipe mode. A swipe-and-zoom reader is always built as the fallback. | S1 What MFW receives; S2 Rationale; S2 Risks | CONFIRMED |
| FR-READ-008 | Whether a reader can switch between the page-turn and swipe modes, and which mode is the default, is set by OQ-14. | DEV; CH §5 | OPEN |
| FR-READ-009 | On tablets and in landscape orientation, the reader shows two pages side by side. | S2 Scope: Reader; S2 AC-2 | CONFIRMED |
| FR-READ-010 | If an issue file is damaged, the app shows an error with a retry option. | S2 AC-2 | CONFIRMED |

### 5.6 PDF handling and offline downloads

S2 assumes that readers download an issue before reading it [S2 Assumptions]. In S2, opening a full issue and keeping it for offline reading use the same downloaded copy. The charter's access table lists reading and downloading as separate capabilities [CH §9]. OQ-08 settles whether they are one action or two.

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-DL-001 | A reader with full access can download an issue to the app's private storage on the device. | S2 Flow 3; S2 Scope: Reader; S2 AC-4 | CONFIRMED |
| FR-DL-002 | Logged-out visitors and readers with an unverified email cannot download a full issue. | S2 AC-3; CH §9 | CONFIRMED |
| FR-DL-003 | The app shows an issue's file size before the download starts. | S2 AC-4 | CONFIRMED |
| FR-DL-004 | When the device is using mobile data, the app shows a warning before the download starts. | S2 Scope: Reader; S2 AC-4 | CONFIRMED |
| FR-DL-005 | The app shows download progress. | S2 Scope: Reader; S2 AC-4 | CONFIRMED |
| FR-DL-006 | A download interrupted by a network break resumes when the network returns, without starting again from the beginning. | S2 Scope: Reader; S2 Flow 3; S2 AC-4 | CONFIRMED |
| FR-DL-007 | A downloaded issue opens and can be read in full with no network connection. | S2 AC-4 | CONFIRMED |
| FR-DL-008 | A Downloads screen lists the issues stored on the device. | S2 Flow 3; S1 A-9 | CONFIRMED |
| FR-DL-009 | A reader can delete a downloaded issue from the Downloads screen, and deleting it frees its storage space. | S2 Flow 3; S2 AC-4 | CONFIRMED |
| FR-DL-010 | What happens to downloaded issues when the reader signs out, deletes the account, or the issue is unpublished is set by OQ-11. | DEV | OPEN |

### 5.7 Bookmarks and favourites

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-BKM-001 | A signed-in reader can bookmark a page of an issue. | S2 Scope: Reader; S2 AC-5 | CONFIRMED |
| FR-BKM-002 | Opening a bookmark opens the issue at the bookmarked page. | S2 AC-5 | CONFIRMED |
| FR-BKM-003 | A signed-in reader can mark and unmark an issue as a favourite, and the change shows at once. | S2 Scope: Reader; S2 AC-5 | CONFIRMED |
| FR-BKM-004 | Bookmarks and favourites are stored with the reader's account and appear when the reader signs in on a second device. | S2 AC-5; CH §8 | CONFIRMED |
| FR-BKM-005 | A reader cannot see another reader's bookmarks or favourites. | S2 AC-5; S2 Rationale | CONFIRMED |
| FR-BKM-006 | The app has screens that list the reader's bookmarks and favourites. | S1 A-9 | CONFIRMED |
| FR-BKM-007 | A reader can remove a bookmark. | DEV | ASSUMPTION |
| FR-BKM-008 | Whether bookmarks and favourites can be viewed and changed offline, and how offline changes are synchronised, is set by OQ-10. | DEV | OPEN |

### 5.8 News and WordPress integration

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-NEWS-001 | The app shows a news list of the latest posts from MFW's WordPress site, each with its image, title, date and category. | S2 Scope: News; S2 AC-7 | CONFIRMED |
| FR-NEWS-002 | A user can open a news article page that shows the post's content. | S2 Scope: News; S1 A-7 | CONFIRMED |
| FR-NEWS-003 | A user can filter the news list by category. | S2 AC-7 | CONFIRMED |
| FR-NEWS-004 | A new WordPress post appears in the app after a refresh. | S2 AC-7 | CONFIRMED |
| FR-NEWS-005 | Articles already loaded stay readable without a network connection, with a notice that the app is offline. | S2 Scope: News; S2 AC-7 | CONFIRMED |
| FR-NEWS-006 | Whether articles are kept for offline reading by an explicit save action or automatically, and how many are kept, is set by OQ-16. | S2 Scope: News; S2 AC-7 | OPEN |
| FR-NEWS-007 | The news list and articles are available to logged-out visitors. | S2 Scope: Accounts; S2 AC-3; S3 via CH §17.3 | CONFIRMED |
| FR-NEWS-008 | A post hidden in the admin panel does not appear in the app after a refresh. | S2 AC-8; S1 Annex A notes | CONFIRMED |
| FR-NEWS-009 | How a post marked as breaking is presented in the app is set by OQ-17. | S1 Annex A notes | OPEN |

S2 AC-3 restricts only full issues and issue files, so S2 leaves news open to logged-out users. The charter restates this [S3 via CH §17.3].

### 5.9 Sharing

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-SHR-001 | A reader can share an issue through the device's share sheet, with the issue's title and a link. | S2 Scope: Reader; S2 AC-6 | CONFIRMED |
| FR-SHR-002 | The link shared for an issue points to the app's store listing. The exact link is set by OQ-15. | S3 via CH §8, §17.3 | PROVISIONAL |
| FR-SHR-003 | A reader can share a news article through the share sheet, with the article's title and a link. | S2 AC-6; S1 A-16 | CONFIRMED |
| FR-SHR-004 | The link shared for an article is the article's public address on MFW's WordPress site. | S3 via CH §8, §17.3 | PROVISIONAL |
| FR-SHR-005 | Shared links do not open the app directly. | S2 Not included | CONFIRMED |
| FR-SHR-006 | Sharing never sends the issue PDF file. | DEV; S2 Flow 3; S2 Not included | ASSUMPTION |

Whether logged-out visitors can share is set by OQ-09.

### 5.10 Push notifications and notification preferences

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-NOTIF-001 | Before the system permission prompt appears, the app explains what notifications it sends. | S2 Scope: Notifications; S2 AC-9 | CONFIRMED |
| FR-NOTIF-002 | A reader can choose which notification categories to receive. | S2 Scope: Notifications; S2 AC-9 | CONFIRMED |
| FR-NOTIF-003 | A reader can change category choices later in the app's settings. | S2 Scope: Notifications; S1 A-10 | CONFIRMED |
| FR-NOTIF-004 | A notification sent to a category reaches only devices that opted in to notifications and chose that category. | S2 AC-9; S1 What MFW receives | CONFIRMED |
| FR-NOTIF-005 | Tapping a notification opens the linked issue or article in the app. Access rules still apply (BR-005). | S2 Scope: Notifications; S2 AC-9 | CONFIRMED |
| FR-NOTIF-006 | Notification categories cover new issues, expo specials and major news. The final list is set by OQ-18. | S1 What MFW receives; S2 Objectives | CONFIRMED |
| FR-NOTIF-007 | Whether logged-out visitors can receive notifications and set preferences is set by OQ-09. | CH §7; S2 Scope: Notifications | OPEN |

### 5.11 Edition-update email sign-up

S1 and S2 include an optional sign-up for edition-update emails. The charter's scope table leaves it out and does not list its removal as an amendment. The requirements below keep the S2 baseline until C-02 is resolved (OQ-31).

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-EMAIL-001 | A user can optionally sign up to receive edition-update emails. | S2 Scope: Accounts; S2 Architecture: Database; S1 A-10, A-19; S1 Annex A notes | CONFLICT |
| FR-EMAIL-002 | A user who signed up can withdraw from the edition-update list. | DEV | ASSUMPTION |
| FR-EMAIL-003 | The product does not send edition-update emails or connect to an email-marketing service. MFW sends the emails using the exported list (FR-USER-001). | DEV (ASM-12); S2 Not included; S2 AC-8 | ASSUMPTION |

### 5.12 Admin panel and content management

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-ADMIN-001 | The admin panel is a web application. It is the product's only web interface. | S2 Product; S2 Not included | CONFIRMED |
| FR-ADMIN-002 | The admin panel requires sign-in and refuses wrong passwords. | S2 Scope: Admin panel; S2 AC-8 | CONFIRMED |
| FR-ADMIN-003 | The admin panel refuses accounts that do not have the admin role. | S2 AC-8; S1 A-31 | CONFIRMED |
| FR-ADMIN-004 | There is one admin role, and every admin has the same permissions. | S2 Assumptions; S2 Not included | CONFIRMED |
| FR-ADMIN-005 | An admin can upload an issue's PDF and cover image. | S2 Scope: Admin panel; S2 Flow 1; S1 A-32 | CONFIRMED |
| FR-ADMIN-006 | An upload is rejected with a clear message when the file is not a genuine PDF, including a non-PDF file renamed to look like a PDF. | S2 Flow 1; S2 AC-8 | CONFIRMED |
| FR-ADMIN-007 | An upload is rejected with a clear message when the PDF is larger than the size limit, which is 150 MB by default. Whether a file of exactly 150 MB is accepted, and whether admins can change the limit, is set by OQ-30. | S2 Flow 1; S2 AC-8 | CONFIRMED |
| FR-ADMIN-008 | Checks on the cover image, such as format, dimensions and file size, are set by OQ-22. | S2 Scope: Admin panel | OPEN |
| FR-ADMIN-009 | An admin can enter and edit an issue's details: title, description, category, industry segment, publication date, year and edition. | S2 Scope: Admin panel; S2 Scope: Discovery; S2 AC-1 | CONFIRMED |
| FR-ADMIN-010 | An admin can create and maintain issue categories. | S2 Scope: Admin panel; S2 AC-8 | CONFIRMED |
| FR-ADMIN-011 | An admin can publish and unpublish an issue. | S2 Scope: Admin panel; S2 AC-8; S1 A-33 | CONFIRMED |
| FR-ADMIN-012 | Whether an admin can permanently delete an issue or replace its PDF is set by OQ-21. | DEV | OPEN |
| FR-ADMIN-013 | An admin can hide a WordPress post from the app. | S1 Annex A notes; S2 AC-8 | CONFIRMED |
| FR-ADMIN-014 | An admin can mark a WordPress post as breaking. | S1 Annex A notes | CONFIRMED |
| FR-ADMIN-015 | An admin can send a WordPress post as a breaking-news notification. | S2 Scope: Notifications; S1 Annex A notes | CONFIRMED |
| FR-ADMIN-016 | An admin can send a push notification to a chosen category, linked to an issue or a news article. | S2 Scope: Notifications; S2 AC-9; S1 A-36 | CONFIRMED |
| FR-ADMIN-017 | Only admins can send notifications. | S2 AC-9 | CONFIRMED |
| FR-ADMIN-018 | A send log records each notification sent. The fields recorded are set by OQ-19. | S2 Scope: Notifications; S2 AC-9 | CONFIRMED |
| FR-ADMIN-019 | News is not written or edited in the admin panel. The panel adds app-level controls only. | S2 Not included; S2 Assumptions | CONFIRMED |

### 5.13 User administration and reporting

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-USER-001 | An admin can export the subscriber list to CSV. The S1 Annex A notes define "subscription" in lines 10 and 19 as the optional email-update sign-up. | S2 Scope: Admin panel; S2 AC-8; S1 A-35; S1 Annex A notes | CONFLICT |
| FR-USER-002 | An admin can view a list of registered users with their profile information. | S3 via CH §6, §8, §16 | PROVISIONAL |
| FR-USER-003 | An admin can export the registered-user list, with profile information, to CSV. | S3 via CH §6, §8, §16 | PROVISIONAL |
| FR-USER-004 | The admin panel has no readership analytics dashboard. | S2 Not included; CH §10 | CONFIRMED |
| FR-USER-005 | How admin accounts are created and removed is set by OQ-20. | S1 What we need from MFW | OPEN |

### 5.14 Error, empty, loading and recovery states

The confirmed state requirements sit with their features: FR-AUTH-010, FR-READ-010, FR-DL-006, FR-NEWS-005, FR-ADMIN-006 and FR-ADMIN-007. The requirements below are development-team proposals. S1 and S2 do not state them. The exact states are designed and approved with the M2 screens [S2 Scope: Design] (ASM-13).

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-STATE-001 | While a screen loads remote content, it shows a loading indicator. | DEV (ASM-13) | ASSUMPTION |
| FR-STATE-002 | The app shows an explanatory empty state when there are no search or filter results, no downloads, no bookmarks, no favourites, or no news in a chosen category. | DEV (ASM-13) | ASSUMPTION |
| FR-STATE-003 | When a screen needs the network and none is available, the app says so and offers a retry. Downloaded issues remain available. | DEV (ASM-13); S2 AC-4; S2 AC-7 | ASSUMPTION |
| FR-STATE-004 | If the device does not have enough free space for a download, the app tells the reader, and a partial file is not listed as a downloaded issue. | DEV (ASM-13) | ASSUMPTION |
| FR-STATE-005 | If MFW's WordPress site cannot be reached, the app shows previously loaded articles where available, with a message. | DEV (ASM-13); S2 Risks | ASSUMPTION |
| FR-STATE-006 | If a download fails and cannot resume, the app shows an error with a retry option. | DEV (ASM-13); S2 AC-4 | ASSUMPTION |
| FR-STATE-007 | The admin panel confirms the result of each upload, publish, unpublish and notification send, or shows a clear error. | DEV (ASM-13); S2 AC-8 | ASSUMPTION |

### 5.15 Account privacy, consent and deletion

| ID | Requirement | Source | Status |
|---|---|---|---|
| FR-PRIV-001 | The app implements reader consent to MFW's privacy policy and terms of use at registration. How consent is recorded is set by OQ-27. | S2 Not included; CH §9 | CONFIRMED |
| FR-PRIV-002 | MFW's privacy policy and terms of use can be opened from inside the app. | DEV; S2 AC-11 | ASSUMPTION |
| FR-PRIV-003 | Deleting an account removes the reader's data: the account, profile, bookmarks, favourites, notification preferences and any edition-update sign-up. Any record kept after deletion is set by OQ-24. | S2 AC-3; S2 Architecture: Server logic | CONFIRMED |
| FR-PRIV-004 | The app asks the reader to confirm before deleting the account. | DEV | ASSUMPTION |

## 6. Non-Functional Requirements

S2 AC-2 sets the only numeric targets. S2 says they are confirmed at the end of Week 2, after testing on MFW's sample PDFs [S2 AC-2 and the text above the S2 acceptance criteria]. No user-volume, concurrency, availability or other performance targets have been agreed [CH §6]. This document adds none.

### 6.1 Performance

| ID | Requirement | Source | Status |
|---|---|---|---|
| NFR-PERF-001 | A downloaded sample issue shows its first page within 3 seconds on the agreed mid-range test phone. | S2 AC-2 | CONFIRMED |
| NFR-PERF-002 | Text on a page is sharp at 300% pinch zoom. | S2 AC-2 | CONFIRMED |

### 6.2 Reliability and recovery

| ID | Requirement | Source | Status |
|---|---|---|---|
| NFR-REL-001 | Twenty page turns in a row cause no crash. | S2 AC-2 | CONFIRMED |
| NFR-REL-002 | No critical or high defect is open when acceptance testing starts. Acceptance is signed off only when no critical or high defect is open. Severity levels are those defined in S2 (Section 10.1). | S2 AC-10; S2 Acceptance testing | CONFIRMED |
| NFR-REL-003 | Notification delivery time depends on Apple and Google and is not guaranteed. | S2 AC-9 | CONFIRMED |

Download resume (FR-DL-006) and damaged-file recovery (FR-READ-010) are covered with their features. An outage at Firebase, Apple, Google or the WordPress host is not a product defect [S2 Warranty]. No availability target has been agreed.

### 6.3 Security and access control

| ID | Requirement | Source | Status |
|---|---|---|---|
| NFR-SEC-001 | All network traffic uses HTTPS. | S2 Rationale; S2 Assumptions | CONFIRMED |
| NFR-SEC-002 | The backend enforces access to full issue files. A direct request for an issue file by a logged-out visitor or a reader with an unverified email is refused. | S2 AC-3; S2 Architecture: File storage; CH §18 R4 | CONFIRMED |
| NFR-SEC-003 | Issue PDFs are stored privately in the backend and are not published at a public address. | S2 Flow 1; S2 Architecture: File storage | CONFIRMED |
| NFR-SEC-004 | Downloaded issues are kept in the app's private storage on the device. | S2 Flow 3; S2 Not included | CONFIRMED |
| NFR-SEC-005 | A reader can read and change only their own bookmarks and favourites. | S2 AC-5; S2 Rationale | CONFIRMED |
| NFR-SEC-006 | A reader can read and change only their own profile and notification preferences. Admins can read profiles only through FR-USER-002 and FR-USER-003. | DEV; S2 Rationale | ASSUMPTION |
| NFR-SEC-007 | Only admin accounts can change issues, categories, publication state and news controls. | S2 Rationale; S2 AC-8 | CONFIRMED |
| NFR-SEC-008 | Upload checks are enforced by backend logic, not only by the admin panel interface. | S2 Flow 1 | CONFIRMED |
| NFR-SEC-009 | Content protection is limited to login gating and private storage. There is no DRM. | S2 Not included; CH §9 | CONFIRMED |
| NFR-SEC-010 | The security checklist is completed before acceptance testing. Its contents are defined in the test strategy. | S2 AC-10 | CONFIRMED |
| NFR-SEC-011 | The measures that make admin sign-in secure, such as password rules, two-step verification and session expiry, are set by OQ-20. | S2 Scope: Admin panel | OPEN |
| NFR-SEC-012 | Developers access MFW's accounts through each platform's role-based access, not shared passwords. Credentials are held by MFW. | S2 Responsibilities; S2 AC-12 | CONFIRMED |

### 6.4 Privacy and data minimisation

| ID | Requirement | Source | Status |
|---|---|---|---|
| NFR-PRIV-001 | The app collects only the profile fields in the approved list (OQ-01), for the purpose stated in MFW's privacy policy. | S3 via CH §9; CH §18 R11 | PROVISIONAL |
| NFR-PRIV-002 | The privacy details declared in both app stores match MFW's privacy policy. | S2 AC-11 | CONFIRMED |
| NFR-PRIV-003 | Usage events do not record which reader opened which issue or page. The event list is set by OQ-23. | S3 via CH §10, §17.3; S2 Not included | PROVISIONAL |
| NFR-PRIV-004 | Exports that contain personal data are available only to admin accounts. | DEV; S2 Scope: Admin panel; S2 AC-8 | ASSUMPTION |
| NFR-PRIV-005 | Retention periods for each kind of reader data are set by OQ-24. | CH §19.3 D4 | OPEN |
| NFR-PRIV-006 | MFW's legal adviser reviews the collection of exact age without an age gate or parental-consent flow before release. The outcome is recorded under OQ-07. | CH §18 R10 | OPEN |

### 6.5 Accessibility and usability

| ID | Requirement | Source | Status |
|---|---|---|---|
| NFR-UX-001 | The interface uses MFW's branding: the logo, colours and fonts MFW supplies. | S2 Scope: Design; S1 What we need from MFW | CONFIRMED |
| NFR-UX-002 | MFW approves the screens before they are developed. | S2 Scope: Design; S2 Milestones (M2) | CONFIRMED |
| NFR-UX-003 | All text in the app and the admin panel is in English. | S2 Assumptions; S2 Not included | CONFIRMED |
| NFR-UX-004 | No accessibility standard is stated in S1 or S2. The accessibility baseline is set by OQ-25. | DEV | OPEN |

### 6.6 Compatibility and supported devices

| ID | Requirement | Source | Status |
|---|---|---|---|
| NFR-COMP-001 | The app runs on Android and iOS from one codebase. | S2 Scope: Platform | CONFIRMED |
| NFR-COMP-002 | The reader works on phones and tablets, in portrait and landscape orientation. | S2 Scope: Reader; S2 AC-2 | CONFIRMED |
| NFR-COMP-003 | Testing covers the device set agreed at M1: one low-cost and one mid-range Android phone, an older and a current iPhone, and a tablet where available. | S2 AC-10 | CONFIRMED |
| NFR-COMP-004 | The minimum supported Android and iOS versions are set by OQ-26. | DEV | OPEN |
| NFR-COMP-005 | The web browsers supported for the admin panel are set by OQ-26. | DEV | OPEN |

Devices outside the agreed test list are not covered [S2 Not included].

### 6.7 Storage and bandwidth

| ID | Requirement | Source | Status |
|---|---|---|---|
| NFR-STOR-001 | The product handles issue PDFs of up to 150 MB and about 120 pages. | S2 Assumptions (ASM-01); S2 Flow 1 | ASSUMPTION |
| NFR-STOR-002 | The product handles five to twelve issues live at launch. | S2 Assumptions (ASM-02) | ASSUMPTION |
| NFR-STOR-003 | S2's proposed architecture has no content delivery network at launch, so readers download a whole issue before reading it. Adding one is an architecture decision, and any added cost needs MFW's written approval. | S2 Rationale (ASM-15); CH §17.4; CH §18 R2 | ASSUMPTION |

The verified limit is the upload limit of 150 MB by default (FR-ADMIN-007). The file profile in NFR-STOR-001 and NFR-STOR-002 is an S2 assumption, checked at M1 with MFW's sample PDFs. Download size display, the mobile-data warning and space recovery are covered by FR-DL-003, FR-DL-004 and FR-DL-009. Cloud storage and data transfer are billed to MFW on actual use [S1 Costs outside the fee].

### 6.8 Maintainability and observability

| ID | Requirement | Source | Status |
|---|---|---|---|
| NFR-MAINT-001 | At handover, the source code for the app, backend and admin panel, with its history, is in a repository owned by MFW. | S2 AC-12; S2 Handover | CONFIRMED |
| NFR-MAINT-002 | Following the written documentation, the app can be built and the backend deployed from a clean copy into a fresh backend project. S2 AC-12 names a fresh Firebase project (C-05). | S2 AC-12 | CONFIRMED |
| NFR-MAINT-003 | Android and iOS release builds are signed and made from tagged source code. | S2 AC-11 | CONFIRMED |
| NFR-MAINT-004 | The technical documentation covers set-up, deployment steps, the data model, security rules and third-party licences. | S2 Handover | CONFIRMED |
| NFR-MAINT-005 | The app reaches backend services through a thin data layer, to limit the cost of changing provider later. | S2 Rationale | ASSUMPTION |
| NFR-MAINT-006 | No paid third-party component, such as a commercial flipbook licence, is used without MFW's written approval. | S2 Rationale; S1 Costs outside the fee | CONFIRMED |
| NFR-OBS-001 | Crashes in the Android and iOS apps are reported to a crash-reporting service on MFW's accounts. | S2 Scope: Platform; S2 Flow 5 | CONFIRMED |
| NFR-OBS-002 | Basic usage events are recorded, within the limits of NFR-PRIV-003. | S2 Scope: Platform; S2 Flow 5 | CONFIRMED |

The charter's scope table does not list crash reporting or usage events (C-07). This document keeps the S2 position.

### 6.9 Offline behaviour

| ID | Requirement | Source | Status |
|---|---|---|---|
| NFR-OFF-001 | Without a network connection, a reader can open the Downloads screen and read downloaded issues in full. | S2 AC-4 | CONFIRMED |
| NFR-OFF-002 | Whether catalogue metadata, bookmarks and favourites are available offline is set by OQ-10. | DEV | OPEN |

Offline, the confirmed capabilities are reading downloaded issues (FR-DL-007, NFR-OFF-001) and reading articles already loaded (FR-NEWS-005). Everything else needs a network connection unless OQ-10 decides otherwise.

## 7. Data Requirements

This section states what information the product manages. The data model itself is part of the technical documentation [S2 Handover].

### 7.1 Data entities

| ID | Entity and information | Source | Status |
|---|---|---|---|
| DATA-001 | Issue: title, description, category, industry segment, publication date, year, edition, cover image, PDF file, file size and publication state. | S2 Scope: Discovery; S2 Scope: Admin panel; S2 AC-1; S2 AC-4; S2 Flow 1 | CONFIRMED |
| DATA-002 | Issue category: name. | S2 Scope: Admin panel | CONFIRMED |
| DATA-003 | Reader account: email address, sign-in method and email-verification state. | S2 Architecture: Accounts; S2 AC-3 | CONFIRMED |
| DATA-004 | Reader profile: the mandatory fields in Section 7.2. | S3 via CH §8 | PROVISIONAL |
| DATA-005 | Bookmark: the reader, the issue and the page. | S2 AC-5 | CONFIRMED |
| DATA-006 | Favourite: the reader and the issue. | S2 AC-5 | CONFIRMED |
| DATA-007 | Notification preferences: the categories chosen and the device registration needed to deliver notifications. | S2 Architecture: Database; S2 AC-9 | CONFIRMED |
| DATA-008 | Notification send record: one entry per send. The fields are set by OQ-19. | S2 AC-9 | CONFIRMED |
| DATA-009 | News control: for each WordPress post an admin has acted on, whether it is hidden and whether it is marked as breaking. | S1 Annex A notes; S2 AC-8 | CONFIRMED |
| DATA-010 | Edition-update list: the email addresses of users who opted in. | S2 Architecture: Database; S2 Scope: Accounts | CONFLICT |
| DATA-011 | Admin account: identity and admin role. | S2 Architecture: Accounts | CONFIRMED |
| DATA-012 | Consent record: what the reader agreed to and when. | DEV; supports FR-PRIV-001 | ASSUMPTION |
| DATA-013 | Data on the device: downloaded issue files and previously loaded articles. | S2 Flow 3; S2 AC-7 | CONFIRMED |
| DATA-014 | Crash reports and basic usage events. | S2 Scope: Platform | CONFIRMED |
| DATA-015 | WordPress stays the master source of news content. The product keeps only cached copies of posts and the news controls in DATA-009. | S2 Scope: News; S2 Rationale | CONFIRMED |

### 7.2 Profile fields

| Field | Required | Sensitivity | Source | Status | Open points |
|---|---|---|---|---|---|
| Email address | Yes, for every account | Personal data | S2 AC-3 | CONFIRMED | None |
| Name | Yes | Personal data | S3 via CH §8 | PROVISIONAL | Full name or display name (OQ-01) |
| Exact age | Yes | Personal data. Can identify a reader as a child. | S3 via CH §8, §9 | PROVISIONAL | Age or date of birth (OQ-02). Minors (OQ-07, CH §18 R10). |
| Gender | Yes | Personal data | S3 via CH §8 | PROVISIONAL | Options, and whether "prefer not to say" is offered (OQ-01) |
| Occupation | Yes | Personal data | S3 via CH §8 | PROVISIONAL | Free text or a list (OQ-01) |
| Domain of work | Yes | Personal data | S3 via CH §8 | PROVISIONAL | List of domains (OQ-01) |
| Further fields ("related fields" in CH §8) | Not known | Not known | CH §8 | OPEN | OQ-01 |

The sources identify no optional profile fields. They do not classify any field under data-protection law, and this document makes no legal classification. MFW confirms the field list, the purpose of each field and its legal position with its adviser (OQ-01, OQ-07). The charter records MFW as the party responsible for its readers' personal data [CH §14].

### 7.3 Ownership, retention, deletion and export

| ID | Requirement | Source | Status |
|---|---|---|---|
| DATA-016 | MFW owns its brand, content and reader data. | S1 Key terms | CONFIRMED |
| DATA-017 | Retention periods for accounts, profiles, inactive accounts, send records, consent records, crash data and exports are set by OQ-24. | CH §19.3 D4 | OPEN |

- **Deletion.** Account deletion is covered by FR-AUTH-009 and FR-PRIV-003.
- **Export.** The only exports in scope are the admin CSV exports: the subscriber list (FR-USER-001, CONFLICT) and the registered-user list (FR-USER-003, PROVISIONAL). No reader-facing data export is in the stated scope.

## 8. External Integrations

S2 proposes a technology for each integration [S2 Architecture]. The charter states that the architecture and authentication provider are not approved by the charter and are decided in a recorded decision [CH §17.4]. The requirements below are stated as capabilities. The S2 proposal is listed for reference only.

| Capability | Technology proposed in S2 | Status |
|---|---|---|
| Accounts | Firebase Authentication | OPEN (CH §19.3 D4) |
| Database | Cloud Firestore | OPEN (CH §19.3 D4) |
| File storage | Cloud Storage for Firebase | OPEN (CH §19.3 D4) |
| Server logic | Cloud Functions | OPEN (CH §19.3 D4) |
| Push notifications | Firebase Cloud Messaging, which uses Apple's push service for iPhones | OPEN (CH §19.3 D4) |
| Admin panel | React web app on Firebase Hosting | OPEN (CH §19.3 D4) |
| News | WordPress REST API on MFW's site | OPEN (CH §19.3 D4) |
| Monitoring | Firebase Crashlytics and Analytics | OPEN (CH §19.3 D4) |

S2 M3, S2 AC-12, S1 A-21 to A-25 and S1 What we need from MFW all refer to Firebase (C-05).

### 8.1 WordPress

| ID | Requirement | Source | Status |
|---|---|---|---|
| INT-WP-001 | The app reads news from MFW's existing WordPress site through the site's API over HTTPS. | S2 Scope: News; S2 Assumptions; S2 Architecture: News | CONFIRMED |
| INT-WP-002 | The project makes no changes to the WordPress site. | S2 Not included; CH §3 | CONFIRMED |
| INT-WP-003 | The app shows posts only from the news categories MFW selects. | S1 What we need from MFW | CONFIRMED |
| INT-WP-004 | The app requests posts in small pages and caches recent articles, so it does not overload MFW's website. | S2 Flow 2; S2 Risks | CONFIRMED |
| INT-WP-005 | For each post, the app uses the post's title, image, date, category and content. | S2 Scope: News; S2 AC-7 | CONFIRMED |

The article's public address, used for sharing, is covered by FR-SHR-004.

### 8.2 Authentication provider

| ID | Requirement | Source | Status |
|---|---|---|---|
| INT-AUTH-001 | The authentication service supports email and password sign-up and sign-in, email verification, password reset, account deletion and a separate admin role. | S2 Architecture: Accounts; S2 Scope: Accounts | CONFIRMED |
| INT-AUTH-002 | The authentication service supports Google Sign-In on Android and iOS, configured in accounts MFW owns. | S3 via CH §8, §15 | PROVISIONAL |

### 8.3 Push notification service

| ID | Requirement | Source | Status |
|---|---|---|---|
| INT-PUSH-001 | Notifications are delivered through the platform push services for Android and iOS. On iOS this is Apple's push service. | S2 Architecture: Notifications | CONFIRMED |
| INT-PUSH-002 | iOS push delivery uses MFW's Apple Developer Program account. | S1 What we need from MFW; S2 Assumptions | CONFIRMED |

### 8.4 PDF storage and delivery

| ID | Requirement | Source | Status |
|---|---|---|---|
| INT-FILE-001 | Issue PDFs and cover images are kept in backend file storage on MFW's accounts. Full issues are released over HTTPS only to signed-in readers with a verified email and, once BR-003 is confirmed, a complete profile. | S2 Architecture: File storage; S2 AC-3; S2 Rationale | CONFIRMED |

There is no content delivery network in the S2 proposal (NFR-STOR-003).

### 8.5 App stores

| ID | Requirement | Source | Status |
|---|---|---|---|
| INT-STORE-001 | The app is published through MFW's own Apple App Store and Google Play accounts. | S1 What MFW receives; S2 Assumptions | CONFIRMED |

## 9. Business Rules and Access Matrix

### 9.1 Business rules

| ID | Requirement | Source | Status |
|---|---|---|---|
| BR-001 | There is no guest reading mode and no public sample issue. Logged-out visitors cannot open any issue content. | S3 via CH §9, §17.3. Conflicts with S2 Scope: Accounts and S2 Flow 3 (C-01). | PROVISIONAL |
| BR-002 | Opening or downloading a full issue requires sign-in. For email accounts, it also requires a verified email address. | S2 AC-3; CH §9 | CONFIRMED |
| BR-003 | Opening or downloading a full issue also requires a complete mandatory profile. | S3 via CH §9 | PROVISIONAL |
| BR-004 | Every edition is free to registered readers. There are no payments, subscriptions or paywalls. | S2 Not included; CH §9 | CONFIRMED |
| BR-005 | A notification or link that leads to a full issue follows BR-002 and BR-003. A user without full access sees the relevant prompt instead of the issue. | DEV; S2 AC-3 | ASSUMPTION |

### 9.2 Access matrix

| Capability | Logged-out visitor | Signed in, access incomplete | Signed in, full access | Admin (admin panel) | Basis |
|---|---|---|---|---|---|
| Browse the catalogue and issue details | Yes | Yes | Yes | Not applicable | FR-MAG-001 (CONFIRMED) |
| Search and filter the catalogue | Yes | Yes | Yes | Not applicable | FR-SRCH-006 (ASSUMPTION) |
| Read the news list and articles | Yes | Yes | Yes | Not applicable | FR-NEWS-007 (CONFIRMED) |
| Read previously loaded articles offline | Yes | Yes | Yes | Not applicable | FR-NEWS-005 (CONFIRMED); method OQ-16 |
| Open a full issue | No | No | Yes | Not applicable | BR-002 (CONFIRMED); BR-003 (PROVISIONAL) |
| Download an issue | No | No | Yes | Not applicable | FR-DL-001, FR-DL-002 (CONFIRMED); BR-003 (PROVISIONAL) |
| Bookmark pages | No | No | Yes | Not applicable | FR-BKM-001 (CONFIRMED). A bookmark needs an open issue. |
| Favourite issues | No | OPEN | Yes | Not applicable | FR-BKM-003 (CONFIRMED); OQ-12 |
| Share an issue or article | OPEN | Yes (ASSUMPTION) | Yes | Not applicable | FR-SHR-001, FR-SHR-003 (CONFIRMED); OQ-09 |
| Receive notifications and set preferences | OPEN | Yes (ASSUMPTION) | Yes | Not applicable | FR-NOTIF-002 (CONFIRMED); FR-NOTIF-007 (OPEN); OQ-09 |
| Sign up for edition-update emails | OPEN | OPEN | OPEN | Not applicable | FR-EMAIL-001 (CONFLICT); OQ-09, OQ-31 |
| View and update own profile | No | Yes | Yes | Not applicable | FR-PROF-006 (CONFIRMED); FR-PROF-007 (ASSUMPTION) |
| Delete own account | No | Yes | Yes | Not applicable | FR-AUTH-009 (CONFIRMED) |
| Use admin panel functions | No | No | No | Yes | FR-ADMIN-002, FR-ADMIN-003 (CONFIRMED) |

"Access incomplete" means a signed-in reader whose email is unverified (email accounts), or whose mandatory profile is incomplete (PROVISIONAL). "Full access" means both conditions are met. How verification applies to Google accounts is OQ-04. "Yes (ASSUMPTION)" marks access not stated in S1, S2 or CH and proposed here for approval.

## 10. Acceptance Criteria

### 10.1 Contractual acceptance criteria from S2

S2 sets acceptance criteria AC-1 to AC-12. Each can be observed by a tester and marked pass or fail [S2 Acceptance criteria]. They are summarised below. The S2 text is authoritative, and this document does not change it. The last column shows how the charter's amendments and this document's open items affect each criterion.

| AC | Area | S2 criterion (summary) | Requirements verified | Effect of amendments |
|---|---|---|---|---|
| AC-1 | Browsing and search | The latest issue and four to six archive issues show cover, title, date and description. Category, year and edition filters and search return the right issues. An issue published in the admin panel appears after a pull-to-refresh with no app update. | FR-MAG-002, FR-MAG-004, FR-MAG-007, FR-SRCH-001, FR-SRCH-002, FR-SRCH-004, FR-SRCH-005, FR-ADMIN-009 | None. The industry filter (FR-SRCH-003) is not named in AC-1. See PAC-07. |
| AC-2 | Reader | A downloaded sample issue shows its first page within 3 seconds on the mid-range test phone. Pages turn by swipe or tap. Pinch zoom to 300% shows sharp text. Tablets and landscape show two pages. Twenty page turns in a row cause no crash. A damaged file shows an error with a retry option. | FR-READ-002, FR-READ-003, FR-READ-004, FR-READ-005, FR-READ-006, FR-READ-007, FR-READ-009, FR-READ-010, NFR-PERF-001, NFR-PERF-002, NFR-REL-001, NFR-COMP-002 | Targets are confirmed at the end of Week 2 after testing on MFW's sample PDFs. |
| AC-3 | Accounts | A new reader registers, receives a verification email and can then open a full issue. Guests and unverified readers see a sign-in prompt, and a direct request for the PDF file is refused. Password reset works. Deleting the account removes the reader's data. | FR-AUTH-001, FR-AUTH-002, FR-AUTH-003, FR-AUTH-004, FR-AUTH-009, FR-AUTH-010, FR-READ-001, FR-DL-002, FR-PRIV-003, NFR-SEC-002, BR-002, INT-AUTH-001, INT-FILE-001 | "Guests" is read as logged-out visitors (C-01). Google Sign-In, the profile and the logged-out rules are covered by PAC-01, PAC-02, PAC-04 and PAC-06. |
| AC-4 | Offline downloads | Downloads show progress, open and read fully in airplane mode, and resume after a network break. The file size is shown and a warning appears on mobile data. Deleting a download frees its space. | FR-DL-001, FR-DL-003, FR-DL-004, FR-DL-005, FR-DL-006, FR-DL-007, FR-DL-008, FR-DL-009, NFR-OFF-001 | None. |
| AC-5 | Bookmarks and favourites | A bookmark opens the issue at its page. Favourites update at once. Both appear after signing in on a second device. A reader cannot see another reader's items. | FR-BKM-001, FR-BKM-002, FR-BKM-003, FR-BKM-004, FR-BKM-005, NFR-SEC-005 | None. |
| AC-6 | Sharing | Sharing an article or an issue opens the share sheet with its title and link. | FR-SHR-001, FR-SHR-003 | The link targets are covered by PAC-05. |
| AC-7 | News | The news list shows the latest WordPress posts with image, title, date and category. A new post appears after a refresh. Category filters work. Articles already loaded stay readable offline, with a notice. | FR-NEWS-001, FR-NEWS-002, FR-NEWS-003, FR-NEWS-004, FR-NEWS-005, INT-WP-001, INT-WP-005 | Logged-out access to news is covered by PAC-04. |
| AC-8 | Admin panel | Wrong passwords and non-admin accounts are refused. A valid PDF uploads. A renamed non-PDF or an oversized file is rejected with a clear message. Categories, publishing, unpublishing and hidden news posts show correctly in the app after a refresh. The subscriber list exports to CSV. | FR-ADMIN-002, FR-ADMIN-003, FR-ADMIN-005, FR-ADMIN-006, FR-ADMIN-007, FR-ADMIN-009, FR-ADMIN-010, FR-ADMIN-011, FR-ADMIN-013, FR-MAG-008, FR-NEWS-008, FR-USER-001, NFR-SEC-007 | The meaning of "subscriber list" is C-02. The registered-user list is covered by PAC-03. |
| AC-9 | Notifications | The app explains notifications before the system prompt. A category notification reaches only devices that chose it, and tapping it opens the linked issue or article. The send log records each send. Only admins can send. Delivery time is not guaranteed. | FR-NOTIF-001, FR-NOTIF-002, FR-NOTIF-004, FR-NOTIF-005, FR-ADMIN-016, FR-ADMIN-017, FR-ADMIN-018, NFR-REL-003, INT-PUSH-001, INT-PUSH-002 | None. |
| AC-10 | Testing | A test plan is run and results are recorded for every criterion. The test phones are agreed at M1. The security checklist is completed. No critical or high defect is open when acceptance testing starts. | NFR-COMP-001, NFR-COMP-003, NFR-SEC-010, NFR-REL-002 | Also applies to each PAC that MFW approves. |
| AC-11 | Release | Signed Android and iOS builds are made from tagged source code. Store listings carry text approved by MFW. The privacy details in both stores match MFW's privacy policy. Both builds are submitted and MFW receives the confirmations. | NFR-MAINT-003, NFR-PRIV-002, INT-STORE-001 | None. |
| AC-12 | Handover | Source code with history is in a repository owned by MFW. Following the written documentation, the developer builds the app and deploys the backend from a clean copy into a fresh Firebase project. Credentials are held by MFW. | NFR-MAINT-001, NFR-MAINT-002, NFR-MAINT-004, NFR-SEC-012 | AC-12 names Firebase (C-05). The repository is not yet owned by MFW (CH §19.3 D8). |

**Acceptance testing.** Acceptance testing follows S2. The developers deliver a test build and a test script. MFW has five working days to test and log defects. The developers reply to each item within one working day. MFW checks each fix within two working days. Acceptance is signed off when no critical or high defect is open [S2 Acceptance testing]. The charter re-bases the test-build date to 2 December 2026 [CH §12]. That date is PROVISIONAL (C-08).

| Severity | Meaning, as defined in S2 |
|---|---|
| Critical | Stops the app working or exposes data |
| High | A confirmed feature does not work and there is no workaround |
| Medium | A visible fault with a workaround |
| Low | Cosmetic |

### 10.2 Proposed acceptance criteria awaiting MFW approval

These criteria are development-team proposals. They cover PROVISIONAL requirements and gaps in AC-1 to AC-12. They are not contractual until MFW approves them in writing.

| PAC | Proposed criterion | Requirements verified | Depends on |
|---|---|---|---|
| PAC-01 | On the Android and iOS test builds, a new reader registers with Google Sign-In, completes the mandatory profile and opens a full issue. The same reader signs in with Google on a second device and sees their bookmarks and favourites. | FR-AUTH-005, FR-PROF-003, FR-BKM-004, INT-AUTH-002 | OQ-03, OQ-04, OQ-29 |
| PAC-02 | Registration cannot be completed while any mandatory profile field is empty. A signed-in reader with an incomplete profile who tries to open or download a full issue is asked to complete the profile, and the issue opens after the profile is completed. | FR-PROF-001, FR-PROF-002, FR-PROF-004, BR-003 | OQ-01, OQ-02, OQ-29 |
| PAC-03 | An admin opens the registered-user list, sees each user's profile fields and exports the list to CSV with the same fields. A non-admin account cannot reach the list or the export. | FR-USER-002, FR-USER-003, NFR-PRIV-004 | OQ-01, OQ-29 |
| PAC-04 | A logged-out visitor can browse the catalogue, search and filter it, and read the news list and articles. The visitor cannot open or download any issue content, including any sample. | BR-001, FR-MAG-001, FR-SRCH-006, FR-NEWS-007 | OQ-29 |
| PAC-05 | Sharing an issue produces a link to the app's store listing. Sharing an article produces the article's address on MFW's WordPress site. | FR-SHR-002, FR-SHR-004 | OQ-15, OQ-29 |
| PAC-06 | After a reader deletes their account, the reader cannot sign in with it, and their profile does not appear in the admin list or in a new export. | FR-PRIV-003, FR-USER-002, FR-USER-003 | OQ-24 |
| PAC-07 | Filtering the catalogue by industry segment returns the right issues. | FR-SRCH-003 | OQ-13 |
| PAC-08 | Registration shows links to MFW's privacy policy and terms of use, and an account cannot be created without the reader's agreement. The policy and terms can also be opened from inside the app after registration. | FR-PRIV-001, FR-PRIV-002 | OQ-27 |
| PAC-09 | An inspection of the configured usage events finds no event that records which reader opened which issue or page. | NFR-PRIV-003, NFR-OBS-002 | OQ-23 |
| PAC-10 | Each loading, empty and error state in FR-STATE-001 to FR-STATE-007 matches the screens MFW approved at M2. | FR-STATE-001, FR-STATE-002, FR-STATE-003, FR-STATE-004, FR-STATE-005, FR-STATE-006, FR-STATE-007 | ASM-13 |
| PAC-11 | If FR-EMAIL-001 is kept: a user opts in to edition-update emails, the address appears in the admin CSV export, and after opting out it no longer appears in a new export. | FR-EMAIL-001, FR-EMAIL-002, FR-USER-001 | C-02, OQ-31 |

### 10.3 Verification of other requirements

Requirements without an AC or PAC are verified by test, demonstration, inspection or review, as shown in Section 13. An OPEN or CONFLICT requirement is verified only after its open question or conflict is resolved. Section 13 marks these with **R**.

## 11. Dependencies and Constraints

### 11.1 Constraints

| Constraint | Source | Status |
|---|---|---|
| One Flutter codebase for Android and iOS | S2 Scope: Platform; CH §19.1 | CONFIRMED |
| The backend runs on accounts MFW owns and pays for. MFW also owns the Apple and Google accounts and any domain. Developers use role-based access. | S2 Scope: Platform; S2 Responsibilities | CONFIRMED |
| Architecture, authentication provider, reader library and data model are decided outside this document. S2 proposes Firebase, and S2 M3, S2 AC-12 and S1 A-21 to A-25 refer to it. A different choice that changes these terms or adds third-party cost needs MFW's written approval. | S2 Architecture; CH §17.4 | CONFLICT |
| No paid third-party component without MFW's written approval | S2 Rationale; S1 Costs outside the fee | CONFIRMED |
| Third-party costs, such as cloud usage, developer accounts and any licence or domain, are paid by MFW directly | S1 Costs outside the fee | CONFIRMED |
| Scope is fixed. Changes follow the S2 change process. | S2 Changes; CH §17.2 | CONFIRMED |
| English only | S2 Assumptions | CONFIRMED |
| Store review outcome and timing are outside the team's control. M5 completes at submission. | S2 Milestones; S2 Not included | CONFIRMED |
| Store policies are as published today (ASM-08) | S2 Assumptions | ASSUMPTION |
| Delivery window of eight weeks from 21 October 2026, with store submission by 16 December 2026. Milestones: M1 21 October, M2 4 November, M3 18 November, M4 2 December, M5 16 December 2026. The S1 and S2 dates (16 November 2026 to 8 January 2027) are recorded as superseded. | S3 via CH §12, §17.3 (C-08) | PROVISIONAL |

### 11.2 Dependencies on MFW inputs

The dates below are the charter's re-based dates [CH §12] and are PROVISIONAL (C-08). The repository has no record of which inputs have been received. Under S2, a one-working-day delay on a key input moves the later dates by one working day, and a delay longer than five working days is a schedule change agreed in writing [S2 Responsibilities].

| Input from MFW | Needed by | Requirements that depend on it | Source |
|---|---|---|---|
| Named approver and deputy, and written confirmation that MFW owns or may use the content (ASM-07) | Before 21 Oct 2026 | Section 14 approval | S1 What we need from MFW; CH §12 |
| Logo files, brand colours and fonts | 21 Oct 2026 | NFR-UX-001 | S1 What we need from MFW; CH §12 |
| Two to three sample PDFs, including the largest expected issue | 28 Oct 2026 | NFR-PERF-001, NFR-PERF-002, NFR-STOR-001, FR-READ-006 | S1 What we need from MFW; CH §12 |
| WordPress site address, API confirmation and the news categories to show | 28 Oct 2026 | INT-WP-001, INT-WP-003, INT-WP-004, INT-WP-005 | S1 What we need from MFW; CH §12 |
| Cloud project in MFW's name with billing switched on. S1 names a Firebase and Google Cloud project. | 28 Oct 2026 | INT-AUTH-001, INT-AUTH-002, INT-FILE-001, INT-PUSH-001, NFR-OBS-001 | S1 What we need from MFW; CH §12 |
| Apple Developer Program (organisation) and Google Play accounts | Enrolment in Week 1. Active by 18 Nov 2026. | INT-STORE-001, INT-PUSH-002, FR-SHR-002 | S1 What we need from MFW; CH §12 |
| Privacy policy and terms of use at a public address | 18 Nov 2026 | FR-PRIV-001, FR-PRIV-002, NFR-PRIV-001, NFR-PRIV-002 | S1 What we need from MFW; CH §12 |
| Launch content: the latest issue and four to six archive issues, with their details | 18 Nov 2026 | FR-MAG-004 | S1 What we need from MFW; CH §12 |
| Admin user list and store listing text | 18 Nov to 2 Dec 2026 | FR-USER-005, INT-STORE-001 | S1 What we need from MFW; CH §12 |
| Testers from MFW's team | From 2 Dec 2026 | Section 10 | S1 What we need from MFW; CH §12 |
| Decisions on open questions | As listed in Section 12.2 | As listed in Section 12.2 | This document |

### 11.3 Internal dependencies

| Dependency | Requirements affected | Source |
|---|---|---|
| Reader test on MFW's sample PDFs and reader approach confirmed at M2 (CH D3) | FR-READ-006, FR-READ-007, FR-READ-008, NFR-PERF-001, NFR-PERF-002 | S2 Milestones; CH §19.3 |
| Architecture document (CH D4, D5) | Section 8, NFR-MAINT-005, NFR-STOR-003, FR-AUTH-006, FR-AUTH-007 | CH §17.4, §19.3 |
| Test strategy, including the test plan and security checklist | NFR-SEC-010, NFR-REL-002, Section 10 | S2 AC-10; CH §11 |

## 12. Assumptions, Open Questions and Conflicts

### 12.1 Assumptions

| ID | Assumption | Source | Used by |
|---|---|---|---|
| ASM-01 | Each issue is one PDF of up to 150 MB and about 120 pages. This is checked at M1 with MFW's sample PDFs. | S2 Assumptions | NFR-STOR-001 |
| ASM-02 | Five to twelve issues are live at launch. | S2 Assumptions | NFR-STOR-002 |
| ASM-03 | MFW's WordPress API is switched on and reachable over HTTPS. | S2 Assumptions | INT-WP-001 |
| ASM-04 | The app text is in English only. | S2 Assumptions | NFR-UX-003 |
| ASM-05 | MFW holds the backend cloud project and the organisation accounts with Apple and Google. | S2 Assumptions | INT-STORE-001, INT-PUSH-002 |
| ASM-06 | A small editorial team uses one admin role. | S2 Assumptions | FR-ADMIN-004 |
| ASM-07 | MFW has the rights to all content, logos and images, and supplies the privacy policy. | S2 Assumptions | FR-PRIV-001, NFR-UX-001 |
| ASM-08 | Apple and Google store policies are as published today. | S2 Assumptions | Section 11.1 |
| ASM-09 | Readers download an issue before reading it. | S2 Assumptions | FR-READ-002 |
| ASM-10 | Search and filters use issue metadata only, not the text inside PDFs. | DEV; S2 Scope: Discovery | FR-SRCH-007 |
| ASM-11 | Sign-out is part of the "account management" line in S1. | DEV; S1 A-29 | FR-AUTH-008 |
| ASM-12 | If edition-update emails are kept, MFW sends them with its own tools using the exported list. The product does not send them. | DEV; S2 Not included | FR-EMAIL-003 |
| ASM-13 | Loading, empty and error states are designed and approved with the M2 screens. | DEV; S2 Scope: Design | FR-STATE-001 to FR-STATE-007 |
| ASM-14 | Logged-out visitors can search and filter the catalogue, because S2 included guest browsing and the charter places search on public metadata. | DEV; S2 Scope: Accounts; CH §9 | FR-SRCH-006 |
| ASM-15 | S2's proposed architecture has no content delivery network at launch. | S2 Rationale | NFR-STOR-003 |

### 12.2 Open questions

Owners and target milestones are proposals. Milestone dates are in Section 11.1.

| ID | Question | Affects | Charter ref | Owner | Needed by |
|---|---|---|---|---|---|
| OQ-01 | What is the final mandatory profile field list? For each field: format and allowed values (gender options, occupation and domain lists), and whether a "prefer not to say" option is offered. What does "related fields" in CH §8 include? | FR-PROF-002, DATA-004, NFR-PRIV-001 | D2 | MFW | Before M2 approval |
| OQ-02 | Is exact age stored as a number or as a date of birth, and how does it stay current? | FR-PROF-002, DATA-004 | D2 | MFW, with the development team | Before M2 approval |
| OQ-03 | When does a Google Sign-In reader complete the mandatory profile: straight after the first sign-in, or before the first full issue? | FR-PROF-003 | D2 | MFW | Before M2 approval |
| OQ-04 | Does email verification apply to Google accounts, and if so, how? | FR-AUTH-007, BR-002 | D5 | Development team, MFW approval | Architecture document |
| OQ-05 | What happens when an email address already registered with email and password is used for Google Sign-In, or the reverse? | FR-AUTH-006 | D4, D5 | Development team, MFW approval | Architecture document |
| OQ-06 | Does MFW confirm in writing that it accepts the App Store guideline 4.8 risk of offering Google Sign-In without Sign in with Apple? | FR-AUTH-005 | R9 | MFW | Before M3 |
| OQ-07 | Does MFW's legal adviser confirm the approach to collecting exact age with no age gate or parental-consent flow? | FR-PROF-005, NFR-PRIV-006 | R10 | MFW and its legal adviser | Before the profile is built (M3) |
| OQ-08 | Does opening a full issue always keep it on the device as an offline copy, or is there a temporary copy for reading and a separate action to keep it offline? | FR-READ-002, FR-DL-001, FR-DL-008 | None (C-03) | MFW, with the development team | Before M2 approval |
| OQ-09 | Can logged-out visitors receive push notifications and set preferences, share issues and articles, and sign up for edition-update emails? | FR-NOTIF-007, FR-SHR-001, FR-SHR-003, FR-EMAIL-001, DATA-007 | None | MFW | Before M2 approval |
| OQ-10 | Are catalogue metadata, bookmarks and favourites available offline, and can bookmarks and favourites be changed offline and synchronised later? | FR-BKM-008, NFR-OFF-002 | None | Development team, MFW approval | Before M2 approval |
| OQ-11 | What happens to downloaded issues when the reader signs out, deletes the account, or the issue is unpublished? | FR-DL-010, DATA-013 | None | MFW | Before M3 |
| OQ-12 | Can a signed-in reader without full access use favourites? | FR-BKM-003 | None | MFW | Before M2 approval |
| OQ-13 | What is the complete list of public issue metadata ("other approved metadata" in CH §9), including whether file size and page count show before sign-in? What do "industry segment" and "edition" mean for filtering? | FR-MAG-009, FR-SRCH-003, FR-SRCH-005, DATA-001 | None | MFW | Before M2 approval |
| OQ-14 | Can the reader switch between the page-turn and swipe modes, and which mode is the default? | FR-READ-008 | D3 | Development team, MFW approval | M2 reader test |
| OQ-15 | Which store link is shared for an issue (one link for both stores, or a link per platform), and what is shared before the store listings are live? | FR-SHR-002 | None | MFW, with the development team | Before M4 |
| OQ-16 | Are news articles kept for offline reading by an explicit save action or automatically? How many are kept, and how is embedded media in posts shown? | FR-NEWS-005, FR-NEWS-006 | None | MFW, with the development team | Before M2 approval |
| OQ-17 | How is a post marked as breaking shown in the app? | FR-NEWS-009, FR-ADMIN-014 | None | MFW | Before M2 approval |
| OQ-18 | What is the final list of notification categories, and can admins add or change categories in the admin panel? | FR-NOTIF-006 | None | MFW | Before M2 approval |
| OQ-19 | Which fields does the notification send log record? | FR-ADMIN-018, DATA-008 | None | Development team, MFW approval | Before M3 |
| OQ-20 | How are admin accounts created and removed (set up by the developers from MFW's admin list, or managed in the panel), and what does "secure login" include (password rules, two-step verification, session expiry)? | FR-USER-005, NFR-SEC-011, DATA-011 | None | MFW, with the development team | Before M3 |
| OQ-21 | Can an admin permanently delete an issue or replace its PDF, and what happens to copies already downloaded? | FR-ADMIN-012 | None | MFW | Before M3 |
| OQ-22 | What formats, dimensions and maximum size apply to cover images? | FR-ADMIN-008 | None | MFW, with the development team | Before M3 |
| OQ-23 | Which basic usage events are recorded, and is consent needed before recording them? | NFR-OBS-002, NFR-PRIV-003, DATA-014 | None | MFW, with the development team | Before M3 |
| OQ-24 | What are the retention periods for accounts, profiles, inactive accounts, send records, consent records, crash data and exports? Is any record kept after account deletion? | NFR-PRIV-005, DATA-017, FR-PRIV-003 | D4 | MFW | Before M4 |
| OQ-25 | Which accessibility baseline applies? Proposed for decision: app interface text follows the device's text-size setting, controls have screen-reader labels, and text and controls have enough colour contrast. The baseline would not apply to the PDF page content. | NFR-UX-004 | None | MFW | Before M2 approval |
| OQ-26 | What are the minimum Android and iOS versions, the test device models, and the supported browsers for the admin panel? | NFR-COMP-003, NFR-COMP-004, NFR-COMP-005 | None | MFW, with the development team | M1 |
| OQ-27 | How is consent recorded: a checkbox or an equivalent action, and are the accepted policy version and date stored? | FR-PRIV-001, DATA-012 | None | MFW | Before M2 approval |
| OQ-28 | Are signed or formally accepted copies of S1 and S2 available, and who are MFW's authorised approver and deputy? | All CONFIRMED items; Section 14 | D1 | MFW | Before M1 approval |
| OQ-29 | Can the S3 client emails, or MFW's written confirmation, be filed in the repository so that PROVISIONAL items can be confirmed? How are the S3 amendments recorded formally? | All PROVISIONAL items | D7 | Development team and MFW | Before M2 |
| OQ-30 | Is a PDF of exactly 150 MB accepted, and can admins change the size limit? | FR-ADMIN-007 | None (C-06) | MFW, with the development team | Before M3 |
| OQ-31 | Is the optional edition-update email sign-up kept, dropped, or merged into registration? Does the S2 AC-8 "subscriber list" mean the edition-update list or the registered-user list? | FR-EMAIL-001, FR-USER-001, DATA-010 | None (C-02) | MFW | Before M2 approval |

### 12.3 Conflicts

| ID | Topic | What the sources say | Position used in this document | Decision needed |
|---|---|---|---|---|
| C-01 | Guest reading | S2 Scope: Accounts and S2 Flow 3 include guest browsing with a public sample, and S1 A-28 prices "guest browsing and protected content access". CH §9 and §17.3 record that the public sample is removed and there is no guest reading [S3]. | The CH position, as PROVISIONAL (BR-001). Logged-out visitors still browse metadata and news, which both positions allow. | File S3 or MFW's written confirmation (OQ-29). |
| C-02 | Edition-update emails and the subscriber list | S2 Scope: Accounts includes an optional sign-up for edition-update emails, and S2 Architecture: Database stores an "update list". S2 Scope: Admin panel and S2 AC-8 require a subscriber list with CSV export. The S1 Annex A notes define "subscription" in lines 10 and 19 as the optional email-update sign-up. CH §8 leaves out the sign-up and describes "a list of registered users with CSV export" [S2, S3]. CH §17.3 does not list the sign-up's removal. | The S2 baseline is kept and marked CONFLICT (FR-EMAIL-001, FR-USER-001, DATA-010). The registered-user list is added as PROVISIONAL (FR-USER-002, FR-USER-003). | MFW decides (OQ-31). |
| C-03 | "Online reading" | CH §8 lists "Online reading" under interactive PDF reading. S2 Assumptions, S2 Flow 3 and S2 Not included say that an issue is downloaded in full before reading, and CH §18 R2 agrees. | The S2 position (FR-READ-002). | Clarify the CH §8 wording and resolve OQ-08. |
| C-04 | Google Sign-In | S1 A-27 and the S1 Annex A notes mark Google Sign-In "Not included (later phase)". S2 Not included lists Google sign-in as a later-phase feature. CH §8 and §17.3 record it as in scope within the revised fee [S3]. | The CH position, as PROVISIONAL (FR-AUTH-005). | File S3 or MFW's written confirmation (OQ-29), and MFW's acceptance of risk R9 (OQ-06). |
| C-05 | Architecture status | S2 presents a "Proposed technical architecture" based on Firebase, and CH §11 and §17.4 state that the architecture is not approved. S2 Milestones (M3 "running on MFW's Firebase project"), S2 AC-12 ("a fresh Firebase project"), S1 A-21 to A-25 and S1 What we need from MFW all refer to Firebase. | Requirements are stated as capabilities. Firebase is the S2 baseline. A different choice that changes M3, AC-12 or third-party cost needs MFW's written approval (CH §17.4). | The architecture document (CH §19.3 D4). |
| C-06 | Upload size limit wording | S2 Assumptions say "up to 150 MB". S2 Flow 1 says "within the size limit (150 MB by default)". CH §8 says "under 150 MB per issue". | The S2 wording (FR-ADMIN-007). | Resolve OQ-30. |
| C-07 | Crash reporting and usage events | S2 Scope: Platform includes "crash reporting and basic usage events", and S2 Architecture lists monitoring. CH §8 does not list them. | The S2 position (NFR-OBS-001, NFR-OBS-002), limited by NFR-PRIV-003. | Confirm, and update CH §8 at its next revision. |
| C-08 | Schedule | S1 and S2 set kickoff on 16 November 2026 and store submission on 8 January 2027. CH §12 and §17.3 record a start on 21 October 2026 and submission by 16 December 2026 [S3]. | The CH dates, as PROVISIONAL (Section 11). | File S3 or MFW's written confirmation (OQ-29). |

### 12.4 Related charter risks

| Charter risk | Requirements affected |
|---|---|
| R1 Reader performance, or licence cost of a reader library | FR-READ-006, FR-READ-007, NFR-PERF-001, NFR-MAINT-006 |
| R2 Large PDFs and no content delivery network | NFR-STOR-001, NFR-STOR-003, FR-DL-004, FR-DL-006 |
| R3 Offline content handling | FR-DL-006, FR-DL-009, FR-READ-010, NFR-SEC-004 |
| R4 Protected-content access | NFR-SEC-002, BR-002, BR-003, FR-PROF-004 |
| R5 WordPress API blocked, slow or not enabled | INT-WP-001, INT-WP-004, FR-STATE-005 |
| R8 Store accounts and review | INT-STORE-001, FR-SHR-002 |
| R9 App Store guideline 4.8 | FR-AUTH-005, OQ-06 |
| R10 Minors' data | FR-PROF-005, NFR-PRIV-006, OQ-07 |
| R11 Personal data collection | FR-PROF-002, NFR-PRIV-001, NFR-PRIV-002 |

Risks R6 (parallel development) and R7 (compressed timeline) are delivery risks with no direct product requirement.

## 13. Traceability Matrix

Every requirement ID in Sections 5 to 9 appears once below. The source and status are the same as in the requirement tables.

- **Verification:** AC-n is an S2 acceptance criterion. PAC-nn is a proposed criterion awaiting MFW approval. T is test, D demonstration, I inspection and R review and decision.
- **Depends on:** the open questions, conflicts, assumptions, inputs and other requirements a requirement relies on.

| ID | Requirement (summary) | Source | Status | Verification | Depends on |
|---|---|---|---|---|---|
| FR-AUTH-001 | Register with email and password | S2 Scope: Accounts; S2 AC-3; S1 A-26 | CONFIRMED | AC-3 (T) | INT-AUTH-001 |
| FR-AUTH-002 | Verification email after email registration | S2 Scope: Accounts; S2 AC-3 | CONFIRMED | AC-3 (T) | INT-AUTH-001 |
| FR-AUTH-003 | Sign in with email and password | S2 AC-3; S2 Milestones (M3) | CONFIRMED | AC-3 (T) | INT-AUTH-001 |
| FR-AUTH-004 | Reset a forgotten password | S2 Scope: Accounts; S2 AC-3; S1 A-29 | CONFIRMED | AC-3 (T) | INT-AUTH-001 |
| FR-AUTH-005 | Register and sign in with Google Sign-In | S3 via CH §8, §17.3. Conflicts with S1 A-27 and S2 Not included (C-04). | PROVISIONAL | PAC-01 (T) | C-04, OQ-06, OQ-29, INT-AUTH-002 |
| FR-AUTH-006 | Rule for an email used with both sign-in methods | DEV; follows from FR-AUTH-001 and FR-AUTH-005 | OPEN | R: resolve OQ-05, then T | OQ-05, FR-AUTH-005 |
| FR-AUTH-007 | Email verification for Google accounts | CH §9, §19.3 D5 | OPEN | R: resolve OQ-04, then PAC-01 (T) | OQ-04, FR-AUTH-005 |
| FR-AUTH-008 | Sign out | DEV (ASM-11); S1 A-29 | ASSUMPTION | T | ASM-11 |
| FR-AUTH-009 | Delete account in the app | S2 Scope: Accounts; S2 AC-3; S1 What MFW receives | CONFIRMED | AC-3 (T) | FR-PRIV-003, FR-PRIV-004 |
| FR-AUTH-010 | Sign-in prompt when a full issue is refused | S2 AC-3 | CONFIRMED | AC-3 (T) | BR-002 |
| FR-PROF-001 | Registration needs every mandatory profile field | S3 via CH §8, §9, §17.3 | PROVISIONAL | PAC-02 (T) | OQ-01, OQ-29 |
| FR-PROF-002 | Mandatory fields: name, exact age, gender, occupation, domain of work | S3 via CH §8, §9 | PROVISIONAL | PAC-02 (T); I against the approved field list | OQ-01, OQ-02, OQ-29 |
| FR-PROF-003 | Google Sign-In readers complete the same profile | S3 via CH §9; CH §19.3 D2 | PROVISIONAL | PAC-01 (T) | OQ-03, FR-AUTH-005 |
| FR-PROF-004 | Profile completion prompt before a full issue | S3 via CH §9 | PROVISIONAL | PAC-02 (T) | BR-003, OQ-29 |
| FR-PROF-005 | Age collected with no age gate or parental consent | S3 via CH §9; CH §18 R10 | PROVISIONAL | R: MFW legal review (OQ-07) | OQ-07, NFR-PRIV-006 |
| FR-PROF-006 | Profile screen | S1 A-10 | CONFIRMED | D | FR-PROF-002 |
| FR-PROF-007 | Reader can update profile fields | DEV; S1 A-10; CH §8 | ASSUMPTION | T | FR-PROF-002 |
| FR-MAG-001 | Catalogue visible to every user | S2 Scope: Accounts; CH §9 | CONFIRMED | AC-1 (T); PAC-04 (T) | BR-001 |
| FR-MAG-002 | Cover, title, date and description per issue | S2 AC-1 | CONFIRMED | AC-1 (T) | DATA-001 |
| FR-MAG-003 | Category shown per issue | S1 What MFW receives; CH §8 | CONFIRMED | T | DATA-001, DATA-002 |
| FR-MAG-004 | Latest issue and archive; four to six archive issues at launch | S2 Scope: Reader; S2 AC-1 | CONFIRMED | AC-1 (T) | Launch content from MFW (Section 11.2) |
| FR-MAG-005 | Issue details screen | S1 A-5 | CONFIRMED | D | FR-MAG-009 |
| FR-MAG-006 | Home screen | S1 A-2; S2 Scope: Design | CONFIRMED | D against the M2 designs | NFR-UX-002 |
| FR-MAG-007 | Published issue appears after pull-to-refresh | S2 AC-1 | CONFIRMED | AC-1 (T) | FR-ADMIN-011 |
| FR-MAG-008 | Unpublished issue disappears after refresh | S2 AC-8 | CONFIRMED | AC-8 (T) | FR-ADMIN-011 |
| FR-MAG-009 | Public metadata field list | CH §9 | OPEN | R: resolve OQ-13 | OQ-13 |
| FR-SRCH-001 | Search by title, description and category | S2 Scope: Discovery; S2 AC-1 | CONFIRMED | AC-1 (T) | DATA-001 |
| FR-SRCH-002 | Category filter | S2 Scope: Discovery; S2 AC-1 | CONFIRMED | AC-1 (T) | DATA-002 |
| FR-SRCH-003 | Industry segment filter | S2 Scope: Discovery; CH §8 | CONFIRMED | PAC-07 (T) | OQ-13 |
| FR-SRCH-004 | Year filter | S2 Scope: Discovery; S2 AC-1 | CONFIRMED | AC-1 (T) | DATA-001 |
| FR-SRCH-005 | Edition filter | S2 Scope: Discovery; S2 AC-1 | CONFIRMED | AC-1 (T) | OQ-13 |
| FR-SRCH-006 | Search and filters for logged-out visitors | DEV (ASM-14); CH §9 | ASSUMPTION | PAC-04 (T) | ASM-14 |
| FR-SRCH-007 | Search covers metadata only | DEV (ASM-10); S2 Scope: Discovery | ASSUMPTION | I | ASM-10 |
| FR-READ-001 | Full issue only for signed-in, verified readers | S2 AC-3; S2 Architecture: File storage; CH §9 | CONFIRMED | AC-3 (T) | BR-002, BR-003, NFR-SEC-002 |
| FR-READ-002 | Read from a complete downloaded copy | S2 Assumptions; S2 Flow 3; S2 Not included; CH §18 R2 | CONFIRMED | AC-2 (T); AC-4 (T) | C-03, OQ-08, ASM-09 |
| FR-READ-003 | Swipe to turn pages | S2 Scope: Reader; S2 AC-2 | CONFIRMED | AC-2 (T) | FR-READ-006 |
| FR-READ-004 | Tap to turn pages | S2 AC-2 | CONFIRMED | AC-2 (T) | FR-READ-006 |
| FR-READ-005 | Pinch zoom to 300% | S2 Scope: Reader; S2 AC-2 | CONFIRMED | AC-2 (T) | NFR-PERF-002 |
| FR-READ-006 | Page-turn effect, confirmed at M2 | S2 Scope: Reader; S2 Milestones (M2); S1 What MFW receives; CH §19.3 D3 | CONFIRMED | AC-2 (T); M2 reader test | CH D3; sample PDFs (Section 11.2) |
| FR-READ-007 | Plain swipe mode as the fallback | S1 What MFW receives; S2 Rationale; S2 Risks | CONFIRMED | AC-2 (T) | CH D3 |
| FR-READ-008 | Switching between reader modes | DEV; CH §5 | OPEN | R: resolve OQ-14 | OQ-14 |
| FR-READ-009 | Two pages on tablets and in landscape | S2 Scope: Reader; S2 AC-2 | CONFIRMED | AC-2 (T) | NFR-COMP-002 |
| FR-READ-010 | Damaged file error with retry | S2 AC-2 | CONFIRMED | AC-2 (T) | None |
| FR-DL-001 | Download an issue to private storage | S2 Flow 3; S2 Scope: Reader; S2 AC-4 | CONFIRMED | AC-4 (T) | BR-002, BR-003, NFR-SEC-004, OQ-08 |
| FR-DL-002 | No download without sign-in and a verified email | S2 AC-3; CH §9 | CONFIRMED | AC-3 (T) | NFR-SEC-002 |
| FR-DL-003 | File size shown before download | S2 AC-4 | CONFIRMED | AC-4 (T) | DATA-001 |
| FR-DL-004 | Mobile-data warning before download | S2 Scope: Reader; S2 AC-4 | CONFIRMED | AC-4 (T) | None |
| FR-DL-005 | Download progress | S2 Scope: Reader; S2 AC-4 | CONFIRMED | AC-4 (T) | None |
| FR-DL-006 | Resume after a network break | S2 Scope: Reader; S2 Flow 3; S2 AC-4 | CONFIRMED | AC-4 (T) | None |
| FR-DL-007 | Read a downloaded issue offline | S2 AC-4 | CONFIRMED | AC-4 (T) | NFR-OFF-001 |
| FR-DL-008 | Downloads screen | S2 Flow 3; S1 A-9 | CONFIRMED | AC-4 (D) | OQ-08 |
| FR-DL-009 | Delete a download and free its space | S2 Flow 3; S2 AC-4 | CONFIRMED | AC-4 (T) | None |
| FR-DL-010 | Downloads after sign-out, deletion or unpublishing | DEV | OPEN | R: resolve OQ-11 | OQ-11 |
| FR-BKM-001 | Bookmark a page | S2 Scope: Reader; S2 AC-5 | CONFIRMED | AC-5 (T) | DATA-005 |
| FR-BKM-002 | Open a bookmark at its page | S2 AC-5 | CONFIRMED | AC-5 (T) | None |
| FR-BKM-003 | Mark and unmark favourites | S2 Scope: Reader; S2 AC-5 | CONFIRMED | AC-5 (T) | DATA-006, OQ-12 |
| FR-BKM-004 | Bookmarks and favourites on a second device | S2 AC-5; CH §8 | CONFIRMED | AC-5 (T); PAC-01 (T) | None |
| FR-BKM-005 | Bookmarks and favourites are private | S2 AC-5; S2 Rationale | CONFIRMED | AC-5 (T) | NFR-SEC-005 |
| FR-BKM-006 | Bookmark and favourite list screens | S1 A-9 | CONFIRMED | D | None |
| FR-BKM-007 | Remove a bookmark | DEV | ASSUMPTION | T | None |
| FR-BKM-008 | Offline bookmarks and favourites | DEV | OPEN | R: resolve OQ-10 | OQ-10 |
| FR-NEWS-001 | News list with image, title, date and category | S2 Scope: News; S2 AC-7 | CONFIRMED | AC-7 (T) | INT-WP-001, INT-WP-005 |
| FR-NEWS-002 | Article page | S2 Scope: News; S1 A-7 | CONFIRMED | AC-7 (T) | INT-WP-005 |
| FR-NEWS-003 | News category filter | S2 AC-7 | CONFIRMED | AC-7 (T) | INT-WP-003 |
| FR-NEWS-004 | New post appears after refresh | S2 AC-7 | CONFIRMED | AC-7 (T) | INT-WP-004 |
| FR-NEWS-005 | Loaded articles readable offline with a notice | S2 Scope: News; S2 AC-7 | CONFIRMED | AC-7 (T) | OQ-16 |
| FR-NEWS-006 | How articles are kept for offline reading | S2 Scope: News; S2 AC-7 | OPEN | R: resolve OQ-16 | OQ-16 |
| FR-NEWS-007 | News available to logged-out visitors | S2 Scope: Accounts; S2 AC-3; S3 via CH §17.3 | CONFIRMED | PAC-04 (T) | None |
| FR-NEWS-008 | Hidden posts not shown | S2 AC-8; S1 Annex A notes | CONFIRMED | AC-8 (T) | FR-ADMIN-013 |
| FR-NEWS-009 | Presentation of breaking posts | S1 Annex A notes | OPEN | R: resolve OQ-17 | OQ-17, FR-ADMIN-014 |
| FR-SHR-001 | Share an issue with title and link | S2 Scope: Reader; S2 AC-6 | CONFIRMED | AC-6 (T) | OQ-09 |
| FR-SHR-002 | Issue link points to the store listing | S3 via CH §8, §17.3 | PROVISIONAL | PAC-05 (T) | OQ-15, OQ-29, INT-STORE-001 |
| FR-SHR-003 | Share an article with title and link | S2 AC-6; S1 A-16 | CONFIRMED | AC-6 (T) | OQ-09 |
| FR-SHR-004 | Article link is the WordPress address | S3 via CH §8, §17.3 | PROVISIONAL | PAC-05 (T) | OQ-29 |
| FR-SHR-005 | Shared links do not open the app | S2 Not included | CONFIRMED | I | None |
| FR-SHR-006 | Sharing never sends the PDF | DEV; S2 Flow 3; S2 Not included | ASSUMPTION | I; T | NFR-SEC-004 |
| FR-NOTIF-001 | Explain notifications before the system prompt | S2 Scope: Notifications; S2 AC-9 | CONFIRMED | AC-9 (T) | None |
| FR-NOTIF-002 | Choose notification categories | S2 Scope: Notifications; S2 AC-9 | CONFIRMED | AC-9 (T) | FR-NOTIF-006, DATA-007 |
| FR-NOTIF-003 | Change category choices in settings | S2 Scope: Notifications; S1 A-10 | CONFIRMED | T | DATA-007 |
| FR-NOTIF-004 | Category notifications reach only opted-in devices | S2 AC-9; S1 What MFW receives | CONFIRMED | AC-9 (T) | INT-PUSH-001 |
| FR-NOTIF-005 | Tap opens the linked issue or article | S2 Scope: Notifications; S2 AC-9 | CONFIRMED | AC-9 (T) | BR-005 |
| FR-NOTIF-006 | Categories: new issues, expo specials, major news | S1 What MFW receives; S2 Objectives | CONFIRMED | I against the OQ-18 decision | OQ-18 |
| FR-NOTIF-007 | Notifications for logged-out visitors | CH §7; S2 Scope: Notifications | OPEN | R: resolve OQ-09 | OQ-09 |
| FR-EMAIL-001 | Optional edition-update email sign-up | S2 Scope: Accounts; S2 Architecture: Database; S1 A-10, A-19; S1 Annex A notes | CONFLICT | R: resolve C-02, then PAC-11 (T) | C-02, OQ-31 |
| FR-EMAIL-002 | Withdraw from the edition-update list | DEV | ASSUMPTION | PAC-11 (T) | FR-EMAIL-001 |
| FR-EMAIL-003 | No email sending or email-marketing integration | DEV (ASM-12); S2 Not included; S2 AC-8 | ASSUMPTION | I | ASM-12, FR-EMAIL-001 |
| FR-ADMIN-001 | Admin panel is the only web interface | S2 Product; S2 Not included | CONFIRMED | I | None |
| FR-ADMIN-002 | Admin sign-in refuses wrong passwords | S2 Scope: Admin panel; S2 AC-8 | CONFIRMED | AC-8 (T) | NFR-SEC-011 |
| FR-ADMIN-003 | Non-admin accounts refused | S2 AC-8; S1 A-31 | CONFIRMED | AC-8 (T) | DATA-011 |
| FR-ADMIN-004 | One admin role | S2 Assumptions; S2 Not included | CONFIRMED | I | ASM-06 |
| FR-ADMIN-005 | Upload PDF and cover | S2 Scope: Admin panel; S2 Flow 1; S1 A-32 | CONFIRMED | AC-8 (T) | INT-FILE-001 |
| FR-ADMIN-006 | Reject non-PDF files | S2 Flow 1; S2 AC-8 | CONFIRMED | AC-8 (T) | NFR-SEC-008 |
| FR-ADMIN-007 | Reject PDFs over the size limit | S2 Flow 1; S2 AC-8 | CONFIRMED | AC-8 (T) | C-06, OQ-30 |
| FR-ADMIN-008 | Cover image checks | S2 Scope: Admin panel | OPEN | R: resolve OQ-22 | OQ-22 |
| FR-ADMIN-009 | Enter and edit issue details | S2 Scope: Admin panel; S2 Scope: Discovery; S2 AC-1 | CONFIRMED | AC-1 (T); AC-8 (T) | DATA-001 |
| FR-ADMIN-010 | Create and maintain categories | S2 Scope: Admin panel; S2 AC-8 | CONFIRMED | AC-8 (T) | DATA-002 |
| FR-ADMIN-011 | Publish and unpublish issues | S2 Scope: Admin panel; S2 AC-8; S1 A-33 | CONFIRMED | AC-8 (T) | FR-MAG-007, FR-MAG-008 |
| FR-ADMIN-012 | Delete an issue or replace its PDF | DEV | OPEN | R: resolve OQ-21 | OQ-21 |
| FR-ADMIN-013 | Hide a WordPress post | S1 Annex A notes; S2 AC-8 | CONFIRMED | AC-8 (T) | DATA-009 |
| FR-ADMIN-014 | Mark a post as breaking | S1 Annex A notes | CONFIRMED | T | DATA-009, OQ-17 |
| FR-ADMIN-015 | Send a post as a breaking-news notification | S2 Scope: Notifications; S1 Annex A notes | CONFIRMED | T | FR-ADMIN-016 |
| FR-ADMIN-016 | Send a category notification | S2 Scope: Notifications; S2 AC-9; S1 A-36 | CONFIRMED | AC-9 (T) | INT-PUSH-001 |
| FR-ADMIN-017 | Only admins send notifications | S2 AC-9 | CONFIRMED | AC-9 (T) | NFR-SEC-007 |
| FR-ADMIN-018 | Send log | S2 Scope: Notifications; S2 AC-9 | CONFIRMED | AC-9 (T) | OQ-19, DATA-008 |
| FR-ADMIN-019 | No news authoring in the admin panel | S2 Not included; S2 Assumptions | CONFIRMED | I | INT-WP-002 |
| FR-USER-001 | Export the subscriber list to CSV | S2 Scope: Admin panel; S2 AC-8; S1 A-35; S1 Annex A notes | CONFLICT | R: resolve C-02, then AC-8 (T) | C-02, OQ-31 |
| FR-USER-002 | View registered users with profiles | S3 via CH §6, §8, §16 | PROVISIONAL | PAC-03 (T) | OQ-29, FR-PROF-002 |
| FR-USER-003 | Export registered users to CSV | S3 via CH §6, §8, §16 | PROVISIONAL | PAC-03 (T) | OQ-29, NFR-PRIV-004 |
| FR-USER-004 | No readership analytics dashboard | S2 Not included; CH §10 | CONFIRMED | I | None |
| FR-USER-005 | Admin account creation and removal | S1 What we need from MFW | OPEN | R: resolve OQ-20 | OQ-20 |
| FR-STATE-001 | Loading indicator | DEV (ASM-13) | ASSUMPTION | PAC-10 (D) | ASM-13 |
| FR-STATE-002 | Empty states | DEV (ASM-13) | ASSUMPTION | PAC-10 (D) | ASM-13 |
| FR-STATE-003 | No-network message with retry | DEV (ASM-13); S2 AC-4; S2 AC-7 | ASSUMPTION | PAC-10 (D) | ASM-13 |
| FR-STATE-004 | Not enough storage for a download | DEV (ASM-13) | ASSUMPTION | PAC-10 (D) | ASM-13, FR-DL-001 |
| FR-STATE-005 | WordPress unreachable | DEV (ASM-13); S2 Risks | ASSUMPTION | PAC-10 (D) | ASM-13, INT-WP-004 |
| FR-STATE-006 | Failed download with retry | DEV (ASM-13); S2 AC-4 | ASSUMPTION | PAC-10 (D) | ASM-13 |
| FR-STATE-007 | Admin panel result messages | DEV (ASM-13); S2 AC-8 | ASSUMPTION | PAC-10 (D) | ASM-13 |
| FR-PRIV-001 | Consent at registration | S2 Not included; CH §9 | CONFIRMED | PAC-08 (T) | OQ-27, DATA-012 |
| FR-PRIV-002 | Policy and terms reachable in the app | DEV; S2 AC-11 | ASSUMPTION | PAC-08 (T) | Privacy policy from MFW (Section 11.2) |
| FR-PRIV-003 | Account deletion removes reader data | S2 AC-3; S2 Architecture: Server logic | CONFIRMED | AC-3 (T); PAC-06 (T) | OQ-24 |
| FR-PRIV-004 | Confirm before account deletion | DEV | ASSUMPTION | T | FR-AUTH-009 |
| NFR-PERF-001 | First page within 3 seconds on the mid-range test phone | S2 AC-2 | CONFIRMED | AC-2 (T) | Sample PDFs; NFR-COMP-003; CH D3 |
| NFR-PERF-002 | Sharp text at 300% zoom | S2 AC-2 | CONFIRMED | AC-2 (T) | Sample PDFs |
| NFR-REL-001 | Twenty page turns without a crash | S2 AC-2 | CONFIRMED | AC-2 (T) | None |
| NFR-REL-002 | No critical or high defect open | S2 AC-10; S2 Acceptance testing | CONFIRMED | AC-10 (T); S2 Acceptance testing | None |
| NFR-REL-003 | Notification delivery time not guaranteed | S2 AC-9 | CONFIRMED | AC-9 (I) | INT-PUSH-001 |
| NFR-SEC-001 | HTTPS for all traffic | S2 Rationale; S2 Assumptions | CONFIRMED | I; security checklist | NFR-SEC-010 |
| NFR-SEC-002 | Backend refuses direct file requests | S2 AC-3; S2 Architecture: File storage; CH §18 R4 | CONFIRMED | AC-3 (T) | INT-FILE-001 |
| NFR-SEC-003 | PDFs stored privately | S2 Flow 1; S2 Architecture: File storage | CONFIRMED | I; T | INT-FILE-001 |
| NFR-SEC-004 | Downloads in app-private storage | S2 Flow 3; S2 Not included | CONFIRMED | I | FR-DL-001 |
| NFR-SEC-005 | Own bookmarks and favourites only | S2 AC-5; S2 Rationale | CONFIRMED | AC-5 (T) | None |
| NFR-SEC-006 | Own profile and preferences only | DEV; S2 Rationale | ASSUMPTION | T | FR-PROF-002 |
| NFR-SEC-007 | Only admins change the catalogue and news controls | S2 Rationale; S2 AC-8 | CONFIRMED | AC-8 (T) | FR-ADMIN-003 |
| NFR-SEC-008 | Backend enforces upload checks | S2 Flow 1 | CONFIRMED | T | FR-ADMIN-006, FR-ADMIN-007 |
| NFR-SEC-009 | Login gating and private storage only; no DRM | S2 Not included; CH §9 | CONFIRMED | I | None |
| NFR-SEC-010 | Security checklist completed | S2 AC-10 | CONFIRMED | AC-10 (I) | Test strategy (Section 11.3) |
| NFR-SEC-011 | Admin sign-in security measures | S2 Scope: Admin panel | OPEN | R: resolve OQ-20 | OQ-20 |
| NFR-SEC-012 | Role-based access; MFW holds credentials | S2 Responsibilities; S2 AC-12 | CONFIRMED | AC-12 (I) | None |
| NFR-PRIV-001 | Collect only approved profile fields | S3 via CH §9; CH §18 R11 | PROVISIONAL | I against the approved field list | OQ-01, OQ-29 |
| NFR-PRIV-002 | Store privacy details match MFW's policy | S2 AC-11 | CONFIRMED | AC-11 (I) | Privacy policy from MFW (Section 11.2) |
| NFR-PRIV-003 | No per-user reading tracking in usage events | S3 via CH §10, §17.3; S2 Not included | PROVISIONAL | PAC-09 (I) | OQ-23, OQ-29 |
| NFR-PRIV-004 | Personal-data exports for admins only | DEV; S2 Scope: Admin panel; S2 AC-8 | ASSUMPTION | PAC-03 (T) | FR-USER-003 |
| NFR-PRIV-005 | Retention periods | CH §19.3 D4 | OPEN | R: resolve OQ-24 | OQ-24 |
| NFR-PRIV-006 | Legal review of age collection | CH §18 R10 | OPEN | R: resolve OQ-07 | OQ-07 |
| NFR-UX-001 | MFW branding | S2 Scope: Design; S1 What we need from MFW | CONFIRMED | I against the M2 designs | Brand assets from MFW (Section 11.2) |
| NFR-UX-002 | Screens approved before development | S2 Scope: Design; S2 Milestones (M2) | CONFIRMED | R: M2 approval record | None |
| NFR-UX-003 | English only | S2 Assumptions; S2 Not included | CONFIRMED | I | ASM-04 |
| NFR-UX-004 | Accessibility baseline | DEV | OPEN | R: resolve OQ-25 | OQ-25 |
| NFR-COMP-001 | Android and iOS from one codebase | S2 Scope: Platform | CONFIRMED | I; AC-10 (T) | None |
| NFR-COMP-002 | Reader on phones and tablets, both orientations | S2 Scope: Reader; S2 AC-2 | CONFIRMED | AC-2 (T) | NFR-COMP-003 |
| NFR-COMP-003 | Agreed test device set | S2 AC-10 | CONFIRMED | AC-10 (I) | OQ-26 |
| NFR-COMP-004 | Minimum OS versions | DEV | OPEN | R: resolve OQ-26 | OQ-26 |
| NFR-COMP-005 | Admin panel browsers | DEV | OPEN | R: resolve OQ-26 | OQ-26 |
| NFR-STOR-001 | PDFs up to 150 MB and about 120 pages | S2 Assumptions (ASM-01); S2 Flow 1 | ASSUMPTION | T with the largest sample PDF | ASM-01; sample PDFs (Section 11.2) |
| NFR-STOR-002 | Five to twelve issues at launch | S2 Assumptions (ASM-02) | ASSUMPTION | T | ASM-02 |
| NFR-STOR-003 | No content delivery network at launch (S2 proposal) | S2 Rationale (ASM-15); CH §17.4; CH §18 R2 | ASSUMPTION | R: architecture document | ASM-15, C-05 |
| NFR-MAINT-001 | Source code in an MFW-owned repository | S2 AC-12; S2 Handover | CONFIRMED | AC-12 (I) | CH D8 |
| NFR-MAINT-002 | Build and deploy from a clean copy | S2 AC-12 | CONFIRMED | AC-12 (D) | C-05 |
| NFR-MAINT-003 | Signed builds from tagged code | S2 AC-11 | CONFIRMED | AC-11 (I) | None |
| NFR-MAINT-004 | Technical documentation contents | S2 Handover | CONFIRMED | AC-12 (I) | None |
| NFR-MAINT-005 | Thin data layer | S2 Rationale | ASSUMPTION | R: architecture document | C-05 |
| NFR-MAINT-006 | No paid component without approval | S2 Rationale; S1 Costs outside the fee | CONFIRMED | I (third-party licence list) | None |
| NFR-OBS-001 | Crash reporting | S2 Scope: Platform; S2 Flow 5 | CONFIRMED | T | C-07 |
| NFR-OBS-002 | Basic usage events | S2 Scope: Platform; S2 Flow 5 | CONFIRMED | PAC-09 (I) | C-07, OQ-23 |
| NFR-OFF-001 | Downloads screen and downloaded issues offline | S2 AC-4 | CONFIRMED | AC-4 (T) | FR-DL-007, FR-DL-008 |
| NFR-OFF-002 | Offline catalogue, bookmarks and favourites | DEV | OPEN | R: resolve OQ-10 | OQ-10 |
| DATA-001 | Issue data | S2 Scope: Discovery; S2 Scope: Admin panel; S2 AC-1; S2 AC-4; S2 Flow 1 | CONFIRMED | I (data model) | OQ-13 |
| DATA-002 | Category data | S2 Scope: Admin panel | CONFIRMED | I (data model) | None |
| DATA-003 | Reader account data | S2 Architecture: Accounts; S2 AC-3 | CONFIRMED | I (data model) | FR-AUTH-005 |
| DATA-004 | Reader profile data | S3 via CH §8 | PROVISIONAL | I against the approved field list | OQ-01, OQ-02, OQ-29 |
| DATA-005 | Bookmark data | S2 AC-5 | CONFIRMED | I (data model) | None |
| DATA-006 | Favourite data | S2 AC-5 | CONFIRMED | I (data model) | None |
| DATA-007 | Notification preferences and device registration | S2 Architecture: Database; S2 AC-9 | CONFIRMED | I (data model) | OQ-09 |
| DATA-008 | Send records | S2 AC-9 | CONFIRMED | I (data model) | OQ-19 |
| DATA-009 | News controls | S1 Annex A notes; S2 AC-8 | CONFIRMED | I (data model) | None |
| DATA-010 | Edition-update list | S2 Architecture: Database; S2 Scope: Accounts | CONFLICT | R: resolve C-02 | C-02, OQ-31 |
| DATA-011 | Admin accounts | S2 Architecture: Accounts | CONFIRMED | I (data model) | OQ-20 |
| DATA-012 | Consent record | DEV; supports FR-PRIV-001 | ASSUMPTION | I (data model) | OQ-27 |
| DATA-013 | Data on the device | S2 Flow 3; S2 AC-7 | CONFIRMED | I | OQ-11 |
| DATA-014 | Crash reports and usage events | S2 Scope: Platform | CONFIRMED | I | OQ-23 |
| DATA-015 | WordPress is the master source of news | S2 Scope: News; S2 Rationale | CONFIRMED | I | INT-WP-002 |
| DATA-016 | MFW owns reader data | S1 Key terms | CONFIRMED | R | None |
| DATA-017 | Retention periods | CH §19.3 D4 | OPEN | R: resolve OQ-24 | OQ-24 |
| INT-WP-001 | News from the WordPress API over HTTPS | S2 Scope: News; S2 Assumptions; S2 Architecture: News | CONFIRMED | AC-7 (T) | ASM-03; WordPress details from MFW (Section 11.2) |
| INT-WP-002 | No changes to the WordPress site | S2 Not included; CH §3 | CONFIRMED | I | None |
| INT-WP-003 | Only MFW-selected news categories | S1 What we need from MFW | CONFIRMED | T | News categories from MFW (Section 11.2) |
| INT-WP-004 | Paged requests and caching | S2 Flow 2; S2 Risks | CONFIRMED | I; T | None |
| INT-WP-005 | Post fields used | S2 Scope: News; S2 AC-7 | CONFIRMED | AC-7 (T) | None |
| INT-AUTH-001 | Authentication capabilities | S2 Architecture: Accounts; S2 Scope: Accounts | CONFIRMED | AC-3 (T); AC-8 (T) | C-05; cloud project from MFW (Section 11.2) |
| INT-AUTH-002 | Google Sign-In configured in MFW's accounts | S3 via CH §8, §15 | PROVISIONAL | PAC-01 (T) | OQ-29 |
| INT-PUSH-001 | Platform push delivery | S2 Architecture: Notifications | CONFIRMED | AC-9 (T) | Apple and Google accounts from MFW (Section 11.2) |
| INT-PUSH-002 | iOS push through MFW's Apple account | S1 What we need from MFW; S2 Assumptions | CONFIRMED | AC-9 (T) on iOS | ASM-05 |
| INT-FILE-001 | Backend file storage with gated release | S2 Architecture: File storage; S2 AC-3; S2 Rationale | CONFIRMED | AC-3 (T) | C-05, BR-003 |
| INT-STORE-001 | Distribution through MFW's store accounts | S1 What MFW receives; S2 Assumptions | CONFIRMED | AC-11 (I) | ASM-05 |
| BR-001 | No guest reading or public sample | S3 via CH §9, §17.3. Conflicts with S2 Scope: Accounts and S2 Flow 3 (C-01). | PROVISIONAL | PAC-04 (T) | C-01, OQ-29 |
| BR-002 | Sign-in and verified email for full issues | S2 AC-3; CH §9 | CONFIRMED | AC-3 (T) | OQ-04 |
| BR-003 | Complete profile for full issues | S3 via CH §9 | PROVISIONAL | PAC-02 (T) | OQ-29 |
| BR-004 | All editions free; no payments | S2 Not included; CH §9 | CONFIRMED | I | None |
| BR-005 | Links and notifications follow access rules | DEV; S2 AC-3 | ASSUMPTION | T | BR-002, BR-003 |

## 14. Approval and Change-Control Notes

### 14.1 Approval status

- This document is a **Draft for Review**. It has not been approved by MFW or by the development team.
- Proposed review path: the two developers review it internally, then send it to MFW's authorised approver or deputy. MFW approves in writing, and email is enough [S2 Responsibilities].
- If MFW's written approval explicitly covers the PROVISIONAL items, they become CONFIRMED and the approval is cited as their source. Otherwise they stay PROVISIONAL until OQ-29 is resolved.

### 14.2 Approval record

| Role | Name | Decision | Date |
|---|---|---|---|
| Development team internal review | | | |
| MFW authorised approver | To be named (OQ-28) | | |
| MFW deputy approver | To be named (OQ-28) | | |

### 14.3 Change control

- **Before approval.** Each change is recorded in the change history with a new version number.
- **After approval.** Changes follow the S2 change process. MFW's approver describes the change in writing. Within two working days the developers reply with the effort, the price, the effect on dates and any new third-party cost. MFW approves in writing, and no work starts before that [S2 Changes; CH §17.2]. A question that only clarifies the agreed scope is answered without a change request [S2 Changes]. A defect is a failure against an acceptance criterion. Anything else is a change [S2 Changes].
- **Status changes.** A PROVISIONAL item becomes CONFIRMED when the S3 record or MFW's written confirmation is filed in the repository and cited. An ASSUMPTION proposed by the development team becomes CONFIRMED when MFW approves it, or is withdrawn. An OPEN item is resolved by a recorded decision with its date and decision-maker, and the requirement is rewritten. A CONFLICT is resolved by a recorded decision that states which source position applies.
- **Identifiers.** Requirement IDs are never reused. A removed requirement stays in the traceability matrix marked "Withdrawn", with the reason.
