# Testing Strategy: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Testing Strategy |
| File | `Documentation/TESTING_STRATEGY.md` |
| Phase | 4 — Testing, Release and Risk Management (document 30) |
| Version | 0.2 |
| Status | Draft for review. Not approved. Every test described here is PLANNED. None is implemented or executed. |
| Date | 23 October 2026 |
| Approval required | Both developers. MFW sees the results as test evidence under S2 AC-10. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft, including the proposed security checklist required by RS NFR-SEC-010 |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. SEC-CHK-17 to SEC-CHK-19 added (account-existence messages, removed admin, abuse and throttling). SEC-CHK-03 limited to the app's storage. Registration wording corrected. Test lines for breaking news and for a failed replacement. Section 16 added: protected files and offline copies, intended and tested. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `MFW_Statement_of_Work.pdf` (S2) AC-1 to AC-12, "How acceptance testing works" | Exists, issued, unsigned. Contractual criteria and severity definitions. |
| `REQUIREMENTS_SPECIFICATION.md` (RS) §10, §13 | Exists, draft. NFR-SEC-010 places the security checklist in this document. |
| `ACCEPTANCE_CRITERIA.md` | Exists (draft). Each acceptance row maps to a suite below. |
| `TEST_DATA_AND_FIXTURES.md` | Exists (draft). Fixtures FX-* used below. |
| `CI_CD_AND_QUALITY_GATES.md` | Exists (draft). Gates QG-* that run these suites. |
| `API_AND_MODULE_CONTRACTS.md`, `DEFINITION_OF_DONE.md`, `DEPLOYMENT_PLAN.md` | Exist (draft) |
| `OPEN_QUESTIONS.md`, `RISK_REGISTER.md` | Exist (draft) |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal. **PLANNED** means designed but not implemented. Availability labels ([NOW], [SCAFFOLD], [BACKEND], [CI], [DEVICES], [STORE]) are defined in `DEFINITION_OF_DONE.md` §3.

## 2. Purpose, Scope and Status

This strategy describes how the app, backend and admin panel will be tested against RS and the S2 acceptance criteria. It covers test levels, environments, devices, feature test plans, non-functional testing, the security checklist, defects, regression, ownership and traceability.

**Current status.** No application code, test code, CI or test environment exists (verified 23 October 2026). No test has been run, and this document reports no results.

## 3. Where Pass and Fail Thresholds Come From

| Threshold | Source | Status |
|---|---|---|
| First page of a downloaded sample issue within 3 seconds on the mid-range test phone | S2 AC-2; RS NFR-PERF-001 | CONFIRMED. S2 confirms the target at the end of Week 2, after tests on MFW's PDFs. |
| Text sharp at 300% pinch zoom | S2 AC-2; RS NFR-PERF-002 | CONFIRMED (judged by inspection) |
| Twenty consecutive page turns without a crash | S2 AC-2; RS NFR-REL-001 | CONFIRMED |
| No critical or high defect open when acceptance testing starts | S2 AC-10; RS NFR-REL-002 | CONFIRMED |
| Upload limit of 150 MB by default | S2 Flow 1; RS FR-ADMIN-007 | CONFIRMED. The boundary and unit are OQ-30. |
| Download speed, memory use, app start time, catalogue load time | None | **No threshold agreed.** Measured and reported only. |
| Code coverage | None | **No threshold agreed.** Reported only. |
| Accessibility values | `CODING_STANDARDS.md` §9 | PROPOSED (OQ-25) |

## 4. Test Levels

