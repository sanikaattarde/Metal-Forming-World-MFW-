# Glossary: Metal Forming World (MFW) Mobile Application

## 1. Purpose and Status

| Field | Detail |
|---|---|
| Document title | Glossary |
| File | `GLOSSARY.md`, in the same folder as `REQUIREMENTS_SPECIFICATION.md` |
| Project | Metal Forming World (MFW) mobile application |
| Version | 0.1 |
| Status | Draft for Review |
| Last updated | 23 October 2026 |
| Prepared by | MFW development team |
| Approval status | Not approved. No MFW or internal approval of this document has been recorded. |
| Related documents | [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) v0.1; [Scope and Exclusions](SCOPE_AND_EXCLUSIONS.md) v0.1; [Assumptions and Constraints Register](ASSUMPTIONS_AND_CONSTRAINTS.md) v0.1; `PROJECT_CHARTER.md` v0.1; `MFW_Statement_of_Work.pdf` (S2); `MFW_Commercial_Proposal-2.pdf` (S1) |

**Purpose.** This glossary explains the terms used in the MFW project documents so that the developers and MFW read them the same way. Definitions use the wording of S1, S2, the charter and the specification wherever possible.

**How to read it.**

- Terms are in alphabetical order, grouped by first letter.
- Each definition is in plain language. A technical note is added only where it is needed.
- "References" points to requirement IDs, specification items, scope items (SCP, EXC, CHG) and register entries (REG).
- Where a term is ambiguous in the sources, the entry records the ambiguity. It does not choose a meaning.
- A definition never answers an open question or resolves a conflict. Where a term depends on one, the entry names it.
- Naming a technology here does not mean it has been approved. Firebase and its services are proposed in S2 and are not approved (C-05; REG-035).
- Status labels are explained under their own names (CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN, CONFLICT). Where a requirement's status is quoted, it is the specification's status.

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft for internal review |

## 2. Source Codes

| Code | Meaning |
|---|---|
| S1 | The commercial proposal, `MFW_Commercial_Proposal-2.pdf`, 17 October 2026. Unsigned. |
| S2 | The statement of work, `MFW_Statement_of_Work.pdf`, 17 October 2026. Unsigned. |
| S3 | Client emails received after S1 and S2. Not available in the repository. |
| CH | The project charter, `PROJECT_CHARTER.md` v0.1. Draft for review. |
| Spec | The [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) v0.1. Draft for Review. |
| DEV | Marks an inference or proposal by the development team that needs approval. |
| Scope §n | A section of [SCOPE_AND_EXCLUSIONS.md](SCOPE_AND_EXCLUSIONS.md) |
| Register §n | A section of [ASSUMPTIONS_AND_CONSTRAINTS.md](ASSUMPTIONS_AND_CONSTRAINTS.md) |

## 3. Terms

### A

