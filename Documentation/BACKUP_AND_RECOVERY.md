# Backup and Recovery: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Backup and Recovery |
| File | `Documentation/BACKUP_AND_RECOVERY.md` |
| Phase | 4 — Testing, Release and Risk Management (document 36) |
| Version | 0.3 |
| Status | Draft for review. Not approved. **No backup exists. No provider backup is assumed. Every frequency, retention period, RPO and RTO below is PROPOSED and needs MFW's approval.** |
| Date | 25 October 2026 |
| Approval required | Both developers, then MFW (cost and data obligations) |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. Backup set-up, restore tests, RPO and RTO and monitoring marked as proposed additions. Section 13 added: status of the proposals and who does what. Planned names replaced by the existing document. |
| 0.3 | 25 October 2026 | Tracking edit, see `CHANGELOG.md`. The related-documents row for `CLOUD_INFRASTRUCTURE_AND_COSTS.md` now says it exists as a draft. No backup frequency, retention period, RPO or RTO changed, and none is approved. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `MFW_Statement_of_Work.pdf` (S2) | Exists, issued, unsigned. Contains no backup requirement. |
| `MFW_Commercial_Proposal-2.pdf` (S1) "Costs outside the fee" | Exists, issued, unsigned. Cloud usage is billed to MFW. |
| `REQUIREMENTS_SPECIFICATION.md` (RS) §7.3, FR-PRIV-003, NFR-PRIV-005 | Exists, draft. Retention is open (OQ-24). |
| `DEPLOYMENT_PLAN.md`, `API_AND_MODULE_CONTRACTS.md`, `RISK_REGISTER.md`, `OPEN_QUESTIONS.md` | Exist (draft) |
| `DATABASE_AND_DATA_MODEL.md` | Exists on `main` (draft). Planned as `DATABASE_DESIGN.md`. |
| `CLOUD_INFRASTRUCTURE_AND_COSTS.md` | Exists (draft, version 0.1, dated 25 October 2026). Section 14 there gives backup and recovery unit rates only. It adds no frequency, retention period, RPO or RTO. |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal.

## 2. Purpose, Scope and Status

This document proposes how the product's data is backed up and restored. Neither S1 nor S2 states any backup or recovery requirement, so every value here is a proposal for MFW to approve, change or decline (OQ-46). Backup set-up, restore tests, RPO and RTO targets and monitoring access are proposed additions and not S2 deliverables.

Storage and database technology are not decided (DEC-003), so the methods are written as requirements, with provider options listed for evaluation only.

No backup is configured, no restore has been tested, and nothing here is a guarantee.

## 3. Data Inventory

| ID | Data | System of record | Owner of the data | Backup needed | Notes |
|---|---|---|---|---|---|
| BK-01 | Issue PDFs | Backend private file storage | MFW (S1 Key terms) | Yes (PROPOSED) | Whether MFW keeps its own master copies is OPEN (OQ-46). If it does, re-uploading is a fallback. |
| BK-02 | Cover images | Backend file storage | MFW | Yes | As BK-01 |
| BK-03 | Issue metadata and categories | Backend database | MFW | Yes | RS DATA-001, DATA-002 |
| BK-04 | Reader accounts | Identity provider | MFW (reader data, S1 Key terms) | Yes | Export capability depends on the provider (DEC-003) |
| BK-05 | Reader profiles and consent records | Backend database | MFW | Yes | Personal data. Retention: OQ-24. |
| BK-06 | Bookmarks and favourites | Backend database | MFW | Yes | RS DATA-005, DATA-006 |
| BK-07 | Notification preferences and device registrations | Backend database | MFW | Preferences: yes. Device tokens: no, because the app re-registers them. | RS DATA-007 |
| BK-08 | Notification send log | Backend database | MFW | Yes | Retention: OQ-24 |
| BK-09 | News controls (hidden, breaking) | Backend database | MFW | Yes | RS DATA-009 |
| BK-10 | Admin accounts | Identity provider or database | MFW | Yes | — |
| BK-11 | Edition-update list, if kept | Backend database | MFW | Yes | CONFLICT C-02 |
| BK-12 | Source code, access rules, deployment configuration | Git repository | MFW after transfer (OQ-48) | Yes | GitHub hosting is not, by itself, a backup |
| BK-13 | Provider console settings | Provider consoles in MFW's accounts | MFW | Documented, not backed up | Recorded in `DEPLOYMENT_PLAN.md` §5.2, without secret values |
| BK-14 | Crash reports and usage events | Monitoring provider | MFW | No | Provider retention applies |
| BK-15 | WordPress news content | MFW's WordPress site and host | MFW and its host | **Outside the project** | The app keeps a cache only (RS DATA-015). Backing up WordPress stays with MFW and its host. |
| BK-16 | Downloaded issues and cached articles on devices | Reader devices | — | No | Can be downloaded again. Excluded from device backups (`CODING_STANDARDS.md` §8.2). |
| BK-17 | CSV exports | Generated on demand | MFW once downloaded | No | MFW handles exported files under its own policy |