| Suite | Level | Scope | Candidate tooling | Owner | Available | Entry | Exit |
|---|---|---|---|---|---|---|---|
| TS-01 | Static checks | Formatting, analysis | `dart format`, `flutter analyze` | Each author | [SCAFFOLD] | Code changed | Zero errors and warnings |
| TS-02 | Unit | Domain logic, repositories with fakes, query filters, failure mapping, download state machine | `flutter_test` (Flutter SDK) | Module owner | [SCAFFOLD] | Module exists | All pass |
| TS-03 | Widget | Each screen in its loading, data, empty and error states; guards; forms | `flutter_test` | Module owner | [SCAFFOLD] | Screen exists | All pass |
| TS-04 | App integration | Cross-feature flows on an emulator or simulator with fake services | `integration_test` (Flutter SDK) | Flow owner | [SCAFFOLD] | Features merged | All pass |
| TS-05 | Backend and authorization rules | Each operation in `API_AND_MODULE_CONTRACTS.md` §8 for each access state, allowed and refused; upload validation; deletion cascade | Blocked by DEC-003 | WS-A | [BACKEND] | Backend skeleton | All pass |
| TS-06 | End to end | App on real devices against ENV-TEST | Manual and `integration_test` | WS-B coordinates | [BACKEND], [DEVICES] | Milestone build | Every related acceptance row recorded |
| TS-07 | Performance | AC-2 targets; measurement of large files | Manual timing or screen recording; profiling | WS-B | [DEVICES] | Reader merged; MFW PDFs available | Section 3 thresholds met |
| TS-08 | Security | Checklist in Section 9 | Manual, rule tests, secret scan | WS-A | [BACKEND] | Before acceptance testing | Every item recorded |
| TS-09 | Privacy | No personal data in logs or events; deletion; exports | Inspection and tests | WS-A | [BACKEND] | Feature complete | Every item recorded |
| TS-10 | Accessibility | Baseline in `CODING_STANDARDS.md` §9 | Platform accessibility inspectors; manual screen-reader pass | WS-B | [DEVICES] | Screens built | Baseline met, or deviations logged |
| TS-11 | Store pre-submission | `APP_STORE_RELEASE_CHECKLIST.md` | Manual | WS-A | [STORE] | Release candidate | Checklist complete |
| TS-12 | Acceptance testing (MFW) | S2 AC-1 to AC-12 | MFW's testers | MFW, supported by both developers | [DEVICES] | Section 12 entry criteria | MFW sign-off |
| TS-13 | Post-release smoke | Section 6 of `DEPLOYMENT_PLAN.md` | Manual | WS-A | [STORE] | Release live | Smoke checks pass |

## 5. Test Environments

| Environment | Purpose | Data | Status |
|---|---|---|---|
| ENV-LOCAL | Developer machines, emulators, simulators | Fakes and local fixtures | PLANNED [SCAFFOLD] |
| ENV-TEST | Non-production backend and admin panel in an MFW-owned project | Synthetic fixtures only (DEC-024) | PROPOSED (DEC-023). Blocked by DEC-003 and OQ-40. |
| ENV-PROD | Production | Real reader data. Testing limited to smoke tests with a designated test account (OQ-43). | PLANNED |
| WordPress | MFW's live site, read only | Real public posts | Site details: OQ-39. Never written to. |

If MFW does not approve a separate ENV-TEST (OQ-40), the plan for testing without production data must be agreed before T-01.4. Risk R17 and DEC-023 apply.

## 6. Device and Platform Coverage

S2 AC-10 fixes the device set to be agreed at M1: one low-cost and one mid-range Android phone, an older and a current iPhone, and a tablet where available.

| Slot | Model and OS version | Holder | Status |
|---|---|---|---|
| Android, low-cost | OPEN (OQ-26) | OPEN | Not agreed |
| Android, mid-range (the AC-2 performance phone) | OPEN (OQ-26) | OPEN | Not agreed |
| iPhone, older | OPEN (OQ-26) | OPEN | Not agreed |
| iPhone, current | OPEN (OQ-26) | OPEN | Not agreed |
| Tablet, where available (two-page spread, RS FR-READ-009) | OPEN (OQ-26) | OPEN | Not agreed |

Minimum supported OS versions are OQ-26. Emulators and simulators are used during development. Acceptance evidence comes from the agreed physical devices. Push notifications and performance are always checked on physical devices.

## 7. Feature Test Plans

Each plan lists what must be shown. The acceptance rows in `ACCEPTANCE_CRITERIA.md` give the steps.

### 7.1 Authentication and authorization

