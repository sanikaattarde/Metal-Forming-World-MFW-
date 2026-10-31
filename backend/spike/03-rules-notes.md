# Backend spike notes 03: deny-by-default and owner-only rules

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`) |
| Date | 30 October 2026 |
| Task | Backend spike for T-03.6 and T-07.1 in `DEVELOPMENT_ROADMAP.md`: the database and file-store rules, with allowed and refused tests |
| Status | Working notes. PROPOSED. Not reviewed. Every result is "emulator only" |
| Rests on | DEC-003 and DEC-020 (OPEN); TD-07 and TD-08 (PROPOSED); the provisional Firestore mapping in `DATABASE_AND_DATA_MODEL.md` section 12 |

## 1. What the rules do

Written from `SECURITY_AND_ACCESS_CONTROL.md` section 12 and the entity sections of `DATABASE_AND_DATA_MODEL.md`. The paths are the data model's provisional mapping (section 12), not a choice made here.

| Path | Client access | Rule |
|---|---|---|
| `segments`, `categories`, `notification_categories`, `news_controls`, `deleted_issues`, `config/public` | Read by anyone. No write | Reads allowed. Nothing else is listed |
| `issues/{id}` | Read by anyone if published. No write | `publication_state == 'published'`. A query must carry the same filter. The segment links are the `segment_ids` array on the issue, so they follow the same rule |
| `issues/{id}/files/{revision}` | None | Not listed |
| `users/{uid}`, `users/{uid}/profile/*`, `users/{uid}/consents/*` | Read by the owner. No client write | `request.auth.uid == uid` for read only |
| `users/{uid}/bookmarks/{id}` | The owner reads, creates, updates and deletes | Owner, plus a field check: exactly the six fields of the entity, `bookmark_id` equal to the key, `user_id` equal to the path, `page_number` and `file_revision` whole numbers from 1, `issue_id` a non-empty string, `created_at` a timestamp. Corrected in `06-admin-operations-notes.md` section 3: the key must come from the issue and the page, and an update must change nothing |
| `users/{uid}/favourites/{issue_id}` | The owner | Owner, plus exactly `user_id`, `issue_id` (equal to the key), `created_at` |
| `users/{uid}/notification_preferences/{category_id}` | The owner | Owner, plus exactly `user_id`, `category_id` (equal to the key), `created_at` |
| `admin_roles`, `admin_audit`, `admin_guard`, `upload_jobs`, `notification_sends`, `edition_updates`, `config/private` | None | Not listed |
| Any other path, and any collection-group query | None | Not listed |
| File store `issues/...` (private), `holding/...` | None | Denied. The backend's signed upload URL is checked by the store, not by the rules |
| File store `covers/{issue}/{version}` | Read by anyone. No write | `allow read: if true` |

No rule reads a token claim other than the user identifier (SC-04). No rule reads another document (`SECURITY_AND_ACCESS_CONTROL.md` section 13).

## 2. Results

`npm --prefix backend/spike test` on 30 October 2026: **290 tests, 290 passed, 0 failed.** Emulator only.

| Group | Tests | What it shows |
|---|---|---|
| G0 Auth emulator | 1 | Sign-up works and the verification code can be read back |
| G1 Deny by default | 150 | Nine no-access entities and four unlisted paths are refused for six actors (visitor, reader A, reader B, an admin account with a role record, reader A with forged admin claims, another reader with forged admin claims). Listing six collections and six collection-group queries is refused for each actor |
| G2 Public reads | 54 | The seven public paths are readable by every actor and writable by none. The unpublished issue is refused. A query with the published filter returns only the published issue, and a query without it, or for unpublished, is refused |
| G3 Own records | 54 | Reader A reads and writes their bookmarks, favourites and preferences. Reader B, a visitor, an admin account and forged claims are refused on every operation. Field checks (extra field, missing field, wrong user, wrong key, bad page number and revision) are refused. The account record, profile and consent records are read-only for the owner |
| G4 File store | 31 | The private file, a guessed private path, the holding area and an unlisted path are refused for read, write and delete for six actors. A cover is readable by all and writable by none. A control shows the seeded files exist with the rules switched off |

## 3. Do the tests catch a broken rule?

23 deliberate breaks of the rules were tried one at a time, each on the final test suite, and the rules were restored afterwards. Each break made at least one test fail.

| Break | Tests that failed |
|---|---|
| Unpublished issues readable | 12 |
| Any signed-in user reads bookmarks | 3 |
| An admin claim in the token is trusted | 6 |
| Page number minimum removed | 2 |
| Private files readable by any signed-in user | 20 |
| A catch-all read rule added | 180 |
| Profile writable by its owner | 2 |
| Extra fields allowed in a bookmark | 1 |
| Favourite's user identifier unchecked | 2 |
| Revision minimum removed | 1 |
| Empty issue identifier allowed | 1 |
| Bookmark's issue and page changeable on update | 1 |
| Favourite's key unchecked | 1 |
| Preference's key unchecked | 1 |
| Consent records readable by any signed-in user | 3 |
| Account record writable by its owner | 2 |
| Collection-group query on bookmarks opened | 8 |
| Covers writable by anyone | 6 |
| Everything readable in the file store | 24 |
| Private configuration readable | 12 |
| Published test inverted | 24 |
| Segments writable | 6 |
| Deleted-issue list writable by any signed-in user | 5 |

The first round of this check showed that removing the page-number minimum was **not** caught. The bad-value cases ran as updates of an existing bookmark, so the "issue and page do not change" rule refused them for another reason. The tests now try each bad value as a fresh create, and the break is caught.

## 4. Findings

| ID | Finding | What it means |
|---|---|---|
| A-3 (resolved) | The data model keeps the segment links as the `segment_ids` array on the issue (section 12). A rule on the issue therefore covers them, and no rule needs to read the parent | Tested under G2. The first version of the inventory expected a join table |
| A-10 | Rules cannot check that an issue or a category exists, because no rule reads another document. `DATABASE_AND_DATA_MODEL.md` says a favourite needs a published issue and a preference needs an active category | The tests show a favourite, preference or bookmark for a missing record is accepted by the rules, and name it a known gap. Options: tolerate and clean up, as INV-13 does for bookmarks, or allow a rule to read one document. Needs both developers. How many reads a rule may make is NOT VERIFIED |
| A-11 | A query on `issues` is allowed only if it filters on `publication_state == 'published'`. The unfiltered list is refused, even for a visitor | The app's catalogue query must always carry the filter. A note for Yuvraj (MOD-05) |
| A-12 | `users/{uid}` and its subcollections are not recursive. A path under the user that no rule lists is refused even for the owner | Tested under G1. Any new subcollection needs a rule |
| A-5 (confirmed) | A reader whose account is marked deleting can still write their own bookmarks, because rules do not look up the status | Tested under G3, as documented in `SECURITY_AND_ACCESS_CONTROL.md` T25 |

Findings A-1, A-2, A-4, A-6, A-7, A-8 and A-9 of the inventory stand. For A-7, the rules now grant no client write in the holding area, and the signed upload URL is outside them.

## 5. Not done and not tested

1. **Server operations.** Functions use the Admin SDK, which ignores these rules. `saveProfile`, `getIssueFile`, the admin operations, upload and account deletion are the next steps (B2.3 onwards).
2. **Writes by functions.** The rules only deny clients. Nothing here proves a function writes the right fields.
3. **Signed links.** Another reader's grant, an expired grant and a signed upload URL need a real signed link. Whether the emulator honours them was not researched.
4. **Claims from real tokens.** The forged claims are set by the test library. They show the rules ignore claims, which is the property needed.
5. **Concurrency, rate limits and App Check.** Not covered by rules.
6. **Offline behaviour** of the mobile SDK (queued writes, cached reads) is not tested.
7. **Final paths.** The mapping is PROVISIONAL (TD-07). If another database is chosen, the rules and tests are rewritten, and the access table in `01-access-inventory.md` stands.
