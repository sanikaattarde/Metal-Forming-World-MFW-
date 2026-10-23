# Coding Standards: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Coding Standards |
| File | `Documentation/CODING_STANDARDS.md` |
| Phase | 3 — Development Planning and Collaboration (document 25) |
| Version | 0.2 |
| Status | Draft for review. Not approved. |
| Date | 23 October 2026 |
| Approval required | Both developers |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. Planned name replaced by the existing document. Access-rule labels. Personal-data term for crash and usage events marked NOT VERIFIED. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `REQUIREMENTS_SPECIFICATION.md` (RS) | Exists, draft. Requirement IDs cited below. |
| `DECISION_LOG.md` | Exists (draft). DEC-002, DEC-003, DEC-004, DEC-012, DEC-013, DEC-014. |
| `API_AND_MODULE_CONTRACTS.md` | Exists (draft). Interfaces and error codes these standards apply. |
| `TASK_OWNERSHIP_MATRIX.md`, `DEVELOPMENT_WORKFLOW.md`, `DEFINITION_OF_DONE.md` | Exist (draft) |
| `DEPENDENCY_REGISTER.md`, `TEST_DATA_AND_FIXTURES.md`, `TESTING_STRATEGY.md` | Exist (draft) |
| `TECHNOLOGY_DECISIONS.md` | Exists on `main` (draft). It was planned as `TECH_STACK_DECISIONS.md`. Backend and admin specifics wait for its decisions (DEC-003, DEC-004). |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal in this document. In RS terms it is an ASSUMPTION (DEV).

## 2. Purpose, Scope and Status

These standards keep code from two developers and two Claude Code sessions consistent, testable and safe to integrate.

| Area | Status |
|---|---|
| Flutter and Dart standards (Sections 3 to 13) | PROPOSED. Flutter itself is CONFIRMED (DEC-002). |
| State management and navigation (Section 5) | Rules that hold whatever the choice: PROPOSED. Library choices: DEC-013 and DEC-014, PROPOSED. |
| Backend standards (Section 14) | Technology-neutral principles only. Specifics are blocked by DEC-003. |
| Admin panel standards (Section 15) | Technology-neutral principles only. Specifics are blocked by DEC-004. |

No package is installed and no configuration file is created by this document. No application code exists yet.

## 3. Project Structure

PROPOSED (DEC-012). The paths below are the boundaries used by `TASK_OWNERSHIP_MATRIX.md` §6.

```
<repository root>/
├── Documentation/                  Project documents
├── README.md
├── app/                            Flutter app for Android and iOS (DEC-002)
│   ├── lib/
│   │   ├── main.dart               Entry point (MOD-01, shared, high-risk)
│   │   ├── app/                    App widget, router, theme, dependency wiring (MOD-01, shared, high-risk)
│   │   ├── contracts/              Shared domain models and interfaces (MOD-00, shared, high-risk)
│   │   ├── core/
│   │   │   ├── config/             Environment configuration, no secrets (MOD-01)
│   │   │   ├── network/            HTTP client wrapper, connectivity (MOD-01)
│   │   │   ├── errors/             AppFailure, failure-to-message mapping (MOD-02)
│   │   │   └── logging/            Logger, crash-reporting and usage-event facades (MOD-02)
│   │   └── features/
│   │       ├── auth/               MOD-03
│   │       ├── profile/            MOD-04: profile, settings, consent
│   │       ├── catalogue/          MOD-05: home, catalogue, issue details, search, filters
│   │       ├── downloads/          MOD-06
│   │       ├── reader/             MOD-07
│   │       ├── library/            MOD-08: bookmarks and favourites
│   │       ├── news/               MOD-09
│   │       ├── sharing/            MOD-10
│   │       └── notifications/      MOD-11, app side
│   ├── test/                       Mirrors lib/. Shared fakes in test/fakes/.
│   ├── integration_test/           Cross-feature flows on a device or emulator
│   ├── android/, ios/              Platform projects (shared, high-risk)
│   └── pubspec.yaml, pubspec.lock, analysis_options.yaml   (shared, high-risk)
├── backend/                        Server logic and access rules: MOD-11 dispatch, MOD-12, MOD-13. Layout blocked by DEC-003.
└── admin/                          Web admin panel: MOD-12. Layout blocked by DEC-004.
```

Each feature folder uses the same layout:

```
features/<feature>/
├── <feature>.dart        Public API of the feature. Other features import only this file.
├── domain/               Feature-private entities and use cases
├── data/                 DTOs, data sources, repository implementations
└── presentation/         Screens, widgets, state holders
```

**Dependency rules**