- Registration, verification email, sign-in, password reset, sign-out, account deletion (AC-3.1 to AC-3.7).
- The access matrix: every capability in `API_AND_MODULE_CONTRACTS.md` §4.1, tested for each fixture user FX-USR-01 to FX-USR-05 in the app (TS-03, TS-04) and on the server (TS-05).
- No guest reading: a logged-out visitor cannot open or download any issue content, including any sample (PAC-04).
- Direct requests for issue files are refused for every state below full access (AC-3.5, PAC-13, SEC-CHK-02).
- Sign-in and password reset show the same message for a known and an unknown address. Registration tells the visitor that an account exists for the address, by design. All three are rate limited. This is PROPOSED (`API_AND_MODULE_CONTRACTS.md` §6.3), and the identity provider's behaviour is NOT VERIFIED (SEC-CHK-17, SEC-CHK-19, PAC-17).

### 7.2 Google Sign-In and email verification

Subject to the account rules still open (OQ-04, OQ-05) and to scope confirmation (OQ-29, C-04).

- Register and sign in with Google on Android and iOS (PAC-01).
- A Google reader completes the mandatory profile before opening a full issue (PAC-02; timing OQ-03).
- The same email address used with both methods follows the rule decided under OQ-05 (PAC-12).
- Cancelling the Google flow returns to the sign-in screen without an error.
- **Blocked until decided:** how verification applies to Google accounts (OQ-04).

### 7.3 Magazine catalogue and search

- Catalogue shows the latest issue and four to six archive issues with cover, title, date and description (AC-1.1).
- Search by title, description and category; filters by category, year, edition and industry segment (AC-1.2, AC-1.3, PAC-07). Search covers metadata only (RS FR-SRCH-007).
- An issue published in the admin panel appears after pull-to-refresh, and an unpublished one disappears (AC-1.4, AC-8.7).
- Empty results show an explanatory state (RS FR-STATE-002).
- Logged-out visitors can browse, search and filter (PAC-04).

### 7.4 PDF rendering and page navigation

- MFW sample PDFs (FX-PDF-03) and the largest expected issue (FX-PDF-04) open and render.
- Swipe and tap page turns; page-turn effect and plain swipe mode (AC-2.2, AC-2.7; switching: OQ-14).
- Pinch zoom to 300% with sharp text (AC-2.3).
- Two-page spread on a tablet and in landscape (AC-2.4).
- Twenty consecutive page turns without a crash (AC-2.5).
- Damaged files (FX-PDF-10, FX-PDF-11) show an error with a retry option (AC-2.6).
- Opening a bookmark goes to its page (AC-5.1).
- First-page time measured as in Section 8.1 (AC-2.1).

### 7.5 Offline downloads

Network scenarios come from `TEST_DATA_AND_FIXTURES.md` §8 (FX-NET-01 to FX-NET-07).

| Scenario | Expected result | Reference |
|---|---|---|
| Size shown before the download starts | Size matches the file | AC-4.4 |
| Download on mobile data | Warning shown before the download starts | AC-4.5 |
| Progress | Visible and advancing | AC-4.1 |
| Network lost mid-download (FX-NET-01) | Status shows waiting; resumes from the same point when the network returns | AC-4.3 |
| Wi-Fi to mobile-data switch mid-download (FX-NET-02) | Behaviour agreed during WP-06. PROPOSED: pause and ask before continuing on mobile data. | AC-4.5 |
| App closed or killed mid-download (FX-NET-03) | Resumes or restarts without listing a partial file as downloaded. Background behaviour is decided in the WP-02 spike. | RS FR-STATE-004 |
| Grant expires mid-download (FX-NET-05) | A new grant is requested; the download continues from the same offset | DEC-020 |
| Device storage full (FX-NET-06) | Clear message; no partial file listed | RS FR-STATE-004 |
| Integrity check fails | `fileCorrupt` with a retry; the partial file is removed | `API_AND_MODULE_CONTRACTS.md` §6.6 |
| Airplane mode after a full download | The issue opens and reads in full | AC-4.2 |
| Delete from the Downloads screen | Storage used by the app drops by about the file size | AC-4.6, AC-4.7 |
| Sign-out, account deletion, or the issue unpublished | Behaviour decided under OQ-11 | PAC-14 |
| Near-limit file (FX-PDF-05) | Downloads, resumes and opens. Time and memory measured. | Risk R2 |

