# Admin spike notes: the panel skeleton and its sign-in page

| Field | Detail |
|---|---|
| Branch | `spike/sa-admin-skeleton`, cut from `spike/sa-backend-rules` at `e7d9f37` for its emulator harness. A spike: not merged to `main` |
| Date | 5 November 2026 |
| Task | `T-01.6` in `DEVELOPMENT_ROADMAP.md`: the admin skeleton and SCR-W-01, admin sign-in, against the Auth emulator |
| Status | Working notes. PROPOSED. Not reviewed. Every result is "local only" or "emulator only" |
| Rests on | DEC-004 (OPEN); DEC-003 (OPEN); TD-14 (PROPOSED); OQ-20 (OPEN: what secure sign-in includes); CFG-01 (OPEN: no project configuration) |

## 1. What was built

| Part | What it does |
|---|---|
| `src/signIn.ts` | Decides a sign-in. Signed in by the provider, then the role check. A wrong password, an unknown address, a disabled account, too many attempts and an account without the admin role all end as `refused`. Only a provider that cannot be reached ends as `unavailable`. A role check that throws, or answers anything but `true`, is a refusal. A refused account is signed out again |
| `src/SignInPage.tsx` | SCR-W-01: email address, password, a button. One message for every refusal, announced as an alert. The password is cleared after a failed attempt, and the button is disabled while a sign-in runs |
| `src/roleCheck.ts` | **The role check is not built.** It calls OP-14 and belongs to the next block (B5, AC-8.2). Until then the built panel refuses every account after sign-in. It fails closed, so no account reaches a page the server would refuse anyway |
| `src/services.ts` | Connects to the local Auth emulator, with the demo project name and the emulator's placeholder key. A page served from any address other than `127.0.0.1` or `localhost` gets no services and shows a notice, because there is no project configuration (CFG-01). Sessions live in memory only, from the start |
| `src/App.tsx` | The sign-in page, the notice, and a placeholder after sign-in with a sign-out button. No admin screen is built |
| `firebase.json` | The Auth emulator only, on 127.0.0.1:9099 |

**Placeholder visuals.** No brand assets have been received, and there is no M2 design. The wording of the three messages is a PLACEHOLDER (OQ-20).

**Not built.** The OP-14 role check; the OQ-20 measures (password rules, a second factor, session expiry, recent sign-in); ending a session when the role is removed; every admin screen; Google sign-in for admins; serving in ENV-TEST, which does not exist yet.

### 1.1 The build tool

TD-14 names React and no build tool. Sanika Attarde chose Vite on 5 November 2026, from Vite, esbuild and Parcel:

- Its static build fits Firebase Hosting (DEP-27).
- It has a maintained React plugin.
- Vitest reads the same configuration, so the tests and the build share one set-up.

**This is a spike choice, flagged for DEC-004.** If DEC-004 picks Flutter web or another build tool, `admin/` is rewritten.

### 1.2 Packages

Every package is pinned to an exact version and recorded in `DEPENDENCY_REGISTER.md` (DEP-31, DEP-34, DEP-67 to DEP-72).

Each is the newest release that was at least two weeks old on 5 November 2026:

- Vite 8.3.6 was published that morning, so 8.3.5 is used.
- Vitest 5.1.0, `@vitejs/plugin-react` 6.2.1 and `firebase` 13.2.0 were three days old, so 5.0.5, 6.1.2 and 13.1.0 are used. `firebase` 13.1.0 is also the version the backend spike's tests use.

No document sets this two-week rule. It is a spike choice, made because a very new release has had little time for a problem to be found.

The packages were installed in `admin/` only, with install scripts switched off.

## 2. Results

On 5 November 2026:

- `npm --prefix admin test`: **24 tests, 24 passed, 0 failed.** Emulator only.
- `npm --prefix admin run test:smoke`: 2 passed, with no emulator.
- `npm --prefix admin run build`: the type check and the build pass. The bundle is 309 kB (95 kB compressed) and holds no gRPC or Firestore code.

| File | Tests | What it shows |
|---|---|---|
| `test/smoke.test.tsx` | 2 | The smoke test for QG-09: the sign-in page with its three controls, and the notice with no form when the page is not served locally |
| `test/sign-in-page.test.tsx` | 11 | In a simulated browser, with stand-ins for the provider: one message for a wrong password, an account without the role, an unknown address, a disabled account and too many attempts. No provider code on the page. A refused account signed out. A failed or odd role answer refused. Its own message when the provider cannot be reached. The password cleared, the button disabled while waiting, one sign-in per click, and the placeholder and sign-out for an admin |
| `test/sign-in.emulator.test.ts` | 9 | Against the Auth emulator with the real SDK: only local addresses get services. A wrong password, an unknown address and a disabled account are refused, with the same outcome. The right password without the role is refused and signed out. The built panel refuses every account. With a role check that says admin, the account is signed in. A failing role check is refused. An unreachable provider is "unavailable" |
| `test/sign-in.test.ts` | 1 | The address is trimmed and the password is not |
| `test/services.test.ts` | 1 | The provider is set up through `initializeAuth` with a persistence option (see M18 below) |

| Requirement | Result |
|---|---|
| AC-8.1: a wrong password is refused | Met, emulator only |
| AC-8.2: a non-admin account is refused | **Not met.** The page refuses an account that the role check rejects, with the same message, and signs it out. The role check itself is not built (I-2) |
| SEC-CHK-17: the same response for a known and an unknown address | Met for admin sign-in, emulator only. Timing is not tested, as the item says |
| Plan acceptance for this block: the page builds and serves locally, and the smoke test passes | Met, local only |