| Term | Definition | References |
|---|---|---|
| Acceptance criterion (AC) | A pass-or-fail check that a tester can observe. S2 sets twelve: AC-1 to AC-12. The S2 text is authoritative, and the specification only summarises it. One acceptance criterion can verify several requirements. Not the same as a requirement, and not the same as a proposed acceptance criterion (PAC). | S2 Acceptance criteria; spec §10.1 |
| Acceptance testing | The S2 process near the end of the build. The developers deliver a test build and a test script. MFW has five working days to test and log defects. The developers reply to each item within one working day, and MFW checks each fix within two working days. Acceptance is signed off when no critical or high defect is open. | S2 Acceptance testing; spec §10.1; SCP-082 |
| Access incomplete | See Signed-in reader. | Spec §3.2 |
| Account deletion | A reader deletes their account from inside the app. Deletion removes the reader's data: the account, profile, bookmarks, favourites, notification preferences and any edition-update sign-up. Whether any record is kept after deletion is OPEN (OQ-24). | FR-AUTH-009, FR-PRIV-003; SCP-014; REG-025 |
| Admin panel | MFW's web application for its editors. It is used to upload issues, manage categories, publish and unpublish issues, control how news appears in the app, send notifications and export lists. It is the product's only web interface. Not the same as the WordPress site, where news is written. S1 calls it "Admin Panel / CMS". | FR-ADMIN-001; S2 Product; SCP-060 |
| Administrator (admin) | A member of MFW's editorial team with an admin account in the admin panel. There is one admin role, and every admin has the same permissions. How admin accounts are created and removed is OPEN (OQ-20). | FR-ADMIN-004, DATA-011; spec §3.2; REG-056 |
| Analytics (Firebase Analytics) | A Google service that records how an app is used. S2 proposes "Firebase Crashlytics and Analytics" for crash reports and basic usage events. Proposed in S2, not approved (C-05). Which events are recorded is OPEN (OQ-23). | S2 Architecture: Monitoring; NFR-OBS-002; REG-027 |
| API (application programming interface) | A defined way for one program to request data from another. In this project it mainly means the WordPress REST API. | INT-WP-001 |
| APNs (Apple Push Notification service) | Apple's service that delivers push notifications to iPhones and iPads. S2 calls it "Apple's push service". In the S2 proposal, FCM passes notifications to it. It uses MFW's Apple Developer Program account. | INT-PUSH-001, INT-PUSH-002; REG-046 |
| App-level news control | A setting in the admin panel that hides a WordPress post in the app, marks it as breaking, or sends it as a notification. It changes how the post appears in the app only. It does not change the post in WordPress. | S1 Annex A notes; FR-ADMIN-013, FR-ADMIN-014, FR-ADMIN-015, DATA-009; SCP-065 |
| App stores | The Apple App Store and Google Play. The app is published through MFW's own accounts. Approval and its timing are decided by Apple and Google. | INT-STORE-001; EXC-21; REG-047, REG-048 |
| Archive issue | A published issue that is not the latest one. At launch the catalogue holds four to six archive issues. | FR-MAG-004; S2 AC-1 |
| ASSUMPTION | (1) A status label in the specification: an S2 planning assumption, or a development-team proposal that needs MFW's approval. A requirement with this label is not agreed scope until MFW approves it. (2) A register entry type: an unverified working proposition. | Spec §1.2; Register §2.1; CHG-10 |
| Authentication | Confirming who a user is, by signing in. Email and password sign-in is CONFIRMED. Google Sign-In is PROVISIONAL. Not the same as authorisation. | FR-AUTH-001, FR-AUTH-005; SCP-010, SCP-016 |
| Authorisation (authorization) | Deciding what a signed-in user may do, for example open a full issue or use the admin panel. It is enforced by the backend, not only by the app's screens. Not the same as authentication. | BR-002, BR-003, NFR-SEC-002, NFR-SEC-007; spec §9.2 |
| Authorised approver | The person MFW names to approve deliverables and changes in writing, with a deputy. Approval by email is enough. Neither has been named yet. | S2 Responsibilities; OQ-28; REG-002 |

### B

| Term | Definition | References |
|---|---|---|
| Backend services | The server side of the product: accounts, the database, private file storage, server logic and notification delivery, on accounts MFW owns. The technology is not yet decided. S2 proposes Firebase. | Spec §2.2; SCP-071, SCP-072; REG-035 |
| Baseline (scope baseline) | The agreed scope that work is measured against. S1 and S2 are the issued baseline, but both are unsigned. The S3 amendments recorded in CH are PROVISIONAL. CH calls the baseline "approved", which the evidence does not yet support. | CH §17.1; Scope §2.5; REG-001, REG-002, REG-003 |
| Basic usage events | See Usage events. | NFR-OBS-002 |
| Bookmark | A saved reference to one page of an issue. Opening it opens the issue at that page. Bookmarks are stored with the reader's account. Not the same as a favourite, which marks a whole issue. | FR-BKM-001, FR-BKM-002, DATA-005; SCP-042 |
| Breaking news | A WordPress post that an admin marks as breaking in the admin panel. An admin can also send it as a breaking-news notification. How a breaking post is shown in the app is OPEN (OQ-17). | FR-ADMIN-014, FR-ADMIN-015, FR-NEWS-009; SCP-055, SCP-065 |

### C

