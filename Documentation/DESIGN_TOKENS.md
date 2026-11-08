# Design Tokens: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Design Tokens |
| File | `Documentation/DESIGN_TOKENS.md` |
| Phase | 3: Development Planning and Collaboration. The token set of MOD16-P1-T01 and the theme of MOD01-P2-T02 |
| Version | 0.1 |
| Status | Draft for review. Not reviewed. **PROPOSED, on the working position of 8 November 2026 that the website's colours and fonts are used in the app as they are (reported by YG, not filed).** OQ-63 stays OPEN for MFW's written confirmation, and OQ-25 for the contrast baseline. The state colours of section 3.2 and the spacing of section 7 are the team's proposals. MFW sees the look at M2 |
| Date | 8 November 2026 |
| Prepared by | Yuvraj Gaykhe (WS-B), 8 November 2026 |
| Approval required | Sanika Attarde confirms that the account, settings, notification and admin screens can be drawn with this set (the acceptance of MOD16-P1-T01). MFW approves the look with the screens at M2 |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 8 November 2026 | First version: the colour, type, spacing and shape tokens taken from `BRAND_REFERENCE.md` sections 4.3, 5 and 6, the proposed state colours, the contrast check of every pair the theme draws, the mapping onto the Flutter theme, and the three bundled typefaces with their licences. Section 2 also says where the set is in Figma, and that the reader screen designs there are not finished. Revised on 8 November 2026: section 2 and section 9 record that YG shared the Figma file with Sanika Attarde. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `BRAND_REFERENCE.md` sections 4 to 6 | Exists, draft. The website values these tokens take, as they are |
| `YUVRAJ_IMPLEMENTATION_ROADMAP.md` MOD16-P1-T01, MOD01-P2-T02 | Exists, a record of the plan. The token set and the theme |
| `CODING_STANDARDS.md` section 9 | Exists, draft. The proposed accessibility values: 4.5 to 1 for text, 48 by 48 touch targets, no information by colour alone |
| `OPEN_QUESTIONS.md` OQ-25, OQ-63 | Exist, draft. The accessibility baseline, and MFW's confirmation of the brand values |
| `DEPENDENCY_REGISTER.md` DEP-78 | Exists, draft. The three typefaces and their licences |
| `SCREEN_INVENTORY_AND_NAVIGATION.md` | Exists, draft. The screens the tokens are drawn on (MOD16-P1-T02 to MOD16-P1-T04) |

## 2. Purpose, Scope and Status

One set of colours, type, spacing and shapes that both developers draw with, in Figma and in the app. The code is the reference: `app/lib/app/theme/mfw_tokens.dart` holds the values, `app/lib/app/theme/mfw_theme.dart` turns them into the Flutter theme, and the tests in `app/test/app/theme/` check them against this document.

In Figma, the file "MFW app low-fi prototype (T-02.1)" in Yuvraj Gaykhe's drafts holds the same set since 8 November 2026: the variable collection "MFW tokens" (12 colour and 11 number variables, one mode, each described with its Dart name) and 12 text styles named "MFW/…". One difference: Figma offers no Fraunces Medium, so the "MFW/H5" style uses Fraunces Regular where the app uses weight 500. YG reports that the file was shared with Sanika Attarde on 8 November 2026; the access level is not recorded. The reader screen designs on these tokens (MOD16-P1-T02) are not finished: a page "Reader designs (MOD16-P1-T02)" holds copies of the low-fi reader screens that are not yet restyled, because the Figma plan's tool call limit stopped the work.

Rules:

1. A token takes a value from `BRAND_REFERENCE.md` sections 4.3, 5 or 6, or is marked PROPOSED here. No other colour or font is added (`BRAND_REFERENCE.md` section 8).
2. The logo is not a token. It is used only from the file MFW supplied, which stays out of the repository (DEC-024), so the app shows no logo yet.
3. The logo blue stays inside the logo. The website's grey meta text `#ADADAD` is not a token, because it reaches 2.24 to 1 on white (`BRAND_REFERENCE.md` section 4.4).
4. The app is light only. The website has no dark scheme, and none is proposed.

## 3. Colour Tokens

### 3.1 Website colours, as they are

| Token | Value | Role | Source |
|---|---|---|---|
| `action` | `#F0233B` | Filled buttons, the selected tab, links, the progress bar | Website buttons |
| `actionPressed` | `#161616` | A button or link when pressed, focused or hovered; a selected filter chip; the message bar | Website button hover |
| `onAction` | `#FFFFFF` | Labels on `action` and `actionPressed` | Website button label |
| `heading` | `#282828` | Headings, typed input text, error messages | Website `h1` to `h5` |
| `body` | `#48586A` | Body text, hints, small text, icons | Website body text |
| `surface` | `#FFFFFF` | Page ground, cards, bars, dialogs | Website page ground |
| `inputFill` | `#F5F7F8` | Input fields, the search field, unselected chips | Website input fields |
| `divider` | `#DCDCDE` | Dividers, field and card borders | Website border |

### 3.2 State colours (PROPOSED)

