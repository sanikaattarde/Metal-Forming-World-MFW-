# Cloud Access Set-up Checklist: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Cloud Access Set-up Checklist |
| File | `Documentation/CLOUD_ACCESS_SETUP_CHECKLIST.md` |
| Phase | 4: Testing, Release and Risk Management. The first steps of `DEPLOYMENT_PLAN.md` once MFW grants cloud access |
| Version | 0.1 |
| Status | Draft for review. **PLANNED. Nothing in it has been done.** Writing it creates no cloud project, account, bucket, database, credential or billing plan. DEP-05 stays NOT RECEIVED. DEC-003 is OPEN and DEC-023 is PROPOSED, and this checklist decides neither. |
| Date | 8 November 2026 |
| Prepared by | Yuvraj Gaykhe (WS-B), 8 November 2026 |
| Approval required | Both developers. MFW for the provider, the projects, the region and the cost (DEC-003, DEC-023, OQ-40, OQ-41, OQ-53) |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 8 November 2026 | First checklist: what to confirm with MFW when access is granted, the set-up steps and their gates, and the work that can go ahead locally before then. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `DEPLOYMENT_PLAN.md` sections 4, 5, 7 | Exists, draft. Environments, configuration items CFG-01 to CFG-15, and component deployment |
| `CLOUD_INFRASTRUCTURE_AND_COSTS.md` | Exists, draft. Candidate clouds and the cost model, written while DEC-003 is open |
| `DECISION_LOG.md` DEC-003, DEC-023, DEC-031 | Exists, draft. Backend platform (OPEN), environment model (PROPOSED), region |
| `DEPENDENCY_REGISTER.md` DEP-05, DEP-22 to DEP-29, section 10 | Exists, draft. The cloud project input and the backend candidates |
| `CI_CD_AND_QUALITY_GATES.md` section 7 | Exists, draft. Secrets per environment |
| `BACKUP_AND_RECOVERY.md` | Exists, draft. Backup before the first production data (a proposed addition, OQ-46) |
| `DEVELOPMENT_ROADMAP.md` T-01.3, T-01.4, T-01.6, section 4.3, section 4.4 | Exists, draft. The set-up tasks and the work that needs no input |

## 2. What MFW Said

Reported by YG on 8 November 2026, not filed: MFW will provide cloud access next week, which read from 8 November 2026 is the week that starts on Monday 9 November 2026. That is MFW's statement as reported, not a filed commitment. MFW did not say which provider, how many projects, or what kind of access. Update of 8 November 2026: YG reports that none of the items of section 3 is provided yet: the provider, the project identifiers, the roles, the region, a test project and the cost ceiling. The Apple and Google store accounts are not provided either (DEP-06, DEP-07).