| Term | Definition | References |
|---|---|---|
| Cached content (caching) | A copy of content kept on the device so that it can be shown again without fetching it. In S2, recent news articles are cached so the app does not overload MFW's website. Not the same as a downloaded issue. Whether catalogue metadata, bookmarks and favourites are available offline is OPEN (OQ-10). | S2 Flow 2; INT-WP-004, FR-NEWS-005; REG-016 |
| Catalogue | See Magazine catalogue. | FR-MAG-001 |
| Category | Three different things in this project. An issue category is a label MFW's admins give issues, used for search and filters. A news category is a WordPress category, and MFW chooses which ones the app shows. A notification category is a topic a reader opts into, such as new issues, expo specials or major news. | FR-ADMIN-010, INT-WP-003, FR-NOTIF-002, FR-NOTIF-006 |
| CDN (content delivery network) | A network of servers that delivers files from locations close to users. S2's proposed architecture has none at launch, so readers download a whole issue before reading it. Adding one is an architecture decision, and any added cost needs MFW's written approval. | NFR-STOR-003; CHG-05; REG-034 |
| Change request | The S2 process for any change. MFW's approver describes the change in writing. Within two working days the developers reply with the effort, price, effect on dates and any new third-party cost. MFW approves in writing, and no work starts before that. Anything that is not a defect is a change. | S2 Changes; spec §14.3; CHG-01, CHG-02; REG-059 |
| Cloud Functions | A Google service that runs server code in response to events or requests. S2 proposes it for upload checks, publishing, sending notifications and account deletion. Proposed in S2, not approved. | S2 Architecture: Server logic; REG-035 |
| Cloud Storage (Cloud Storage for Firebase) | A Google file storage service. S2 proposes it for magazine PDFs and covers, stored privately. Proposed in S2, not approved. | S2 Architecture: File storage; INT-FILE-001; REG-035 |
| CMS (content management system) | Software for managing content. S1 labels the admin panel "Admin Panel / CMS". It manages issues, categories and notifications. News content is still managed in WordPress, not in the admin panel. | S1 Annex A section E; FR-ADMIN-019; EXC-12 |
| Co-developer | The second developer recorded in CH as working with the contracting developer [S3]. The two-developer arrangement is PROVISIONAL. | CH §7, §14; REG-052 |
| CONFIRMED | A status label. The item is stated in S1 or S2 and no later record changes it. S1 and S2 are unsigned, so their formal acceptance is itself unverified. | Spec §1.2; OQ-28 |
| CONFLICT | (1) A status label: the available sources disagree, and the requirement states the position used until a decision is made. (2) A register entry type: statements that cannot all be true and need a decision. | Spec §1.2, §12.3; Register §2.1 |
| Consent | A reader's agreement to MFW's privacy policy and terms of use, given at registration. How consent is recorded is OPEN (OQ-27). | FR-PRIV-001, DATA-012; SCP-013; REG-024 |
| CONSTRAINT | A register entry type: a documented limitation or obligation. | Register §2.1 |
| Content administrator | Not a term used in S1, S2, CH or the specification. The sources speak of an "admin" or "administrator", and of MFW's "editors" or "editorial team". There is one admin role, and separate content roles are excluded. See Administrator. | FR-ADMIN-004; EXC-07 |
| Contracting developer | The developer named in S1 and S2 as the party doing the work. | S1; S2; CH §14 |
| Crash reporting (Crashlytics) | Automatic reports sent when the app crashes, so that faults can be found. S2 proposes Firebase Crashlytics, a Google crash-reporting service. Crash reporting is CONFIRMED in S2. The Crashlytics product is proposed, not approved. CH §8 does not list crash reporting (C-07). | NFR-OBS-001; SCP-076; REG-027 |
| CSV export | A download of a list as a comma-separated values file, which opens in spreadsheet programs. Two exports are recorded: the subscriber list (FR-USER-001, CONFLICT) and the registered-user list (FR-USER-003, PROVISIONAL). | SCP-067, SCP-068; REG-026 |

### D

