# Admin spike notes, B5: the admin's content operations

| Field | Detail |
|---|---|
| Branch | `spike/sa-admin-content`, cut from `spike/sa-admin-skeleton` at `d8d10f7`. A spike: not merged to `main` |
| Date | 5 November 2026 |
| Task | `T-09.1` (admin sign-in and role check), `T-09.3` (publish and unpublish), `T-09.4` (news controls) in `DEVELOPMENT_ROADMAP.md` |
| Status | Working notes. PROPOSED. Not reviewed. Every result is "emulator only" or "local only". Built in three steps, each committed on its own: B5.1, B5.2 and B5.3 |
| Rests on | DEC-004 (OPEN); DEC-003 (OPEN); DEC-027 (PROPOSED, one admin role); OQ-20 (working position: password, verified email, recent sign-in, no second factor; PROPOSED); OQ-56 and OQ-58 (OPEN) |

## 1. Choices made for this block

Sanika Attarde chose these on 5 November 2026, before any code was written:

| Question | Choice | Why it was a question |
|---|---|---|
| Where the verified email is enforced | In the server's admin gate and in the panel | The gate from B2.4 did not check it, and OQ-20's working position asks for it |
| The recent-sign-in check | Left out | OQ-56 is about adding or removing an admin (OP-35, OP-37), which waits for OQ-58. No document names another action that needs it |
| Moving between screens | `react-router`, with a register row (B5.2) | No navigation existed. The alternative was no package |
| The news flags on the news screen | Read `news_controls` as OP-04 does, through the Firestore client in `firebase` (B5.3) | OP-24's contract returns posts without the flags |

## 2. B5.1: the role check, the verified email and the end of a session

### 2.1 What was built

**On the server** (`backend/spike/functions`):

| Part | What it does |
|---|---|
| `requireAdmin` | Refuses an admin whose email the provider does not report as verified, with `FAILED_PRECONDITION` and the reason `EMAIL_NOT_VERIFIED`. The check comes after the role check, so a caller who is not an admin still gets `FORBIDDEN` and learns nothing about the email. A closed account is still refused as closed first. Every admin operation goes through this gate (`adminCall`) |
| `readStanding` | Also reports the provider's email flag, read on the same call |
| OP-14 `getMyAdminRole` | Also returns `email_verified` |
| OP-40 `onUploadFinalized` | Rejects a file whose uploader's email is no longer verified, as `UPLOADER_NOT_AUTHORISED` |

**In the panel** (`admin/src`):

| Part | What it does |
|---|---|
| `roleCheckThrough` | The role check calls OP-14. An account is an admin to the panel only if the role exists, is active and the email is verified. Anything else, including OP-14 failing, is the one refusal message, and the account is signed out |
| `adminApi` | The one way a screen calls a server operation. If a call is refused as `FORBIDDEN`, `UNAUTHENTICATED`, `ACCOUNT_CLOSED` or `EMAIL_NOT_VERIFIED`, the panel signs out at once and shows "Your admin access has ended" (PLACEHOLDER wording). Any other refusal reaches the screen |
| `App` | When the panel comes back into focus, OP-14 is asked again, and a "no" signs the admin out with the same notice. Signing out by hand shows no notice |
| `services.ts` | The panel now also reaches the Functions emulator. `roleCheck.ts`, the stub that refused everyone, is gone |

**The tests** now start the Auth, Functions and Firestore emulators from the backend spike's configuration, after building its functions. `admin/firebase.json` is removed. Test data goes in through the emulators' own REST interfaces (`test/emulator.ts`).

## 2a. B5.2: the issue and category screens (T-09.3)

### 2a.1 What was built

