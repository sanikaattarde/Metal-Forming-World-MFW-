# Backend spike notes 04: saveProfile (OP-10)

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`) |
| Date | 30 October 2026 |
| Task | Backend spike for T-03.6 and the server side of T-03.3 in `DEVELOPMENT_ROADMAP.md`: `saveProfile` from `API_AND_BACKEND_CONTRACT.md` section 4.2 |
| Status | Working notes. PROPOSED. Not reviewed. Every result is "emulator only". The mandatory profile is PROVISIONAL (BR-003) |
| Rests on | DEC-003 (OPEN); DEC-025 and DEC-026 (PROPOSED); the working positions on OQ-01, OQ-02, OQ-03 and OQ-27 |

## 1. What was built

`functions/src/saveProfile.ts` is a callable function, in TypeScript, and `functions/src/profile.ts` holds its checks with no database access.

The checks run in the contract's order: signed in; account active (the app's `status` and the provider's disabled flag); every value valid; accepted versions current. A segment reference is checked inside the transaction (INV-13). Then one transaction creates the account record on the first call, replaces the profile, and writes any consent record that does not exist yet. The email address is not copied.

| Refusal | When |
|---|---|
| `UNAUTHENTICATED` | No sign-in token, or a value that is not a token |
| `FAILED_PRECONDITION` `ACCOUNT_CLOSED` | Status `deleting`, or the provider has disabled or no longer has the account |
| `INVALID_ARGUMENT` with `fields` | A bad `request_id` or `profile`; a bad value; a field outside the configured set; a missing or stale `accepted_versions`; a segment that does not exist. The reply names every field and repeats no value |
| `INTERNAL` | The public configuration is missing or unusable. The call fails closed and nothing is written (SC-03) |

A profile with missing fields is not an error. It is saved and the reply names the missing fields, as the contract says.

## 2. Results

`npm --prefix backend/spike test` on 30 October 2026: **356 tests, 356 passed, 0 failed.** Emulator only.

| Group | Tests | What it shows |
|---|---|---|
| U1 Profile checks | 29 | Trim, text limit, age range, fields outside the set, missing fields, configuration that fails closed, version comparison, consent key. No database |
| G6 `saveProfile` | 37 | Through the Functions emulator with accounts from the Auth emulator: what is written on a first, partial, later and repeated call; every refusal, each also checking that nothing was written |
| G0 to G4 | 290 | Unchanged from `03-rules-notes.md` |

**Do the tests catch a broken function?** 23 deliberate breaks of the source were tried one at a time against U1 and G6, and each made at least one test fail. They include removing the sign-in check, ignoring the provider's disabled flag or the `deleting` status, accepting any versions, skipping the segment check, merging instead of replacing, rewriting a consent record or the account record on a repeat, copying the email, keeping unknown fields, and repeating the input in a refusal. One break first failed to compile, so it proved nothing. It was rewritten and then caught.

## 3. Findings

| ID | Finding | What it means |
|---|---|---|
| B-1 | **The Functions emulator does not verify a sign-in token.** A token with no signature, a token with a made-up signature and an expired token, all forged for a real account, passed sign-in. Only a value that is not a token was refused | No emulator result here shows that a forged or expired token is refused. It must be tested on a test project. The code relies on the platform's check and adds none of its own |
| B-2 | `request_id` is required but not stored. `API_AND_BACKEND_CONTRACT.md` section 2.4 says the backend remembers it and returns the earlier result. OP-10 says a repeat is harmless because the profile is replaced, and the data model has no record for it | A delayed retry of an old save can overwrite a newer one. Needs both developers: accept this for OP-10, or add a store for request identifiers |
| B-3 | No document sets a text length. `PLACEHOLDER_MAX_TEXT_LENGTH` is 200 and is not a decided value (MA-6) | Set it with the field list (OQ-01) |
| B-4 | OQ-01 says optional candidates are "switched on by configuration", but `APP_CONFIG` only has `profile_required_fields`. There is no setting for optional fields | Optional fields are not built and are refused. If MFW asks for one, a setting and a validator are needed |
| B-5 | `date_of_birth` is not built, because the working position is a whole-number age (OQ-02). A configuration that names it is refused as unusable | Changes if MFW answers OQ-02 the other way |
| B-6 | The gender options are OPEN (OQ-01), so gender is checked as text only | Changes with OQ-01 |
| B-7 | An inactive segment is accepted. The documents say a reference must exist, and do not say it must be active | Worth settling when the segment list is seeded |
| B-8 | The input and output shapes (`profile`, `accepted_versions`, `profile_status`, `missing_fields`) are spike choices, because the contract fixes none of them. `ProfileRepository.recordConsent` in `API_AND_MODULE_CONTRACTS.md` section 6.4 has no call of its own: its alias is OP-10 | To agree with Yuvraj before MOD-04's contract is written. `recordConsent` may need to go |
| B-9 | Accepting a changed policy version is not built. A later call without versions still passes after the policy changes | OQ-27 decides how consent is recorded |
| B-10 | Functions run on Node 26 under the emulator, with a warning that `package.json` asks for 22. The deploy runtime has not been tried | Re-run on the chosen runtime |
| B-11 | The emulator uses the default region, because no region is set (DEC-031 is OPEN) | Set when the region is decided |

## 4. Packages added

In `backend/spike/functions`, pinned to exact versions, with lifecycle scripts off: `firebase-functions` 7.4.0 (MIT), `firebase-admin` 14.5.0 (Apache-2.0), `typescript` 7.0.2 (Apache-2.0) and `@types/node` 22.20.5. The licences are as stated by the registry, and are not yet read from LICENSE files. `npm audit` reports 0 vulnerabilities for this folder. No `DEPENDENCY_REGISTER.md` entry is written yet.

## 5. Not tested

1. Whether a forged or expired token is refused (B-1). This is the most important item on the re-run list.
2. Two calls at the same moment. The transaction is there, but how it behaves under concurrency is NOT VERIFIED, and an emulator pass would not count.
3. Whether logs stay free of personal data in a real environment. The function logs one line, for an unusable configuration, with no value from the caller. The reply was checked; the logs were not checked by a test.
4. Rate limits (`RATE_LIMITED`, SC-18), and App Check (OQ-52).
5. A deployed function.