1. `presentation` depends on `domain` and `contracts`. `data` implements interfaces from `domain` or `contracts`.
2. A feature may import another feature only through that feature's public file (`<feature>.dart`), never its internal folders.
3. `core` never imports a feature. `contracts` imports neither Flutter UI libraries nor any backend SDK.
4. Backend SDK imports (for example Firebase packages, if DEC-003 chooses Firebase) are allowed only in `data/` folders and in `core` adapters. This keeps the provider replaceable (RS NFR-MAINT-005).

## 4. Dart and Flutter Naming and Formatting

| Item | Rule | Example |
|---|---|---|
| Files and folders | `lower_snake_case` | `download_manager.dart` |
| Classes, enums, typedefs, extensions | `UpperCamelCase` | `DownloadStatus` |
| Members, variables, parameters, constants, enum values | `lowerCamelCase` | `maxUploadBytes`, `fullAccess` |
| Acronyms | Capitalised as one word | `PdfRenderer`, `HttpClient` |
| Booleans | Read as a question | `isDownloaded`, `hasFullAccess` |
| Async methods | Return `Future` or `Stream`. No `Async` suffix. | `Future<Result<Issue>> getIssue(...)` |
| Route-level widgets | Suffix `Screen` | `ReaderScreen` |
| Private members | Leading underscore | `_retryCount` |
| Test files | `<file under test>_test.dart` | `download_manager_test.dart` |

**Formatting.** `dart format` output is the only formatting authority. Do not hand-align code. How the formatter handles trailing commas depends on the Dart version pinned under OQ-50.

**Static analysis (PROPOSED).** `analysis_options.yaml` includes the `flutter_lints` rule set, enables `strict-casts`, `strict-inference` and `strict-raw-types`, and adds `prefer_final_locals`, `always_declare_return_types`, `unawaited_futures` and `avoid_dynamic_calls`. The rule: zero analyzer errors and zero warnings before review.

**Widgets.** Use `const` constructors where possible. Keep widgets small. Never call the network, storage or a backend inside `build()`. Give list items stable keys.

## 5. State Management and Navigation

### 5.1 Rules that hold whatever library is chosen

1. Widgets display state and forward user intent. Business logic and side effects live in state holders and use cases.
2. Each screen models loading, data, empty and error states explicitly (RS FR-STATE-001 to FR-STATE-003).
3. State objects are immutable.
4. There are no global mutable singletons. Dependencies are injected so that tests can replace them with fakes.
5. Subscriptions and controllers are disposed when their owner is disposed.

### 5.2 Library choice

| Concern | Proposal | Status |
|---|---|---|
| State management | Riverpod | DEC-013, PROPOSED |
| Navigation | go_router | DEC-014, PROPOSED |

If both are AGREED:

- Providers are declared inside the feature that owns them, and tests override them with fakes.
- Providers that wire implementations to interfaces live in `app/lib/app/` (MOD-01).

### 5.3 Navigation rules

1. The route table lives only in `app/lib/app/` (MOD-01).
2. Routes that show content use stable IDs. PROPOSED paths: `/issues/:issueId`, `/issues/:issueId/read?page=<n>`, `/news/:postId`.
3. Routes that open or download a full issue require `AccessState.fullAccess` (`API_AND_MODULE_CONTRACTS.md` §4.1). Otherwise the guard redirects to the right prompt: sign in, verify email, or complete profile (RS FR-AUTH-010, FR-PROF-004).
4. The route guard is user experience only. The server enforces access (DEC-009).
5. Notification taps use the same routes and guards (RS BR-005).

## 6. Error Handling and Logging

### 6.1 Errors

1. The data layer catches exceptions from SDKs, HTTP and the platform, and converts them into an `AppFailure` (`API_AND_MODULE_CONTRACTS.md` §4.2). Repository methods return `Result<T>`.
2. The presentation layer turns a `FailureCode` into a user message through the `core/errors` mapper. Raw exception text is never shown to users.
3. No empty `catch` blocks. Programming errors (`Error` subclasses) are not caught, except by the top-level handler.
4. Failures marked retryable offer a retry action (RS FR-READ-010, FR-STATE-003, FR-STATE-006).
5. Top-level handlers (`FlutterError.onError` and `PlatformDispatcher.instance.onError`) forward to the crash-reporting facade in MOD-02.

### 6.2 Logging

1. Log only through the MOD-02 logger. Never use `print`.
2. Levels: `debug` (development builds only), `info`, `warning`, `error`.
3. **Never log:**
   - Passwords, tokens, download grants or signed URLs.
   - Email addresses, names, or any profile value (age, gender, occupation, domain of work).
   - Push device tokens.
   - Request or response bodies, or file contents.
   - Reader account IDs.
4. Never record which reader opened which issue or page (RS NFR-PRIV-003). Usage events come only from the approved list (OQ-23).
5. Issue IDs and news post IDs may be logged. They identify content, not people.
6. Whether device and installation identifiers count as personal data in crash reports and usage events is not defined, and the provider's behaviour is NOT VERIFIED. The term is defined when the crash and analytics provider is chosen (DEC-028, OQ-23).

