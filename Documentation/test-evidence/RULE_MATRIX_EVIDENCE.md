# Rule Matrix Evidence: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/test-evidence/RULE_MATRIX_EVIDENCE.md` |
| Task | MOD13-P2-T01, an input to MOD17-P3-T03 (the security checklist) |
| Status | Draft. Emulator only (ENV-LOCAL): ENV-TEST does not exist yet (MOD14-P2-T03), so the run is repeated there once it does |
| Date | 12 November 2026 |
| Run by | Sanika Attarde |
| Build | `main` after the merge of MOD08-P2-T03, with `backend/test/g20-rule-matrix.test.mjs` |

## 1. What Was Run

`backend/test/g20-rule-matrix.test.mjs` (G20) checks every client operation on every kind of record and file against the expected result of `SECURITY_AND_ACCESS_CONTROL.md` section 12, for ten actors: the visitor FX-USR-09, the five reader states FX-USR-01 to FX-USR-05, another reader, an admin, a removed admin, and a reader carrying admin-looking claims. Each actor is checked on the public records, the issues, its own records, reader A's records, the server-only records and the files.

Result: **58 tests, 676 checks, every one as expected.** Run with `npm test` in `backend/`, or alone:

```bash
sh scripts/run-with-env.sh npx firebase emulators:exec --only auth,functions,firestore,storage --project demo-mfw "node --test test/g20-rule-matrix.test.mjs"
```

## 2. The Matrix

"Allowed" lists the operations that pass; everything else in the area is refused. "Create valid" means a record with exactly the allowed fields; an extra field (such as `role`) and a change to a stored record are refused. "n/a" means the area does not apply (a visitor owns no records, and reader A's own records are the "Own records" column).

| Actor | Public records | Issues | Reader A's records | Server-only records | Files | Own records |
|---|---|---|---|---|---|---|
| FX-USR-09 visitor | allowed: read | allowed: read published, list published | all refused | all refused | allowed: read cover | n/a |
| FX-USR-01 full access | allowed: read | allowed: read published, list published | n/a | all refused | allowed: read cover | allowed: read account, profile, read bookmarks, favourites, preferences, create valid, delete |
| FX-USR-02 not verified | allowed: read | allowed: read published, list published | all refused | all refused | allowed: read cover | allowed: read account, profile, read bookmarks, favourites, preferences, create valid, delete |
| FX-USR-03 profile incomplete | allowed: read | allowed: read published, list published | all refused | all refused | allowed: read cover | allowed: read account, profile, read bookmarks, favourites, preferences, create valid, delete |
| FX-USR-04 Google | allowed: read | allowed: read published, list published | all refused | all refused | allowed: read cover | allowed: read account, profile, read bookmarks, favourites, preferences, create valid, delete |
| FX-USR-05 Google, incomplete | allowed: read | allowed: read published, list published | all refused | all refused | allowed: read cover | allowed: read account, profile, read bookmarks, favourites, preferences, create valid, delete |
| another reader | allowed: read | allowed: read published, list published | all refused | all refused | allowed: read cover | allowed: read account, profile, read bookmarks, favourites, preferences, create valid, delete |
| admin | allowed: read | allowed: read published, list published | all refused | all refused | allowed: read cover | allowed: read account, profile, read bookmarks, favourites, preferences, create valid, delete |
| removed admin | allowed: read | allowed: read published, list published | all refused | all refused | allowed: read cover | allowed: read account, profile, read bookmarks, favourites, preferences, create valid, delete |
| admin-looking claims | allowed: read | allowed: read published, list published | all refused | all refused | allowed: read cover | allowed: read account, profile, read bookmarks, favourites, preferences, create valid, delete |

## 3. What the Matrix Shows

1. **The access state does not change the rules.** FX-USR-01 to FX-USR-05 get the same answers: the rules know only the signed-in identity. An unverified address, an incomplete profile or a Google sign-in is stopped by the app's guard and by the functions, not by the rules (`SECURITY_AND_ACCESS_CONTROL.md` section 13; threat T25). This is by design and is recorded here so the security checklist does not read it as a gap.
2. **Admins have no direct access.** An admin, a removed admin and a reader with admin-looking claims get exactly what a reader gets: no claim and no role record opens anything (GS-Q20, SC-04). Admin data is reached only through the operations, which check the role record on each call.
3. **Server-only records are closed to every client,** including the admin: role records, the change record, the guard, upload jobs, the send log, deletion requests, rate-limit counters, the private configuration and file revisions.
4. **Files:** covers are public to read; issue PDFs, the holding area and every other path are closed to every client.

## 4. Against the Security Checklist

| Item | What it asks | Evidence | Result |
|---|---|---|---|
| SEC-CHK-02 | An issue file is refused when signed out, unverified, profile incomplete, with another reader's grant, an expired grant or a guessed path | G7 (OP-11 refusals), G4 and G20 (no direct file access) | Passed on the emulators |
| SEC-CHK-03 | Issue PDFs are not publicly readable or listable, and no long-lived link is issued | G4, G20 (files), G7 and U6 (short-lived, one-object signed links) | Passed on the emulators |
| SEC-CHK-04 | Downloaded issues only in app-private storage, excluded from backups | `IPHONE_DEVICE_TEST_EVIDENCE.md`: the files are in the app's own container. The backup exclusion is set in `AppDelegate.swift` and was not inspected on the device | Partly: the backup flag is not yet inspected |
| SEC-CHK-05 | A reader reads and changes only their own records | G3, G1, G20 (own and reader A's records), G19 (two devices) | Passed on the emulators |
| SEC-CHK-06 | Every admin operation is refused for non-admins | G5, G8, G12 | Passed on the emulators |
| SEC-CHK-11 | Account deletion removes the reader's data on the server | G11, G19 | Passed on the emulators |
| SEC-CHK-18 | A removed admin is refused on the next privileged call, including from an older session | G5 (FX-ADM-08), G8; G20 shows the removed admin has no direct access | Passed on the emulators. The time until a removal is seen in a cloud project is measured only once ENV-TEST exists |

No defect was found. The open points are the SEC-CHK-04 backup flag on a device, and repeating the whole run on ENV-TEST.
