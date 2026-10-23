# Deployment Plan: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Deployment Plan |
| File | `Documentation/DEPLOYMENT_PLAN.md` |
| Phase | 4 — Testing, Release and Risk Management (document 34) |
| Version | 0.1 |
| Status | Draft for review. Not approved. **The architecture is not approved (DEC-003, DEC-004).** Component-specific steps are BLOCKED. Nothing has been deployed. |
| Date | 23 October 2026 |
| Prepared in | Sanika Attarde's Claude Code session, branch `SA` |
| Approval required | Both developers. MFW for environments and costs (DEC-023). |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `MFW_Statement_of_Work.pdf` (S2) "Proposed technical architecture", "Responsibilities", "Handover" | Exists, issued, unsigned. The architecture is a proposal. |
| `DECISION_LOG.md` | Exists, created in this task. DEC-003, DEC-004, DEC-020, DEC-021, DEC-023. |
| `CI_CD_AND_QUALITY_GATES.md`, `BACKUP_AND_RECOVERY.md`, `APP_STORE_RELEASE_CHECKLIST.md`, `MAINTENANCE_AND_HANDOVER.md` | Exist, created in this task |
| `API_AND_MODULE_CONTRACTS.md`, `TESTING_STRATEGY.md` | Exist, created in this task |
| `SYSTEM_ARCHITECTURE.md`, `CLOUD_INFRASTRUCTURE_AND_COSTS.md` | Planned (Phase 2). Not created. |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal.

## 2. Purpose, Scope and Status

This plan covers how the backend services, file storage, authentication, push notifications, admin panel, WordPress connection, monitoring and mobile apps will be deployed and verified. It also covers rollback and who is responsible for what.

This plan contains no credentials, resource names, project identifiers, URLs or infrastructure settings, because none has been decided or supplied. Every such item is OPEN in Section 12.

## 3. Architecture Status

| Component | S2 proposal | Status |
|---|---|---|
| Mobile apps | Flutter, one codebase | CONFIRMED (DEC-002) |
| Accounts | Firebase Authentication | PROVISIONAL (DEC-003) |
| Database | Cloud Firestore | PROVISIONAL (DEC-003) |
| File storage | Cloud Storage for Firebase | PROVISIONAL (DEC-003) |
| Server logic | Cloud Functions | PROVISIONAL (DEC-003) |
| Push | Firebase Cloud Messaging, through Apple's push service on iOS | Delivery through the platform push services is CONFIRMED (RS INT-PUSH-001). The provider is PROVISIONAL. |
| Admin panel | React web app on Firebase Hosting | PROVISIONAL (DEC-004) |
| News | WordPress REST API on MFW's site | CONFIRMED (RS INT-WP-001). Retrieval path: DEC-021. |
| Monitoring | Firebase Crashlytics and Analytics | Crash reporting and basic usage events are CONFIRMED (RS NFR-OBS-001, NFR-OBS-002). The provider is PROVISIONAL. |

S2 states that Cloud Storage and Cloud Functions need Firebase's pay-as-you-go plan, billed to MFW at actual use. This applies only if DEC-003 confirms Firebase.

## 4. Environments

PROPOSED (DEC-023). Needs MFW's approval, because a second cloud project may add cost billed to MFW.

| Environment | Purpose | Owner of the account | Data | Status |
|---|---|---|---|---|
| ENV-LOCAL | Development on the developers' machines, with emulators, simulators and fakes | Developers | Synthetic fixtures | PLANNED |
| ENV-TEST | Integration, end-to-end and acceptance testing | MFW, as a separate non-production project | Synthetic fixtures only (DEC-024) | PROPOSED. Needs MFW's approval (OQ-40). |
| ENV-PROD | The live service | MFW (S2 Responsibilities) | Real readers and content | PLANNED |

If MFW provides only one project, the team and MFW must agree in writing how testing avoids production data before T-01.4. Risk R17 applies.

## 5. Configuration and Secret Management

### 5.1 Rules

1. No secret in the repository (`CODING_STANDARDS.md` §13).
2. Each environment has its own configuration. The app selects it at build time, using `--dart-define` style configuration (PROPOSED).
3. Server-side secrets live in the provider's secret store in MFW's account.
4. Developers use role-based access, never shared passwords (RS NFR-SEC-012).
5. Every credential holder is recorded at handover. The record names holders, never values (S2 Handover).

### 5.2 Configuration items

