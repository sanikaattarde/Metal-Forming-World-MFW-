# Dependency Register: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Dependency Register |
| File | `Documentation/DEPENDENCY_REGISTER.md` |
| Phase | 4 — Testing, Release and Risk Management (document 39) |
| Version | 0.15 |
| Status | Draft for review. Not approved. Three packages are installed on `main`, by pull request #30: DEP-43, DEP-44 and DEP-58, with the Flutter and Dart pin (DEP-35, DEP-36). Pull request #63 adds a fourth, DEP-50 (`connectivity_plus` 7.3.2), with its entry in section 8.1. Pull request #66 adds the first backend tools, DEP-79 to DEP-83, in section 8.2. The first CI workflow, `.github/workflows/pr.yml` (pull request #48), uses DEP-61 and DEP-74 to DEP-77. The three typefaces of DEP-78 are bundled in the app by pull request #57, as font files and not a package. YG read their three licence files on 9 November 2026 (in chat, not filed). No version, licence or price below has been verified unless it is quoted from a source document, or is recorded in section 8.1 with the page it was read from. The section 8.1 facts were read on 30 October 2026 by an automated page reader. A developer has read the LICENSE files of DEP-64, DEP-65 and DEP-66 (YG, 1 November 2026; DEP-66 also on 30 October 2026). YG also reports the licence of PDFium and of the pdfx native engines (1 November 2026), and re-read PDFium's LICENSE file on 4 November 2026 after the review of pull request 13: a BSD-3-Clause notice followed by the Apache License 2.0 text. Those reports give licence names only, with no page addresses. On 7 November 2026 an automated reader read the LICENSE files of DEP-35, DEP-43, DEP-44 and DEP-58 at the pinned versions, at YG's request, and YG accepts that reading (in chat, not filed). A developer has not read those four files. |
| Date | 9 November 2026 |
| Approval required | Both developers. MFW for any paid component (RS NFR-MAINT-006). |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial register |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. Planned name replaced by the existing document. Stale status rows corrected. |
| 0.3 | 30 October 2026 | Section 8.1 added: review entries for DEP-43, DEP-44, DEP-58, and for DEP-64 and DEP-65 (the PDF libraries to be compared under DEC-005) and DEP-66 (an HTML parser, one input to DEP-54), read from pub.dev and the LICENSE files. DEP-64 to DEP-66 added to section 8. Five rows of section 8 point to section 8.1. Six rows added to section 10. No package is added and no version is pinned. |
| 0.4 | 1 and 4 November 2026 | YG's LICENSE-file reads of 1 November 2026 recorded for DEP-64, DEP-65 and DEP-66 (all MIT), with YG's reports of the PDFium licence (Apache License 2.0) and of the pdfx native engines. Section 8, section 8.1 and section 10 updated to say so. The prebuilt PDFium binaries that the pdfrx build downloads are recorded as not read. Revised on 4 November 2026 after the review of pull request 13: PDFium's LICENSE file is recorded as a BSD-3-Clause notice followed by the Apache License 2.0 text (YG's re-read of 4 November 2026, matching the review's reading) in DEP-64, DEP-65 and section 10. DEP-43 and DEP-44 point to `DECISION_LOG.md` section 5.5. Section 2 points to the section 8.1 labels. No package is added and no version is pinned. |
| 0.5 | 5 November 2026 | DEP-43 and DEP-44: the Decision rows follow `DECISION_LOG.md` 0.6, which sets DEC-013 and DEC-014 to AGREED (section 5.6) and keeps the conditions listed there. The review of pull request #14 asked for it, because the rows said "Not AGREED" after pull request #13 merged. The status of both entries stays CANDIDATE. The DEP-43 row gives the section 5.6 conditions in full, as the re-review of 5 November 2026 asked. No package is added and no version is pinned. |
| 0.6 | 5 November 2026 | The header of the related-documents table reads "Status", with no date. No requirement, scope item, decision or status label changed. |
| 0.7 | 5 November 2026 | The DEP-60 row records that branch protection on `main` is on. Revised on 5 November 2026 after the review of pull request #21: the DEP-60 row records the visibility as public (GitHub API). No MFW approval is recorded, and no entry is APPROVED. |
| 0.8 | 7 November 2026 | The pin and the packages of pull request #30 are recorded: DEP-35 and DEP-36 give Flutter 3.47.9 and Dart 3.13.7 and the range in `app/pubspec.yaml` (OQ-50, now ANSWERED), and DEP-43, DEP-44 and DEP-58 move from CANDIDATE to CONFIRMED with their locked versions. DEP-37 and DEP-39 record what T-01.1 found. The LICENSE files of DEP-35, DEP-43, DEP-44 and DEP-58 are recorded from an automated reading that YG accepts. New rows come ahead of the CI workflow (T-01.5): DEP-74 (Java 17) and DEP-75 to DEP-77 (the three GitHub actions it uses), all CANDIDATE until the workflow merges. DEP-61 reads CONFIRMED, because DEC-022 chose GitHub Actions (AGREED, conditional on the cost check, which stays open in the Cost column). DEP-62 and DEP-63 are chosen and written after T-01.5, because the first workflow covers QG-01 to QG-06 only. Section 10 records a PROPOSED position on transitive packages for QG-10, and the server-side tools that need rows with the first backend or admin code (finding T-5 of issue 32). No MFW approval is recorded, and no entry is APPROVED. |
| 0.9 | 7 November 2026 | Section 4: DEP-02 is PARTLY RECEIVED (the logo file) and DEP-03 is RECEIVED (three issues). Both are recorded in `inputs/README.md`, which lists each file with its size and SHA-256. The files are kept outside Git (DEC-024), and MFW still confirms where its sample PDFs may be kept. Section 2 adds the statuses RECEIVED and PARTLY RECEIVED, and section 4 says where receipt is recorded. No package is added and no version is pinned, and no entry is APPROVED. |
| 0.10 | 7 November 2026 | The CI workflow `.github/workflows/pr.yml` comes with this version (T-01.5, pull request #48). DEP-75 to DEP-77 move from CANDIDATE to CONFIRMED, DEP-74 records the CI use as CONFIRMED, and DEP-61 names the pull request. The versions, commits and licence readings of those rows do not change. The cost check of DEC-022 stays in the Cost column of DEP-61. No MFW approval is recorded, and no entry is APPROVED. |
| 0.11 | 8 November 2026 | DEP-61 records that the repository owner approved the cost of the first workflow in writing on 8 November 2026 (DEC-022, `DECISION_LOG.md` section 5.9), and its status reads CONFIRMED (DEC-022, AGREED). The plan minutes and the macOS runner cost stay NOT VERIFIED. No other entry changed. |
| 0.12 | 8 November 2026 | MFW's clarifications, reported by YG on 8 November 2026 and not filed, carried as dated updates. DEP-02 moves from PARTLY RECEIVED to RECEIVED: MFW directs the team to the colours and fonts of its website and supplies no values or font files, and YG then reports that the website's colours and fonts are used in the app as they are, so they are received by reference; the values read from the public website are in `BRAND_REFERENCE.md`. Receipt is not approval, and OQ-63 stays OPEN for MFW's written confirmation. DEP-04 moves from NOT RECEIVED to PARTLY RECEIVED: the site address is recorded in `inputs/README.md`, YG reports that the app may use the website's categories (working position in `DEPLOYMENT_PLAN.md` CFG-04), and the API confirmation is not received (OQ-39). DEP-05 stays NOT RECEIVED: MFW says access comes next week, YG reports that the provider, the projects, the roles, the region, a test project and the cost ceiling are not provided yet, and `CLOUD_ACCESS_SETUP_CHECKLIST.md` holds the steps. DEP-19 records the WordPress version the site showed that day. DEP-78 is added as a CANDIDATE: the three typefaces the website uses, with licences not read. Section 10 adds a row. No package is added and no version is pinned, and no entry is APPROVED. |
| 0.13 | 8 November 2026 | DEP-78 moves from CANDIDATE to CONFIRMED: the three licence files were read by the development assistant at YG's request (all SIL Open Font License 1.1), YG approved bundling the upright files, and pull request #57 bundles them in the app with their licences (MOD16-P1-T01, MOD01-P2-T02). The status row names it. A developer has not read the licence files themselves. Revised on 9 November 2026 after the review of pull request #57: YG then read them, and the DEP-78 row records it. No package is added, `pubspec.lock` does not change, and no entry is APPROVED. |
| 0.14 | 9 November 2026 | DEP-50 moves from CANDIDATE to CONFIRMED: `connectivity_plus` is added to `app/pubspec.yaml` at `^7.3.2`, locked at 7.3.2, for the connectivity service of MOD01-P2-T03 (pull request #63). Section 8.1 adds its review entry, with the licence read from the published package on 9 November 2026 (BSD-3-Clause), and lists the nine packages it brings in with their licences. Two of them, `dbus` and `nm`, are under the Mozilla Public License 2.0 and serve the Linux build only. Whether they reach an Android or iOS build is NOT VERIFIED. No paid component is added. |
| 0.15 | 9 November 2026 | Section 8.2 added: the server-side tools of the first backend code, `backend/` (MOD13-P1-T01 to T03, pull request #66): DEP-79 Node.js, DEP-80 Firebase command line tools, DEP-81 the rules test library, DEP-82 the Firebase JavaScript SDK used by the tests, and DEP-83 Java for the emulators. All are development tools, none is shipped in the app, and none has a cost. The open item of section 10 that asked for these rows (finding T-5 of issue 32) is met. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `MFW_Commercial_Proposal-2.pdf` (S1) "Costs outside the fee", "What we need from MFW" | Exists, issued, unsigned. Source of the cost figures below. |
| `MFW_Statement_of_Work.pdf` (S2) "Proposed technical architecture" | Exists, issued, unsigned |
| `DECISION_LOG.md`, `CODING_STANDARDS.md` §12, `CI_CD_AND_QUALITY_GATES.md` QG-10 | Exist (draft) |
| `TECHNOLOGY_DECISIONS.md` | Exists on `main` (draft). It was planned as `TECH_STACK_DECISIONS.md`. |

## 2. Purpose, Scope and Status

This register tracks everything the product and the project depend on:

- Client inputs and documents
- Accounts and platform services
- Backend and admin candidates
- Toolchain and development tools
- Flutter packages
- Repository and CI services

The register separates confirmed dependencies from candidates and open choices, using these statuses. The last three apply only to client inputs (section 4):

| Verification status | Meaning |
|---|---|
| CONFIRMED | Needed according to the source documents or repository evidence. The version or terms may still need verifying. |
| CANDIDATE | Proposed, not chosen, and not installed |
| UNRESOLVED | A choice is needed and no candidate is preferred |
| NOT RECEIVED | A client input with no record of receipt in the repository |
| PARTLY RECEIVED | Part of a client input has a record of receipt in the repository, and the "Required action" column says what is missing |
| RECEIVED | A client input with a record of receipt in the repository. Receipt is not approval, and it does not say that the input is complete or cleared for use. |

**Verification rule.** A version is recorded only once it is pinned in the repository. A licence is recorded only from the dependency's own LICENSE file or official page, read by a developer. A cost is recorded only from a source document, and must still be checked with the provider. Until then, the "Licence and security" and "Cost" columns say what must be verified. Section 8.1 records versions seen and licences shown, and labels each one that way. It pins no version and accepts no licence for use, so it does not conflict with this rule.

## 3. How to Add a Dependency

1. Add an entry here first, in the same pull request as the change to `pubspec.yaml` (or the backend or admin equivalent) (`CODING_STANDARDS.md` §12).
2. Record the purpose, dependent modules, licence (with its source), publisher, platform support, maintenance signals, alternatives considered and any cost.
3. A paid or commercially licensed component needs MFW's written approval before it is added (RS NFR-MAINT-006; S1 Costs outside the fee).
4. QG-10 fails if `pubspec.lock` contains a package with no entry here.

## 4. Client-Provided Inputs and Documents

Owner of each input: MFW. Tracking: Sanika Attarde (MFW contact). The "needed by" timing is from S1, relative to project weeks. CH §12 dates are PROVISIONAL. Receipt of an input is recorded in `inputs/README.md`, which lists each file with its size and SHA-256. MFW's sample PDFs are confidential, so the files themselves are kept outside Git (DEC-024).

| ID | Dependency | Purpose and dependent work | Needed by [S1] | Status | Required action |
|---|---|---|---|---|---|
| DEP-01 | Named approver and deputy; written confirmation of content rights | All approvals; COM-08 | Before kickoff | NOT RECEIVED | Request (OQ-28) |
| DEP-02 | Logo files, brand colours and fonts | WP-02 designs; RS NFR-UX-001 | Kickoff | RECEIVED | The logo file is recorded in `inputs/README.md` (7 November 2026). Request the brand colours and fonts. Update of 8 November 2026: MFW directs the team to use the colours and fonts of its website, with the identity of the issues and the logo it supplied, and gives no values or font files (reported by YG, not filed). YG then reports that the website's colours and fonts are used in the app as they are (not filed). So the colours and fonts are received by reference to the website, and the values read from it are in `BRAND_REFERENCE.md`. Receipt is not approval: OQ-63 stays OPEN until MFW's written confirmation is filed. Font licences: DEP-78. The supplied logo file and the three issues were read the same day for their fonts and colours (`BRAND_REFERENCE.md` section 7). Status before this update: PARTLY RECEIVED. |
| DEP-03 | Two or three sample PDFs, including the largest expected issue | T-02.3 reader test; FX-PDF-03, FX-PDF-04 | End of Week 1 | RECEIVED | Three issues (April-May, August-September and October-November 2026) are recorded in `inputs/README.md` (7 November 2026). Agree storage with MFW (DEC-024). Ask whether the largest expected issue is among them (FX-PDF-04). |
| DEP-04 | WordPress site address, API confirmation, news categories | WP-08; CFG-03, CFG-04 | End of Week 1 | PARTLY RECEIVED | Request (OQ-39). Update of 8 November 2026: the site address, https://metalformingworld.com, is recorded in `inputs/README.md` as the website MFW shared (reported by YG, not filed). The API confirmation and the categories are not received. A public read-only check of that day is in `test-evidence/WORDPRESS_PUBLIC_SITE_EVIDENCE.md`, and it is not MFW's confirmation. YG then reports (not filed) that the app may use the categories of the website, and that the team has creative freedom; the working position is in `DEPLOYMENT_PLAN.md` CFG-04. The API confirmation is still not received, so the status is PARTLY RECEIVED. Status before this update: NOT RECEIVED. |
| DEP-05 | Cloud project in MFW's name with billing switched on (S1 names Firebase and Google Cloud) | WP-01; every backend task | End of Week 1 | NOT RECEIVED | Request after DEC-003 and DEC-023. Update of 8 November 2026: MFW says cloud access will be provided next week (reported by YG, not filed), without naming the provider or the projects. YG reports the same day that the provider, the project identifiers, the roles, the region, a test project and a cost ceiling are not provided yet. The status stays NOT RECEIVED until access is granted. No project is created in a personal account or another project before then. The steps for that day are in `CLOUD_ACCESS_SETUP_CHECKLIST.md`. |
| DEP-06 | Apple Developer Program organisation account | T-10.1; WP-12 | Active by the end of Week 4 | NOT RECEIVED | MFW starts enrolment in Week 1 |
| DEP-07 | Google Play Console account in MFW's name | WP-12 | Active by the end of Week 4 | NOT RECEIVED | Request |
| DEP-08 | Privacy policy and terms of use at public addresses | RS FR-PRIV-001, FR-PRIV-002; COM-02 | End of Week 4 | NOT RECEIVED | Request |
| DEP-09 | Launch content: the latest issue and four to six archive issues, with details | RS FR-MAG-004; AC-1.1 | End of Week 4 | NOT RECEIVED | MFW enters production content (S2) |
| DEP-10 | Admin user list | RS FR-USER-005; CFG-14 | Weeks 5 and 6 | NOT RECEIVED | Request (OQ-20) |
| DEP-11 | Store listing text | AC-11.2 | Weeks 5 and 6 | NOT RECEIVED | Request |
| DEP-12 | Testers from MFW's team | Acceptance testing (TS-12) | Acceptance-testing start | NOT RECEIVED | Request |
| DEP-13 | Signed or formally accepted S1 and S2 | Contractual baseline | — | Unsigned copies only | Request (OQ-28) |
| DEP-14 | S3 client emails, or MFW's written confirmation of the amendments | Every PROVISIONAL item | — | Not in the repository | Request (OQ-29) |

## 5. Accounts and Platform Services

| ID | Name | Category | Purpose and dependent modules | Version | Owner | Licence and security | Cost | Status | Required action |
|---|---|---|---|---|---|---|---|---|---|
| DEP-15 | Apple Developer Program (organisation) | Store account | iOS distribution; push credential (MOD-11) | — | MFW | Role-based access for developers (RS NFR-SEC-012) | USD 99 per year [S1]. Verify the current price. | CONFIRMED | DEP-06 |
| DEP-16 | Google Play Console | Store account | Android distribution | — | MFW | Role-based access | USD 25, one time [S1]. Verify the current price. | CONFIRMED | DEP-07 |
| DEP-17 | Apple push notification service | Push delivery | iOS notifications (RS INT-PUSH-001, INT-PUSH-002) | — | MFW's Apple account | Credential held in MFW's account | Included in the program (verify) | CONFIRMED | Set up in T-10.1 |
| DEP-18 | Google Sign-In (Google identity services) | Authentication provider | MOD-03 (RS FR-AUTH-005) | — | MFW's Google account | OAuth consent screen and client configuration (CFG-09) | Verify | CANDIDATE: in scope as a PROVISIONAL requirement (C-04) | OQ-29; set up in T-03.2 |
| DEP-19 | WordPress REST API on MFW's site | External API | MOD-09 (RS INT-WP-001) | WordPress version unknown. On 8 November 2026 the public site named WordPress 7.1.4 (`test-evidence/WORDPRESS_PUBLIC_SITE_EVIDENCE.md`). It can change at any time and is not pinned | MFW and its host | Read-only and public. No credentials. | None to the project | CONFIRMED | OQ-39 |
| DEP-20 | MFW's WordPress hosting | External service | Availability of news (R5) | — | MFW and its host | Outside the project's control | MFW's existing hosting | CONFIRMED | — |
| DEP-21 | Custom domain for the admin panel | Optional service | MOD-12 address (CFG-12) | — | MFW | — | At the registrar's price [S1] | CANDIDATE (optional) | MFW decides |

## 6. Backend and Admin Candidates

All are from the S2 proposal unless noted. None is approved (DEC-003, DEC-004).

| ID | Name | Category | Purpose and dependent modules | Owner | Licence and security | Cost | Status | Required action |
|---|---|---|---|---|---|---|---|---|
| DEP-22 | Firebase Authentication | Authentication | MOD-03, MOD-13 | MFW account | Provider terms; verify | Verify the pricing model | CANDIDATE | DEC-003 |
| DEP-23 | Cloud Firestore | Database | MOD-04, MOD-05, MOD-08, MOD-11, MOD-12, MOD-13 | MFW account | Security rules required (DEC-009) | Usage-based; verify | CANDIDATE | DEC-003 |
| DEP-24 | Cloud Storage for Firebase | File storage | MOD-06, MOD-12, MOD-13 | MFW account | Private access; no long-lived bearer links for PDFs (DEC-009) | Usage-based; S2 says it needs the pay-as-you-go plan | CANDIDATE | DEC-003, DEC-020 |
| DEP-25 | Cloud Functions | Server logic | MOD-11, MOD-12, MOD-13 | MFW account | Secrets in the provider's secret store | Usage-based; S2 says it needs the pay-as-you-go plan | CANDIDATE | DEC-003 |
| DEP-26 | Firebase Cloud Messaging | Push dispatch | MOD-11 | MFW account | No personal data in payloads | Verify | CANDIDATE | DEC-003 |
| DEP-27 | Firebase Hosting | Admin hosting | MOD-12 | MFW account | — | Verify | CANDIDATE | DEC-004 |
| DEP-28 | Firebase Crashlytics | Crash reporting | MOD-02 (RS NFR-OBS-001) | MFW account | No personal data (`CODING_STANDARDS.md` §6.2); store privacy declarations | Verify | CANDIDATE | DEC-003 |
| DEP-29 | Google Analytics for Firebase | Usage events | MOD-02 (RS NFR-OBS-002) | MFW account | Approved event list only (OQ-23); declarations | Verify | CANDIDATE | DEC-003, OQ-23 |
| DEP-30 | AWS-based design | Alternative backend | All backend modules | — | — | — | Considered in S2 and not preferred there | Recorded for completeness |
| DEP-31 | React (`react`, `react-dom`) | Admin user interface | MOD-12 | Development team | MIT (package.json, read 10 November 2026) | None (open source) | CONFIRMED: 19.3.1, exact pin, in `admin/` (DEC-004 AGREED, section 8.4) | None |
| DEP-32 | Flutter web | Admin user interface (alternative) | MOD-12 | Development team | As DEP-35 | None expected; verify | CANDIDATE, not assessed (not in S2) | DEC-004 |

## 7. Toolchain and Development Tools

| ID | Name | Category | Purpose | Version | Owner | Licence and security | Cost | Status | Required action |
|---|---|---|---|---|---|---|---|---|---|
| DEP-35 | Flutter SDK | Framework | All app modules (DEC-002) | 3.47.9 (tag `3.47.9`, revision `c197ca5`). Pinned as `flutter: ">=3.47.9 <3.48.0"` in `app/pubspec.yaml` by pull request #30 (OQ-50, ANSWERED) | Both developers | The LICENSE file at the tag is a BSD-3-Clause licence with the line "Copyright 2014 The Flutter Authors. All rights reserved." (automated reading of 7 November 2026, accepted by YG) | None expected | CONFIRMED | A version outside the range needs a change to `app/pubspec.yaml` (OQ-50) |
| DEP-36 | Dart SDK | Language | Bundled with Flutter | 3.13.7, the Dart of DEP-35. `sdk: ^3.13.7` in `app/pubspec.yaml` (pull request #30) | Both | As DEP-35 | None expected | CONFIRMED | None |
| DEP-37 | Android SDK and build tools | Build tooling | Android builds (QG-05) | Recorded at T-01.1 from `main` at `5a77910`: Android Gradle Plugin 9.1.0, Kotlin Gradle plugin 2.4.0, Gradle 9.3.1 (the wrapper), Java 17 source and target (DEP-74). The compile, minimum and target SDK levels and the NDK version are Flutter's defaults, not the answer to OQ-26. Built on YG's Mac on 7 November 2026 with SDK platform 36 and build-tools 36.0.0, and run on an Android 16 (API 36) emulator | Both | Vendor terms | None expected | CONFIRMED | Set the SDK levels once OQ-26 is answered |
| DEP-38 | Xcode on macOS | Build tooling | iOS builds (QG-06, QG-13). iOS builds need macOS. | The version Apple requires at submission (verify) | Both | Apple terms | Needs a Mac (developer-owned) | CONFIRMED | Confirm each developer's Mac access |
| DEP-39 | iOS plugin dependency tooling (CocoaPods and/or Swift Package Manager, as the pinned Flutter version uses) | Build tooling | iOS plugin integration | Found at T-01.1 (7 November 2026): the pinned Flutter has Swift Package Manager on by default (`flutter doctor` lists it as on, and `flutter config` sets no override). The scaffold's iOS project refers to the Swift package Flutter generates, and no `Podfile` exists, because no plugin with native iOS code is in use yet. CocoaPods 1.17.0 is installed on YG's Mac, for a plugin that has no Swift package (NOT VERIFIED until such a plugin is added) | Both | Verify | None expected | CONFIRMED (need); tool: Swift Package Manager | Check again with the first plugin that has native iOS code |
| DEP-40 | Git | Version control | Repository | — | Both | — | None | CONFIRMED | — |
| DEP-41 | Claude Code | Development assistant | Both developers' sessions (`CLAUDE_CODE_WORKING_RULES.md`) | — | Each developer | Each developer's own terms. No production secrets or personal data shared with sessions. | Each developer's own account | CONFIRMED (in use) | — |
| DEP-42 | Network fault-injection proxy (for example toxiproxy or mitmproxy) | Test tooling | FX-NET-07 | — | WS-B | Verify the licence before use | Verify | CANDIDATE | Choose in WP-06 |
| DEP-74 | Java Development Kit 17 | Build tooling | Gradle for the Android builds (QG-05), on the developers' Macs and in CI | 17. The scaffold sets Java 17 source and target (DEP-37). In CI, Eclipse Temurin 17 through DEP-77. On YG's Mac, Homebrew OpenJDK 17 | Both | The LICENSE file of the local OpenJDK 17 is the GNU General Public License version 2 with the Classpath Exception (automated reading of 7 November 2026, to confirm). Not shipped in the app | None | CONFIRMED (Android builds need it, and `.github/workflows/pr.yml` uses it for QG-05) | None |

## 8. Flutter Package Candidates

Three are added, by pull request #30 (the scaffold, T-01.1): DEP-43, DEP-44 and DEP-58. Each of the others needs the review in Section 3 before it is added.

Section 8.1 holds review entries for the candidates the WS-B scaffold needs, and for the two PDF libraries to be compared under DEC-005. What it records is what the pages showed on 30 October 2026. It is not a pin and not an approval.

| ID | Candidate | Purpose and dependent modules | Decision | Licence and security to verify | Cost | Status |
|---|---|---|---|---|---|---|
| DEP-43 | Riverpod | State management (all app modules) | DEC-013 | LICENSE file; maintenance. Read on 30 October 2026, and at the pinned version on 7 November 2026: section 8.1 | None expected | CONFIRMED (3.4.3 locked, pull request #30) |
| DEP-44 | go_router | Navigation and guards (MOD-01) | DEC-014 | LICENSE file. Read on 30 October 2026, and at the pinned version on 7 November 2026: section 8.1 | None expected | CONFIRMED (18.1.2 locked, pull request #30) |
| DEP-45 | PDF rendering library | MOD-07 | DEC-005, OQ-36 | **Licence is critical.** Some PDF viewer packages are distributed under commercial licences, which would need MFW's written approval. Check platform support, rendering quality at 300% zoom, and memory use with large files. Candidates for the comparison: DEP-64 and DEP-65 (section 8.1). Neither is chosen. | Possibly paid; verify | UNRESOLVED |
| DEP-46 | google_sign_in plugin | MOD-03 | DEC-006 | LICENSE file; platform set-up | None expected | CANDIDATE |
| DEP-47 | Backend provider plugins: the FlutterFire packages (DEC-003 AGREED) | MOD-03 to MOD-13 data layers | DEC-003 | Section 8.5 | None | CONFIRMED: four packages in `app/pubspec.yaml` from 10 November 2026, section 8.5 |
| DEP-48 | Secure storage plugin (for example flutter_secure_storage) | Tokens (`CODING_STANDARDS.md` §8.1) | — | LICENSE file; Keychain and Keystore behaviour | None expected | CANDIDATE |
| DEP-49 | App directories (path_provider) | Private storage paths (MOD-06) | — | LICENSE file | None expected | NOT NEEDED for MOD06-P2-T02 (10 November 2026): the app's `mfw/storage` platform channel gives the issue folder, Android's no-backup storage and iOS Application Support excluded from backups, which path_provider does not offer |
| DEP-50 | Connectivity type: connectivity_plus | Mobile-data warning (MOD-01; RS FR-DL-004) | None | Read on 9 November 2026: section 8.1. Update of 9 November 2026: YG read this licence (reported in chat, not filed). Accuracy on both platforms is checked on a device | None expected | CONFIRMED (7.3.2 locked, pull request #63) |
| DEP-51 | Resumable download client (an HTTP client with range requests, or a platform background-download plugin) | MOD-06 (RS FR-DL-006) | DEC-020; WP-02 spike | LICENSE file; background behaviour | None expected | RESOLVED (10 November 2026): no package; `dart:io`'s HttpClient with `Range` requests (`HttpFileTransport`, MOD06-P2-T02) |
| DEP-52 | Share sheet (for example share_plus) | MOD-10 | — | LICENSE file | None expected | CANDIDATE |
| DEP-53 | Link opening (url_launcher) | Policy links and article links (MOD-04, MOD-09) | — | LICENSE file | None expected | CANDIDATE |
| DEP-54 | HTML rendering for WordPress content | MOD-09 (`CODING_STANDARDS.md` §7) | — | LICENSE file; **must not run scripts** (SEC-CHK-15). The parser DEP-66 is recorded in section 8.1 as one input; the rendering route stays open. | None expected | UNRESOLVED |
| DEP-55 | Local cache storage for news and metadata | MOD-05, MOD-09 (RS FR-NEWS-005) | OQ-10, OQ-16 | LICENSE file | None expected | UNRESOLVED |
| DEP-56 | JSON code generation (json_serializable, freezed) | Serialization (`CODING_STANDARDS.md` §7) | — | LICENSE files | None expected | CANDIDATE (optional) |
| DEP-57 | Mocking library (for example mocktail) | Tests (`CODING_STANDARDS.md` §10) | — | LICENSE file | None expected | CANDIDATE (optional) |
| DEP-58 | flutter_lints | Static analysis (`CODING_STANDARDS.md` §4) | None | LICENSE file. Read on 30 October 2026, and at the pinned version on 7 November 2026: section 8.1 | None expected | CONFIRMED (6.0.0 locked, development only, pull request #30) |
| DEP-59 | flutter_test and integration_test | Tests (TS-02 to TS-04) | — | Part of the Flutter SDK | None | CONFIRMED (SDK) |
| DEP-101 | crypto (`package:crypto`, the Dart team) | SHA-256 of a downloaded issue file against the grant's `checksum_sha256` (MOD-06; RS FR-STATE-006) | None | LICENSE file of 3.0.8, read in the package cache on 10 November 2026: BSD-3-Clause ("Copyright 2015, the Dart project authors"), to confirm by a developer. Already in the lockfile at 3.0.8 as a transitive dependency, so nothing new is downloaded | None | CONFIRMED (3.0.8 locked, MOD06-P2-T02) |
| DEP-64 | pdfrx | PDF rendering library, for the comparison test (MOD-07, T-02.3) | DEC-005, OQ-36 | LICENSE file, read by YG on 1 November 2026: MIT. PDFium, the engine it bundles: a BSD-3-Clause notice and the Apache License 2.0 text, YG's re-read of 4 November 2026. Section 8.1 | None expected; verify | In `app/pubspec.yaml` from 10 November 2026 at `^2.11.0`, locked at 2.11.0, behind `PdfRenderer` in `app/lib/features/reader/` only (MOD07-P2-T01). It brings in `pdfrx_engine` 0.9.0, `pdfium_dart` and `pdfium_flutter` 0.4.1, `path_provider` 2.1.6 and the packages they need, all now in `pubspec.lock`. PROPOSED with DEC-005, which stays OPEN |
| DEP-65 | pdfx | PDF rendering library, for the comparison test (MOD-07, T-02.3) | DEC-005, OQ-36 | LICENSE file, read by YG on 1 November 2026: MIT. Native engines, YG's reports of 1 and 4 November 2026: PDFium (Windows) a BSD-3-Clause notice and the Apache License 2.0 text, PDF.js (web) Apache License 2.0; Android and iOS use the platform's own engines. Section 8.1 | None expected; verify | CANDIDATE (comparison only) |
| DEP-66 | html (HTML parser) | Parses WordPress post content, one input to DEP-54 (MOD-09) | DEP-54 | LICENSE file, read by YG on 30 October 2026 and again on 1 November 2026: MIT License (YG's identification from the terms; the file does not name it). pub.dev reports the licence as unknown. Section 8.1 | None expected; verify | CANDIDATE |
| DEP-78 | The typefaces of MFW's website: Fraunces, Inter and Plus Jakarta Sans (font files, not a package) | The app theme (MOD01-P2-T02) and the design tokens (MOD16-P1-T01); the admin panel | DEP-02, OQ-63 | Each family's own licence file, read by a developer before any font file is added. Not read. The website loads them from Google Fonts (`BRAND_REFERENCE.md` section 5, 8 November 2026). Whether the app bundles the files or loads them in another way is open. Update of 8 November 2026: the three licence files (`OFL.txt` in each family's folder of the Google Fonts repository at commit `86aced91de05cd4f96a06838124cca45be337b2b`) were read by the development assistant (DEP-41) at YG's request. Each is the SIL Open Font License 1.1, which allows bundling with software if each copy carries the copyright notice and the licence. YG then approved bundling the upright files (in chat, not filed). A developer has not read the files themselves. Update of 9 November 2026: YG read the three licence files as bundled in the app (`app/assets/fonts/fraunces/OFL.txt`, `app/assets/fonts/inter/OFL.txt` and `app/assets/fonts/plus_jakarta_sans/OFL.txt`), as this row's verification rule asks (reported in chat, not filed). The app bundles the upright variable font of each family with its licence file, and shows the licences on its licence page (pull request #57); file sizes and SHA-256 values are in `DESIGN_TOKENS.md` section 8. Italics are not bundled. The admin panel's use is open (DEC-004). Status before this update: CANDIDATE | None. The licence is free of charge | CONFIRMED (bundled in the app by pull request #57) |

### 8.1 Review Entries (facts read on 30 October 2026)

**How these entries were made.** On 30 October 2026 an automated page reader opened the pub.dev pages and the LICENSE files named in each entry and reported what they showed. A developer has read the LICENSE files of DEP-64, DEP-65 and DEP-66 (YG: DEP-66 on 30 October 2026, and all three on 1 November 2026). Every other licence row says "to confirm". YG's reads of 1 November 2026, and the re-read of PDFium's LICENSE file on 4 November 2026, are reports in chat: YG gave licence names and no page addresses, so the titles and copyright lines recorded for DEP-64 and DEP-65 are still the automated reader's. "Seen" means shown on a page that day. Nothing here was pinned, approved or installed on 30 October 2026. Pull request #30 later installed and pinned DEP-43, DEP-44 and DEP-58, and their Status, Version and Licence rows say so. For those three, the LICENSE files at the pinned versions were read on 7 November 2026 by an automated reader at YG's request, from the published packages that `flutter pub get` downloaded, and YG accepts that reading (in chat, not filed). A date marked "derived" is worked out from an age label such as "56 days ago", because the page gave no calendar date. The reader's reports are not filed in the repository.

**Toolchain seen.** Flutter 3.47.9 and Dart 3.13.7 on YG's machine on 30 October 2026 (`flutter doctor -v`). This is an observation, not a pin (DEP-35, OQ-50). Every minimum SDK version in the entries below is met by it. The same versions were pinned later by pull request #30 (DEP-35, DEP-36).

**Before a package goes into a `pubspec.yaml`:**

1. A developer opens the LICENSE file named in the entry and records the licence name and the date in the entry.
2. The version is pinned in the same pull request as the pubspec change and recorded in the entry (section 2, verification rule; section 3, step 1).
3. The decision behind the package is agreed in writing by both developers (DEC-013, DEC-014, DEC-005), or the use stays on a spike branch (`DEFINITION_OF_DONE.md` section 5, check 2).

For DEP-43, DEP-44 and DEP-58, step 1 was not done before pull request #30 added them. The reading of 7 November 2026 above stands in for it, and section 10 records that gap.

#### DEP-43 flutter_riverpod

| Field | Detail |
|---|---|
| Purpose and modules | State management and the injection of fakes, for all app modules |
| Decision | DEC-013 (AGREED, recorded 4 November 2026, evidence in `DECISION_LOG.md` section 5.6). Both developers' written positions are filed: Sanika Attarde's in section 5.4 and Yuvraj's in section 5.5. Conditions still open (section 5.6): Riverpod is used in `app/lib/app/` only, feature code takes its dependencies through constructors, the Flutter and Dart versions are pinned at the scaffold (OQ-50), and this entry comes before the package. No MFW approval is recorded. Pull request #30 met the last two: the pin is in `app/pubspec.yaml`, and this entry was on `main` before the package. The first two apply to every later change. |
| Status | CONFIRMED. In `app/pubspec.yaml` since pull request #30 (merged as `250190a`). |
| Version | Pinned: `^3.4.3` in `app/pubspec.yaml`, locked at 3.4.3 in `app/pubspec.lock` (pull request #30). On 30 October 2026 the latest stable seen was 3.4.3, published "56 days ago" (4 September 2026, derived). Needs Dart 3.12 or later. |
| Licence and source | pub.dev shows MIT. The LICENSE file read at `https://raw.githubusercontent.com/rrousselGit/riverpod/master/LICENSE` has the title "MIT License" and the line "Copyright (c) 2020 Remi Rousselet". The pub.dev licence page shows the same two lines. At the pinned version, the LICENSE file of the published 3.4.3 package has the same title and line (automated reading of 7 November 2026, accepted by YG). Read by a developer: no. |
| Publisher | dash-overflow.net (verified publisher on pub.dev) |
| Platform support | Android, iOS, Linux, macOS, Windows. Web is not listed. Android and iOS are the project's targets. |
| Maintenance signals | 130 versions in all. 9 stable versions are under 12 months old by their age labels. The repository shows 156 open issues and 16 open pull requests. Pub points 140, 2.92k likes, 4.15M downloads. No discontinued or replaced notice on the pages read. |
| Direct dependencies seen | `collection`, `meta`, `riverpod` (3.4.3), `state_notifier`. `flutter` and `flutter_test` come from the SDK. |
| Alternatives considered | Bloc or Cubit; Provider with ChangeNotifier (DEC-013). Not assessed further. |
| Cost | None expected (MIT shown). No source document states a cost. |

#### DEP-44 go_router

| Field | Detail |
|---|---|
| Purpose and modules | Navigation and route guards (MOD-01) |
| Decision | DEC-014 (AGREED, recorded 4 November 2026, evidence in `DECISION_LOG.md` section 5.6), on the same filing position as DEC-013. Conditions still open (section 5.6): the route guard steers screens only and the server enforces access (DEC-009), the versions are pinned at the scaffold, and this entry comes before the package. No MFW approval is recorded. Pull request #30 met the last two: the pin is in `app/pubspec.yaml`, and this entry was on `main` before the package. The first applies to every later change. |
| Status | CONFIRMED. In `app/pubspec.yaml` since pull request #30 (merged as `250190a`). |
| Version | Pinned: `^18.1.2` in `app/pubspec.yaml`, locked at 18.1.2 in `app/pubspec.lock` (pull request #30). On 30 October 2026 the latest stable seen was 18.1.2, published "16 hours ago", so within a day of the reading (the page gives no calendar date). Needs Dart 3.12 or later. The page links a migration guide for the breaking changes in 18.0.0. |
| Licence and source | pub.dev shows BSD-3-Clause. The file read is the repository root LICENSE, `https://raw.githubusercontent.com/flutter/packages/main/LICENSE`, not a file inside the package folder. It has no title line. Its first line is "Copyright 2013 The Flutter Authors", and the pub.dev licence page shows the same first line. At the pinned version, the LICENSE file of the published 18.1.2 package is a BSD-3-Clause licence with the first line "Copyright 2013 The Flutter Authors" and no title line (automated reading of 7 November 2026, accepted by YG). Read by a developer: no. |
| Publisher | flutter.dev (verified publisher on pub.dev) |
| Platform support | Android, iOS, Linux, macOS, web, Windows |
| Maintenance signals | 257 versions in all. 16 stable versions are under 12 months old by their age labels. Retracted versions: five of the 15.2 line and 4.2.1. Pub points 150, 5.8k likes, 5.27M downloads. The page shows the Flutter Favorite mark and states that the package is considered feature-complete, with no active feature development planned. Issues are tracked in the main flutter repository, and no count is shown. No discontinued or replaced notice. |
| Direct dependencies seen | `collection`, `cupertino_ui`, `logging`, `material_ui`, `meta`. `flutter` and `flutter_web_plugins` come from the SDK. |
| Alternatives considered | The Navigator 2.0 API used directly; auto_route (DEC-014). Not assessed further. |
| Cost | None expected (BSD-3-Clause shown). No source document states a cost. |

#### DEP-58 flutter_lints

| Field | Detail |
|---|---|
| Purpose and modules | The static analysis rule set (`CODING_STANDARDS.md` section 4). Proposed as a development-only dependency, not shipped in the app. |
| Decision | None. The analysis rules in `CODING_STANDARDS.md` are PROPOSED. Sanika Attarde's review of pull request #30 checked the lint rules, and that pull request is approved. |
| Status | CONFIRMED. A development dependency in `app/pubspec.yaml` since pull request #30 (merged as `250190a`). Not shipped in the app. |
| Version | Pinned: `^6.0.0` in `app/pubspec.yaml`, locked at 6.0.0 in `app/pubspec.lock` (pull request #30). On 30 October 2026 the latest stable seen was 6.0.0, published 27 May 2025 (from the package's version feed). Needs Dart 3.8 or later. |
| Licence and source | pub.dev shows BSD-3-Clause. The LICENSE file read at `https://github.com/flutter/packages/blob/main/packages/flutter_lints/LICENSE` has no title line. Its first line is "Copyright 2013 The Flutter Authors". The pub.dev licence page shows the same line followed by "All rights reserved." At the pinned version, the LICENSE file of the published 6.0.0 package is a BSD-3-Clause licence with the first line "Copyright 2013 The Flutter Authors. All rights reserved." and no title line (automated reading of 7 November 2026, accepted by YG). Read by a developer: no. |
| Publisher | flutter.dev (verified publisher on pub.dev) |
| Platform support | All six platforms listed on pub.dev. It is an analysis rule set. |
| Maintenance signals | 17 stable versions. The latest release is 17 months before the reading, so no release in the last 12 months (derived). Pub points 160 of 160, 1.34k likes, 10.7M downloads. Issues are tracked in the main flutter repository, and no count is shown. No discontinued or replaced notice. |
| Direct dependencies seen | `lints` ^6.0.0. The latest `lints` seen is 6.1.0, "published 9 months ago", publisher dart.dev, BSD-3-Clause on its pub.dev page. Its LICENSE file was not read. |
| Alternatives considered | Not recorded in the repository. |
| Cost | None expected (BSD-3-Clause shown). No source document states a cost. |

#### DEP-66 html (HTML parser)

| Field | Detail |
|---|---|
| Purpose and modules | Parses the HTML of WordPress posts into a tree, so the app can show post content without running scripts (MOD-09; `CODING_STANDARDS.md` section 7; SEC-CHK-15). It is one input to DEP-54, which stays UNRESOLVED. |
| What it is | Its README calls it "an HTML5 parser". It describes no rendering and does not say that the package sanitises HTML. The app would need its own mapping from the tree to widgets, or a renderer package (DEP-54). |
| Decision | None. DEP-54 is UNRESOLVED. |
| Status | CANDIDATE. The licence is read (MIT License). The dependency decision stays open: DEP-54 is UNRESOLVED. |
| Version | Not pinned. Latest stable seen: 0.15.7, published 28 August 2026 (from the package's version feed). Needs Dart 3.6 or later. The repository's main branch is already at 0.15.8-wip. |
| Licence and source | MIT License, read from the LICENSE file by YG on 30 October 2026 at `https://github.com/dart-lang/tools/blob/main/pkgs/html/LICENSE`. Copyright line in that file: "Copyright (c) 2006-2013 James Graham and other contributors". The file has no title line and does not name the licence. MIT License is YG's identification of its terms (permission grant, notice condition and warranty disclaimer). pub.dev shows the licence as "unknown", and its score page says no licence was recognised (0 of 10 for the OSI-approved check). **Attribution discrepancy:** the pub.dev licence page, `https://pub.dev/packages/html/license`, shows "Copyright (c) 2006-2012 The Authors" and a list of contributors. YG compared the two pages and found the permission conditions and the warranty disclaimer materially consistent. The discrepancy is recorded for traceability and is not resolved. Read by a developer: yes (YG, 30 October 2026). YG read the file again on 1 November 2026 and reports MIT License; the discrepancy above is not resolved. Acceptability: YG assesses the terms as acceptable for the MFW application, including commercial use, provided the applicable copyright and permission notices are preserved. This is not approved: both developers' agreement is required (section 1). |
| Publisher | tools.dart.dev (verified publisher on pub.dev) |
| Platform support | Android, iOS, Linux, macOS, web, Windows |
| Maintenance signals | 33 stable versions. One release in the last 12 months (0.15.7, 28 August 2026). The one before it, 0.15.6, is dated 24 April 2025 (derived from the version feed). Pub points 150 of 160, and the missing 10 are the licence check. 661 likes, 13M downloads. The open-issue count shown is for the whole dart-lang/tools repository (578), not for this package. The 0.15.7 changelog lists a fix for an XSS vulnerability in `htmlToCodeMarkup()`. Check whether the app would call that function (SEC-CHK-15). No discontinued or replaced notice. |
| Direct dependencies seen | `csslib` ^1.0.0, `source_span` ^1.8.0 |
| Alternatives considered | Not assessed: an HTML renderer package (DEP-54), or showing post bodies as plain text with the gap recorded. |
| Cost | None expected (MIT License per YG's reading). No source document states a cost. |

#### DEP-50 connectivity_plus

| Field | Detail |
|---|---|
| Purpose and modules | The connection type for the mobile-data warning before a download (MOD-01, `ConnectivityService`; RS FR-DL-004), used by MOD06-P2-T01 |
| Decision | No decision entry: a MOD-01 implementation choice under `API_AND_MODULE_CONTRACTS.md` section 6.1. Both developers agree it through the review of pull request #63. |
| Status | CONFIRMED. In `app/pubspec.yaml` from pull request #63. |
| Version | Pinned: `^7.3.2` in `app/pubspec.yaml`, locked at 7.3.2 in `app/pubspec.lock`. The pub.dev API showed 7.3.2 as the latest version, published on 1 October 2026, on 9 November 2026. Needs Dart 3.2 and Flutter 3.7 or later. |
| Licence and source | BSD-3-Clause. The LICENSE file of the published 7.3.2 package, read from the local package cache on 9 November 2026, starts "Copyright 2017 The Chromium Authors" and has the three BSD conditions. pub.dev tags it `license:bsd-3-clause`. Read in Sanika Attarde's session by an automated reader. Read by a developer: no. |
| Publisher | fluttercommunity.dev (pub.dev API, 9 November 2026) |
| Platform support | Android, iOS, Linux, macOS, web, Windows. Android adds the permission `ACCESS_NETWORK_STATE` through the plugin's manifest, a normal permission granted at install. iOS: the package ships a privacy manifest (`PrivacyInfo.xcprivacy`) and supports Swift Package Manager. |
| Maintenance signals | 73 versions in all. pub.dev score on 9 November 2026: 160 of 160 points, 4,104 likes, 4,513,463 downloads in 30 days, the Flutter Favorite tag. |
| Packages it brings in | Nine, from pub.dev, with the licence of each LICENSE file read from the package cache on 9 November 2026: `connectivity_plus_platform_interface` 2.1.0, `plugin_platform_interface` 2.1.8, `args` 2.7.0, `ffi` 2.2.0 and `web` 1.1.2 (BSD-3-Clause); `petitparser` 7.0.2 and `xml` 7.0.1 (MIT); `dbus` 0.8.0 and `nm` 0.6.0 (Mozilla Public License 2.0). `dbus` and `nm` serve the Linux build, which the project does not ship. Whether any of their code reaches an Android or iOS build is NOT VERIFIED. The Mozilla Public License applies file by file and allows use in an app whose own code is under another licence, if the files are not changed and their source stays available. Under the position on QG-10 (section 10) these are listed here and not given entries. |
| Alternatives considered | A platform channel of our own on each platform (more code to maintain); no connectivity check, with the warning on every download (worse for readers on Wi-Fi). |
| Cost | None (BSD-3-Clause). No source document states a cost. |

#### DEP-64 pdfrx

| Field | Detail |
|---|---|
| Purpose and modules | A PDF rendering library to compare with DEP-65 for MOD-07 (T-02.3). Proposed use: only in a spike package on a `spike/` branch until DEC-005 moves. Not in `app/pubspec.yaml` before then. |
| Decision | DEC-005 (OPEN), OQ-36. No library is chosen. |
| Status | CANDIDATE (comparison only). The licences are read (YG's report). The dependency decision stays open: DEC-005 is OPEN. |
| Version | Not pinned. Latest stable seen: 2.11.0, published 29 October 2026 (from the package's version feed). The feed shows 8 releases between 19 and 29 October 2026 (derived). Needs Dart 3.13 or later. The README names Flutter 3.47, and iOS 15 or later and macOS 12 or later for Apple targets. The toolchain seen meets this. |
| Licence and source | pub.dev shows MIT. The LICENSE file read at `https://raw.githubusercontent.com/espresso3389/pdfrx/master/LICENSE` has the title "The MIT License (MIT)" and the line "Copyright (c) 2018 @espresso3389 (Takashi Kawasaki)". The pub.dev licence page shows the same. Read by a developer: yes (YG, 1 November 2026): MIT. YG reported the licence name, so the title and copyright line above are still from the automated reader. **PDFium, the native engine it builds on:** YG read the licence in PDFium's own repository on 1 November 2026 and reported Apache License 2.0. The review of pull request 13 (Sanika, 3 November 2026) says PDFium's LICENSE file opens with a BSD-3-Clause notice and then carries the Apache License 2.0 text, says both notices have to be kept, and names `pdfium.googlesource.com` (main branch) as the file's location. YG re-read the file on 4 November 2026 and reports both: a BSD-3-Clause notice and the Apache License 2.0 text. YG gave no page address, version or copyright line. The MIT statement in the pdfrx repository covers the project, not PDFium. No reading of the prebuilt PDFium binaries that the pdfrx build downloads is recorded. |
| Publisher | espresso3389.jp (verified publisher on pub.dev) |
| Platform support | Android, iOS, Linux, macOS, web, Windows |
| Native code | Built on PDFium. The README says Android, Linux and Windows bundle PDFium through Dart native assets, and iOS and macOS link a PDFium XCFramework through CocoaPods or Swift Package Manager. The repository README says one component downloads PDFium and bundles it at build time. Native builds also need a C toolchain. A download at build time affects CI and offline builds, and is to be assessed. |
| Maintenance signals | 287 versions in all. At least 41 stable versions are under 12 months old by their age labels. The repository shows 27 open issues and 1 open pull request. Pub points 160, 352 likes, 611k downloads. No discontinued or replaced notice on the pages read. |
| Direct dependencies seen | `collection`, `crypto`, `material_ui`, `path`, `path_provider`, `pdfium_flutter`, `pdfrx_engine`, `rxdart`, `synchronized`, `url_launcher`, `vector_math`, `web`, `yaml`. `flutter` comes from the SDK. `path_provider` and `url_launcher` overlap DEP-49 and DEP-53. The others have no row here. |
| Alternatives considered | DEP-65 is the comparison partner. No other library is assessed (DEC-005). |
| Cost | None expected (MIT; PDFium a BSD-3-Clause notice and the Apache License 2.0 text per YG's re-read of 4 November 2026). No source document states a cost. A paid licence needs MFW's written approval (RS NFR-MAINT-006). |

#### DEP-65 pdfx

| Field | Detail |
|---|---|
| Purpose and modules | A PDF rendering library to compare with DEP-64 for MOD-07 (T-02.3). Same proposed use as DEP-64: spike package only until DEC-005 moves. |
| Decision | DEC-005 (OPEN), OQ-36. No library is chosen. |
| Status | CANDIDATE (comparison only). The licences are read (YG's report). The dependency decision stays open: DEC-005 is OPEN. |
| Version | Not pinned. Latest stable seen: 2.11.0, published 20 August 2026 (from the package's version feed). Needs Dart 3.3 or later. The 2.11.0 changelog raises the minimum Flutter version to 3.29.0. The toolchain seen meets this. |
| Licence and source | pub.dev shows MIT. The LICENSE file read at `https://raw.githubusercontent.com/ScerIO/packages.flutter/main/LICENSE` is the repository root file, reported identical to the one inside the pdfx folder. It has the title "MIT License" and the line "Copyright (c) 2019 RBC, Serge Shkurko". The pub.dev licence page shows the same. Read by a developer: yes (YG, 1 November 2026): MIT. YG reported the licence name, so the title and copyright line above are still from the automated reader. **Native engines:** the pages read do not show their licences. YG reported on 1 November 2026 that PDFium (Windows) and PDF.js (web) are Apache License 2.0, and that Android and iOS use the platform's own engines (the Android PdfRenderer and the iOS CGPDFPage), which are system components. No page addresses were given. YG's re-read of PDFium's LICENSE file on 4 November 2026 found a BSD-3-Clause notice as well as the Apache License 2.0 text (see DEP-64). The review of pull request 13 says PDF.js is Apache License 2.0. |
| Publisher | serge.software (verified publisher on pub.dev) |
| Platform support | Android, iOS, macOS, web, Windows. Linux is not listed. |
| Native code | The README names the Android PdfRenderer for Android, CGPDFPage for iOS and macOS, PDFium for Windows and PDF.js for web. It does not say whether binaries are bundled or downloaded. |
| Maintenance signals | 22 versions in all. 2 releases in the last 12 months, both on 20 August 2026. The one before them is dated 13 June 2025 (derived from the version feed). The repository is a monorepo with 268 open issues across all its packages, and no count for pdfx alone. Its page carries a notice inviting new maintainers. Pub points 160, 528 likes, 490k downloads. No discontinued or replaced notice on the pages read. |
| Direct dependencies seen | `extension`, `meta`, `photo_view`, `plugin_platform_interface`, `synchronized`, `universal_platform`, `uuid`, `vector_math`, `web`. `flutter` and `flutter_web_plugins` come from the SDK. |
| Alternatives considered | DEP-64 is the comparison partner. No other library is assessed (DEC-005). |
| Cost | None expected (MIT; the engines PDFium under a BSD-3-Clause notice and the Apache License 2.0 text, PDF.js under Apache License 2.0, or system components, per YG's reports of 1 and 4 November 2026). No source document states a cost. A paid licence needs MFW's written approval (RS NFR-MAINT-006). |

### 8.2 Backend tools (pull request #66)

The first backend code, `backend/` (MOD13-P1-T01 to T03, DEC-003 AGREED), runs its rule tests on the local emulators. These are development tools: none is shipped in the app or deployed. The versions are pinned in `backend/package.json` and `backend/package-lock.json`, which come from the emulator spike on `spike/sa-backend-rules`. The licences were read on 9 November 2026 from the installed packages, by an automated reader in Sanika Attarde's session. Read by a developer: no.

| ID | Tool | Purpose | Version | Licence and source | Cost | Status |
|---|---|---|---|---|---|---|
| DEP-79 | Node.js | Runs the tests and the command line tools | `engines: node >=22` in `backend/package.json`. The tests ran on 26.0.0. The deploy runtime of Cloud Functions is set with the first function (TD-04, B-10 of the spike) | MIT: the `LICENSE` file shipped with Node.js ("Node.js is licensed for use as follows", the MIT terms, "Copyright Node.js contributors"), which also lists the licences of the parts it bundles. Read by YG, confirmed in chat on 10 November 2026. Installed by the developer, not by the project; on the runner of QG-08 by `actions/setup-node` (DEP-96) | None | CONFIRMED for development |
| DEP-80 | `firebase-tools` | The Firebase command line tools: the Firestore and Storage emulators, and later deploys | 15.34.2, exact pin | MIT: the package's LICENSE file, "The MIT License (MIT)", "Copyright (c) 2015 Firebase". Read by YG, confirmed in chat on 10 November 2026. Install scripts: `npm ci` meets three packages with install scripts, `@firebase/util` and `protobufjs` (postinstall) and `re2`, which downloads a prebuilt native binary. npm 11 on the developer's Mac lists them and does not run them unless approved; npm 10 on the runner of QG-08 runs them by default, with read-only permissions and no secret. QG-11 is to decide on them. | None | CONFIRMED (development) |
| DEP-81 | `@firebase/rules-unit-testing` | Runs the rule tests against the emulators | 6.0.0, exact pin | Apache-2.0: the `license` field of the package's `package.json`. The package ships no LICENSE file. Read by YG, confirmed in chat on 10 November 2026 | None | CONFIRMED (development) |
| DEP-82 | `firebase` (JavaScript SDK) | The client calls in the rule tests | 13.1.0, exact pin | Apache-2.0: the `license` field of the package's `package.json`. The package ships no LICENSE file. Read by YG, confirmed in chat on 10 November 2026 | None | CONFIRMED (development); also a runtime dependency of the admin panel since 10 November 2026 (section 8.4) |
| DEP-83 | Java (OpenJDK) | The emulators need Java 21 or later | OpenJDK 21.0.13 (Homebrew `openjdk@21`) on the run of 9 November 2026 | GPL-2.0 with the Classpath Exception: `legal/java.base/LICENSE` of the OpenJDK 21 install (the GNU General Public License version 2, with the notice that files Oracle so designates carry the "Classpath" exception), with `ASSEMBLY_EXCEPTION` and `ADDITIONAL_LICENSE_INFO` beside it. A development tool, not shipped or linked into the app. Read by YG, confirmed in chat on 10 November 2026. Installed by the developer; on the runner of QG-08 by `actions/setup-java` (DEP-77) | None | CONFIRMED for development |

The lockfile pins the packages these bring in. Under the position on QG-10 (section 10), they are not given entries.

### 8.3 Cloud Functions packages (10 November 2026)

`backend/functions/` (DEC-003, DEC-025 AGREED). Pinned in `backend/functions/package.json` and its lockfile, taken from the emulator spike. Licences read from the installed packages' `package.json` on 10 November 2026, in Sanika Attarde's session.

| ID | Package | Purpose | Version | Licence | Cost | Status |
|---|---|---|---|---|---|---|
| DEP-84 | `firebase-admin` | Server access to Auth, Firestore and Storage from the functions | 14.5.0, exact pin | Apache-2.0 | None | CONFIRMED (runtime, server) |
| DEP-85 | `firebase-functions` | Declares the callable and storage-triggered functions | 7.4.0, exact pin | MIT | None | CONFIRMED (runtime, server) |
| DEP-86 | `typescript` | Compiles `functions/src/` | 7.0.2, exact pin | Apache-2.0 | None | CONFIRMED (development) |
| DEP-87 | `@types/node` | Node.js types for the compiler | 22.20.5, exact pin | MIT | None | CONFIRMED (development) |
| DEP-88 | `pdfjs-dist` | The genuine-PDF check of OP-40 (FR-ADMIN-006, NFR-SEC-008), with scripts and font loading off | 6.4.299, exact pin | Apache-2.0 | None | CONFIRMED (runtime, server) |

### 8.4 Admin panel packages (10 November 2026)

`admin/` (DEC-004 AGREED). Pinned in `admin/package.json` and its lockfile, taken from the admin spike, where each was the newest release at least two weeks old on 5 November 2026. Licences read from the installed packages' `package.json` on 10 November 2026. React is DEP-31 (section 6), and the Firebase JavaScript SDK is DEP-82, now also a runtime dependency of the panel.

| ID | Package | Purpose | Version | Licence | Cost | Status |
|---|---|---|---|---|---|---|
| DEP-89 | `vite`, `@vitejs/plugin-react` | The panel's dev server and static build (TD-14 names no build tool) | 8.3.5 and 6.1.2, exact pins | MIT | None | CONFIRMED (development) |
| DEP-90 | `typescript` | Type checks for `admin/` (also DEP-86 for the functions) | 7.0.2, exact pin | Apache-2.0 | None | CONFIRMED (development) |
| DEP-91 | `@types/react`, `@types/react-dom` | Types for DEP-31 | 19.3.0, exact pins | MIT | None | CONFIRMED (development) |
| DEP-92 | `vitest` | The panel's test runner (QG-09) | 5.0.5, exact pin | MIT | None | CONFIRMED (development) |
| DEP-93 | `jsdom` | A simulated browser for the component tests | 30.1.3, exact pin | MIT | None | CONFIRMED (development) |
| DEP-94 | `@testing-library/react`, `@testing-library/dom` | Render and drive the components in tests | 16.3.3 and 10.4.2, exact pins | MIT | None | CONFIRMED (development) |
| DEP-95 | `react-router` | The panel's routes (issues, an issue, categories, news) | 8.5.0, exact pin | MIT | None | CONFIRMED (runtime, admin panel) |

### 8.5 FlutterFire packages in the app (10 November 2026)

`app/` (DEC-003 AGREED, DEP-47). Added with `flutter pub add` and locked in `app/pubspec.lock`. Licences read from each package's LICENSE file on 10 November 2026: BSD-3-Clause, "the Chromium project authors". They need iOS 15 and Android minSdk 24, which the app already sets. The plugins run only on a device or simulator; the app's tests use fakes through the account ports (`app/lib/features/account/domain/`).

| ID | Package | Purpose | Version | Licence | Cost | Status |
|---|---|---|---|---|---|---|
| DEP-96 | `firebase_core` | Starts Firebase in the app | 5.1.0 (`^5.1.0`) | BSD-3-Clause | None | CONFIRMED (runtime, app) |
| DEP-97 | `firebase_auth` | Email registration, sign-in, verification and password reset (MOD-03) | 7.0.1 (`^7.0.1`) | BSD-3-Clause | None | CONFIRMED (runtime, app) |
| DEP-98 | `cloud_functions` | Calls the backend operations, such as OP-10 and OP-12 | 7.0.1 (`^7.0.1`) | BSD-3-Clause | None | CONFIRMED (runtime, app) |
| DEP-99 | `cloud_firestore` | Reads the reader's own records, such as the profile (MOD-04) | 7.1.0 (`^7.1.0`) | BSD-3-Clause | None | CONFIRMED (runtime, app) |
| DEP-100 | `url_launcher` | Opens MFW's privacy policy and terms of use in the browser (CFG-07, MOD04-P2-T02) | 6.3.3 (`^6.3.3`) | BSD-3-Clause, "The Flutter Authors" | None | CONFIRMED (runtime, app) |
| DEP-102 | `firebase_messaging` | Push: the notification permission, one topic per category, and taps (TD-13, MOD11-P2-T02). Added on 11 November 2026; its manifest adds the Android `POST_NOTIFICATIONS` permission. iOS delivery needs the push credential and capability in MFW's Apple account (MOD11-P2-T01) | 17.0.1 (`^17.0.1`), with `firebase_messaging_platform_interface` 4.11.1 and `firebase_messaging_web` 4.3.1 | BSD-3-Clause, "The Chromium Authors" | None. Firebase Cloud Messaging has no charge (S2) | CONFIRMED (runtime, app) |

## 9. Repository and CI Services

| ID | Name | Category | Purpose | Owner | Licence and security | Cost | Status | Required action |
|---|---|---|---|---|---|---|---|---|
| DEP-60 | GitHub repository `sanikaattarde/Metal-Forming-World-MFW-` | Source hosting | All code and documents | Currently the `sanikaattarde` account; MFW after transfer (OQ-48) | Plan not verified. Visibility: public (GitHub API, 5 November 2026). Branch protection on `main` is on (`DEVELOPMENT_WORKFLOW.md` section 3) | Depends on the plan; verify | CONFIRMED | Verify plan features; OQ-48 |
| DEP-61 | GitHub Actions | CI | QG-01 to QG-13. The first workflow, `.github/workflows/pr.yml`, runs QG-01 to QG-06 (T-01.5, pull request #48) | Repository owner | Secrets per environment (`CI_CD_AND_QUALITY_GATES.md` §7). The first workflow uses no secrets and reads the repository only | Minutes depend on the plan; macOS minutes cost more. The repository owner approved the cost of the first workflow on 8 November 2026 (DEC-022, `DECISION_LOG.md` section 5.9). The plan minutes and the macOS runner cost are NOT VERIFIED (MOD15-P1-T01) | CONFIRMED (DEC-022, AGREED) | DEC-022 |
| DEP-62 | Secrets scanner (gitleaks, or GitHub secret scanning) | CI security | QG-11 | Repository owner | Verify the licence or plan availability | Verify | CANDIDATE | Choose after T-01.5. The first workflow covers QG-01 to QG-06 only (YG, 7 November 2026) |
| DEP-63 | Documentation check script | CI | QG-12 | Both | Written by the team | None | CANDIDATE | Write after T-01.5, for the same reason as DEP-62 |
| DEP-75 | `actions/checkout` v7.0.1, used at commit `3d3c42e5aac5ba805825da76410c181273ba90b1` (the commit of the tag) | CI action | Checks out the repository in each job of the first workflow (QG-01 to QG-06) | Both | The LICENSE file at the tag is "The MIT License (MIT)", "Copyright (c) 2018 GitHub, Inc. and contributors" (automated reading of 7 November 2026, to confirm). Owned by GitHub. Used with `persist-credentials: false` under read-only contents permission | None | CONFIRMED | In `.github/workflows/pr.yml` (T-01.5, pull request #48) |
| DEP-76 | `actions/upload-artifact` v7.0.2, used at commit `cf430e030ddbb5b0abf93d22962f4752f3646cd9` (the commit of the tag) | CI action | Keeps the coverage report of QG-04 for 7 days | Both | The LICENSE file at the tag is "The MIT License (MIT)", "Copyright (c) 2018 GitHub, Inc. and contributors" (automated reading of 7 November 2026, to confirm). Owned by GitHub | None | CONFIRMED | In `.github/workflows/pr.yml` (T-01.5, pull request #48) |
| DEP-77 | `actions/setup-java` v6.1.0, used at commit `b843ebf9b913146b38da2eaa7aeddf76074ae1ad` (the commit of the tag) | CI action | Installs Eclipse Temurin Java 17 (DEP-74) for the Android build of QG-05, and Java 21 (DEP-83) for the emulators of QG-08 (`.github/workflows/backend.yml`) | Both | The LICENSE file at the tag is "The MIT License (MIT)", "Copyright (c) 2018 GitHub, Inc. and contributors" (automated reading of 7 November 2026, to confirm). Owned by GitHub | None | CONFIRMED | In `.github/workflows/pr.yml` (T-01.5, pull request #48) |
| DEP-96 | `actions/setup-node` v7.1.0, used at commit `949feb2413d6458794dcd2491c4babbbce0c15c1` (the commit of the tag, released 8 October 2026) | CI action | Installs Node.js 22 (DEP-79) for QG-08, the runtime `backend/functions/` pins | Both | The LICENSE file at the tag is "The MIT License (MIT)", "Copyright (c) 2018 GitHub, Inc. and contributors" (read by the development assistant on 9 November 2026, to confirm by a developer). Owned by GitHub | None | CONFIRMED | In `.github/workflows/backend.yml` (MOD15-P2-T02) |

Numbers 33 and 34 are not assigned. Sections 7 to 9 start at 35, to leave room for further backend or admin candidates. DEP-64 to DEP-66 were added later and sit in section 8. DEP-33, DEP-34 and DEP-67 to DEP-73 are used on the backend and admin spike branches, which are not on `main`, so the rows added on 7 November 2026 start at DEP-74. DEP-78 was added on 8 November 2026.

## 10. Open Items

| Item | Reference |
|---|---|
| Backend and admin choices | DEC-003, DEC-004, OQ-35 |
| PDF library and licence | DEC-005, OQ-36 |
| Toolchain versions are pinned (DEP-35, DEP-36). OQ-50 is ANSWERED, not CLOSED, because the other documents that cite it are not all updated | OQ-50 |
| Client inputs | DEP-01 to DEP-14 |
| The brand values read from MFW's website, which MFW confirms, and the licences of the three typefaces (8 November 2026) | DEP-02, DEP-78, OQ-63 |
| Current provider prices | To be checked with each provider before any cost is reported to MFW |
| A developer reads the LICENSE file of each package in section 8.1 and records the licence name. Done for DEP-66 on 30 October 2026, and for DEP-64, DEP-65 and DEP-66 on 1 November 2026 (YG's report, licence names only). DEP-43, DEP-44 and DEP-58 were added by pull request #30 before a developer read their files. On 7 November 2026 an automated reader read them at the pinned versions, with DEP-35's, and YG accepts that reading (in chat, not filed). Whether an accepted automated reading meets the verification rule of section 2 is for both developers to say | Section 2, verification rule; DEP-35, DEP-43, DEP-44, DEP-58, DEP-64, DEP-65 |
| pub.dev reports the licence of `html` as unknown. YG read the GitHub LICENSE file on 30 October 2026 and recorded it as MIT License (the file does not name the licence; YG identified it from the terms). The copyright line on the pub.dev licence page (2006-2012 The Authors) differs from the one in the file (2006-2013 James Graham and other contributors). The discrepancy is recorded, not resolved | DEP-66, DEP-54 |
| The licence of PDFium (used by pdfrx) and of the native engines of pdfx is not shown on the pages read. YG reported Apache License 2.0 for PDFium, and for the PDFium and PDF.js engines of pdfx (1 November 2026, no page addresses). After the review of pull request 13, YG re-read PDFium's LICENSE file on 4 November 2026 and reports a BSD-3-Clause notice followed by the Apache License 2.0 text. Both notices are recorded, because the review says both have to be kept. The prebuilt PDFium binaries that the pdfrx build downloads are recorded as not read | DEP-64, DEP-65; DEC-005, OQ-36 |
| QG-10 fails for a package in `pubspec.lock` that has no entry. The text does not say whether transitive packages count. On `main` (`5a77910`) the lock file lists 40 packages: 5 direct (DEP-43, DEP-44 and DEP-58 from pub.dev, and `flutter` and `flutter_test` from the SDK, DEP-35 and DEP-59) and 35 transitive (32 from pub.dev, 3 from the SDK). **Position (PROPOSED, YG, 7 November 2026; Sanika Attarde raised the point in the review of pull request #30):** a register entry is needed for each direct dependency only. The transitive packages are listed, with their licences, in a QG-10 report, not as register entries. Both developers decide | Section 3, step 4; `CI_CD_AND_QUALITY_GATES.md` QG-10 |
| Section 3, step 1 puts the register entry in the same pull request as the pubspec change. `DEVELOPMENT_WORKFLOW.md` section 12, point 1 says documentation changes go in separate pull requests from code. For the first CI workflow, the rows (DEP-74 to DEP-77) come first in this register change, and the workflow follows in its own pull request (YG's choice, 7 November 2026) | Section 3; `DEVELOPMENT_WORKFLOW.md` section 12 |
| The register has no rows for the server-side tools: Node.js, TypeScript, the server npm packages, the Firebase command line tools, and the Java that the emulators use. The backend and the admin panel are spikes (DEC-003, DEC-004), and nothing from them is on `main`. The rows go into the pull request that merges the first backend or admin code, so that QG-10 can check them (finding T-5 of issue 32, agreed by YG on 6 November 2026). Met for the backend on 9 November 2026: section 8.2 (pull request #66). The admin panel's tools come with its first code | DEC-003, DEC-004; QG-10 |
