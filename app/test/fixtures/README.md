# Test fixtures

Where each fixture of `Documentation/TEST_DATA_AND_FIXTURES.md` lives, and which ones are still waiting. Checked on 14 November 2026 (MOD17-P1-T01). Every value is synthetic (DEC-024): no real person, no password, no MFW content. `fixtures_load_test.dart` loads every file here and checks its IDs.

## Use

- **App tests** import the Dart files (`synthetic_pdf.dart`, `fx_issue_files.dart`, `fx_library.dart`, `../fakes/test_users.dart`) or read the JSON files through the fakes, for example `FakeCatalogueRepository.fromFixtures()`.
- **Backend tests** build their PDFs with `backend/test/pdf-fixtures.mjs` and their users in each test file, on the emulators (project `demo-mfw`).
- **MFW's sample issues** (FX-PDF-03, FX-PDF-04) are never in Git. `integration_test/reader_mfw_samples_test.dart` reads local copies, checked against the SHA-256 values in `inputs/README.md`.
- **Test credentials** are never committed. The fakes check no password, and the emulators accept any.

## Where each family is

| Family | Exists | Where | Waiting, and why |
|---|---|---|---|
| FX-USR (users) | 01 to 07, 09, 13 | `../fakes/test_users.dart`; `backend/test/g20-rule-matrix.test.mjs` | 08 (admin): no named fixture; the backend tests make their admins in `backend/test/helpers.mjs`. 10: BLOCKED by OQ-02 and OQ-07. 11: BLOCKED by OQ-05. 12: BLOCKED by OQ-43, made only in production with MFW's approval |
| FX-CAT, FX-ISS (catalogue) | CAT 01 to 04, ISS 01 to 10 | `catalogue/fx_catalogue.json`, `fx_issue_files.dart` | None |
| FX-PDF (files) | 01, 02, 10 in the app; 06 to 13 in the backend | `synthetic_pdf.dart`; `backend/test/pdf-fixtures.mjs` | 03 and 04 are MFW's, kept outside Git. 05 (near limit, about 120 pages): only its size is faked in `fx_issue_files.dart`; no generator yet, and the limit L waits for OQ-30 |
| FX-NET (network) | 06, 07 as faults in the download tests | `../features/downloads/download_fakes.dart` | 01 to 05 are device procedures (airplane mode, app killed, restart, grant expiry), run by hand in MOD17-P3; 05 also needs ENV-TEST |
| FX-LIB (library) | 01, 02 | `fx_library.dart` | 03: OQ-11 and OQ-21 |
| FX-WP (WordPress) | 01 to 12 | `wordpress/`; 10 and 11 are made in `../features/news/data/wordpress_news_repository_test.dart` | 13 (news controls) belongs to MOD09-P2-T03 |
| FX-NTF (notifications) | 01 to 08 | `notifications/fx_ntf_payloads.json` | The oversized case of 08: no size limit is defined |
| FX-ADM (admin) | 05 to 09 | `backend/test/g5-admin-gate.test.mjs`, `g8-admin-operations.test.mjs`, `g10-uploads.test.mjs`, `u10-csv.test.mjs`; `admin/test/sign-in.emulator.test.ts` | 01 to 04 (the upload form and cover rules): OQ-22, and the admin upload screen of WS-A |