## 7. API and Model Serialization

1. Each external data shape has its own DTO in the `data/` layer, mapped to a domain entity. Domain entities do not depend on transport formats.
2. `fromJson` and `toJson` are explicit. Code generation with `json_serializable` or `freezed` is PROPOSED and needs a `DEPENDENCY_REGISTER.md` entry first.
3. **Tolerant reader.** Ignore unknown fields. Validate required fields. A response that cannot be parsed becomes `FailureCode.invalidResponse`.
4. Unknown enum values map to an `unknown` member instead of throwing.
5. **Dates.** ISO 8601 with a time-zone offset in transport, held in UTC, shown in the device's local time. Display formats follow the M2 designs.
6. **IDs.** IDs are opaque strings. Never derive meaning from an ID, and never build a storage path for a protected file on the client.
7. **Sizes.** File sizes are whole bytes held in an `int`.
8. **WordPress content.** Decode HTML entities in titles. Render post content with an HTML renderer that does not run scripts, and open links outside the app. The renderer is chosen under `DEPENDENCY_REGISTER.md`. This rule is PROPOSED.

## 8. Authentication, Secure Storage and File Storage

### 8.1 Authentication

1. Session tokens are managed by the authentication SDK, or kept only in platform secure storage: the iOS Keychain or Android Keystore-backed storage.
2. Never store passwords. Never put tokens in plain preferences or files.
3. On sign-out, clear user-scoped data held in memory and in caches (profile, bookmarks, favourites). What happens to downloaded issues is OQ-11.
4. If the provider requires a recent sign-in before account deletion, the app asks the reader to sign in again (RS FR-AUTH-009). This is provider-specific and PROVISIONAL.
5. Client-side access checks are user experience only. The server is the authority (DEC-009).

### 8.2 Issue file storage on the device

1. Issue files live only in app-private storage (RS NFR-SEC-004):
   - Android: app-specific internal storage, never shared or external storage.
   - iOS: the Application Support directory, with files excluded from device backups because they can be downloaded again. Verify this behaviour in WP-06.
2. A partial download is kept separately and is never listed as downloaded until it is complete and its integrity check has passed (RS FR-STATE-004).
3. File names derive from opaque issue IDs, not from titles.
4. Issue files are never passed to the share sheet or to other apps (RS FR-SHR-006).
5. Check free space before a download starts (RS FR-STATE-004).

## 9. Accessibility and Localization

**Accessibility (PROVISIONAL; the baseline is OQ-25).** The baseline proposed in RS OQ-25, with concrete values PROPOSED here:

1. Every interactive control has a semantic label. Icon-only buttons have a label or tooltip.
2. App interface text follows the device's text-size setting, and layouts do not clip at large sizes. This does not apply to PDF page content.
3. Touch targets are at least 48 × 48 dp on Android and 44 × 44 pt on iOS, following each platform's guidelines.
4. Text contrast is at least 4.5:1, the WCAG 2.1 AA level for normal text.
5. Information is never conveyed by colour alone.
6. Reader page turns can also be done with buttons, not only gestures.

**Localization.** The app and the admin panel are in English only (RS NFR-UX-003). Keep user-facing strings together per feature rather than inline, never build sentences by joining strings, and format dates and numbers through one shared helper.

## 10. Testing Conventions

| Topic | Rule |
|---|---|
| Location | `app/test/` mirrors `app/lib/`. `app/integration_test/` holds cross-feature flows. |
| Names | Test names describe behaviour and cite requirement IDs, for example `'resumes after a network break [FR-DL-006]'`. |
| Structure | Arrange, act, assert. One behaviour per test. |
| Test doubles | Hand-written fakes that implement the `contracts/` interfaces, kept in `app/test/fakes/`. Each fake is maintained by the owner of its interface. A mocking library is optional and needs a `DEPENDENCY_REGISTER.md` entry. |
| Isolation | No real network, backend or WordPress site in unit or widget tests. Use the fixtures in `TEST_DATA_AND_FIXTURES.md`. |
| Time and randomness | Injected, never read directly |
| Widget tests | Each screen is tested in its loading, data, empty and error states (RS FR-STATE-001 to FR-STATE-003). |
| Integration tests | Key flows on an emulator or simulator with fakes, then against ENV-TEST once it exists (`TESTING_STRATEGY.md`) |
| Backend tests | Blocked by DEC-003. Rule: every protected operation has at least one allowed test and one refused test for each access state in RS §9.2. |
| Coverage | Measured and reported. No threshold is agreed. |

## 11. Documentation in Code