### 7.6 Bookmarks and favourites

- Add, open and remove a bookmark; mark and unmark a favourite (AC-5.1, AC-5.2).
- Items appear after signing in on a second device (AC-5.3).
- Reader A cannot see or change reader B's items, both in the app and through direct server calls (AC-5.4, SEC-CHK-05).
- Offline behaviour decided under OQ-10.

### 7.7 WordPress integration

- Fixture-driven tests with FX-WP-01 to FX-WP-13: normal pages, last page, empty category, missing image, embedded media, entity-encoded titles, out-of-range page, REST disabled, wrong route, server error, slow response, non-JSON response, hidden post.
- A live, read-only check against MFW's site, once its address is known (OQ-39).
- Only MFW-selected categories appear (RS INT-WP-003). Requests are paged (INT-WP-004).
- Articles already loaded stay readable offline, with a notice (AC-7.4).
- If the site cannot be reached, cached articles show with a message (RS FR-STATE-005).
- Post content is rendered without running scripts (SEC-CHK-15).

### 7.8 Notifications

- Explanation shown before the system permission prompt (AC-9.1).
- A category notification reaches only devices that opted in to that category (AC-9.2). Test with two devices holding different preferences.
- Tapping opens the linked issue or article, with access rules applied (AC-9.3, BR-005). Use payloads FX-NTF-01 to FX-NTF-08, including an issue that requires sign-in.
- The send log records each send (AC-9.4). Only admins can send (AC-9.5).
- Delivery time is recorded but never judged (AC-9.6; RS NFR-REL-003).
- A WordPress post marked as breaking in the admin panel is flagged in the app, and sending it as a breaking-news notification reaches opted-in devices (RS FR-ADMIN-014, FR-ADMIN-015; AC-9.7, PROPOSED).

### 7.9 Admin permissions and upload validation

- A wrong password and a non-admin account are refused (AC-8.1, AC-8.2), and admin operations called directly by a non-admin are refused on the server (SEC-CHK-06).
- Only if MFW approves two admin roles (PRC-01): the role matrix, role changes, the last-Super-Admin rule, the bootstrap step and the audit events are tested as ST-02 and ST-07 to ST-11 (`SECURITY_AND_ACCESS_CONTROL.md` section 14; PAC-18). None of this applies to the baseline.
- An admin whose role record is removed is refused on the next privileged call, including from a session opened before the removal (SEC-CHK-18, FX-ADM-08). How long a token stays valid is NOT VERIFIED.
- A replacement file that fails validation leaves the current revision in place (FX-ADM-09). Whether an issue can be deleted or replaced at all is OQ-21.
- A valid PDF and cover upload (AC-8.3).
- Rejections with a clear message (AC-8.4, AC-8.5; FX-PDF-06 to FX-PDF-09, FX-PDF-12, FX-PDF-13):
  - A renamed non-PDF
  - A file that starts like a PDF but is not one
  - A file over the limit
  - The boundary file (OQ-30)
  - A password-protected PDF (expected behaviour: OQ-30)
  - A zero-byte file
- Checks also run on the server (SEC-CHK-07).
- Categories, publishing, unpublishing and hidden posts show correctly in the app after a refresh (AC-8.6 to AC-8.8).
- CSV exports (AC-8.9, PAC-03): only approved fields; admin-only; formula-injection cells escaped (FX-ADM-07, SEC-CHK-12).

### 7.10 Sharing

The share sheet opens with the title and link (AC-6.1, AC-6.2). Issues link to the store listing and articles to the WordPress address (PAC-05). No file is ever attached (RS FR-SHR-006).

## 8. Non-Functional Testing

### 8.1 Performance

| Measurement | Method (PROPOSED; repetitions agreed with the T-02.3 reader test) | Threshold |
|---|---|---|
| First page of a downloaded sample | Screen recording from tapping Open to the first page fully drawn, on the mid-range test phone | 3 seconds or less (S2 AC-2) |
| Sharpness at 300% zoom | Tester inspection of agreed sample pages, on the test phone | Sharp text (S2 AC-2) |
| Page-turn stability | Twenty consecutive page turns, repeated on each test device | No crash (S2 AC-2) |
| Download of a near-limit file | Time and peak memory on Wi-Fi and on mobile data | Reported only |
| Opening the largest issue | Time and memory | Reported only |
| Catalogue and news load | Time to show content | Reported only |

