# Development Workflow: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Development Workflow |
| File | `Documentation/DEVELOPMENT_WORKFLOW.md` |
| Phase | 3 — Development Planning and Collaboration (document 21) |
| Version | 0.1 |
| Status | Draft for review. Not approved. The branching model is DEC-010, PROPOSED. |
| Date | 23 October 2026 |
| Prepared in | Sanika Attarde's Claude Code session, branch `SA` |
| Approval required | Both developers (AGREED in `DECISION_LOG.md`). No MFW approval: process only. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `PROJECT_CHARTER.md` (CH) §17.5 | Exists, draft. States the source-control principle this document expands. |
| `DECISION_LOG.md` | Exists, created in this task. DEC-010, DEC-012, DEC-015. |
| `TASK_OWNERSHIP_MATRIX.md` | Exists, created in this task. Owned paths and shared files. |
| `CLAUDE_CODE_WORKING_RULES.md` | Exists, created in this task. Session rules that apply this workflow. |
| `CODING_STANDARDS.md`, `DEFINITION_OF_DONE.md`, `CHANGELOG.md` | Exist, created in this task |
| `CI_CD_AND_QUALITY_GATES.md` | Exists, created in this task. All gates are PLANNED. |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal made in this document. In RS terms it is an ASSUMPTION (DEV): it has no force until both developers agree.

## 2. Purpose, Scope and Status

This document defines how the two developers work in one shared GitHub repository without overwriting each other's work. It covers branches, pull requests, integration order, shared files, testing before review, commit messages, documentation changes and recovery.

It applies to code, configuration and documents. Every rule here is PROPOSED until both developers agree (DEC-010). GitHub settings are not assumed. Section 15 lists the settings proposed for the repository owner.

## 3. Current Repository State

Verified with local Git on 23 October 2026. The remote was last fetched the same day.