## 4. Proposed Backup Approach

All rows are PROPOSED and need MFW's approval.

| Data | Method requirement | Frequency | Retention |
|---|---|---|---|
| BK-03, BK-05 to BK-11 (database) | A provider-managed export or scheduled backup, stored separately from the live database, in MFW's account | Daily | 30 days, unless OQ-24 sets a shorter limit for personal data |
| BK-01, BK-02 (files) | Object versioning or soft delete on the storage, plus a periodic copy to separate storage in MFW's account | Versioning continuous; copy weekly, and after each new issue upload | 30 days for deleted versions; the copy kept while the issue exists |
| BK-04 (accounts) | A provider export of account records, if available | Daily | 30 days |
| BK-12 (code) | Git repository plus the developers' clones; MFW's copy after transfer | On every push | Full history |

**PROVISIONAL example.** If DEC-003 confirms Firebase, the options to evaluate include Firestore scheduled backups or point-in-time recovery, managed exports to Cloud Storage, Cloud Storage object versioning or soft delete, and the Firebase CLI export of authentication users. None is assumed enabled, and their availability, limits and cost must be checked when the architecture is decided.

## 5. Proposed Recovery Objectives

These are proposed values, **not commitments**. They need MFW's approval. Provider outages are outside the team's control and are not product defects (S2 Warranty).

| Data | Proposed RPO (maximum data loss) | Proposed RTO (time to restore) |
|---|---|---|
| Database (BK-03, BK-05 to BK-11) | 24 hours | 1 working day after the decision to restore |
| Issue files (BK-01, BK-02) | Since the last copy or version: 7 days for the copy, near zero with versioning | 2 working days for a full restore. A single issue: same working day. |
| Accounts (BK-04) | 24 hours | 1 working day |
| Code and configuration (BK-12) | Last push | Same working day |

## 6. Encryption and Access Control

1. Backups stay in MFW's accounts, in the same region as the live data unless OQ-41 decides otherwise.
2. Access is limited to named roles. Developers use role-based access during the project, and their access is removed when MFW asks after handover (S2 Handover).
3. Encryption at rest follows the provider's default, which must be verified for the chosen service. Exports containing personal data are personal data, and are handled like the live data.
4. Backup exports are never downloaded to personal devices, attached to tickets, or committed to Git.

## 7. Restore Procedure

PROPOSED. To be made specific once DEC-003 is decided.

| Step | Action |
|---|---|
| RP-1 | Confirm the incident and its scope: which data, from when, and which environment |
| RP-2 | Notify both developers and MFW's contact (OQ-47) |
| RP-3 | Choose the restore point. Record the reason. |
| RP-4 | Where possible, restore first into ENV-TEST and check it |
| RP-5 | Pause admin publishing and notification sends during a production restore |
| RP-6 | Restore into production |
| RP-7 | Re-apply account deletions made after the restore point (Section 9) |
| RP-8 | Run the verification in Section 8, then resume admin activity |
| RP-9 | Write an incident note: cause, data affected, data lost, and actions taken |

