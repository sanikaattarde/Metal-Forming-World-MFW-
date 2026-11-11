# MFW backend

The backend on Firebase (DEC-003, AGREED). This folder holds the Cloud Firestore and Cloud Storage access rules (MOD13-P1-T01 to T03), the Cloud Functions in `functions/` (TypeScript, DEC-025), and their tests on the local emulators. Nothing here is deployed: no cloud project exists yet (`Documentation/CLOUD_ACCESS_SETUP_CHECKLIST.md`), and ENV-TEST waits for MFW's answer to OQ-40.

The functions were first built on the emulator spike, branch `spike/sa-backend-rules`. Its notes, `backend/spike/01-*.md` to `10-*.md` on that branch, hold the findings and the deliberate-break checks; a code comment that says "spike note 07" points there.

## Set-up

1. Install Node.js 22 or later (DEP-79). The tests were run with Node.js 26.0.0.
2. Install Java 21 or later (DEP-83), which the emulators need. With Homebrew's `openjdk@21`, `scripts/run-with-env.sh` puts it on `PATH` for the one command, so nothing global changes.
3. From this folder, install the pinned tools and the functions' packages from the lockfiles:

   ```bash
   npm ci && npm --prefix functions ci
   ```

## Tests

```bash
npm test
```

It builds `functions/`, starts the Auth, Functions, Firestore and Storage emulators for the project `demo-mfw`, which needs no login and no cloud project, runs every file in `test/`, and stops them. The emulator downloads are kept in the ignored `node_modules/.cache/`. On 10 November 2026: 1,039 tests, 1,039 passed (emulator only).

