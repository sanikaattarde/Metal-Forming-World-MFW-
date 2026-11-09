# Account Screen Designs: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Account Screen Designs |
| File | `Documentation/design/ACCOUNT_SCREEN_DESIGNS.md` |
| Phase | 2: Design. The designs of task MOD16-P1-T03 |
| Version | 0.1 |
| Status | Draft for review. Not reviewed. **Designs for the prototype, not the M2 designs.** The wording is PLACEHOLDER, no MFW logo is shown, they have not been shown to MFW, and they approve nothing |
| Date | 9 November 2026 |
| Prepared by | Sanika Attarde (WS-A), 9 November 2026 |
| Approval required | Both developers. MFW approves the screens at M2 (MOD16-P2-T01) |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 9 November 2026 | First version: 23 frames of SCR-A-01 to SCR-A-08, SCR-A-20 and SCR-A-21 with their states, drawn on the app's theme and tokens, with the choices made and the open points each frame waits for. Revised on 9 November 2026 after the review of pull request #67: on SCR-A-08 the filled button keeps the account and deleting has its own outlined style, and section 2 says that the images are 1x. |

### 1.1 Related documents

| Document | Status |
|---|---|
| `SCREEN_INVENTORY_AND_NAVIGATION.md` sections 5, 7 and 8 | Exists, draft. The screens, the states every screen handles, and the open points that affect them |
| `DESIGN_TOKENS.md` | Exists, draft. The colours, type, spacing and shape the frames use, and the contrast exceptions of section 5 |
| `SANIKA_IMPLEMENTATION_ROADMAP.md` MOD16-P1-T03 | Exists, a record of the plan. Steps: use the tokens, draw each screen and state, hand the frames over for the prototype |
| `test-evidence/PROTOTYPE_WALKTHROUGH_RECORD.md` | Exists, draft. The low-fi prototype of the other app screens (MOD16-P1-T05), on `spike/yg-prototype` |
| `API_AND_MODULE_CONTRACTS.md` section 4.2 | Exists, draft. The failure messages that the error frames show (`messageFor`, MOD02-P1-T01) |

## 2. How the Frames Are Made

Each frame is a Flutter widget drawn with the app's own theme (`buildMfwTheme`) and tokens (`MfwColours`, `MfwType`, `MfwSpace`), on a 390 by 844 point phone. The images are 390 by 844 pixels (1x). The widgets are in `app/test/design/account_frames.dart`. They are designs, not app screens: they hold no logic, and nothing in `app/lib/` uses them. The real screens are built in MOD03-P2 and MOD04-P2.

`app/test/design/account_frames_test.dart` checks every frame on each `flutter test`: tap targets of at least 48 by 48 on Android and 44 by 44 on iOS, and a label on every control (the baseline proposed for OQ-25, `CODING_STANDARDS.md` section 9). All 23 pass. To redraw the images in `design/account/`, run on a Mac, from `app/`:

```bash
flutter test --dart-define=MFW_DESIGN_FRAMES=true --update-goldens test/design/account_frames_test.dart
```

Text is drawn a little differently on another machine, so the images are compared only when that define is given.

## 3. The Frames

