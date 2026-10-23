# Maintenance and Handover: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Maintenance and Handover |
| File | `Documentation/MAINTENANCE_AND_HANDOVER.md` |
| Phase | 4 — Testing, Release and Risk Management (document 37) |
| Version | 0.2 |
| Status | Draft for review. Not approved. Every handover item is NOT STARTED. |
| Date | 23 October 2026 |
| Approval required | Both developers. MFW agrees the handover at M5. |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. HO-13, HO-14 and the section 2 sentence marked as proposed additions. Planned names replaced by the existing documents. Note on the S1 maintenance figures. |

### 1.1 Related documents

| Document | Status on 23 October 2026 |
|---|---|
| `MFW_Statement_of_Work.pdf` (S2) "Changes, handover and warranty", AC-11, AC-12 | Exists, issued, unsigned |
| `MFW_Commercial_Proposal-2.pdf` (S1) "Key terms", "Costs outside the fee" | Exists, issued, unsigned |
| `PROJECT_CHARTER.md` (CH) §10, §11, §13, §19.3 D8 | Exists, draft |
| `DEPLOYMENT_PLAN.md`, `BACKUP_AND_RECOVERY.md`, `DEPENDENCY_REGISTER.md`, `APP_STORE_RELEASE_CHECKLIST.md`, `TESTING_STRATEGY.md`, `DEFINITION_OF_DONE.md` | Exist (draft) |

Status labels follow RS §1.2.

## 2. Purpose, Scope and Status

This document lists what MFW receives at handover, how ownership and access move to MFW, how defects are reported, and what applies during and after the warranty.

Every obligation below is quoted from S1 or S2 with its source. Two items are the exception: monitoring and alert access (HO-13) and a backup configuration with a verified restore (HO-14) are proposed additions that S1 and S2 do not contain. They are not obligations unless MFW agrees them (OQ-46, OQ-47). Otherwise this document creates no new obligation. Where sources differ, both positions are shown. S1 and S2 are unsigned copies (OQ-28), and some commercial terms are in conflict (OQ-32).

## 3. Sources of Obligations

| Topic | S1 (unsigned) | S2 (unsigned) | CH (draft) | Assessment |
|---|---|---|---|---|
| Ownership | Code, admin panel and designs made for MFW pass to MFW when the final invoice is paid. MFW keeps its brand, content and reader data. | Source code in a repository owned by MFW (AC-12; Handover) | D8: the repository is currently owned by Sanika Attarde; transfer before M5 | Sequencing is OPEN (Section 4) |
| Warranty | 30 days of free defect correction from the first public release | Starts on the day the app first becomes publicly available in a store, using the later date if the two stores differ. Ends no later than 60 days after submission. | 30-day warranty (§11) | Consistent. S2 is more specific. |
| After the warranty | Optional monthly plans; day rate without a plan | Support after the warranty is excluded; plans are in S1 | §13 repeats S1 | CONFIRMED (S1 values, unsigned) |
| Change requests | ₹2,500 per person-day | Written request, then an estimate within two working days, then written approval; 50% on approval and 50% on delivery unless agreed otherwise | §17.2 repeats S2 | CONFIRMED (unsigned) |
| Handover contents | Source code, documentation, training session | The list in Section 15 | §11 | CONFIRMED (unsigned) |

## 4. Source Repository Ownership and Transfer

| Item | Detail | Status |
|---|---|---|
| Current location | `github.com/sanikaattarde/Metal-Forming-World-MFW-` (local remote configuration, 23 October 2026) | CONFIRMED |
| Required at handover | A repository owned by MFW, with history (S2 AC-12) | CONFIRMED (unsigned) |
| Sequencing tension | S1 passes ownership when the final invoice is paid. The M5 invoice is raised at approval, store submission and handover, and is due 7 days after its date [S1 How payment works]. S2 AC-12 requires an MFW-owned repository as a handover check at M5. | **OPEN (OQ-48).** The order of transfer and final payment must be agreed in writing. |
| Transfer method options | (a) GitHub repository transfer to an MFW account or organisation, which keeps the history. (b) MFW creates a repository and receives a full-history mirror. | OPEN (OQ-48) |
| After transfer | CI secrets re-created in MFW's account; developer access set by MFW | PLANNED |

## 5. Build and Release Instructions

