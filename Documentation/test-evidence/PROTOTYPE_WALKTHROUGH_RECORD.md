# Prototype Walk-through Record: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Prototype Walk-through Record |
| File | `Documentation/test-evidence/PROTOTYPE_WALKTHROUGH_RECORD.md` |
| Phase | 4: Testing, Release and Risk Management. The recorded walk-through of T-02.1 (MOD16-P1-T05) |
| Version | 0.1 |
| Status | Draft for review. Not reviewed. **A prototype, not the M2 design.** The low-fi prototype (sections 2 to 4) uses no MFW brand asset. The branded prototype (section 7) uses the website's colours and fonts as the working position of OQ-63, and no MFW logo or content. Neither has been shown to MFW, and neither approves anything |
| Date | 9 November 2026 |
| Prepared by | Yuvraj Gaykhe (WS-B), 8 and 9 November 2026 |
| Approval required | Both developers. This record covers the app screens of MOD16-P1-T05, low-fi and branded. Its review by Sanika Attarde is the hand-over of the "Done when" of MOD16-P1-T05. The admin panel screens (MOD16-P1-T04) and MFW's approval at M2 stay open |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 8 November 2026 | First record: the low-fi clickable prototype of the app screens, its walk-through against the screen inventory, a design critique, and the Figma copy of the screens. Revised on 8 November 2026 after the review of pull request #53: the "Approval required" row says that the record covers the app screens of MOD16-P1-T05, and that the admin panel screens and the final look stay open; section 3.1 counts 21 in-scope app screens; section 2 gives the counts of the whole test suite and says that the drawing tests are golden comparisons; and the prototype's one package beyond the SDK, `flutter_lints`, is named. Revised again on 8 November 2026: the Figma row records that YG shared the file with Sanika Attarde, and that the file now also holds the work of pull request #57. Revised on 10 November 2026 (no version change, DEC-010): section 7 adds the branded prototype, and the status, approval and related documents rows and section 5 say what applies to which prototype. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `SCREEN_INVENTORY_AND_NAVIGATION.md` sections 3, 4, 5 and 7 | Exists, draft. The access states, what must be reachable, the app screens SCR-A-01 to SCR-A-23, and the states every screen handles |
| `DEVELOPMENT_ROADMAP.md` T-02.1 | Exists, draft. Exit: the prototype covers every in-scope screen and state |
| `YUVRAJ_IMPLEMENTATION_ROADMAP.md` MOD16-P1-T05 | Exists, a record of the plan. Tests: a walk-through against the inventory, recorded. This document is that record |
| `DEVELOPMENT_WORKFLOW.md` §13 item 5 | Exists, draft. A spike is not merged into `main`; its findings are merged as a document |
| Branch `spike/yg-prototype`, commit `c3f2773` | Not merged to `main`. On GitHub. The prototype in `tools/spikes/prototype/`, a separate Flutter app with no package beyond the SDK and the lints package (`flutter_lints`, DEP-58, for development only), and its 24 rendered screens in `test/shots/` |
| Branch `spike/yg-prototype-branded`, commit `797d16b` | Not merged to `main`. On GitHub. The branded prototype in `app/prototype/`, run with `flutter run -t prototype/main.dart`, its tests in `app/test/prototype/` and its 30 images in `app/test/prototype/shots/`. Built on top of pull request #69 |
| `design/READER_SCREEN_DESIGNS.md`, `design/ACCOUNT_SCREEN_DESIGNS.md` | Exist, draft (pull requests #69 and #67). The frames whose look the branded prototype follows |
| Figma file "MFW app low-fi prototype (T-02.1)" | In Yuvraj Gaykhe's Figma drafts (Starter plan). YG reports that the file was shared with Sanika Attarde on 8 November 2026; the access level is not recorded. The file now also holds the design tokens and an unfinished page of reader designs (pull request #57); the low-fi page recorded here is unchanged. https://www.figma.com/design/7iQl4WKs8HoC8z5olvVzxX |

## 2. What Was Built

1. **A clickable Flutter prototype** of the app screens, greyscale, with made-up issues and articles only (DEC-024). Each screen shows its SCR-A-nn ID. A "prototype controls" sheet, which is not part of the app, switches the access state (section 3 of the inventory), loading and empty content, the network, mobile data, the news site, low storage, a damaged file, an unpublished issue, and how the next download ends.
2. **A walk-through as tests.** `test/walkthrough_test.dart` (6 tests) opens every screen from its entry point and follows the entry rule from a signed-out visitor to the reader. `test/screen_shots_test.dart` draws 24 screens and states at 1170 by 2532 pixels.
3. **A Figma copy** built as editable layers, not screenshots: 25 phone frames composed from 10 local components (icon placeholder, placeholder box, button, chip, toggle, text field, list item, app bar, navigation bar, notice banner), 9 colour variables and 7 text styles in Roboto. 25 click links join the screens and 40 join the tab bars, with two flow starting points: "Visitor opens an issue (entry rule)" and "Settings and account deletion".

**Checks on the prototype tree:** `dart format`, 0 changed; `dart analyze`, no issues; `flutter test` on Yuvraj Gaykhe's Mac (8 November 2026), 7 passed and 24 skipped without `FONT_DIR`, and all 31 passed with it. The 24 drawing tests compare each screen with its drawing committed in `test/shots/`, so they pass only where text renders the same: on Sanika Attarde's Mac the first one differs by 0.05 % of its pixels (1,372 pixels) and fails.

## 3. Walk-through Against the Inventory

### 3.1 App screens (section 5)

| SCR | Screen | In the prototype | Reached in the walk-through tests by |
|---|---|---|---|
| SCR-A-01 | Sign in | Yes | Read on an issue while signed out |
| SCR-A-02 | Register | Yes | "Create an account" on sign in |
| SCR-A-03 | Verify email | Yes | Creating an account |
| SCR-A-04 | Password reset | Yes | "Forgot your password?" on sign in |
| SCR-A-05 | Complete profile | Yes, fields PROVISIONAL (OQ-01, OQ-02) | "I have verified it" |
| SCR-A-06 | Profile | Yes | Settings, Profile |
| SCR-A-07 | Settings | Yes | The Settings tab |
| SCR-A-08 | Delete account confirmation | Yes, with the password asked again (OP-12) | Settings, Delete account |
| SCR-A-09 | Deletion pending, with undo | Not drawn: withdrawn with PRC-02 | None |
| SCR-A-10 | Home | Yes | The Home tab |
| SCR-A-11 | Catalogue, search and filters | Yes | The search action on Home |
| SCR-A-12 | Issue details | Yes | "View issue" on Home, and a notification tap |
| SCR-A-13 | Download prompt and progress | Yes: size, mobile-data warning, progress, waiting with Resume, check failed with Retry, low storage | The entry rule ends here, and a broken download resumes |
| SCR-A-14 | Reader | Yes: page-turn and swipe modes, two pages in landscape, zoom to 300%, bookmark, damaged file | "Download and read" |
| SCR-A-15 | Downloads | Yes | The Downloads tab |
| SCR-A-16, SCR-A-17 | Bookmarks, Favourites | Yes, as two tabs of one screen (SN-05 is open) | The Library tab |
| SCR-A-18 | News list | Yes | The News tab |
| SCR-A-19 | News article | Yes, with Save for offline reading | A news item on Home |
| SCR-A-20 | Notification explanation | Yes, before a stand-in for the system prompt | "Turn on notifications" in Settings |
| SCR-A-21 | Notification categories | Yes, in Settings | After the system prompt |
| SCR-A-22 | Not found | Yes | An unknown link |
| SCR-A-23 | Edition-update sign-up | Not drawn: dropped on the working position (GS-Q49), CONFLICT C-02 | None |

All 21 in-scope app screens are drawn and reached. SCR-A-16 and SCR-A-17 share one screen, as two tabs (SN-05), so the table gives them one row. The two that are not drawn are the ones the inventory itself withdraws or drops.

### 3.2 States (section 7)

| State | Where the prototype shows it | Covered by a walk-through test |
|---|---|---|
| Loading (FR-STATE-001) | Every content screen | Yes |
| Empty (FR-STATE-002) | Catalogue results, Downloads, Bookmarks, Favourites, News | Yes (Downloads) |
| No network (FR-STATE-003) | A banner on every screen, and a retry on screens that need the network | Yes |
| Low storage (FR-STATE-004) | SCR-A-13, before the download | No: prototype control only |
| News site unreachable (FR-STATE-005) | SCR-A-18, with what was loaded before | Yes |
| Download failed (FR-STATE-006) | SCR-A-13: waiting with Resume, and a check failure with Retry | Yes (waiting and Resume) |
| Damaged issue file (FR-READ-010) | SCR-A-14 | No: drawn in `test/shots/` only |
| Offline notice for articles (FR-NEWS-005) | SCR-A-19 | No: prototype control only |
| Unpublished issue (OP-CAT-02) | SCR-A-12 | Yes |
| Panel results (FR-STATE-007) and the panel's own states | Not in this prototype: the admin panel is WS-A | No |

### 3.3 The entry rule (section 3)

The walk-through test follows a signed-out visitor from Home to an issue, then Read: sign in, register, verify the email, complete the profile, the download prompt, and the reader. It checks that the access state is fullAccess before the download starts and that Read does not keep a copy (the working position of OQ-08). A Google sign-in goes straight to the profile step in the prototype; whether that applies to Google accounts is OQ-03 and OQ-04.

## 4. Design Critique

The design plugin's critique was run on the 24 rendered screens, for a low-fi stage: flow, hierarchy and states, not visual polish. Two findings were applied in `c3f2773`. The others are for the M2 designs.

| No. | Finding | Severity | Outcome |
|---|---|---|---|
| 1 | Read and Download are two buttons of near equal weight, and the difference between a temporary and a kept copy is in small print. | Moderate | For M2, once OQ-08 is answered |
| 2 | A new visitor passes four steps before the first page: sign in or register, verify, profile, download. Nothing shows how many steps are left. | Moderate | For M2: show progress through the steps. The return to the issue is already required (FR-AUTH-010) |
| 3 | The reader keeps its app bar and a caption on screen, which takes reading space, and the bookmark and mode icons have no visible labels. | Moderate | For M2: controls that hide while reading, and a labelled mode switch |
| 4 | Saving an article for offline reading used the same bookmark icon as bookmarking a page in the reader. | Minor | Applied: an offline icon |
| 5 | Cancel on a waiting download did not say that it deletes the part already downloaded. | Minor | Applied: "Cancel and delete the part downloaded" |
| 6 | Delete account sits directly under Sign out, and the confirm button has the same style as any primary action. | Minor | For M2: space them apart and give deletion its own style |
| 7 | "Create account" stays disabled until consent is ticked, without saying why. | Minor | For M2: keep it enabled and explain on tap |
| 8 | In the Flutter prototype, icon buttons are 48 by 48 points (Flutter's default); the Figma frames draw the 24 point icon only. Colour contrast was not measured, because the M2 colours set it. | For the record | OQ-25 and the M2 designs |

## 5. What This Is Not

- **Not the M2 design.** The low-fi prototype uses no MFW logo, colour, font or content. The branded one uses the website's colours and fonts (OQ-63 stays open) and no logo or content. In both, the arrangement of the tabs (an M2 decision, section 4 of the inventory) is a placeholder, and so is the wording where the code does not set it.
- **Not the app.** The low-fi prototype does not use the code under `app/`. The branded one uses only the theme, the tokens and the wording of the app's code, and none of its logic or contracts.
- **Not reviewed with MFW.** MFW approves the screens at M2 (MOD16-P2-T01, Sanika Attarde's task).
- **Not the admin panel.** The SCR-W screens are WS-A work.

## 6. Points for Other Documents

These are points for the owners of the documents to consider. This record changes none of them.

| Document | Point |
|---|---|
| `SCREEN_INVENTORY_AND_NAVIGATION.md` SN-01 | The password reset and the delete confirmation were reached without routes of their own, which fits the gap SN-01 names: they need routes or a decision that they are not deep-linkable |
| `SCREEN_INVENTORY_AND_NAVIGATION.md` SN-03, SN-05 | The prototype draws Home and the catalogue as two screens (SN-03), and bookmarks and favourites as two tabs of one screen (SN-05). Both are open, and the prototype decides neither |
| `OPEN_QUESTIONS.md` OQ-08 | Critique finding 1: the answer to OQ-08 decides whether the issue screen needs one action or two |

## 7. The Branded Prototype (9 November 2026)

The low-fi prototype, drawn on the app's theme. It is the prototype step of MOD16-P1-T05 for the app: the reader frames of MOD16-P1-T02 (#69) and the account frames of MOD16-P1-T03 (#67) combined, with the flows linked.

### 7.1 What changed

1. **Where it lives.** The code moved from `tools/spikes/prototype/` into `app/prototype/` on a spike branch, so that it can use the app's theme (`buildMfwTheme`), tokens and bundled fonts. Nothing under `app/lib/` uses it, and the branch is not merged.
2. **The look of the frames.** Section headings in the website's style, cover and picture placeholders, notices with an icon and a coloured edge, empty states with an icon and a heading, the search field with rounded ends, the reader's page bar with a slider, and the logo as a placeholder box (DEC-024). The account screens follow Sanika Attarde's frames: their fields (full name, age, gender, occupation, domain of work, still PROVISIONAL under OQ-01 and OQ-02), their wording, and settings grouped as notifications, reading, account and about.
3. **The app's wording.** The download sheet and Downloads use `DownloadsText`, and the damaged-file message uses `messageFor`, as the frames do.
4. **Screen IDs can be hidden.** A switch in the prototype controls hides the SCR-A-nn IDs, to show the screens as the designs draw them. The walk-through keeps them on.
5. **Unchanged:** every flow, the entry rule, and every state switch of section 2.

### 7.2 Walk-through and checks

The six walk-through tests of section 3 pass on the branded prototype. They now run on the frames' phone size, 390 by 844 points, and three steps tap the frames' labels: "Your profile", "New here? Create an account" and "I have verified my email".

On `797d16b` with Flutter 3.47.9, from `app/`:

- `flutter pub get --enforce-lockfile` passes with no `pubspec` change.
- `dart format` changes 0 of 119 files, and `flutter analyze` finds no issues.
- `flutter test` passes 479 tests and skips 82 (images and goldens).
- 30 screens and states pass the tap-target and label checks of the frames (the baseline proposed for OQ-25). Their images are drawn at 780 by 1688 pixels.
- The prototype ran on an iPhone 18 Pro simulator (iOS 27.2): Home drew with the bundled fonts, and "View issue" opened the issue details. It was not run on Android.

The 30 images cover SCR-A-01 to SCR-A-08, SCR-A-10 to SCR-A-20 and SCR-A-22, with the visitor views of settings and issue details. They also cover these states: no network, empty Downloads, empty search, news site unreachable, low storage, damaged file, unpublished issue, and full access needed.

### 7.3 What it does not cover

- **The admin panel screens** (MOD16-P1-T04, Sanika Attarde). MOD16-P1-T05 combines them too, so it is not complete. The admin panel itself is on `main` as code since 10 November 2026 (MOD12-P1-T01, MOD12-P2-T01, MOD12-P2-T03, MOD12-P2-T04), but its screens are not in this prototype.
- **The Figma copy** is still the low-fi one of section 2.
- **MFW's logo and content.** MFW approves the screens at M2 (MOD16-P2-T01).
- **The critique findings left for M2** in section 4, apart from one: the reader's caption line is now a page bar, as in the frames. The app bar stays on screen.
