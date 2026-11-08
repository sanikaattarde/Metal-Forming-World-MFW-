# Brand Reference: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Brand Reference |
| File | `Documentation/BRAND_REFERENCE.md` |
| Phase | 3: Development Planning and Collaboration. The reference for the design tokens (MOD16-P1-T01), the app theme (MOD01-P2-T02) and the M2 designs of the app and the admin panel |
| Version | 0.1 |
| Status | Draft for review. Not reviewed. **OBSERVED, and the working position for the app: used as they are (reported by YG on 8 November 2026, not filed).** The values below were read from MFW's public website on 8 November 2026. They are not confirmed by MFW in writing, so OQ-63 stays OPEN. DEP-02 is RECEIVED by reference to the website. |
| Date | 8 November 2026 |
| Prepared by | Yuvraj Gaykhe (WS-B), 8 November 2026 |
| Approval required | Both developers, for its use in the designs. MFW confirms the values in writing (OQ-63) and approves the screens at M2 |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 8 November 2026 | First record: MFW's direction as reported on 8 November 2026, the colours, fonts, type scale and page patterns read from the public website and its web logo, the contrast of the colour pairs, and what was not inspected. It also records YG's report of the same day that the website's colours and fonts are used in the app as they are, as the working position of section 4.3. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `REQUIREMENTS_SPECIFICATION.md` NFR-UX-001, NFR-UX-004 | Exists, draft. The interface uses MFW's logo, colours and fonts. The accessibility baseline is OQ-25 |
| `DEPENDENCY_REGISTER.md` DEP-02, DEP-78 | Exists, draft. The brand input, and the typefaces seen on the website |
| `OPEN_QUESTIONS.md` OQ-63, OQ-25 | Exists, draft. MFW's confirmation of these values, and the contrast baseline |
| `YUVRAJ_IMPLEMENTATION_ROADMAP.md` MOD16-P1-T01, MOD01-P2-T02, MOD16-P1-T02 | Exists, a record of the plan. The tasks that draw on this reference |
| `SCREEN_INVENTORY_AND_NAVIGATION.md` section 2 | Exists, draft. Colours, fonts and layout belong to the M2 designs on MFW's brand assets |
| `inputs/README.md` | Exists. The logo file and the three issues MFW supplied, kept outside Git (DEC-024), and the website link |

## 2. MFW's Direction, Reported on 8 November 2026

Reported by YG on 8 November 2026, not filed: MFW confirmed that the app and the admin panel use the same colours and fonts as its official website, https://metalformingworld.com, together with the visual identity of the magazine issues and the logo it supplied. No new colour palette or type system is to be introduced.

MFW gave no colour values, font names or font files. The channel and the sender's role are not recorded. So the direction is received, and the values are not: this document reads them from the website, and MFW confirms them (OQ-63).

**Update of 8 November 2026.** YG reports, not filed, that the website's colours and fonts are used in the app as they are. The colours and fonts are therefore received by reference to the website (DEP-02), and section 4.3 is the working position. OQ-63 stays OPEN until MFW's written confirmation is filed.

## 3. How the Values Were Read

