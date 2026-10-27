# API and Backend Contract: Metal Forming World (MFW) Mobile Application

## 1. Document Control, Purpose, Scope and Status

| Field | Detail |
|---|---|
| Document title | API and Backend Contract |
| File | `API_AND_BACKEND_CONTRACT.md`, in the same folder as `REQUIREMENTS_SPECIFICATION.md` |
| Project | Metal Forming World (MFW) mobile application |
| Version | 0.3 |
| Status | Draft for Review |
| Last updated | 27 October 2026 |
| Prepared by | MFW development team |
| Approval status | Not approved. No MFW or internal approval of this document has been recorded. The architecture is not approved by the charter (CH §17.4). |
| Related documents | [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) v0.1; [Scope and Exclusions](SCOPE_AND_EXCLUSIONS.md) v0.1; [Assumptions and Constraints Register](ASSUMPTIONS_AND_CONSTRAINTS.md) v0.2; [Glossary](GLOSSARY.md) v0.1; [System Architecture](SYSTEM_ARCHITECTURE.md) v0.4; [Technology Decisions](TECHNOLOGY_DECISIONS.md) v0.4; [Database and Data Model](DATABASE_AND_DATA_MODEL.md) v0.4; [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) v0.4; `PROJECT_CHARTER.md` v0.2 |

**Purpose.** This document says what the backend does for the app and the admin panel. For each operation it gives the caller, the inputs and outputs, the checks, the errors, the writes, the audit entry and the requirements behind it. It also fixes the conventions that every operation follows, the contract for reading MFW's WordPress site, the rules for changing a contract without breaking installed apps, and the tests that guard the contract.

**Scope.** The operations between the Flutter app, the admin panel, the backend and the systems the backend uses. It contains no code, no OpenAPI file, no schema code and no cloud configuration, and it creates no cloud resource. S2 does not ask for a public API (GS-D2), so this is the internal contract between the product's own parts.

**Status of the technology.** The core of this document is written without a vendor's terms. Section 11 maps it onto Firebase, which is the PROPOSED baseline (TD-03, CONFLICT C-05, not approved). Only Flutter (TD-01) is an accepted decision. Every vendor-specific detail is in Section 11 and is provisional. If another platform is chosen, only Section 11 changes.

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 23 October 2026 | Initial draft. Written after the 17-question interview (GS-Q17 to GS-Q33) and a read-only review of MFW's public website (WEB). Decisions recorded here are team-accepted, with the requirement label PROVISIONAL and MFW written approval pending (GS-Q30). No requirement status in the specification changed. |
| 0.2 | 23 October 2026 | Remediation edits, see `CHANGELOG.md`. Error scheme changed to upper-case categories with reason codes (GONE, RATE_LIMITED and FAILED_PRECONDITION added; DEADLINE_EXCEEDED a reason under UNAVAILABLE). Section 3.1 to 3.4 added: aliases for the 31 app-side operation identifiers, the baseline and PRC-01 privileges, the baseline and PRC-02 deletion, and the open design differences. OP-12, OP-13 and the grace-window text marked PRC-02. "Team-accepted" replaced by PROPOSED with the agreement note. Registration and sign-in message rule added. Website check updated. |
| 0.3 | 27 October 2026 | Positions from the questioning session of 26 and 27 October 2026 applied (Technology Decisions section 10.5). One Admin role: the callers, Sections 3.2, 5.1 and 5.2 are rewritten, and OP-30 to OP-39 and OP-42 are open to any admin. OP-36 is withdrawn. OP-35, OP-37, OP-39 and OP-42 are named addAdmin, removeAdmin, listAdminChanges and bootstrapAdmin. The audit set is narrowed to adds and removes of admins, so the denied entries are dropped and INV-16 is withdrawn. Immediate deletion: OP-13 is withdrawn and OP-12 and OP-41 are simplified. OP-33 is dropped with the edition-update sign-up. Section 3.3 is rewritten. PRC-01 and PRC-02 are withdrawn. No decision is approved. |

### 1.1 Sources and authority

| Ref | Source | Evidence status | Authority in this document |
|---|---|---|---|
| S1, S2 | MFW Mobile App Commercial Proposal and Statement of Work, 17 October 2026 | Read. Both copies are unsigned (REG-002). | S2 lists the product's capabilities and acceptance criteria. |
| S3 | Client emails received after S1 and S2 | Not available (REG-001). | Not used as evidence. Anything known only through the charter is PROVISIONAL. |
| CH | `PROJECT_CHARTER.md` v0.2 | Read. Draft for review, unsigned. | Working summary. It does not override S1 or S2. |
| SPEC | [Requirements Specification](REQUIREMENTS_SPECIFICATION.md) | Read. Draft for Review. | The requirement IDs and statuses, used as written. |
| TD, GS | [Technology Decisions](TECHNOLOGY_DECISIONS.md) | Draft for Review. | The decisions, and the interview answers GS-Q1 to GS-Q33 and the defaults GS-D1 to GS-D20. |
| ARCH | [System Architecture](SYSTEM_ARCHITECTURE.md) | Draft for Review. | The flows and the function list this document turns into a contract. |
| DM | [Database and Data Model](DATABASE_AND_DATA_MODEL.md) | Draft for Review. | The entities, invariants (INV-nn) and the access rules per entity. |
| SEC | [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) | Draft for Review. | The permission rules, the audit policy and the security tests. This document refers to it and does not repeat it. |
| WEB | MFW's public website, https://metalformingworld.com/, read on 23 October 2026 | Observed. Not an approved source. | A reference for the WordPress contract (Section 7 and Appendix A). It does not change scope (INT-WP-002) and is not MFW's approval. |

S1, S2 and CH are named by file name and not linked, because they are not in this folder. Fees and personal names are left out, as in the specification. All sample values are fictional.

### 1.2 Status labels and identifiers

The status legend is the specification's: CONFIRMED, PROVISIONAL, ASSUMPTION, OPEN and CONFLICT. "Proposed" is a decision status for choices the development team recommends. Version 0.1 used "team-accepted" for a choice the developer who ran the interview recorded as accepted. That word is not in the repository's status model (`DECISION_LOG.md` section 3.1), so every such choice is now PROPOSED and carries this note: "Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed." The requirement label stays PROVISIONAL, and MFW written approval is pending (GS-Q30, REG-052). CONFIRMED is never used for a proposed decision.

| Prefix | Meaning | Defined in |
|---|---|---|
| OP-nn | An operation in this contract. The main identifier | Sections 3 to 6 |
| OP-AREA-nn | The identifier of the same operation in `API_AND_MODULE_CONTRACTS.md` section 8 (for example OP-FILE-01). An alias of an OP-nn | Section 3.1 |
| CT-nn | A contract test | Section 10 |
| FR, NFR, INT, BR, AC, DATA | Requirement IDs and S2 acceptance criteria | Specification Sections 5 to 10 |
| OQ, C, ASM | Open questions, conflicts, assumptions | Specification Section 12 |
| TD-nn, AOQ-nn, PRC-nn | Technology decision, architecture open question, proposed requirement change | [Technology Decisions](TECHNOLOGY_DECISIONS.md). Each TD maps to a DEC entry and each AOQ to an OQ (`DECISION_LOG.md` 5.2, `OPEN_QUESTIONS.md` section 7) |
| AR-nn | Architecture risk | [System Architecture](SYSTEM_ARCHITECTURE.md) §14 |
| INV-nn | Data invariant | [Database and Data Model](DATABASE_AND_DATA_MODEL.md) §10.8 |
| GS-Qnn, GS-Dnn | Interview answers and confirmed defaults | [Technology Decisions](TECHNOLOGY_DECISIONS.md) §10 |
| WEB | An observation on MFW's website | Section 1.1 and Appendix A |

### 1.3 How to read this document

An **operation** is a named thing the backend does for a caller. There are two kinds. A **server operation** is code that runs in the backend, checks the caller and does the work. A **direct operation** is a read or write that the database rules allow the caller to make on their own records or on public data, with no server code in between. Both are listed, so that a different platform can implement every one of them. Section 11 says which kind each operation is on Firebase.

## 2. Conventions

### 2.1 Contract format

Each operation is a short tree: who may call it, what goes in and out, the checks, the refusals, the writes, the audit entry, whether a repeat is harmless, and the requirements. The format is Markdown, not OpenAPI, and there is no public REST API (GS-D2, GS-D13). The operation names are working names, as in System Architecture §10.1. Field lengths and formats are proposals for testing.

```text
OP-nn operationName                              [kind; who may call it]
├── In: the inputs
├── Out: the outputs
├── Checks: what the backend verifies, in order
├── Refuses: the error category and reason code for each refusal
├── Writes: the entities changed
├── Audit: the audit action written, if any
├── Repeat: whether a repeated call is harmless
└── Requirements: the requirement IDs and decisions behind it
```

### 2.2 Callers

```text
Callers
├── Logged-out visitor        no sign-in. May use the public direct reads and the WordPress site
├── Reader                    signed in. May use the public reads, the operations on their own records, and the reader operations
├── Admin                     a reader with an active admin role record: the one admin role of RS FR-ADMIN-004. May use every admin operation, including adding and removing admins (Section 3.2)
├── Storage event, schedule   the backend's own triggers. No human caller
└── Developer-run step        the controlled bootstrap and recovery step. Not an operation a client can call
```

### 2.3 Identity and authorisation