| Term | Definition | References |
|---|---|---|
| Damaged file | An issue file that cannot be opened properly. The app shows an error with a retry option. | FR-READ-010; S2 AC-2 |
| Deep link | Not a term used in the sources. S2 excludes "shared links that open the app directly". Shared links open a store listing or a web page instead. | FR-SHR-005; EXC-08 |
| Defect | A failure against an acceptance criterion, fixed at no charge. S2 defines four severities. Critical: stops the app working or exposes data. High: a confirmed feature does not work and there is no workaround. Medium: a visible fault with a workaround. Low: cosmetic. Anything else is a change. | S2 Defect or change; S2 Acceptance testing; spec §10.1 |
| DEPENDENCY | A register entry type: an external input, service, decision or deliverable the project needs. | Register §2.1 |
| DEV | Marks an inference or proposal by the development team. A DEV item needs MFW's approval. | Spec §1.2, §1.4 |
| Downloaded issue | A complete copy of an issue's PDF kept in the app's private storage on the device. It can be read with no network connection and is listed on the Downloads screen. Whether opening an issue always creates one is OPEN (OQ-08). | FR-DL-001, FR-DL-007; spec §4.3; REG-029 |
| Downloads screen | The screen that lists downloaded issues and lets the reader delete them. Deleting a download frees its storage space. | FR-DL-008, FR-DL-009 |
| DRM (digital rights management) | Technical copy protection for files. Excluded. Protection is limited to login gating and private storage. | NFR-SEC-009; EXC-19 |

### E

| Term | Definition | References |
|---|---|---|
| Edition | Used in two ways in the sources. (1) A general word for an issue of the magazine, as in "digital edition" or "every edition is free". (2) A filter field: S2 includes "edition filters". The meaning of "edition" as a filter is OPEN (OQ-13). This glossary does not choose it. | S2 Objectives; S2 Scope: Discovery; FR-SRCH-005; REG-016 |
| Edition-update email sign-up | An optional sign-up, in S1 and S2, for emails about new editions. The edition-update list is the stored set of email addresses. Whether the sign-up is kept, dropped or merged into registration is unresolved (C-02, OQ-31). Its status is CONFLICT. If it is kept, MFW sends the emails with its own tools. | FR-EMAIL-001, DATA-010; FR-EMAIL-003; SCP-022; EXC-15; REG-026 |
| Email verification | Confirming that a reader controls the email address given at registration, through a link in a verification email. Email accounts need a verified address before a full issue opens. Whether verification applies to Google accounts is OPEN (OQ-04). | FR-AUTH-002, FR-AUTH-007, BR-002; REG-020 |

### F

| Term | Definition | References |
|---|---|---|
| Favourite | An issue the reader has marked as a favourite. It marks a whole issue, while a bookmark marks a page. Favourites are stored with the reader's account. | FR-BKM-003, DATA-006; SCP-042 |
| FCM (Firebase Cloud Messaging) | A Google service that sends push notifications to Android and iOS apps. On iOS it passes notifications to APNs. S2 proposes it. Proposed in S2, not approved. | S2 Architecture: Notifications; INT-PUSH-001; REG-035 |
| Firebase | Google's platform of hosted app services. S2 proposes one MFW-owned Firebase project for accounts, the database, file storage, server logic, messaging and monitoring. S2 M3 and AC-12 and parts of S1 also name Firebase, but CH states that the architecture is not approved (C-05). Its appearance in this glossary does not mean it has been approved. | S2 Architecture; CH §17.4; SCP-072; REG-035 |
| Firebase Authentication | A Google sign-in service. S2 proposes it for email and password sign-in, email verification, password reset and admin roles. Proposed in S2, not approved. | S2 Architecture: Accounts; INT-AUTH-001; REG-035 |
| Firestore (Cloud Firestore) | A Google-hosted database. S2 proposes it for issues, categories, bookmarks, favourites, preferences and the update list, protected by security rules. Proposed in S2, not approved. | S2 Architecture: Database; REG-035 |
| Flipbook | S1's word for the interactive magazine reader with a page-turn effect ("Interactive flipbook / PDF reader"). A commercial flipbook licence is a paid third-party reader component. None is assumed, and one is bought only with MFW's written approval. | S1 Annex A lines 6, 13; S1 Costs outside the fee; CHG-03; REG-040 |
| Full access | See Signed-in reader. | Spec §3.2, §9.2 |
| Full issue | The complete PDF content of an issue, as opposed to its public metadata. Only signed-in readers with full access can open or download it. | Spec §4.3; FR-READ-001, BR-002 |

### G

