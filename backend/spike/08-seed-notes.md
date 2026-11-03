# Backend spike notes 08: the seed definitions

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`) |
| Date | 3 November 2026 |
| Task | Backend spike for `MOD13-P1-T10` (GAP-03): the three fixed notification categories, their loader, and OP-05 `listNotificationCategories` from `API_AND_BACKEND_CONTRACT.md` |
| Status | Working notes. PROPOSED. Not reviewed. Every result is "emulator only" |
| Rests on | GS-Q47 (working position, PROPOSED); OQ-18 and CFG-13 (OPEN); DEC-003 (OPEN). The segment list waits for OQ-13 |

## 1. What was built

| Part | What it does |
|---|---|
| `seed/notification-categories.json` | The three categories: new issues, expo specials and major news (GS-Q47). The fields are exactly those of `DATABASE_AND_DATA_MODEL.md` section 4.12. Public data only |
| `seed/seed.mjs` | `seedProblems` names everything wrong with a seed in one pass. `seedDocuments` turns a usable seed into records keyed by the identifier (section 12) and refuses a bad one. `loadSeed` writes them in one batch |
| `seed/load.mjs` | The command. `npm --prefix backend/spike run seed` loads a running emulator, for the app in B6. `run seed:check` checks the file with no emulator. It refuses any address that is not a local one, before it connects |
| `test/helpers.mjs` | The shared test data now uses the real seed, not a test category called `n1`, so G2 and G3 run against the real identifiers |

| Seed entry | `category_id` | `name` | `display_order` | `is_active` |
|---|---|---|---|---|
| New issues | `notif-new-issues` | New issues | 1 | true |
| Expo specials | `notif-expo-specials` | Expo specials | 2 | true |
| Major news | `notif-major-news` | Major news | 3 | true |

The identifiers, the wording and the order are spike choices (F-1 to F-3).

**The checks.** A seed is refused for: an unknown top-level key (so a segment list cannot slip in before OQ-13); an empty list; an entry without exactly the four fields; an identifier that is not lower-case words joined by hyphens, or that repeats; a name that is empty, has spaces at an end, or repeats ignoring case (section 4.12); an order that is not a whole number from 1, or that repeats; `is_active` that is not true or false.

**Loading.** A seed record replaces what is stored under its key, so loading twice changes nothing and a changed record is put back. A record that is not in the seed is left alone and named, because a category in use cannot be deleted (section 10.2). A bad seed writes nothing.

**Rules.** No change. `notification_categories` was already readable by anyone with no client write (`03-rules-notes.md`).

**Not built.** The segment list (OQ-13). Admin changes to categories (OP-29), which the working position rules out (GS-Q47). Any loader for a real project (F-5). Topic subscription, which is app side (MOD-11).

## 2. Results

`npm --prefix backend/spike test` on 3 November 2026: **776 tests, 776 passed, 0 failed.** Emulator only.

| Group | Tests | What it shows |
|---|---|---|
| G9 Seed | 18 | OP-05 for each of the six kinds of caller: exactly the three categories, in display order, and one read by key. Each caller, an admin included, is refused when adding, renaming, switching off, replacing or removing a category, and nothing changes. The loader: a repeat, a changed record put back, another record left alone and named, a bad seed writing nothing. The command against the emulator, and its refusal of another address |
| U4 Seed | 35 | The seed passes its checks. The identifiers, wording, order and active flags are pinned. No segment list. 24 bad seeds are refused, each naming its problem, and every problem is named in one run. The command's check, and its refusal of an unknown option |
| G2, G3 | 112 | Unchanged in number. They now use the real identifiers |
| The rest | 611 | Unchanged |

**Acceptance** (plan B2.7): OP-05 returns exactly the three categories, and a client cannot change them. Met, emulator only.

**Do the tests catch broken code?** 37 deliberate breaks were tried one at a time on clean baselines: the seed checks (15), the refusal of a bad seed (1), the loader (5), the command (5), the seed file (5) and the rules (6). All 37 were caught. With the address check removed, the command tried to reach 192.0.2.1 until the test's 20-second limit stopped it.

## 3. Findings

| ID | Finding | What it means |
|---|---|---|
| F-1 | No document gives the identifiers. The fictional sample data in `DATABASE_AND_DATA_MODEL.md` uses `notif-new-issues` and `notif-expo`. The seed follows the first and spells the others out. A preference is keyed by the identifier and the push topic name is derived from it (section 4.12, TD-13), so changing one after release would orphan stored preferences and subscribed devices | Both developers to agree the identifiers before release. A test pins them, so a change is deliberate. The sample data would then be aligned |
| F-2 | The wording "New issues", "Expo specials" and "Major news" is the documents' words with a capital letter. Readers see it in the app | MFW's wording is OQ-18 and CFG-13 |
| F-3 | The order follows the order the documents list them in. A unique order is a spike choice, so that the list has one order | To confirm with the B6 screen |
| F-4 | How the topic name is "derived" from the identifier is not stated. The identifier pattern is narrower than Firestore keys need, and is meant to fit Firebase Cloud Messaging topic names. That fit is NOT VERIFIED | To settle with Yuvraj's push work (MOD-11) |
| F-5 | The loader writes only to a local emulator. How the seed reaches ENV-TEST or production is not designed, and no document says who runs it. With admins unable to change the list, changing a category is a developer deployment step | Needs DEC-003. To plan with the deployment work |
| F-6 | Every record has `is_active`, but no document says whether OP-05 returns inactive categories or the app hides them. All three are active, so it does not show yet | To settle in B6 |
| F-7 | A-10 in `03-rules-notes.md` still applies: the rules accept a preference for a category that is not in the seed (a G3 test shows it). The seed now exists, so the option of a rule reading one document could be tried | Still needs both developers |
| F-8 | The command's refusal is tested with 192.0.2.1, a documentation address nothing answers on. That a `demo-` project name keeps the emulators offline is NOT VERIFIED, as before | None |

## 4. Not tested

| Case | Why |
|---|---|
| A real project | The loader refuses anything but a local emulator (F-5) |
| Whether the push service accepts the topic names | TD-13 work is not built (F-4) |
| OP-05 from the app | B6 needs Yuvraj's scaffold |
