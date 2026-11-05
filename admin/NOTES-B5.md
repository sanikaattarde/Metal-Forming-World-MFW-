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

## 3. Results

### 3.1 B5.1, on 5 November 2026

- `npm --prefix backend/spike test`: **921 tests, 921 passed, 0 failed.** Emulator only. That is 14 more than the 907 in `Documentation/test-evidence/BACKEND_RULES_EMULATOR_EVIDENCE.md`:
  - G5: 4 tests. An unverified admin is refused with `EMAIL_NOT_VERIFIED`, and passes once verified. A reader still gets `FORBIDDEN`. A closed account is refused as closed first. OP-14 reports the flag.
  - G8: 7 tests, one for each admin operation, refusing an admin whose email is not verified, with nothing written.
  - G10: 3 tests. The same caller is refused on OP-19 and OP-20, and the trigger rejects a file whose uploader's email stopped being verified.
  - Five existing test set-ups now verify their admins' emails, because the gate requires it: G5, G7 (one test), G8 and G10.
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

## 5. Not tested

| Case | Why |
|---|---|
| A real project, real tokens, and how soon a removal is seen | No project exists; the Functions emulator does not verify tokens (`backend/spike/04-save-profile-notes.md`, B-1) |
| The other OQ-20 measures: password rules, session length, a second factor | Not decided |
| The browser check for this step | Done with the screens in B5.2 |