Delivered as technical documentation, which S2 Handover requires to cover set-up, deployment steps, data model, security rules and third-party licences (RS NFR-MAINT-004).

| Content | Where it will live | Status |
|---|---|---|
| Developer set-up | `app/README.md`, `backend/README.md`, `admin/README.md` (WP-01) | PLANNED |
| Build and sign | `CI_CD_AND_QUALITY_GATES.md` §6; app README | PLANNED |
| Deployment steps | `DEPLOYMENT_PLAN.md`, updated with the actual configuration names | PLANNED |
| Data model | `DATABASE_AND_DATA_MODEL.md` (draft exists; brought up to date at handover) | PLANNED |
| Security rules | `backend/` access rules and `SECURITY_AND_ACCESS_CONTROL.md` (draft exists; brought up to date at handover) | PLANNED |
| Third-party licences | `DEPENDENCY_REGISTER.md`; the in-app licence page | PLANNED |
| Clean-copy rebuild check | AC-12.2 | NOT STARTED |

## 6. Environment and Configuration Documentation

`DEPLOYMENT_PLAN.md` §4 and §5.2 list the environments and configuration items (CFG-01 to CFG-15). At handover each item is filled in with its actual value or name, except secrets, which are recorded only by holder and location.

## 7. Administrative Access Handover

| Item | Detail | Source |
|---|---|---|
| Admin accounts | Created from MFW's admin user list | S1 What we need from MFW; OQ-20 |
| Administrator guide | A short guide | S2 Handover |
| Training | A live session of up to two hours | S2 Handover |
| Credential-holder record | Who holds each credential. Names and locations only, never values. | S2 Handover; AC-12.3 |
| Developer access removal | Removed when MFW asks after handover | S2 Handover |

## 8. Infrastructure and Billing Ownership

MFW owns and pays for the cloud project(s), the Apple and Google developer accounts and any domain, and gives the developers role-based access [S2 Responsibilities]. Third-party costs are paid by MFW directly to each provider, with no mark-up [S1 Costs outside the fee]. The figures S1 lists are in `DEPENDENCY_REGISTER.md`. Current prices must be checked with each provider.

## 9. Dependency Inventory

`DEPENDENCY_REGISTER.md` is the inventory. At handover it lists every package, service and account actually used, with version, licence and owner. Candidates that were not used are marked as such.

## 10. Monitoring and Incident Procedure

PROPOSED, until MFW names its contacts (OQ-47).

1. **Detect.** Crash reports and alerts reach the named recipients (`DEPLOYMENT_PLAN.md` §7.7).
2. **Report.** MFW reports problems through the agreed channel (OQ-47).
3. **Triage.** Assign a severity using the S2 definitions (Section 11).
4. **Acknowledge.** During the warranty, critical and high defects within one working day [S2 Warranty].
5. **Fix and release.** Through the normal workflow and DoD-BUG. A store rejection is handled as in S2 Warranty.
6. **Close.** A short note to MFW: cause, fix, release, follow-ups.

## 11. Bug Reporting and Severity

| Severity | Meaning [S2 How acceptance testing works] |
|---|---|
| Critical | Stops the app working, or exposes data |
| High | A confirmed feature does not work and there is no workaround |
| Medium | A visible fault with a workaround |
| Low | Cosmetic |

A report includes: what happened, what was expected, steps, device and OS, app version, time, and screenshots without personal data. The reporting tool is PROPOSED as GitHub issues in the project repository (`TESTING_STRATEGY.md` §10). The channel for MFW is OQ-47.

## 12. Warranty

From S2 Warranty (unsigned):

