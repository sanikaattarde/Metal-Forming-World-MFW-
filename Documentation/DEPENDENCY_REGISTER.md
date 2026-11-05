# Dependency Register: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Dependency Register |
| File | `Documentation/DEPENDENCY_REGISTER.md` |
| Phase | 4 — Testing, Release and Risk Management (document 39) |
| Version | 0.7 |
| Status | Draft for review. Not approved. No package is installed. No version, licence or price below has been verified unless it is quoted from a source document, or is recorded in section 8.1 with the page it was read from. The section 8.1 facts were read on 30 October 2026 by an automated page reader. A developer has read the LICENSE files of DEP-64, DEP-65 and DEP-66 (YG, 1 November 2026; DEP-66 also on 30 October 2026). YG also reports the licence of PDFium and of the pdfx native engines (1 November 2026), and re-read PDFium's LICENSE file on 4 November 2026 after the review of pull request 13: a BSD-3-Clause notice followed by the Apache License 2.0 text. Those reports give licence names only, with no page addresses. |
| Date | 5 November 2026 |
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
| 0.7 | 5 November 2026 | The DEP-60 row records that branch protection on `main` is on. No MFW approval is recorded, and no entry is APPROVED. |

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

The register separates confirmed dependencies from candidates and open choices, using four statuses:

| Verification status | Meaning |
|---|---|
| CONFIRMED | Needed according to the source documents or repository evidence. The version or terms may still need verifying. |
| CANDIDATE | Proposed, not chosen, and not installed |
| UNRESOLVED | A choice is needed and no candidate is preferred |
| NOT RECEIVED | A client input with no record of receipt in the repository |

**Verification rule.** A version is recorded only once it is pinned in the repository. A licence is recorded only from the dependency's own LICENSE file or official page, read by a developer. A cost is recorded only from a source document, and must still be checked with the provider. Until then, the "Licence and security" and "Cost" columns say what must be verified. Section 8.1 records versions seen and licences shown, and labels each one that way. It pins no version and accepts no licence for use, so it does not conflict with this rule.

## 3. How to Add a Dependency

1. Add an entry here first, in the same pull request as the change to `pubspec.yaml` (or the backend or admin equivalent) (`CODING_STANDARDS.md` §12).
2. Record the purpose, dependent modules, licence (with its source), publisher, platform support, maintenance signals, alternatives considered and any cost.
3. A paid or commercially licensed component needs MFW's written approval before it is added (RS NFR-MAINT-006; S1 Costs outside the fee).
4. QG-10 fails if `pubspec.lock` contains a package with no entry here.

## 4. Client-Provided Inputs and Documents

Owner of each input: MFW. Tracking: Sanika Attarde (MFW contact). The "needed by" timing is from S1, relative to project weeks. CH §12 dates are PROVISIONAL.

| ID | Dependency | Purpose and dependent work | Needed by [S1] | Status | Required action |
|---|---|---|---|---|---|
| DEP-01 | Named approver and deputy; written confirmation of content rights | All approvals; COM-08 | Before kickoff | NOT RECEIVED | Request (OQ-28) |
| DEP-02 | Logo files, brand colours and fonts | WP-02 designs; RS NFR-UX-001 | Kickoff | NOT RECEIVED | Request |
| DEP-03 | Two or three sample PDFs, including the largest expected issue | T-02.3 reader test; FX-PDF-03, FX-PDF-04 | End of Week 1 | NOT RECEIVED | Request; agree storage (DEC-024) |
| DEP-04 | WordPress site address, API confirmation, news categories | WP-08; CFG-03, CFG-04 | End of Week 1 | NOT RECEIVED | Request (OQ-39) |
| DEP-05 | Cloud project in MFW's name with billing switched on (S1 names Firebase and Google Cloud) | WP-01; every backend task | End of Week 1 | NOT RECEIVED | Request after DEC-003 and DEC-023 |
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
| DEP-19 | WordPress REST API on MFW's site | External API | MOD-09 (RS INT-WP-001) | WordPress version unknown | MFW and its host | Read-only and public. No credentials. | None to the project | CONFIRMED | OQ-39 |
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
| DEP-31 | React | Admin user interface | MOD-12 | Development team | Verify from its LICENSE file | None expected (open source); verify | CANDIDATE (S2) | DEC-004 |
| DEP-32 | Flutter web | Admin user interface (alternative) | MOD-12 | Development team | As DEP-35 | None expected; verify | CANDIDATE, not assessed (not in S2) | DEC-004 |

