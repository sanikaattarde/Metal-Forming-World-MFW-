# Reader Screen Designs: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Reader Screen Designs |
| File | `Documentation/design/READER_SCREEN_DESIGNS.md` |
| Phase | 2: Design. The designs of task MOD16-P1-T02 |
| Version | 0.1 |
| Status | Draft for review. Not reviewed. **Designs for the prototype, not the M2 designs.** The wording is PLACEHOLDER where the code does not set it, no MFW logo, cover, article or picture is shown, they have not been shown to MFW, and they approve nothing |
| Date | 9 November 2026 |
| Prepared by | Yuvraj Gaykhe (WS-B), 9 November 2026 |
| Approval required | Sanika Attarde reviews them (the "Done when" of MOD16-P1-T02). MFW approves the screens at M2 (MOD16-P2-T01) |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 9 November 2026 | First version: 28 frames of SCR-A-10 to SCR-A-19 and SCR-A-22 with their states, drawn on the app's theme and tokens, with the choices made and the open points each frame waits for. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `SCREEN_INVENTORY_AND_NAVIGATION.md` sections 5, 7 and 8 | Exists, draft. The screens, the states every screen handles, and the open points that affect them |
| `DESIGN_TOKENS.md` | Exists, draft. The colours, type, spacing and shape the frames use, and the contrast exceptions of section 5 |
| `YUVRAJ_IMPLEMENTATION_ROADMAP.md` MOD16-P1-T02 | Exists, a record of the plan. Draw each screen and state, with the Read and Download actions as the working position, marked pending OQ-08 |
| `design/ACCOUNT_SCREEN_DESIGNS.md` | Exists, draft. Sanika Attarde's frames of the account and settings screens (MOD16-P1-T03), made the same way |
| `test-evidence/PROTOTYPE_WALKTHROUGH_RECORD.md` | Exists, draft. The low-fi prototype these frames replace in the branded one (MOD16-P1-T05) |
| `API_AND_MODULE_CONTRACTS.md` section 4.2 | Exists, draft. The failure messages the error frames show (`messageFor`) |

## 2. How the Frames Are Made

Each frame is a Flutter widget drawn with the app's own theme (`buildMfwTheme`) and tokens, on a 390 by 844 point phone. The widgets are in `app/test/design/reader_frames.dart`. They are designs, not app screens: they hold no logic, and nothing in `app/lib/` uses them. Where the code already holds the wording, the frames use it: the failure messages of `messageFor` and the download texts of `DownloadsText` (MOD06-P2), so the designs and the app say the same thing.

The images in `design/reader/` are 780 by 1688 pixels, a 2x drawing: the test harness captures one pixel per point, so the image test draws the frame twice as large inside the captured area. `app/test/design/reader_frames_test.dart` checks every frame on each `flutter test`, at the real size: tap targets of at least 48 by 48 on Android and 44 by 44 on iOS, and a label on every control (the baseline proposed for OQ-25, `CODING_STANDARDS.md` section 9). All 28 pass. To redraw the images, run on a Mac, from `app/`:

```bash
flutter test --dart-define=MFW_DESIGN_FRAMES=true --update-goldens test/design/reader_frames_test.dart
```

The images are compared only with that define, because text is drawn differently on another machine.

## 3. The Frames