1. Every server operation authenticates the caller first.
2. An admin operation reads the caller's role record and account status on this call. It does not trust a role claim, a cached role or anything held by the client (GS-Q20, INV-08). The panel hides controls by role as a convenience only.
3. If the backend cannot verify the caller's current authorisation, the operation is refused and nothing changes. This is fail closed.
4. A reader whose account is being deleted is refused by every server operation. The direct operations on the reader's own records stay open to the owner, because rules do not look up the account status (whether they could is NOT VERIFIED, Section 11). Those records are removed with the account.
5. The intended guarantee is that an admin whose role record is removed is refused on the next privileged call, once the removal is visible to the check. How long a token stays valid and whether a read made right after the change always sees it are NOT VERIFIED (Section 11). A test for a removed admin is proposed (CT-07; `TESTING_STRATEGY.md` section 9).
6. A privileged operation is an admin operation. A refusal writes nothing, because the change record covers only admin adds and removes (GS-Q44).

```mermaid
sequenceDiagram
  autonumber
  participant C as Panel or app
  participant F as Server operation
  participant R as Role record
  participant D as Data
  C->>F: Call with a request identifier and the sign-in token
  F->>F: Authenticate the caller
  F->>R: Read the current role and account status
  alt cannot read, or not permitted
    F-->>C: Refused, fail closed
  else permitted
    F->>D: Do the work. An admin add or remove writes its change record in the same transaction
    F-->>C: Result
  end
```

### 2.4 Request identifiers and repeats

Every write operation carries a `request_id` that the client creates once per user action and reuses on every retry. The backend remembers it for a period (the length is OPEN) and returns the earlier result for a repeat, so a retry after a lost reply changes nothing and adds no second change record (GS-D14, INV-07, M6). Direct writes are made repeat-safe by their keys (DM §10.1). Reads need no request identifier.

### 2.5 Errors

Every refusal carries a category, a stable reason code, and a plain message. The names are the upper-case names that `API_AND_MODULE_CONTRACTS.md` section 4.2 already uses, with three categories added (FAILED_PRECONDITION, GONE, RATE_LIMITED). EMAIL_NOT_VERIFIED and PROFILE_INCOMPLETE are reasons under FAILED_PRECONDITION, and DEADLINE_EXCEEDED is a reason under UNAVAILABLE. The exact names are confirmed at implementation, as System Architecture §10.1 says (GS-D16). The scheme is PROPOSED. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed.

```text
Error categories
├── UNAUTHENTICATED        no valid sign-in
├── FORBIDDEN              signed in, but not allowed: wrong role, or not the owner
├── FAILED_PRECONDITION    a rule is not met. The reason code says which: ACCOUNT_CLOSED, EMAIL_NOT_VERIFIED,
│                          PROFILE_INCOMPLETE, ISSUE_NOT_AVAILABLE, NO_CURRENT_FILE, NO_ACCEPTED_FILE, NOT_UNPUBLISHED,
│                          CONFIRMATION_MISMATCH, IN_USE, NOT_RETRYABLE, ALREADY_DELETING, TARGET_NOT_AVAILABLE,
│                          LAST_ADMIN, RECENT_SIGN_IN_REQUIRED, TARGET_ACCOUNT_CLOSED, TARGET_EMAIL_NOT_VERIFIED,
│                          ALREADY_ADMIN, NOT_AN_ADMIN
├── INVALID_ARGUMENT       a value is missing or malformed. The reply names the fields
├── NOT_FOUND              the thing does not exist
├── GONE                   the issue was permanently deleted. Returned only for an identifier on the deleted-issue list (GS-Q24, GS-Q25)
├── CONFLICT               a stale screen: the record is not what the caller saw (STALE_RECORD), or the target's admin state is not (STALE_ADMIN_STATE)
├── RATE_LIMITED           a rate or size limit. The reply may carry a retry-after value
├── UNAVAILABLE            a dependency cannot be reached, such as the WordPress site or the push service. Retry later.
│                          The reason DEADLINE_EXCEEDED means a call took too long. It is retryable
└── INTERNAL               an unexpected failure. Nothing was changed, or the change is repeatable (Section 2.4)
```

A rejected upload is not an error to the caller. It is reported on the upload job with the reason NOT_A_PDF, OVER_LIMIT, UPLOADER_NOT_AUTHORISED or COVER_INVALID (OP-40). OVER_LIMIT and NOT_A_PDF are the same conditions as FILE_TOO_LARGE and NOT_A_PDF in `API_AND_MODULE_CONTRACTS.md` section 4.2. The app maps each category and reason to the prompts in System Architecture §7.4 and to the states in FR-STATE-001 to FR-STATE-007 (ASSUMPTION), and the app-side `FailureCode` mapping stays in `API_AND_MODULE_CONTRACTS.md`.

**Registration and sign-in messages (PROPOSED).** A duplicate address at registration arises at the identity provider and is mapped in the app to the conflict case. Registration tells the visitor that an account exists for the address. Sign-in gives one message for any wrong email or password, and password reset gives the same message whether or not the address has an account. All three are rate limited. The provider's behaviour is NOT VERIFIED and is checked when the provider is chosen (DEC-006).

### 2.6 Pagination

The catalogue is small and is fetched whole and filtered on the device (GS-D3, GS-D15). Admin lists use a cursor: the input is `page_size` and `cursor`, and the output is `items` and `next_cursor`. The largest page size is OPEN. News paging follows the WordPress site: 10 posts by default and 100 at most per request (VS-41, Section 7).

### 2.7 Rate limits and abuse

A limit is stated as a requirement for each class of operation. The mechanism is OPEN, because whether App Check is enabled for the backend is AOQ-10, and no number is invented (GS-D17). A refusal for a limit is `RATE_LIMITED`.

```text
Operation classes that need a limit             [mechanism OPEN (AOQ-10); no value is set]
├── Sign-in, registration, password reset      through the identity provider. Whether the provider limits them is NOT VERIFIED
├── File-link requests (getIssueFile)           a cap per reader per day, signed_url_requests_per_reader (ASSUMPTION)
├── Profile saves and deletion requests
├── Admin writes and uploads
├── Reader-data lists and exports               admins only
├── Notification sends and retries
└── Searching for a reader by email address     admins only
```

### 2.8 Logging

Operation logs record the operation name, the caller's identifier and the outcome category. They never contain a signed link, a token, a password, an exported file or a reader's profile values (System Architecture §12.1). A signed link is a temporary credential and is neither stored nor logged (DM §9).

### 2.9 Identifiers and time

Identifiers are opaque, generated by the server and never reused, except the user identifier, which is the sign-in provider's (M10, INV-14). Timestamps are UTC. A request never carries an email address as a key.

## 3. Operations Overview

```mermaid
flowchart LR
  subgraph callers["Callers"]
    v["Logged-out visitor"]
    r["Signed-in reader"]
    ad["Admin"]
    dev["Developer-run step"]
    sys["Storage events and the schedule"]
  end
  subgraph direct["Direct access allowed by database rules"]
    d1["Public reads: catalogue, categories, segments, configuration, news controls, deleted-issue list"]
    d2["Own records: bookmarks, favourites, notification preferences, own account and profile"]
  end
  subgraph srv["Server operations, each checks the caller on every call"]
    f1["Reader: saveProfile, getIssueFile, account deletion"]
    f2["Admin: issues, uploads, publish, news controls, notifications"]
    f3["Admin: delete issue, reader list and export, add and remove admins, change history"]
    f4["Triggers and scheduled tasks"]
  end
  wp["WordPress REST API, read only"]
  v --> d1
  v --> wp
  r --> d1
  r --> d2
  r --> f1
  r --> wp
  ad --> f2
  ad --> f3
  dev -->|bootstrap and recovery| f3
  sys --> f4
  f2 -->|post picker| wp
```

```text
Operations                                                   [PROPOSED, PROVISIONAL, MFW written approval pending, agreement between the developers reported by YG and not filed, unless a line says otherwise]
├── Public and reader data, direct access (Section 4)
│   ├── OP-01 listCatalogue                public read of published issues, categories and segments
│   ├── OP-02 getPublicConfig              public read of the public configuration
│   ├── OP-03 listDeletedIssues            public read of the deleted-issue list
│   ├── OP-04 listNewsControls             public read of the news controls
│   ├── OP-05 listNotificationCategories   public read
│   ├── OP-06 getMyAccount                 own account and profile
│   ├── OP-07 manageBookmarks              own bookmarks: add, remove, list
│   ├── OP-08 manageFavourites             own favourites: add, remove, list
│   └── OP-09 managePreferences            own notification preferences
├── Reader server operations (Section 4)
│   ├── OP-10 saveProfile
│   ├── OP-11 getIssueFile
│   ├── OP-12 requestAccountDeletion
│   └── OP-13 cancelAccountDeletion        [withdrawn with PRC-02. The identifier stays, so earlier references resolve]
├── Admin operations (Section 5)
│   ├── OP-14 getMyAdminRole
│   ├── OP-15 listIssuesForAdmin
│   ├── OP-16 saveIssue
│   ├── OP-17 saveCategory and OP-18 deleteCategory
│   ├── OP-19 requestUpload
│   ├── OP-20 listUploadJobs
│   ├── OP-21 publishIssue and OP-22 unpublishIssue
│   ├── OP-23 setNewsControl
│   ├── OP-24 listWordPressPosts
│   ├── OP-25 sendNotification and OP-26 retryNotification
│   ├── OP-27 listNotificationSends
│   └── OP-28 saveSegment and OP-29 saveNotificationCategory   [conditional on AOQ-16 and OQ-18]
├── Further admin operations: issue deletion, reader data and admin management (Section 5.2)
│   ├── OP-30 deleteIssue
│   ├── OP-31 listRegisteredUsers and OP-32 exportRegisteredUsers. OP-33 exportSubscribers is dropped on the working position [CONFLICT, OQ-31]
│   ├── OP-34 searchUsersByEmail
│   ├── OP-35 addAdmin and OP-37 removeAdmin. OP-36 changeAdminRole is withdrawn, because there is one role
│   └── OP-38 listAdmins and OP-39 listAdminChanges
└── Triggered, scheduled and operator steps (Section 6)
    ├── OP-40 onUploadFinalized
    ├── OP-41 scheduledMaintenance
    └── OP-42 bootstrapAdmin
```