| Item | State | Evidence class |
|---|---|---|
| Remote | `origin` = `https://github.com/sanikaattarde/Metal-Forming-World-MFW-.git` | CONFIRMED (local config) |
| `main` on GitHub | `8941964` "Add project documentation" | CONFIRMED (fetched) |
| `SA` on GitHub | `3e642e0` "Initial commit". It does not contain the Phase 1 documents. | CONFIRMED (fetched) |
| `YG` on GitHub | `3e642e0`. It does not contain the Phase 1 documents. | CONFIRMED (fetched) |
| Local `SA` (Sanika Attarde's checkout) | Two commits ahead of `origin/SA`, not pushed: `8941964` (the Phase 1 documents, from `main`) and the commit that adds the Phase 3 and Phase 4 documents. | CONFIRMED |
| Tags | None | CONFIRMED |
| CI | None. There is no `.github/` directory. | CONFIRMED |
| Branch protection on GitHub | Not verified from local Git | OPEN |
| How `8941964` reached `main` | A single-parent commit by YuvrajGaykhe, with no pull request visible in local metadata. Whether it was reviewed cannot be verified locally. | OPEN |

## 4. Branch Roles

| Branch | Role | Who changes it | Rules (PROPOSED) |
|---|---|---|---|
| `main` | Stable integration branch (CH §17.5). The source of release tags. | Only by merging a reviewed pull request | No direct commits or pushes. No force pushes. Never deleted. Each merge must meet `DEFINITION_OF_DONE.md` §7 (DoD-INT). |
| `SA` | Sanika Attarde's long-lived working branch (CH §7, §14) | Sanika Attarde only | Source of Sanika Attarde's pull requests into `main`. Kept up to date with `main` (Section 5). No force push once shared. |
| `YG` | Yuvraj's long-lived working branch (CH §7, §14) | Yuvraj only | Same as `SA` |
| Topic branches | Optional short-lived branches for a task that runs in parallel with other work on the same developer's branch, or for a spike | The developer who created it | Named as below. Cut from the developer's own up-to-date branch. Deleted after merge. |
| Release tags | Immutable markers of released source (S2 AC-11) | Created on `main` only, after release approval | Format `vMAJOR.MINOR.PATCH` (DEC-015). Never moved or deleted. |

**Topic branch naming (PROPOSED).** Use `<type>/<initials>-<topic>`, with lowercase initials and hyphenated topic words. Examples: `feat/sa-email-sign-in`, `docs/yg-reader-test-report`, `spike/yg-pdf-renderer`. Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `spike`.

Do not use `SA/<topic>` or `sa/<topic>`. Git cannot hold a branch `SA` and a branch `SA/<topic>` at the same time. This checkout also has `core.ignorecase=true`, so `sa/<topic>` collides with `SA` on a case-insensitive file system.

**The other developer's branch.** Never commit to it, push to it, reset it, or check it out to edit. Reading it (`git log origin/YG`, `git diff origin/main...origin/YG`) is allowed.

## 5. Working Independently

1. **Start of each task.** Bring your own branch up to date with `origin/main`. Use a fast-forward when your branch has no unmerged work. Otherwise merge `origin/main` into your branch.
2. **One task per pull request.** A task is one item from `DEVELOPMENT_ROADMAP.md`, for example a `T-03.2` step, or one document. Keep pull requests small enough to review in one sitting.
3. **Stay in your owned paths.** `TASK_OWNERSHIP_MATRIX.md` §6 lists the paths each workstream owns. Editing outside them follows Section 8.
4. **Claim before you start.** Open a draft pull request as soon as you start a task. The draft is the visible claim that the work is active. Do not edit `TASK_OWNERSHIP_MATRIX.md` to claim work.
5. **Depend on interfaces, not implementations.** Cross-workstream work goes through the contracts in `API_AND_MODULE_CONTRACTS.md`. Use a fake implementation until the real one is merged.
6. **Push your own branch often.** Weekly commits with notes are a contractual expectation [S2 Responsibilities]. Pushing is always a separate, deliberate action by the developer.

## 6. Pull Request and Review Workflow

### 6.1 Opening a pull request

Each pull request description includes:

| Field | Content |
|---|---|
| Task | Roadmap task ID, or document number |
| Requirements | RS IDs (for example `FR-DL-006`) and acceptance IDs (for example `AC-4.3`) |
| Decisions | DEC IDs relied on. Flag any that are still OPEN or PROPOSED. |
| Files | The paths changed. Note any shared or high-risk files (`TASK_OWNERSHIP_MATRIX.md` §8). |
| Tests | What was run and the result, with output or screenshots as evidence. Say what was not run and why. |
| Open points | New questions, added to `OPEN_QUESTIONS.md` in the same pull request |

### 6.2 Review

- **Reviewer.** The other developer reviews every pull request into `main` (CH §17.5).
- **Response time (PROPOSED).** The reviewer responds within one working day, by approving, requesting changes, or saying when they will review.
- **Review checklist.** `CODING_STANDARDS.md` §16 for code. `DEFINITION_OF_DONE.md` §4 for documents.
- **Who merges.** After approval, the reviewer merges. This puts the "reviewed integration by the other developer" (CH §17.5) into practice.
- **Ignored approvals.** An approval of an older version does not count after new commits. The reviewer re-checks the changes since their approval.

### 6.3 Merge method

Use **"Create a merge commit"** for pull requests from `SA` or `YG` into `main`. Do not squash or rebase-merge them.

The reason: squash and rebase merges create new commit hashes on `main`. The long-lived `SA` or `YG` branch then diverges and can only be re-synchronised by rewriting it. With a merge commit, the developer's branch can fast-forward to `main` after each merge.

Topic branches that are deleted after merge may be squash-merged if both developers prefer it.

## 7. Integration and Merge Sequencing

1. **Contracts first.** A change to a shared interface (MOD-00 in `API_AND_MODULE_CONTRACTS.md`) or a shared file is merged in its own small pull request before the work that uses it.
2. **Provider before consumer.** A backend operation and its authorization rules are merged before the app feature that calls them. Until then the app uses a fake.
3. **One integration at a time.** Before merging, the reviewer checks that the pull request is up to date with `main`. If another merge landed first, the author merges `main` into the branch and re-runs the checks.
4. **Sync after each merge.** After any merge into `main`, both developers update their branches from `main` before their next push. PROPOSED target: the same working day.
5. **Milestone integration builds.** Before each milestone demo (M3, M4) and the acceptance build, both developers freeze feature merges. Only fixes are merged until the build is cut from `main` (`DEFINITION_OF_DONE.md` §7).

## 8. Conflict Prevention and Shared Files

| Rule | Detail |
|---|---|
| Owned paths | Edit only the paths your workstream owns (`TASK_OWNERSHIP_MATRIX.md` §6). |
| Shared-file protocol | For a file listed in `TASK_OWNERSHIP_MATRIX.md` §8: (1) say in the draft pull request that you intend to change it; (2) keep the change in a small, dedicated pull request; (3) the file's primary editor reviews it; (4) merge it before dependent work; (5) the other developer syncs from `main`. |
| Dependency files | Only the primary editor changes `app/pubspec.yaml`. The lock file is regenerated by the tool, never merged by hand. A new dependency needs a `DEPENDENCY_REGISTER.md` entry first (`CODING_STANDARDS.md` §12). |
| Generated files | Never edit generated files by hand. Regenerate them. |
| Formatting | Never reformat files you are not otherwise changing. A formatting-only change is its own pull request. |
| Renames and moves | Never rename or move another workstream's files. Raise it with the owner. |
| Registers | `DECISION_LOG.md`, `OPEN_QUESTIONS.md`, `RISK_REGISTER.md` and `DEPENDENCY_REGISTER.md` each have one primary editor. Anyone may add a new entry in a pull request. The primary editor reviews it and resolves numbering. |
| Changelog | Each pull request adds its own line under "Unreleased" in `CHANGELOG.md`. On a conflict in that file, keep both lines. |

## 9. Conflict Resolution

1. Merge `origin/main` into your own branch. Do not rebase a branch that has been pushed.
2. Resolve each conflict by keeping both sides' intent. If the conflict involves the other workstream's file, ask its owner before choosing.
3. Never resolve a conflict by discarding the other developer's change without their agreement.
4. If a merge goes wrong, `git merge --abort` returns to the state before the merge.
5. After resolving, run the checks in Section 10 again and say in the pull request that a conflict was resolved and how.

## 10. Testing Before Review

| Gate availability | Checks before asking for review |
|---|---|
| Now (documents only) | Every cited ID exists in its source document. Every referenced file exists, or is marked as planned. Status labels are present. No dates, approvals or results are invented (`DEFINITION_OF_DONE.md` §4). |
| After the app scaffold exists (WP-01) | `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and `flutter test` for the changed area all pass locally. Screenshots for any UI change. |
| After the backend is chosen (DEC-003) | Backend and authorization-rule tests for the operations changed, including tests that are refused |
| After CI exists | All required checks in `CI_CD_AND_QUALITY_GATES.md` pass on the pull request |

## 11. Commit Message Convention

PROPOSED (DEC-015). This document defines the convention but no commit is made by it.

```
<type>(<scope>): <summary in the imperative, at most 72 characters>

<body: what changed and why. Wrap at 72 characters.>

Refs: <RS IDs, AC IDs, DEC IDs, roadmap task ID>
```

- `type` is one of `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `build`, `ci`.
- `scope` is a module ID in lowercase (`mod-06`), a feature folder name (`downloads`), or a document name (`decision-log`).
- Examples:
  - `feat(downloads): resume interrupted issue downloads` with `Refs: FR-DL-006, AC-4.3, T-06.3`
  - `docs(decision-log): propose DEC-013 state management` with `Refs: DEC-013`
- Never put secrets, tokens, personal data or real user names from production in a commit.
- A commit created with help from a Claude Code session carries that session's co-author trailer.

## 12. Documentation Change Workflow

1. Documentation changes use the same pull-request flow as code, in separate pull requests from code.
2. Each change updates the document's version and change-history table and keeps its status label accurate. A draft stays "Draft for review" until the approval record shows otherwise.
3. **Phase 1 and Phase 2 documents.** `PROJECT_CHARTER.md`, `REQUIREMENTS_SPECIFICATION.md` and the planned Phase 2 documents need both developers' review. Requirement IDs are never renumbered. RS §14.3 sets the rules for withdrawing an ID.
4. **Section references.** RS cites CH by section number (for example "CH §17.3"). Renumbering a section in either document breaks those references, so add sections at the end or update every reference in the same pull request.
5. **MFW-facing documents.** Documents that MFW approves (the M1 note, screens, acceptance evidence) are sent by the contracting developer. MFW's written reply is recorded in `DECISION_LOG.md`, or as the approval record inside the document.
6. **Source evidence.** Client emails or signed copies that settle an OPEN item are filed in the repository only with MFW's consent, because they may contain personal data. Otherwise a reference is recorded: date, sender role and subject.

## 13. Architecture Decision Workflow

1. A change to architecture, a technology, the data model or a shared contract starts as a `DECISION_LOG.md` entry (OPEN or PROPOSED).
2. Both developers agree (AGREED). Where CH §17.4 applies, MFW approves in writing (APPROVED).
3. The affected documents are updated: the planned Phase 2 documents, `API_AND_MODULE_CONTRACTS.md` and `CODING_STANDARDS.md`.
4. Only then is production code written against the decision.
5. **Spikes.** Before a decision, exploratory work is allowed on a `spike/` topic branch to gather evidence (for example, the WP-02 reader test). A spike is not merged into `main` as production code. Its findings are merged as a document.

## 14. Safe Recovery Procedures

| Situation | Safe action | Do not |
|---|---|---|
| You need to switch tasks with uncommitted work | Commit it as a work-in-progress commit on your own branch, or on a topic branch | `git checkout -- .`, `git reset --hard`, `git clean` |
| You committed to the wrong branch and have not pushed | Create a branch at that commit (`git branch <new-branch> <commit>`). Once the commit is safe there, move only your own branch back with `git reset --keep <earlier-commit>`, which refuses to discard uncommitted changes. | Reset a branch that someone else uses |
| A bad change is already merged to `main` | Revert it with `git revert` in a new pull request | Reset or force-push `main` |
| A merge goes wrong | `git merge --abort` | Resolve by taking one side wholesale |
| A commit seems lost | Find it with `git reflog`, then `git branch rescue/<name> <commit>` | Run garbage collection or prune |
| Your branch has diverged from `main` | Merge `origin/main` into your branch | Rebase a branch that has been pushed |
| You edited another workstream's file by mistake and have not committed | Check the diff, then restore only that path (`git restore --source=HEAD -- <path>`), and tell the owner | Commit it |
| A secret was committed or pushed | Treat it as compromised. The account holder revokes or rotates it with the provider at once. Then remove it from the code. Any history rewrite needs both developers' and MFW's agreement. | Assume that a later commit deleting it is enough |

## 15. Proposed Repository Settings

These settings are proposed for the repository owner (currently the `sanikaattarde` GitHub account). None of them is verified as configured.

| Setting | Proposal |
|---|---|
| `main` protection | Require a pull request with one approval. Require approval after the latest push. Block force pushes and deletion. Once CI exists, require its checks to pass. |
| `SA` and `YG` protection | Block force pushes and deletion |
| Availability | Branch protection on a private repository depends on the GitHub plan. If it is unavailable, these rules are kept by agreement and by `CLAUDE_CODE_WORKING_RULES.md`. |
| Collaborator access | Each developer gets the lowest access that lets them push their own branch and review |

## 16. Immediate Actions (Not Performed)

These actions change Git state. They are listed for the developers to decide on and are not carried out by this document.

| # | Action | Who |
|---|---|---|
| 1 | Review this document and the other Phase 3 and Phase 4 documents, then commit them on `SA` | Sanika Attarde |
| 2 | Push `SA`, then open a pull request from `SA` into `main` for the documents | Sanika Attarde |
| 3 | Fast-forward `YG` to `origin/main` so it holds the Phase 1 documents | Yuvraj |
| 4 | Agree DEC-010, or record the changes wanted | Both |
| 5 | Configure the settings in Section 15, if available | Repository owner |

## 17. Open Points

- DEC-010 is PROPOSED and needs both developers' agreement.
- Whether `8941964` was reviewed before it reached `main` is not recorded. From now on, Section 6 applies.
- GitHub plan and repository visibility, which decide whether Section 15 is available, are not verified.