### 8.2 Accessibility

Check the PROVISIONAL baseline in `CODING_STANDARDS.md` §9: semantic labels with TalkBack and VoiceOver; the largest system text size; touch-target size; contrast. Deviations are logged as defects, with severity agreed once OQ-25 is answered.

### 8.3 Privacy

| Check | Reference |
|---|---|
| Logs, crash reports and usage events contain no personal data, tokens or reading activity per reader. The term "personal data" is not defined for device and installation identifiers and the provider's behaviour is NOT VERIFIED; it is defined when the provider is chosen (DEC-028, OQ-23) | RS NFR-PRIV-003; PAC-09; SEC-CHK-10 |
| Only the approved profile fields are collected | RS NFR-PRIV-001 (OQ-01) |
| Account deletion removes the reader's data. The reader is absent from new exports. | RS FR-PRIV-003; PAC-06; SEC-CHK-11 |
| Consent is recorded as decided | RS FR-PRIV-001; PAC-08 (OQ-27) |
| Store privacy declarations match MFW's policy | S2 AC-11; AC-11.3 |
| Test evidence contains no real personal data | DEC-024 |

## 9. Security Checklist

RS NFR-SEC-010 places the contents of the S2 AC-10 security checklist in this document. The items below are PROPOSED. Both developers agree them, and MFW sees them as part of the test evidence. No item has been checked.

| ID | Check | Method | Reference |
|---|---|---|---|
| SEC-CHK-01 | All network traffic uses HTTPS; cleartext is disabled on both platforms | Configuration inspection; proxy observation | RS NFR-SEC-001 |
| SEC-CHK-02 | A request for an issue file is refused when signed out, unverified, profile incomplete, using another reader's grant, using an expired grant, or using a guessed storage path | TS-05 rule tests; manual requests | RS NFR-SEC-002; S2 AC-3; PAC-13 |
| SEC-CHK-03 | Issue PDFs are not publicly readable or listable in the app's storage, and no long-lived bearer link to a PDF is ever issued. This covers the app's copy only; the website's copy is outside the project (OQ-57) | Storage configuration inspection; grant inspection | RS NFR-SEC-003; DEC-009 |
| SEC-CHK-04 | Downloaded issues are only in app-private storage, not shared storage, and are excluded from device backups where applicable | Device file inspection | RS NFR-SEC-004; `CODING_STANDARDS.md` §8.2 |
| SEC-CHK-05 | A reader can read and change only their own bookmarks, favourites, profile and preferences | TS-05 rule tests with two readers | RS NFR-SEC-005, NFR-SEC-006 |
| SEC-CHK-06 | Every admin operation is refused on the server for non-admin accounts | TS-05 direct calls | RS NFR-SEC-007; FR-ADMIN-003 |
| SEC-CHK-07 | Upload validation is enforced on the server, not only in the admin interface | Direct upload attempts that bypass the interface | RS NFR-SEC-008 |
| SEC-CHK-08 | Admin sign-in refuses wrong passwords; the measures decided under OQ-20 are in place | Manual | RS FR-ADMIN-002, NFR-SEC-011 |
| SEC-CHK-09 | No secrets in the repository or in app builds, apart from public client identifiers | Secret scan (QG-11); build inspection | `CODING_STANDARDS.md` §13 |
| SEC-CHK-10 | No personal data, tokens or grant links in logs, crash reports or usage events | Log and event inspection during TS-06 | RS NFR-PRIV-003; `CODING_STANDARDS.md` §6.2 |
| SEC-CHK-11 | Account deletion removes the reader's data on the server | TS-05; PAC-06 | RS FR-PRIV-003 |
| SEC-CHK-12 | CSV exports are admin-only and escape formula-injection cells | TS-05; FX-ADM-07 | RS NFR-PRIV-004; `CODING_STANDARDS.md` §15 |
| SEC-CHK-13 | Dependencies reviewed: licences recorded and published advisories checked | `DEPENDENCY_REGISTER.md` review; QG-10 | RS NFR-MAINT-006 |
| SEC-CHK-14 | Developers reach MFW's accounts through role-based access, with no shared passwords | Account access review | RS NFR-SEC-012 |
| SEC-CHK-15 | WordPress content is rendered without running scripts, and external links open outside the app | TS-03 with FX-WP-05 | `CODING_STANDARDS.md` §7 |
| SEC-CHK-16 | Notification payloads contain no personal data, and tap routing re-checks access | Payload inspection; FX-NTF-07 | `API_AND_MODULE_CONTRACTS.md` §6.11 |
| SEC-CHK-17 | Sign-in and password-reset responses are the same for a known and an unknown address (the message and the error category). Registration may reveal that an account exists. Timing is not tested | TS-03 and TS-05 with FX-USR-13 | `API_AND_MODULE_CONTRACTS.md` §6.3; PAC-17 |
| SEC-CHK-18 | An admin whose role record is removed is refused on the next privileged call, including from a session opened before the removal. The time until the removal is visible to the check is measured and reported, not judged | TS-05 direct calls with FX-ADM-08 | RS NFR-SEC-007, FR-ADMIN-003; OQ-20 |
| SEC-CHK-19 | Sign-in, registration, password reset, file-link requests and notification sends are limited, and a limited request is refused with RATE_LIMITED. No limit value is set here, and the mechanism is OPEN | TS-05; manual repeated requests | `API_AND_BACKEND_CONTRACT.md` §2.7; OQ-52 |