| Term | Definition | References |
|---|---|---|
| Google-authenticated user | Not a term used in the sources. It can be read as a reader whose account uses Google Sign-In. Three points about such readers are OPEN: whether email verification applies (OQ-04), when they complete the mandatory profile (OQ-03), and what happens when the same email address is used with both sign-in methods (OQ-05). | FR-AUTH-006, FR-AUTH-007, FR-PROF-003; REG-020, REG-022 |
| Google Sign-In | Signing in with a Google account. S1 and S2 place it in a later phase. CH records it as moved into scope [S3]. Its status is PROVISIONAL, and the source conflict is C-04. | FR-AUTH-005, INT-AUTH-002; SCP-016; REG-017 |
| Guest | Ambiguous. In S1 and S2 a guest is a user who is not signed in and who can browse and see "only a public sample". CH records that guest reading and the public sample are removed [S3], and the specification reads "guests" in AC-3 as logged-out visitors (C-01). The project documents use "logged-out visitor" instead. "No guest reading" does not mean logged-out visitors see nothing. They can still browse public metadata and read news. | S2 Scope: Accounts; S2 Flow 3; BR-001; EXC-02; REG-019 |

### H

| Term | Definition | References |
|---|---|---|
| Home screen | The app's first main screen. Its content is set in the M2 screen designs. | FR-MAG-006; SCP-002 |
| HTTPS | The encrypted form of the web protocol. All network traffic in the product uses it. | NFR-SEC-001; SCP-073 |

### I

| Term | Definition | References |
|---|---|---|
| Industry segment | A filter for issues. S2 says "industry filters" and CH says "industry segment". What it means for filtering is OPEN (OQ-13). | FR-SRCH-003; PAC-07; REG-016 |
| Issue | One magazine edition, held as one PDF file with a cover image and details. "Edition" is often used with the same meaning. | Spec §4.3; DATA-001 |
| Issue details screen | The screen that shows an issue's public metadata and the action to read or download it. | FR-MAG-005 |

### L

| Term | Definition | References |
|---|---|---|
| Latest issue | The most recent published issue, shown with the archive in the catalogue. | FR-MAG-004 |
| Library | S1's and S2's word for the catalogue and archive ("Library and discovery", "Magazine library"). See Magazine catalogue. | S1 What MFW receives; S2 Architecture: Mobile app |
| Logged-out visitor (logged-out user) | Anyone using the app without being signed in. A logged-out visitor can browse the catalogue and public metadata, read news, and, as a development-team proposal, search and filter. A logged-out visitor cannot open or download a full issue. Notifications, sharing and the edition-update sign-up for logged-out visitors are OPEN (OQ-09). | Spec §3.2, §9.2; FR-MAG-001, FR-NEWS-007, FR-SRCH-006; REG-021 |

### M

| Term | Definition | References |
|---|---|---|
| Magazine catalogue | The list of published issues shown in the app: the latest issue and an archive of earlier issues. Every user can see it, including logged-out visitors. | FR-MAG-001, FR-MAG-004; SCP-026 |
| Magazine metadata | Information that describes an issue rather than its pages: title, description, category, industry segment, publication date, year, edition, cover image, file size and publication state. Public metadata is the part shown without sign-in. | DATA-001; FR-MAG-009 |
| Mandatory profile | See Profile. | FR-PROF-001 |
| MFW | Metal Forming World, the client. MFW publishes an industrial magazine and industry news, and owns its brand, content and reader data. | S2 Objectives; DATA-016 |
| Milestone (M1 to M5) | The five approval points in S2: M1 Kickoff, M2 Design approval, M3 Core app and backend, M4 Feature-complete build, M5 Approval and store submission. Each ends with a delivery that MFW approves in writing. The dates differ between S2 and CH (C-08). | S2 Deliverables and milestones; REG-006 |

### N

| Term | Definition | References |
|---|---|---|
| News post (article) | A post on MFW's WordPress site shown in the app. News is written and edited only in WordPress. | Spec §4.3; FR-NEWS-001, FR-ADMIN-019 |
| Notification category | See Category. A reader chooses which notification categories to receive. The final list is OPEN (OQ-18). | FR-NOTIF-002, FR-NOTIF-006; SCP-057 |

### O

