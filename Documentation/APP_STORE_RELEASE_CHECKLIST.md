# App Store Release Checklist: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | App Store Release Checklist |
| File | `Documentation/APP_STORE_RELEASE_CHECKLIST.md` |
| Phase | 4 — Testing, Release and Risk Management (document 35) |
| Version | 0.1 |
| Status | Draft for review. Not approved. **No build has been uploaded and no app has been submitted. No item is verified. Compliance with store guidelines is not asserted.** |
| Date | 23 October 2026 |
| Prepared in | Sanika Attarde's Claude Code session, branch `SA` |
| Approval required | Both developers. MFW approves the listing text and submission (S2 AC-11, M5). |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `MFW_Statement_of_Work.pdf` (S2) AC-11, "Release", "Scope not included" | Exists, issued, unsigned |
| `PROJECT_CHARTER.md` (CH) §18 R8, R9, R10 | Exists, draft |
| `REQUIREMENTS_SPECIFICATION.md` (RS) NFR-PRIV-002, FR-AUTH-009, FR-NOTIF-001 | Exists, draft |
| `DEPLOYMENT_PLAN.md`, `CI_CD_AND_QUALITY_GATES.md`, `TESTING_STRATEGY.md`, `RISK_REGISTER.md`, `OPEN_QUESTIONS.md` | Exist, created in this task |

Store policies change. S2 assumes they are as published at the time of S2 (RS ASM-08). Each item marked "verify" must be checked against the store's current rules when the release is prepared.

## 2. Purpose, Scope and Status

This document lists what must be true before the Android and iOS apps are submitted, and what happens after release. It covers identifiers and signing, build configuration, listings, privacy declarations, permissions, authentication review concerns, account deletion, supported OS versions, test devices, review access, versioning, and post-release checks.

S2 makes M5 complete at submission. Store approval and its timing are outside the team's control (S2 "Scope not included"; risk R8).

## 3. Status Values

| Value | Meaning |
|---|---|
| NOT STARTED | No work done |
| UNVERIFIED | Depends on account settings or facts that have not been seen |
| BLOCKED | Waiting on an open question |
| DONE | Completed, with evidence linked |

All items are NOT STARTED, UNVERIFIED or BLOCKED on 23 October 2026.

## 4. Common Pre-Submission Items

| ID | Item | Reference | Status |
|---|---|---|---|
| COM-01 | MFW approves the store listing text in writing | S2 AC-11; AC-11.2 | NOT STARTED |
| COM-02 | Privacy policy and terms of use are published at public addresses, and linked in the app | CH §12 inputs; RS FR-PRIV-002 | BLOCKED (MFW input) |
| COM-03 | Store privacy declarations match MFW's privacy policy, and are based on an inventory of what the app and its SDKs collect (`DEPENDENCY_REGISTER.md`) | S2 AC-11; RS NFR-PRIV-002; OQ-44 | BLOCKED |
| COM-04 | In-app account deletion works and removes the reader's data | RS FR-AUTH-009, FR-PRIV-003; AC-3.7 | NOT STARTED |
| COM-05 | Review access: a demo account exists in production for store reviewers, because full content needs sign-in | OQ-43 | BLOCKED |
| COM-06 | Release builds made from a release tag, with versions set (Section 8) | S2 AC-11; DEC-015 | NOT STARTED |
| COM-07 | Testing complete on the agreed devices | S2 AC-10; `TESTING_STRATEGY.md` §6 | BLOCKED (OQ-26) |
| COM-08 | MFW's written confirmation that it owns, or may use, the content shown in the app is on file | S1 What we need from MFW; RS ASM-07 | BLOCKED (MFW input) |
| COM-09 | Age-rating and audience answers are consistent with collecting exact age with no age gate, and MFW's legal adviser has reviewed them | CH §18 R10; RS FR-PROF-005; OQ-07 | BLOCKED |
| COM-10 | A support contact or support address is available | OQ-47 | BLOCKED |
| COM-11 | App icon and screenshots come from the M2-approved designs and MFW's brand assets | S2 Scope included: Design; RS NFR-UX-001 | NOT STARTED |
| COM-12 | Release notes written | — | NOT STARTED |
| COM-13 | Security checklist completed, and no critical or high defect open | S2 AC-10; `TESTING_STRATEGY.md` §9 | NOT STARTED |

## 5. Android (Google Play)

