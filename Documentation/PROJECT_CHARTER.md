# Project Charter: Metal Forming World (MFW) Mobile Application

## 1. Document Information

| Field | Detail |
|---|---|
| Document title | Project Charter |
| Repository file | `PROJECT_CHARTER.md` |
| Project name | Metal Forming World (MFW) mobile application |
| Version | 0.1 |
| Status | Draft for review |
| Date | 22 October 2026 |
| Purpose | Establish the purpose, scope boundaries, stakeholders, constraints, success criteria and governance of the MFW project. This is the foundational reference for the requirements, architecture, task assignment, development workflow, testing and deployment documents that follow. |

**Revision history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 22 October 2026 | Initial draft |

**Source documents**

| Ref | Document | Date | Use in this charter |
|---|---|---|---|
| S1 | MFW Mobile App Commercial Proposal | 17 October 2026 | Commercial terms |
| S2 | MFW Mobile App Statement of Work | 17 October 2026 | Scope, deliverables, milestones, acceptance criteria, responsibilities, exclusions |
| S3 | Client emails received after S1 and S2 | Dates and senders to be inserted from the emails | Amend S1 and S2 on the points listed in Section 17.3 |

S1 and S2 are the baseline. Where S3 states a different position, S3 prevails for that point only. Statements are tagged [S1], [S2] or [S3] where the source matters. Untagged statements are framing by the development team.

## 2. Executive Summary

The project delivers a cross-platform digital magazine and industrial news application for Metal Forming World (MFW), built in Flutter for Android and iOS, together with a web admin panel for MFW's editors.

Readers can browse magazine covers and descriptions and read industry news without an account. To read a full magazine edition or download it for offline reading, a reader must register, complete a mandatory profile and sign in, using email and password or Google Sign-In. There is no guest-reading mode. MFW's existing WordPress website remains the place where news is written and is the source of news in the app.

The work starts on 21 October 2026 and runs for eight weeks, ending with submission of the app to the Apple App Store and Google Play by 16 December 2026. The agreed fee is INR 91,000. Store approval and its timing are outside the project's control.

## 3. Project Background

**Client.** MFW publishes a magazine and industry news. MFW owns its brand assets and magazine content, and will supply the official logo, branding and colour guidelines [S1, S2].

**Existing publishing platform.** MFW already runs a WordPress website with hosting. News is written in WordPress and stays there. The website is not changed by this project [S1, S2].

**Business need.** MFW's magazine exists as high-resolution PDF editions. The app gives readers an interactive way to read these editions on a phone or tablet, keep them offline, and receive notifications, and it gives MFW visibility of who registers and reads in the app [S3].

## 4. Problem Statement

The source documents do not contain readership data or a quantified description of the current problem, so this statement is limited to what S2 and S3 describe.

MFW does not yet have a mobile application. Readers cannot read editions interactively on their phones, keep an edition for offline reading, or receive direct notifications about new editions, expo specials and major manufacturing news. MFW also has no way to know who is reading its magazines in a mobile channel. MFW's editors have no simple tool to publish editions and run an app without developer help.

## 5. Project Vision

A reader finds MFW in the app store, browses current and archived editions, creates an account, and reads a full edition in an interactive page-turn reader or a plain swipe mode. The reader can download editions for offline reading, bookmark pages, favourite issues, share issues and articles, read industry news, and receive notifications they have opted into. MFW's editors upload editions, manage categories, control how news appears, send notifications and see their registered readers, using a web admin panel, without developer help.

## 6. Business Objectives

| ID | Objective | Evidence of achievement | Source |
|---|---|---|---|
| O1 | Give readers an interactive digital edition on Android and iOS | AC-1 and AC-2 pass | S2 |
| O2 | Let readers download issues and read them offline | AC-4 passes | S2 |
| O3 | Show MFW's industry news in the app without duplicating the WordPress site | AC-7 passes | S2 |
| O4 | Reach readers directly with notifications about new issues and expo announcements | AC-9 passes | S2 |
| O5 | Let MFW's editors run the app without developer help | AC-8 passes and the administrator training session is held | S2 |
| O6 | Give MFW visibility of who registers and reads in the app | Registered readers complete a mandatory profile, and MFW can view and export registered users with their profile information. Detailed criteria to be defined in the requirements document. | S3 |
| O7 | Deliver within the agreed window | App submitted to both stores by 16 December 2026 | S3 |