The bracket after each operation ("direct" or "server") is its access path. The access paths are a PROVISIONAL mapping onto Firebase (Section 11). The rules that enforce them are in [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) Section 12.

### 3.1 Aliases: the identifiers in the app-side contract

`API_AND_MODULE_CONTRACTS.md` section 8 lists 31 operations under area-based identifiers. This document is the single catalogue and its OP-nn identifiers are the main ones. Each area-based identifier below is an alias of the operation or operations shown. The alias table is PROPOSED. Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed.

| Alias | Name there | Main identifier here | Main name and the difference |
|---|---|---|---|
| OP-CAT-01 | listPublishedIssues | OP-01 | listCatalogue. One read returns issues, categories and segments |
| OP-CAT-02 | getIssue | none | The catalogue is filtered on the device. A single-issue read is not defined here (open, Section 3.4) |
| OP-CAT-03 | listCategories | OP-01 | listCatalogue |
| OP-FILE-01 | requestIssueFile | OP-11 | getIssueFile. Adds the ordered checks, GONE for deleted issues, the revision and rate limiting |
| OP-PRF-01 | getOwnProfile | OP-06 | getMyAccount. Account and profile are returned together |
| OP-PRF-02 | saveOwnProfile | OP-10 | saveProfile. Also writes the account record and the first consent record |
| OP-PRF-03 | recordConsent | OP-10 | saveProfile. The consent record is written on the first call |
| OP-LIB-01 | listBookmarks | OP-07 | manageBookmarks (list) |
| OP-LIB-02 | addBookmark | OP-07 | manageBookmarks (add) |
| OP-LIB-03 | removeBookmark | OP-07 | manageBookmarks (remove) |
| OP-LIB-04 | listFavourites | OP-08 | manageFavourites (list) |
| OP-LIB-05 | setFavourite | OP-08 | manageFavourites (add, remove) |
| OP-NWS-01 | getNewsControls | OP-04 | listNewsControls |
| OP-NTF-01 | registerDevice | none | No device token is stored. One push topic per category (TD-13). A design difference (open, Section 3.4) |
| OP-NTF-02 | unregisterDevice | none | As OP-NTF-01 |
| OP-NTF-03 | getPreferences | OP-09 | managePreferences (and OP-05 for the category list) |
| OP-NTF-04 | savePreferences | OP-09 | managePreferences |
| OP-EML-01 | setEditionUpdateSubscription | none | Conditional on conflict C-02 (OQ-31). Dropped on the working position (GS-Q49). Open in both documents |
| OP-ACC-01 | deleteOwnAccount | OP-12 | requestAccountDeletion. The deletion is immediate (GS-Q50). OP-13 is withdrawn, and the cleanup task in OP-41 only finishes a deletion that stopped part-way |
| OP-ADM-01 | uploadIssue | OP-19, OP-20, OP-40 | requestUpload, listUploadJobs, onUploadFinalized. The upload is staged and validated afterwards (open, Section 3.4) |
| OP-ADM-02 | updateIssueDetails | OP-16 | saveIssue |
| OP-ADM-03 | setIssuePublished | OP-21, OP-22 | publishIssue, unpublishIssue. One operation with a flag against two (open, Section 3.4) |
| OP-ADM-04 | manageCategory | OP-17, OP-18 | saveCategory, deleteCategory |
| OP-ADM-05 | setNewsControl | OP-23 | setNewsControl |
| OP-ADM-06 | sendNotification | OP-25, OP-26 | sendNotification, retryNotification. Adds the record-first states and the manual retry |
| OP-ADM-07 | listSendLog | OP-27 | listNotificationSends |
| OP-ADM-08 | listRegisteredUsers | OP-31 | listRegisteredUsers |
| OP-ADM-09 | exportRegisteredUsersCsv | OP-32 | exportRegisteredUsers |
| OP-ADM-10 | exportSubscriberListCsv | OP-33 | exportSubscribers (conditional on C-02, and dropped on the working position, GS-Q49) |
| OP-ADM-11 | deleteIssue or replaceIssueFile | OP-30, and OP-19 with OP-40 | OP-30 deleteIssue. A replacement is a new revision through OP-19 and OP-40, so delete and replace are separate operations here |
| OP-ADM-12 | adminSignIn | OP-14 | getMyAdminRole. Sign-in itself is the identity provider's job; the operation is the role lookup |

Local-only operations, with no alias: OP-02, OP-03, OP-15, OP-24, OP-28, OP-29, OP-34 to OP-39, OP-41 and OP-42.

### 3.2 Minimum privilege by operation

There is one admin role (RS FR-ADMIN-004, CONFIRMED), and every admin has the same permissions (GS-Q44). In-panel add and remove of admins and a narrow change record are a proposed addition that MFW has not confirmed (OQ-58). S2 excludes editorial roles and an audit log (EXC-07). The two-role model of the version 0.2 text (PRC-01) is withdrawn.

| Operations | S2 baseline | Working position (proposed) |
|---|---|---|
| OP-14 getMyAdminRole | Admin | Any signed-in reader. It returns whether the caller is an admin |
| OP-15 to OP-27 (issues, categories, uploads, publish, news controls, WordPress posts, notifications, send log) | Admin | Admin |
| OP-28, OP-29 | Admin, conditional (AOQ-16, OQ-18) | Not built. Segments and notification categories are seeded by the developers (GS-Q47, GS-Q56) |
| OP-30 deleteIssue | Admin, only if OQ-21 allows | Admin, only after unpublishing and with a typed confirmation (GS-Q45) |
| Replacing an issue file (a new revision through OP-19 and OP-40) | Admin, only if OQ-21 allows | Admin. The old file is kept until the new one is validated (GS-Q45) |
| OP-31, OP-32 (registered-reader list and export) | Admin. PROVISIONAL | Admin (GS-Q49) |
| OP-33 exportSubscribers | Conditional on C-02 | Dropped (GS-Q49) |
| OP-34 searchUsersByEmail | Not in S2 | Admin |
| OP-35 addAdmin, OP-37 removeAdmin | Not in S2 (OQ-20). Admin access is granted by a developer-run step from MFW's admin list | Admin, with a recent sign-in, the last-admin rule and a change record (GS-Q44) |
| OP-36 changeAdminRole | Not in S2 | Withdrawn. There is one role |
| OP-38 listAdmins, OP-39 listAdminChanges | Not in S2 (S2 excludes an audit log) | Admin |
| OP-42 bootstrapAdmin | The first admin is a named step from MFW's admin list (OQ-20) | MFW's authorised approver names the person in writing. One developer runs the step and the other verifies it. The change record holds the written reference |

**Whichever model applies**

1. The server reads the current role record on each privileged call and refuses if it cannot (Section 2.3). The intended guarantee is "refused once the change is visible to the check". Token lifetime and read-after-write visibility stay NOT VERIFIED.
2. There is a proposed test and a fixture for a removed admin (`TESTING_STRATEGY.md` section 9, `TEST_DATA_AND_FIXTURES.md`).
3. The first admin is a named step, even in the baseline (`DEPLOYMENT_PLAN.md` section 7.5).
4. A replacement file never destroys the existing file before the new one is validated (OP-19, OP-40).

### 3.3 Account deletion

Deletion is immediate (RS FR-PRIV-003, CONFIRMED; GS-Q50). The grace window with undo (PRC-02) is withdrawn.

```text
Account deletion
├── Request    OP-12 deletes the account and the reader's data at once. A recent sign-in is required if the provider requires one.
│              The app asks for confirmation (FR-PRIV-004, ASSUMPTION)
├── Undo       None. OP-13 is withdrawn
├── States     active, deleting. Moves forward only (INV-18)
└── Removal    Immediate. The cleanup task in OP-41 finishes a deletion that stopped part-way
```

Backups keep deleted data until they expire, and a restore re-applies deletions made after the restore point (`BACKUP_AND_RECOVERY.md` section 9).

### 3.4 Open design differences

These differences between this document and the app-side contract are listed and not decided. Each needs both developers' agreement.

```text
Open design differences
├── Device tokens or topics     the app-side contract stores device registrations (OP-NTF-01, OP-NTF-02); this contract uses one push topic per category (TD-13)
├── Upload                      one call (OP-ADM-01) or a staged upload that is validated afterwards (OP-19, OP-20, OP-40)
├── Publish and unpublish       one operation with a flag (OP-ADM-03) or two operations (OP-21, OP-22)
└── Single-issue read           OP-CAT-02 getIssue has no counterpart here; the catalogue is fetched whole and filtered on the device (GS-D3, GS-D15)
```

