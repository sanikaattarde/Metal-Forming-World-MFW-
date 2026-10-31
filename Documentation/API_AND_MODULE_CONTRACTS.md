# API and Module Contracts: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | API and Module Contracts |
| File | `Documentation/API_AND_MODULE_CONTRACTS.md` |
| Phase | 3 — Development Planning and Collaboration (document 24) |
| Version | 0.6 |
| Status | Draft for review. Not approved. Every contract is PROPOSED. Backend parts depend on OPEN decisions. |
| Date | 30 October 2026 |
| Approval required | Both developers. Changes follow Section 12. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft. 14 modules, 31 backend operations, 8 integration contracts. |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. Section 8 gains a column with the main identifier in `API_AND_BACKEND_CONTRACT.md` and notes on OP-ADM-11, OP-ADM-12 and OP-ACC-01. Section 4.2 error table gains the category and reason, with GONE and RATE_LIMITED added. Registration and sign-in messages stated. Compatibility and paging requirements added (4.5). Guest-reading rule labelled as a working position. Planned names replaced by the existing documents. |
| 0.3 | 25 October 2026 | The related-documents row for `PDF_READER_AND_OFFLINE_DESIGN.md` now says the draft exists. No contract changed. |
| 0.4 | 27 October 2026 | Positions from the questioning session of 26 and 27 October 2026 applied (Technology Decisions section 10.5). MOD-06 notes the two reading actions (Read is temporary, Download is kept) and foreground-only downloads. MOD-12 notes in-panel add and remove of admins, which has no alias. The edition-update sign-up (OP-EML-01, OP-ADM-10) is dropped on the working position. OP-13 and the grace window are withdrawn. The catalogue keeps its 31 identifiers. No decision is approved. |
| 0.5 | 30 October 2026 | Two fixes from the design-draft review (findings F-01 and F-02). `IssueSummary` holds a list of industry segment identifiers, and `IssueQuery` filters on one segment identifier (`industrySegment` is renamed in both). `DownloadedIssue` and `IssueFileGrant` gain the owner and revision fields that `DATABASE_AND_DATA_MODEL.md` section 7.1 and `PDF_READER_AND_OFFLINE_DESIGN.md` sections 4.3 and 5 already require, and section 6.6 gains behaviour rules 7 and 8. No code exists yet, so nothing is broken by the renames. No decision is approved. |
| 0.6 | 30 October 2026 | The bookmark contract carries the file revision, as the review of pull request #7 found. `Bookmark` gains `fileRevision`, `addBookmark` takes `(issueId, page, fileRevision)`, and the `OP-LIB-02` row adds `fileRevision` to its inputs. `DATABASE_AND_DATA_MODEL.md` section 4.10, OP-07 in `API_AND_BACKEND_CONTRACT.md`, `PDF_READER_AND_OFFLINE_DESIGN.md` sections 5 and 7, and GS-Q16 already require it. Section 6.8 gains behaviour rules 1 to 4. They record that a bookmark stays unique on the reader, the issue and the page, without the revision, that its identifier is derived from the issue and the page, and that a repeated add changes nothing and returns the stored bookmark. Rules 1 and 2 follow Sanika Attarde's review of pull request #9. That key is a working position of YG. It is PROPOSED and not agreed by both developers. No code exists yet. No decision is approved. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `REQUIREMENTS_SPECIFICATION.md` (RS) | Exists, draft. Source of every requirement ID below. |
| `DECISION_LOG.md` | Exists (draft). DEC-003, DEC-007, DEC-008, DEC-009, DEC-020, DEC-021, DEC-026. |
| `CODING_STANDARDS.md` | Exists (draft). Project structure and error-handling rules. |
| `TASK_OWNERSHIP_MATRIX.md` | Exists (draft). Module owners. The document map is in section 13. |
| `ACCEPTANCE_CRITERIA.md`, `TESTING_STRATEGY.md`, `TEST_DATA_AND_FIXTURES.md` | Exist (draft) |
| `SYSTEM_ARCHITECTURE.md`, `TECHNOLOGY_DECISIONS.md`, `DATABASE_AND_DATA_MODEL.md`, `API_AND_BACKEND_CONTRACT.md`, `SECURITY_AND_ACCESS_CONTROL.md` | Exist on `main` (drafts, merged by pull request #2). They were planned as `SYSTEM_ARCHITECTURE.md`, `TECH_STACK_DECISIONS.md`, `DATABASE_DESIGN.md`, `API_SPECIFICATION.md` and `AUTHENTICATION_AND_AUTHORIZATION.md`. `API_AND_BACKEND_CONTRACT.md` is the single catalogue of backend operations (section 8 below holds aliases of its identifiers). These contracts are not yet reconciled line by line with those documents; the differences are listed in `API_AND_BACKEND_CONTRACT.md` section 3.4. |
| `PDF_READER_AND_OFFLINE_DESIGN.md` | Exists (draft, version 0.1, dated 24 October 2026). The device-side lifecycle of a downloaded issue. It follows the `DownloadStatus` types in section 6.6 below and adds the removal paths. |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal in this document. In RS terms it is an ASSUMPTION (DEV).

## 2. Purpose, Scope and Status

This document sets the boundaries between modules and the contracts each module offers, so that two developers can build in parallel against agreed interfaces.

**What is fixed and what is not**

| Content | Status |
|---|---|
| Module boundaries and responsibilities | PROPOSED |
| App-side interfaces, written in Dart because Flutter is CONFIRMED (DEC-002) | PROPOSED shapes. Names and parameters may change by agreement (Section 12). |
| Backend operations (Section 8) | Technology-neutral capability contracts. **Not** a REST API, database schema or Firebase configuration. The transport is decided under DEC-003. |
| Provider-specific notes | Labelled "PROVISIONAL example". They are not decisions. |

**Rules these contracts preserve**

- Full issues can be opened or downloaded only by a reader with full access. There is no guest reading (DEC-007, working position, PROVISIONAL until MFW confirms it in writing).
- Issue files are released only after a server-side check, never through a public or guessable address (DEC-009, baseline). This covers the app's copy only. The same issues are publicly downloadable from MFW's website, and MFW has not decided whether that stays (OQ-57).

## 3. Module Map

Workstreams and the proposed developer mapping are in `TASK_OWNERSHIP_MATRIX.md` (DEC-011, PROPOSED): WS-A Platform and Publishing (proposed: Sanika Attarde); WS-B Reader Experience (proposed: Yuvraj).

| ID | Module | Workstream | App path (`CODING_STANDARDS.md` §3) | Backend part | Main requirements |
|---|---|---|---|---|---|
| MOD-00 | Shared domain models and interfaces | Joint | `app/lib/contracts/` | Shapes used by Section 8 | RS §7.1 |
| MOD-01 | App shell, navigation and platform services | WS-B | `app/lib/main.dart`, `app/lib/app/`, `app/lib/core/config/`, `app/lib/core/network/` | None | FR-MAG-006, NFR-UX-001, BR-005 |
| MOD-02 | Errors, logging and monitoring | WS-A | `app/lib/core/errors/`, `app/lib/core/logging/` | Server log rules | FR-STATE-001 to 007, NFR-OBS-001, NFR-OBS-002, NFR-PRIV-003 |
| MOD-03 | Authentication and account lifecycle | WS-A | `app/lib/features/auth/` | Identity provider configuration | FR-AUTH-001 to 010 |
| MOD-04 | Profile, settings and consent | WS-A | `app/lib/features/profile/` | OP-PRF-* | FR-PROF-001 to 007, FR-PRIV-001 to 004 |
| MOD-05 | Catalogue, search and home | WS-B | `app/lib/features/catalogue/` | OP-CAT-* | FR-MAG-001 to 009, FR-SRCH-001 to 007 |
| MOD-06 | Issue access and downloads | WS-B (app); WS-A (OP-FILE-01) | `app/lib/features/downloads/` | OP-FILE-01 | FR-DL-001 to 010, FR-READ-002 |
| MOD-07 | Reader | WS-B | `app/lib/features/reader/` | None | FR-READ-001 to 010, NFR-PERF-001, NFR-PERF-002, NFR-REL-001 |
| MOD-08 | Bookmarks and favourites | WS-B (app); WS-A (rules) | `app/lib/features/library/` | OP-LIB-* | FR-BKM-001 to 008 |
| MOD-09 | News from WordPress | WS-B | `app/lib/features/news/` | OP-NWS-01 | FR-NEWS-001 to 009, INT-WP-001 to 005 |
| MOD-10 | Sharing | WS-B | `app/lib/features/sharing/` | None | FR-SHR-001 to 006 |
| MOD-11 | Notifications | WS-A | `app/lib/features/notifications/` | OP-NTF-*, dispatch in OP-ADM-06 | FR-NOTIF-001 to 007 |
| MOD-12 | Admin and content management | WS-A | None (`admin/`, blocked by DEC-004) | OP-ADM-* | FR-ADMIN-001 to 019, FR-USER-001 to 005 |
| MOD-13 | Backend authorization, data rules and account deletion | WS-A | None (`backend/`, blocked by DEC-003) | Access rules for every operation; OP-ACC-01 | NFR-SEC-002 to 008, FR-PRIV-003 |

## 4. Cross-Cutting Conventions

### 4.1 Access states

```dart
/// Access state of the current user, derived from RS §3.2 and §9.2.
enum AccessState {
  signedOut,         // Logged-out visitor
  emailUnverified,   // Email account whose address is not verified (RS BR-002)
  profileIncomplete, // Mandatory profile not complete (RS BR-003, PROVISIONAL)
  fullAccess,        // May open and download full issues
}
```

States are evaluated in the order listed: the first one that applies is the state. Whether `emailUnverified` can apply to a Google account is OQ-04.

| Capability (RS §9.2) | signedOut | emailUnverified | profileIncomplete | fullAccess |
|---|---|---|---|---|
| Browse catalogue, issue details, search and filters | Yes | Yes | Yes | Yes |
| News list and articles, including cached articles offline | Yes | Yes | Yes | Yes |
| Open a full issue (OP-FILE-01) | No | No | No (PROVISIONAL) | Yes |
| Download an issue (OP-FILE-01) | No | No | No (PROVISIONAL) | Yes |
| Bookmark pages | No | No | No | Yes |
| Favourite issues | No | OPEN (OQ-12) | OPEN (OQ-12) | Yes |
| Share | OPEN (OQ-09) | Yes (ASSUMPTION) | Yes (ASSUMPTION) | Yes |
| Notifications and preferences | OPEN (OQ-09) | Yes (ASSUMPTION) | Yes (ASSUMPTION) | Yes |
| View and update own profile; delete own account | No | Yes | Yes | Yes |

### 4.2 Results and errors

```dart
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final AppFailure failure;
}

enum FailureCode {
  unauthenticated, emailNotVerified, profileIncomplete, forbidden, notFound,
  invalidInput, fileTooLarge, notAPdf, fileCorrupt, insufficientStorage,
  network, timeout, serviceUnavailable, invalidResponse, conflict, cancelled,
  unknown,
}

final class AppFailure {
  const AppFailure(this.code, {this.retryable = false, this.detail});
  final FailureCode code;
  final bool retryable;

  /// Diagnostic text for logs only. Never shown to users. Never contains personal data.
  final String? detail;
}
```

**Backend error codes** (transport-neutral names) map to app codes as follows. The backend reports a category and a reason code (`API_AND_BACKEND_CONTRACT.md` section 2.5). A name that was a top-level code in earlier text is now a reason under a category, as the second column shows. The scheme is PROPOSED. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed.

| Backend code | Category and reason | `FailureCode` | Retryable | User-facing meaning (wording set in the M2 designs) |
|---|---|---|---|---|
| `UNAUTHENTICATED` | UNAUTHENTICATED | `unauthenticated` | No | Sign in to continue |
| `EMAIL_NOT_VERIFIED` | FAILED_PRECONDITION, reason EMAIL_NOT_VERIFIED | `emailNotVerified` | No | Verify your email address |
| `PROFILE_INCOMPLETE` | FAILED_PRECONDITION, reason PROFILE_INCOMPLETE | `profileIncomplete` | No | Complete your profile |
| `FORBIDDEN` | FORBIDDEN | `forbidden` | No | You do not have access |
| `NOT_FOUND` | NOT_FOUND | `notFound` | No | No longer available |
| `INVALID_ARGUMENT` | INVALID_ARGUMENT | `invalidInput` | No | Check the highlighted fields |
| `FILE_TOO_LARGE` | Upload-job reason OVER_LIMIT (a request-level problem is INVALID_ARGUMENT) | `fileTooLarge` | No | File is larger than the limit (admin) |
| `NOT_A_PDF` | Upload-job reason NOT_A_PDF | `notAPdf` | No | File is not a valid PDF (admin) |
| `CONFLICT` | CONFLICT | `conflict` | No | Already exists, or in use |
| `UNAVAILABLE` | UNAVAILABLE | `serviceUnavailable` | Yes | Service unavailable, try again |
| `DEADLINE_EXCEEDED` | UNAVAILABLE, reason DEADLINE_EXCEEDED | `timeout` | Yes | Taking too long, try again |
| `INTERNAL` | INTERNAL | `unknown` | Yes | Something went wrong |
| `GONE` (added) | GONE: the issue was permanently deleted | Not mapped yet (open) | No | No longer available |
| `RATE_LIMITED` (added) | RATE_LIMITED: a rate or size limit | Not mapped yet (open) | Yes, after the retry-after value (PROPOSED) | Too many requests, try again later |

The retryable flag belongs to the category, with the exceptions listed above. In section 8, a code that the table shows as a reason (`EMAIL_NOT_VERIFIED`, `PROFILE_INCOMPLETE`, `FILE_TOO_LARGE`, `NOT_A_PDF`, `DEADLINE_EXCEEDED`) is read as that category and reason. No rate-limit value is set.

`network`, `insufficientStorage`, `fileCorrupt`, `invalidResponse` and `cancelled` arise on the device.

PROVISIONAL example: if DEC-003 chooses Firebase callable functions, the backend codes above can travel in the error details, alongside the platform's own codes.

### 4.3 Identifiers and data formats

| Item | Convention |
|---|---|
| IDs | Opaque strings. Never parsed and never used to build file paths for protected content. |
| Timestamps | ISO 8601 with offset in transport. Held in UTC. |
| Publication date | Calendar date (`YYYY-MM-DD`) |
| File sizes | Whole bytes |
| Page numbers | Start at 1 in every contract |
| Text | UTF-8 |

### 4.4 Authorization principle

1. The server is the authority for every rule in Section 4.1. App checks only shape the user experience.
2. Every operation in Section 8 states its authorization rule, and MOD-13 enforces it.
3. Readers can read and change only their own records (RS NFR-SEC-005, NFR-SEC-006).
4. Admin operations check the admin role on the server (RS FR-ADMIN-003, NFR-SEC-007). The check reads the current role record on each call and refuses if it cannot. The intended guarantee is that a removed admin is refused once the removal is visible to the check. How long a token stays valid and whether a read made right after the change always sees it are NOT VERIFIED. A test for a removed admin is proposed (`TESTING_STRATEGY.md` section 9). The first admin is a named step (`DEPLOYMENT_PLAN.md` section 7.5).
5. Issue-file access follows DEC-009. A request without a valid grant is refused, whatever address it uses.

### 4.5 Contract changes and compatibility

1. Changes to `app/lib/contracts/` or to Section 8 follow the shared-file protocol (`DEVELOPMENT_WORKFLOW.md` §8) and Section 12 of this document.
2. Prefer additive changes. A breaking change needs a `DECISION_LOG.md` entry agreed by both developers.
3. After the first store release, the backend must keep working for the app version in the stores: keep old fields until no supported version needs them, and accept unknown fields.
4. The fuller policy is PROPOSED in `API_AND_BACKEND_CONTRACT.md` section 9: backward compatibility by default; an impact assessment and a compatibility record for any breaking change; a migration and rollout plan with rollback; deprecation criteria; contract tests (section 10 there); and, only if MFW agrees, a minimum supported app version (the update gate, PRC-04). No version scheme and no compatibility period is set.
5. Three technology-neutral requirements (PROPOSED): admin lists page with a cursor (`page_size` and `cursor`, the largest size OPEN); a write operation carries a request identifier that makes a retry harmless; an issue file or cover is uploaded to a holding area, validated by the backend after the upload, and only then moved (`API_AND_BACKEND_CONTRACT.md` OP-19 and OP-40).

### 4.6 Logging and privacy in contracts

- No contract carries personal data into logs (`CODING_STANDARDS.md` §6.2).
- Notification payloads carry no personal data (MOD-11).
- Usage events never record which reader opened which issue or page (RS NFR-PRIV-003).

## 5. MOD-00 Shared Domain Models

These are conceptual shapes for interfaces, not a database schema. `DATABASE_AND_DATA_MODEL.md` (draft; planned as `DATABASE_DESIGN.md`) defines storage.

| Model | Fields (conceptual) | Source | Status | Written by |
|---|---|---|---|---|
| `IssueSummary` | `issueId`, `title`, `description`, `categoryId`, `industrySegmentIds` (a list), `publicationDate`, `year`, `edition`, `coverImage`, `fileSizeBytes` | RS DATA-001, FR-MAG-002 | CONFIRMED fields. Which fields are public is OQ-13. An issue can carry several segments (OQ-13 working position; `DATABASE_AND_DATA_MODEL.md` section 4.5), so this field is a list. | MOD-12 |
| `IssueCategory` | `categoryId`, `name` | RS DATA-002 | CONFIRMED | MOD-12 |
| `AuthSession` | `userId`, `method` (email or Google), `emailVerified` | RS DATA-003 | CONFIRMED (Google: PROVISIONAL) | MOD-03 |
| `ReaderProfile` | `name`, `age`, `gender`, `occupation`, `domainOfWork`, further fields | RS DATA-004, §7.2 | PROVISIONAL. Field list OQ-01, age format OQ-02. | MOD-04 |
| `ConsentRecord` | What was agreed, and when | RS DATA-012 | ASSUMPTION (OQ-27) | MOD-04 |
| `Bookmark` | `bookmarkId`, `issueId`, `page`, `fileRevision` (the revision of the file the reader was reading), `createdAt` | RS DATA-005; `DATABASE_AND_DATA_MODEL.md` section 4.10 | CONFIRMED fields, except `fileRevision`, which is PROPOSED. RS DATA-005 names the reader, the issue and the page. The revision comes from the data model (section 4.10), OP-07 and GS-Q16. See section 6.8, rules 1 to 4. | MOD-08 |
| `Favourite` | `issueId`, `createdAt` | RS DATA-006 | CONFIRMED | MOD-08 |
| `NewsPost` | `postId`, `title`, `contentHtml`, `imageUrl`, `publishedAt`, `categoryIds`, `link`, `isBreaking` | RS INT-WP-005, DATA-015 | CONFIRMED (`isBreaking` presentation: OQ-17) | WordPress, plus MOD-12 controls |
| `NewsControl` | `postId`, `hidden`, `breaking` | RS DATA-009 | CONFIRMED | MOD-12 |
| `NotificationPreferences` | `optedIn`, `categoryIds` | RS DATA-007 | CONFIRMED (categories: OQ-18) | MOD-11 |
| `NotificationTarget` | `type` (`issue` or `article`), `targetId` | RS FR-NOTIF-005 | CONFIRMED | MOD-11 |
| `NotificationSendRecord` | `sendId`, `sentAt`, `category`, `target` | RS DATA-008 | CONFIRMED (fields: OQ-19) | MOD-12 |
| `IssueFileGrant` | `issueId`, opaque access descriptor, `expiresAt`, `sizeBytes`, `contentHash`, `revision` (the file revision the grant is for; OP-11 returns it, `API_AND_BACKEND_CONTRACT.md` section 4.2) | DEC-020 | PROPOSED | MOD-13 |
| `DownloadedIssue` (device only) | `issueId`, `ownerUserId` (the reader who downloaded it), `fileRevision` (the revision downloaded), local file reference, `sizeBytes`, `downloadedAt`, `contentHash`, `retention` (kept or temporary; proposed, GS-Q43) | RS DATA-013 | CONFIRMED (behaviour after sign-out: OQ-11). The owner and revision fields match the file registry in `DATABASE_AND_DATA_MODEL.md` section 7.1. There is no `state` field: a `DownloadedIssue` exists only for a complete, verified copy (section 6.6 rule 4). | MOD-06 |
| `RegisteredUserRow` (admin) | Email, profile fields, registration date | RS FR-USER-002 | PROVISIONAL | MOD-12 (reads MOD-04 data) |
| `EditionUpdateSubscription` | Email, opted in | RS DATA-010 | CONFLICT C-02 (OQ-31) | MOD-04 |

```dart
/// Public issue metadata. Never contains a file location.
final class IssueSummary {
  const IssueSummary({
    required this.issueId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.publicationDate,
    required this.year,
    this.industrySegmentIds = const [],
    this.edition,
    this.coverImageUrl,
    this.fileSizeBytes,
  });

  final String issueId;
  final String title;
  final String description;
  final String categoryId;
  final DateTime publicationDate;
  final int year;
  final List<String> industrySegmentIds; // several per issue; meaning of "industry segment": OQ-13
  final String? edition;         // meaning: OQ-13
  final Uri? coverImageUrl;
  final int? fileSizeBytes;      // shown before sign-in? OQ-13
}

/// Short-lived permission to fetch one issue file (DEC-020, PROPOSED).
final class IssueFileGrant {
  const IssueFileGrant({
    required this.issueId,
    required this.access,
    required this.expiresAt,
    required this.sizeBytes,
    required this.contentHash,
    required this.revision,
  });

  final String issueId;
  final Object access;        // opaque; shape set by DEC-020
  final DateTime expiresAt;
  final int sizeBytes;
  final String contentHash;   // for integrity checking after download
  final int revision;         // file revision this grant is for; stored with the copy as fileRevision
}
```

## 6. App Modules

### 6.1 MOD-01 App shell, navigation and platform services

| Field | Detail |
|---|---|
| Purpose | Start the app, wire dependencies, apply MFW branding, own the route table and guards, and provide connectivity information. |
| Owner | WS-B (proposed: Yuvraj). Reviewer: WS-A. |
| Responsibilities | Entry point; theme with MFW's logo, colours and fonts (RS NFR-UX-001); route table and access guards (DEC-014); home structure from the M2 designs (RS FR-MAG-006); connectivity type for the mobile-data warning (RS FR-DL-004); environment configuration. |
| Excludes | Feature internals; the authentication logic itself (it consumes `AccessState`); the `app/android/` and `app/ios/` folders (shared, primary editor WS-A, `TASK_OWNERSHIP_MATRIX.md` §8) |
| Depends on | MOD-03 (`watchAccessState`), every feature's public file |
| Errors | An unknown route shows a not-found screen. |
| Authorization | Routes that open or download a full issue require `fullAccess`. Other states redirect to sign-in, verification or profile completion (RS FR-AUTH-010, FR-PROF-004). |
| Data owned | None |
| Tests | Unit tests of guard decisions for each access state; widget test of the navigation shell |
| Integration acceptance | IC-01, IC-05 |

```dart
enum ConnectionType { none, wifi, mobile, other }

abstract interface class ConnectivityService {
  Stream<ConnectionType> watch();
  Future<ConnectionType> current();
}

/// Used by MOD-11 to open notification targets (RS FR-NOTIF-005).
abstract interface class AppNavigator {
  void openIssue(String issueId);
  void openArticle(String postId);
}
```

PROPOSED routes:

- `/`
- `/issues/:issueId`
- `/issues/:issueId/read?page=<n>` (needs `fullAccess`)
- `/downloads`
- `/library`
- `/news`
- `/news/:postId`
- `/sign-in`
- `/register`
- `/verify-email`
- `/complete-profile`
- `/settings`

### 6.2 MOD-02 Errors, logging and monitoring

| Field | Detail |
|---|---|
| Purpose | One place for turning failures into user messages, logging, crash reporting and usage events |
| Owner | WS-A (proposed: Sanika Attarde). Reviewer: WS-B. |
| Responsibilities | `FailureCode` to message mapping; logger; crash-reporting facade (RS NFR-OBS-001); usage events from an approved list only (RS NFR-OBS-002, NFR-PRIV-003) |
| Excludes | Choosing the crash-reporting or analytics provider (DEC-003) |
| Depends on | Nothing inside the app |
| Errors | Never throws. Reporting failures are swallowed after one local log line. |
| Data owned | Crash reports and usage events (RS DATA-014), with no personal data |
| Tests | Every `FailureCode` has a message. Redaction rules are tested. Usage events outside the approved list are rejected (PAC-09). |

```dart
abstract interface class AppLogger {
  void debug(String message, {Map<String, Object?> context = const {}});
  void info(String message, {Map<String, Object?> context = const {}});
  void warning(String message, {Map<String, Object?> context = const {}});
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, Object?> context = const {}});
}

abstract interface class CrashReporter {
  Future<void> recordFatal(Object error, StackTrace stackTrace);
  Future<void> recordNonFatal(Object error, StackTrace stackTrace);
}

/// Accepts only events on the approved list (OQ-23).
abstract interface class UsageEvents {
  void record(UsageEvent event);
}

String messageFor(AppFailure failure);
```

### 6.3 MOD-03 Authentication and account lifecycle

| Field | Detail |
|---|---|
| Purpose | Registration, sign-in, verification, password reset, sign-out and account deletion |
| Owner | WS-A (proposed: Sanika Attarde). Reviewer: WS-B. |
| Responsibilities | Email and password (RS FR-AUTH-001 to 004); Google Sign-In (FR-AUTH-005, PROVISIONAL, C-04); sign-out (FR-AUTH-008); in-app account deletion (FR-AUTH-009); computing `AccessState` |
| Excludes | Sign in with Apple (excluded); profile fields (MOD-04); admin sign-in (MOD-12) |
| Depends on | MOD-04 `watchStatus`; identity provider (DEC-003); OP-ACC-01 |
| Errors | `invalidInput`, `conflict` (address already used, shown to the visitor by design; the rule for an address used with another sign-in method is OQ-05), `unauthenticated` (wrong credentials, with a message that does not say which part was wrong), `cancelled` (Google flow cancelled), `network`, `serviceUnavailable` |
| Authorization | `deleteAccount` requires a signed-in session. PROPOSED: registration tells the visitor that an account exists for the address. Sign-in shows one message for any wrong email or password. Password reset shows the same message whether or not the address has an account. All three are rate limited. The identity provider's behaviour is NOT VERIFIED. |
| Data owned | Reader account (RS DATA-003), held by the identity provider |
| Blocked | OQ-04 (Google verification), OQ-05 (linking), OQ-06 (guideline 4.8) |
| Tests | Unit tests with a fake provider; widget tests of each form state; integration register → verify → full access (AC-3.1, AC-3.2); PAC-01; PAC-12 |
| Integration acceptance | IC-01, IC-08 |

```dart
enum SignInMethod { email, google }

final class AuthSession {
  const AuthSession({required this.userId, required this.method, required this.emailVerified});
  final String userId;
  final SignInMethod method;
  final bool emailVerified;
}

abstract interface class AuthService {
  Stream<AuthSession?> watchSession();     // null when signed out
  Stream<AccessState> watchAccessState();  // Section 4.1
  Future<Result<void>> registerWithEmail({required String email, required String password});
  Future<Result<void>> signInWithEmail({required String email, required String password});
  Future<Result<void>> signInWithGoogle(); // PROVISIONAL (C-04)
  Future<Result<void>> resendVerificationEmail();
  Future<Result<void>> reloadVerificationStatus();
  Future<Result<void>> sendPasswordReset(String email);
  Future<void> signOut();
  Future<Result<void>> deleteAccount();    // calls OP-ACC-01
}
```

### 6.4 MOD-04 Profile, settings and consent

| Field | Detail |
|---|---|
| Purpose | Mandatory reader profile, the settings screen, and consent to MFW's privacy policy and terms |
| Owner | WS-A (proposed: Sanika Attarde). Reviewer: WS-B. |
| Responsibilities | Profile capture and validation (RS FR-PROF-001 to 004, PROVISIONAL); profile screen (FR-PROF-006); profile editing (FR-PROF-007, ASSUMPTION); consent at registration (FR-PRIV-001); links to the policy and terms (FR-PRIV-002); delete-account confirmation (FR-PRIV-004); the settings screen, which hosts MOD-11 preferences and sign-out |
| Excludes | Age gate or parental consent (none, FR-PROF-005); edition-update sign-up (dropped on the working position, GS-Q49; C-02 and OQ-31 stay open) |
| Depends on | OP-PRF-01 to 03; MOD-11 preferences widget |
| Errors | `invalidInput` (missing or invalid field), `unauthenticated`, `network` |
| Authorization | Own profile only (RS NFR-SEC-006) |
| Data owned | Reader profile (RS DATA-004); consent record (DATA-012) |
| Blocked | OQ-01, OQ-02, OQ-03, OQ-07, OQ-27 |
| Tests | Validation for each field once OQ-01 is answered; PAC-02; PAC-08 |
| Integration acceptance | IC-01, IC-08 |

```dart
enum ProfileStatus { unknown, incomplete, complete }

abstract interface class ProfileRepository {
  Stream<ProfileStatus> watchStatus();
  Future<Result<ReaderProfile?>> getOwnProfile();             // OP-PRF-01
  Future<Result<void>> saveOwnProfile(ReaderProfile profile); // OP-PRF-02
  Future<Result<void>> recordConsent(ConsentRecord consent);  // OP-PRF-03
}
```

### 6.5 MOD-05 Catalogue, search and home

| Field | Detail |
|---|---|
| Purpose | Show published issues and their public metadata to every user, with search and filters |
| Owner | WS-B (proposed: Yuvraj). Reviewer: WS-A. |
| Responsibilities | Catalogue with the latest issue and the archive (RS FR-MAG-001 to 004); issue details (FR-MAG-005); home screen (FR-MAG-006); pull-to-refresh (FR-MAG-007, FR-MAG-008); search by title, description and category, and filters by category, industry segment, year and edition (FR-SRCH-001 to 005) |
| Excludes | Searching text inside PDFs (FR-SRCH-007); issue files (MOD-06) |
| Depends on | OP-CAT-01 to 03 |
| Errors | `network`, `serviceUnavailable`, `notFound` (unpublished issue), `invalidResponse` |
| Authorization | Public. No sign-in needed (FR-MAG-001, FR-SRCH-006). Only published issues are returned, and never a file location. |
| Data owned | None (reads issues and categories written by MOD-12) |
| Blocked | OQ-13 (public fields; meaning of "industry segment" and "edition"); OQ-10 (catalogue offline) |
| Tests | `applyQuery` unit tests for each filter and for search (AC-1.2, AC-1.3, PAC-07); widget states; publish then refresh (AC-1.4) |
| Integration acceptance | IC-07 |

```dart
final class IssueQuery {
  const IssueQuery({this.text, this.categoryId, this.industrySegmentId, this.year, this.edition});
  final String? text;
  final String? categoryId;
  final String? industrySegmentId; // matches an issue whose industrySegmentIds contains it
  final int? year;
  final String? edition;
}

abstract interface class CatalogueRepository {
  Future<Result<List<IssueSummary>>> listPublishedIssues(); // OP-CAT-01
  Future<Result<IssueSummary>> getIssue(String issueId);    // OP-CAT-02
  Future<Result<List<IssueCategory>>> listCategories();     // OP-CAT-03
}

/// Metadata-only search and filtering (RS FR-SRCH-001 to 007).
List<IssueSummary> applyQuery(List<IssueSummary> issues, IssueQuery query);
```

A segment filter takes one segment and matches an issue whose `industrySegmentIds` contains it. RS FR-SRCH-003 does not ask for several segments to be selected at once. If that is added, whether the filter means any or all of them is decided then. The segment names come from the catalogue read (OP-01 returns issues, categories and segments, `API_AND_BACKEND_CONTRACT.md` section 3.1). This contract does not yet define the model, or the method, that gives the app those names. PROPOSED.

With five to twelve issues at launch (RS ASM-02), filtering on the device is enough. A server-side query can be added later as an additive change. This is PROPOSED.

### 6.6 MOD-06 Issue access and downloads

| Field | Detail |
|---|---|
| Purpose | Obtain an authorized, complete, verified local copy of an issue, and manage downloaded issues |
| Owner | WS-B (proposed: Yuvraj) for the app. WS-A for OP-FILE-01 in MOD-13. |
| Responsibilities | Size and mobile-data warning before download (RS FR-DL-003, FR-DL-004); download with progress (FR-DL-001, FR-DL-005); resume after a network break (FR-DL-006); integrity check; Downloads screen (FR-DL-008); deletion that frees space (FR-DL-009); offline opening (FR-DL-007); storage checks (FR-STATE-004, FR-STATE-006) |
| Excludes | Rendering (MOD-07); reading before the download completes (S2 "Scope not included") |
| Depends on | OP-FILE-01; MOD-01 `ConnectivityService`; MOD-03 `watchAccessState` |
| Errors | `unauthenticated`, `emailNotVerified`, `profileIncomplete` (from the grant); `insufficientStorage`; `network` and `timeout` (retryable); `fileCorrupt`; `notFound` (unpublished); `cancelled` |
| Authorization | `start` checks `AccessState` for the user experience. OP-FILE-01 enforces on the server (DEC-009). |
| Data owned | Downloaded issues on the device (RS DATA-013) |
| Blocked | DEC-008 and OQ-08 (reading model); OQ-11 (FR-DL-010); DEC-020 and OQ-37 (mechanism) |
| Tests | Unit tests with a fake transport that simulates breaks (FX-NET-* in `TEST_DATA_AND_FIXTURES.md`); AC-4.1 to AC-4.7; PAC-13; PAC-14; near-limit file test (FX-PDF-05) |
| Integration acceptance | IC-02, IC-03, IC-08 |

```dart
sealed class DownloadStatus { const DownloadStatus(); }
final class NotDownloaded extends DownloadStatus { const NotDownloaded(); }
final class Queued extends DownloadStatus { const Queued(); }
final class InProgress extends DownloadStatus {
  const InProgress(this.receivedBytes, this.totalBytes);
  final int receivedBytes;
  final int totalBytes;
}
final class WaitingForNetwork extends DownloadStatus {
  const WaitingForNetwork(this.receivedBytes, this.totalBytes);
  final int receivedBytes;
  final int totalBytes;
}
final class Verifying extends DownloadStatus { const Verifying(); }
final class Downloaded extends DownloadStatus {
  const Downloaded(this.issue);
  final DownloadedIssue issue;
}
final class Failed extends DownloadStatus {
  const Failed(this.failure);
  final AppFailure failure;
}

final class DownloadPlan {
  const DownloadPlan({required this.sizeBytes, required this.onMobileData, required this.enoughSpace});
  final int sizeBytes;
  final bool onMobileData;
  final bool enoughSpace;
}

abstract interface class DownloadManager {
  Stream<DownloadStatus> watch(String issueId);
  Future<Result<DownloadPlan>> prepare(String issueId);
  Future<Result<void>> start(String issueId, {required bool mobileDataAccepted}); // a copy kind, kept or temporary, is proposed: GS-Q43, OQ-08
  Future<Result<void>> cancel(String issueId);
  Future<Result<void>> delete(String issueId);
  Future<List<DownloadedIssue>> listDownloaded();
  Future<Result<LocalIssueFile>> openLocal(String issueId); // only for MOD-07
}
```

**Behaviour rules (PROPOSED)**

1. When the network drops, the status becomes `WaitingForNetwork`. When it returns, the download continues from `receivedBytes`.
2. If the grant has expired, the manager requests a new one through OP-FILE-01 and continues from the same offset.
3. When the transfer completes, the manager checks the size and `contentHash`. On a mismatch it deletes the partial file and reports `fileCorrupt` with a retry (RS FR-READ-010, FR-STATE-006).
4. A partial file is never listed as downloaded (RS FR-STATE-004).
5. On the working position there are two actions (GS-Q43, reported as MFW's answer and not filed). Read downloads a complete copy that is temporary and is removed when the reader leaves the issue, or at the next start of the app after a crash. Download keeps the copy until the reader deletes it. `listDownloaded` returns only kept copies. The `kind` parameter on `start` waits for MFW's written answer to OQ-08.
6. Downloads run only while the app is in the foreground. A stopped download resumes the next time the app is open (GS-Q60).
7. Each stored copy records the reader who downloaded it (`ownerUserId`). `openLocal` and `listDownloaded` return only copies owned by the signed-in reader, and refuse any other (`PDF_READER_AND_OFFLINE_DESIGN.md` invariant I-2). On the OQ-11 working position, sign-out hides a reader's copies until the same reader signs in again. Whether a second reader on the same device downloads a second copy is RD-05 in that document.
8. Each stored copy records the file revision it was downloaded at (`fileRevision`), and the grant carries the current revision. A copy at an older revision still opens, and the app shows an updated badge. The app never replaces a copy silently (`PDF_READER_AND_OFFLINE_DESIGN.md` section 5; the space and display questions are RD-03). If MFW does not allow replacement (OQ-21), only revision 1 exists.

### 6.7 MOD-07 Reader

| Field | Detail |
|---|---|
| Purpose | Render a downloaded issue with page-turn and swipe modes |
| Owner | WS-B (proposed: Yuvraj). Reviewer: WS-A. |
| Responsibilities | Page-turn effect and plain swipe mode (RS FR-READ-006, FR-READ-007); swipe and tap page turns (FR-READ-003, FR-READ-004); zoom to 300% (FR-READ-005); two-page spread on tablets and in landscape (FR-READ-009); damaged-file error with retry (FR-READ-010); bookmark action (calls MOD-08); performance targets (NFR-PERF-001, NFR-PERF-002, NFR-REL-001) |
| Excludes | Downloading (MOD-06); text search inside PDFs |
| Depends on | MOD-06 `openLocal`; MOD-08; the rendering library (DEC-005) behind `PdfRenderer` |
| Errors | `fileCorrupt`, `notFound` (local file missing), `unknown` |
| Authorization | Opens only files returned by `openLocal`. Its route requires `fullAccess`. |
| Data owned | None |
| Blocked | DEC-005 and OQ-36 (library); OQ-14 (mode switching and default) |
| Tests | Widget tests of controls; device performance tests (AC-2.1, AC-2.3, AC-2.5); damaged files (FX-PDF-10, FX-PDF-11) |
| Integration acceptance | IC-03 |

```dart
/// Wraps the library chosen under DEC-005.
abstract interface class PdfRenderer {
  Future<Result<PdfDocumentHandle>> open(LocalIssueFile file); // fileCorrupt when damaged
}

abstract interface class PdfDocumentHandle {
  int get pageCount;
  Future<void> close(); // page-rendering methods are defined after DEC-005
}

enum ReaderMode { pageTurn, swipe }

abstract interface class ReaderController {
  Stream<int> watchCurrentPage(); // 1-based
  Future<void> goToPage(int page);
  ReaderMode get mode;            // switching and default: OQ-14
}
```

### 6.8 MOD-08 Bookmarks and favourites

| Field | Detail |
|---|---|
| Purpose | Page bookmarks and favourite issues stored with the reader's account |
| Owner | WS-B (proposed: Yuvraj) for the app. WS-A for the server rules in MOD-13. |
| Responsibilities | Add, open and remove bookmarks (RS FR-BKM-001, FR-BKM-002, FR-BKM-007); favourites (FR-BKM-003); list screens (FR-BKM-006); second-device availability (FR-BKM-004) |
| Excludes | Reading-activity tracking (RS NFR-PRIV-003) |
| Depends on | OP-LIB-01 to 05; MOD-07 for the bookmark action |
| Errors | `unauthenticated`, `forbidden`, `network`, `notFound` |
| Authorization | Own records only, enforced on the server (RS NFR-SEC-005). Bookmarking needs `fullAccess`. Favourites for incomplete access are OQ-12. |
| Data owned | Bookmarks and favourites (RS DATA-005, DATA-006) |
| Blocked | OQ-10 (offline viewing and changes), OQ-12 |
| Tests | AC-5.1 to AC-5.4; isolation between two readers (SEC-CHK-05) |
| Integration acceptance | IC-04 |

```dart
abstract interface class LibraryRepository {
  Stream<List<Bookmark>> watchBookmarks();
  Future<Result<Bookmark>> addBookmark(String issueId, int page, int fileRevision); // OP-LIB-02
  Future<Result<void>> removeBookmark(String bookmarkId);            // OP-LIB-03
  Stream<Set<String>> watchFavouriteIssueIds();
  Future<Result<void>> setFavourite(String issueId, bool favourite); // OP-LIB-05, idempotent
}
```

**Behaviour rules (PROPOSED)**

1. A bookmark is unique on the reader, the issue and the page, without the revision (`DATABASE_AND_DATA_MODEL.md` section 4.10; OP-07, whose repeat is harmless). Database rules do not enforce uniqueness across records (`SECURITY_AND_ACCESS_CONTROL.md` section 12.1). So the key holds only if `bookmarkId` is derived from `issueId` and `page` rather than generated, and a repeated add then reaches the same record (`DATABASE_AND_DATA_MODEL.md` section 12, provisional). The format of the identifier is not agreed and is settled in the backend spike (DEC-003). The key is a working position of YG and is not agreed by both developers.
2. Adding a page that is already bookmarked changes nothing. The stored bookmark keeps its `fileRevision` and its `createdAt`, even if the reader adds the same page again on a later revision. The server keeps the first record and refuses a write that would change it, and a replayed write with the same values is harmless. MOD-08 checks its bookmark list before adding, and treats that refusal for an existing key as "already bookmarked": `addBookmark` returns the stored bookmark, not an error. To bookmark the page on the revision that is open, the reader removes the bookmark and adds it again.
3. `fileRevision` is the revision of the file the reader had open when the bookmark action was used. MOD-07 passes the page and the revision to MOD-08 (`PDF_READER_AND_OFFLINE_DESIGN.md` section 7).
4. Opening a bookmark opens the file at the stored page. The page is clamped to the file that opens, and a notice shows if its revision differs from `fileRevision` (`PDF_READER_AND_OFFLINE_DESIGN.md` section 5; GS-Q16). A bookmark made on an older revision keeps showing the notice until the reader removes it and adds it again. Revisions above 1 exist only if MFW allows a PDF to be replaced (OQ-21), as in section 6.6 rule 8.

### 6.9 MOD-09 News from WordPress

| Field | Detail |
|---|---|
| Purpose | Show MFW's WordPress news in the app, with app-level controls applied |
| Owner | WS-B (proposed: Yuvraj). Reviewer: WS-A. |
| Responsibilities | News list with image, title, date and category (RS FR-NEWS-001); article page (FR-NEWS-002); category filter (FR-NEWS-003); refresh (FR-NEWS-004); offline reading of loaded articles with a notice (FR-NEWS-005); hidden posts removed (FR-NEWS-008); only MFW-selected categories (INT-WP-003); small pages and caching (INT-WP-004); WordPress unreachable (FR-STATE-005) |
| Excludes | Writing or editing news (RS FR-ADMIN-019); any change to the WordPress site (INT-WP-002) |
| Depends on | WordPress REST API (Section 9.1); OP-NWS-01; DEC-021 |
| Errors | `network`, `timeout`, `serviceUnavailable`, `invalidResponse`, `notFound` |
| Authorization | Public (RS FR-NEWS-007) |
| Data owned | None. WordPress is the master source (RS DATA-015). The app keeps a cache only. |
| Blocked | OQ-16 (offline save model), OQ-17 (breaking presentation), OQ-39 (site details) |
| Tests | Fixture-based tests (FX-WP-*); AC-7.1 to AC-7.5 |
| Integration acceptance | IC-06 |

```dart
final class NewsPage {
  const NewsPage({required this.posts, required this.hasMore, required this.fromCache});
  final List<NewsPost> posts;
  final bool hasMore;
  final bool fromCache; // drives the offline notice (RS FR-NEWS-005)
}

abstract interface class NewsRepository {
  Future<Result<NewsPage>> listPosts({String? categoryId, int page = 1});
  Future<Result<NewsPost>> getPost(String postId);
  Future<Result<List<NewsCategory>>> listCategories();
}
```

### 6.10 MOD-10 Sharing

| Field | Detail |
|---|---|
| Purpose | Share an issue or an article through the device's share sheet |
| Owner | WS-B (proposed: Yuvraj). Reviewer: WS-A. |
| Responsibilities | Issue: title and store-listing link (RS FR-SHR-001, FR-SHR-002). Article: title and WordPress address (FR-SHR-003, FR-SHR-004). |
| Excludes | Sending files (FR-SHR-006); links that open the app (FR-SHR-005) |
| Errors | `cancelled`, `unknown` |
| Blocked | OQ-15 (which store link); OQ-09 (sharing while logged out) |
| Tests | AC-6.1, AC-6.2; PAC-05 |

```dart
abstract interface class ShareService {
  Future<Result<void>> shareIssue(IssueSummary issue);
  Future<Result<void>> shareArticle(NewsPost post);
}
```

### 6.11 MOD-11 Notifications

| Field | Detail |
|---|---|
| Purpose | Notification permission, category preferences, device registration, opening notification targets, and dispatch |
| Owner | WS-A (proposed: Sanika Attarde). Reviewer: WS-B, who owns tap routing in MOD-01. |
| Responsibilities | Explanation before the system prompt (RS FR-NOTIF-001); category choice and later changes (FR-NOTIF-002, FR-NOTIF-003); delivery only to opted-in devices for the category (FR-NOTIF-004); tap opens the target, with access rules applied (FR-NOTIF-005, BR-005); dispatch and send log on the server (FR-ADMIN-016 to 018) |
| Excludes | Scheduled sends, audience segments, delivery and open statistics (S2 "Later-phase features") |
| Depends on | OP-NTF-01 to 04; OP-ADM-06; MOD-01 `AppNavigator`; platform push services (Section 9.2) |
| Errors | Permission denied is an outcome, not a failure. `network`, `unknown`. |
| Data owned | Notification preferences and device registrations (RS DATA-007) |
| Blocked | OQ-09 (logged-out users), OQ-18 (categories), OQ-19 (send-log fields) |
| Tests | AC-9.1 to AC-9.6; payload fixtures FX-NTF-* |
| Integration acceptance | IC-05 |

```dart
enum PermissionOutcome { granted, denied, notDetermined }

abstract interface class NotificationService {
  Future<Result<PermissionOutcome>> explainAndRequestPermission();
  Future<Result<NotificationPreferences>> getPreferences();       // OP-NTF-03
  Future<Result<void>> savePreferences(NotificationPreferences p); // OP-NTF-04
  Stream<NotificationTarget> watchOpened();                        // forwarded to AppNavigator
}
```

**Payload (PROPOSED).** The visible title and body, plus `{"type": "issue" | "article", "targetId": "<opaque id>", "sendId": "<opaque id>"}`. No personal data.

## 7. Backend Modules

### 7.1 MOD-12 Admin and content management

| Field | Detail |
|---|---|
| Purpose | Let MFW's editors run the app without developer help (S2 Objectives) |
| Owner | WS-A (proposed: Sanika Attarde). Reviewer: WS-B. |
| Responsibilities | Admin sign-in and the single admin role (RS FR-ADMIN-002 to 004), with in-panel add and remove of admins (GS-Q44, OQ-58); issue upload with validation (FR-ADMIN-005 to 008); issue details (FR-ADMIN-009); categories (FR-ADMIN-010); publish and unpublish (FR-ADMIN-011); news controls (FR-ADMIN-013 to 015); notifications and send log (FR-ADMIN-016 to 018); registered-user list and export (FR-USER-002, FR-USER-003, PROVISIONAL); subscriber export (FR-USER-001, CONFLICT C-02, dropped on the working position, GS-Q49); result messages (FR-STATE-007) |
| Excludes | News authoring (FR-ADMIN-019); editorial roles, drafts, scheduled publishing and audit log (S2 "Later-phase features"), apart from the narrow record of admin adds and removes (GS-Q44); readership analytics (FR-USER-004) |
| Interface | OP-ADM-01 to OP-ADM-11 (Section 8). OP-ADM-12 is a note: sign-in is the identity provider's job, and the role lookup is OP-14 in `API_AND_BACKEND_CONTRACT.md`. Adding and removing admins is OP-35 and OP-37 in section 5.2 of that document and has no alias (DEC-026) |
| Authorization | The admin role is checked on the server for every operation. |
| Data owned | Issues, categories, news controls, send records, admin accounts (RS DATA-001, 002, 008, 009, 011) |
| Blocked | DEC-003, DEC-004, OQ-20, OQ-21, OQ-22, OQ-30, OQ-31 |
| Tests | AC-8.1 to AC-8.9; AC-9.4; AC-9.5; PAC-03; upload fixtures FX-PDF-06 to FX-PDF-09; FX-ADM-* |
| Integration acceptance | IC-06, IC-07 |

### 7.2 MOD-13 Backend authorization, data rules and account deletion

| Field | Detail |
|---|---|
| Purpose | Enforce the access rules of Section 4.1 on the server, and remove a reader's data on deletion |
| Owner | WS-A (proposed: Sanika Attarde). Reviewer: WS-B. |
| Responsibilities | Authorization for every operation in Section 8; OP-FILE-01; owner-only rules for profiles, bookmarks, favourites and preferences; OP-ACC-01 deletion of the account, profile, bookmarks, favourites, notification preferences and any edition-update sign-up (RS FR-PRIV-003) |
| Blocked | DEC-003, DEC-020, OQ-24 (records kept after deletion) |
| Tests | Rule tests for every operation and access state (allowed and refused); SEC-CHK-02 to 06; SEC-CHK-11 |
| Integration acceptance | IC-02, IC-04, IC-08 |

## 8. Backend Operation Catalogue

`API_AND_BACKEND_CONTRACT.md` is the single catalogue of backend operations, and its OP-nn identifiers are the main ones. The identifiers in this table are aliases of them (last column). This table stays until that catalogue is agreed, and then becomes a pointer to it. The two catalogues differ in four design points that are open, not decided (`API_AND_BACKEND_CONTRACT.md` section 3.4).

These are technology-neutral operations. Each row is a contract: who may call it, what it takes, what it returns, and which errors it can raise. The transport (SDK call, function, HTTP endpoint) is decided under DEC-003.

| OP | Operation | Caller | Authorization (enforced on the server) | Input | Output | Errors | Requirements | Main identifier (`API_AND_BACKEND_CONTRACT.md`) |
|---|---|---|---|---|---|---|---|---|
| OP-CAT-01 | `listPublishedIssues` | App | Public | None | Published `IssueSummary` list | `UNAVAILABLE` | FR-MAG-001, FR-MAG-004, FR-MAG-007 | OP-01 |
| OP-CAT-02 | `getIssue` | App | Public. Unpublished returns `NOT_FOUND`. | `issueId` | `IssueSummary` | `NOT_FOUND` | FR-MAG-005, FR-MAG-008 | none (open) |
| OP-CAT-03 | `listCategories` | App | Public | None | `IssueCategory` list | `UNAVAILABLE` | FR-MAG-003, FR-SRCH-002 | OP-01 |
| OP-FILE-01 | `requestIssueFile` | App | Signed in; email verified for email accounts (Google: OQ-04); profile complete (PROVISIONAL, BR-003); issue published | `issueId` | `IssueFileGrant` | `UNAUTHENTICATED`, `EMAIL_NOT_VERIFIED`, `PROFILE_INCOMPLETE`, `NOT_FOUND` | FR-READ-001, FR-DL-001, FR-DL-002, NFR-SEC-002, INT-FILE-001 | OP-11 |
| OP-PRF-01 | `getOwnProfile` | App | Signed in; own record | None | `ReaderProfile` or none | `UNAUTHENTICATED` | FR-PROF-006 | OP-06 |
| OP-PRF-02 | `saveOwnProfile` | App | Signed in; own record | `ReaderProfile` | None | `INVALID_ARGUMENT` | FR-PROF-001, FR-PROF-002, FR-PROF-007 | OP-10 |
| OP-PRF-03 | `recordConsent` | App | Signed in; own record | `ConsentRecord` | None | `INVALID_ARGUMENT` | FR-PRIV-001, DATA-012 | OP-10 |
| OP-LIB-01 | `listBookmarks` | App | Signed in; own records | None | `Bookmark` list | `UNAUTHENTICATED` | FR-BKM-006 | OP-07 |
| OP-LIB-02 | `addBookmark` | App | Full access; own record | `issueId`, `page`, `fileRevision` | `Bookmark` | `INVALID_ARGUMENT` (page out of range) | FR-BKM-001 | OP-07 |
| OP-LIB-03 | `removeBookmark` | App | Own record | `bookmarkId` | None | `NOT_FOUND` | FR-BKM-007 | OP-07 |
| OP-LIB-04 | `listFavourites` | App | Signed in; own records | None | Issue ID list | `UNAUTHENTICATED` | FR-BKM-006 | OP-08 |
| OP-LIB-05 | `setFavourite` | App | Full access (incomplete access: OQ-12); idempotent | `issueId`, `favourite` | None | `NOT_FOUND` | FR-BKM-003 | OP-08 |
| OP-NWS-01 | `getNewsControls` | App | Public | None | Hidden and breaking post IDs | `UNAVAILABLE` | FR-NEWS-008, FR-NEWS-009 | OP-04 |
| OP-NTF-01 | `registerDevice` | App | Signed in, or a logged-out visitor on the working position (GS-Q46; OQ-09 stays open); idempotent | Device token, platform | None | `INVALID_ARGUMENT` | DATA-007 | none (open) |
| OP-NTF-02 | `unregisterDevice` | App | Own device | Device token | None | None | DATA-007 | none (open) |
| OP-NTF-03 | `getPreferences` | App | Own record | None | `NotificationPreferences` | `UNAUTHENTICATED` | FR-NOTIF-002 | OP-09 |
| OP-NTF-04 | `savePreferences` | App | Own record | `NotificationPreferences` | None | `INVALID_ARGUMENT` | FR-NOTIF-002, FR-NOTIF-003 | OP-09 |
| OP-EML-01 | `setEditionUpdateSubscription` | App | OQ-09 | Opt in or out | None | None | FR-EMAIL-001, FR-EMAIL-002 (CONFLICT C-02) | none (conditional, C-02; dropped on the working position, GS-Q49) |
| OP-ACC-01 | `deleteOwnAccount` | App | Signed in; own account; recent sign-in if the provider requires it | None | None | `UNAUTHENTICATED` | FR-AUTH-009, FR-PRIV-003 | OP-12 (OP-13 is withdrawn) |
| OP-ADM-01 | `uploadIssue` | Admin panel | Admin role | PDF, cover, issue details | `issueId` (unpublished) | `FORBIDDEN`, `NOT_A_PDF`, `FILE_TOO_LARGE`, `INVALID_ARGUMENT` | FR-ADMIN-005 to 009, NFR-SEC-008 | OP-19, OP-20, OP-40 |
| OP-ADM-02 | `updateIssueDetails` | Admin panel | Admin role | `issueId`, details | None | `NOT_FOUND`, `INVALID_ARGUMENT` | FR-ADMIN-009 | OP-16 |
| OP-ADM-03 | `setIssuePublished` | Admin panel | Admin role | `issueId`, `published` | None | `NOT_FOUND` | FR-ADMIN-011 | OP-21, OP-22 |
| OP-ADM-04 | `manageCategory` | Admin panel | Admin role | Create, rename or remove | Category | `CONFLICT` (in use) | FR-ADMIN-010 | OP-17, OP-18 |
| OP-ADM-05 | `setNewsControl` | Admin panel | Admin role | `postId`, `hidden`, `breaking` | None | `INVALID_ARGUMENT` | FR-ADMIN-013, FR-ADMIN-014 | OP-23 |
| OP-ADM-06 | `sendNotification` | Admin panel | Admin role | Category, target, title, body | `sendId` | `FORBIDDEN`, `INVALID_ARGUMENT` | FR-ADMIN-015 to 017, FR-NOTIF-004 | OP-25, OP-26 |
| OP-ADM-07 | `listSendLog` | Admin panel | Admin role | Paging | `NotificationSendRecord` list | `FORBIDDEN` | FR-ADMIN-018 | OP-27 |
| OP-ADM-08 | `listRegisteredUsers` | Admin panel | Admin role | Paging | `RegisteredUserRow` list | `FORBIDDEN` | FR-USER-002 (PROVISIONAL) | OP-31 |
| OP-ADM-09 | `exportRegisteredUsersCsv` | Admin panel | Admin role | None | CSV file | `FORBIDDEN` | FR-USER-003, NFR-PRIV-004 | OP-32 |
| OP-ADM-10 | `exportSubscriberListCsv` | Admin panel | Admin role | None | CSV file | `FORBIDDEN` | FR-USER-001 (CONFLICT C-02, OQ-31). Dropped on the working position (GS-Q49) | OP-33 |
| OP-ADM-11 | `deleteIssue` or `replaceIssueFile` | Admin panel | Admin role | `issueId` | None | `NOT_FOUND` | FR-ADMIN-012 (OPEN, OQ-21) | OP-30 (delete); a replacement is OP-19 with OP-40 |
| OP-ADM-12 | `adminSignIn` | Admin panel | Valid credentials and admin role | Credentials | Admin session | `UNAUTHENTICATED`, `FORBIDDEN` | FR-ADMIN-002, FR-ADMIN-003, NFR-SEC-011 (OQ-20) | OP-14 |

**Notes on the table**

- "Admin role" means the one admin role (RS FR-ADMIN-004). Every admin has the same permissions (GS-Q44). The two-role model (PRC-01) is withdrawn (`API_AND_BACKEND_CONTRACT.md` section 3.2).
- OP-ADM-11 joins two different things, deleting an issue and replacing its PDF. They need different safeguards (a typed confirmation, an atomic swap, the effect on copies already downloaded). The split waits for OQ-21. One rule applies now, whatever OQ-21 decides: a replacement file is validated before the old file is removed.
- OP-ADM-12 is not a backend operation: sign-in is the identity provider's job, and the role lookup is OP-14 in the catalogue.
- OP-ACC-01 is an immediate deletion (GS-Q50). The grace window with undo (PRC-02) is withdrawn.

## 9. External Interfaces

### 9.1 WordPress REST API

PROVISIONAL example: standard WordPress REST routes. Each must be confirmed against MFW's site (OQ-39). The app only reads, and never authenticates to WordPress.

| Use | Example request | Notes |
|---|---|---|
| News list | `GET <site>/wp-json/wp/v2/posts?categories=<ids>&per_page=<n>&page=<p>&_embed` | Pagination totals come in the `X-WP-Total` and `X-WP-TotalPages` response headers. |
| One article | `GET <site>/wp-json/wp/v2/posts/<id>?_embed` | |
| Categories | `GET <site>/wp-json/wp/v2/categories?include=<ids>` | Only the categories MFW selects (RS INT-WP-003) |

| WordPress field | Contract field |
|---|---|
| `id` | `postId` |
| `title.rendered` | `title` (entities decoded) |
| `content.rendered` | `contentHtml` (rendered without scripts, `CODING_STANDARDS.md` §7) |
| `date_gmt` | `publishedAt` |
| `link` | `link`, used for sharing (RS FR-SHR-004) |
| `categories` | `categoryIds` |
| Featured media in `_embedded` | `imageUrl` |

### 9.2 Push notification services

Notifications are delivered through the platform push services, and on iOS through Apple's push service using MFW's Apple Developer account (RS INT-PUSH-001, INT-PUSH-002). The provider that calls those services is decided under DEC-003. S2 proposes Firebase Cloud Messaging.

### 9.3 App store links

Issue sharing uses the store-listing link (RS FR-SHR-002). Which link, and what is shared before the listings are live, is OQ-15.

## 10. Cross-Workstream Integration Contracts

Each contract has a provider, a consumer and a pass condition. They are checked under DoD-INT (`DEFINITION_OF_DONE.md` §7).

| ID | Contract | Provider | Consumer | Passes when |
|---|---|---|---|---|
| IC-01 | Access state | MOD-03 and MOD-04 (WS-A) | MOD-01 and MOD-05 to MOD-08 (WS-B) | For each test user FX-USR-01 to FX-USR-05, `watchAccessState` emits the expected state, and the route guard shows the right screen or prompt. |
| IC-02 | Issue-file grant | MOD-13 (WS-A) | MOD-06 (WS-B) | A grant is issued only to a reader with full access. A download completes, and resumes with a new grant after expiry. Each refused state maps to its prompt. |
| IC-03 | Local file to reader | MOD-06 | MOD-07 | `openLocal` returns only complete, verified files. A damaged file gives `fileCorrupt` and a retry. |
| IC-04 | Library rules | MOD-13 (WS-A) | MOD-08 (WS-B) | Reader A cannot read or change reader B's items. Items appear on a second device. |
| IC-05 | Notification tap | MOD-11 (WS-A) | MOD-01 (WS-B) | Each payload in FX-NTF-01 to FX-NTF-08 opens the right screen or prompt, with access rules applied. |
| IC-06 | News controls | MOD-12 (WS-A) | MOD-09 (WS-B) | A post hidden in the admin panel disappears from the app after a refresh. |
| IC-07 | Catalogue publication | MOD-12 (WS-A) | MOD-05 (WS-B) | Publishing and unpublishing show correctly after a refresh. |
| IC-08 | Account deletion | MOD-03 and MOD-13 (WS-A) | MOD-04, MOD-06, MOD-08, MOD-11 | After deletion, the server holds none of the reader's data in RS FR-PRIV-003, the app clears local user data, and downloads behave as OQ-11 decides. |

## 11. Blocked and Open Items

| Item | Blocks | Resolved by |
|---|---|---|
| Backend platform | Section 8 transport; MOD-12 and MOD-13 implementation | DEC-003, OQ-35 |
| Admin technology | MOD-12 user interface | DEC-004, OQ-35 |
| Issue-file mechanism | OP-FILE-01; MOD-06 transport | DEC-020, OQ-37 |
| Reader library | `PdfRenderer` implementation | DEC-005, OQ-36 |
| Profile fields and age format | `ReaderProfile`; OP-PRF-02 validation | OQ-01, OQ-02 |
| Google verification and linking | `AccessState` for Google accounts; FR-AUTH-006 | OQ-04, OQ-05 |
| Reading model | MOD-06 copy retention | DEC-008, OQ-08 |
| Subscriber list | OP-ADM-10, OP-EML-01 | C-02, OQ-31 |

## 12. Change Control

1. A change to a contract here, or to `app/lib/contracts/`, is a shared-file change (`DEVELOPMENT_WORKFLOW.md` §8). It goes in its own pull request, reviewed by both developers.
2. Additive changes need the review only. Breaking changes also need a `DECISION_LOG.md` entry.
3. When a Phase 2 document makes a contract concrete, this document points to it rather than repeating it.
4. Operation and module IDs are never reused.
