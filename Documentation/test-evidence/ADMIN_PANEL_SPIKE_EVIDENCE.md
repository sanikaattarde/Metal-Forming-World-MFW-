# Admin Panel Spike Evidence, Emulator Only: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Admin Panel Spike Evidence, Emulator Only |
| File | `Documentation/test-evidence/ADMIN_PANEL_SPIKE_EVIDENCE.md` |
| Phase | 4 — Testing, Release and Risk Management. A test evidence report (`TESTING_STRATEGY.md` §13) |
| Version | 0.1 |
| Status | Draft for review. Not reviewed. **Every result is "emulator only" or "local only".** DEC-004 is OPEN, so the panel is a spike and nothing here chooses its technology. Nothing is AGREED, and nothing here has gone to MFW |
| Date | 6 November 2026 |
| Tests run by | Sanika Attarde (WS-A) |
| Approval required | Both developers |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 6 November 2026 | First report: the WS-A admin panel spike, for T-01.6, T-09.1, T-09.3 and T-09.4 |

### 1.1 Related documents

| Document | Status on 6 November 2026 |
|---|---|
| `DEVELOPMENT_WORKFLOW.md` §13 item 5 | A spike is not merged into `main` as production code. Its findings are merged as a document. This report is that document |
| `Documentation/test-evidence/BACKEND_RULES_EMULATOR_EVIDENCE.md` | The backend spike's report, at `e7d9f37`. This report adds the server changes the panel needed (section 4.2) |
| `TESTING_STRATEGY.md` §9, §13 | The security checklist and the evidence location |
| `ACCEPTANCE_CRITERIA.md` AC-8, AC-9.7 | The admin panel's acceptance rows |
| `SECURITY_AND_ACCESS_CONTROL.md` SC-22, ST-22, threat T28 | The panel's web-surface objectives. Their mechanism is OPEN (DEC-004, OQ-60) |
| `CI_CD_AND_QUALITY_GATES.md` QG-09 | Admin panel build and tests, "Blocked by DEC-004". Section 9 gives the commands used here |
| `DEVELOPMENT_ROADMAP.md` T-01.6, T-09.1, T-09.3, T-09.4 | The tasks this spike explored |
| Branch `spike/sa-admin-skeleton`, commit `d8d10f7` | B3, the skeleton and sign-in page. Working notes `admin/NOTES.md` (findings I-1 to I-10) |
| Branch `spike/sa-admin-content`, commit `ca31b5a` | B5, built on B3: the role check, the issue and category screens, and the news controls. Working notes `admin/NOTES-B5.md` (findings J-1 to M-1). Both branches are on GitHub and neither is merged |

## 2. What This Report Is

1. It records what the admin panel spike built, and what its tests and browser checks showed, against the acceptance rows and checklist items they bear on.
2. It lists what the spike could not show, and what needs ENV-TEST or MFW's inputs.
3. It gives the commands for building and testing the panel (section 9), for QG-09.
4. It lists the choices the spike made that need both developers before the work is promoted (section 10).

**What it is not.**

- It does not choose the admin panel's technology. DEC-004 stays OPEN. React was proposed in S2 and TD-14, and the build tool, the router and the test tools are spike choices (section 10).
- It does not change any decision, requirement, checklist item or status label.
- It does not claim AC-9.7: marking a post as breaking sends no notification, because OP-25 is not built.

## 3. The Run

| Field | Detail |
|---|---|
| Commits | `spike/sa-admin-content` at `ca31b5a`: B5's tip `f276bd4` plus one test fix (section 6.1, M-1) |
| Date | 6 November 2026 |
| Backend | `npm --prefix backend/spike test`: **958 tests, 958 passed, 0 failed.** The runner reported 191 seconds. Emulator only |
| Admin panel | `npm --prefix admin test`: at `f276bd4`, 78 passed and 1 failed: the flaky session test (M-1). With the fix, **79 tests, 79 passed, 0 failed**, in two runs of about 16 seconds each. Emulator only |
| Build | `npm --prefix admin run build`: passes. 468 kB of script, 147 kB compressed |
| Emulators | Auth, Functions and Firestore from the backend spike's `firebase-tools` 15.34.2, project name `demo-mfw-spike`. No login and no cloud project |
| Runtime | Node.js 26.0.0; OpenJDK 21 for the emulators |
| Test data | Generated. Accounts use `example.test` addresses and a test password that works only on the emulators. WordPress posts come from a stand-in site on 127.0.0.1. No MFW content, no real person, no credential (DEC-024) |
| Runner output | Not filed. As in the backend report, it holds local paths and the emulators' one-time codes, and it was kept only in a temporary folder |