## 4. Public and Reader Operations

### 4.1 Direct operations

These are reads and writes that the database rules allow, with no server code in between. The rules that allow them are in the [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) document, Section 12.

```text
Direct operations
├── OP-01 listCatalogue                              [direct; anyone]
│   ├── In: none
│   ├── Out: the published issues, the issue categories and the industry segments
│   ├── Checks: none. The rules return only issues whose publication_state is published
│   ├── Writes: none
│   └── Requirements: FR-MAG-001 to FR-MAG-008, FR-SRCH-001 to FR-SRCH-005 (CONFIRMED); FR-MAG-009 (OPEN); OQ-13
├── OP-02 getPublicConfig                            [direct; anyone]
│   ├── Out: profile_required_fields, policy_versions, news_category_ids, min_supported_app_version
│   └── Requirements: FR-PROF-001 (PROVISIONAL); INT-WP-003 (CONFIRMED); PRC-04
├── OP-03 listDeletedIssues                          [direct; anyone, an ASSUMPTION (GS-D20)]
│   ├── Out: issue_id and deleted_at for each deleted issue
│   ├── Use: the app removes a downloaded copy whose identifier is on the list. It never removes one because an issue is missing
│   │   from a fetch (GS-Q24)
│   └── Requirements: DATA-013 (CONFIRMED); FR-DL-010 (OPEN); OQ-11; AOQ-19; GS-Q24, GS-Q25
├── OP-04 listNewsControls                           [direct; anyone]
│   ├── Out: wp_post_id, is_hidden and is_breaking for each controlled post
│   └── Requirements: DATA-009, FR-NEWS-008 (CONFIRMED); FR-NEWS-009 (OPEN)
├── OP-05 listNotificationCategories                 [direct; anyone]
│   ├── Out: the three fixed notification categories (GS-Q47)
│   └── Requirements: FR-NOTIF-002, FR-NOTIF-006 (CONFIRMED); OQ-18; GS-Q47
├── OP-06 getMyAccount                               [direct; Reader, own records]
│   ├── Out: the account status and deletion dates, the profile, and the policy versions accepted
│   ├── Checks: the rules allow only the owner
│   └── Requirements: FR-PROF-006 (CONFIRMED); NFR-SEC-006 (ASSUMPTION)
├── OP-07 manageBookmarks                            [direct; Reader, own records]
│   ├── In: add (issue_id, page_number, file_revision), remove (bookmark_id), or list
│   ├── Checks: the rules allow only the owner (INV-11). page_number is at least 1. A bookmark for a missing issue is tolerated and
│   │   cleaned up later (INV-13)
│   ├── Repeat: harmless. The key is (user, issue, page)
│   └── Requirements: FR-BKM-001, FR-BKM-002, FR-BKM-004 to FR-BKM-006, NFR-SEC-005 (CONFIRMED); FR-BKM-007 (ASSUMPTION);
│       FR-BKM-008 (OPEN); OQ-10
├── OP-08 manageFavourites                           [direct; Reader, own records]
│   ├── In: add (issue_id), remove (issue_id), or list
│   ├── Checks: owner only (INV-11). Whether a reader without full access may favourite is OQ-12
│   ├── Repeat: harmless. The key is (user, issue)
│   └── Requirements: FR-BKM-003, FR-BKM-004 to FR-BKM-006, NFR-SEC-005 (CONFIRMED); OQ-12
└── OP-09 managePreferences                          [direct; Reader, own records]
    ├── In: add or remove a notification category, or list. The app also subscribes the device to the matching push topics (TD-13). A logged-out visitor can subscribe the device to the same topics without an account, and the backend stores nothing (GS-Q46)
    ├── Checks: owner only (INV-11). The category exists and is active
    ├── Repeat: harmless. The key is (user, category)
    └── Requirements: DATA-007, FR-NOTIF-002, FR-NOTIF-003 (CONFIRMED); FR-NOTIF-007 (OPEN); OQ-09
```

### 4.2 Reader server operations

```text
Reader server operations
├── OP-10 saveProfile                                [server; Reader]
│   ├── In: request_id; the profile fields in the configured set; on the first call, the privacy-policy and terms-of-use versions accepted
│   ├── Out: the profile status, complete or the names of the missing fields
│   ├── Checks: authenticated; the account is active; every value is valid (trimmed, within length, in format); the accepted
│   │   versions equal the current versions in configuration
│   ├── Refuses: INVALID_ARGUMENT (field names); FAILED_PRECONDITION ACCOUNT_CLOSED; UNAUTHENTICATED
│   ├── Writes: APP_USER (created on the first call, with the caller's identifier), READER_PROFILE, CONSENT_RECORD (first call). The
│   │   email address is not copied
│   ├── Repeat: harmless. The profile is replaced, and a consent record is unique per user, document and version
│   ├── Offline: not queued. The app asks the reader to retry (System Architecture §7.2)
│   └── Requirements: FR-PROF-001 to FR-PROF-005, DATA-004 (PROVISIONAL); FR-PROF-006, FR-PRIV-001 (CONFIRMED); FR-PROF-007,
│       DATA-012 (ASSUMPTION); GS-Q23
├── OP-11 getIssueFile                               [server; Reader]
│   ├── In: issue_id
│   ├── Out: url, expires_at, revision, size_bytes, checksum_sha256
│   ├── Checks, in this order
│   │   ├── 0. If the identifier is on the deleted-issue list, the answer is GONE
│   │   ├── 1. The caller is signed in
│   │   ├── 2. The account is active and not being deleted
│   │   ├── 3. The email is verified. Required for password accounts. For Google accounts it depends on AOQ-09
│   │   ├── 4. The profile is complete, checked only when the gate is on (BR-003)
│   │   ├── 5. The issue exists and is published
│   │   └── 6. A current file revision exists
│   ├── Refuses: UNAUTHENTICATED; FAILED_PRECONDITION with ACCOUNT_CLOSED, EMAIL_NOT_VERIFIED, PROFILE_INCOMPLETE, ISSUE_NOT_AVAILABLE
│   │   or NO_CURRENT_FILE; GONE; RATE_LIMITED
│   ├── Writes: none. The link is neither stored nor logged
│   ├── Repeat: each call issues a new link. A resumed or expired download calls again
│   ├── Also used when: a notification or a shared link leads to a full issue (BR-005). Read and Download both call it. The backend cannot tell them apart and stores nothing about either (GS-Q43, NFR-PRIV-003)
│   └── Requirements: BR-002, FR-READ-001, FR-DL-002, FR-AUTH-010, NFR-SEC-002, INT-FILE-001 (CONFIRMED); BR-003, FR-PROF-004 (PROVISIONAL);
│       BR-005 (ASSUMPTION); AC-3; Section 8
├── OP-12 requestAccountDeletion                     [server; Reader, the account owner]
│   ├── In: request_id; a confirmation flag (FR-PRIV-004). The deletion is immediate (GS-Q50)
│   ├── Out: a confirmation that deletion has started or is done
│   ├── Checks: authenticated; the account is the caller's own; not already deleting. If the caller is an active admin, the
│   │   last-admin rule applies (INV-03)
│   ├── Effects, in one transaction: set APP_USER.status to deleting, and take the account out of the active admin count if it was one.
│   │   Then end the caller's sessions, delete the profile, bookmarks, favourites, preferences, consent record and user record, and delete
│   │   the sign-in account
│   ├── Refuses: FAILED_PRECONDITION LAST_ADMIN or ALREADY_DELETING; UNAUTHENTICATED
│   ├── Repeat: harmless. A repeat returns the same state, and a deletion that stopped part-way is finished by the cleanup task (OP-41)
│   ├── After: the app removes its notification subscriptions and clears local data
│   └── Requirements: FR-AUTH-009, FR-PRIV-003 (CONFIRMED); FR-PRIV-004 (ASSUMPTION); NFR-PRIV-005 (OPEN); AOQ-02; GS-Q50
└── OP-13 cancelAccountDeletion                      [withdrawn with PRC-02. The identifier stays, so earlier references resolve]
```

**Sign-in during deletion.** There is no undo, so there is no window in which the reader signs in again. The deletion removes the sign-in account as it proceeds. A server operation for an account marked deleting is refused with `ACCOUNT_CLOSED` (GS-Q50).

## 5. Admin Operations

Every operation in this section follows Section 2.3: it authenticates the caller, reads the current role record and the account status on this call, and fails closed. "Admin" is the one admin role (RS FR-ADMIN-004, CONFIRMED). A refusal writes nothing (GS-Q44). The panel never reads admin data directly. Every read is an operation here (GS-Q20).

### 5.1 Admin operations

