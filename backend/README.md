# MFW backend

The backend on Firebase (DEC-003, AGREED). This folder holds the Cloud Firestore and Cloud Storage access rules of MOD13-P1-T01 to T03, with their tests on the local emulators. Nothing here is deployed: no cloud project exists yet (`Documentation/CLOUD_ACCESS_SETUP_CHECKLIST.md`), and ENV-TEST waits for MFW's answer to OQ-40. Cloud Functions (OP-11, OP-12 and the admin operations) come in later tasks.

## Set-up

1. Install Node.js 22 or later (DEP-79). The tests were run with Node.js 26.0.0.
2. Install Java 21 or later (DEP-83), which the emulators need. With Homebrew's `openjdk@21`, `scripts/run-with-env.sh` puts it on `PATH` for the one command, so nothing global changes.
3. From this folder, install the pinned tools from the lockfile:

   ```bash
   npm ci
   ```

## Tests

```bash
npm test
```

It starts the Firestore and Storage emulators for the project `demo-mfw`, which needs no login and no cloud project, runs every file in `test/`, and stops them. The emulator downloads are kept in the ignored `node_modules/.cache/`. On 9 November 2026: 318 tests, 318 passed (emulator only).

| Group | File | What it shows |
|---|---|---|
| G1 Deny by default | `test/g1-deny-by-default.test.mjs` | The records with no client access, and paths no rule lists, are refused to six actors, including an admin account and readers with forged admin claims. Listing and collection-group queries are refused |
| G2 Public reads | `test/g2-public-reads.test.mjs` | Segments, categories, notification categories, news controls, the deleted-issue list, the public configuration and published issues are readable by anyone and writable by no client. An unpublished issue is refused, and a query must filter on the published state |
| G3 Own records | `test/g3-own-records.test.mjs` | A reader reads their account, profile and consent records, and reads and writes their bookmarks, favourites and notification preferences, with the fields checked. Every other actor is refused |
| G4 File store | `test/g4-storage.test.mjs` | Issue files, the holding area and unlisted paths are refused to every client. Covers are readable by anyone and writable by no client |

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