The admin tests by file:

| File | Tests | What it covers |
|---|---|---|
| `smoke.test.tsx` | 2 | The smoke test for QG-09: the sign-in page, and the notice when not served locally |
| `sign-in-page.test.tsx` | 11 | One refusal message, the provider's code never shown, a refused account signed out, the password cleared, one sign-in per click |
| `sign-in.test.ts`, `services.test.ts`, `admin-api.test.ts` | 8 | Trimming the address; the in-memory session set-up; which refusals end a session; the OP-14 role check's three conditions |
| `session.test.tsx` | 3 | The session ending when access is lost, on returning to the panel, and signing out |
| `screens.test.tsx` | 19 | The issues list, the issue editor and the categories screen, against a stand-in server |
| `news.test.tsx` | 8 | The news screen, against a stand-in server |
| `sign-in.emulator.test.ts` | 14 | Sign-in and the role check against the real OP-14 |
| `content.emulator.test.ts` | 10 | The issue and category calls against the real OP-15 to OP-18, OP-21 and OP-22, and the rules |
| `news.emulator.test.ts` | 4 | The news calls against the real OP-24 and OP-23, with the stand-in site |

The backend's 958 include 37 for OP-24 (groups G12 and U6) and 14 for the verified-email gate. They are 51 more than the 907 in the backend report.

### 3.1 Do the tests catch broken code?

Each step was checked with deliberate breaks of its code, one at a time, each type-checked or rebuilt, and each run on a clean baseline against the whole suite.

| Step | Breaks | Result |
|---|---|---|
| B3 skeleton and sign-in | 20 | 19 caught. One cannot be caught by these tests: swapping in browser storage for the in-memory session, because the tests load the provider SDK's Node build, where the two are the same object (I-10). The browser check is the only evidence for it |
| B5.1 role check and verified email | 18 | All caught |
| B5.2 issue and category screens | 21 | All caught, after one gap was closed: the test stand-in server shared its stored records with the screen, so a screen that never updated looked correct. It now replies with copies |
| B5.3 news controls and OP-24 | 23 | All caught |

## 4. What Was Built

### 4.1 The panel (`admin/`)

| Part | What it does |
|---|---|
| Technology | React 19.3.1, built and served with Vite 8.3.5 (TD-14 names no build tool). React Router 8.5.0 gives each screen its own address. Firebase's JavaScript SDK 13.1.0 for sign-in, server calls and public reads, using its lite Firestore client. TypeScript. All pinned exactly; register rows DEP-31, DEP-34 and DEP-67 to DEP-73 are on the spike branches only |
| Where it runs | Only against the local emulators. A page served from any address other than `127.0.0.1` or `localhost` shows a notice, because there is no project configuration (CFG-01) |
| SCR-W-01 Admin sign-in | One message for a wrong password, an unknown address, a disabled account, too many attempts, an account without the role and an admin whose email is not verified. Only an unreachable provider has its own message. A refused account is signed out. The session lives in memory only |
| The role check | OP-14, after sign-in. Admitted only with an active role and a verified email. A check that fails is a refusal |
| The end of a session | Every server call goes through one wrapper. A refusal that means "no longer an admin" signs the panel out with a notice. The panel also asks OP-14 again when it comes back into focus |
| SCR-W-02 Issues list | OP-15, newest first, filtered by state, 20 at a time |
| SCR-W-03 Issue editor | OP-16 for the details, with one request identifier per new issue and the record version on each edit. OP-21 and OP-22 after a confirmation. No upload control (K-4) |
| SCR-W-05 Categories | OP-17 and OP-18. A category in use cannot be deleted. Deleting asks first |
| SCR-W-06 News controls | Posts through OP-24, with their flags read as the app reads them, saved through OP-23 |
| Messages | Every refusal becomes a PLACEHOLDER message. Missing fields are named by label. The server's own text is never shown |

### 4.2 Server changes made for the panel

These are on `spike/sa-admin-content`. The backend report on `main` was written at `e7d9f37`, before them.