| Part | What it does |
|---|---|
| Navigation | `react-router` 8.5.0 (DEP-73). Each screen has its own address: `/issues`, `/issues/new`, `/issues/:issueId` and `/categories`. Any other address goes to the issues list. A menu links the screens, beside sign-out |
| SCR-W-02 Issues list | Published and unpublished issues through OP-15, newest publication date first, 20 at a time with "Show more" (PLACEHOLDER page size). A filter for all, published or unpublished |
| SCR-W-03 Issue editor | The details through OP-16: title, description, category, segments when any exist, publication date, and optionally year and edition. A new issue keeps one request identifier while its form is open, so a retry after a lost reply makes no second issue. An edit sends the record version the screen showed, so a stale screen is refused and told to reload. Publish and unpublish (OP-21, OP-22) each ask for confirmation first (`CODING_STANDARDS.md` §15 item 7). The state and the current file revision are shown. **No upload control** (W3), so publishing needs a file accepted some other way |
| SCR-W-05 Categories | Issue categories only, in display order, through OP-17 and OP-18. Add (after the last one unless an order is typed), rename or reorder, and delete with a confirmation. A category in use is refused, and the screen says why. Segments and notification categories are seeded by the developers (GS-Q47, GS-Q56) |
| `data.ts` | The screens' calls in one place. The emulator tests run these same calls against the real operations |
| `describeError.ts` | Turns each refusal into a PLACEHOLDER message. Missing fields are named by their labels. The server's own message, and any value the admin typed, are never shown |
| Public reads | Categories and segments are read the way the app reads them, through the lite Firestore client in `firebase` (`firebase/firestore/lite`). It has no live updates or offline cache, which the panel does not need. The full client made the bundle 820 kB; the lite one makes it 465 kB |

### 2a.2 The browser check

Done by hand on 5 November 2026 in an embedded Chromium 152 browser on macOS, against `vite preview` and the Auth, Functions and Firestore emulators. The emulators held a generated admin, two categories and one issue with an accepted file.

1. Sign-in went through the real OP-14 to the issues list, which showed the issue after one OP-15 call.
2. Opening the issue and confirming "Publish" made it published. A visitor's read of it through the rules then returned 200.
3. On the categories screen, deleting the category the issue uses was refused with the "in use" message.
4. The page contacted only 127.0.0.1 on ports 4173, 9099, 5001 and 8080. Local and session storage stayed empty, and IndexedDB held only `firebase-heartbeat-database`.
5. The Functions emulator logged `"app": "MISSING"` beside `"auth": "VALID"` for each call: App Check is not used (OQ-52).

## 2b. B5.3: the news controls (T-09.4)

### 2b.1 What was built

**On the server** (`backend/spike/functions/src/wordpress.ts`), OP-24 `listWordPressPosts`:

| Part | What it does |
|---|---|
| The gate | Admin only, through `adminCall`, like every admin operation |
| Input | `page` (1 by default, up to a PLACEHOLDER 1,000), `per_page` (a PLACEHOLDER 20 by default, up to the API's own 100) and an optional `category`. Anything else is refused, and the site is not asked |
| The address | `wordpress_base_url` in the private configuration. CFG-03 is OPEN (OQ-39), and the data model's APP_CONFIG has no setting for it, so the name is a spike addition. It must be HTTPS, with no user name, password, query or fragment. Plain HTTP is allowed only to this machine, and only on the emulators, for the stand-in site. A missing or unusable address refuses the call with `INTERNAL`, and no site is asked |
| The request | It asks for `/wp-json/wp/v2/posts` with only the contract's fields (`_fields=id,title,date,link,categories`). It sends no credentials, refuses a redirect, stops after a PLACEHOLDER 10 seconds, and reads at most a PLACEHOLDER 1 MB |
| The reply | `posts` (`id`, `title`, `date`, `link`, `categories`), `total_pages` from the site's header (or null without one), and `page` and `per_page`. Titles become plain text. A link must be an `http` or `https` address, so a `javascript:` link from the site never reaches the panel. A page past the last one is an empty page |
| Failure | Anything the site does wrong becomes `UNAVAILABLE` with the reason `SITE_UNAVAILABLE`, as the contract says, and nothing from the reply is passed on: a server error, a reply that is not JSON or not a list, one bad post, a redirect, a reply too large or too slow, or no answer. The log line holds the operation, the caller and `OK` or `SITE_UNAVAILABLE`, never an address |
| Stand-in site | `backend/spike/test/wp-standin.mjs` serves generated posts on 127.0.0.1, pages them as the API does, records each request, and can be told to fail in each way above. No test reads MFW's live site |

**In the panel**, SCR-W-06 at `/news`, with a "News" menu link:

| Part | What it does |
|---|---|
| The list | Posts through OP-24, 20 at a time (PLACEHOLDER), with Previous and Next and "Page 1 of N". Each row has the title as text, the date, an "Open post" link that opens a new tab with no opener, and Hidden and Breaking checkboxes showing the current flags |
| The flags | Read from `news_controls`, as the app reads them (OP-04, section 1). A row's Save button is offered only when its flags changed, and saves through OP-23. Clearing both flags removes the record |
| Breaking | The screen says that marking a post as breaking sends no notification. OP-25 is not built, so AC-9.7 is not claimed |

### 2b.2 The browser check

Done by hand on 5 November 2026 in the same embedded Chromium 152 browser. It ran against `vite preview`, the emulators and the stand-in site on 127.0.0.1. One post was seeded as hidden, and one post's title held encoded characters and an `<em>` tag.

1. Opening `/news` and signing in kept the address and listed the three posts through OP-24, with "Page 1 of 1".
2. The encoded title showed as "Presses & dies: MFW’s expo preview", with no `<em>` element in the page.
3. The seeded post showed as hidden.
4. Each link opened in a new tab with `rel="noopener noreferrer"`.
5. Marking Post 1 as breaking and saving showed "Saved.". A visitor's read of `news_controls/100` then showed `is_breaking` true.
6. The browser contacted only 127.0.0.1 on ports 4173, 9099, 5001 and 8080, **never the site**: the posts came through the server, as TD-12 requires. Storage held only `firebase-heartbeat-database`.

## 3. Results

### 3.1 B5.1, on 5 November 2026

- `npm --prefix backend/spike test`: **921 tests, 921 passed, 0 failed.** Emulator only. That is 14 more than the 907 in `Documentation/test-evidence/BACKEND_RULES_EMULATOR_EVIDENCE.md`:
  - G5: 4 tests. An unverified admin is refused with `EMAIL_NOT_VERIFIED`, and passes once verified. A reader still gets `FORBIDDEN`. A closed account is refused as closed first. OP-14 reports the flag.
  - G8: 7 tests, one for each admin operation, refusing an admin whose email is not verified, with nothing written.
  - G10: 3 tests. The same caller is refused on OP-19 and OP-20, and the trigger rejects a file whose uploader's email stopped being verified.
  - The admin set-ups in four existing test groups now verify their admins' emails, because the gate requires it: G5, G7 (one test), G8 and G10.
- `npm --prefix admin test`: **38 tests, 38 passed, 0 failed.** Emulator only.
  - Against the emulators: a verified admin signs in through OP-14. Refused, and left signed out: a wrong password, an unknown address, a reader, an unverified admin, a removed admin, an account marked deleting, and a disabled account. An unreachable provider is "unavailable". An unreachable OP-14 is a refusal. Removing the role, or un-verifying the email, ends the session on the next call. A refusal about the input does not.
  - With stand-ins: which refusals end a session, the wrapper, the role check's three conditions, and the focus check.
- `npm --prefix admin run build`: passes. 319 kB (98 kB compressed), with the Functions client added. No gRPC code.

**Do the tests catch broken code?** 18 deliberate breaks were tried one at a time.

| Where | How each break was run | Breaks |
|---|---|---|
| Server | Rebuilt, then run against G5, G8 and G10, and the admin suite | 6 |
| Panel | Type-checked, then run against the admin suite | 12 |

All 18 were caught, and none failed to compile. They include:

- the gate ignoring the email, or checking it before the role;
- OP-14 dropping or faking the flag;
- the upload trigger ignoring it;
- the panel ignoring `is_active` or the email;
- a `FORBIDDEN` refusal keeping the session, or every failed precondition ending it;
- the wrapper not ending the session or throwing the server's error;
- the focus check missing or ignored;
- a session ending without signing out, or without the notice;
- a manual sign-out showing the notice.

### 3.2 B5.2, on 5 November 2026

- `npm --prefix admin test`: **67 tests, 67 passed, 0 failed.** Emulator only: 19 screen tests with the stand-in server and 10 against the real operations.
- `npm --prefix admin run build`: passes. 465 kB (146 kB compressed).
- The backend was not changed in B5.2, and its suite was not run again.

**Do the tests catch broken code?** 21 deliberate breaks of the panel were tried one at a time, each type-checked and run against the whole admin suite with the emulators.

**First round:**

- 16 were caught.
- 4 did not compile (Q06, Q15, Q19, Q20), because each left an import or a variable unused.
- 1 got through.

| Break | Why it got through | What changed |
|---|---|---|
| Q08: the state shown is not updated after publishing | The stand-in server handed the screen its own stored records, not copies. Publishing changed the stored record, so the screen's copy changed with it, and the test saw "Published" without the screen ever updating | The stand-in now replies with copies, as a real server does. Then Q08 was caught |

**Second round:**

- The four rewritten breaks and Q08 were run again, and all five were caught.
- Q20 now orders categories by name instead of by display order.

**Final run.** Fixing the stand-in could change other results, so all 21 were run again from a clean baseline. **All 21 were caught.**

### 3.3 B5.3, on 5 November 2026

- `npm --prefix backend/spike test`: **958 tests, 958 passed, 0 failed.** Emulator only. That is 37 more than B5.1's 921:
  - G12: 31 tests of OP-24 through the Functions emulator, against the stand-in site.
  - U6: 6 tests with no emulator: the address check, plain-text titles, and the time and size limits.
- `npm --prefix admin test`: **79 tests, 79 passed, 0 failed.** Emulator only. That is 12 more:
  - 8 news-screen tests with the stand-in server.
  - 4 against the real OP-24 and OP-23, with the backend's stand-in site.
- `npm --prefix admin run build`: passes. 468 kB (147 kB compressed).

**A defect the tests found while building.** With no page-count header, OP-24 reported 0 pages instead of "unknown", because `Number(null)` is 0. G12 caught it, and it was fixed before any break was run.

**The stand-in site was made stricter before the breaks**, so that a break could not pass for the wrong reason:

- Its redirect now goes to a page on itself that serves posts. Following the redirect would therefore succeed, and a test can tell that OP-24 refused it. Before, the redirect went to an address that does not exist.
- Its server error now carries a body that looks like a usable empty list, so only the status shows the failure.
- The time-limit test has its own 5-second limit, so a break that removes OP-24's time limit fails the test instead of hanging the run.

**Do the tests catch broken code?** 23 deliberate breaks were tried one at a time.

| Where | How each break was run | Breaks |
|---|---|---|
| OP-24 on the server | Rebuilt, then run against G12 and U6, and the admin suite | 13 |
| The news screen | Type-checked, then run against the admin suite | 10 |

In the first round, 21 were caught and none got through. Two did not compile: W06 (no time limit) and N07 (Next always offered). They were rewritten as "the time limit is 1,000 times longer" and "Next offered one page past the last", and both were then caught.

W06 was caught by the U6 time-limit test failing at its own 5-second limit. That run did not then finish on its own, because the stand-in's unanswered request kept it open, and the script's 5-minute limit stopped it.

The 23 include:

- every field asked for;
- a redirect followed;
- a `javascript:` link passed on;
- plain HTTP to any host;
- credentials or a query in the address;
- no size limit;
- a page past the last being a failure;
- a missing pages header counting as 0;
- a failure status accepted;
- more than 100 a page;
- unknown fields accepted;
- character references not decoded;
- the saved flags not shown or not updated;
- Save offered with no change;
- the breaking box setting hidden;
- links keeping the opener;
- the title shown as HTML;
- the page not sent;
- the site's message lost;
- no News link.

**A flaky run.** One admin baseline run failed one test on unchanged code, and the repeats passed. It recurred on 6 November 2026 and was then named, explained and fixed: see M-1. It was not the emulator.

## 4. Findings

| ID | Finding | What it means |
|---|---|---|
| J-1 | `EMAIL_NOT_VERIFIED` is the reason OP-11 already uses for readers. The contract names `FORBIDDEN` for a caller who is not an admin, and nothing for an admin whose email is not verified | Spike choice. To agree |
| J-2 | OP-14's reply gains `email_verified`, beside the spike's own `is_admin` and `is_active` (C-6) | To agree with the panel's contract |
| J-3 | An admin whose email is not verified still counts in the last-admin guard, as a disabled admin does (C-3). The last active admin could be one who cannot act, and nothing reports it | To look at with the count repair (OP-41) |
| J-4 | The recent-sign-in check is not built (section 1) | Waits for OP-35, OP-37 and OQ-56 |
| J-5 | A session ends on the next server call or when the panel comes back into focus. A panel left open shows what it showed until then, but the server refuses every call. There is no timer, because OQ-20 sets no session length | To settle with OQ-20 |
| J-6 | At sign-in, an admin whose email is not verified gets the one refusal message, so the panel never says "verify your email" | Spike choice. It keeps one message for every refusal (SEC-CHK-17). To agree with the M2 designs |
| J-7 | `npm test` in `admin/` builds and runs the backend spike's functions, so `admin/` depends on that folder being installed | As I-8 in `NOTES.md`. Decide at promotion |
| K-1 | The lite Firestore client is used for the public reads (section 2a.1) | Spike choice, within DEP-34 |
| K-2 | No operation returns one issue to an admin. Opening an issue by its address pages through OP-15 until it is found, so it costs more as issues grow. Opening it from the list costs nothing, because the list hands it over | To agree: OP-15 could take an `issue_id`, or a "get one issue" operation could be added |
| K-3 | The panel lists 20 issues at a time. That is a PLACEHOLDER (D-5) | To set with the M2 designs |
| K-4 | The editor has no upload control (W3), so an admin cannot publish an issue from the panel until a file has been accepted through OP-19 and OP-40 some other way | Waits for the upload screen (T-09.2, OQ-22, OQ-30) |
| K-5 | Confirmations are inline buttons, not dialogs, and every message and label is a PLACEHOLDER | To settle with the M2 designs |
| K-6 | App Check is not used, as the Functions emulator's own log shows | OQ-52 |
| K-7 | No segment list is seeded (OQ-13), so the editor shows no segment choice. Its checkboxes are built but no test covers them | Test when segments are seeded |
| L-1 | APP_CONFIG has no setting for the WordPress address. `wordpress_base_url` (private) is a spike addition for CFG-03 | To add to the data model, with OQ-39 |
| L-2 | The time limit (10 s), size limit (1 MB), default page size (20) and highest page (1,000) are PLACEHOLDERS | To set when MFW's site is known |
| L-3 | One malformed post makes the whole page `UNAVAILABLE`, rather than being skipped. That fails closed, but one bad post would hide the whole page from the admin | Spike choice. To agree |
| L-4 | A page past the last one is an empty page, read from the API's documented error code `rest_post_invalid_page_number`. How MFW's site answers is NOT VERIFIED | Check with OQ-39's "successful read-only test" |
| L-5 | Titles are made plain text on the server: tags dropped and a small set of named character references decoded. Other named references stay as written | Spike choice |
| L-6 | The news screen has no category filter, although OP-24 accepts one. The categories shown in the app are `news_category_ids` (CFG-04, OPEN) | Add when CFG-04 is set |
| L-7 | Whether the live site is reachable from the backend, with no security plugin or firewall in the way (OQ-39), is NOT VERIFIED. Only the stand-in was read | OQ-39 |
| M-1 | **Found and fixed on 6 November 2026.** The failing test was the session test "coming back to the panel after the role was removed". The panel attaches its focus listener in an effect that runs just after the first paint, and the test sent the focus event as soon as the heading appeared, so it sometimes arrived first. It failed 3 times in 40 runs. The test now waits until the issues list has called the server, which happens in the same update as the listener, and it then passed 40 runs out of 40. Removing the focus check, or ignoring its answer, is still caught. The emulator guess in section 3.3 was wrong | A test defect, not the panel's. In the panel, a focus missed in that moment is harmless, because the role was checked at sign-in |

## 5. Not tested

| Case | Why |
|---|---|
| A real project, real tokens, and how soon a removal is seen | No project exists; the Functions emulator does not verify tokens (`backend/spike/04-save-profile-notes.md`, B-1) |
| The other OQ-20 measures: password rules, session length, a second factor | Not decided |
| The browser check for this step | Done with the screens in B5.2 |
| MFW's live WordPress site: whether it is reachable, how fast, how large its pages are, and how it answers a page past the last | OQ-39. Only the stand-in was read (L-4, L-7) |
| The breaking-news notification | OP-25 is not built. AC-9.7 is not claimed |
| AC-8.6, AC-8.7 and AC-8.8 in the app itself | The app side is Yuvraj's (MOD-05, MOD-09). Here the public reads the app makes are shown instead |