Until access is granted, no cloud resource is created or configured in a personal account or in any other project (YG's instruction of 8 November 2026, and `DEVELOPMENT_ROADMAP.md` section 4.3). Cloud-dependent tasks stay blocked.

## 3. Ask MFW When Access Is Granted

Information to record, never secrets. No password, key or token goes into the repository, a pull request or a chat message (`CODING_STANDARDS.md` section 13; `DEPLOYMENT_PLAN.md` section 5.1).

| ID | Item | Why | Tracked in |
|---|---|---|---|
| CA-01 | The provider and products of the account. S1 names Firebase and Google Cloud | DEC-003 is OPEN. The checklist steps after CA-07 depend on it | DEC-003; OQ-35 |
| CA-02 | How many projects: one, or a separate test project as well as production | DEC-023 proposes three environments, two of them in MFW's account | DEC-023; OQ-40 |
| CA-03 | The project identifiers | Configuration item CFG-01 | CFG-01 |
| CA-04 | Who owns the billing account, and that billing is switched on | S1 asks for a project with billing switched on. Usage is billed to MFW | DEP-05; S1 Costs outside the fee |
| CA-05 | Each developer's access, by a named role in MFW's account and through the developer's own sign-in, never a shared password | RS NFR-SEC-012 | T-01.3 |
| CA-06 | The region for the data and backups | Working position Mumbai (asia-south1), PROPOSED. MFW and its legal adviser decide | OQ-41; CFG-02; DEC-031 |
| CA-07 | The monthly cost ceiling, the budget alerts MFW wants, and who receives them | No ceiling is recorded | OQ-53; OQ-47 |
| CA-08 | The billing currency and tax setup | Affects every cost figure | `CLOUD_INFRASTRUCTURE_AND_COSTS.md` CL-01 |
| CA-09 | Who at MFW administers the account and can add or remove access | Handover records the holders, never the values (S2 Handover) | OQ-47 |

## 4. Set-up Steps and Their Gates

PLANNED. Each step starts only when its gate is met, and each result is recorded with its date in the document named.

| Step | Action | Gate | Record in |
|---|---|---|---|
| S-01 | Each developer signs in with their own account and checks the role granted (T-01.3) | Access granted (CA-05) | `DEPENDENCY_REGISTER.md` DEP-05; `DEVELOPMENT_ROADMAP.md` section 4.2 row 5 |
| S-02 | Record the project identifiers and the region | CA-03; OQ-41 answered | `DEPLOYMENT_PLAN.md` CFG-01, CFG-02 |
| S-03 | Check the billing plan, and set the budget alerts in MFW's account with MFW's approval | CA-04; CA-07 | `CLOUD_INFRASTRUCTURE_AND_COSTS.md` |
| S-04 | Switch on only the services the backend decision names | DEC-003 AGREED | `DEPENDENCY_REGISTER.md` DEP-22 to DEP-29 |
| S-05 | Add the register rows for the server-side tools (Node.js, TypeScript, the server packages, the provider's command line tools) in the pull request that merges the first backend code | That pull request | `DEPENDENCY_REGISTER.md` section 10 |
| S-06 | Deploy the backend skeleton, the access rules and their tests to the test environment from a tag (T-01.4), then the admin panel skeleton (T-01.6) | DEC-003 AGREED; DEC-004 for the admin panel; the test environment approved (OQ-40) | `DEPLOYMENT_PLAN.md` sections 6 and 7 |
| S-07 | Run the smoke tests SM-01 to SM-12 that apply to the test environment | S-06 | `DEPLOYMENT_PLAN.md` section 6 |
| S-08 | Run again on the test environment the cases the emulator evidence names | S-06 | `test-evidence/BACKEND_RULES_EMULATOR_EVIDENCE.md` |
| S-09 | Store the CI deploy credentials as environment secrets, if CI deploys | QG-08 and QG-09 planned in CI | `CI_CD_AND_QUALITY_GATES.md` section 7 |
| S-10 | Set up backup before the first production data | OQ-46 | `BACKUP_AND_RECOVERY.md` |
| S-11 | Set up production only after the test environment passes S-07 | S-07 | `DEPLOYMENT_PLAN.md` section 7 |
| S-12 | Record every credential holder by name and role, never the values | Each step that grants access | S2 Handover; `MAINTENANCE_AND_HANDOVER.md` |

If MFW provides one project only, the team and MFW agree in writing how testing avoids production data before S-06 (`DEPLOYMENT_PLAN.md` section 4; R17).

## 5. What Can Be Written Now and Moved Later

The code that needs no cloud account can be written now on the developers' machines (ENV-LOCAL) and deployed once access and the decisions are in place. The rules of `DEVELOPMENT_ROADMAP.md` section 4.3 still apply: work that rests on an OPEN or PROPOSED decision stays on a `spike/` branch and is not merged as production code (`DEFINITION_OF_DONE.md` section 5 check 2).

| Work | Where it runs now | How it moves to the cloud |
|---|---|---|
| App modules against the shared contracts and fakes (MOD-00), such as the shell, the catalogue on seeded data, downloads on the app side and the reader interface | `main`, on simulators and emulators | The fakes are swapped for the real providers once DEC-003 is AGREED |
| The WordPress client and its fixture tests (T-08.1) | `main`; the public response shapes are recorded in `test-evidence/WORDPRESS_PUBLIC_SITE_EVIDENCE.md` | No cloud step. The live read waits for OQ-39 |
| Access rules, server functions and the admin panel | `spike/` branches against the local emulators (the backend and admin spikes) | S-06, after DEC-003 and DEC-004 |
| Design tokens and the app theme from `BRAND_REFERENCE.md`, PROVISIONAL | `main` | No cloud step |
| This checklist and the configuration item list | `main` | Filled in at S-01 and S-02 |

This document only plans this work. It changes no application code and no infrastructure.