| Change | What it does |
|---|---|
| The admin gate | Refuses an admin whose email is not verified, with `EMAIL_NOT_VERIFIED`, after the role check. OQ-20's working position asks for a verified email. The admin set-ups in four earlier test groups (G5, G7, G8, G10) now verify their admins' emails |
| OP-14 | Also returns `email_verified` |
| OP-40 | Rejects a file whose uploader's email is no longer verified |
| OP-24 `listWordPressPosts` (new) | Admin only. Reads one page of posts from the address in a new private setting, `wordpress_base_url` (CFG-03 is OPEN). HTTPS only, no credentials, no redirects, and PLACEHOLDER time and size limits. Titles become plain text, and only web links are accepted. Any failure is `UNAVAILABLE` with the reason `SITE_UNAVAILABLE`. It logs only its outcome. The tests use a stand-in site on 127.0.0.1, and MFW's site is never read |

## 5. Results by Acceptance Row and Checklist Item

| Item | Result (emulator or local only) | Evidence |
|---|---|---|
| AC-8.1: a wrong password is refused | **Met** | Admin tests against the Auth emulator; the browser checks |
| AC-8.2: a non-admin account is refused, in the panel and on direct calls | **Met** for the panel, through OP-14. Direct calls are refused by the server gate (backend report, SEC-CHK-06) | Admin tests against the Functions emulator |
| AC-8.6: categories show correctly in the app | **Partly met.** A category added or renamed in the panel is what the public read returns, in display order. The app itself is not built here | Admin tests against the emulators |
| AC-8.7: publishing and unpublishing show correctly | **Partly met.** After publishing, a visitor can read the issue through the rules, and after unpublishing cannot. Shown in a browser check too. The app itself is not built here, and an issue needs a file accepted some other way (K-4) | Admin tests; the B5.2 browser check |
| AC-8.8: hidden news posts are not shown | **Partly met.** A post hidden in the panel is hidden in the public read the app makes. The app itself is not built here | Admin tests; the B5.3 browser check |
| AC-9.7: a breaking post is flagged and sent | **Not claimed.** The flag is set and readable; nothing is sent | — |
| SEC-CHK-06: every admin operation is refused for non-admins | **Met for OP-24**, for five kinds of caller, with the site not asked | Backend group G12 |
| SEC-CHK-08: admin sign-in refuses wrong passwords, with the OQ-20 measures | **Partly met.** Wrong passwords are refused, and a verified email is required. The recent-sign-in check is not built (OQ-56 is about adding and removing admins, which wait for OQ-58), and password rules and session length are not decided | Admin and backend tests |
| SEC-CHK-15: WordPress content is shown without running scripts, and links open outside | **Panel side met.** Titles are plain text on the server and shown as text; links open in a new tab with no opener. The app's rendering is not built here | Backend G12 and U6; admin news tests; the B5.3 browser check |
| SEC-CHK-17: the same response for a known and an unknown address | **Met** for admin sign-in. Timing is not tested | Admin tests |
| SEC-CHK-18: a removed admin is refused on the next privileged call | **Met** in the panel: the next call, or coming back to the panel, ends the session. How soon a removal is seen on a real project is not measured | Admin tests |
| SC-22 and ST-22: the panel's web surface | **Not built.** The session is held in memory and sent as a bearer token on each call, not as a cookie. No frame or script policy is set, and nothing in the spike limits which browser origins may call the functions. These wait for DEC-004 and OQ-60 | Observed only |

### 5.1 The browser checks

Three checks by hand, on 5 November 2026, in an embedded Chromium 152 browser on macOS against `vite preview` and the emulators:

1. **B3:** a wrong and a right password showed the same message. The provider's replies were 400 and 200, and the second was refused by the role check.
2. **B5.2:** an admin signed in through OP-14 and published an issue after confirming, which a visitor could then read. Deleting a category in use was refused with its message.
3. **B5.3:** the news screen listed the stand-in site's posts through OP-24, showed an encoded title as clean text, and saved a breaking flag that a visitor could read.

In every check the browser contacted only 127.0.0.1. It never contacted the WordPress stand-in itself, as TD-12 requires. Local and session storage stayed empty, and IndexedDB held only the Firebase SDK's heartbeat date (I-5).

## 6. Defects and Gaps Logged

### 6.1 Found and fixed in the spike