```text
Admin operations                                      [any admin]
├── OP-14 getMyAdminRole                              [server; any signed-in reader]
│   ├── Out: whether the caller is an admin, and is_active
│   ├── Use: the panel shows or hides controls. It is never an authorisation. Every privileged operation checks again (GS-D20)
│   └── Requirements: FR-ADMIN-003 (CONFIRMED); GS-Q20
├── OP-15 listIssuesForAdmin
│   ├── In: an optional publication_state filter, page_size, cursor
│   ├── Out: a page of issues, including unpublished ones, with the current revision's facts
│   └── Requirements: FR-ADMIN-009, FR-MAG-008, NFR-SEC-007 (CONFIRMED); GS-Q20
├── OP-16 saveIssue
│   ├── In: request_id; issue_id (absent to create); title, description, category_id, segment_ids, publication_date, year, edition;
│   │   expected_updated_at when editing
│   ├── Checks: title and description are present; the category and segments exist; year defaults to the year of publication_date.
│   │   It cannot change publication_state, current_revision or the file facts
│   ├── Refuses: INVALID_ARGUMENT; NOT_FOUND; CONFLICT STALE_RECORD
│   ├── Writes: ISSUE, ISSUE_SEGMENT. Audit: none (GS-Q44)
│   ├── Repeat: harmless
│   └── Requirements: FR-ADMIN-009, FR-MAG-002 to FR-MAG-005, NFR-SEC-007 (CONFIRMED); OQ-13
├── OP-17 saveCategory and OP-18 deleteCategory
│   ├── In: request_id; category_id (absent to create), name, display_order. For delete, category_id
│   ├── Checks: the name is not empty and is unique ignoring case. A category in use cannot be deleted
│   ├── Refuses: INVALID_ARGUMENT; CONFLICT; FAILED_PRECONDITION IN_USE
│   ├── Writes: ISSUE_CATEGORY. Audit: none
│   └── Requirements: FR-ADMIN-010, DATA-002 (CONFIRMED)
├── OP-19 requestUpload
│   ├── In: request_id; kind (pdf or cover); issue_id; declared_size_bytes; content_type
│   ├── Out: job_id, upload_url (signed, resumable, short-lived) and expires_at. The URL points to a holding area
│   ├── Checks: the issue exists; the size is within max_upload_bytes (150 MB by default); the content type is allowed. It serves a
│   │   first upload and a replacement (GS-Q45)
│   ├── Refuses: INVALID_ARGUMENT (size or type); NOT_FOUND; RATE_LIMITED
│   ├── Writes: UPLOAD_JOB (pending). Audit: none (GS-Q44)
│   ├── Repeat: harmless. The same request_id returns the same job
│   └── Requirements: FR-ADMIN-005, FR-ADMIN-007, NFR-SEC-008 (CONFIRMED); FR-ADMIN-008, FR-ADMIN-012 (OPEN); OQ-21, OQ-22, OQ-30
├── OP-20 listUploadJobs
│   ├── In: issue_id or job_id
│   ├── Out: the status and the reason for a rejection
│   └── Requirements: FR-ADMIN-006 (CONFIRMED); FR-STATE-007 (ASSUMPTION); GS-Q20
├── OP-21 publishIssue and OP-22 unpublishIssue
│   ├── In: request_id; issue_id
│   ├── Out: the issue with its new state
│   ├── Checks: for publish, in one transaction, the issue has an accepted current revision and has its title, description and
│   │   category (INV-02). A repeat of the same state succeeds and changes nothing
│   ├── Refuses: NOT_FOUND; FAILED_PRECONDITION NO_ACCEPTED_FILE
│   ├── Writes: ISSUE. Audit: none (GS-Q44)
│   └── Requirements: FR-ADMIN-011, FR-MAG-007, FR-MAG-008, NFR-SEC-007 (CONFIRMED); INV-02
├── OP-23 setNewsControl
│   ├── In: request_id; wp_post_id; is_hidden; is_breaking
│   ├── Checks: wp_post_id is a positive integer. A record with neither flag set may be removed
│   ├── Writes: NEWS_CONTROL. Audit: none. Repeat: harmless
│   └── Requirements: FR-ADMIN-013, FR-ADMIN-014, DATA-009 (CONFIRMED); FR-NEWS-009 (OPEN)
├── OP-24 listWordPressPosts
│   ├── In: page, per_page, an optional category filter
│   ├── Out: a page of posts (id, title, date, link, category identifiers) and the number of pages
│   ├── Refuses: UNAVAILABLE when the site cannot be reached
│   ├── Note: the panel does not call the site itself, because cross-origin access from a browser was not researched (TD-12)
│   └── Requirements: FR-ADMIN-013 to FR-ADMIN-015, INT-WP-001 (CONFIRMED)
├── OP-25 sendNotification and OP-26 retryNotification
│   ├── In: request_id; for send, category_id, title, body, target_type (issue, news_post or none) and target_ref; for retry, send_id
│   ├── Out: send_id and the outcome (accepted, failed or unknown)
│   ├── Order for send: check the category and the link target (an issue must be published, a post must exist on the site); write
│   │   the record as pending; send to the category; mark the record accepted or failed
│   ├── Order for retry: the record must be failed or unknown. In one transaction set it to pending and add 1 to attempt_count;
│   │   then send and mark it. Nothing retries automatically (INV-17)
│   ├── Refuses: INVALID_ARGUMENT; NOT_FOUND; FAILED_PRECONDITION TARGET_NOT_AVAILABLE or NOT_RETRYABLE; CONFLICT (another retry has
│   │   started); RATE_LIMITED; UNAVAILABLE (the push service failed and the record is marked failed)
│   ├── Writes: NOTIFICATION_SEND. Audit: none, because the send record shows who sent it
│   ├── Repeat: harmless. The same request_id returns the same send_id
│   └── Requirements: FR-ADMIN-015 to FR-ADMIN-018, DATA-008 (CONFIRMED); INV-17; GS-Q27
├── OP-27 listNotificationSends
│   ├── In: an optional outcome filter, page_size, cursor
│   ├── Out: a page of send records, newest first
│   └── Requirements: FR-ADMIN-018 (CONFIRMED); OQ-19; GS-Q20
└── OP-28 saveSegment and OP-29 saveNotificationCategory      [conditional on AOQ-16 and OQ-18. Not built on the working position: segments and categories are seeded by the developers (GS-Q47, GS-Q56)]
    ├── In: request_id; id (absent to create); name; display_order; is_active
    ├── Checks: the name is unique ignoring case. A value in use cannot be deleted, only made inactive
    ├── Writes: INDUSTRY_SEGMENT or NOTIFICATION_CATEGORY. Audit: none
    └── Requirements: FR-SRCH-003, FR-NOTIF-006 (CONFIRMED); AOQ-16; OQ-18
```

### 5.2 Further admin operations: issue deletion, reader data and admin management

These operations are open to any admin (GS-Q44, GS-Q45, GS-Q49). A caller who is not an admin is refused with `FORBIDDEN`.

```text
Further admin operations
├── OP-30 deleteIssue
│   ├── In: request_id; issue_id; confirmation, the value the admin typed. The rule is that it equals the issue's title (a proposal)
│   ├── Out: confirmation of the deletion
│   ├── Checks: the caller is an admin; the issue exists; it is unpublished (INV-15); the confirmation matches
│   ├── One transaction: delete the issue and its segment links, write the deleted-issue record
│   ├── Afterwards: remove the file revisions, the cover and the upload jobs. Orphan cleanup removes the readers' bookmarks and
│   │   favourites (DM §10.3)
│   ├── Refuses: FORBIDDEN; NOT_FOUND; GONE (already deleted); FAILED_PRECONDITION NOT_UNPUBLISHED or CONFIRMATION_MISMATCH
│   ├── Audit: none (GS-Q44). Repeat: the same request_id returns the first result
│   └── Requirements: FR-ADMIN-012 (OPEN); OQ-21; OQ-11; INV-15; GS-Q45
├── OP-31 listRegisteredUsers
│   ├── In: page_size, cursor
│   ├── Out: a page of readers: user_id, email (from the sign-in provider), the profile fields and created_at. Accounts being deleted are hidden
│   ├── Audit: none (GS-Q44)
│   └── Requirements: FR-USER-002 (PROVISIONAL); NFR-PRIV-004 (ASSUMPTION); AOQ-05; GS-D6, GS-Q49
├── OP-32 exportRegisteredUsers
│   ├── Out: a CSV built in memory and not stored. Cells that start with a formula character are neutralised
│   ├── Audit: none (GS-Q44)
│   └── Requirements: FR-USER-003 (PROVISIONAL); NFR-PRIV-004 (ASSUMPTION); AOQ-05; GS-Q49
├── OP-33 exportSubscribers                           [dropped on the working position (GS-Q49); the list does not exist unless OQ-31 keeps it]
│   ├── Out: a CSV built in memory
│   └── Requirements: FR-USER-001 (CONFLICT); FR-EMAIL-001 (CONFLICT); DATA-010 (CONFLICT); OQ-31
├── OP-34 searchUsersByEmail
│   ├── In: an email address
│   ├── Out: the matching user_id, whether the person is already an admin, and whether the email is verified
│   ├── Audit: none (GS-D19). Rate limited (Section 2.7)
│   └── Requirements: FR-USER-005 (OPEN); OQ-58; GS-Q44
├── OP-35 addAdmin and OP-37 removeAdmin              [OP-36 changeAdminRole is withdrawn: there is one role]
│   ├── In: request_id; target_user_id; expected_state (admin or not); for a removal, a confirmation that names the person
│   ├── Out: the role record
│   ├── Checks: the caller is an admin by the record; the token is not revoked; the sign-in is recent (AOQ-14); for an addition the
│   │   target is a registered reader whose account is active and whose email is verified; for a removal the target is an admin
│   ├── One transaction: read the guard record; check the last-admin rule for a removal (INV-03); check expected_state (INV-07); write the
│   │   role record, the change record and the guard record (INV-04)
│   ├── After a removal commits: end the target's sessions, with retry (INV-09). A failure there does not undo the change
│   ├── Refuses: FORBIDDEN; NOT_FOUND; INVALID_ARGUMENT (a removal with no confirmation); FAILED_PRECONDITION RECENT_SIGN_IN_REQUIRED,
│   │   TARGET_ACCOUNT_CLOSED, TARGET_EMAIL_NOT_VERIFIED, ALREADY_ADMIN, NOT_AN_ADMIN or LAST_ADMIN; CONFLICT STALE_ADMIN_STATE
│   ├── Audit: admin_add or admin_remove. Repeat: the same request_id returns the first result
│   └── Requirements: FR-ADMIN-003, FR-ADMIN-004 (CONFIRMED); FR-USER-005, NFR-SEC-011 (OPEN); EXC-07; OQ-58; INV-03 to INV-09; GS-Q33, GS-Q44
├── OP-38 listAdmins
│   ├── Out: every admin role record
│   └── Requirements: OQ-58; GS-Q44
└── OP-39 listAdminChanges
    ├── In: page_size, cursor
    ├── Out: a page of change records, newest first
    ├── Audit: none
    └── Requirements: NFR-SEC-011 (OPEN); OQ-58; AOQ-04; GS-Q44
```

