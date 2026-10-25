# Security Incident Procedure: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Security Incident Procedure |
| File | `Documentation/SECURITY_INCIDENT_PROCEDURE.md` |
| Version | 0.1 |
| Status | Draft for review. Not approved. **PLANNED: no incident has occurred, no contact is named, and no drill has been run.** Nothing here is implemented. |
| Date | 24 October 2026 |
| Audience | The two developers during the build. MFW's named contacts after handover, once MFW names them (OQ-47). |
| Proposed owner | Sanika Attarde (WS-A), PROPOSED and not agreed. Reviewer: Yuvraj (WS-B). |
| Approval required | Both developers. MFW for the contacts and for any step that involves MFW (OQ-47, OQ-28). MFW's legal adviser for anything legal. |
| Sources | `SECURITY_AND_ACCESS_CONTROL.md` §4.3, §6, §7, §8, §9, §10, §11; `SYSTEM_ARCHITECTURE.md` §12.1; `MAINTENANCE_AND_HANDOVER.md` §10, §11; `BACKUP_AND_RECOVERY.md` §10; `API_AND_BACKEND_CONTRACT.md` §5, §6; `DEPLOYMENT_PLAN.md` §7.5, §7.7; S2 Warranty and acceptance-testing severities |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 24 October 2026 | Initial draft. Written on top of commit 5a436a3 (pull request 3, which has since reached `main` by a direct push on 2026-10-25, with no review by a person; see `CHANGELOG.md`, Repository History), so the identifiers it cites are those of that commit. |

### 1.1 Related documents