| Term | Definition | References |
|---|---|---|
| Offline download | The act of downloading an issue so it can be read without a network connection, and the copy that results. See Downloaded issue. | FR-DL-001; SCP-036 |
| Online reading | Ambiguous. CH §8 lists "Online reading" without defining it. S2 does not provide reading an issue before its full download finishes, and the specification follows S2 (C-03). This glossary does not define "online reading" as streaming, as reading a temporary copy, or as anything else. | FR-READ-002; EXC-03; REG-028, REG-029 |
| OPEN | (1) A status label: a decision or clarification is needed, and the requirement points to an open question. (2) A register entry type: an unresolved question. | Spec §1.2, §12.2; Register §2.1 |

### P

| Term | Definition | References |
|---|---|---|
| PAC (proposed acceptance criterion) | A pass-or-fail check proposed by the development team for PROVISIONAL requirements and gaps in AC-1 to AC-12. There are eleven: PAC-01 to PAC-11. They are not contractual until MFW approves them in writing. | Spec §10.2; CHG-10; REG-058 |
| Page-turn effect | An animation that imitates turning the page of a printed magazine. The reader approach is confirmed at M2 after a test on MFW's PDFs. A plain swipe mode is always built as the fallback. | FR-READ-006, FR-READ-007; REG-033 |
| Pagination | Requesting a long list in small pages instead of all at once. The app requests WordPress posts this way so it does not overload MFW's website. | S2 Flow 2; INT-WP-004 |
| PDF (Portable Document Format) | The file format of each magazine issue. S2 assumes each issue is one PDF of up to 150 MB and about 120 pages. Uploads over the size limit, 150 MB by default, are rejected. | NFR-STOR-001, FR-ADMIN-007; REG-031, REG-032 |
| PDF reader (reader component) | The part of the app that displays an issue's pages, with swipe and tap page turns, pinch zoom, the page-turn effect and the two-page spread. Not the same as a reader, the person. | FR-READ-003 to FR-READ-010; SCP-032 |
| Private storage | On the device, the app's own storage area, which other apps cannot read. Downloaded issues are kept there. In the backend, "stored privately" means files are not published at a public address. | NFR-SEC-003, NFR-SEC-004; SCP-040 |
| Profile (mandatory reader profile) | The information a reader must give to complete registration, recorded in CH as name, exact age, gender, occupation and domain of work, and possibly further fields [S3]. Its status is PROVISIONAL. The final field list and formats are OPEN (OQ-01, OQ-02). | FR-PROF-001, FR-PROF-002, DATA-004; SCP-018; REG-022 |
| Profile completion | Providing every mandatory profile field. Under the PROVISIONAL requirements, registration is complete only after it, and a full issue opens only after it. When Google Sign-In readers complete it is OPEN (OQ-03). | FR-PROF-001, FR-PROF-003, FR-PROF-004, BR-003 |
| PROVISIONAL | A status label. The item is recorded in CH as a client amendment [S3], but the S3 emails are not in the repository. It is the working position, but it is not confirmed until the S3 record is filed or MFW confirms in writing (OQ-29). | Spec §1.2; REG-001 |
| Public metadata | Issue information shown without sign-in: cover, title, description, category, publication date, and any other fields MFW approves. The complete list is OPEN (OQ-13). | Spec §4.3; FR-MAG-009; SCP-029 |
| Publish, unpublish | Admin actions that make an issue appear in, or disappear from, the app after a refresh, without an app update. | FR-ADMIN-011, FR-MAG-007, FR-MAG-008; SCP-028 |
| Push notification | A message that appears in the device's notification area, even when the app is not open. Admins send them to a notification category, and only devices that opted in to that category receive them. Delivery time depends on Apple and Google and is not guaranteed. | FR-NOTIF-004, FR-ADMIN-016, NFR-REL-003; SCP-057, SCP-066 |

### R