## 6. Triggered, Scheduled and Operator Operations

```text
Triggered, scheduled and operator operations
├── OP-40 onUploadFinalized                           [trigger; a file arrives in the holding area]
│   ├── In: the uploaded object and its upload job
│   ├── Steps
│   │   ├── 1. Re-check the uploader's current role (INV-08)
│   │   ├── 2. Check that the file is a genuine PDF, not only by its name, and within the size limit. A cover goes through its own checks (OQ-22)
│   │   ├── 3. Move the file to the private path and remove it from the holding area
│   │   └── 4. In one transaction mark the old current revision superseded, write the new revision as current, set current_revision, the
│   │       size and the page count on the issue, and set the job to accepted (INV-01)
│   ├── Rejects (job rejected, object removed): upload_rejected, with the reason NOT_A_PDF, OVER_LIMIT, UPLOADER_NOT_AUTHORISED or COVER_INVALID
│   ├── Failure: if the database write fails after the move, an orphan file remains and cleanup removes it
│   └── Requirements: FR-ADMIN-006, FR-ADMIN-007, NFR-SEC-007, NFR-SEC-008 (CONFIRMED); FR-ADMIN-008, FR-ADMIN-012 (OPEN); INV-01, INV-08
├── OP-41 scheduledMaintenance                        [schedule; runs under the backend's own credentials]
│   ├── Every task is repeatable. A run that stops part-way continues on the next run
│   ├── Daily: account deletion cleanup, which finishes deletions left in the deleting state (TD-19, GS-Q50); the holding area and finished upload
│   │   jobs; superseded revisions after their retention period
│   ├── Hourly (ASSUMPTION): the admin count repair (INV-03); marking stale pending sends as unknown (INV-17)
│   ├── Weekly: orphaned reader records; orphaned user records
│   ├── Monthly: orphaned news controls; deleted-issue records past their retention period, if MFW sets one (AOQ-19)
│   └── Requirements: FR-PRIV-003 (CONFIRMED); GS-Q50; DM §10.3
└── OP-42 bootstrapAdmin                              [developer-run step; not an operation a client can call]
    ├── Who: MFW's authorised approver names the person in writing (the approver is not yet named, OQ-28). One developer runs the
    │   documented step under role-based access (NFR-SEC-012). The other developer verifies it (GS-Q33). The developers then hand
    │   access to MFW (GS-Q44)
    ├── Precondition: the person has registered an ordinary reader account
    ├── Effects: create the admin role record with a fixed marker as granted_by; create the guard record with a count of 1; write
    │   a change record bootstrap_admin that holds the written reference
    ├── Guard: the step refuses to run while an active admin exists, unless it is declared a recovery and carries the written
    │   reference. A recovery follows the same two-person procedure (GS-Q33)
    └── Requirements: FR-USER-005, NFR-SEC-011 (OPEN); NFR-SEC-012 (CONFIRMED); INV-03; GS-D4, GS-Q33, GS-Q44; the procedure is in
        [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) Section 7
```

## 7. WordPress Integration Contract

WordPress is the master source of news (DATA-015) and the project makes no change to the site (INT-WP-002). The app and the panel only read from it. The proposed access is option A of TD-12: the app calls the site directly and the backend reads it only for the panel's post picker. TD-12 is proposed and not approved. The observations on the site are in Appendix A.

```text
WordPress read contract                         [read only; TD-12 proposed; INT-WP-001 to INT-WP-005 (CONFIRMED)]
├── Direction and credentials
│   ├── The app sends HTTPS GET requests to the site's API and sends no credentials and no personal data (NFR-SEC-001)
│   ├── The admin panel does not call the site. It uses OP-24, because cross-origin access from a browser was not researched
│   └── The routes are the standard WordPress routes for posts and categories, observed under /wp-json/wp/v2/ (WEB)
├── List posts
│   ├── Request: a page number; a small page size (INT-WP-004); the category identifiers MFW selected (INT-WP-003); only the fields
│   │   the app needs; embedded media
│   ├── Documented limits: 10 posts by default and 100 at most per request, headers that give the total count and the page count, and a
│   │   modified-after filter (VS-41)
│   ├── Fields used: id, date, modified, slug, link, title, content, featured image and categories (INT-WP-005)
│   └── Result: the list is merged with the news controls (OP-04). Hidden posts are removed and breaking posts are flagged (FR-NEWS-008)
├── Get one post
│   └── The article page uses the cached post, or one request for the post by id
├── Categories
│   ├── The app filters the list by category (FR-NEWS-003) and shows only the categories MFW selects (INT-WP-003)
│   ├── The selected identifiers are configuration (news_category_ids). Which ones MFW selects is not yet known (REG-043)
│   └── Observed: only Industry News has posts (Appendix A)
├── Rendering
│   ├── Post content is HTML from MFW's site, shown by a sanitising renderer (TD-12). Scripts, styles, forms and embedded frames are not run
│   ├── Observed: the content of a sample post was page-builder markup of about 32 KB. How it looks in the app has to be tested with real
│   │   posts (recommendation, unverified). How embedded media is shown is OPEN (OQ-16)
│   └── Observed: the excerpt of the sample post began with the word "Home". The app should not show the site's excerpt as written until
│       that is settled (recommendation; the choice is unresolved)
├── Cache and offline
│   ├── Recent articles are cached on the device and stay readable offline with a notice (FR-NEWS-005)
│   └── Whether articles are saved by an explicit action or automatically, and how many are kept, is OPEN (OQ-16)
├── Failure
│   ├── If the site cannot be reached, the app shows the cached articles and a message (FR-STATE-005)
│   └── If the host throttles or blocks the app (CH R5), the design moves to a backend cache, which is option B of TD-12
├── Not used
│   └── Comments, the author, tags (none are in use) and the site's pages. The app does not write to the site
└── Unresolved, for MFW
    ├── The host's capacity and whether the API stays reachable (REG-042)
    ├── Which categories the app shows (INT-WP-003, REG-043)
    └── How a breaking post is shown (OQ-17)
```

## 8. File Delivery Contract

This section describes intended behaviour. Resume, byte-range support, link expiry, unpublishing and offline retention are listed with what has and has not been tested in `TESTING_STRATEGY.md` section 16. Nothing in that table has been tested.

```text
File delivery
├── Download of an issue (OP-11)
│   ├── The link: one object, the current revision; read-only; short-lived. The lifetime is signed_url_lifetime, and 60 minutes is an
│   │   ASSUMPTION (AOQ-07)
│   ├── Needed from the file store: byte-range reads on the issued link, so that a broken download can resume (FR-DL-006). This is
│   │   unproven (AR-01) and is the subject of the TD-09 proof plan
│   ├── The app: checks the size and checksum (FR-READ-010); moves the file to private app storage; adds a registry row; asks for a
│   │   new link after expiry
│   └── The link is a temporary credential. It is never stored in the database and never logged (DM §9)
├── Upload of an issue file or a cover (OP-19, OP-40)
│   ├── The panel uploads to a holding area through a signed, resumable, short-lived URL. Nothing in the holding area is readable by readers
│   ├── Validation is done by the backend and not only by the panel (NFR-SEC-008): a genuine PDF, the size limit (150 MB by default,
│   │   OQ-30), and the cover rules (OQ-22, OPEN)
│   ├── An accepted PDF moves to the private area at a path that includes its revision, so a revision's path is never overwritten
│   └── A replacement adds the next revision. Readers keep what they downloaded and see an updated badge (DM §6.2)
├── Covers
│   ├── A cover is in the public-read area and anyone can fetch it by its address (GS-D7)
│   └── Before publication a cover is reachable by anyone who knows its address. Addresses are opaque (AOQ-20)
└── The website's copy of an issue
    ├── The same issue may be public on MFW's website as a separate object that WordPress owns (WEB)
    ├── This contract never serves, links to or depends on that copy. The app's file store is the only source the app uses (GS-Q32)
    └── The check in OP-11 controls the app's copy only (AOQ-18, now OQ-57). The [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md)
        document says what the gate is for
```

## 9. Compatibility, Versioning and the Update Gate

Installed apps stay on old versions for months, and the two developers change the backend independently. This policy keeps a change to a contract from breaking an installed app. It is PROPOSED (GS-Q29; agreement between the developers is reported by YG and not filed), with the requirement label PROVISIONAL. Only the update gate (Section 9.6) is a proposed addition to S2 scope that needs MFW's agreement. Nothing in this section exists yet (Section 9.8).