1. Every public type and member in `contracts/` and in each feature's public file has a `///` doc comment, including the failures it can return.
2. Comments explain why, not what.
3. TODO format: `// TODO(sa): <text> (OQ-nn)` or `// TODO(yg): ...`. Each TODO cites a question, task or DEC ID.
4. `app/`, `backend/` and `admin/` each get a `README.md` with set-up steps in WP-01 (RS NFR-MAINT-004).

## 12. Dependency and Licence Review

1. Before adding a package, add a `DEPENDENCY_REGISTER.md` entry with:
   - Purpose
   - Licence, taken from the package's LICENSE file
   - Publisher
   - Android and iOS support
   - Maintenance signals
   - Alternatives considered
   - Any cost
2. Any paid or commercially licensed component needs MFW's written approval first (RS NFR-MAINT-006).
3. Prefer packages from the Dart and Flutter teams or verified publishers, and keep the dependency count low.
4. Use caret version constraints in `pubspec.yaml`, and commit `pubspec.lock` for the app.
5. Upgrade dependencies in dedicated pull requests and re-run the full test suite.
6. Keep the third-party licence list current for handover (RS NFR-MAINT-004). PROPOSED: the app shows open-source licences through Flutter's licence page.

## 13. Secret Management

1. No secrets in the repository. Never commit:
   - Android keystores (`*.jks`, `*.keystore`) or `key.properties`
   - Apple certificates and keys (`*.p12`, `*.p8`) or provisioning profiles
   - Service-account key files
   - `.env` files with values
   - API secret keys
2. Supply build-time configuration through `--dart-define` or `--dart-define-from-file`, using files kept out of Git. An example file with placeholder names only is PROPOSED for WP-01.
3. Public client identifiers, such as a backend provider's mobile configuration files, are not secrets but are environment-specific. Whether they are committed is decided with DEC-003 and DEC-023.
4. Signing keys and platform credentials are held in storage that MFW controls. Developers get role-based access (RS NFR-SEC-012; S2 AC-12).
5. `.gitignore` entries for the files above are added in WP-01. They are not added by this document.
6. If a secret is exposed, follow `DEVELOPMENT_WORKFLOW.md` §14.

## 14. Backend Standards (Technology-Neutral)

Specifics are blocked by DEC-003.

1. Every operation in `API_AND_MODULE_CONTRACTS.md` §8 enforces its authorization rule on the server. Deny by default.
2. Validate every input on the server (type, size, format), including upload checks (RS NFR-SEC-008).
3. Write operations that may be retried are idempotent (for example `setFavourite`, `registerDevice`).
4. Return only the error codes in `API_AND_MODULE_CONTRACTS.md` §4.2. Never send stack traces or internal details to clients.
5. Server logs follow Section 6.2.
6. Server secrets live in the provider's secret store, never in code.
7. Every change to an access rule comes with allowed and refused tests.
8. Account deletion removes every piece of reader data listed in RS FR-PRIV-003.
9. A backend change must keep the app version currently in the stores working (`API_AND_MODULE_CONTRACTS.md` §4.5).

## 15. Admin Panel Standards (Technology-Neutral)

Specifics are blocked by DEC-004.

1. The server checks the admin role for every admin operation (RS FR-ADMIN-003). Hiding controls in the interface is not security.
2. No privileged backend credentials in the browser bundle.
3. Session rules follow OQ-20.
4. **CSV exports** (RS FR-USER-001, FR-USER-003):
   - UTF-8 with a header row.
   - Only the approved fields (RS NFR-PRIV-004).
   - A cell that begins with `=`, `+`, `-`, `@`, a tab or a carriage return is escaped, so the file cannot run formulas when opened in a spreadsheet.
5. No personal data kept in browser storage beyond what the session needs.
6. Uploads show progress and a clear result (RS FR-STATE-007). Client-side checks are for convenience. The server enforces them.
7. Publishing, unpublishing and sending a notification ask for confirmation first.

## 16. Review Checklist

The reviewer checks:

| # | Check |
|---|---|
| 1 | Changes stay inside the task's owned paths, or follow the shared-file protocol (`DEVELOPMENT_WORKFLOW.md` §8). |
| 2 | Formatting and analysis are clean (Section 4). |
| 3 | The layer and import rules in Section 3 are respected. |
| 4 | Errors are converted to `AppFailure`. No raw messages reach users. |
| 5 | Nothing in Section 6.2 "never log" appears in logs or usage events. |
| 6 | Access rules are not weakened, and the server enforces them (DEC-007, working position, PROVISIONAL; DEC-009, baseline). |
| 7 | No secrets, no real personal data, no production data. |
| 8 | Tests cover the new behaviour and its failure paths, with requirement IDs in the test names. |
| 9 | Any new dependency has a `DEPENDENCY_REGISTER.md` entry. |
| 10 | Public interfaces have doc comments. Contract changes followed `API_AND_MODULE_CONTRACTS.md` §12. |