## 7. Toolchain and Development Tools

| ID | Name | Category | Purpose | Version | Owner | Licence and security | Cost | Status | Required action |
|---|---|---|---|---|---|---|---|---|---|
| DEP-35 | Flutter SDK | Framework | All app modules (DEC-002) | Not pinned (OQ-50) | Both developers | Verify the licence from the Flutter repository at pinning | None expected | CONFIRMED (framework); version UNRESOLVED | Pin the version (OQ-50) |
| DEP-36 | Dart SDK | Language | Bundled with Flutter | Follows DEP-35 | Both | As DEP-35 | None expected | CONFIRMED | — |
| DEP-37 | Android SDK and build tools | Build tooling | Android builds (QG-05) | Per Flutter's requirements | Both | Vendor terms | None expected | CONFIRMED | Record versions at T-01.1 |
| DEP-38 | Xcode on macOS | Build tooling | iOS builds (QG-06, QG-13). iOS builds need macOS. | The version Apple requires at submission (verify) | Both | Apple terms | Needs a Mac (developer-owned) | CONFIRMED | Confirm each developer's Mac access |
| DEP-39 | iOS plugin dependency tooling (CocoaPods and/or Swift Package Manager, as the pinned Flutter version uses) | Build tooling | iOS plugin integration | Verify | Both | Verify | None expected | CONFIRMED (need); tool UNRESOLVED | Confirm at T-01.1 |
| DEP-40 | Git | Version control | Repository | — | Both | — | None | CONFIRMED | — |
| DEP-41 | Claude Code | Development assistant | Both developers' sessions (`CLAUDE_CODE_WORKING_RULES.md`) | — | Each developer | Each developer's own terms. No production secrets or personal data shared with sessions. | Each developer's own account | CONFIRMED (in use) | — |
| DEP-42 | Network fault-injection proxy (for example toxiproxy or mitmproxy) | Test tooling | FX-NET-07 | — | WS-B | Verify the licence before use | Verify | CANDIDATE | Choose in WP-06 |

## 8. Flutter Package Candidates

None is added. Each needs the review in Section 3 before it is added.

Section 8.1 holds review entries for the candidates the WS-B scaffold needs, and for the two PDF libraries to be compared under DEC-005. What it records is what the pages showed on 30 October 2026. It is not a pin and not an approval.

