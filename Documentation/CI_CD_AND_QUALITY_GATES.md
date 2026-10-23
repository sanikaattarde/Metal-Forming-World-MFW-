# CI/CD and Quality Gates: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | CI/CD and Quality Gates |
| File | `Documentation/CI_CD_AND_QUALITY_GATES.md` |
| Phase | 4 — Testing, Release and Risk Management (document 33) |
| Version | 0.2 |
| Status | Draft for review. Not approved. **PLANNED: no CI/CD exists and no check runs automatically.** |
| Date | 23 October 2026 |
| Approval required | Both developers (DEC-022). MFW if any cost is billed to MFW. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. QG-12 states that its script is not in the repository. Planned name replaced by the existing document. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `TESTING_STRATEGY.md` | Exists (draft). The suites these gates run. |
| `DEFINITION_OF_DONE.md` | Exists (draft). Gates referenced by DoD-TASK, DoD-INT and DoD-RC. |
| `DEVELOPMENT_WORKFLOW.md` | Exists (draft). Branch roles and pull-request flow. |
| `CODING_STANDARDS.md`, `DEPENDENCY_REGISTER.md`, `DEPLOYMENT_PLAN.md`, `DECISION_LOG.md` | Exist (draft) |
| `TECHNOLOGY_DECISIONS.md` | Exists on `main` (draft). It was planned as `TECH_STACK_DECISIONS.md`. Backend and admin gates wait for its decisions. |

Status labels follow RS §1.2. **PLANNED** means designed, not implemented. Availability labels follow `DEFINITION_OF_DONE.md` §3.

## 2. Purpose, Scope and Status

This document proposes the automated checks that guard pull requests, integration into `main`, and releases. It also sets the rules for signing, environments, secrets and approvals.

**Verified current state (23 October 2026).** The repository contains only `README.md` and `Documentation/`. There is no `.github/` directory, no workflow file, no app project and no build script. Nothing described here is running. This document creates no workflow file.

## 3. Proposed CI Service

| Item | Proposal | Status |
|---|---|---|
| Service | GitHub Actions, since the repository is hosted on GitHub | DEC-022, PROPOSED |
| Runners | Linux for formatting, analysis, tests and Android builds. macOS for iOS builds, which need Xcode. | PROPOSED |
| Constraint | Runner minutes, macOS minute cost, and feature availability (environments, required reviewers) depend on the account plan and repository visibility | Not verified |
| After handover | CI moves with the repository to MFW's ownership (OQ-48). Secrets are re-created in MFW's account. | PLANNED |

## 4. Quality Gates

| Gate | Check | Command or tool (candidate) | Runs on | Blocks merge | Available | Implements |
|---|---|---|---|---|---|---|
| QG-01 | Formatting | `dart format --output=none --set-exit-if-changed .` | Every pull request | Yes | [SCAFFOLD] | TS-01 |
| QG-02 | Static analysis | `flutter analyze`, failing on any issue (confirm the default behaviour for the Flutter version pinned under OQ-50) | Every pull request | Yes | [SCAFFOLD] | TS-01 |
| QG-03 | Unit and widget tests | `flutter test` | Every pull request | Yes | [SCAFFOLD] | TS-02, TS-03 |
| QG-04 | Coverage report | `flutter test --coverage` | Every pull request | No: report only. No threshold agreed. | [SCAFFOLD] | — |
| QG-05 | Android build check | `flutter build apk --debug` | Pull requests that touch `app/` | Yes | [SCAFFOLD] | DoD-INT 2 |
| QG-06 | iOS build check | `flutter build ios --no-codesign` on macOS | Pull requests that touch `app/`; every merge to `main` | Yes | [SCAFFOLD] | DoD-INT 2 |
| QG-07 | App integration tests | `flutter test integration_test` on an emulator | Every merge to `main`; release candidates | Yes, on `main` | [SCAFFOLD] | TS-04 |
| QG-08 | Backend and authorization-rule tests | Blocked by DEC-003 | Pull requests that touch `backend/` | Yes | [BACKEND] | TS-05 |
| QG-09 | Admin panel build and tests | Blocked by DEC-004 | Pull requests that touch `admin/` | Yes | [BACKEND] | TS-05 |
| QG-10 | Dependency and licence check | A script comparing `pubspec.lock` with `DEPENDENCY_REGISTER.md` (planned); `flutter pub outdated` report; published advisory check | Pull requests that touch dependency files; weekly | Yes, for an unregistered dependency | [SCAFFOLD] | SEC-CHK-13 |
| QG-11 | Secrets scan | Candidate: gitleaks, or GitHub secret scanning if the plan includes it | Every pull request and push | Yes | [CI] | SEC-CHK-09 |
| QG-12 | Documentation checks | A check of IDs, references, file names, status labels and links. The script that was used when the documents were drafted is not in the repository, so the check cannot be reproduced from the repository and is PLANNED, not available; link check | Pull requests that touch `Documentation/` | Yes | [NOW] (manual until CI exists) | DoD-DOC |
| QG-13 | Release build and signing | Tag-triggered signed Android App Bundle and iOS archive; manual approval | Release tags `v*` | Not a merge gate | [STORE] | AC-11.1 |

## 5. Pipelines

### 5.1 Pull-request validation (PLANNED)

```
pull request opened or updated
  → QG-11 secrets scan
  → QG-01 format → QG-02 analyze → QG-03 tests (+ QG-04 report)
  → QG-05 Android build, QG-06 iOS build      (if app/ changed)
  → QG-08 backend tests                       (if backend/ changed)
  → QG-09 admin build                         (if admin/ changed)
  → QG-10 dependency check                    (if dependency files changed)
  → QG-12 documentation check                 (if Documentation/ changed)
  → review by the other developer (DEVELOPMENT_WORKFLOW.md §6)
```