The website gives no state colours. Each one below is a colour the website's kit already defines (`BRAND_REFERENCE.md` section 4.2), as section 8 of that document asks.

| Token | Value | Kit ID | How it is used |
|---|---|---|---|
| `error` | `#F0233B` | `d49ac81` | Borders and icons only. The message itself is in `heading`, because the red reaches 4.19 to 1 on white |
| `success` | `#3DD800` | `e4f358e` | A fill behind `onStatus` text and icon. Never as text or an icon on white (1.91 to 1) |
| `warning` | `#FFAE25` | `b3919de` | A fill behind `onStatus` text and icon. Never as text or an icon on white (1.85 to 1) |
| `onStatus` | `#161616` | `332724a` | Text and icons on `success` and `warning` |

Every state also carries an icon and words, so that no state is shown by colour alone (`CODING_STANDARDS.md` section 9). The error colour is the same red as `action`, because the kit has no other red; the icon and the words tell them apart.

## 4. Type Tokens

The phone column of the website's type scale (`BRAND_REFERENCE.md` section 5.2), in logical pixels. The device text size applies on top (OQ-25), and the theme sets no limit on it.

| Token | Family | Weight | Size | Line height | Letter spacing | Colour |
|---|---|---|---|---|---|---|
| `display` | Fraunces | 600 | 32 | 1.0 | minus 2 | `heading` |
| `h1` | Fraunces | 600 | 30 | 1.3 | minus 1.5 | `heading` |
| `h2` | Fraunces | 600 | 24 | 1.3 | minus 0.5 | `heading` |
| `h3` | Fraunces | 600 | 20 | 1.3 | minus 0.5 | `heading` |
| `h4` | Fraunces | 400 | 18 | 1.3 | Not set | `heading` |
| `h5` | Fraunces | 500 | 15 | 1.4 | Not set | `heading` |
| `label` | Plus Jakarta Sans | 600 | 12 | Not set | Not set | `action`, set in capitals by the widget |
| `body` | Inter | 400 | 14 | 1.4 | Not set | `body` |
| `input` | Inter | 400 | 12 | 1.4 | Not set | `heading` |
| `formLabel` | Fraunces | 600 | 14 | 1.5 | Not set | `body` |
| `button` | Fraunces | 400 | 13 | 1.0 | Not set | `onAction` |
| `small` | Inter | 400 | 11 | 1.5 | Not set | `body` (the kit sets none) |

The bundled files are variable fonts, so each style sets the weight axis as well as the weight. Fraunces also sets its optical size axis to the font size, as a browser does on the website. A probe on 8 November 2026 with Flutter 3.47.9 showed that the weight alone already moves the weight axis and that no synthetic bold is added; the explicit axis values are kept so the result does not depend on that.

## 5. Contrast Check

Every pair the theme draws, computed with the formula of the Web Content Accessibility Guidelines 2.x. The test `app/test/app/theme/contrast_test.dart` holds the same pairs and ratios, and fails if a token changes without this table. The proposed baseline is 4.5 to 1 for text and 3 to 1 for the parts of a control (`CODING_STANDARDS.md` section 9, OQ-25).

| Pair | Foreground on background | Ratio | Needs | Result |
|---|---|---|---|---|
| Body text | `#48586A` on `#FFFFFF` | 7.29 | 4.5 | Meets |
| Headings | `#282828` on `#FFFFFF` | 14.74 | 4.5 | Meets |
| Typed input text | `#282828` on `#F5F7F8` | 13.72 | 4.5 | Meets |
| Hint text | `#48586A` on `#F5F7F8` | 6.79 | 4.5 | Meets |
| Pressed button label, message bar | `#FFFFFF` on `#161616` | 18.10 | 4.5 | Meets |
| Status text on success | `#161616` on `#3DD800` | 9.50 | 4.5 | Meets |
| Status text on warning | `#161616` on `#FFAE25` | 9.77 | 4.5 | Meets |
| Focused field border | `#161616` on `#F5F7F8` | 16.84 | 3 | Meets |
| Error border, selected tab icon | `#F0233B` on `#FFFFFF` | 4.19 | 3 | Meets |
| **Button label** | `#FFFFFF` on `#F0233B` | 4.19 | 4.5 | **Does not meet** |
| **Red links, tab labels, small labels** | `#F0233B` on `#FFFFFF` | 4.19 | 4.5 | **Does not meet** |
| **Field border** | `#DCDCDE` on `#FFFFFF` | 1.37 | 3 | **Does not meet** |

The three exceptions are the website's own colours, used as they are on the working position. They are recorded for MFW's decision under OQ-25 and OQ-63, and not changed here, because changing them would add colours MFW has not given. What could follow from that decision, and is not done: larger or bolder button labels (large text needs 3 to 1 only), `actionPressed` for buttons, or a darker field border.

## 6. The Flutter Theme

`buildMfwTheme()` in `app/lib/app/theme/mfw_theme.dart` (MOD01-P2-T02) uses only the tokens above. Material 3, light.