**The browser check.** Done by hand on 5 November 2026 in an embedded Chromium 152 browser (Chrome 152.0.7977.167) on macOS, against `vite preview` on 127.0.0.1:4173 and the Auth emulator:

1. The page shows the heading, the two fields and the button.
2. A demo account was signed in with a wrong password, then the right one. Both showed the same message. The network log shows that the provider refused the first (400) and accepted the second (200). The second was then refused by the role check, which is not built.
3. Only 127.0.0.1:4173 and 127.0.0.1:9099 were contacted.
4. Local and session storage stayed empty.
5. IndexedDB, first build: `getAuth` created an empty `firebaseLocalStorageDb`. The code now uses `initializeAuth` with in-memory persistence. After that change, only `firebase-heartbeat-database`, holding one date, was created (I-5).

**Do the tests catch broken code?** 20 deliberate breaks of the source were tried one at a time. Each was type-checked and then run against the whole suite with the emulator.

In the first round, 16 were caught and 2 did not compile. Both of those were rewritten, then caught. Two got through:

| Break | Why it got through | What changed |
|---|---|---|
| M09: the address is not trimmed | A browser trims an email field itself, so the page test passed either way | A direct test of `signInAdmin`. Caught on the re-run |
| M18: sessions kept in browser storage | Under Vitest the SDK's Node build is loaded. There the browser persistences are the same object as in-memory persistence: checked in both test environments | No test here can catch it. The browser check is the only evidence (I-10) |

Final count: 19 of 20 caught. M18 is a known limit.

### 2.1 Running it (for QG-09)

QG-09 stays "Blocked by DEC-004". These commands run this spike's checks, from the repository root:

```bash
npm --prefix backend/spike ci --ignore-scripts
npm --prefix admin ci --ignore-scripts
npm --prefix admin run build
npm --prefix admin test
```

- The first line installs the emulator tool that `npm test` borrows (I-8).
- `npm --prefix admin run test:smoke` needs no emulator.
- The run script puts Java 21 on `PATH`, as for the backend. Whether the Auth emulator alone needs Java was not checked.
- The commands were not tried on a clean checkout (NOT VERIFIED).

## 3. Findings

| ID | Finding | What it means |
|---|---|---|
| I-1 | The build tool is a spike choice (section 1.1) | DEC-004 |
| I-2 | The role check is not built, so the built panel refuses every account after sign-in | B5 adds the OP-14 call (AC-8.2). Until then, signing in can only be shown with a role check passed in by a test |
| I-3 | A provider that cannot be reached gets a message of its own. Every other failure gets the one refusal message, including too many attempts. A role check that fails is a refusal too, so a network failure during that check shows the refusal message | Spike choices. To agree with OQ-20 and the M2 designs |
| I-4 | Sessions live in memory only, so a reload signs the admin out. `CODING_STANDARDS.md` §15 item 5 asks for no personal data in browser storage beyond what the session needs | Session length is OQ-20. To agree |
| I-5 | Firebase's own heartbeat. The SDK keeps a date in an IndexedDB database (`firebase-heartbeat-database`), and can send heartbeats to Firebase services. Only a date was stored, and no request left the machine in the browser check. What it sends on a real project is NOT VERIFIED | For TD-16 and SEC-CHK-10 |
| I-6 | `npm audit` reports 4 high advisories in `@grpc/grpc-js` 1.9.16, reached through Firestore's Node build. Releases 13.1.0 and 13.2.0 both pin it at ~1.9.0; others were not checked. The only fix offered is a downgrade to 9.14.0. The admin bundle holds no gRPC or Firestore code: the only "firestore" strings in it are package names in the SDK's list of products. For comparison, `backend/spike` now reports 19 (14 moderate, 5 high), up from the 10 that `02-setup-notes.md` recorded | Recorded in DEP-34. To review with SEC-CHK-13 |
| I-7 | Vite's install tree holds `lightningcss` 1.33.0 under MPL-2.0, a file-level copyleft. It runs at build time and is not shipped. `firebase` has no LICENSE file in its npm package | Recorded in DEP-67 and DEP-34 |
| I-8 | `npm test` uses the backend spike's `firebase-tools` and run script, so `backend/spike` must be installed first. Promotion needs its own or a shared copy | Decide at promotion |
| I-9 | jsdom 30 needs Node 22.22.2, 24.15 or 26 and later, which is narrower than the functions' Node 22 | Settle the Node version for the repository |
| I-10 | No automated test here can tell browser storage from in-memory sessions, because the tests load the SDK's Node build (M18) | A browser-based test, or the manual check in section 2, each time this changes |

## 4. Not tested

| Case | Why |
|---|---|
| Sign-in on a real project | No project exists (DEC-003, CFG-01). The Auth emulator's tokens are unsigned, so nothing here shows how real tokens behave (`backend/spike/04-save-profile-notes.md`, B-1) |
| The OP-14 role check, a removed admin, a closed account | B5 |
| The OQ-20 measures, and rate limits on sign-in (SEC-CHK-19) | Not decided, not built |
| Browsers other than the one used | The supported list is OQ-26. The manual check used one embedded Chromium 152 browser on macOS |
| Accessibility | OQ-25. The fields have labels and the message is an alert, and nothing more was checked |
| Serving from Hosting or ENV-TEST | Neither exists. The acceptance is a local build and serve |
