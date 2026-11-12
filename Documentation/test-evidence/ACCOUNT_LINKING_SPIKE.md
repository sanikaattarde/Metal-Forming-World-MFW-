# Account-Linking Spike: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/test-evidence/ACCOUNT_LINKING_SPIKE.md` |
| Task | MOD03-P3-T01 (AOQ-08, AOQ-09), input to OQ-04, OQ-05 and MOD03-P3-T02 |
| Status | Spike, emulator only. Google Sign-In stays PROVISIONAL (DEC-006, C-04); nothing here builds it |
| Date | 12 November 2026 |
| Run by | Sanika Attarde |
| Test | `backend/test/g21-account-linking.test.mjs` (G21, 6 cases, all passed) |

## 1. Question

What happens when one email address is used both with a password and with Google, and does the Auth service support the TD-06 rule of the OQ-04 and OQ-05 working positions: one account per email address, Google's verified-email result trusted, and Google joined to a password account only when that account's address is verified?

## 2. How

The Firebase Auth emulator, with its test Google credentials (an unsigned token naming the address and whether Google verified it). The client SDK made each sign-in, as the app's adapter would. The emulator uses the default "one account per email address" setting.

## 3. What Happened

| Case | Steps | Result on the emulator |
|---|---|---|
| A | Verified password account, then Google with the same address | Signed in to **the same account**, now with both ways in (password and Google) |
| B | Unverified password account, then Google with the same address | Signed in to the same account identifier, but **Google replaced the password**: the password no longer works |
| C | Google first, then a password sign-up with the same address | Sign-up refused, `email-already-in-use` |
| D | Signed in with a verified password, the reader links Google | Linked; Google then signs in to the same account |
| E | Google, with an address Google has not verified | New account, address **not verified** |
| F | Google, with an address Google has verified | New account, address verified |

## 4. What It Means for the App

1. **TD-06 holds for a verified password account (A, D):** one account, joined automatically. The reader keeps the same bookmarks, favourites and profile.
2. **An unverified password account is taken over by Google (B).** This protects a reader against someone who registered the reader's address first and never verified it, but anything stored on that account stays with it. In the app, little can be stored before verification: the profile step comes after the verify step (the access state's order, FR-AUTH-010), and bookmarks and favourites need full access. On the server, though, OP-10 does not check that the address is verified, so a direct call could store a profile on an unverified account, which a Google sign-in would then inherit. Recommended: OP-10 refuses a caller whose address is not verified (a small follow-up), and the privacy notice says that Google sign-in takes over an unverified account with the same address.
3. **Google first, then a password sign-up (C)** must show a message that the address is used with Google, with Google as the way in. `email-already-in-use` maps to `conflict` today ("This already exists…"); MOD03-P3-T02 should add the specific wording.
4. **OQ-04 (E, F):** Google's own verified result sets the account's verified flag, so the access state follows it with no extra step. A Google account with an unverified address goes to the verify step, as a password account does.
5. **No code change is needed for linking itself:** the identity service joins the accounts. MOD03-P3-T02 needs the sign-in button, the plugin and MFW's OAuth client in its cloud project.

## 5. Not Verified

- The real service's behaviour, which depends on the project's account-linking setting and on Google's trust in the address's domain. Repeat G21 against ENV-TEST once MOD14-P2-T03 exists.
- Sign in with Apple and App Store guideline 4.8 (OQ-06).
