# MFW Request Drafts: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/MFW_REQUEST_DRAFTS.md` |
| Tasks | MOD20-P2-T01 (written records on the baseline), MOD20-P2-T02 (open product questions and change requests) and MOD20-P2-T03 (the M1 requirements and architecture note). The tasks are Sanika Attarde's, who holds the contact with MFW (CH section 14) |
| Version | 0.1 |
| Status | Draft for review. **Three drafts. Nothing is sent.** Each is text for the sender. It asks MFW for answers and records none. It approves nothing and changes no status label |
| Date | 14 November 2026 |
| Prepared by | Yuvraj Gaykhe |
| Sent by | Not decided. The contracting developer sends a decision that needs MFW to MFW's approver (`DECISION_LOG.md` section 4, step 4). If Yuvraj Gaykhe sends, Sanika Attarde's written agreement comes first, as for the pack of 8 November 2026 |
| Date sent | Not sent. The date is added to each draft when it goes |

## 1. How the drafts fit together

```text
MFW_QUESTIONS_2026-11-08.md   five questions (OQ-08, OQ-11, OQ-26, OQ-35, OQ-40 and a place for recordings), drafted, not sent
MFW_REQUEST_DRAFTS.md
├── Draft 1  MOD20-P2-T01   the baseline records: approver, S3 emails, commercial terms, two-developer delivery, chat approvals
├── Draft 2  MOD20-P2-T02   the open product questions, each with the team's working position, and the questions of change
└── Draft 3  MOD20-P2-T03   the M1 note and the request for an approval that names it
MFW_INPUTS_RECORD.md           the inputs MFW still owes, and the days late
```

Four of the questions in Draft 2 are also in the pack of 8 November 2026. If that pack is sent first, they are dropped from Draft 2 before it goes. A reply to any email is enough for an approval (S2 Responsibilities).

Nothing of MFW's is attached to any draft (DEC-024).

## 2. Draft 1: the baseline records (MOD20-P2-T01)

Closes OQ-28, OQ-29, OQ-32, OQ-33, OQ-34 and OQ-59 when the answers are filed. The commercial figures are left out of the text, because the sender may prefer to name them. The sender adds them, or not, before it goes.

```text
Subject: MFW app: please confirm the project records in writing

Dear <MFW approver>,

We need a few written confirmations so that the project records are
complete. A reply to this email is enough, and you can answer them one
at a time.

1. Approver and deputy. Please confirm in writing who your authorised
   approver and deputy are, and which of the two holds which role. Please
   also confirm that the Statement of Work and the Commercial Proposal
   dated 17 October 2026 are accepted by MFW, or send the signed copies.

2. Changes agreed by email. Some points were agreed by email after the
   Statement of Work (guest reading, Google Sign-In, the schedule, the
   profile fields, sharing links and the registered-user export). Please
   either confirm each point in writing, or tell us that we may file the
   emails by reference (date, sender's role and subject only, without
   their text, because our repository is public).

3. Fee and payments. The Commercial Proposal and our project charter
   differ on the fee, the advance and the last payment. Please confirm in
   writing which applies, and whether the nil-GST position of the
   Commercial Proposal still applies at that fee.

4. Two developers. The Statement of Work names one developer. Please
   confirm in writing that MFW accepts delivery by two developers.

5. Approvals by chat. Do you accept a message from your authorised
   approver on a chat app (for example WhatsApp) as written approval
   under the Statement of Work, or should approvals be repeated by email?

Thank you.
<Sender>
```

## 3. Draft 2: the open product questions (MOD20-P2-T02)

Puts the questions that block tasks to MFW, each with the team's working position where one is recorded, and asks the questions of change. A working position is the team's, is PROPOSED, and is built or planned on until MFW answers. It is not MFW's answer. The positions come from `OPEN_QUESTIONS.md`, with the provenance notes left out. Where the register records none, the table says so, and the sender can add one before it goes.