| Term | Definition | References |
|---|---|---|
| Reader (person) | In the specification, a signed-in user of the app. "User" means anyone using the app, signed in or not. Not the same as the PDF reader, the software component. | Spec §3.2 |
| Registered user | A person who has created an account. CH also says "registered readers". Under the PROVISIONAL profile requirements, registration is complete only when the mandatory profile is complete. The registered-user list is the admin view and CSV export of registered users with their profile information, which is PROVISIONAL. | FR-USER-002, FR-USER-003; spec §4.3; SCP-068 |
| Requirement ID | A stable identifier for a requirement in the specification: FR (functional), NFR (non-functional), DATA (data), INT (integration) or BR (business rule). IDs are never reused. Other ID families: OQ, C, ASM and PAC in the specification; SCP, EXC and CHG in the scope document; REG in the register. | Spec §14.3; Scope §1.3; Register §2.5 |
| Role-based access | Giving each person their own access to an account, with set permissions, through the platform's own access controls instead of shared passwords. MFW gives the developers access this way. | NFR-SEC-012; S2 Responsibilities; REG-038 |

### S

| Term | Definition | References |
|---|---|---|
| Security checklist | A list of security checks completed before acceptance testing (AC-10). Its contents are defined in the test strategy, which has not been written. | NFR-SEC-010; REG-041 |
| Security rules | Rules in the backend that control who can read or change each piece of data. Under S2, a reader sees only their own bookmarks and favourites, and only admin accounts change the catalogue. | S2 Scope: Platform; S2 Rationale; NFR-SEC-005, NFR-SEC-007 |
| Send log | The admin panel's record of notifications sent, with one entry per send. The fields recorded are OPEN (OQ-19). | FR-ADMIN-018, DATA-008; SCP-066 |
| Share link | The link included when a reader shares an issue or article through the device's share sheet. For an issue it points to the app's store listing, and for an article to its public WordPress address. Both targets are PROVISIONAL. Which store link is used is OPEN (OQ-15). Shared links do not open the app directly. | FR-SHR-002, FR-SHR-004, FR-SHR-005; SCP-046; EXC-08 |
| Share sheet | The device's standard menu for sharing content with other apps. | FR-SHR-001, FR-SHR-003 |
| Sign in with Apple | Apple's sign-in option. Excluded. Offering Google Sign-In on iOS without it carries an App Store review risk that MFW is asked to accept in writing (OQ-06). | EXC-01; CHG-06; REG-018 |
| Signed build | An app build signed with the developer credentials that stores and devices use to verify where it came from. Release builds are signed and made from tagged source code. Who holds the signing credentials is OPEN in the register. | NFR-MAINT-003; SCP-084; REG-051 |
| Signed-in reader | A reader who has signed in. With access incomplete, the reader has not verified their email address (email accounts) or has not completed the mandatory profile (PROVISIONAL). With full access, both conditions are met, and the reader can open and download full issues. | Spec §3.2, §9.2; BR-002, BR-003 |
| Store listing | An app's page in the App Store or Google Play. Its text must be approved by MFW, and its privacy details must match MFW's privacy policy. | NFR-PRIV-002; S2 AC-11; REG-050 |
| Subscriber, subscription | Ambiguous. In S1's Annex A notes, "subscription" in lines 10 and 19 means the optional edition-update email sign-up. S2 AC-8 and S2 Scope: Admin panel require a "subscriber list" with CSV export, and S2 Architecture: Admin panel says editors manage "subscribers". S2 Flow 4 says notifications reach readers "who subscribed to that category", meaning notification opt-in. CH describes a registered-user list instead. Paid subscriptions are excluded. Which meaning applies to AC-8 is unresolved (C-02, OQ-31). This glossary does not choose it. | FR-USER-001, FR-EMAIL-001; EXC-10; REG-026 |
| Swipe mode | A plain reader mode that turns pages by swiping, without the page-turn effect. It is always built as the fallback. Whether readers can switch modes is OPEN (OQ-14). | FR-READ-007, FR-READ-008 |

### T

| Term | Definition | References |
|---|---|---|
| Tagged source code | A version of the source code marked with a named tag in version control, so that a release build can be traced to the exact code it was made from. | NFR-MAINT-003; S2 AC-11 |
| Temporary download | Not a term used in the sources. It can be read as a complete copy of an issue kept only for reading, as distinct from a copy kept for offline use. Whether the product has such a copy is OPEN (OQ-08). It is not reading before the download finishes, which is excluded. | OQ-08; EXC-03; REG-029 |
| Test build, test script | The build and step-by-step test instructions the developers deliver to MFW for acceptance testing. | S2 Acceptance testing; SCP-082 |
| Traceability matrix | A table that links each requirement to its source, status, verification method and dependencies. The specification's matrix is in its Section 13. The scope document's Section 15 links scope items to requirements and acceptance criteria. | Spec §13; Scope §15 |
| Two-page spread | Two pages shown side by side on tablets and in landscape orientation. | FR-READ-009; S2 AC-2 |