| Theme part | Tokens |
|---|---|
| Colour scheme | primary `action`, secondary `actionPressed`, surface `surface`, on surface `heading`, on surface variant `body`, error `error`, outline `divider`; the highest container is `inputFill` and the other containers are `surface` |
| Text theme | display `display`; headline large to small `h1` to `h3`; title large to small `h4`, `h5`, `formLabel`; body large `input` (Material draws text fields with it), body medium `body`, body small `small`; label large `button`, label medium `label`, label small `small` |
| Filled and elevated buttons | `action` fill with a 1 pixel border in the same colour, `actionPressed` when pressed, focused or hovered, square corners, at least 48 pixels tall |
| Outlined and text buttons | `action` label and outline, `actionPressed` when pressed, focused or hovered |
| Input fields | `inputFill`, a 1 pixel `divider` border, `actionPressed` when focused, an `error` border with the message in `heading` |
| Search field | `inputFill` with rounded ends (radius 30), at least 48 pixels tall |
| Navigation bar | `surface`; the selected tab in `action` with a grey `inputFill` block behind the icon, so the selection is not shown by colour alone |
| Filter chips | `inputFill` with `heading` text; when selected, `actionPressed` with `onAction` text |
| List tiles | title `h5`, subtitle `body`, at least 48 pixels tall |
| Message bar, dialogs, sheets, cards | Square corners; the message bar is `actionPressed` with `onAction` text |

The token specimen `app/test/app/theme/goldens/token_specimen.png` draws every token with the bundled fonts. It is checked on a Mac with `flutter test --dart-define=MFW_GOLDENS=true test/app/theme/token_specimen_test.dart`, and skipped in the pull-request checks, because text is drawn differently on the Linux runner.

## 7. Spacing and Shape

| Token | Value | Source |
|---|---|---|
| Spacing `xs`, `sm`, `md`, `lg`, `xl`, `xxl`, `xxxl` | 4, 8, 12, 16, 24, 32, 48 | PROPOSED: a 4 pixel step, because the website records no spacing scale. `lg` (16) is the page margin on a phone |
| `radius` | 0 | Website buttons and fields have square corners (`BRAND_REFERENCE.md` section 6) |
| `searchRadius` | 30 | The website's search field |
| `stroke` | 1 | The 1 pixel border of the website's buttons |
| `minTouchTarget` | 48 | `CODING_STANDARDS.md` section 9, proposed under OQ-25 |

## 8. The Bundled Typefaces

The upright variable font of each family, from the Google Fonts repository at commit `86aced91de05cd4f96a06838124cca45be337b2b`, downloaded on 8 November 2026 with YG's approval. Italics are not bundled, because the type scale uses none. Each licence file ships beside its font and is shown on the app's licence page (`app/lib/app/theme/font_licences.dart`).

| Family | File in `app/assets/fonts/` | Size in bytes | SHA-256 | Axes | Licence |
|---|---|---|---|---|---|
| Fraunces | `fraunces/Fraunces-Variable.ttf` | 360,440 | `177ff6c0f14e5550a3c624247cd1189611d4eb65d000b14944c63d967958abbb` | optical size 9 to 144, weight 100 to 900 (900 by default), softness, wonky | SIL Open Font License 1.1, Copyright 2018 The Fraunces Project Authors (`fraunces/OFL.txt`, SHA-256 `bdf4c228…`) |
| Inter | `inter/Inter-Variable.ttf` | 876,576 | `29160a80ff49ddcab2c97711247e08b1fab27a484a329ce8b813d820dc559031` | optical size 14 to 32, weight 100 to 900 | SIL Open Font License 1.1, Copyright 2020 The Inter Project Authors (`inter/OFL.txt`, SHA-256 `5b9321a4…`) |
| Plus Jakarta Sans | `plus_jakarta_sans/PlusJakartaSans-Variable.ttf` | 176,288 | `89b3fb38aa0d275d7a731d0d817a4f1622b316b4d7fbdedcf02ee9099ff68bc8` | weight 200 to 800 | SIL Open Font License 1.1, Copyright 2020 The Plus Jakarta Sans Project Authors (`plus_jakarta_sans/OFL.txt`, SHA-256 `995c7199…`) |

The licence lets the fonts be bundled with software if each copy carries the copyright notice and the licence (condition 2), and forbids selling the fonts by themselves (condition 1). The licence files were read by the development assistant (DEP-41) on 8 November 2026 at YG's request; a developer has not read them yet (`DEPENDENCY_REGISTER.md` DEP-78).

## 9. Open Points

| Point | Where it is tracked |
|---|---|
| MFW's written confirmation of the website values, and of the state colours at M2 | OQ-63 |
| The three contrast exceptions of section 5 | OQ-25, OQ-63 |
| Sanika Attarde's confirmation that the WS-A screens can be drawn with this set; the Figma file is shared with Sanika Attarde | MOD16-P1-T01 acceptance |
| The reader screen designs on these tokens, unfinished in Figma | MOD16-P1-T02 |
| How the logo enters the app while the file stays out of the repository | DEC-024, DEP-02 |
| A developer's reading of the three licence files | DEP-78 |