| Group | File | What it shows |
|---|---|---|
| G1 Deny by default | `test/g1-deny-by-default.test.mjs` | The records with no client access, and paths no rule lists, are refused to six actors, including an admin account and readers with forged admin claims. Listing and collection-group queries are refused |
| G2 Public reads | `test/g2-public-reads.test.mjs` | Segments, categories, notification categories, news controls, the deleted-issue list, the public configuration and published issues are readable by anyone and writable by no client. An unpublished issue is refused, and a query must filter on the published state |
| G3 Own records | `test/g3-own-records.test.mjs` | A reader reads their account, profile and consent records, and reads and writes their bookmarks, favourites and notification preferences, with the fields checked. Once written, none of the three can be changed, `created_at` included; a replayed write passes. Every other actor is refused |
| G4 File store | `test/g4-storage.test.mjs` | Issue files, the holding area and unlisted paths are refused to every client. Covers are readable by anyone and writable by no client |
| G0 Auth emulator | `test/g0-auth-emulator.test.mjs` | The Auth emulator creates and signs in a test account (UA-8) |
| G6 Save profile | `test/g6-save-profile.test.mjs` | OP-10 through the Functions emulator: the first save, later saves, consent records, the segment check, closed accounts and an unusable configuration |
| U1 Profile checks | `test/u1-profile-checks.test.mjs` | The profile and configuration checks of OP-10, with no database |
| G8 Admin operations | `test/g8-admin-operations.test.mjs` | OP-15 to OP-18 and OP-21 to OP-23 through the Functions emulator: every privileged call refused to a visitor, a reader, a closed or removed admin and forged claims; the details checks, stale-record and name conflicts, retries with the same request identifier, publishing only with an accepted file |
| U2 Issue checks | `test/u2-issue-checks.test.mjs` | The OP-16 input checks and the derived identifier, with no database |
| G9 Seed | `test/g9-seed.test.mjs` | The loader writes the three categories into the emulator, is safe to run twice, leaves other records alone and refuses any address that is not a local emulator |
| U4 Seed definitions | `test/u4-seed.test.mjs` | The seed file's checks: identifiers, names, order and fields, with no database |
| G7 Issue file | `test/g7-issue-file.test.mjs` | OP-11 through the Functions emulator: the allowed reply and its five fields; each of check 0 and the six ordered checks, and their order; forged claims; unpublishing stops new links at once; an unusable or over-ceiling lifetime refuses the call; the log holds no link |
| U3 Issue file parts | `test/u3-issue-file-parts.test.mjs` | The key check, the profile computation, the log wrapper and the emulator grant issuer, with no database |
| U6 Signed links | `test/u6-signed-links.test.mjs` | The signed-URL issuers of DEC-020 against a fake file: V4, the action, the path, the expiry, the one-hour ceiling, and that the emulator issuer is chosen only on the emulators |
| G10 Uploads | `test/g10-uploads.test.mjs` | OP-19, OP-20 and OP-40 through the emulators: a job and its upload address for an admin only; the size and type checks; a genuine PDF accepted as the next revision, a fake, an over-limit file, a file with no pending job and a file from a removed admin refused and deleted; a replacement keeps revision 1 until it succeeds |
| U5 PDF check | `test/u5-pdf-check.test.mjs` | The genuine-PDF check on generated files (FX-PDF-06 to FX-PDF-13) and the emulator upload address, with no database |
| G11 Account deletion | `test/g11-account-deletion.test.mjs` | OP-12 through the Functions emulator: the confirmation, every own record and the sign-in account erased, a retry after a lost reply, an admin taken out of the count, the last admin refused, a deletion that stopped part-way finished by the cleanup task, and the known gap below |
| G12 WordPress posts | `test/g12-wordpress.test.mjs` | OP-24 through the Functions emulator against a stand-in WordPress site (`test/wp-standin.mjs`): a page of posts for an admin only, paging and the category filter, and every kind of bad site reply refused as `SITE_UNAVAILABLE` with nothing from the site in the log |
| U7 WordPress parts | `test/u7-wordpress-parts.test.mjs` | The site-address check, the plain-text title and the time and size limits, with no emulator |
| G13 First-admin step | `test/g13-bootstrap.test.mjs` | OP-42: the first admin from a verified reader with the guard at 1 and the change record; each refusal writes nothing; two steps at once make one admin; recovery; the verification; the command and its refusals |
| G14 Security events | `test/g14-security-events.test.mjs` | The real operations, run in the test's process, log a refused reader, a signed-out call, an unverified admin, a closed account, a link given out, an account deletion with an admin removal and a rejected upload, with no input, address or link in the log |
| U8 Security event list | `test/u8-security-events.test.mjs` | The closed event list, which outcome is which event, the warning level, and that a caller cannot set the event or log an email address |
| G15 Notification sends | `test/g15-notification-sends.test.mjs` | OP-25, OP-26 and OP-27 through the emulators with the stand-in push sender: a send to the category topic, written as pending first; a repeat sends nothing; the input, category and link checks write nothing; a push failure marks the record failed; a retry by an admin only, once per request, with a conflict while an attempt is pending; the log newest first, with a pending record past the window shown as unknown; the stale-send task |
| U9 Notification parts | `test/u9-notification-parts.test.mjs` | The OP-25 input check and the topic name, with no emulator |
| G16 Registered readers | `test/g16-registered-users.test.mjs` | OP-31 and OP-32 through the emulators: newest first with a cursor, the provider email and the profile fields only, accounts being deleted hidden, admin only, formula cells neutralised in the export, and nothing stored |
| U10 CSV | `test/u10-csv.test.mjs` | The export's cell escaping, quoting, columns and line ends, with no emulator |
| G17 Issue deletion | `test/g17-delete-issue.test.mjs` | OP-30 through the emulators: an unpublished issue whose title is typed is deleted with its file records, stored files, cover and upload jobs; the deleted-issue record holds the identifier and the time only and anyone reads it (OP-03); a repeat returns the first result and a new request is `GONE`; a published issue, a wrong title, bad input and a reader are refused with nothing changed |
| G5 Admin gate | `test/g5-admin-gate.test.mjs` | The gate reads the role record and the account on each call and trusts no claim; the last-admin guard refuses to remove the only active admin, also with removals at the same moment; the count repair finds and corrects a wrong count |

## The seed

`seed/notification-categories.json` holds the three fixed notification categories of the working position (GS-Q47, PROPOSED; OQ-18 and CFG-13 are OPEN), and `seed/seed.mjs` checks and loads them (MOD13-P1-T10). With the emulators running, `npm run seed` loads them into the local Firestore emulator; it refuses any other address. `npm run seed:check` checks the file with no emulator. The segment list waits for OQ-13 and is not seeded.

## The operations

