# MFW admin panel

The web admin panel (DEC-004, AGREED): a React single-page app in TypeScript (DEC-025), built with Vite as a static site for Firebase Hosting. It holds no secret. Every privileged operation is checked again on the backend (TD-14, SEC-CHK-06), so the panel's own checks only decide what it shows.

The panel was first built on the spike branches `spike/sa-admin-skeleton` and `spike/sa-admin-content`. Their notes (`admin/NOTES.md`, `admin/NOTES-B5.md` on those branches) hold the browser checks and the deliberate-break results; "the admin spike notes" in a comment points there.

## Set-up

1. Node.js 22 or later, and the backend set-up of [`backend/README.md`](../backend/README.md), because the tests run against the backend's emulators and functions.
2. From this folder: `npm ci --ignore-scripts`.

## Running and testing

| Command | What it does |
|---|---|
| `npm test` | Builds `backend/functions`, starts the Auth, Functions and Firestore emulators with `backend/firebase.json`, and runs every test in `test/` |
| `npm run test:smoke` | The smoke test for QG-09, with no emulator |
| `npm run build` | The type check and the static build into `dist/` |
| `npm run dev` | The dev server on `127.0.0.1:5173`. With no project configuration it talks to the local emulators, which must be running |

## Configuration

`.env.example` names the web configuration of a Firebase project (CFG-01): `VITE_FIREBASE_API_KEY`, `VITE_FIREBASE_AUTH_DOMAIN`, `VITE_FIREBASE_PROJECT_ID` and, optionally, `VITE_FIREBASE_APP_ID`. Copy it to `.env.test` or `.env.production` (ignored by Git) and build with `vite build --mode test` or `vite build`. Set all three or none: a partial configuration, or a `demo-` project name, stops the panel. With none, the panel works only from `127.0.0.1` or `localhost` against the emulators, and shows a notice anywhere else. No project exists until ENV-TEST is created (OQ-40).

## Screens

| Screen | File | Task |
|---|---|---|
| SCR-W-01 Admin sign-in | `src/SignInPage.tsx`, `src/signIn.ts` | MOD12-P1-T01, MOD12-P2-T01 |
| Issues list | `src/IssuesPage.tsx` | MOD12-P2-T03 |
| Issue details: create, edit, publish and unpublish | `src/IssueEditor.tsx` | MOD12-P2-T03 |
| Issue categories: add, rename, reorder and delete | `src/CategoriesPage.tsx` | MOD12-P2-T03 |
| SCR-W-06 News controls: hide or show a post, mark it as breaking | `src/NewsPage.tsx` | MOD12-P2-T04 |

## What the panel does on sign-in

- **One message for every refusal** (SEC-CHK-17): a wrong password, an unknown address, a disabled account and an account without the admin role cannot be told apart. Only an unreachable provider has a message of its own.
- **The role check** calls OP-14 `getMyAdminRole`: an account is admitted only if the role exists, is active and the email is verified (OQ-20's working position). A refused account is signed out.
- **The session ends when access is lost**: when any server operation refuses the account as no longer an admin, and when the panel comes back into focus and OP-14 says so.
- **Sessions live in memory only**, so a reload signs the admin out and nothing about the account is kept in browser storage (`CODING_STANDARDS.md` §15).

## The content screens

- **Every write goes through a server operation** (OP-15 to OP-18, OP-21, OP-22) in `src/data.ts`; the public reads of categories and segments use the same Firestore reads as the app, which the rules allow to anyone.
- **A retry sends the same request identifier**, so a lost reply never makes a second issue or category.
- **An edit carries the record version the screen showed**; a stale screen is told to reload (`STALE_RECORD`).
- **Publishing needs an accepted file** (`NO_ACCEPTED_FILE`). The upload screen waits for OQ-22 and OQ-30 (MOD12-P2-T02).
- **The server's own message never reaches the screen**: `src/describeError.ts` maps each reason to the panel's wording, and names fields by their labels, never by the value typed.

The news-controls screen lists MFW's posts through OP-24 and sets each post's control through OP-23. Marking a post as breaking sends no notification: dispatch is MOD11-P2-T03.

## Known limits

- **Placeholder visuals and wording.** No brand assets or admin designs exist yet (MOD16-P1-T04). The message wording waits for OQ-20.
- **The OQ-20 measures are not built**: password rules, a second factor, session expiry and recent sign-in.
- **Hosting is not configured.** The `hosting` entry of `firebase.json` and the bucket CORS setting for uploads come with ENV-TEST (MOD14-P2-T03).