### 9.1 Backward compatibility by default

```text
Compatibility rules
├── Additive changes, allowed without ceremony
│   ├── A new optional input field, with a default that keeps the old behaviour
│   ├── A new field in a response or a document
│   ├── A new operation
│   ├── A new reason code, and a new value in an enumeration that a response returns
│   └── Condition: clients ignore unknown fields and treat an unknown reason code or enumeration value as the generic case for its
│       category. The app must implement this, and CT-04 tests it
└── Breaking changes, which need Section 9.2
    ├── Removing or renaming an operation, a field or a reason code
    ├── Changing a field's type, meaning or unit
    ├── Making an optional input required, or tightening validation so a request that was valid now fails
    ├── Changing the error category for an existing situation
    ├── Changing who may call an operation, or the order or guarantee a client relies on
    └── Changing a stored document so that an installed app can no longer read it
```

### 9.2 Breaking changes need a record and an approval

No breaking change is made until a compatibility record exists. The record is the pull request that makes the change plus an entry in the change history of this document.

```text
Compatibility record for a breaking change
├── What changes: the operation or field, and the old and new behaviour
├── Why: the rationale, and what was considered instead
├── Impact: the assessment in Section 9.3
├── Migration plan: the steps and the order (Section 9.5)
├── Rollout and rollback: what is deployed first, how it is undone (Section 9.5)
├── Minimum supported app version: needed or not, and the value when it is set (Section 9.6)
└── Approval: both developers (CH §17.4). MFW's authorised approver as well, if scope, cost or an S2 acceptance criterion changes
    (the change process in the scope document). No other approver is created here
```

### 9.3 Compatibility assessment

```text
Assessment checklist                                   [answer each line in the record]
├── Android app versions in the field, and iOS app versions in the field
├── Cached data: the database cache, the cached catalogue, the article cache and the deleted-issue list
├── Authentication: sign-in methods, token contents, and the account states the backend checks
├── Offline reading: a downloaded issue and its registry row must stay readable after the change (FR-DL-007)
├── Admin operations: a panel left open in a browser may be older than the backend
└── Integrations: the WordPress site, push topics and the sign-in provider
```

### 9.4 Versioning

```text
Versioning
├── Operations are addressed by name. No version number is placed in an address, and no URL scheme is invented for callable functions
├── A breaking change gets a new operation name, and the old operation stays until its removal criteria are met (Section 9.7)
├── Stored data has schema_version in configuration (DM §10.5)
├── The WordPress API has the site's own version, which this project does not control
└── Where a platform offers versioning of its own, it is adopted in the mapping (Section 11). None is assumed
```

### 9.5 Migration and rollout

```text
Rollout of a breaking change
├── 1. Deploy the new operation next to the old one, so both work
├── 2. Release an app version that uses the new operation
├── 3. Keep both for a compatibility period. Its length is OPEN, and no period is set here
├── 4. When MFW agrees, raise the minimum supported app version (Section 9.6)
├── 5. Remove the old operation when its removal criteria are met (Section 9.7)
├── Rollback before step 5: stop using the new operation. The old one is still there
├── Rollback of a backend release: redeploy the previous release from source control. The previous release must still read the data
└── Data changes: additive steps first, a backup and a tested restore before any destructive step (DM §10.5)
```

### 9.6 The update gate (PRC-04)

```text
Update gate                                            [PROPOSED (GS-Q29; agreement reported by YG, not filed), PROVISIONAL, MFW agreement pending; a proposed addition to S2 scope]
├── Setting: min_supported_app_version in the public configuration (OP-02). No value is set
├── Behaviour: an app whose version is lower shows an update-required screen with a link to its store listing (which link is OQ-15)
├── Offline: the app uses the last value it read. What the gate does to reading downloaded issues offline is OPEN and is decided before
│   the gate is built
├── Limit: the gate stops only app versions that contain it, so it has to be in the first release if it is wanted
├── Not verified: whether the app stores restrict or review forced updates (Technology Decisions §9.4, item 23)
└── Effort: not estimated here
```

### 9.7 Deprecation

```text
Deprecation record
├── Affected: the operation or field
├── Replacement: the operation or field that takes its place
├── Migration guidance: what each client changes, and from which app version
├── Removal criteria: no supported app version still calls it. A version is supported when it is at or above the minimum supported
│   app version once PRC-04 exists. Until then the developers and MFW agree a date in writing
└── Steps: mark it deprecated in the change history, add the replacement, keep the old one, remove it only when the criteria are met,
    and record the removal with the same approval as a breaking change
```

### 9.8 Approval and implementation status

```text
Status of this policy
├── Decision: PROPOSED (GS-Q29). Agreement between the developers is reported by YG. No date. Sanika's written note or approving PR review is not filed. Requirement label PROVISIONAL. MFW written approval pending for the update gate (PRC-04)
├── Not CONFIRMED: no source document or MFW approval establishes it
├── Built: nothing. The repository holds no code, because the project is in the documentation stage
├── Does not exist yet: a versioning scheme, contract tests, deprecation records, the update gate and any enforcement of a minimum version
└── Effort: no estimate, including the earlier PRC-01 figure, covers this policy
```

## 10. Contract Tests

These tests are proposed. None is written, and none has been run. They run against the emulators in continuous integration where that is possible (TD-17). The permission and security tests are in [Security and Access Control](SECURITY_AND_ACCESS_CONTROL.md) §14.

```text
Contract tests                                         [proposed; none exists]
├── CT-01 Contract snapshot         each operation's inputs, outputs, error categories and reason codes are kept as a reference file.
│                                   A change that removes or renames anything fails the build
├── CT-02 Old-client replay         recorded requests from each released app version are replayed against the current backend, and each
│                                   still gets a valid answer
├── CT-03 Additive check            adding an optional field or a new operation passes. Making an optional input required fails
├── CT-04 Tolerant reader           the app ignores unknown response fields and treats an unknown reason code or enumeration value as the
│                                   generic case for its category
├── CT-05 Error stability           each refusal returns its documented category and reason code
├── CT-06 Repeats                   replaying a write with the same request_id returns the first result, adds no record and adds no
│                                   second change record
├── CT-07 Authorisation             for every operation, a signed-out caller, a reader, an admin and a removed admin
│                                   each get the documented answer
├── CT-08 Update gate               an app below the minimum version shows the update-required screen. An app at or above it does not. With
│                                   no value set, nothing is gated
├── CT-09 WordPress shape           the app handles a missing field, an extra field, an empty list and an unreachable site
├── CT-10 Cached data               an app updated from the previous release still reads its cached catalogue, bookmarks and downloads
└── CT-11 Deprecation               a deprecated operation still works until its removal criteria are met
```

## 11. Firebase Mapping (PROVISIONAL)

Everything in this section is PROVISIONAL. Firebase is the proposed baseline (TD-03, CONFLICT C-05), and each service is proposed and not approved. The sections above do not change if another platform is chosen. Only services named in the project's documents are mapped.

```text
Firebase mapping                                       [PROVISIONAL; TD-03 proposed, CONFLICT C-05]
├── Cloud Firestore (TD-07)
│   ├── Direct operations OP-01 to OP-09 under security rules. The collections are in DM §12
│   └── Rules deny by default (SEC §12)
├── Firebase Authentication (TD-06)
│   ├── Email and password (FR-AUTH-001 to FR-AUTH-004), and Google Sign-In (FR-AUTH-005, PROVISIONAL; OQ-06)
│   ├── The provider's user identifier is user_id. The email address is read from the provider and not copied (GS-Q5)
│   └── No role is carried in a sign-in claim (GS-Q20)
├── Cloud Functions, TypeScript (TD-04)
│   ├── Server operations OP-10 to OP-39 as callable functions, the upload trigger OP-40, and one scheduled function OP-41
│   │   (the scheduler's free allowance is three jobs per account, VS-14)
│   ├── A callable function receives the caller's sign-in identity. It still reads the role record on every call (INV-08)
│   ├── The Admin SDK bypasses security rules (TD-03), so each function checks the caller itself
│   └── Errors map to the callable error codes: UNAUTHENTICATED, permission-denied, failed-precondition, not-found, invalid-argument,
│       resource-exhausted, unavailable and internal. The exact names are confirmed at implementation. The reason code travels in
│       the error details. GONE is carried as not-found with the reason GONE, and RATE_LIMITED as resource-exhausted (assumptions)
├── Cloud Storage (TD-08, TD-09)
│   ├── A private area, a public cover area and a holding area. Rules deny every direct client read of the private area
│   ├── V4 signed URLs for downloads and for resumable uploads. A storage-finalised event starts OP-40
│   └── Resume on a signed URL is unproven (AR-01)
├── Firebase Cloud Messaging (TD-13)
│   └── One topic per notification category. OP-25 sends to a topic. No device token is stored by the backend
├── Firebase Hosting (TD-14, TD-18)
│   └── Serves the React admin panel. It is not an API
├── Crashlytics (TD-16)
│   └── Crash reports only. It is not an operation. Analytics collection is off (GS-Q10)
└── App Check (AOQ-10)
    └── Open. Not assumed
```