## 8. Restore Verification

| Check | When |
|---|---|
| A test restore of the database and one issue file into ENV-TEST, before the first production release | Before M5 (PROPOSED) |
| Smoke tests SM-01, SM-04, SM-06 and SM-07 (`DEPLOYMENT_PLAN.md` §6) after every restore | Every restore |
| Record counts and spot checks of restored issues, bookmarks and profiles against what is expected | Every restore |
| A periodic test restore after handover | Frequency for MFW to decide (OQ-46) |

No restore has been tested on 23 October 2026.

## 9. Account Deletion and Backups

RS FR-PRIV-003 requires that deleting an account removes the reader's data. Backups keep the data until they expire. This holds in the baseline (immediate deletion) and under the labelled change PRC-02 (a grace window with undo).

1. A deleted reader's data remains only in backups, until their retention ends (Section 4).
2. A restore must not bring back deleted accounts. Step RP-7 re-applies deletions made after the restore point. That needs a minimal record of deleted account IDs and deletion times, which may conflict with "is any record kept after account deletion?" (OQ-24).
3. MFW's legal adviser should confirm this approach (OQ-24, OQ-46).

## 10. Failure Escalation

| Situation | Escalation (PROPOSED) |
|---|---|
| A backup job fails | The responsible developer, or after handover MFW's operator, is alerted. Investigate on the same working day. |
| Data loss or corruption in production | RP-1 to RP-9. During the warranty, a critical defect is acknowledged within one working day [S2 Warranty]. |
| A provider outage | Not a product defect [S2 Warranty]. Monitor the provider's status; restore only if data is lost. |
| After the warranty | Under a support plan or a day rate (S1 "Costs outside the fee"; `MAINTENANCE_AND_HANDOVER.md` §13) |

## 11. Costs and Ownership

- Storage and operations for backups are cloud usage billed to MFW [S1 Costs outside the fee]. No amount is quoted, because provider prices change.
- MFW owns the backups and the accounts that hold them.
- Setting up backups during the build is a PROPOSED addition and not an S2 deliverable (OQ-46). If MFW agrees, it is done as part of backend deployment. Running them after handover is MFW's responsibility, unless a support plan covers it.

## 12. Open Items

| Item | Reference |
|---|---|
| MFW's backup expectations: RPO, RTO, scope, and whether MFW keeps master PDFs | OQ-46 |
| Retention periods and records kept after deletion | OQ-24 |
| Storage and database technology | DEC-003, OQ-35 |
| Environment for test restores | DEC-023, OQ-40 |
| Region | OQ-41 |
| Who receives backup alerts | OQ-47 |

## 13. Status of the Proposals

State on 23 October 2026. Every row is a proposal. None is approved, configured or tested.

| Item | Proposed | Approved by MFW | Configured | Restore tested |
|---|---|---|---|---|
| Method and frequency (Section 4) | Yes | No | No | Not applicable |
| Retention (Section 4) | Yes | No | No | Not applicable |
| RPO and RTO (Section 5) | Yes | No | Not applicable | No |
| Restore procedure (Section 7) | Yes | No | Not applicable | No |
| Restore verification (Section 8) | Yes | No | Not applicable | No |

```text
Who does what, if MFW agrees (PROPOSED)
├── MFW           owns the accounts and the backups, pays for storage and operations, decides RPO, RTO, scope and retention (OQ-46)
├── Developers    set up the backups during the build and document them; run the test restore before M5; hand the procedure over
└── Provider      runs the managed backup features it offers. Availability, limits and cost of those features are NOT VERIFIED
                  until the backend is chosen (DEC-003). A provider outage is not a product defect [S2 Warranty]
```
