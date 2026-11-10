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

It builds `functions/`, starts the Auth, Functions, Firestore and Storage emulators for the project `demo-mfw`, which needs no login and no cloud project, runs every file in `test/`, and stops them. The emulator downloads are kept in the ignored `node_modules/.cache/`. On 10 November 2026: 428 tests, 428 passed (emulator only).

| Group | File | What it shows |
|---|---|---|
| G1 Deny by default | `test/g1-deny-by-default.test.mjs` | The records with no client access, and paths no rule lists, are refused to six actors, including an admin account and readers with forged admin claims. Listing and collection-group queries are refused |
| G2 Public reads | `test/g2-public-reads.test.mjs` | Segments, categories, notification categories, news controls, the deleted-issue list, the public configuration and published issues are readable by anyone and writable by no client. An unpublished issue is refused, and a query must filter on the published state |
| G3 Own records | `test/g3-own-records.test.mjs` | A reader reads their account, profile and consent records, and reads and writes their bookmarks, favourites and notification preferences, with the fields checked. Once written, none of the three can be changed, `created_at` included; a replayed write passes. Every other actor is refused |
| G4 File store | `test/g4-storage.test.mjs` | Issue files, the holding area and unlisted paths are refused to every client. Covers are readable by anyone and writable by no client |
| G0 Auth emulator | `test/g0-auth-emulator.test.mjs` | The Auth emulator creates and signs in a test account (UA-8) |
| G6 Save profile | `test/g6-save-profile.test.mjs` | OP-10 through the Functions emulator: the first save, later saves, consent records, the segment check, closed accounts and an unusable configuration |
| U1 Profile checks | `test/u1-profile-checks.test.mjs` | The profile and configuration checks of OP-10, with no database |
| G5 Admin gate | `test/g5-admin-gate.test.mjs` | The gate reads the role record and the account on each call and trusts no claim; the last-admin guard refuses to remove the only active admin, also with removals at the same moment; the count repair finds and corrects a wrong count |

## The operations

| Operation | File | Task | Notes |
|---|---|---|---|
| OP-14 `getMyAdminRole` | `functions/src/getMyAdminRole.ts` | MOD13-P1-T08 | Shows or hides panel controls only; every privileged operation checks again. The panel goes by `is_active` |
| Admin gate, last-admin guard, count repair | `functions/src/admin.ts`, `adminCall.ts` | MOD13-P1-T08 | `adminCall` is the only way to declare a privileged operation. The guard record `admin_guard/current` keeps the active-admin count (INV-03). In-panel add and remove (OP-34 to OP-39) wait for OQ-58; the bootstrap step OP-42 is MOD12-P1-T02 |
| OP-10 `saveProfile` | `functions/src/saveProfile.ts`, `profile.ts` | MOD13-P1-T01 | The required fields and policy versions come from `config/public`; a missing or malformed setting refuses the call. The mandatory profile is PROVISIONAL (BR-003, OQ-01) |

## What the rules do

- **Deny by default** (SC-05). A path that no rule lists is refused to every client.
- **No client writes to shared records.** Issues, categories, segments, news controls and notification categories are changed only by server functions that check the admin role (MOD13-P1-T03, NFR-SEC-007). Admins get no direct access in the rules (GS-Q20), and no rule trusts a role claim in the token (SC-04).
- **Owner only** for the account record, profile, consent records, bookmarks, favourites and notification preferences (NFR-SEC-005, NFR-SEC-006). Profile and consent writes go through a function (OP-10), so the rules allow the owner to read them only.
- **No rule reads another document** (`SECURITY_AND_ACCESS_CONTROL.md` section 13).

## Known limits

- **A record for a missing issue or category is accepted** (finding A-10 of the spike): a rule cannot check that an issue or a category exists without reading another document. A bookmark for a deleted issue is cleaned up as INV-13 says. Whether a rule may read one document is for both developers to decide.
- **Bookmarks and favourites check the owner, not `fullAccess`.** The app's guard asks for `fullAccess` (`API_AND_MODULE_CONTRACTS.md` section 4.1), but a rule cannot check a complete profile without reading another document. Who may use favourites is OQ-12.
- **The bookmark key** is `<issue_id>_<page_number>`, PROPOSED, so a page is bookmarked once.
- **Signed upload links** to the holding area are checked by the file store, not by these rules, and the emulator was not tried with them.
- **Not yet in CI.** QG-08 runs these tests in CI once it is added (MOD15-P2-T02).