| Document | Status on 24 October 2026 |
|---|---|
| `MFW_Statement_of_Work.pdf` (S2) Warranty, severities | Exists, issued, unsigned. **The S2 text is authoritative.** |
| `SECURITY_AND_ACCESS_CONTROL.md` | Exists (draft). Owns the threats T18 to T26, the controls SC-nn and the tests ST-nn |
| `SYSTEM_ARCHITECTURE.md` | Exists (draft). Owns the threats T1 to T17 (§12.1) |
| `MAINTENANCE_AND_HANDOVER.md` | Exists (draft). Owns the general incident flow (§10) and bug severity (§11). This document does not change it |
| `BACKUP_AND_RECOVERY.md` | Exists (draft). Owns restore steps and failure escalation |
| `API_AND_BACKEND_CONTRACT.md` | Exists (draft). Owns the operations named below |
| `OPEN_QUESTIONS.md` | Exists (draft). OQ-47 (contacts and channel), OQ-28 (MFW's approver), OQ-20, OQ-24, OQ-57 |

Status labels follow RS §1.2. **PROPOSED** marks a development-team proposal in this document. In RS terms it is an ASSUMPTION (DEV). **NOT VERIFIED** means that nothing has checked the claim. The baseline is one Admin role with no audit log (FR-ADMIN-004, EXC-07). Steps that need a Super Admin or an audit log belong to the labelled change **PRC-01**, which MFW has not approved, and each such step says so.

## 2. Purpose, Scope and Status

**Purpose.** This document says what the developers do when something may have exposed MFW's readers, files or accounts, or may have let someone act without the right to. It turns the threats and controls of the security document into steps a person can follow under pressure.

**Scope.** Security events only. An ordinary defect, an outage at a provider, or a store rejection follows `MAINTENANCE_AND_HANDOVER.md` §10 and §11. A restore of data follows `BACKUP_AND_RECOVERY.md` §7.

```text
What this document does and does not do
├── Does
│   ├── Define what starts a security incident and how serious it starts
│   ├── Give the common steps, then the steps for six scenarios taken from the threat list
│   ├── Say what the design cannot do, so no one promises it
│   └── List what must exist before an incident can be handled (Section 9)
└── Does not
    ├── Make a legal assessment or state a deadline set by law. Those are for MFW's legal adviser (SECURITY_AND_ACCESS_CONTROL §9.6)
    ├── Claim that any rule, regulation or certification is met
    └── Describe a tool, because no cloud platform is decided (DEC-003). Platform behaviour is NOT VERIFIED unless a source says otherwise
```

**Status.** Everything below is PROPOSED. Nothing can be rehearsed yet, because no backend, no accounts and no admin panel exist.

## 3. What Starts an Incident

A security incident starts when anyone sees, or reasonably suspects, one of these.

```text
Triggers
├── A secret is seen where it should not be: in the repository, a log, a screenshot or a message (T12; SC-16, SC-19)
├── An admin account is used by someone who should not hold it, or an admin who should have lost access still acts (T4, T5, T18 to T20)
├── Personal data is visible to someone who should not see it: through a rules defect, a log, an export or a backup (T6, T10 to T13)
├── An issue file reached someone it should not have, or a wrong issue was published (T1, T2, T21, T23)
├── A notification went to the wrong audience or carried the wrong text (T24)
└── Unusual volume or probing: link requests, registrations, sign-in or reset attempts, or a cost spike (T7, T26)
```

**Starting severity.** The four levels are those of S2: Critical, High, Medium, Low (`MAINTENANCE_AND_HANDOVER.md` §11). S2 defines Critical as stopping the app or exposing data.

- Start at **Critical** when personal data or protected files may have been exposed.
- Start at **High** for any other trigger above.
- Lower the level only when the facts support it, and write down why. PROPOSED.

## 4. Who Does What

```text
Roles
├── Incident lead      the developer who finds or receives the report. Keeps the record and decides the next step.
│                      During the build this is one of the two developers. After handover it is MFW's operator, if MFW names one (OQ-47)
├── Second person      the other developer. Told the same working day for a High or Critical incident, and verifies any change to access (SI-01)
├── MFW's approver     decides anything that affects readers, content or cost. Not yet named (OQ-28)
└── MFW's legal adviser  decides what MFW owes anyone, and by when. The developers supply facts and make no legal statement
```

No on-call arrangement exists. Who leads, and who is reachable at night or at the weekend, is open (SI-01).

## 5. Common Steps

Every scenario in Section 6 uses these steps. They extend the six-step flow of `MAINTENANCE_AND_HANDOVER.md` §10 for a security event.

1. **Report privately.** Do not put the report, the evidence or the names of affected people in a public place. The repository is public and has issues enabled (checked 24 October 2026). The bug-reporting proposal in `MAINTENANCE_AND_HANDOVER.md` §11 uses GitHub issues, so it must not be used for a security event. The private channel is open (OQ-47, SI-02).
2. **Contain first.** Stop the harm before finding the cause: revoke, rotate, disable, unpublish. Each scenario says which. Revoke a credential before removing it from where it was seen, because removal does not undo exposure.
3. **Preserve evidence.** Record the time, what was seen, and where. Keep logs and screenshots in a private place. Do not store reader data, tokens or signed links in the record (SC-16).
4. **Triage.** Set the starting severity (Section 3). Decide what is known, what is not, and what MFW must decide.
5. **Recover.** Restore a safe state: new credentials, a corrected rule, a corrected publication. Add the test that would have caught it (Section 10).
6. **Tell MFW.** Section 7.
7. **Close.** Send a short note: cause, fix, what is still unknown, follow-ups. Update the threat list, the risk register and the tests (Section 8).

## 6. Scenarios

### 6.1 A credential or secret is exposed

```text
Credential or secret exposed                           [T3, T4, T12; SC-16, SC-19]
├── Examples: a password, a key, a signing identity or a token in the repository, a log, a screenshot or a message
├── Contain
│   ├── Treat it as used. Revoke or rotate it first, then remove it from where it was seen
│   ├── A secret committed to the public repository stays visible in the history and in copies. Removing the commit is not containment
│   └── Developers use role-based access with no shared password (NFR-SEC-012), so remove the person's role and not a shared account
├── Preserve: where it was seen, from when to when, and who could see it
├── Recover: issue a new credential through MFW's accounts. Record who holds it, by name and place and never by value (HO-04)
├── Check whether it was used: platform logs. Their content and retention were not researched (SI-04)
└── Tell MFW: at once if it gave access to MFW's cloud project, store accounts or reader data
```

### 6.2 An admin account is compromised, or an admin must lose access

```text
Admin compromise or removal                            [T4, T5, T18; SC-02, SC-12; both models]
├── Contain
│   ├── Baseline (one Admin role, FR-ADMIN-004): a developer removes the single admin role from the account. A revocation in the baseline is the removal of that role (SC-12)
│   ├── PRC-01 (not approved): a Super Admin revokes the role with OP-37. A recent sign-in is required, and the last Super Admin cannot be removed (SC-10)
│   └── Either way, the decision comes from the role record read on each call and not from the person's token (INV-08)
├── Known limits
│   ├── A signed upload URL issued before the revocation works until it expires. It can write to the holding area only, and finalising the upload rejects it because the uploader no longer holds the role (SC-08, OP-40)
│   ├── How soon an issued sign-in token stops working after a revocation is NOT VERIFIED (TECHNOLOGY_DECISIONS §9.4, item 12)
│   └── Whether a read made right after the commit always sees the change is NOT VERIFIED (item 21). ST-03 is the test that would show it
├── Find what the account did
│   ├── Baseline: there is no audit log (EXC-07). What the account did can be learned only from platform logs (SI-04)
│   └── PRC-01: the audit log records role changes, publish and unpublish, deletes, replacements, list views and exports (OP-39, SECURITY_AND_ACCESS_CONTROL §8)
├── If the last admin is locked out or removed
│   ├── Baseline: the developers create the admin account again from MFW's admin list, as in the first deployment (DEPLOYMENT_PLAN §7.5)
│   └── PRC-01: the recovery step of §7.6, with MFW's written naming, one developer running it and the other verifying
└── Tell MFW: always. The admin account belongs to MFW's staff
```

### 6.3 Personal data may have been exposed

```text
Personal data exposed                                  [T6, T10 to T13; AR-15; SC-05, SC-06, SC-15, SC-16]
├── Examples: a rule that let a reader read another reader's records; an export that went to the wrong person; personal data in a log; a backup restored without re-applying deletions
├── Contain
│   ├── Close the access first: tighten the rule, remove the role, or take the operation out of service (for example the exports, OP-32 and OP-33). How an operation is taken out of service depends on the platform (DEC-003)
│   └── Stop any log or report that carries the data from being kept or shared
├── Work out the scope
│   ├── Which records and how many. The product does not record which reader opened which issue or page (NFR-PRIV-003), so it cannot say who read what
│   └── Whether the data was only readable or was also taken. Record what is known and what is not
├── Recover: correct the rule or operation; delete a leaked log; after a restore, re-run the purge for every account deleted since the backup (T13)
├── Tell MFW: the same working day, as Critical. The developers give the facts. What MFW owes readers and when is for its legal adviser (SECURITY_AND_ACCESS_CONTROL §9.6)
└── Not decided here: whether and how readers are told (SI-05)
```

### 6.4 An issue file reached the wrong people, or a wrong issue was published

```text
Wrongful access or publication                         [T1, T2, T21, T23; AR-06, AR-19; OQ-11, OQ-57]
├── Contain
│   ├── Unpublish the issue (OP-22). New downloads stop at once, and OP-11 answers ISSUE_NOT_AVAILABLE
│   ├── Delete it only if MFW's answer to OQ-21 allows permanent deletion (OP-30, after unpublishing; Super Admin only under PRC-01). Its identifier then goes on the deleted-issue list (OP-03)
│   └── Shorten the link lifetime for new links if the configuration allows it (60 minutes is an ASSUMPTION, AOQ-07)
├── What cannot be undone
│   ├── A link already issued works until it expires (AR-06, T2)
│   ├── A copy already on a device cannot be recalled. The app removes it only when it is online and sees the issue on the deleted-issue list (T23, OQ-11)
│   └── The website's copy of an issue is MFW's and is not part of this project. The project does not change WordPress (S2 "Scope not included", OQ-57)
├── Recover: correct the issue, re-upload from MFW's original, and publish again after MFW confirms
└── Tell MFW: at once. MFW decides about its own website and about any notice to readers
```

### 6.5 A notification was sent in error

```text
Notification sent in error                             [T24; OP-25, OP-26, OP-27; SC-13]
├── Contain
│   ├── Stop further sends and retries. Only an admin can retry (INV-17)
│   └── Check the send record (OP-27) to see what was sent, when, and by whom
├── What cannot be done: whether a sent push can be corrected or recalled depends on the push provider and was not researched (SI-06). Assume it cannot
├── Recover: with MFW's agreement, send one short correction through the normal operation. Do not send several
└── Tell MFW: at once. The wording and the audience of any correction are MFW's decision
```

### 6.6 Abuse or unusual volume

```text
Abuse or unusual volume                                [T7, T26; SC-18, SC-21; AOQ-10]
├── Examples: many file-link requests from one reader; registration, sign-in or password-reset probing; a sudden cost
├── Contain
│   ├── Tighten the limit for that class of operation. The values and the mechanism are OPEN (SC-18, AOQ-10). A refused request is RATE_LIMITED and reveals nothing about the thing asked for
│   ├── If one reader account is the source, disable it at the sign-in provider. No operation in the catalogue disables a reader account, and the provider's disable function is listed in TECHNOLOGY_DECISIONS (VS-29) but was not tested for this use
│   └── Look at billing alerts in MFW's console if the provider offers them. Not researched (T7)
├── Recover: set the limit that was missing, and add the test (ST-18). Consider App Check if MFW and the team decide to adopt it (AOQ-10)
└── Tell MFW: if there is a cost, because cloud usage is billed to MFW (S1 "Costs outside the fee")
```

## 7. Telling MFW

```text
The note to MFW (PROPOSED)
├── Timing: the same working day for High and Critical. Within the next working day for Medium and Low (SI-03)
├── Channel: the private channel MFW names (OQ-47). Never a public issue or a public pull request
├── Content, facts only
│   ├── What happened and when it was found
│   ├── What is affected, and what is not known
│   ├── What has been done to contain it
│   └── What MFW must decide
├── Not in the note: reader data, tokens, signed links, or a conclusion about the law
└── Who at MFW: the named contact, and MFW's approver for anything that affects readers, content or cost (OQ-28)
```

During the 30-day warranty, S2 requires that critical and high defects be acknowledged within one working day (`MAINTENANCE_AND_HANDOVER.md` §12). That is a promise about defects, and this document does not extend it. The timing above is a proposal for security events only.

## 8. After the Incident

- Send the closing note: cause, fix, what is still unknown, follow-ups. Keep it free of personal data.
- Update the **threat list** if the incident was a new threat, and add its control and test. The threats are in two places: T1 to T17 in `SYSTEM_ARCHITECTURE.md` §12.1 and T18 to T26 in `SECURITY_AND_ACCESS_CONTROL.md` §4.3.
- Update `RISK_REGISTER.md` if a risk changed or a new one appeared.
- Add the test that would have caught it. Security tests are ST-nn in `SECURITY_AND_ACCESS_CONTROL.md` §14.
- If a rule or an operation changed, follow the compatibility policy of `API_AND_BACKEND_CONTRACT.md` §9.

## 9. What Must Exist First

Until these exist, the procedure cannot be followed in full.

| Needed | Why | State |
|---|---|---|
| Named contacts at MFW, and a private channel | Section 7 | OPEN (OQ-47) |
| MFW's authorised approver and deputy | Decisions that affect readers or cost | OPEN (OQ-28) |
| A named incident lead during the build, and a second person | Section 4 | OPEN (SI-01) |
| A record of who holds each credential, without values | Section 6.1 | NOT STARTED (HO-04) |
| Knowledge of which platform logs exist and how long they are kept | Sections 6.1 to 6.3 | NOT VERIFIED (SI-04) |
| A throwaway project to rehearse admin removal and recovery | ST-09 | Blocked by DEC-003 |
| MFW's legal adviser, to take the legal questions | Section 6.3 | MFW's matter |

## 10. Verification

No incident has occurred and no drill has been run. Everything below is PLANNED.

```text
How this would be checked
├── A paper drill of each scenario in Section 6 by both developers. Not run
├── A rehearsal of admin removal and recovery in a throwaway project (ST-09), once the platform is chosen. Not run
├── The security tests that cover the controls named above
│   ├── ST-03 revoked-role access (SC-02, SC-12)
│   ├── ST-09 bootstrap and recovery (SC-14), PRC-01 only
│   ├── ST-16 notification records (T24), ST-17 deleted-issue copies (T23), ST-18 limits (SC-18)
│   └── SEC-CHK-02 and SEC-CHK-03 direct requests for a protected file
└── Everything marked NOT VERIFIED above stays so until a test shows it
```

## 11. Open Items

These items are local to this document. They are not yet in the registers. After pull request 3 is merged they are to be registered in `OPEN_QUESTIONS.md`, with the owner and the evidence that would close each.

| Ref | Item | Owner | Depends on |
|---|---|---|---|
| SI-01 | Who leads an incident during the build and after handover, who is the second person, and who is reachable out of hours | Both developers, then MFW | OQ-47 |
| SI-02 | The private channel for security reports, because the repository is public | Both developers, with MFW | OQ-47 |
| SI-03 | The time targets for telling MFW (same working day proposed) | Both developers, with MFW | S2 Warranty |
| SI-04 | Which platform logs exist and how long they are kept. The baseline has no audit log, so these are the only record of what an admin did | Development team | DEC-003 |
| SI-05 | Whether and how readers are told after an exposure. User-facing wording and a legal question | MFW and its legal adviser | OQ-24, OQ-27 |
| SI-06 | Whether a sent push notification can be corrected or recalled | Development team | TD-13 |

Questions for MFW stay in the register as they are: OQ-20, OQ-24, OQ-28, OQ-47 and OQ-57. No new question for MFW is raised here.

## 12. Traceability

```text
This document to its sources
├── Threats: T1 to T7, T10 to T14, T18 to T26; AR-06, AR-15, AR-19
├── Controls: SC-02, SC-05, SC-06, SC-08, SC-10, SC-12, SC-13, SC-15, SC-16, SC-18, SC-19, SC-21
├── Tests: ST-03, ST-09, ST-16, ST-17, ST-18, SEC-CHK-02, SEC-CHK-03
├── Operations: OP-03, OP-11, OP-22, OP-25 to OP-27, OP-30, OP-32, OP-33, OP-37, OP-39, OP-40
├── Requirements: FR-ADMIN-004, NFR-PRIV-003, NFR-SEC-012; EXC-07
├── Decisions and questions: DEC-003, OQ-11, OQ-20, OQ-21, OQ-24, OQ-27, OQ-28, OQ-47, OQ-57; AOQ-07, AOQ-10
├── Labelled change: PRC-01 (not approved)
└── Handover: HO-04
```