| ID | Item | Reference | Status |
|---|---|---|---|
| AND-01 | Google Play Console account in MFW's name is active, and developers have role-based access | S1 What we need from MFW; RS INT-STORE-001, NFR-SEC-012 | UNVERIFIED |
| AND-02 | Account type confirmed. Verify: if it is a personal account created recently, Google Play may require a closed test with a minimum number of testers and a minimum duration before production access. This would affect the M5 timing. | OQ-42; risk R18 | UNVERIFIED |
| AND-03 | Application ID chosen. It cannot be changed after publishing. | OQ-42; CFG-15 | BLOCKED |
| AND-04 | Play App Signing enrolled; upload key held in MFW-controlled storage | `CI_CD_AND_QUALITY_GATES.md` §6 | NOT STARTED |
| AND-05 | Android App Bundle built from the release tag | S2 AC-11 | NOT STARTED |
| AND-06 | Target API level meets Google Play's current requirement. Verify at submission. | Store policy | UNVERIFIED |
| AND-07 | Minimum supported Android version set | OQ-26 | BLOCKED |
| AND-08 | Only the permissions needed are declared: network access, network-state access (for the mobile-data warning, RS FR-DL-004), and notifications. On recent Android versions, notifications need a runtime permission, which is requested after the in-app explanation (RS FR-NOTIF-001). No storage permission is needed for app-private storage. | RS FR-NOTIF-001, NFR-SEC-004 | NOT STARTED |
| AND-09 | Data safety form completed and consistent with MFW's privacy policy | OQ-44; AC-11.3 | BLOCKED |
| AND-10 | Account deletion: the in-app path is declared. Verify Google Play's requirement for a web link where users can request deletion outside the app. The scope excludes public web pages and WordPress changes, so where such a link would live is open. | OQ-45; PAC-15 | BLOCKED |
| AND-11 | Content rating questionnaire completed | Store policy | NOT STARTED |
| AND-12 | Target audience and content declaration completed, consistent with COM-09 | OQ-07; risk R10 | BLOCKED |
| AND-13 | Verify whether Google Play's news-app declaration applies to an app with industry news | Store policy | UNVERIFIED |
| AND-14 | Store listing: app name, short and full descriptions, icon, feature graphic, phone and tablet screenshots. Verify the current size and length limits in Play Console. | COM-01, COM-11 | NOT STARTED |
| AND-15 | "App access" section completed with the review demo account (COM-05) | OQ-43 | BLOCKED |
| AND-16 | Internal testing track run before the production release. A staged rollout for production is PROPOSED. | `DEPLOYMENT_PLAN.md` §9 | NOT STARTED |
| AND-17 | The pre-launch report, if produced by Play Console, is reviewed | Store tooling | NOT STARTED |

## 6. iOS (App Store)

| ID | Item | Reference | Status |
|---|---|---|---|
| IOS-01 | Apple Developer Program membership as an organisation is active. Verify enrolment prerequisites with Apple; organisation enrolment can take weeks. | S1 What we need from MFW; CH §18 R8 | UNVERIFIED |
| IOS-02 | Bundle ID registered. Capabilities configured: push notifications, plus the URL scheme needed for Google Sign-In (CFG-09). | OQ-42 | BLOCKED |
| IOS-03 | Distribution certificate and provisioning profile in MFW's account | `CI_CD_AND_QUALITY_GATES.md` §6 | NOT STARTED |
| IOS-04 | App Store Connect app record created: name, primary language English | RS NFR-UX-003 | NOT STARTED |
| IOS-05 | Build from the release tag uploaded, with a build number higher than any earlier upload | DEC-015 | NOT STARTED |
| IOS-06 | Minimum iOS version set. iPad support decided: the reader supports tablets (RS FR-READ-009), and supporting iPad means iPad screenshots are needed. | OQ-26 | BLOCKED |
| IOS-07 | Only the usage descriptions needed are declared. The notification prompt comes after the in-app explanation (RS FR-NOTIF-001). | RS FR-NOTIF-001 | NOT STARTED |
| IOS-08 | Export compliance (encryption) question answered. Verify the classification for an app that uses only standard HTTPS. | Store policy | UNVERIFIED |
| IOS-09 | Privacy manifest provided for the app and for included SDKs where Apple requires it. Verify against the SDKs chosen. | `DEPENDENCY_REGISTER.md` | UNVERIFIED |
| IOS-10 | App Privacy details completed, consistent with MFW's privacy policy | OQ-44; AC-11.3 | BLOCKED |
| IOS-11 | In-app account deletion available | RS FR-AUTH-009 | NOT STARTED |
| IOS-12 | **Guideline 4.8 (login services).** The app offers Google Sign-In and email login, without Sign in with Apple. **Compliance is not asserted.** See Section 7. | CH §18 R9; OQ-06 | BLOCKED |
| IOS-13 | Review notes and demo account provided, since full content needs sign-in | OQ-43 | BLOCKED |
| IOS-14 | Age rating questionnaire completed, consistent with COM-09 | OQ-07 | BLOCKED |
| IOS-15 | Screenshots for the device sizes App Store Connect currently requires. Verify at submission. | COM-11 | NOT STARTED |
| IOS-16 | Support address and privacy policy address entered | COM-02, COM-10 | BLOCKED |
| IOS-17 | TestFlight internal testing run. External TestFlight testing needs Apple's beta review first. | — | NOT STARTED |
| IOS-18 | For later updates, phased release is considered (PROPOSED) | `DEPLOYMENT_PLAN.md` §9 | NOT STARTED |
| IOS-19 | Any App Store Connect questions about third-party content answered with MFW's content-rights confirmation | COM-08 | BLOCKED |