### U

| Term | Definition | References |
|---|---|---|
| Usage events | Records of how the app is used, sent to a monitoring service. S2 includes "basic usage events". The event list, and whether consent is needed first, are OPEN (OQ-23). Usage events must not record which reader opened which issue or page (PROVISIONAL). | NFR-OBS-002, NFR-PRIV-003; SCP-076; EXC-06; REG-027 |
| User | Anyone using the app, signed in or not. See also Reader (person). | Spec §3.2 |

### V

| Term | Definition | References |
|---|---|---|
| Verified user | Not a term used in the sources. It can be read as a reader whose email address has been verified. For email accounts, verification is needed before a full issue opens. Full access also needs a complete profile (PROVISIONAL). How verification applies to Google accounts is OPEN (OQ-04). | BR-002, BR-003; REG-020 |

### W

| Term | Definition | References |
|---|---|---|
| Warranty | Thirty days of defect correction at no charge. It starts when the app first becomes publicly available in a store, using the later date if the two stores differ, and ends no later than 60 days after submission. Support after the warranty is excluded. | S2 Warranty; SCP-090; EXC-22 |
| WordPress | The platform that runs MFW's existing website, where news is written. The project does not change the site. | INT-WP-002; EXC-12; REG-044 |
| WordPress REST API | WordPress's built-in web API, which returns posts, categories and images as data over HTTPS. The app reads news through it. S2 assumes it is switched on and reachable. | INT-WP-001, INT-WP-004; REG-042, REG-043 |

## 4. Terms That Are Easily Confused

| Terms | Difference |
|---|---|
| Issue and edition | An issue is one magazine edition held as one PDF. "Edition" also names a filter field whose meaning is OPEN (OQ-13). |
| Reader (person) and PDF reader | A reader is a signed-in user. The PDF reader is the software that displays pages. |
| Bookmark and favourite | A bookmark marks a page. A favourite marks a whole issue. |
| Logged-out visitor, guest, registered user, verified user, Google-authenticated user | A logged-out visitor is anyone not signed in. "Guest" is the S1 and S2 word for a logged-out user, tied to a public sample that CH removes (C-01). A registered user has an account. "Verified user" and "Google-authenticated user" are not source terms. Full access needs sign-in, a verified email for email accounts, and a complete profile (PROVISIONAL). |
| Downloaded issue, temporary download, cached content, online reading | A downloaded issue is a complete PDF copy on the device. "Temporary download" is not a source term, and whether one exists is OPEN (OQ-08). Cached content is mainly recent news articles. "Online reading" is undefined (C-03). Reading before a full download finishes is excluded. |
| Authentication and authorisation | Authentication confirms who someone is. Authorisation decides what they may do. |
| Admin panel and WordPress | The admin panel manages issues, categories, notifications and app-level news controls. WordPress is where news is written. |
| Subscriber list, edition-update list, registered-user list, notification opt-in | The edition-update list holds addresses of users who opted into edition-update emails (CONFLICT). The registered-user list holds registered users with their profiles (PROVISIONAL). Notification opt-in is a reader's choice of notification categories. Which list AC-8's "subscriber list" means is unresolved (OQ-31). |
| Issue category, news category, notification category | An issue category labels issues. A news category is a WordPress category. A notification category is a topic readers opt into. |
| Requirement, acceptance criterion, proposed acceptance criterion | A requirement states what the product must do. An acceptance criterion (AC) is an S2 pass-or-fail check. A PAC is a proposed check that is not contractual until MFW approves it. |
| Defect and change | A defect is a failure against an acceptance criterion, fixed at no charge. Anything else is a change and needs a change request. |
| Status labels and register types | CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN and CONFLICT are the specification's status labels. ASSUMPTION, CONSTRAINT, DEPENDENCY, OPEN and CONFLICT are the register's entry types. Three words appear in both lists. The register's fields say which use is meant. |
| Named and approved technology | Firebase and its services are named in S1 and S2, and S2 proposes them. They are not approved (C-05). |