On 8 November 2026, at YG's request, an automated reading in a browser opened the public home page and one news article. It read the theme's global stylesheet, `/wp-content/uploads/elementor/css/post-23.css` (the site's Elementor "kit", which holds the global colours and the global type settings), measured the styles of the rendered elements, and counted the colours of the web logo, `/wp-content/uploads/2026/03/Logo-for-web.png` (485 by 125 pixels). No file from the site is stored in the repository. A developer has not checked the values by eye.

The site names WordPress 7.1.4, Elementor 4.3.6 and the Hello Elementor theme 3.4.7. The values are a snapshot of 8 November 2026: MFW can change them whenever it edits the site.

## 4. Colours

### 4.1 The web logo

Share of the logo's opaque pixels, by exact value. The other values are the blended edges of the lettering.

| Colour | Value | Share | Where it appears |
|---|---|---|---|
| Red | `#ED1C24` | 43 % | The block that carries the words "METAL FORMING" in white |
| White | `#FFFFFF` | 35 % | The lettering on the red block, and the ground |
| Blue | `#014EA2` | 13 % | The word "WORLD" |
| Near black | `#231F20` | under 1 % | The line of small text beside "WORLD" |

The red of the logo (`#ED1C24`) and the red of the website's buttons (`#F0233B`, section 4.2) are close but not the same value. The blue of the logo is not used anywhere else on the pages read. Both points are for MFW (OQ-63). The working position of section 4.3 follows the website: its red for actions, and both logo colours only inside the logo.

### 4.2 The website's global colours

The Elementor kit defines 17 global colours. Four have names in the kit; the others have only internal IDs, given here so they can be found again. "Not seen" means defined in the kit and not found on the two pages read.

| Kit name or ID | Value | Seen on the pages read |
|---|---|---|
| Primary | `#48586A` | Body text and links: most of the text on the site |
| Secondary | `#282828` | Headings `h1` to `h5`, the menu items, the text in input fields |
| Text | `#FFFFFF` | Button labels, and text on dark or red grounds |
| Accent | `#FFFFFF2B` (white at about 17 % opacity) | Not seen |
| `d49ac81` | `#F0233B` | Buttons ("Subscribe"), the active menu item, link hover, `h6` labels, the round social media buttons |
| `332724a` | `#161616` | Button hover and focus, and one form button |
| `4d462f5` | `#DCDCDE` | One border |
| `cfa1f76` | `#F5F7F8` | The fill and the border of input fields |
| `291baba` | `#FAFBFC` | Not seen |
| `c94d9ab` | `#161616` | Same value as `332724a` |
| `a228420` | `#3A3A3A` | Not seen |
| `044b931` | `#282828` | Same value as Secondary |
| `638d055` | `#0F1012` | Not seen |
| `a2c0d56` | `#FF3385` | The border of a focused input field |
| `4ca25af` | `#BDDC00` | Small uppercase labels on dark grounds ("Your Ads", "Subscribe today!") |
| `e4f358e` | `#3DD800` | Not seen |
| `b3919de` | `#FFAE25` | Not seen |

One value outside the kit is in use: `#ADADAD`, for the date and the comment count under each item of the home page news list (Inter, 12 px). The page ground is white, `#FFFFFF`.

### 4.3 Roles for the app and the admin panel (working position)

The map MOD16-P1-T01 starts from. It uses only values from sections 4.1 and 4.2, and adds none. Working position of 8 November 2026 (reported by YG, not filed; Sanika Attarde's written agreement not filed): the website's values are used as they are. OQ-63 stays OPEN for MFW's written confirmation.

| Role | Value | Taken from |
|---|---|---|
| Logo | The file MFW supplied (DEP-02), never redrawn or recoloured | `inputs/README.md` |
| Main action (filled buttons, the selected tab, links when pressed) | `#F0233B` | Website buttons |
| Pressed or focused action | `#161616` | Website button hover |
| Headings | `#282828` | Website `h1` to `h5` |
| Body text | `#48586A` | Website body text |
| Surface | `#FFFFFF` | Website page ground |
| Input fill | `#F5F7F8` | Website input fields |
| Divider | `#DCDCDE` | Website border |
| Error, success and warning states | **No website value.** The team proposes them in MOD16-P1-T01, preferring colours the website's kit already defines, and MFW sees them at M2. None is set here | OQ-63 |
| Second brand colour outside the logo | **None.** The logo blue `#014EA2` stays inside the logo, because the website's interface does not use it | Working position; OQ-63 |

### 4.4 Contrast

Contrast ratios computed from the values above with the formula of the Web Content Accessibility Guidelines 2.x. The proposed baseline of OQ-25 asks for enough contrast and sets no level; the two levels shown are the usual AA levels (4.5 to 1 for normal text, 3 to 1 for large text and for the parts of a control).

| Text or part | On | Ratio | 4.5 to 1 | 3 to 1 |
|---|---|---|---|---|
| `#48586A` body text | `#FFFFFF` | 7.29 | Meets | Meets |
| `#282828` headings | `#FFFFFF` | 14.74 | Meets | Meets |
| `#282828` input text | `#F5F7F8` | 13.72 | Meets | Meets |
| `#FFFFFF` button label | `#F0233B` | 4.19 | **Does not meet** | Meets |
| `#FFFFFF` on the logo red | `#ED1C24` | 4.38 | **Does not meet** | Meets |
| `#F0233B` text or link | `#FFFFFF` | 4.19 | **Does not meet** | Meets |
| `#FFFFFF` button label | `#161616` | 18.10 | Meets | Meets |
| `#ADADAD` date and count | `#FFFFFF` | 2.24 | **Does not meet** | **Does not meet** |
| `#BDDC00` label | `#161616` | 11.55 | Meets | Meets |
| `#BDDC00` label | `#FFFFFF` | 1.57 | **Does not meet** | **Does not meet** |
| `#014EA2` logo blue | `#FFFFFF` | 8.04 | Meets | Meets |

What follows from it, for OQ-25 and the M2 designs, and not decided here: white labels on the website red meet only the large-text level, and the website sets its button labels at 13 to 15 px. Grey `#ADADAD` meta text does not meet either level. Using the website's colours as they are, and meeting a contrast baseline, can pull in different directions. MFW decides (OQ-25, OQ-63).

## 5. Typography

### 5.1 Families

The website loads three families from Google Fonts, every weight from 100 to 900 with italics, with the "swap" display setting.

| Family | Kind | Role on the website | Weights seen in use |
|---|---|---|---|
| Fraunces | Serif | Headings `h1` to `h5`, the menu, buttons, form labels | 400, 500, 600 |
| Inter | Sans serif | Body text, input fields, dates and other small text | 400 |
| Plus Jakarta Sans | Sans serif | `h6`: small uppercase labels | 600 |

The licences of the three families are NOT VERIFIED. A developer reads each family's own licence file before any font file goes into the app or the admin panel (`DEPENDENCY_REGISTER.md` DEP-78, section 2 verification rule).

### 5.2 Type scale

The kit's global type settings. Sizes are in CSS pixels for the desktop, the tablet (up to 1024 px wide) and the phone (up to 767 px wide). Line height is a multiple of the size.

| Element | Family | Weight | Size: desktop, tablet, phone | Line height | Letter spacing | Other |
|---|---|---|---|---|---|---|
| `h1` | Fraunces | 600 | 48, 31, 30 | 1.3 | minus 1.5 px | Colour `#282828` |
| `h2` | Fraunces | 600 | 39, 25, 24 | 1.3 | minus 0.5 px | Colour `#282828` |
| `h3` | Fraunces | 600 | 31, 21, 20 | 1.3 | minus 0.5 px | Colour `#282828` |
| `h4` | Fraunces | 400 | 25, 18, 18 | 1.3 | Not set | Colour `#282828` |
| `h5` | Fraunces | 500 | 18, 15, 15 | 1.4 | Not set | Colour `#282828` |
| `h6` | Plus Jakarta Sans | 600 | 14, 13, 12 | Not set | Not set | Uppercase, colour `#F0233B` |
| Body text | Inter | 400 | 16, 15, 14 | 1.4 | Not set | Colour `#48586A` |
| Input text | Inter | 400 | 14, 13, 12 | 1.4 | Not set | Colour `#282828` |
| Form label | Fraunces | 600 | 16, 15, 14 | 1.5 | Not set | Colour `#48586A` |
| Button | Fraunces | 400 | 15, 14, 13 | 1.0 | Not set | White on `#F0233B` |
| Small text (kit ID `112b6c4`) | Inter | 400 | 13, 12, 11 | 1.5 | Not set | |
| Display (kit ID `a435f28`) | Fraunces | 600 | 61, 37, 32 | 1.0 | minus 2 px | |

Pages can override the kit. The article title read on 8 November 2026 measured 36 px with letter spacing of minus 1.9 px in an 800 px wide window, which is not a kit value. So the kit is the base scale, and single widgets may differ.

For the app, the phone column is the natural start, because Flutter sizes are logical pixels. The device text size setting (OQ-25) applies on top. The mapping is MOD16-P1-T01's work and is not set here.

## 6. Page Patterns Seen

Recorded so the designs can follow the same identity. None is a requirement.

- **Header.** The logo centred on white. A red "Subscribe" button on one side and four round red social media buttons on the other. A horizontal menu below in Fraunces 600, with the active item in red.
- **Buttons and fields.** Square corners (radius 0) and a 1 px border in the button's own colour. Buttons turn `#161616` on hover. Input fields are filled `#F5F7F8`. The search field has rounded ends (radius 30 px), set on that widget.
- **News lists.** A picture on the left, the title in Fraunces (typed in capitals by the editor in several posts), the date and comment count in small grey Inter, and a "Read More »" link.
- **Article page.** A breadcrumb (Home, Industry News), the title, a line with the author name, the date and a reading time, a full-width picture, then the body in Inter.
- **Section headings.** A short red rule under a heading such as "Latest News".
- **Width.** Content up to 1280 px wide on the desktop, with breakpoints at 1024 px and 767 px.
- **Website-only features.** Advertising slots and a pop-up advert for a trade event on first load. No requirement asks for these in the app.

## 7. What Was Not Inspected

| Source | Why | What is needed |
|---|---|---|
| The three magazine issues MFW supplied (`inputs/README.md`) | They are MFW's confidential sample PDFs (DEC-024). The team keeps them out of automated reading, so no tool opened them for this record | A developer looks at the covers and inside pages by eye and adds only colour and font observations here, with no image of a page (DEC-024). Or MFW names the fonts and colours of the magazine. Colours read from a print file are approximate on a screen |
| The logo file MFW supplied (`inputs/brand/`) | It is kept with MFW's inputs outside Git and was not opened. Section 4.1 reads the public web logo instead | A developer compares the supplied file with the web logo. MFW confirms the logo colours (OQ-63) |
| Website pages other than the home page and one article | The global colours and type settings apply to the whole site | Nothing, unless a design needs a pattern from another page |
| The website's settings behind the sign-in | No credentials were given, and none are needed | MFW's written confirmation (OQ-63) |

## 8. How the Designs Use This Reference

1. MOD16-P1-T01 draws its tokens from sections 4.3 and 5 only, on the working position that the website's values are used as they are. It adds no other colour or font. A role with no website value (error, success, warning) is the team's proposal, preferring colours the website's kit already defines, and MFW sees it at M2.
2. The admin panel uses the same tokens. Its screens are WS-A work, and Sanika Attarde updates the WS-A plans.
3. The logo is used only from the file MFW supplied, never redrawn.
4. The low-fi prototype of T-02.1 (pull request #53) stays greyscale. This reference does not change it.
5. MFW approves the look when it approves the screens at M2. This document approves nothing.

## 9. Open Points

| Point | Where it is tracked |
|---|---|
| MFW's written confirmation of sections 4 and 5. YG reports that they are used as they are, and section 4.3 follows that. The colours for error, success and warning states are the team's proposal, seen by MFW at M2 | OQ-63 |
| The contrast of white on the website red, and of the grey meta text | OQ-25 |
| The licences of Fraunces, Inter and Plus Jakarta Sans for use in the app and the admin panel | DEP-78 |
| The magazine's identity, read by eye and with no page image | Section 7; DEC-024 |