## 7. Authentication Review Concerns

| Concern | Evidence | Position |
|---|---|---|
| Apple guideline 4.8 | CH §18 R9: the iOS build offers Google Sign-In and email login but not Sign in with Apple, so review may require an equivalent privacy-preserving login option. CH records the risk as accepted [S3], but S3 is not in the repository. | OPEN. MFW's written acceptance is OQ-06. If Apple requires an equivalent option, Sign in with Apple is the known mitigation, handled as a change request (CH R9). Check the current text of the guideline before submission. |
| Google Sign-In scope | S1 Annex A line 27 and S2 list it as a later-phase item. CH §17.3 brings it into scope [S3]. | PROVISIONAL (C-04, OQ-29) |
| Google OAuth consent screen | Google Sign-In needs an OAuth consent screen in MFW's Google account, with the app name, support email and privacy-policy link | NOT STARTED. Verify whether Google requires verification for the scopes used. |
| Email verification for Google accounts | How verification applies to Google accounts | OPEN (OQ-04) |
| Reviewer access | Full content needs sign-in. Without a demo account, review of the reader is likely to stall. | OPEN (OQ-43) |

## 8. Versioning

PROPOSED (DEC-015).

| Item | Rule |
|---|---|
| Version | `MAJOR.MINOR.PATCH`, the same on both platforms |
| Build number | Increases with every upload to either store |
| First release | `1.0.0` with build number 1 (PROPOSED) |
| Tag | `v1.0.0` on `main`, made after DoD-RC |
| Changelog | A version section is added to `CHANGELOG.md` when the tag is created |

## 9. Submission and Review Tracking

| Platform | Version and build | Submitted | Review status | Confirmation sent to MFW (AC-11.4) |
|---|---|---|---|---|
| Android | — | Not submitted | — | — |
| iOS | — | Not submitted | — | — |

## 10. Post-Release Checks and Rollback

1. Once each store makes the app available, run the post-release smoke test (TS-13; `DEPLOYMENT_PLAN.md` §6, SM-01, SM-02, SM-05, SM-07) on the store build.
2. Record the first public availability date in each store. The warranty starts on the later of the two dates (S2 Warranty; `MAINTENANCE_AND_HANDOVER.md` §12).
3. Review crash reports daily during the first week (PROPOSED).
4. Rollback options are limited for mobile apps (`DEPLOYMENT_PLAN.md` §9): halt a staged or phased release, then fix forward and resubmit.
5. A store rejection caused by a defect is fixed and resubmitted at no charge. A rejection that needs MFW's input (for example privacy wording) waits for that input [S2 Warranty].

## 11. Open Items

| Item | Reference |
|---|---|
| App identity and store accounts | OQ-42 |
| Demo account for review | OQ-43 |
| Privacy declarations | OQ-44 |
| Web link for account-deletion requests | OQ-45 |
| Guideline 4.8 acceptance | OQ-06 |
| Minimum OS versions and test devices | OQ-26 |
| Minors and age declarations | OQ-07 |