| ID | Item | Value | Status |
|---|---|---|---|
| CFG-01 | Backend project identifiers for ENV-TEST and ENV-PROD | — | OPEN (DEC-003, OQ-40) |
| CFG-02 | Cloud region | — | OPEN (OQ-41) |
| CFG-03 | WordPress site address | — | OPEN (OQ-39) |
| CFG-04 | WordPress categories shown in the app | — | OPEN (RS INT-WP-003; MFW input) |
| CFG-05 | Upload size limit | 150 MB by default (RS FR-ADMIN-007) | Boundary and unit: OQ-30 |
| CFG-06 | Issue-file grant lifetime | — | OPEN (OQ-37) |
| CFG-07 | Privacy policy and terms-of-use addresses | — | MFW input (CH §12) |
| CFG-08 | Store links used for sharing | — | OPEN (OQ-15) |
| CFG-09 | Google Sign-In client configuration (Android package name and signing-certificate fingerprints; iOS bundle ID and URL scheme) | — | OPEN (DEC-006, OQ-42) |
| CFG-10 | iOS push credential in MFW's Apple Developer account | — | OPEN |
| CFG-11 | Crash-reporting and usage-event configuration | — | OPEN (DEC-003, OQ-23) |
| CFG-12 | Admin panel address; optional custom domain at MFW's cost [S1 Costs outside the fee] | — | OPEN |
| CFG-13 | Notification categories | — | OPEN (OQ-18) |
| CFG-14 | Admin accounts | — | MFW's admin list (CH §12); OQ-20 |
| CFG-15 | App name and identifiers (Android application ID, iOS bundle ID) | — | OPEN (OQ-42) |

## 6. Verification and Smoke Tests

Run after every deployment. The results are recorded as evidence (`DEFINITION_OF_DONE.md` §11).

| ID | Check | ENV-TEST | ENV-PROD |
|---|---|---|---|
| SM-01 | The app launches, and a signed-out user sees the published catalogue | Yes | Yes |
| SM-02 | The news list loads from WordPress | Yes | Yes |
| SM-03 | Sign-in works: a fixture account in test; the store-review demo account (OQ-43) in production | Yes | Yes, if approved |
| SM-04 | A full-access reader downloads a small issue, opens it, and opens it again offline | Yes | Demo account only, if approved |
| SM-05 | Signed out, opening an issue shows a prompt, and a direct file request is refused | Yes | Yes (refusal only) |
| SM-06 | A bookmark and a favourite are saved and reloaded | Yes | Demo account only, if approved |
| SM-07 | Admin sign-in works, and a non-admin is refused | Yes | Yes |
| SM-08 | Admin uploads FX-PDF-01, publishes it, then unpublishes it | Yes | No. MFW handles production content. |
| SM-09 | A notification reaches a test device | Yes | Only with MFW's agreement, and only to a test device (method OPEN) |
| SM-10 | Crash reporting receives a test event | Yes | No |
| SM-11 | The deployed backend and access-rule versions match the release tag | Yes | Yes |
| SM-12 | Deleting a test account removes its data | Yes | No |

## 7. Component Deployment

### 7.1 Backend services

BLOCKED by DEC-003. PROPOSED principles: deploy from a release tag only; access rules and server logic are versioned in `backend/`; deploy to ENV-TEST first, then ENV-PROD; a backend release must keep the app version in the stores working (`API_AND_MODULE_CONTRACTS.md` §4.5).

### 7.2 Database and file storage

BLOCKED by DEC-003 and `DATABASE_DESIGN.md` (planned). Fixed requirements:

- Issue PDFs are stored privately, with no public listing or reading (RS NFR-SEC-003; DEC-009).
- Access rules deny by default and are deployed with tests (QG-08).
- Backup is configured before the first production data exists (`BACKUP_AND_RECOVERY.md`).
- There is no CDN at launch (RS ASM-15). Adding one is an architecture decision needing MFW's approval for cost.

### 7.3 Authentication provider

BLOCKED by DEC-003. Set up in MFW's account:

- Email and password with verification and reset (RS INT-AUTH-001).
- Google Sign-In for Android and iOS (RS INT-AUTH-002, PROVISIONAL). This needs CFG-09 and the app identifiers (OQ-42).
- The admin role (RS DATA-011).

Sign in with Apple is not configured (excluded; risk R9).

### 7.4 Push notifications

The iOS push credential is created in MFW's Apple Developer account (RS INT-PUSH-002), which must be active first. S1 expects it by the end of Week 4. The provider is BLOCKED by DEC-003. The Android side follows the chosen provider.

### 7.5 Admin panel