The only numeric targets agreed to date are the reader targets in S2 AC-2 (first page within 3 seconds on the mid-range test phone, sharp text at 300% zoom, no crash across twenty consecutive page turns), which are confirmed after testing on MFW's sample PDFs. No user growth, revenue or engagement targets have been agreed, and none are stated here.

## 7. Target Users and Stakeholders

| Group | Who | Interest |
|---|---|---|
| Readers, logged out | Any app visitor | Browse magazine covers and descriptions, read news |
| Readers, registered | Users with an account and completed profile | Full editions, offline downloads, bookmarks, favourites, notifications |
| Editorial and admin team | MFW's editorial team, assumed to use one admin role [S2] | Upload editions, manage categories and news controls, send notifications, view registered users |
| Client and business stakeholders | MFW. Authorised approver and deputy to be confirmed. Sandeep Gaikwad and Subhajit sent the confirmation emails [S3]. | Approvals, payments, content, platform accounts |
| Development team | Sanika Attarde (contracting developer, repository owner, branch `SA`). Developer YG (Yuvraj, branch `YG`). | Delivery |
| External service providers | Google (Firebase and Google Cloud, Google Play, Google Sign-In), Apple (Developer Program, App Store, push notification service), MFW's WordPress host | Platform services and store distribution |

## 8. High-Level Product Scope