| Where | What was wrong | Fix |
|---|---|---|
| OP-24 | With no page-count header from the site, it reported 0 pages instead of unknown, because `Number(null)` is 0. A test found it | A missing header is now null |
| The panel's provider set-up | The first build set up sign-in with the SDK's default storage, which created an empty IndexedDB database before switching to memory | The session is set to memory from the start |
| A test stand-in | The stand-in server handed screens its stored records, so a screen that never updated passed its test | It replies with copies |
| A session test (M-1) | It sent a focus event as soon as the page drew, before the panel's focus listener was attached, so it failed about 1 run in 13 (3 of 40) | It waits until the listener is in place. 40 runs out of 40 then passed, and removing the focus check is still caught |

### 6.2 Open

| Finding | What is open |
|---|---|
| I-10 | No automated test here can tell browser storage from an in-memory session. Only the browser check shows it |
| J-3 | An admin whose email is not verified still counts in the last-admin guard, so the last active admin could be one who cannot act |
| K-2 | No operation returns one issue to an admin. Opening an issue by its address pages through OP-15 |
| K-4 | The panel cannot publish an issue on its own until the upload screen exists (T-09.2, OQ-22, OQ-30) |
| L-3 | One malformed post makes OP-24's whole page `UNAVAILABLE` |
| I-6 | `npm audit` reports 4 high advisories in `@grpc/grpc-js` inside `firebase`. Releases 13.1.0 and 13.2.0 both pin it at ~1.9.0, and the only fix offered is a downgrade to 9.14.0. None of that code is in the panel's bundle |

## 7. What Needs ENV-TEST or MFW's Inputs

| No. | Case | Needs |
|---|---|---|
| 1 | Admin sign-in with real tokens, and how soon a removed admin is refused | ENV-TEST (DEC-023, OQ-40) |
| 2 | MFW's live WordPress site: reachable from the backend, its speed and page sizes, and how it answers a page past the last | OQ-39 (L-4, L-7) |
| 3 | App Check, and the SC-22 controls: frames, scripts, browser origins | OQ-52, OQ-60, DEC-004 |
| 4 | The supported browsers | OQ-26. Only one browser was used |
| 5 | Serving from the chosen host, and the bundle (468 kB, 147 kB compressed) on a slow connection | DEC-004 |
| 6 | The OQ-20 measures still open: password rules, session length, the recent-sign-in window | OQ-20, OQ-56 |

## 8. What Is Not Built

| Part | Waits for |
|---|---|
| The upload screen (SCR-W-03's PDF and cover, SCR-W-04) | OQ-22, OQ-30; T-09.2 |
| Sending a notification and the send log (SCR-W-07, SCR-W-08) | OP-25 to OP-27 |
| Deleting or replacing an issue | OQ-21 |
| The registered-user list and export (SCR-W-09) | OQ-29, OQ-31, OQ-51 |
| Admin management in the panel (SCR-W-11) | OQ-58 |
| A category filter on the news screen | CFG-04 |

## 9. Building and Testing the Panel (for QG-09)

QG-09 stays "Blocked by DEC-004". These commands run the spike's checks, from the repository root:

```bash
git switch spike/sa-admin-content
npm --prefix backend/spike ci --ignore-scripts
npm --prefix backend/spike/functions ci
npm --prefix admin ci --ignore-scripts
npm --prefix admin run build
npm --prefix admin test
```

- `npm --prefix admin test` builds the backend spike's functions, then starts the Auth, Functions and Firestore emulators from the backend's configuration. So the backend folder must be installed first (I-8, J-7). It needs Java 21, as the backend's suite does.
- `npm --prefix admin run test:smoke` runs the smoke test alone, with no emulator.
- `npm --prefix backend/spike test` runs the backend suite, including OP-24's tests.
- The commands were not tried on a clean checkout (NOT VERIFIED).

## 10. Choices to Agree

The spike made these choices because the documents leave them open. Each is recorded in the working notes.

| Area | Choices |
|---|---|
| For DEC-004 | Vite as the build tool; React Router for the screens; Vitest, jsdom and Testing Library for the tests; each package pinned to the newest release at least two weeks old (I-1) |
| Contracts | `email_verified` in OP-14's reply (J-2); `EMAIL_NOT_VERIFIED` for an admin (J-1); `SITE_UNAVAILABLE` and OP-24's reply shape; `wordpress_base_url` as a new private setting (L-1) |
| Behaviour | One refusal message at sign-in, including for an unverified admin (J-6); when a session ends (J-5); sessions in memory only (I-4); a malformed post failing the whole page (L-3) |
| Values that are placeholders | Every message and label (K-5); 20 issues and 20 posts a page (K-3, L-2); OP-24's time and size limits (L-2) |
| Reads | The lite Firestore client for the public reads (K-1) |