```text
Firebase constraints and verification gaps
├── Transactions and uniqueness
│   ├── Firestore is not assumed to enforce references or uniqueness. The mechanisms are in DM §10.8
│   └── How transactions behave when two changes touch one record is NOT VERIFIED (Technology Decisions §9.4, item 20)
├── Security rules
│   ├── Rules do not join across collections, and the admin reads that needed a role lookup are functions instead (GS-Q20)
│   └── How many documents a rule may read, and whether a rule can see a revoked token, are NOT VERIFIED (item 21). Nothing relies on them now
├── Server-side authorisation
│   └── Every function checks the caller on every call, because the Admin SDK ignores rules (TD-03)
├── Signed URLs
│   ├── Whether a V4 signed URL honours the Range header is NOT VERIFIED (item 6, AR-01)
│   └── A link cannot be withdrawn before it expires (AR-06)
├── Queries and indexes
│   └── Composite indexes are validated against the platform before they are relied on (DM §18)
├── Callable function limits
│   └── Request size, response size and run time limits were not researched. An export built in memory (OP-32) may need another route if the user list grows
├── Push
│   ├── An accepted send is not a delivery (NFR-REL-003)
│   └── Whether a repeated send reaches devices twice is NOT VERIFIED (item 22)
└── Stores
    └── Whether the stores restrict or review a forced update is NOT VERIFIED (item 23)
```

## 12. Traceability

```text
Decisions to operations
├── GS-Q18 Neutral core with a Firebase mapping        Sections 2 to 10 are neutral. Section 11 is the mapping
├── GS-Q19 Two admin roles (replaced by GS-Q44)        OP-14, OP-35 to OP-39, OP-42
├── GS-Q20 Admin reads through functions               OP-14, OP-15, OP-20, OP-24, OP-27, OP-31, OP-38, OP-39
├── GS-Q21 Replace a PDF, delete an issue              OP-19, OP-30, OP-40
├── GS-Q22 Only a Super Admin deletes (replaced by GS-Q45)   OP-30
├── GS-Q23 Working profile list (partly reversed by GS-Q34)                        OP-10
├── GS-Q24 Downloaded copies                           OP-03, OP-11
├── GS-Q25 Deleted-issue list, opaque identifiers      OP-03, OP-11, OP-30
├── GS-Q26 Audit set (narrowed by GS-Q44)              OP-35, OP-37 and OP-42 only
├── GS-Q27 Notification send                           OP-25, OP-26, OP-27, OP-41
├── GS-Q28 Account deletion with a window (replaced by GS-Q50)   OP-12, OP-41
├── GS-Q29 Compatibility and the update gate           Sections 9 and 10, and OP-02
├── GS-Q30 Labels                                      Section 1.2
├── GS-Q31 Taxonomy                                    OP-01, OP-17, OP-28, Section 7 and Appendix A
├── GS-Q32 Channel policy                              OP-11, Section 8 and Appendix A
├── GS-Q33 Bootstrap and recovery                      OP-42
├── GS-Q43 Read and Download                           OP-11
├── GS-Q44 One Admin role, in-panel add and remove     OP-14, OP-30 to OP-32, OP-34 to OP-39, OP-42
├── GS-Q45 Any admin: unpublish, replace, delete       OP-19, OP-21, OP-22, OP-30, OP-40
├── GS-Q49 Registered-user export only                 OP-31, OP-32
└── GS-Q50 Immediate account deletion                  OP-12, OP-41
```

```text
S2 acceptance criteria and the operations behind them
├── AC-1 Publish and find an issue                     OP-01, OP-16, OP-19, OP-21
├── AC-3 Sign-in gate and account deletion             OP-10, OP-11, OP-12
├── AC-4 Download, resume, read offline                OP-11 and Section 8
├── AC-5 Bookmarks and favourites                      OP-07, OP-08
├── AC-7 News                                          Section 7, OP-04
├── AC-8 Admin panel                                   OP-14 to OP-27, OP-31, OP-32
├── AC-9 Notifications                                 OP-05, OP-09, OP-25 to OP-27
└── AC-12 Handover                                     This document and the other documents in the set
```

## 13. Open Questions and Verification Gaps

```text
Open items
├── For MFW
│   ├── OQ-09, OQ-11, OQ-13, OQ-16, OQ-17, OQ-18, OQ-19, OQ-21, OQ-22, OQ-24, OQ-27, OQ-30, OQ-31
│   ├── FR-USER-005 and NFR-SEC-011 (OQ-20), AOQ-04, AOQ-05, AOQ-16, AOQ-18 (OQ-57), AOQ-19
│   ├── OQ-58 (in-panel add and remove), and PRC-03 and PRC-04, which need MFW's written approval. PRC-01 and PRC-02 are withdrawn
│   └── Which news categories the app shows (INT-WP-003, REG-043), and the host's capacity (REG-042)
├── For the development team
│   ├── AOQ-07 (link lifetime), AOQ-09 and AOQ-08 (linking), AOQ-10 (App Check), AOQ-13, AOQ-14 (recent sign-in), AOQ-20 (covers)
│   ├── How long a request identifier is remembered, the largest page size, and every rate-limit value
│   ├── The rule for the typed confirmation in OP-30
│   └── What the update gate does to offline reading of downloaded issues
└── Not verified
    ├── Technology Decisions §9.4 items 6, 7, 12, 16, 20 and 21, and the new items 22 and 23
    └── The limits of callable functions
```

## Appendix A. Website Observations

The observations come from a read-only review of MFW's public website on 23 October 2026 (WEB). They describe the existing product. They are a reference only. They do not change the approved scope, they are not MFW's approval, and they create no requirement. Facts, recommendations and unresolved items are kept apart. Nothing was downloaded, and the only request for a file was a header-only request for one PDF.

```text
Website observations (WEB)                             [observed 23 October 2026; read only]
├── Pages read
│   ├── https://metalformingworld.com/ (home), /about/, /industry-news/, /contact/ and /april-may-2026-issue/
│   ├── The section pages /industry-watch/, /hall-of-fame/, /world-gateway/, /case-studies/, /innovators/, /project-updates/,
│   │   /product-view/ and /event-coverage/, and /news/
│   └── The public WordPress API under /wp-json/wp/v2/ (posts, categories, tags, pages, media, types, taxonomies), and /robots.txt
├── Facts observed
│   ├── Platform: WordPress with the Elementor page builder. A footer credit names Globbuzz Media Private Limited. The names of the
│   │   plugins listed by the API suggest Hostinger hosting with LiteSpeed caching. That is an inference (REG-042)
│   ├── Menu: Home, About, News, one issue link, Contact, and a Subscribe link that goes to the Contact page. The News menu lists
│   │   nine section pages. The footer link "News" goes to /news/, which returns "Page not found". The social icons have no link targets
│   ├── Issues: three issue pages are published: April-May 2026 (21 April), June-July 2026 (30 June) and August-September 2026
│   │   (15 August). The menu links only April-May. The April-May page shows a flipbook of a PDF and holds no category, description,
│   │   cover, segment or edition number. The other two pages were not opened
│   ├── PDFs: they are media uploads. April-May is 7.7 MB and 28 pages. August-September is 15.3 MB, with smaller variants of 9.2 and
│   │   9.6 MB. The largest is 15.3 MB, against the 150 MB limit. The media list returned 5 PDFs while its header said 7, and none was
│   │   for June-July
│   ├── Public access: a header-only request for the April-May PDF returned 200 with no sign-in. The file supports byte ranges and
│   │   may be cached publicly for about 31 days. Only that file was tested at first. A later header-only check on 23 October 2026 of three files (7.7, 9.2 and 9.6 MB, none downloaded) also returned 200 without sign-in. The 15.3 MB file was not checked
│   ├── Cadence: the editorial calendar on /about/ lists 8 issues for 2026-27. April-May, June-July, August-September and
│   │   October-November 2026, then December 2026, January, February and March 2027 as single months. The published issues are
│   │   two-monthly, and the later ones are not
│   ├── News: the API holds 11 posts, all in Industry News and dated 16 to 21 March 2026. None is newer. The three posts checked
│   │   each have a title, date, modified date, slug, link, one author, a featured image and a category. No tags are in use. The sample
│   │   post allows comments
│   ├── Categories: 10 flat categories. Only Industry News has posts
│   ├── Content: the sample post's body was about 32 KB of page-builder markup, and its excerpt began with the word "Home"
│   ├── Industries and editorial themes: see the Database and Data Model, Appendix B
│   └── Sign-up: the home page has a Name and Email form with a Sign Up button. What it does with the data is unknown
├── Differences from the app requirements
│   ├── The site holds no per-issue metadata, so the admin panel enters it
│   ├── The brief describes about one issue every two months, and the site's calendar is not uniformly two-monthly
│   ├── The site labels issues by period and shows no edition number (OQ-13)
│   ├── The site has no marker for breaking news (OQ-17)
│   ├── The issue PDFs are public on the site, and the app requires sign-in (AOQ-18, OQ-57)
│   ├── The news is thin and the newest post is from March 2026
│   └── The footer link "News" is broken
├── Recommended
│   ├── Treat the site as a reference. Do not change the app's scope because of it
│   ├── Taxonomy: as in the Database and Data Model, Appendix B (PROVISIONAL)
│   └── WordPress contract: as in Section 7
└── Unresolved, for MFW
    ├── Whether the public PDFs on the website are meant to stay public (AOQ-18, now OQ-57). Three files were checked, by header only
    ├── Which news categories the app shows (INT-WP-003, REG-043)
    ├── The host's capacity (REG-042), and what the sign-up form does (OQ-31)
    └── Cover images: none were seen on the issue page that was opened (OQ-22)
```