| Area | Scope | Source |
|---|---|---|
| Magazine browsing and discovery | Latest edition and four to six archived editions at launch. Covers, titles, descriptions, categories and publication dates. Search by title, description and category. Category, industry segment, year and edition filters. | S2 |
| Interactive PDF reading | Swipe and zoom, page-turn effect, two-page spread on tablets and in landscape. PDF files under 150 MB per issue. Online reading. | S2 |
| Registration and Google Sign-In | Email and password registration with email verification and password reset. Google Sign-In. In-app account deletion. | S2, S3 |
| Mandatory profile | Name, exact age, gender, occupation, domain of work and related fields collected on the account. Final field list to be set in the requirements document. | S3 |
| Protected full-content access | Full editions available only to signed-in readers. No guest-reading mode. | S2, S3 |
| Offline downloads | Download with progress, resume after interruption, size warning on mobile data, deletion from a Downloads screen. | S2 |
| Bookmarks and favourites | Page bookmarks and favourite issues tied to the user account and available on a second device. | S2 |
| Sharing | Sharing of issues (link to the app's store listing) and news articles (WordPress article link). | S2, S3 |
| Industry news | News list and article pages from MFW's WordPress site, with categories, images and dates. Saved articles for offline viewing. Public to logged-out users. | S2, S3 |
| Push notifications | Permission explanation and category preferences. Sending from the admin panel. Tap-to-open links. Breaking-news alert from a WordPress post. Send log. Sent only to readers who agreed. | S2 |
| Administration and CMS | Web admin panel with secure login, PDF and cover upload with checks, issue details, categories, publish and unpublish, app-level news controls, notification sending, and a list of registered users with CSV export. | S2, S3 |
| WordPress integration | News read from MFW's existing WordPress site through its API. No changes to the site. | S2 |
| Android and iOS delivery | One Flutter codebase. Signed builds, store listings and submission to Apple and Google. | S2 |

## 9. Access and Content Rules

| Capability | Logged out | Registered and signed in |
|---|---|---|
| View magazine covers, titles, descriptions, categories, publication dates and other approved metadata | Yes | Yes |
| Read the news list and full news articles | Yes | Yes |
| Read a full magazine edition | No | Yes |
| Download an edition for offline reading | No | Yes |
| Bookmarks and favourites | No | Yes |
| Account and profile | No | Yes |

Search and filters operate on the public metadata. Details are confirmed in the requirements document.

1. **No guest-reading mode.** The public sample issue in S2 is removed [S3].
2. **Mandatory authentication.** Full reading and offline downloads require an account. For email accounts, a verified email is required before a full issue opens [S2 AC-3]. A direct request for the PDF file by a logged-out or unverified user must be refused [S2 AC-3]. How verification applies to Google accounts is a design decision.
3. **Account-specific data.** Bookmarks and favourites are private to each reader [S2 AC-5]. Deleting the account removes the reader's data [S2 AC-3].
4. **Mandatory profile.** Exact age and the other profile fields are mandatory [S3]. Registration is not complete without them. How and when Google Sign-In users complete the profile is a requirements-stage decision.
5. **Age.** Age is collected with no age restriction and no parental-consent flow [S3]. See risk R10.
6. **Free-to-read.** Every edition is free to registered readers. There are no payments, subscriptions or paywalls [S2].
7. **Content protection.** Protection is login gating and private storage only. There is no DRM [S2].
8. **Legal documents.** MFW supplies the privacy policy and terms of use. The policy must name the profile fields collected and their purpose. The developers implement consent and deletion [S2].

## 10. Scope Boundaries and Exclusions

The fixed fee does not cover the items below. They can be added later through a change request [S2].

**Later-phase features**
- Apple sign-in (Google Sign-In is now in scope [S3]).
- Reading an issue before the full download finishes.
- Scheduled notifications, audience segments, and delivery and open statistics.
- A readership analytics dashboard, including per-user reading-activity tracking [S2, S3].
- Editorial roles, draft and review, scheduled publishing, and an audit log.
- Shared links that open the app directly.
- Lead capture forms and sponsor placement slots.

**Other exclusions**
- Payments, subscriptions and paywalls.
- A public web version of the reader. The admin panel is the only web interface.
- Changes to the WordPress site, and writing news in the admin panel.
- Marketplace and community features, AI features, advertising platforms and enterprise analytics.
- Integrations with CRM, email-marketing, accounting or ticketing systems.
- Creating or preparing content, and entering production issues, news and notifications. MFW's team does this.
- Languages other than English.
- Legal documents, including the privacy policy.
- Copy protection beyond login gating and private storage.
- Third-party charges, an independent penetration test, and devices outside the agreed test list.
- A guarantee of store approval or its timing.
- Support after the 30-day warranty.

## 11. High-Level Deliverables

**Final deliverables supported by S1 and S2**

| Deliverable | Notes |
|---|---|
| Mobile app for Android and iOS | One codebase, signed release builds |
| Backend services | Running on MFW's own accounts |
| Web admin panel | For MFW's editors |
| Store submission | Listings and submission to Apple and Google, with confirmations |
| Source code and repository | In a repository owned by MFW, with history |
| Technical documentation | Set-up, deployment steps, data model, security rules, third-party licences |
| Administrator guide and training | Guide plus a live session of up to two hours |
| Release package | Store listing text and screenshots, privacy inputs |
| Test evidence | Test results against the acceptance criteria, security checklist |
| Handover records | Record of who holds each credential, list of known limitations |
| 30-day warranty | Defect correction after first public release |

**Contractual interim deliverables.** The requirements and architecture note is an M1 deliverable [S2].

**Proposed technical artefacts, not contractual deliverables.** This charter and the later project documents (requirements, architecture decisions, task assignments, development workflow, test strategy) support delivery. The Firebase-based architecture in S2 is described as proposed and is confirmed or changed in the architecture document.

## 12. Project Timeline and Major Milestones

The project starts on 21 October 2026 with an eight-week window ending 16 December 2026 [S3]. S2's dates were set for a 16 November kickoff. The planned dates below apply S2's two-week milestone cadence to the agreed start. Week N ends N x 7 days after the start.

| Milestone | S2 date (superseded) | Planned date | Developer delivers | MFW approves when |
|---|---|---|---|---|
| M1 Kickoff | 16 Nov 2026 | 21 Oct 2026 | Requirements and architecture note, repositories set up, kickoff meeting | MFW approves the note in writing, names its approver and deputy, and supplies brand assets |
| M2 Design approval | 27 Nov 2026 | 4 Nov 2026 | Approved screens, interactive prototype, reader test result on MFW's PDFs | Screens approved. Reader approach confirmed, or an agreed alternative recorded. |
| M3 Core app and backend | 11 Dec 2026 | 18 Nov 2026 | Demo build on Android and iOS test devices with sign-up, login, catalogue and the first reader | A tester can sign up, log in, browse the catalogue and open an issue |
| M4 Feature-complete build | 25 Dec 2026 | 2 Dec 2026 | Test builds with every included feature, admin panel live, notifications working end to end, internal test summary | Every included feature is present and no critical defect is open |
| M5 Approval and store submission | 8 Jan 2027 | 16 Dec 2026 | Approved build submitted to Apple and Google, release package, source code, documentation, administrator session, test evidence | MFW signs off acceptance testing and AC-11 and AC-12 are met |

M5 completes at submission. It does not wait for Apple or Google to finish their review, and no approval date is guaranteed [S2].

**Acceptance testing.** The test build and test script are delivered on 2 December 2026. MFW has five working days to test. The developers reply to each item within one working day, and MFW checks each fix within two working days [S2].

**Internal target.** The team will try to finish in six weeks. This is an internal planning target, not a commitment to MFW. The eight-week window and S2's review periods apply.

**Client inputs, re-based to the 21 October start.** These dates apply S2's offsets to the new start and are checked against S3.

| Input | Needed by |
|---|---|
| Named approver and deputy, written confirmation that MFW owns or may use the content | Before 21 Oct 2026 |
| Logo files, brand colours and fonts | 21 Oct 2026 |
| Two to three sample PDFs including the largest expected issue | 28 Oct 2026 |
| WordPress site address, API confirmation, news categories to show | 28 Oct 2026 |
| Firebase and Google Cloud project in MFW's name, billing switched on | 28 Oct 2026 |
| Apple Developer Program (organisation) and Google Play accounts | Enrolment starts in Week 1. Active by 18 Nov 2026. |
| Privacy policy and terms of use at a public address | 18 Nov 2026 |
| Launch content: latest issue and four to six archive issues with details | 18 Nov 2026 |
| Admin user list and store listing text | 18 Nov to 2 Dec 2026 |
| Testers from MFW's team | From 2 Dec 2026 |

A one-working-day delay on a key input moves later dates by one working day. A delay longer than five working days is a schedule change agreed in writing [S2]. MFW reviews a milestone within three working days, a test build within two, and acceptance testing within five [S2].

## 13. Commercial Overview

| Item | Amount (INR) | Source |
|---|---|---|
| Total project fee | 91,000 | S3 (S1: 85,000) |
| Initial payment received | 28,000 | S3 |
| Remaining balance | 63,000 | |
| M2 Design approval | 12,750 | S3 |
| M3 Core app and backend | 17,000 | S3 |
| M4 Feature-complete build | 17,000 | S3 |
| M5 Approval and store submission | 16,250 | S3 |

The fee increase over S1 was added by the client. It is not allocated to line items in S1 Annex A, which still totals 85,000. The additional requirements in Section 17.3 are delivered within the revised fee.

**Payment terms [S1].** Each later invoice is raised when MFW approves the milestone in writing, and email is enough. Each invoice is due 7 days from its date. If an invoice stays unpaid, the developer sends a reminder and may pause work, moving the dates by the days paused. M5 is invoiced at approval, store submission and handover, and does not wait for Apple or Google. No GST is charged under S1. Work outside agreed scope is priced through a written change request at INR 2,500 per person-day. The other S1 terms (validity, warranty, ownership, cancellation, confidentiality, governing law) remain as written.

**Recurring and third-party expenses, outside the development fee [S1].** MFW pays each provider directly, and nothing is marked up.

| Item | Cost to MFW |
|---|---|
| Cloud usage (Firebase and Google Cloud) | Billed by Google to MFW's account on actual use |
| Apple Developer Program | USD 99 per year |
| Google Play Console | USD 25, one time |
| Commercial flipbook licence | None assumed. Bought only if needed and only after MFW's written approval. |
| Custom domain for the admin panel | Optional, at the registrar's price |
| Maintenance after the 30-day warranty | Optional. Monthly plans of INR 5,000 (8 hours), 8,000 (16 hours) or 12,000 (32 hours), three-month minimum. Without a plan, INR 5,500 per day. |

## 14. Roles and Responsibilities

| Role | Responsibilities |
|---|---|
| Client (MFW) | Name one authorised approver and one deputy. Supply the inputs in Section 12 by the dates shown. Approve milestones in writing and send one consolidated feedback list per review round. Own and pay for the Firebase project, Apple and Google accounts and any domain, and give the developers role-based access. Provide and enter production content. Supply the privacy policy and terms of use. Act as the party responsible for the personal data of its readers. |
| Sanika Attarde | Contracting developer named in S1 and S2. Owner of the project repository. Works on branch `SA`. |
| Developer YG (Yuvraj) | Co-developer working on branch `YG`. |
| Development team, shared | Design, build, test and deploy the app, backend and admin panel on MFW's accounts. Submit to Apple and Google. Hand over source code and documentation. Commit work to the repository every week with short notes. Notify MFW in writing as soon as a delay is expected. Correct defects at no charge during the build and the 30-day warranty. |
| External providers | Google and Apple provide platform services, store review and push delivery. MFW's WordPress host provides the website and API. Their decisions and outages are outside the team's control. |

Detailed task assignments between the two developers are pending and will be set out in a later document.

## 15. Constraints and Dependencies

| Constraint or dependency | Detail |
|---|---|
| Delivery window | Eight weeks from 21 October 2026. Six weeks is an internal target only. |
| Branding assets and sample PDFs | The design and reader testing cannot start without them. Dates are in Section 12. |
| WordPress API access | The API must be enabled and reachable over HTTPS. Confirmed in Week 1. |
| Authentication and cloud configuration | A Firebase and Google Cloud project in MFW's name with billing on. Google Sign-In configuration in MFW's accounts. |
| Reader library | Suitability and licensing of any third-party reader library. No paid component without MFW's written approval [S2]. |
| Client feedback and approvals | Reviews within the S2 periods. Delays move later dates. |
| Store accounts and review | Apple organisation enrolment can take weeks. Review outcomes and timing are decided by Apple and Google. |
| Content and legal inputs | Launch content, privacy policy and terms of use supplied by MFW. |
| File assumptions | Each issue is one PDF of up to 150 MB and about 120 pages, with five to twelve issues live at launch [S2]. |

## 16. High-Level Success Criteria

The project succeeds when the acceptance criteria in S2 pass in acceptance testing, with the amendments below. No numeric performance threshold beyond S2 AC-2 has been agreed.

| Area | Criterion | Reference |
|---|---|---|
| Browsing and search | Latest and archive issues show cover, title, date and description. Search and filters return the right issues. A newly published issue appears after a pull-to-refresh. | S2 AC-1 |
| Reader | First page, swipe, tap, zoom, two-page layout, damaged-file handling as set out in S2. Targets confirmed at the end of Week 2. | S2 AC-2 |
| Accounts and access | Registration, email verification, password reset and account deletion work. Logged-out and unverified users see a sign-in prompt and cannot open a full issue or request the PDF directly. | S2 AC-3, amended by S3 |
| Google Sign-In | A reader can register and sign in with Google on the Android and iOS test builds. Criteria to be defined in the requirements document. | S3 |
| Mandatory profile | A reader cannot complete registration without the mandatory profile fields. MFW can view and export registered users with their profile information. Criteria to be defined in the requirements document. | S3 |
| Offline downloads | Progress, full offline reading, resume, size warning and deletion work. | S2 AC-4 |
| Bookmarks and favourites | Work across devices and are private to each reader. | S2 AC-5 |
| Sharing | The share sheet opens with the title and link. Issues link to the store listing and articles to the WordPress article. | S2 AC-6, S3 |
| News | The news list and articles work for logged-out and registered users. Category filters work. Loaded articles stay readable offline. | S2 AC-7, S3 |
| Admin panel | Access control, upload validation, publishing and CSV export work. | S2 AC-8 |
| Notifications | Category targeting, tap-to-open, send log and admin-only sending work. | S2 AC-9 |
| Testing | Test results recorded for every criterion. No critical or high defect open at the start of acceptance testing. | S2 AC-10 |
| Release | Signed builds from tagged code. Store listings approved by MFW. Store privacy details match MFW's privacy policy. Both builds submitted. | S2 AC-11 |
| Handover | Source code in an MFW-owned repository. The app builds and the backend deploys from a clean copy into a fresh Firebase project. | S2 AC-12 |

## 17. Governance and Change Control

### 17.1 Baseline
S1, S2 and the S3 amendments in Section 17.3 form the approved baseline. Nothing outside this baseline is committed to MFW.

### 17.2 Change control
Anything that is not a defect against an acceptance criterion is a change. Changes follow S2: the request is made in writing by MFW's approver, the developers reply within two working days with effort, price at INR 2,500 per person-day, effect on dates and any new third-party cost, MFW approves in writing, and only then does work begin. Unless agreed otherwise, 50% is invoiced on approval and 50% on delivery.

### 17.3 Amendments to S1 and S2

| Item | S1 and S2 position | Current position | Source |
|---|---|---|---|
| Project fee | INR 85,000 | INR 91,000 | S3 |
| Initial payment | INR 25,500 (30%) | INR 28,000 received | S3 |
| Remaining payment schedule | M2 to M5 total INR 59,500 | M2 12,750, M3 17,000, M4 17,000, M5 16,250 (total 63,000) | S3 |
| Start | Kickoff 16 Nov 2026 | 21 Oct 2026, eight weeks | S3 |
| Milestone dates | 27 Nov, 11 Dec, 25 Dec 2026, 8 Jan 2027 | 4 Nov, 18 Nov, 2 Dec, 16 Dec 2026 | S3 |
| Guest browsing with a public sample | In scope | Removed. No guest reading. | S3 |
| Google Sign-In | Excluded, later phase | In scope, within the revised fee | S3 |
| Profile information | Not in scope | Mandatory profile on the account, including exact age | S3 |
| Apple sign-in | Excluded | Remains excluded | S2 |
| News for logged-out users | Guests browse news | News public to logged-out users | S3 |
| Issue share link | Share sheet with title and link | Store listing for issues, WordPress article link for news | S3 |
| Per-user reading-activity tracking | Excluded (analytics dashboard excluded) | Remains excluded | S2, S3 |
| Delivery team | One developer | Sanika Attarde as contracting developer, working with Developer YG | S3 |

### 17.4 Technical decisions
The architecture, authentication provider, reader library and data model are not approved by this charter. Each is decided in a recorded decision, agreed by both developers. A decision that adds third-party cost, changes scope or touches the contract is approved by MFW in writing before it is implemented.

### 17.5 Source control
`main` is the stable integration branch. Work is done on `YG` and `SA`. Changes reach `main` only through a reviewed integration by the other developer. Detailed branching, review and release procedures are defined in the development workflow document.

## 18. Major Risks

| ID | Risk | Initial response |
|---|---|---|
| R1 | Interactive reader performs poorly on low-end phones or heavy PDFs, or a third-party library carries licence cost or restrictions | Test on MFW's real PDFs in Week 2 against stated targets. Build a swipe and zoom reader as the fallback. Use no paid component without MFW's written approval. |
| R2 | Large PDF performance and bandwidth. Files up to 150 MB are downloaded in full before reading, with no CDN at launch. | Resume interrupted downloads, show a size warning on mobile data, test with the largest expected issue. |
| R3 | Offline content handling: interrupted downloads, storage use, damaged files | Cover under AC-2 and AC-4. Keep downloads in app-private storage. |
| R4 | Authentication and protected-content access. Full issues must not be reachable without signing in. The mandatory profile adds a registration step, and Google users need a profile-completion step. | Enforce access in the backend, not only in app screens. Test with direct file requests (AC-3). |
| R5 | WordPress API blocked, slow or not enabled | Confirm access in Week 1, test early, cache recent articles. |
| R6 | Parallel development conflicts between two developers on one codebase and one cloud project | Branch discipline, reviewed integration into `main`, an agreed task split. |
| R7 | Compressed timeline. Start moved up from 16 November, client inputs due earlier, added scope absorbed. | Eight weeks remains the commitment. Track client inputs weekly. Raise delays in writing. |
| R8 | Store account lead time and review. Apple organisation enrolment can take weeks. Review timing and outcome are outside the team's control. | Start enrolment in Week 1. M5 completes at submission. No approval date is promised. |
| R9 | Apple App Store Review Guideline 4.8. The iOS build offers Google Sign-In and email login but not Sign in with Apple, so review may require an equivalent privacy-preserving login option. | Accepted risk [S3]. Sign in with Apple is the known mitigation and would be handled as a change request if Apple requires it. |
| R10 | Minors' data. Age is collected with no age gate or parental-consent flow, and India's data protection rules on children's data are due to apply within months of launch. | Raised with MFW as the party responsible for the data. MFW's legal adviser to confirm. An age gate can be added later by change request. |
| R11 | Personal data collection. Mandatory profile fields raise privacy obligations, and store privacy declarations must match MFW's policy. | MFW's privacy policy names the fields and purpose. The developers implement consent and deletion [S2]. |

## 19. Assumptions and Open Decisions

### 19.1 Confirmed facts
- MFW owns the brand assets and magazine content. Official branding will be supplied.
- The project uses Flutter for Android and iOS. WordPress remains the publishing platform for news.
- Fee INR 91,000. INR 28,000 received [S3].
- Start 21 October 2026, eight-week delivery [S3].
- No guest reading. Logged-out users see public magazine metadata and news. Full reading and offline downloads require an account [S3].
- Google Sign-In is in scope for Android and iOS. Sign in with Apple is not [S3].
- Exact age and the other profile fields are mandatory [S3].
- Sanika Attarde owns the repository and works on branch `SA`. Developer YG works on branch `YG`. `main` is the stable integration branch.

### 19.2 Assumptions carried from S2
Each issue is one PDF of up to 150 MB and about 120 pages, with five to twelve issues live at launch. The WordPress API is on and reachable over HTTPS. App text is English only. MFW holds the Firebase project and the organisation accounts with Apple and Google. A small editorial team uses one admin role. Apple and Google store policies are as published today.

### 19.3 Open decisions

| No. | Decision | Resolved in |
|---|---|---|
| D1 | Which MFW people are the authorised approver and deputy, and whether Sandeep Gaikwad and Subhajit hold those roles | Before M1 approval |
| D2 | Final list of mandatory profile fields. How and when they are collected, including for Google Sign-In users. Storage format for exact age. | Requirements document |
| D3 | Reader approach and any licensing, per S2 (native page-turn with swipe fallback) | M2 reader test |
| D4 | Final architecture, authentication design and data retention | Architecture document |
| D5 | How verified email applies to Google accounts | Architecture and requirements documents |
| D6 | Whether the nil GST position in S1 applies at the revised fee | Confirm with MFW |
| D7 | How the S3 amendments are recorded formally, for example a consolidated change record or amended SOW | Before M2 |
| D8 | Transfer of the repository to MFW. S1 passes ownership when the final invoice is paid, and S2 AC-12 requires an MFW-owned repository at handover. The repository is currently owned by Sanika Attarde. | Before M5 |
| D9 | Detailed task split between the two developers | Task assignment document |

## 20. Approval and Sign-Off

| Role | Name | Signature | Date |
|---|---|---|---|
| MFW authorised approver | To be completed | | |
| MFW deputy approver | To be completed | | |
| Contracting developer | Sanika Attarde | | |
| Developer YG | Yuvraj | | |
