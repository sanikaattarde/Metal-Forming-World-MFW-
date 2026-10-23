# Dependency Register: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Dependency Register |
| File | `Documentation/DEPENDENCY_REGISTER.md` |
| Phase | 4 — Testing, Release and Risk Management (document 39) |
| Version | 0.1 |
| Status | Draft for review. Not approved. No package is installed. No version, licence or price below has been verified unless it is quoted from a source document. |
| Date | 23 October 2026 |
| Prepared in | Sanika Attarde's Claude Code session, branch `SA` |
| Approval required | Both developers. MFW for any paid component (RS NFR-MAINT-006). |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial register |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `MFW_Commercial_Proposal-2.pdf` (S1) "Costs outside the fee", "What we need from MFW" | Exists, issued, unsigned. Source of the cost figures below. |
| `MFW_Statement_of_Work.pdf` (S2) "Proposed technical architecture" | Exists, issued, unsigned |
| `DECISION_LOG.md`, `CODING_STANDARDS.md` §12, `CI_CD_AND_QUALITY_GATES.md` QG-10 | Exist, created in this task |
| `TECH_STACK_DECISIONS.md` | Planned (Phase 2). Not created. |

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

**Verification rule.** A version is recorded only once it is pinned in the repository. A licence is recorded only from the dependency's own LICENSE file or official page, read by a developer. A cost is recorded only from a source document, and must still be checked with the provider. Until then, the "Licence and security" and "Cost" columns say what must be verified.

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

| ID | Candidate | Purpose and dependent modules | Decision | Licence and security to verify | Cost | Status |
|---|---|---|---|---|---|---|
| DEP-43 | Riverpod | State management (all app modules) | DEC-013 | LICENSE file; maintenance | None expected | CANDIDATE |
| DEP-44 | go_router | Navigation and guards (MOD-01) | DEC-014 | LICENSE file | None expected | CANDIDATE |
| DEP-45 | PDF rendering library | MOD-07 | DEC-005, OQ-36 | **Licence is critical.** Some PDF viewer packages are distributed under commercial licences, which would need MFW's written approval. Check platform support, rendering quality at 300% zoom, and memory use with large files. | Possibly paid; verify | UNRESOLVED |
| DEP-46 | google_sign_in plugin | MOD-03 | DEC-006 | LICENSE file; platform set-up | None expected | CANDIDATE |
| DEP-47 | Backend provider plugins (for example the FlutterFire packages, if DEC-003 chooses Firebase) | MOD-03 to MOD-13 data layers | DEC-003 | LICENSE files; privacy manifests (IOS-09) | None expected | CANDIDATE |
| DEP-48 | Secure storage plugin (for example flutter_secure_storage) | Tokens (`CODING_STANDARDS.md` §8.1) | — | LICENSE file; Keychain and Keystore behaviour | None expected | CANDIDATE |
| DEP-49 | App directories (path_provider) | Private storage paths (MOD-06) | — | LICENSE file | None expected | CANDIDATE |
| DEP-50 | Connectivity type (for example connectivity_plus) | Mobile-data warning (MOD-01; RS FR-DL-004) | — | LICENSE file; accuracy on both platforms | None expected | CANDIDATE |
| DEP-51 | Resumable download client (an HTTP client with range requests, or a platform background-download plugin) | MOD-06 (RS FR-DL-006) | DEC-020; WP-02 spike | LICENSE file; background behaviour | None expected | UNRESOLVED |
| DEP-52 | Share sheet (for example share_plus) | MOD-10 | — | LICENSE file | None expected | CANDIDATE |
| DEP-53 | Link opening (url_launcher) | Policy links and article links (MOD-04, MOD-09) | — | LICENSE file | None expected | CANDIDATE |
| DEP-54 | HTML rendering for WordPress content | MOD-09 (`CODING_STANDARDS.md` §7) | — | LICENSE file; **must not run scripts** (SEC-CHK-15) | None expected | UNRESOLVED |
| DEP-55 | Local cache storage for news and metadata | MOD-05, MOD-09 (RS FR-NEWS-005) | OQ-10, OQ-16 | LICENSE file | None expected | UNRESOLVED |
| DEP-56 | JSON code generation (json_serializable, freezed) | Serialization (`CODING_STANDARDS.md` §7) | — | LICENSE files | None expected | CANDIDATE (optional) |
| DEP-57 | Mocking library (for example mocktail) | Tests (`CODING_STANDARDS.md` §10) | — | LICENSE file | None expected | CANDIDATE (optional) |
| DEP-58 | flutter_lints | Static analysis (`CODING_STANDARDS.md` §4) | — | LICENSE file | None expected | CANDIDATE |
| DEP-59 | flutter_test and integration_test | Tests (TS-02 to TS-04) | — | Part of the Flutter SDK | None | CONFIRMED (SDK) |

## 9. Repository and CI Services

| ID | Name | Category | Purpose | Owner | Licence and security | Cost | Status | Required action |
|---|---|---|---|---|---|---|---|---|
| DEP-60 | GitHub repository `sanikaattarde/Metal-Forming-World-MFW-` | Source hosting | All code and documents | Currently the `sanikaattarde` account; MFW after transfer (OQ-48) | Plan, visibility and branch protection not verified | Depends on the plan; verify | CONFIRMED | Verify plan features; OQ-48 |
| DEP-61 | GitHub Actions | CI | QG-01 to QG-13 | Repository owner | Secrets per environment (`CI_CD_AND_QUALITY_GATES.md` §7) | Minutes depend on the plan; macOS minutes cost more; verify | CANDIDATE (DEC-022) | DEC-022 |
| DEP-62 | Secrets scanner (gitleaks, or GitHub secret scanning) | CI security | QG-11 | Repository owner | Verify the licence or plan availability | Verify | CANDIDATE | Choose at T-01.5 |
| DEP-63 | Documentation check script | CI | QG-12 | Both | Written by the team | None | CANDIDATE | Write at T-01.5 |

Numbers 33 and 34 are not assigned. Sections 7 to 9 start at 35, to leave room for further backend or admin candidates.

## 10. Open Items

| Item | Reference |
|---|---|
| Backend and admin choices | DEC-003, DEC-004, OQ-35 |
| PDF library and licence | DEC-005, OQ-36 |
| Toolchain versions | OQ-50 |
| Client inputs | DEP-01 to DEP-14 |
| Current provider prices | To be checked with each provider before any cost is reported to MFW |