| Screen | Frames | What the frame shows | Waits for |
|---|---|---|---|
| SCR-A-01 Sign in | [default](account/a01_sign_in.png), [wrong email or password](account/a01_sign_in_error.png), [no network](account/a01_sign_in_no_network.png), [signing in](account/a01_sign_in_loading.png) | Email and password, the reset link, Google as a second button, and a link to register. A failure is a notice above the form; no network adds Retry (FR-STATE-003) | DEC-006 and OQ-29 (Google, PROVISIONAL); OQ-04, OQ-05 |
| SCR-A-02 Register | [default](account/a02_register.png), [address in use](account/a02_register_address_in_use.png) | Email and password, one consent box for the privacy policy and the terms with a link to each, and the address in use told plainly, as the inventory says | OQ-27 (how consent is recorded); OQ-05 |
| SCR-A-03 Verify email | [default](account/a03_verify_email.png), [not verified yet](account/a03_verify_email_not_yet.png) | The address the link went to, a check-again action, a resend link (PROPOSED: no requirement asks for it) and sign out | OQ-04 (Google accounts) |
| SCR-A-04 Password reset | [default](account/a04_password_reset.png), [sent](account/a04_password_reset_sent.png) | One message for a known and an unknown address (SC-21) | None |
| SCR-A-05 Complete profile | [default](account/a05_complete_profile.png), [fields to check](account/a05_complete_profile_invalid.png) | The five fields of the working position (GS-Q40): full name, age as a whole number from 1 to 120 (OQ-02), gender with "Prefer not to say", occupation and domain of work. Each wrong field says what to fix | OQ-01 (the field list and allowed values), OQ-02, OQ-03 |
| SCR-A-06 Profile | [default](account/a06_profile.png), [loading](account/a06_profile_loading.png), [could not load](account/a06_profile_error.png) | The email and the profile values, with an edit action (editing is an ASSUMPTION). Loading (FR-STATE-001) and an error with Retry | SN-01 (own screen or part of settings) |
| SCR-A-07 Settings | [signed in](account/a07_settings.png), [visitor](account/a07_settings_visitor.png) | Notifications (SCR-A-21 inside), the account items (profile, sign out, delete account), and the policy, terms and licence links. A visitor sees notifications and a sign-in item instead of the account items (GS-Q46) | OQ-09 (what a visitor sees) |
| SCR-A-08 Delete account | [confirm](account/a08_delete_confirm.png), [sign in again](account/a08_delete_reauth.png), [deleting](account/a08_deleting.png) | What is deleted, at once and for good (GS-Q50, FR-PRIV-003). Keeping the account is the filled button, and deleting has its own style: an outline in the error colour with a delete icon. When the last sign-in is not recent (`RECENT_SIGN_IN_REQUIRED`), the password is asked again (OP-12, #49); a Google reader would see a Google button there, not drawn | OQ-24 (records kept), OQ-56 (the recent sign-in window) |
| SCR-A-20 Notification explanation | [default](account/a20_notification_explanation.png) | What MFW sends, before the phone's own permission prompt, with Continue and Not now (FR-NOTIF-001) | OQ-09, OQ-18 |
| SCR-A-21 Notification categories | [default](account/a21_categories.png), [no network](account/a21_categories_error.png) | The three fixed categories of the working position (GS-Q47): new issues, expo specials, major news, each with a switch | OQ-18 (the categories), OQ-55 |

## 4. Choices Made in the Frames (PROPOSED)

1. **Messages.** A failure is a notice above the form: a red bar and an icon, with the message in the heading colour, so that colour is not the only signal and the text meets the contrast baseline (`DESIGN_TOKENS.md` section 3.2). The error frames use the `messageFor` wording of MOD02-P1-T01; a retryable failure adds Retry (CODING_STANDARDS section 6.1, rule 4).
2. **Field errors** are under the field and say what to fix.
3. **Busy states** keep the form and replace the button label with a progress indicator, so a second tap does nothing.
4. **An irreversible action** is never the filled button: on SCR-A-08 the filled button keeps the account, and deleting is an outlined button in the error colour with a delete icon and a dark label. **Links** are text buttons in the theme's red, and Google Sign-In is an outlined button below the main action, so the email path stays first while DEC-006 is PROVISIONAL.
5. **Visitors** see notification choices in settings (GS-Q46), which stays open under OQ-09.

## 5. Accessibility

- **Tap targets and labels:** every frame passes the Android, iOS and label guidelines of the Flutter test library (section 2).
- **Contrast:** the frames inherit the two exceptions recorded in `DESIGN_TOKENS.md` section 5: white button labels on the website red, and red link text on white, at 4.19 to 1 where the proposed baseline is 4.5 to 1. The Flutter contrast check finds the same two pairs in these frames. MFW decides at M2, with a darker red drawn beside the website red (OQ-25, OQ-63). The frames do not change the tokens, which are MOD16-P1-T01.
- **Text size:** the frames are drawn at the default size. The theme follows the device's text size (`DESIGN_TOKENS.md`), and the frames scroll, so larger text does not clip.

## 6. Hand-over

The frames are for Yuvraj Gaykhe's prototype (MOD16-P1-T05, ICP-09), which draws the other app screens on `spike/yg-prototype` with a Figma copy. The task is done when these frames are in the prototype and Yuvraj Gaykhe has reviewed them. The images in `design/account/` can be placed in Figma as they are, and the widgets show the spacing and type exactly. The final look waits for MFW's brand assets and logo (DEP-02, DEC-024) and the M2 approval (MOD16-P2-T01).

## 7. Open Points

| Point | Tracked in |
|---|---|
| The profile field list, the allowed values, and whether "Prefer not to say" is offered | OQ-01, OQ-02 |
| How consent is recorded: one box or two, and the version stored | OQ-27 |
| Google Sign-In and its flows | DEC-006, OQ-03 to OQ-05, OQ-29 |
| What a visitor sees in settings and before notifications | OQ-09 |
| The notification categories | OQ-18, CFG-13 |
| The contrast of the button label and red links | OQ-25, OQ-63, `DESIGN_TOKENS.md` section 5 |
| Whether the profile is its own screen or part of settings | SN-01 |