An independent penetration test is out of scope (S2 "Scope not included").

## 10. Defect Management and Severity

Severity follows S2 "How acceptance testing works":

| Severity | Meaning [S2] | Handling (PROPOSED) |
|---|---|---|
| Critical | Stops the app working, or exposes data | Fix before any further feature work. Blocks M4 and acceptance. |
| High | A confirmed feature does not work and there is no workaround | Must be closed before acceptance testing starts (S2 AC-10) |
| Medium | A visible fault with a workaround | Fixed, or agreed in writing for the warranty period [S2] |
| Low | Cosmetic | Fixed, or agreed in writing for the warranty period [S2] |

Each defect records: ID, title, steps, expected result, actual result, severity, build, device and OS, the affected requirement or acceptance ID, owner and status. Where defects are tracked is PROPOSED as GitHub issues in the project repository, so that the record moves with the repository at handover. During acceptance testing, the developers reply to each item within one working day: a defect, a change request, or not reproducible [S2].

## 11. Regression Strategy

| Trigger | Regression run |
|---|---|
| Every pull request | TS-01, TS-02 and TS-03 for the whole app; TS-05 for changed rules [CI] |
| Every merge into `main` | TS-01 to TS-04 [CI] |
| Milestone builds (M3, M4) | TS-04, then TS-06 on at least one Android and one iOS device |
| Release candidate | TS-06 across the full device set, TS-07, TS-08, TS-09, TS-10, TS-11 |
| Bug fix | The reproducing test, plus the affected feature's suite (DoD-BUG) |
| Dependency or toolchain upgrade | The full automated suite, plus a reader and download smoke test on devices |

A test that fails intermittently is fixed or removed in a recorded pull request. It is never silently ignored.

## 12. Acceptance Testing Entry and Exit

**Entry** (PROPOSED internal checks, plus S2 AC-10):

- The release candidate meets DoD-RC items 1 to 4 (`DEFINITION_OF_DONE.md` §9).
- A test script is prepared from `ACCEPTANCE_CRITERIA.md`.
- The test build is delivered to MFW's testers [S2].

**Exit** [S2]:

- MFW tests for five working days and logs defects.
- The developers reply within one working day.
- MFW checks each fix within two working days.
- Acceptance is signed off when no critical or high defect is open.

## 13. Traceability and Evidence

```
RS requirement (RS §13) → ACCEPTANCE_CRITERIA.md row (AC-n.m or PAC-nn) → test suite (TS-nn) and case → evidence record
```