| ID | Candidate | Purpose and dependent modules | Decision | Licence and security to verify | Cost | Status |
|---|---|---|---|---|---|---|
| DEP-43 | Riverpod | State management (all app modules) | DEC-013 | LICENSE file; maintenance. Read on 30 October 2026: section 8.1 | None expected | CANDIDATE |
| DEP-44 | go_router | Navigation and guards (MOD-01) | DEC-014 | LICENSE file. Read on 30 October 2026: section 8.1 | None expected | CANDIDATE |
| DEP-45 | PDF rendering library | MOD-07 | DEC-005, OQ-36 | **Licence is critical.** Some PDF viewer packages are distributed under commercial licences, which would need MFW's written approval. Check platform support, rendering quality at 300% zoom, and memory use with large files. Candidates for the comparison: DEP-64 and DEP-65 (section 8.1). Neither is chosen. | Possibly paid; verify | UNRESOLVED |
| DEP-46 | google_sign_in plugin | MOD-03 | DEC-006 | LICENSE file; platform set-up | None expected | CANDIDATE |
| DEP-47 | Backend provider plugins (for example the FlutterFire packages, if DEC-003 chooses Firebase) | MOD-03 to MOD-13 data layers | DEC-003 | LICENSE files; privacy manifests (IOS-09) | None expected | CANDIDATE |
| DEP-48 | Secure storage plugin (for example flutter_secure_storage) | Tokens (`CODING_STANDARDS.md` §8.1) | — | LICENSE file; Keychain and Keystore behaviour | None expected | CANDIDATE |
| DEP-49 | App directories (path_provider) | Private storage paths (MOD-06) | — | LICENSE file | None expected | CANDIDATE |
| DEP-50 | Connectivity type (for example connectivity_plus) | Mobile-data warning (MOD-01; RS FR-DL-004) | — | LICENSE file; accuracy on both platforms | None expected | CANDIDATE |
| DEP-51 | Resumable download client (an HTTP client with range requests, or a platform background-download plugin) | MOD-06 (RS FR-DL-006) | DEC-020; WP-02 spike | LICENSE file; background behaviour | None expected | UNRESOLVED |
| DEP-52 | Share sheet (for example share_plus) | MOD-10 | — | LICENSE file | None expected | CANDIDATE |
| DEP-53 | Link opening (url_launcher) | Policy links and article links (MOD-04, MOD-09) | — | LICENSE file | None expected | CANDIDATE |
| DEP-54 | HTML rendering for WordPress content | MOD-09 (`CODING_STANDARDS.md` §7) | — | LICENSE file; **must not run scripts** (SEC-CHK-15). The parser DEP-66 is recorded in section 8.1 as one input; the rendering route stays open. | None expected | UNRESOLVED |
| DEP-55 | Local cache storage for news and metadata | MOD-05, MOD-09 (RS FR-NEWS-005) | OQ-10, OQ-16 | LICENSE file | None expected | UNRESOLVED |
| DEP-56 | JSON code generation (json_serializable, freezed) | Serialization (`CODING_STANDARDS.md` §7) | — | LICENSE files | None expected | CANDIDATE (optional) |
| DEP-57 | Mocking library (for example mocktail) | Tests (`CODING_STANDARDS.md` §10) | — | LICENSE file | None expected | CANDIDATE (optional) |
| DEP-58 | flutter_lints | Static analysis (`CODING_STANDARDS.md` §4) | — | LICENSE file. Read on 30 October 2026: section 8.1 | None expected | CANDIDATE |
| DEP-59 | flutter_test and integration_test | Tests (TS-02 to TS-04) | — | Part of the Flutter SDK | None | CONFIRMED (SDK) |
| DEP-64 | pdfrx | PDF rendering library, for the comparison test (MOD-07, T-02.3) | DEC-005, OQ-36 | LICENSE file, read by YG on 1 November 2026: MIT. PDFium, the engine it bundles: a BSD-3-Clause notice and the Apache License 2.0 text, YG's re-read of 4 November 2026. Section 8.1 | None expected; verify | CANDIDATE (comparison only) |
| DEP-65 | pdfx | PDF rendering library, for the comparison test (MOD-07, T-02.3) | DEC-005, OQ-36 | LICENSE file, read by YG on 1 November 2026: MIT. Native engines, YG's reports of 1 and 4 November 2026: PDFium (Windows) a BSD-3-Clause notice and the Apache License 2.0 text, PDF.js (web) Apache License 2.0; Android and iOS use the platform's own engines. Section 8.1 | None expected; verify | CANDIDATE (comparison only) |
| DEP-66 | html (HTML parser) | Parses WordPress post content, one input to DEP-54 (MOD-09) | DEP-54 | LICENSE file, read by YG on 30 October 2026 and again on 1 November 2026: MIT License (YG's identification from the terms; the file does not name it). pub.dev reports the licence as unknown. Section 8.1 | None expected; verify | CANDIDATE |

### 8.1 Review Entries (facts read on 30 October 2026)

**How these entries were made.** On 30 October 2026 an automated page reader opened the pub.dev pages and the LICENSE files named in each entry and reported what they showed. A developer has read the LICENSE files of DEP-64, DEP-65 and DEP-66 (YG: DEP-66 on 30 October 2026, and all three on 1 November 2026). Every other licence row says "to confirm". YG's reads of 1 November 2026, and the re-read of PDFium's LICENSE file on 4 November 2026, are reports in chat: YG gave licence names and no page addresses, so the titles and copyright lines recorded for DEP-64 and DEP-65 are still the automated reader's. "Seen" means shown on a page that day. Nothing here is pinned, approved or installed. A date marked "derived" is worked out from an age label such as "56 days ago", because the page gave no calendar date. The reader's reports are not filed in the repository.

**Toolchain seen.** Flutter 3.47.9 and Dart 3.13.7 on YG's machine on 30 October 2026 (`flutter doctor -v`). This is an observation, not a pin (DEP-35, OQ-50). Every minimum SDK version in the entries below is met by it.

**Before a package goes into a `pubspec.yaml`:**

1. A developer opens the LICENSE file named in the entry and records the licence name and the date in the entry.
2. The version is pinned in the same pull request as the pubspec change and recorded in the entry (section 2, verification rule; section 3, step 1).
3. The decision behind the package is agreed in writing by both developers (DEC-013, DEC-014, DEC-005), or the use stays on a spike branch (`DEFINITION_OF_DONE.md` section 5, check 2).

#### DEP-43 flutter_riverpod

| Field | Detail |
|---|---|
| Purpose and modules | State management and the injection of fakes, for all app modules |
| Decision | DEC-013 (AGREED, recorded 4 November 2026, evidence in `DECISION_LOG.md` section 5.6). Both developers' written positions are filed: Sanika Attarde's in section 5.4 and Yuvraj's in section 5.5. Conditions still open (section 5.6): Riverpod is used in `app/lib/app/` only, feature code takes its dependencies through constructors, the Flutter and Dart versions are pinned at the scaffold (OQ-50), and this entry comes before the package. No MFW approval is recorded. |
| Status | CANDIDATE |
| Version | Not pinned. Latest stable seen: 3.4.3, published "56 days ago" (4 September 2026, derived). Needs Dart 3.12 or later. |
| Licence and source | pub.dev shows MIT. The LICENSE file read at `https://raw.githubusercontent.com/rrousselGit/riverpod/master/LICENSE` has the title "MIT License" and the line "Copyright (c) 2020 Remi Rousselet". The pub.dev licence page shows the same two lines. Read by a developer: no (to confirm). |
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
| Decision | DEC-014 (AGREED, recorded 4 November 2026, evidence in `DECISION_LOG.md` section 5.6), on the same filing position as DEC-013. Conditions still open (section 5.6): the route guard steers screens only and the server enforces access (DEC-009), the versions are pinned at the scaffold, and this entry comes before the package. No MFW approval is recorded. |
| Status | CANDIDATE |
| Version | Not pinned. Latest stable seen: 18.1.2, published "16 hours ago", so within a day of the reading (the page gives no calendar date). Needs Dart 3.12 or later. The page links a migration guide for the breaking changes in 18.0.0. Choose the pin at the scaffold, not from this entry. |
| Licence and source | pub.dev shows BSD-3-Clause. The file read is the repository root LICENSE, `https://raw.githubusercontent.com/flutter/packages/main/LICENSE`, not a file inside the package folder. It has no title line. Its first line is "Copyright 2013 The Flutter Authors", and the pub.dev licence page shows the same first line. Read by a developer: no (to confirm). |
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
| Decision | None. The analysis rules in `CODING_STANDARDS.md` are PROPOSED. |
| Status | CANDIDATE |
| Version | Not pinned. Latest stable seen: 6.0.0, published 27 May 2025 (from the package's version feed). Needs Dart 3.8 or later. |
| Licence and source | pub.dev shows BSD-3-Clause. The LICENSE file read at `https://github.com/flutter/packages/blob/main/packages/flutter_lints/LICENSE` has no title line. Its first line is "Copyright 2013 The Flutter Authors". The pub.dev licence page shows the same line followed by "All rights reserved." Read by a developer: no (to confirm). |
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

## 9. Repository and CI Services

| ID | Name | Category | Purpose | Owner | Licence and security | Cost | Status | Required action |
|---|---|---|---|---|---|---|---|---|
| DEP-60 | GitHub repository `sanikaattarde/Metal-Forming-World-MFW-` | Source hosting | All code and documents | Currently the `sanikaattarde` account; MFW after transfer (OQ-48) | Plan and visibility not verified. Branch protection on `main` is on (`DEVELOPMENT_WORKFLOW.md` section 3) | Depends on the plan; verify | CONFIRMED | Verify plan features; OQ-48 |
| DEP-61 | GitHub Actions | CI | QG-01 to QG-13 | Repository owner | Secrets per environment (`CI_CD_AND_QUALITY_GATES.md` §7) | Minutes depend on the plan; macOS minutes cost more; verify | CANDIDATE (DEC-022) | DEC-022 |
| DEP-62 | Secrets scanner (gitleaks, or GitHub secret scanning) | CI security | QG-11 | Repository owner | Verify the licence or plan availability | Verify | CANDIDATE | Choose at T-01.5 |
| DEP-63 | Documentation check script | CI | QG-12 | Both | Written by the team | None | CANDIDATE | Write at T-01.5 |

Numbers 33 and 34 are not assigned. Sections 7 to 9 start at 35, to leave room for further backend or admin candidates. DEP-64 to DEP-66 were added later and sit in section 8.

## 10. Open Items

| Item | Reference |
|---|---|
| Backend and admin choices | DEC-003, DEC-004, OQ-35 |
| PDF library and licence | DEC-005, OQ-36 |
| Toolchain versions | OQ-50 |
| Client inputs | DEP-01 to DEP-14 |
| Current provider prices | To be checked with each provider before any cost is reported to MFW |
| Package versions are not pinned. They are pinned at the scaffold and recorded in section 8.1 | OQ-50; DEP-43, DEP-44, DEP-58 |
| A developer reads the LICENSE file of each package in section 8.1 and records the licence name. Done for DEP-66 on 30 October 2026, and for DEP-64, DEP-65 and DEP-66 on 1 November 2026 (YG's report, licence names only). DEP-43, DEP-44 and DEP-58 are still to confirm | Section 2, verification rule; DEP-43, DEP-44, DEP-58, DEP-64, DEP-65 |
| pub.dev reports the licence of `html` as unknown. YG read the GitHub LICENSE file on 30 October 2026 and recorded it as MIT License (the file does not name the licence; YG identified it from the terms). The copyright line on the pub.dev licence page (2006-2012 The Authors) differs from the one in the file (2006-2013 James Graham and other contributors). The discrepancy is recorded, not resolved | DEP-66, DEP-54 |
| The licence of PDFium (used by pdfrx) and of the native engines of pdfx is not shown on the pages read. YG reported Apache License 2.0 for PDFium, and for the PDFium and PDF.js engines of pdfx (1 November 2026, no page addresses). After the review of pull request 13, YG re-read PDFium's LICENSE file on 4 November 2026 and reports a BSD-3-Clause notice followed by the Apache License 2.0 text. Both notices are recorded, because the review says both have to be kept. The prebuilt PDFium binaries that the pdfrx build downloads are recorded as not read | DEP-64, DEP-65; DEC-005, OQ-36 |
| QG-10 fails for a package in `pubspec.lock` that has no entry. The text does not say whether transitive packages count. Direct dependencies seen are listed in section 8.1, and the full set is known only after the first `flutter pub get` | Section 3, step 4; `CI_CD_AND_QUALITY_GATES.md` QG-10 |
| Section 3, step 1 puts the register entry in the same pull request as the pubspec change. `DEVELOPMENT_WORKFLOW.md` section 12, point 1 says documentation changes go in separate pull requests from code | Section 3; `DEVELOPMENT_WORKFLOW.md` section 12 |