| Screen | Frames in `design/reader/` | Waits for |
|---|---|---|
| SCR-A-10 Home | `r10_home`, `r10_home_loading`, `r10_home_no_network` | Home content and whether home and catalogue are one screen (SCP-002, SN-03); the logo file (DEC-024) |
| SCR-A-11 Catalogue | `r11_catalogue`, `r11_catalogue_no_results` | Filter meanings (OQ-13); offline catalogue (OQ-10) |
| SCR-A-12 Issue details | `r12_issue_details`, `r12_issue_details_visitor` | Favourite (OQ-12); share and store link (OQ-09, OQ-15) |
| SCR-A-13 Download | `r13_download_choice`, `r13_download_mobile_data`, `r13_download_progress`, `r13_download_waiting`, `r13_download_low_storage`, `r13_download_failed` | Read and Download as the working position (GS-Q43), pending OQ-08 |
| SCR-A-14 Reader | `r14_reader`, `r14_reader_damaged` | Page-turn and swipe modes (OQ-14); the reader library (DEC-005) |
| SCR-A-15 Downloads | `r15_downloads`, `r15_downloads_failed`, `r15_downloads_empty` | After sign-out (OQ-11) |
| SCR-A-16 Bookmarks | `r16_bookmarks`, `r16_bookmarks_empty` | Offline library (OQ-10) |
| SCR-A-17 Favourites | `r17_favourites` | Who may use favourites (OQ-12); one screen with two views (SN-05) |
| SCR-A-18 News | `r18_news`, `r18_news_loading`, `r18_news_category_empty`, `r18_news_unreachable` | The categories MFW selects (CFG-04, OQ-39); breaking presentation (OQ-17) |
| SCR-A-19 Article | `r19_article`, `r19_article_offline` | The save model (OQ-16) |
| SCR-A-22 Not found | `r22_not_found` | None |

The states of `SCREEN_INVENTORY_AND_NAVIGATION.md` section 7 for these screens are all drawn: loading (home, news), empty (search results, Downloads, bookmarks, a news category), no network (home), low storage (the download), download failed (the download and Downloads) and WordPress unreachable (news). SCR-A-23 is not drawn, as the task says.

## 4. Choices Made in the Frames (PROPOSED)

1. **Five tabs:** Home, News, Library, Downloads and Settings, as in the low-fi prototype. Settings is drawn in `design/account/`.
2. **The logo is a placeholder box** in the home bar, because the file MFW supplied stays out of the repository (DEC-024).
3. **Section headings follow the website:** a small capital label in the action red with a short red rule (`BRAND_REFERENCE.md` section 6). The label is red text at 12, one of the contrast exceptions of `DESIGN_TOKENS.md` section 5.
4. **Read and Download in one sheet,** each with a line on what it does: Read opens a temporary copy, Download keeps one (GS-Q43, the working position of DEC-033, pending OQ-08).
5. **Every state carries an icon and words,** never colour alone: a red bar for an error, the warning colour for offline and "site unreachable", and an empty state with an icon, a heading, one line and an action where there is one.
6. **Breaking news is a small capital label** above the title, a placeholder until OQ-17.
7. **Search is a text field with the website's rounded ends,** not Flutter's `SearchBar`: see section 5.

## 5. Accessibility

All 28 frames pass the tap-target and label checks. Two findings came out of drawing them:

- **Flutter's `SearchBar` exposes its text field as a 302 by 17 point tap target** to accessibility, though the bar itself is 48 high. The theme of `DESIGN_TOKENS.md` section 6 styles `SearchBar`; the app should use a `TextField` with the search radius instead, as the frames do. This is a point for the catalogue task (MOD05-P2).
- **A progress bar's spoken value must be a number** (Flutter asserts it), so the frames give "42" and not "42 percent".

The contrast exceptions of `DESIGN_TOKENS.md` section 5 apply here as in the account frames: white on the action red, red links and labels, and the grey field border. MFW decides them at M2 (OQ-25, OQ-63).

## 6. Hand-over

The frames go into the branded prototype with the account frames (MOD16-P1-T05). Figma is not used: the plan's tool call limit stopped the work there, and the frames would go in as flat images in any case.

## 7. Open Points

| Point | Where it is tracked |
|---|---|
| Sanika Attarde's review, which is the "Done when" of MOD16-P1-T02 | This pull request |
| The admin panel screens, the other part of the prototype | MOD16-P1-T04 (Sanika Attarde) |
| The search field: `TextField` in place of `SearchBar` in the theme and the catalogue | MOD05-P2 |
| MFW's approval of the screens | M2 (MOD16-P2-T01) |