BLOCKED by DEC-004. Deployed from a release tag to MFW-owned hosting. A custom domain is optional and at MFW's cost (S1). The first admin accounts are created from MFW's admin list (CH §12; OQ-20).

### 7.6 WordPress integration

Nothing is deployed to WordPress, and the site is not changed (RS INT-WP-002). The app needs CFG-03 and CFG-04. Before release:

1. Confirm the REST API is reachable over HTTPS (RS ASM-03).
2. Confirm that no security plugin or firewall blocks the app's requests (FX-WP-08 scenario).
3. Confirm the categories with MFW.

### 7.7 Logging and monitoring

Crash reporting for Android and iOS goes to a service on MFW's accounts (RS NFR-OBS-001). The provider is BLOCKED by DEC-003. Usage events come only from the approved list (OQ-23). Who at MFW receives alerts is OQ-47.

### 7.8 Mobile apps

Built and signed from the release tag (`CI_CD_AND_QUALITY_GATES.md` §6). Uploaded and submitted through MFW's store accounts, following `APP_STORE_RELEASE_CHECKLIST.md`.

## 8. Release Sequencing

PROPOSED order for the first production release:

1. Release candidate tagged after DoD-RC items 1 to 4.
2. Backend and access rules deployed to ENV-TEST from the tag. SM-01 to SM-12 pass.
3. Acceptance testing by MFW (TS-12).
4. Production backup configuration confirmed (`BACKUP_AND_RECOVERY.md`).
5. Backend and access rules deployed to ENV-PROD from the approved tag. Both developers approve, and MFW is informed.
6. Admin panel deployed to ENV-PROD.
7. MFW enters the launch content in the production admin panel (S2: MFW enters production content).
8. Production smoke tests SM-01, SM-02, SM-05, SM-07 and SM-11.
9. Signed app builds from the same tag, uploaded to the store testing tracks, then a final check on devices.
10. MFW approves the listing text and the build. Submission (S2 M5).
11. After the stores release the app: post-release smoke tests on the store builds (TS-13), and crash monitoring.

## 9. Rollback and Recovery

| Component | Rollback approach (PROPOSED) |
|---|---|
| Backend logic | Redeploy the previous release tag. The method follows DEC-003. |
| Access rules | Redeploy the previous rules version. Rule changes are released as their own step. |
| Data | Changes move forward only. Before any data migration, take a backup and restore if needed, as in `BACKUP_AND_RECOVERY.md`. |
| Admin panel | Redeploy the previous build |
| Mobile apps | Installed versions cannot be rolled back. If staged or phased release is in use, halt the Google Play staged rollout or pause the App Store phased release, then fix forward and resubmit. An expedited Apple review can be requested, but is not guaranteed. |
| WordPress | Not deployed by the project. If MFW's site fails, the app shows cached articles (RS FR-STATE-005). |

## 10. Responsibility Boundaries

| Party | Responsible for |
|---|---|
| MFW | Owning and paying for the cloud projects, Apple and Google accounts and any domain; granting role-based access; production content; privacy policy and terms; approvals; holding credentials (S2 Responsibilities; AC-12) |
| Development team | Configuring and deploying the backend, admin panel and apps on MFW's accounts; smoke tests; deployment documentation (S2 "I will"). Proposed lead: WS-A, with WS-B for app builds. |
| Google, Apple, MFW's WordPress host | Platform services, store review and push delivery. Their outages are not product defects (S2 Warranty). |

## 11. Handover

Deployment knowledge is handed over through:

- The deployment steps in the technical documentation (S2 Handover)
- This plan, updated with the actual configuration names, never secret values
- The credential-holder record
- A clean-copy rebuild into a fresh project (AC-12.2)

Details are in `MAINTENANCE_AND_HANDOVER.md`. The developers' access is removed when MFW asks after handover (S2 Handover).

## 12. Open Inputs

| Input | Needed for | Reference |
|---|---|---|
| Cloud project(s) in MFW's name with billing; environment decision | ENV-TEST, ENV-PROD | DEC-023, OQ-40; CH §12 inputs |
| Backend and admin technology | Sections 7.1 to 7.5 | DEC-003, DEC-004, OQ-35 |
| Cloud region | CFG-02 | OQ-41 |
| WordPress site address and categories | CFG-03, CFG-04 | OQ-39 |
| App identifiers; Apple and Google accounts | CFG-09, CFG-10, CFG-15 | OQ-42 |
| Store-review demo account | SM-03 in production | OQ-43 |
| Alert recipients at MFW | Section 7.7 | OQ-47 |
| Backup expectations | Release step 4 | OQ-46 |