```text
Subject: MFW app: product questions for your written answer

Dear <MFW approver>,

The questions below decide how the app and the admin panel behave. For
each we say what we will build unless you tell us otherwise. Please
answer in writing; a reply to this email is enough. You can answer in
parts, and in any order. The questions marked "no working position yet"
need your answer before we can start the work they affect.

The questions are in the table below the email, numbered by their
references (OQ-nn). The sender pastes the table into the email (section 3.1).

Two of them ask whether something is a clarification of the Statement
of Work or a change to it, so that we raise a change request only where
you see one:

A. Admin management (OQ-58): the admin panel lets any admin add or
   remove admins, and keeps a small record of who did it. Is that a
   clarification of the admin panel in the Statement of Work, or a
   change?

B. Edition-update emails (OQ-31): the Statement of Work lists an
   optional edition-update sign-up. We propose to drop it and give you
   one CSV export of registered readers. Is dropping it agreed, and is it
   a clarification or a change?

We also ask for two confirmations:

C. Google Sign-In. Please confirm in writing that Google Sign-In is in
   scope for the first release.

D. Apple's rule. Please confirm in writing that MFW accepts the App
   Store guideline 4.8 risk of offering Google Sign-In without Sign in
   with Apple, which the Statement of Work excludes.

Thank you.
<Sender>
```

### 3.1 The table for Draft 2