| Situation | Treatment [S2] |
|---|---|
| The app fails an acceptance criterion, or differs from the approved design | Fixed at no charge. Critical and high defects are acknowledged within one working day. |
| A store rejects the app because of a defect in delivered features | Fixed and resubmitted at no charge |
| A store rejection needs input from MFW, such as privacy wording | MFW supplies the input, and the developer resubmits at no charge |
| A new feature, or different behaviour from what was approved | A change request |
| A Firebase, Apple, Google or WordPress outage (S2's wording; Firebase is the S2 proposal, DEC-003); a new operating system version; a change made by MFW; a content error | Not a defect. The developer helps diagnose it. Adapting the app needs a support plan or a change request. |

**Dates to record.** The first public availability date in each store, the warranty start (the later of the two), and the warranty end (30 days later, and no later than 60 days after submission). None exists yet.

## 13. After the Warranty

**Maintenance plans** [S1 Costs outside the fee; unsigned; S1's commercial figures are subject to OQ-32]:

| Plan | Hours a month | Monthly fee |
|---|---|---|
| Basic | 8 | ₹5,000 |
| Standard | 16 | ₹8,000 |
| Extended | 32 | ₹12,000 |

S1 states a rate of ₹312.50 an hour, with a three-month minimum. S1's figures do not agree with each other: ₹312.50 an hour for 8 hours is ₹2,500, not ₹5,000, and the other two plans imply ₹500 an hour (₹8,000 for 16 hours) and ₹375 an hour (₹12,000 for 32 hours). No conclusion is drawn here. The question for MFW is part of OQ-32. Without a plan, occasional work is ₹5,500 per day. Whether MFW takes a plan is OQ-49.

**Exclusions.** Support after the 30-day warranty is not covered by the fixed fee (S2 "Scope not included"; CH §10). The S2 later-phase features and other exclusions are change requests.

**Change requests.** Handled through the S2 change process, at ₹2,500 per person-day (S1, S2).

## 14. Knowledge Transfer

| Session | Basis | Status |
|---|---|---|
| Administrator training, up to two hours | S2 Handover | NOT STARTED |
| Walkthrough for a future maintainer | Not in S1 or S2. PROPOSED only if MFW and the developers agree. Not committed. | — |

## 15. Final Acceptance and Outstanding Issues

- Final acceptance is MFW's sign-off of acceptance testing at M5, with AC-11 and AC-12 met (S2 M5).
- Medium and low defects still open at sign-off are fixed, or agreed in writing for the warranty period [S2 How acceptance testing works]. They are listed in the outstanding-issues record (HO-15).
- A list of known limitations is part of the handover [S2 Handover].

## 16. Handover Checklist

| ID | Item | Source | Status |
|---|---|---|---|
| HO-01 | Repository with full history owned by MFW | S2 AC-12; OQ-48 | NOT STARTED |
| HO-02 | Technical documentation: set-up, deployment steps, data model, security rules, third-party licences | S2 Handover | NOT STARTED |
| HO-03 | Clean-copy build and backend deployment into a fresh project, following the documentation | S2 AC-12 | NOT STARTED |
| HO-04 | Credential-holder record, without values | S2 Handover | NOT STARTED |
| HO-05 | MFW holds every credential. A list of developer access to remove on request. | S2 AC-12; S2 Handover | NOT STARTED |
| HO-06 | Short administrator guide | S2 Handover | NOT STARTED |
| HO-07 | Live administrator training of up to two hours | S2 Handover | NOT STARTED |
| HO-08 | Release package: store listing text, screenshots, privacy inputs | S2 Handover | NOT STARTED |
| HO-09 | Test evidence | S2 Handover; AC-10 | NOT STARTED |
| HO-10 | List of known limitations | S2 Handover | NOT STARTED |
| HO-11 | Dependency inventory with licences | RS NFR-MAINT-004; `DEPENDENCY_REGISTER.md` | NOT STARTED |
| HO-12 | Store submission confirmations held by MFW | S2 AC-11 | NOT STARTED |
| HO-13 | Monitoring and alert access set up for MFW. PROPOSED addition: not in S1 or S2 | OQ-47 | NOT STARTED |
| HO-14 | Backup configuration documented, and a restore verified. PROPOSED addition: not in S1 or S2 | `BACKUP_AND_RECOVERY.md`; OQ-46 | NOT STARTED |
| HO-15 | Outstanding-issues record agreed with MFW | S2 How acceptance testing works | NOT STARTED |
| HO-16 | Warranty start and end dates recorded | S2 Warranty | NOT STARTED |

## 17. Open Items

| Item | Reference |
|---|---|
| Repository transfer: method and order relative to the final payment | OQ-48 |
| Commercial baseline, which affects the final invoice | OQ-32, OQ-33 |
| Incident contacts and reporting channel | OQ-47 |
| Maintenance plan choice | OQ-49 |
| Backup expectations | OQ-46 |
| Signed S1 and S2 | OQ-28 |