| Operation | File | Task | Notes |
|---|---|---|---|
| OP-14 `getMyAdminRole` | `functions/src/getMyAdminRole.ts` | MOD13-P1-T08 | Shows or hides panel controls only; every privileged operation checks again. Returns `is_admin`, `is_active` and `email_verified`; the panel admits an account only when the last two are true |
| Admin gate, last-admin guard, count repair | `functions/src/admin.ts`, `adminCall.ts` | MOD13-P1-T08 | `adminCall` is the only way to declare a privileged operation. The gate also needs a verified email, read from the provider on the call (OQ-20's working position, `EMAIL_NOT_VERIFIED`). The guard record `admin_guard/current` keeps the active-admin count (INV-03). In-panel add and remove (OP-34 to OP-39) wait for OQ-58; the bootstrap step OP-42 is MOD12-P1-T02 |
| OP-15 `listIssuesForAdmin`, OP-16 `saveIssue`, OP-21 `publishIssue`, OP-22 `unpublishIssue` | `functions/src/issues.ts`, `issueChecks.ts` | MOD13-P1-T03 | Admin only, through `adminCall`. A save carries the version it was opened at and is refused as `STALE_RECORD` if the record changed. Publishing needs an accepted file (`NO_ACCEPTED_FILE`) |
| OP-17 `saveCategory`, OP-18 `deleteCategory` | `functions/src/categories.ts` | MOD13-P1-T03 | Issue categories only. A category in use is refused (`IN_USE`); names are unique (`NAME_TAKEN`) |
| OP-23 `setNewsControl` | `functions/src/newsControls.ts` | MOD13-P1-T03 | Hides or marks a news post. Marking a post as breaking sends nothing; a send is OP-25 |
| OP-11 `getIssueFile` | `functions/src/issueFile.ts`, `grantIssuer.ts`, `signedLinks.ts`, `safeLog.ts` | MOD13-P1-T04 | Check 0 (`GONE`) and six ordered checks, then a V4 signed read URL for the current revision (DEC-020, TD-09). The lifetime is `config/private.signed_url_lifetime` in seconds, refused over 3,600 (the AOQ-07 assumption) and with no default. The log keeps only the operation, the caller and the outcome |
| OP-19 `requestUpload`, OP-20 `listUploadJobs` | `functions/src/uploads.ts`, `uploadUrlIssuer.ts` | MOD13-P1-T09 | Admin only. A job and a V4 signed resumable-upload URL for `holding/{job_id}` (DEC-020), with the headers the client sends to open the session (`content-type: application/pdf`, `x-goog-resumable: start`). The store does not limit the size: OP-19 checks the declared size and OP-40 the real one. The limit is `config/private.max_upload_bytes`, with no default (CFG-05, OQ-30). The URL lifetime of 900 seconds is a PLACEHOLDER. PDFs only; a cover waits for OQ-22 |
| OP-40 `onUploadFinalized` | `functions/src/uploadFinalized.ts`, `pdfCheck.ts` | MOD13-P1-T09 | Runs when a file lands in the holding area: checks the job, the uploader's admin standing, the size and that the file is a genuine PDF (pdf.js, no scripts, no fonts), then copies it to `issues/{issue_id}/{revision}.pdf` as the next accepted revision. Anything else is deleted and the job records the reason |
| OP-12 `requestAccountDeletion` | `functions/src/accountDeletion.ts`, `deletionCleanup.ts` | MOD13-P1-T06 | PROVISIONAL (DEC-029, OQ-24): immediate deletion, nothing kept. Ends the sessions, removes the admin role through the guard, erases the reader's records and the sign-in account. `finishDeletions` is the OP-41 task that finishes a deletion that stopped part-way; its schedule is not built |
| OP-24 `listWordPressPosts` | `functions/src/wordpress.ts` | MOD12-P2-T04 | A page of MFW's WordPress posts for the news-controls screen, so the panel never calls the site itself (TD-12). The site address is `config/private.wordpress_base_url` (CFG-03, OQ-39), HTTPS only, with no default. The timeout, size and page limits are PLACEHOLDERS. No post is stored |
| OP-25 `sendNotification`, OP-26 `retryNotification`, OP-27 `listNotificationSends` | `functions/src/notifications.ts`, `pushSender.ts` | MOD11-P2-T03 | Admin only. One push topic per notification category, named by `category_id` (TD-13, PROPOSED), and no device token stored. The record is written as pending, then accepted or failed (GS-Q27); a failure is `UNAVAILABLE` with reason `PUSH_FAILED` and the `send_id`. An issue target must be published; a post must exist on the site and not be hidden. Only an admin retries (INV-17); a pending attempt older than the 10-minute PLACEHOLDER window counts as unknown, and `markStaleSends` is the OP-41 task that marks it. The record's fields are PROVISIONAL (OQ-19), and the title and body limits are PLACEHOLDERS. On the emulators a stand-in push sender takes the message; push is not set up in MFW's accounts (MOD11-P2-T01) |
| OP-31 `listRegisteredUsers`, OP-32 `exportRegisteredUsers` | `functions/src/registeredUsers.ts` | MOD12-P2-T06 | PROVISIONAL (OQ-29, OQ-31, OQ-51); any admin on the working position (GS-Q49). A reader is listed from the first profile save, which makes the user record; an account being deleted is hidden. The email comes from the sign-in provider on each call. The export is a CSV built in memory, not stored, with formula cells neutralised (SEC-CHK-12) and refused as `EXPORT_TOO_LARGE` over 10,000 rows (a PLACEHOLDER). No audit record (GS-Q44) |
| OP-30 `deleteIssue` | `functions/src/issueDeletion.ts` | MOD13-P1-T05 | PROVISIONAL (OQ-21, OQ-11), on the GS-Q45 working position; the panel has no delete control until OQ-21 is answered. The issue must be unpublished (INV-15) and the confirmation must be its title. One transaction deletes the issue and writes `deleted_issues/{issue_id}` with the identifier and the time only, which OP-03 lets anyone read; the identifier is never reused (INV-14). The file records, stored files, cover and upload jobs are removed afterwards (`removeIssueRemains`, safe to run again). A server-only `issue_deletion_requests` record makes a repeat return the first result. Readers' bookmarks and favourites wait for the orphan cleanup (DM section 10.3) |
| OP-42 `bootstrapAdmin` (developer-run, not deployed) | `functions/src/bootstrap.ts`, `scripts/bootstrap-admin.mjs` | MOD12-P1-T02 | Creates the first admin, or recovers from a lockout, from a verified reader account named in writing by MFW (SC-14). Refuses while an active admin exists unless `--recovery`. Writes the role, the guard and the change record `bootstrap_admin` in one transaction. Without `--project` it writes only to local emulators. The procedure is in `Documentation/DEPLOYMENT_PLAN.md` section 7.5 |
| OP-10 `saveProfile` | `functions/src/saveProfile.ts`, `profile.ts` | MOD13-P1-T01 | The required fields and policy versions come from `config/public`; a missing or malformed setting refuses the call. The mandatory profile is PROVISIONAL (BR-003, OQ-01) |

## What the rules do

- **Deny by default** (SC-05). A path that no rule lists is refused to every client.
- **No client writes to shared records.** Issues, categories, segments, news controls and notification categories are changed only by server functions that check the admin role (MOD13-P1-T03, NFR-SEC-007). Admins get no direct access in the rules (GS-Q20), and no rule trusts a role claim in the token (SC-04).
- **Owner only** for the account record, profile, consent records, bookmarks, favourites and notification preferences (NFR-SEC-005, NFR-SEC-006). Profile and consent writes go through a function (OP-10), so the rules allow the owner to read them only.
- **No rule reads another document** (`SECURITY_AND_ACCESS_CONTROL.md` section 13).

## The server log (MOD02-P2-T03)

`functions/src/safeLog.ts` writes one line per logged outcome with only the operation, the caller's identifier and the outcome (SC-16, SEC-CHK-10); a value that looks like a link, a token or an email address, or is too long, is dropped and only its field name is noted. A line that is a security event carries `event`, from a closed list: `access_refused` (signed out, not an admin, closed account, unverified email), `check_failed` (a check could not be made, SC-03), `grant_issued` (OP-11), `account_deleted` (OP-12), `admin_removed` and `upload_rejected` (OP-40). Refusals and failures are warnings. Every admin operation (through `adminCall`), OP-10 and OP-14 log their security refusals; a refusal of the input is not an event. The caller's identifier is pseudonymous; whether it may be logged at all is finding E-9.

## Known limits

- **A record for a missing issue or category is accepted** (finding A-10 of the spike): a rule cannot check that an issue or a category exists without reading another document. A bookmark for a deleted issue is cleaned up as INV-13 says. Whether a rule may read one document is for both developers to decide.
- **Bookmarks and favourites check the owner, not `fullAccess`.** The app's guard asks for `fullAccess` (`API_AND_MODULE_CONTRACTS.md` section 4.1), but a rule cannot check a complete profile without reading another document. Who may use favourites is OQ-12.
- **The bookmark key** is `<issue_id>_<page_number>`, PROPOSED, so a page is bookmarked once.
- **Signed upload links** to the holding area are checked by the file store, not by these rules, and the emulator was not tried with them.
- **Signed URLs are not tried on the emulators.** The emulators have no key to sign with, so they use an issuer whose links cannot resolve, and the real issuers are tested against a fake file (U6). Signing in ENV-TEST needs the Service Account Token Creator role (TD-09, VS-08). Another reader's link, an expired link, Range and resume on a 150 MB file, and a resumable upload through the signed URL are the TD-09 proof plan (AR-01, AOQ-07), run when ENV-TEST exists.
- **The bucket needs a CORS setting** for the admin panel's origin before a browser can upload to a signed URL, and it must expose the `Location` header of the resumable session. It is set with ENV-TEST (MOD14-P2-T03).
- **A deleted account's last token can still write** (finding A-10). The rules cannot see that the account is gone, so until the token expires (up to an hour) a direct write of a bookmark, favourite or preference is accepted and left as an orphan. G11 records the gap. The fix needs a rule that reads the user record, or a sweep in OP-41, for both developers to choose.
- **Not yet in CI.** QG-08 runs these tests in CI once it is added (MOD15-P2-T02).