| Ref | Question | Team's working position |
|---|---|---|
| OQ-01 | What is the final mandatory profile field list, with the format and allowed values of each field? Is "prefer not to say" offered? What do "related fields" include? | The five fields of the S3 summary - name, exact age, gender, occupation, domain of work. Mobile number, company, country, city and areas of interest are optional candidates, switched on by configuration if MFW asks. |
| OQ-02 | Is exact age stored as a number or as a date of birth, and how does it stay current? | A whole-number age entered by the reader, checked from 1 to 120. |
| OQ-03 | When does a Google Sign-In reader complete the profile: straight after the first sign-in, or before the first full issue? | The profile is collected at registration for both email and Google accounts. The access check still prompts a reader who skipped or abandoned it. |
| OQ-07 | Does MFW's legal adviser confirm the approach to collecting exact age with no age gate or parental-consent flow? | No working position yet |
| OQ-08 | Does opening a full issue always keep it as an offline copy, or is there a temporary copy for reading and a separate action to keep it offline? Also asked in the pack of 8 November 2026. | Read opens a temporary copy, which is not listed in Downloads and goes when the reader closes it or at the next start; Download keeps a copy until the reader deletes it. This is a working position chosen for the build, not MFW's answer. |
| OQ-09 | Can logged-out visitors receive push notifications and set preferences, share issues and articles, and sign up for edition-update emails? | Logged-out visitors can accept notifications and choose categories (a device subscription, so no personal data is stored), and can share issues and articles. The edition-update sign-up is dealt with under OQ-31. |
| OQ-10 | Are catalogue metadata, bookmarks and favourites available offline? Can bookmarks and favourites be changed offline and synchronised later? | The catalogue, bookmarks and favourites last read show offline with a notice, and bookmark and favourite changes made offline are kept on the device and sent when the connection returns. |
| OQ-11 | What happens to downloaded issues when the reader signs out, deletes the account, or the issue is unpublished? Also asked in the pack of 8 November 2026. | For a kept copy, sign-out hides it until the same reader signs in again, account deletion removes it, unpublishing leaves it, and permanent deletion removes it once the app sees the issue on the deleted-issue list. These four rules carry over from earlier work and were not asked again. |
| OQ-12 | Can a signed-in reader without full access use favourites? | Favourites need full access, the same as bookmarks. This is the answer of Yuvraj Gaykhe of 10 November 2026, PROVISIONAL until MFW answers, and the app follows it. |
| OQ-13 | What is the complete list of public issue metadata, including whether file size and page count show before sign-in? What do "industry segment" and "edition" mean for filtering? | Industry segment is the 16 circulation industries of the website, seeded by the developers, several per issue. Edition is a text label such as 'April-May 2026'. Category is the editorial theme, one per issue. |
| OQ-16 | Are news articles kept offline by an explicit save action or automatically? How many are kept? How is embedded media shown? | Recently opened articles are cached automatically and rotate out, and a Save button keeps an article until the reader removes it. |
| OQ-17 | How is a post marked as breaking shown in the app? | A "Breaking" label above the title, and breaking posts first in the news list and the home section, newest first, at most five; the rest in date order. |
| OQ-18 | What is the final list of notification categories, and can admins add or change categories? | Three fixed categories - new issues, expo specials, major news - set by the developers. Admins cannot change the list in the panel. |
| OQ-20 | How are admin accounts created and removed (set up by the developers from MFW's admin list, or managed in the panel), and what does "secure login" include (password rules, two-step verification, session expiry)? | One Admin role. The developers create the first admin at set-up and hand access to MFW. After that any admin adds or removes admins in the panel, by granting the role to a registered reader whose email is verified. |
| OQ-21 | Can an admin permanently delete an issue or replace its PDF, and what happens to copies already downloaded? | Any admin can unpublish an issue, replace its PDF as a new revision, and permanently delete an unpublished issue with a typed confirmation. |
| OQ-22 | What formats, dimensions and maximum size apply to cover images? | No working position yet |
| OQ-23 | Which basic usage events are recorded, and is consent needed before recording them? | No working position yet |
| OQ-24 | What are the retention periods for accounts, profiles, inactive accounts, send records, consent records, crash data and exports? Is any record kept after account deletion? | Account deletion is immediate, with no grace window. |
| OQ-25 | Which accessibility baseline applies? Proposed: app interface text follows the device's text-size setting, controls have screen-reader labels, and text and controls have enough colour contrast. The baseline would not apply to the PDF page content. | No working position yet |
| OQ-26 | What are the minimum Android and iOS versions, the test device models, and the supported admin browsers? Also asked in the pack of 8 November 2026. | No working position yet |
| OQ-27 | How is consent recorded (a checkbox or equivalent action), and are the accepted policy version and date stored? | No working position yet |
| OQ-30 | Is a PDF of exactly 150 MB accepted, and can admins change the limit? Does "MB" mean 10^6 or 2^20 bytes, and are password-protected PDFs rejected at upload? | No working position yet |
| OQ-31 | Is the optional edition-update email sign-up kept, dropped, or merged into registration? Does the S2 AC-8 "subscriber list" mean the edition-update list or the registered-user list? | The admin CSV is the registered-user list with profile fields, and the optional edition-update sign-up is dropped. S1 and S2 list that sign-up, so MFW must agree to drop it in writing. |
| OQ-39 | What is MFW's WordPress site address? Is the REST API reachable over HTTPS without being blocked by security plugins or firewalls? Which categories are shown? | The app shows the nine sections of the website's News menu, which are the WordPress categories with IDs 7 and 11 to 18. Blog (ID 1), which is not in the menu and holds no post, is not shown. |
| OQ-40 | Will MFW provide a separate non-production cloud project for testing, at its cost? Also asked in the pack of 8 November 2026. | No working position yet |
| OQ-41 | In which cloud region are the backend data and backups held? | Everything in Mumbai (asia-south1), after checking that the Firebase console offers it. MFW and its legal adviser decide. |
| OQ-42 | What are the app name, Android application ID and iOS bundle ID? Are the Apple and Google accounts organisation accounts in MFW's name, and what is their enrolment status? | No working position yet |
| OQ-46 | What backup and recovery does MFW expect (recovery point and time, scope, cost)? Does MFW keep master copies of the issue PDFs? S1 and S2 do not mention backup or restore, so these are proposed additions and not S2 deliverables. | No working position yet |
| OQ-51 | Which roles may see the registered-reader list and export it? On the one-role working position every admin can. | Any admin, because there is one Admin role. |
| OQ-53 | What is MFW's monthly cloud cost ceiling, and what volume should the design assume? | No working position yet |
| OQ-54 | Must a download continue while the app is in the background or the screen is locked? | Downloads run in the foreground. If the reader leaves, the download pauses and resumes from the bytes held. No background-download plugin in the first release. |
| OQ-57 | Are the issue PDFs on MFW's website meant to stay publicly downloadable? If so, what is the sign-in requirement in the app meant to achieve? If not, who changes the website, given that the project does not change WordPress (S2 "Scope not included")? | No working position yet |
| OQ-58 | Does MFW treat the in-panel adding and removing of admins by any admin, and the small record of who added or removed whom, as a clarification of the S2 admin panel or as a change request? | Any admin can add or remove admins in the panel, with a small change record. It is built and switched off until MFW answers (the working position of the team, DEC-027). |

The sender checks the table against `OPEN_QUESTIONS.md` before it goes. Each answer is filed there with the sender, the date and the wording that decides (`DECISION_LOG.md` section 3.1).

## 4. Draft 3: the M1 note (MOD20-P2-T03)

S2 milestone M1 needs MFW's written approval of the requirements and architecture note, MFW's named approver and deputy, and the brand assets (`ACCEPTANCE_CRITERIA.md` section 4). The approval so far is reported as a chat message that says "go ahead" and names no note (OQ-59). This draft is the note and the email that asks for an approval that names it. It is written from `REQUIREMENTS_SPECIFICATION.md`, `SYSTEM_ARCHITECTURE.md` and the decisions of `DECISION_LOG.md` as they stand on 14 November 2026. The note is short on purpose, and the sender may attach longer documents (not in this draft).

```text
Subject: MFW app: requirements and architecture note for your approval (M1)

Dear <MFW approver>,

Attached below is the short note that the Statement of Work asks us to
send for milestone M1. Please reply in writing that you approve "the
MFW app requirements and architecture note dated <date>", or tell us
what to change. A reply to this email is enough.

------------------------------------------------------------------
MFW app: requirements and architecture note
------------------------------------------------------------------

1. What readers can do

   - Browse the latest issue and the archive without signing in, and
     search and filter by category, year and edition.
   - Register and sign in with email and password, with a verification
     email. Google Sign-In is planned, and needs your written
     confirmation (Draft 2, C and D).
   - Download an issue to the phone, then read it from the complete
     copy, with or without a network. Reading opens a temporary copy;
     Download keeps one until the reader deletes it.
   - Turn pages by swipe or tap, with a page-turn effect or a plain
     swipe mode, zoom to 300%, and see two pages side by side on tablets
     and in landscape.
   - Keep bookmarks and favourites with the account, on more than one
     device.
   - Read MFW's news from the WordPress site, share issues and articles,
     and choose notification categories.

2. What admins can do (a web panel)

   - Sign in, upload an issue PDF and cover, enter the details, publish
     and unpublish.
   - Manage categories, hide posts or mark them as breaking news, send
     notifications by category, and see and export the list of
     registered readers.

3. How it is built

   - One Flutter app for Android and iOS.
   - Firebase, as the Statement of Work proposes: sign-in, the database,
     file storage, server functions (TypeScript on Node.js), push
     notifications and crash reports. The admin panel is a React web
     app on Firebase Hosting.
   - Issue PDFs are never public in the app: the server checks the
     reader and then gives a short-lived link.
   - News is read from MFW's WordPress site by the app, and the news
     controls are applied from our backend.
   - Three environments: the developers' machines, a test project, and
     the live project.

4. What falls to MFW

   - Firebase file storage and server functions need the pay-as-you-go
     plan in a project in MFW's name. Usage is billed to MFW at actual
     use and is not in the Commercial Proposal.
   - A second, test project would also be in MFW's name and billed to MFW
     (we ask separately).
   - Our planning arithmetic for downloads, which is the main cost, is
     about USD 5 to USD 118 a month for the scenarios in our cost
     document, with the files stored in Mumbai. It is not a quotation,
     and the prices will be checked again before we give you figures.

5. Not decided yet

   - The library that draws the PDF pages. We choose it after the reader
     test on your sample issues, and you approve it at milestone M2.
   - The questions in our product questions email (Draft 2), including
     where data is stored (OQ-41).

------------------------------------------------------------------

Thank you.
<Sender>
```

Checks to make before it goes: the note repeats what the documents say on 14 November 2026. Its statements about the platform and the admin panel are AGREED between the developers and not yet approved by MFW (`DECISION_LOG.md` DEC-003 and DEC-004). The cost figure is from `CLOUD_INFRASTRUCTURE_AND_COSTS.md` section 10.1, read from vendor prices of 25 October 2026.

## 5. What this does not do

- It sends nothing, and it changes no status in any register.
- It does not decide the working positions. Where the register records none, the draft says so.
- It does not replace the pack of 8 November 2026, which is drafted and not sent.