### 5.2 Integration on `main` (PLANNED)

Every merge to `main` runs the pull-request gates, plus QG-06 and QG-07 unconditionally. A red `main` is fixed before any other merge.

### 5.3 Release (PLANNED)

```
release tag vMAJOR.MINOR.PATCH on main (after DoD-RC)
  → full gate set
  → QG-13: build the signed Android App Bundle and iOS archive from the tag
  → manual approval by both developers
  → upload to store testing tracks — only by an explicit human action
  → store submission — only after MFW approves (S2 M5; AC-11.2)
```

No pipeline submits to a store, deploys to production, or contacts MFW's accounts without an explicit human approval step.

### 5.4 Scheduled (PLANNED)

A weekly dependency and advisory report (QG-10). It never changes files automatically.

## 6. Release Tagging and Signed Builds

| Rule | Detail |
|---|---|
| Tag format | `vMAJOR.MINOR.PATCH` on `main` only (DEC-015). Never moved or deleted. |
| App version | `pubspec.yaml` `version: MAJOR.MINOR.PATCH+BUILD`. The build number rises with every store upload. |
| Source of release builds | Only the tagged commit (S2 AC-11) |
| Android signing | Google Play App Signing with an upload key held in MFW-controlled storage. Never committed. Holder recorded at handover (S2 Handover). |
| iOS signing | Distribution certificate and provisioning in MFW's Apple Developer account. Never committed. |
| Where signing runs | In CI, using secrets stored for the release environment only, or on a designated machine with MFW's agreement. Decision OPEN. |
| Evidence | Build logs linking the tag, the commit and the artifact checksums, kept for AC-11.1 |

## 7. Environment Separation and Secrets in CI

| Environment | Used by | Configuration source | Who can trigger |
|---|---|---|---|
| ENV-LOCAL | Pull-request builds and tests | Committed example configuration with placeholders | Any pull request |
| ENV-TEST | Integration and end-to-end runs on `main` | CI secrets scoped to the test environment | Merges to `main` |
| ENV-PROD | Release builds and production deploys | CI secrets scoped to production, with manual approval | Both developers, after release approval |

Rules:

1. Pull requests, and especially those from forks, never receive production secrets.
2. Production configuration is used only by the release pipeline.
3. Secret values are never printed in logs.
4. Environments and approvals follow `DEPLOYMENT_PLAN.md` §4 and §5.

## 8. Dependency and Licence Checks

1. Every package in `pubspec.lock` must have a `DEPENDENCY_REGISTER.md` entry, or QG-10 fails.
2. Licence information comes from the package's own LICENSE file and is recorded by a developer. The tool only compares lists. It does not judge licences.
3. A paid or commercially licensed component needs MFW's written approval (RS NFR-MAINT-006).
4. Published advisories for dependencies are reviewed. A known critical issue blocks the release until it is assessed.

## 9. Secrets Scanning

QG-11 scans every change for keys, tokens, keystores and credential files. On a finding:

1. Stop the merge.
2. If the secret reached GitHub, treat it as compromised. The account holder revokes or rotates it (`DEVELOPMENT_WORKFLOW.md` §14).
3. Record the incident in the pull request, without the secret value.

## 10. Security Checks in CI

| Check | Gate |
|---|---|
| Authorization-rule tests (allowed and refused) for every operation | QG-08 |
| No secrets in the repository | QG-11 |
| Dependencies registered and advisories reviewed | QG-10 |
| HTTPS-only configuration in the app projects | Manual SEC-CHK-01 before release. Automating it is PROPOSED for later. |
| The rest of the security checklist | Manual, `TESTING_STRATEGY.md` §9 |

## 11. Failure Handling

| Situation | Rule |
|---|---|
| A required gate fails | The merge is blocked. The author fixes it. |
| An infrastructure failure (runner outage) | One re-run is allowed, with a note in the pull request |
| An intermittent test | Fixed, or quarantined in its own pull request with a tracking issue. Never silently skipped. |
| `main` is red | Fixing it takes priority over other merges |
| An urgent bypass | Only with both developers' written agreement in the pull request, plus a follow-up task. Never for QG-08 or QG-11. |

## 12. Approval Gates

| Step | Approval needed |
|---|---|
| Merge to `main` | All required gates green, plus approval from the other developer |
| Creating a release tag | Both developers |
| Production backend or admin deploy | Both developers, with MFW informed (`DEPLOYMENT_PLAN.md` §8) |
| Store submission | MFW's approval of the build and the listing text (S2 M5; AC-11.2) |

## 13. Cost and Account Considerations

- CI usage is billed to the account that owns the repository. That is currently `sanikaattarde`, and later MFW (OQ-48).
- macOS runners use more of the minute allowance than Linux runners.
- Any CI cost billed to MFW needs MFW's approval (DEC-022). No price is quoted here, because provider prices change.

## 14. Implementation Steps (Not Performed)

1. Agree DEC-022 and this document.
2. Create the app scaffold (T-01.1).
3. Add workflow files for QG-01 to QG-06, QG-11 and QG-12 (T-01.5).
4. Add QG-07 once integration tests exist.
5. Add QG-08 and QG-09 once DEC-003 and DEC-004 are decided.
6. Configure environment secrets after DEC-023 and the MFW account access in T-01.3.
7. Add QG-13 once the store accounts and signing are set up (OQ-42).

## 15. Open Items

| Item | Reference |
|---|---|
| CI service and cost | DEC-022 |
| Toolchain versions | OQ-50 |
| Backend and admin gates | DEC-003, DEC-004 |
| Where release signing runs, and who holds the keys | Section 6; `MAINTENANCE_AND_HANDOVER.md` |
| GitHub plan features (environments, secret scanning, branch protection) | Not verified |