- Automated test names cite requirement IDs (`CODING_STANDARDS.md` §10).
- Manual test cases cite acceptance row IDs.
- **Evidence location (PROPOSED).** Test evidence reports go in `Documentation/test-evidence/`, created when testing starts. Large media (recordings) go in an MFW-approved location, linked from the report.
- The evidence forms in `DEFINITION_OF_DONE.md` §11 apply.

## 14. Ownership

| Area | Owner (PROPOSED, `TASK_OWNERSHIP_MATRIX.md`) |
|---|---|
| Test strategy upkeep and test coordination (S2 AC-10) | WS-B |
| Unit, widget and integration tests for a module | That module's owner |
| Backend rule tests, security checklist, privacy checks | WS-A |
| Device performance tests, accessibility | WS-B |
| Store pre-submission and post-release smoke tests | WS-A |
| Acceptance test script and the MFW test sessions | Both, with Sanika Attarde as MFW contact |

## 15. Blocked Items

| Item | Blocked by |
|---|---|
| TS-05 backend and rule tests | DEC-003, DEC-020 |
| ENV-TEST | DEC-023, OQ-40 |
| Device matrix | OQ-26 |
| Google account rules | OQ-04, OQ-05, OQ-29 |
| Reader performance on real content | MFW sample PDFs; DEC-005 |
| Upload boundary and the unit of "MB" | OQ-30 |
| Accessibility severity | OQ-25 |

## 16. Protected Files and Offline Copies: Intended and Tested

This table keeps the intended behaviour apart from what has been tested. Nothing in it has been tested, and nothing is guaranteed. A row changes only when a test has been run and its evidence recorded.

| Behaviour | Intended (PROPOSED) | Tested | Test that would show it |
|---|---|---|---|
| Issuing a link | A link is issued only after the access checks, for one object, read only and short lived (DEC-020, OP-11) | NOT TESTED | SEC-CHK-02, PAC-13 |
| Link expiry | The link expires after `signed_url_lifetime`. 60 minutes is an ASSUMPTION (AOQ-07) | NOT TESTED | FX-NET-05 (grant expires mid-download); the TD-09 proof plan for the length on slow connections |
| Refresh and signing in again | A new link is requested after expiry. If the sign-in has expired, the reader signs in again | NOT TESTED | FX-NET-05; PROPOSED new line: a download that outlives the sign-in |
| Interrupted download | The status shows waiting, and the download continues when the network returns | NOT TESTED | AC-4.3 with FX-NET-01 |
| Byte-range support | The file store honours byte ranges on the issued link | NOT VERIFIED (AR-01) | The TD-09 proof plan on a real Android device and a real iPhone |
| Resume | The download continues from its previous progress and not from zero (S2 AC-4) | NOT TESTED | AC-4.3 with FX-NET-01 and FX-PDF-05 |
| Storage-provider support | Signed links and byte ranges work with the provider that is chosen | NOT VERIFIED | The TD-09 proof plan (`TECHNOLOGY_DECISIONS.md`) |
| Unpublishing | The issue leaves the catalogue and no new link is issued | NOT TESTED | AC-8.7; SEC-CHK-02 |
| Links already issued | A link cannot be withdrawn before it expires (AR-06) | NOT TESTED | PROPOSED new line: unpublish while a link is live, and record what happens |
| Offline retention | Opening an issue keeps the full copy until the reader deletes it. This is the working position. MFW's answer is reported by YG and not filed (OQ-08) | NOT TESTED | AC-4.2 and AC-4.6 |
| Cache clean-up | Deleting a download frees its space, and no partial file is listed as downloaded | NOT TESTED | AC-4.6, AC-4.7; FX-NET-03; PROPOSED new line: stale partial files after an interrupted download |
| Sign-out | What happens to downloaded issues is decided under OQ-11 | NOT TESTED. The behaviour is OPEN | PAC-14 |
| Account deletion | Local user data is cleared. Downloaded issues behave as OQ-11 decides | NOT TESTED | IC-08; PAC-06 |
| Copies already on devices | A copy on a device cannot be recalled remotely. The app removes a copy only when the issue is on the deleted-issue list (OP-03) | NOT TESTED | PROPOSED new line: a deleted issue on the list, with the device online and offline |
