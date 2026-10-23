# Changelog: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/CHANGELOG.md` |
| Phase | 3 — Development Planning and Collaboration (document 29) |
| Version | 0.1 |
| Status | Draft for review. Not approved. The conventions are PROPOSED (DEC-015). |
| Date | 23 October 2026 |
| Prepared in | Sanika Attarde's Claude Code session, branch `SA` |

**Purpose.** A chronological record of changes to the repository. It keeps verified history (from Git and from each document's own change table) apart from work not yet merged to `main`, and from future releases. It invents no releases, tags or dates.

**Related documents**

| Document | Status on 23 October 2026 |
|---|---|
| `DECISION_LOG.md` DEC-015 | Exists, created in this task. Commit, changelog and version conventions (PROPOSED). |
| `DEVELOPMENT_WORKFLOW.md` §8, §11 | Exists, created in this task. How pull requests add changelog lines. |
| `APP_STORE_RELEASE_CHECKLIST.md` §8 | Exists, created in this task. When a version section is added. |

## Conventions

PROPOSED (DEC-015).

1. **Unreleased** lists changes merged, or prepared for merge, since the last release tag. Each pull request adds its own line (`DEVELOPMENT_WORKFLOW.md` §8).
2. **Version sections** (`## [1.0.0] - <date>`) are added only when a release tag `vMAJOR.MINOR.PATCH` is created on `main`. No version has been released.
3. **Repository history** records changes that Git shows, with their commit hashes. It never records changes that cannot be verified.
4. Entry types: **Added**, **Changed**, **Fixed**, **Removed**, **Security**, **Documentation**.
5. Dates use `YYYY-MM-DD`. A date is given only when Git or a document's own history shows it.
6. Each entry cites the files changed and, where relevant, requirement, decision or task IDs.

## Unreleased

### Documentation — committed on `SA` on 2026-10-23, not merged to `main`, not reviewed

These were drafted in Sanika Attarde's Claude Code session on branch `SA`, on top of commit `8941964`, and committed to `SA` in a single commit. When that commit was made, it had not been pushed or merged to `main`. Every document is a draft v0.1 awaiting review by both developers.

**Added: Phase 3, development planning and collaboration**

- `Documentation/DEVELOPMENT_WORKFLOW.md`: branch roles, pull requests, integration, shared files, recovery (DEC-010)
- `Documentation/TASK_OWNERSHIP_MATRIX.md`: proposed workstreams and module, document and acceptance ownership (DEC-011)
- `Documentation/DEVELOPMENT_ROADMAP.md`: work packages WP-00 to WP-12 in relative weeks, internal estimates, blocked tasks
- `Documentation/API_AND_MODULE_CONTRACTS.md`: modules MOD-00 to MOD-13, technology-neutral operations, integration contracts IC-01 to IC-08
- `Documentation/CODING_STANDARDS.md`: Flutter and Dart standards; technology-neutral backend and admin principles
- `Documentation/CLAUDE_CODE_WORKING_RULES.md`: rules for both Claude Code sessions
- `Documentation/DEFINITION_OF_DONE.md`: DoD-DOC to DoD-HO, with gate-availability labels
- `Documentation/DECISION_LOG.md`: decision record with DEC-001 to DEC-024. None is AGREED or APPROVED.
- `Documentation/CHANGELOG.md`: this file

**Added: Phase 4, testing, release and risk management**

- `Documentation/TESTING_STRATEGY.md`: test suites TS-01 to TS-13 and the proposed security checklist SEC-CHK-01 to SEC-CHK-16
- `Documentation/ACCEPTANCE_CRITERIA.md`: verification checks for S2 AC-1 to AC-12, PAC-01 to PAC-11 from RS, and new proposals PAC-12 to PAC-15
- `Documentation/TEST_DATA_AND_FIXTURES.md`: synthetic fixture definitions (FX-*). No fixture files created.
- `Documentation/CI_CD_AND_QUALITY_GATES.md`: proposed gates QG-01 to QG-13. No workflow files created.
- `Documentation/DEPLOYMENT_PLAN.md`: environments, configuration items, smoke tests, release order, rollback
- `Documentation/APP_STORE_RELEASE_CHECKLIST.md`: Android and iOS checklists. Nothing submitted.
- `Documentation/BACKUP_AND_RECOVERY.md`: proposed backup approach. All values need MFW's approval.
- `Documentation/MAINTENANCE_AND_HANDOVER.md`: handover checklist HO-01 to HO-16; warranty and maintenance terms quoted from S1 and S2
- `Documentation/RISK_REGISTER.md`: CH R1 to R11 carried over; R12 to R22 added
- `Documentation/DEPENDENCY_REGISTER.md`: client inputs, accounts, candidates and tools (DEP-*)
- `Documentation/OPEN_QUESTIONS.md`: consolidated register; RS OQ-01 to OQ-31 kept; OQ-32 to OQ-50 added

**Not changed:** `README.md`, `Documentation/PROJECT_CHARTER.md`, `Documentation/REQUIREMENTS_SPECIFICATION.md`, `Documentation/MFW_Statement_of_Work.pdf`, `Documentation/MFW_Commercial_Proposal-2.pdf`.

## Repository History

From Git on 2026-10-23.

### 2026-10-23 — `8941964` "Add project documentation"

Author: YuvrajGaykhe. On `main` (`origin/main`). A single-parent commit; no pull request is visible in local metadata.

- **Added** `Documentation/PROJECT_CHARTER.md`: v0.1, "Draft for review", dated 22 October 2026 in its own history
- **Added** `Documentation/REQUIREMENTS_SPECIFICATION.md`: v0.1, "Draft for Review", dated 22 October 2026 in its own history
- **Added** `Documentation/MFW_Statement_of_Work.pdf`: dated 17 October 2026, unsigned copy
- **Added** `Documentation/MFW_Commercial_Proposal-2.pdf`: dated 17 October 2026, unsigned copy

### 2026-10-20 — `3e642e0` "Initial commit"

Author: sanikaattarde, committed through GitHub.

- **Added** `README.md` (title only)

## Releases

None. No release tags exist (verified 2026-10-23).
