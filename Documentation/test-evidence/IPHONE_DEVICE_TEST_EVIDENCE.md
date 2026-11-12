# iPhone Device Test Evidence: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/test-evidence/IPHONE_DEVICE_TEST_EVIDENCE.md` |
| Status | Draft. Every result is "device, ENV-LOCAL": no backend was reachable from the phone, and push is not set up in MFW's accounts (MOD11-P2-T01) |
| Date | 12 November 2026 |
| Tests run by | Sanika Attarde (WS-A), on her own iPhone |
| Build | `main` at `c9feac0` plus `app/integration_test/notifications_device_test.dart`; Flutter 3.47.9, Xcode 27.2 |

## 1. Set-up

- **Device:** iPhone 17 (iPhone18,3), connected by USB, Developer Mode on.
- **Signing:** a personal team and a local bundle identifier, set on the developer's Mac only. The committed project keeps its placeholder identifier.
- **How the tests ran:** `flutter test -d <id>` built, installed and launched the app, but could not attach. Flutter's USB port forward (`iproxy`) refused the connection to the Dart VM service, so DDS did not start. Each test was therefore built with `flutter build ios --profile --dart-define=MFW_ENV=local -t <test>`, installed with `xcrun devicectl device install app`, and read from `xcrun devicectl device process launch --console` with `OS_ACTIVITY_DT_MODE=enable`.
- **Seen on the way:** a profile build with no `MFW_ENV` stops at start-up with `AppConfigException: check MFW_ENV`, as MOD01-P2-T04 requires of a build that is not a debug build.

## 2. Results

| Test file | Tests | Result | What it shows |
|---|---|---|---|
| `notifications_device_test.dart` (MOD11-P2-T02, MOD11-P2-T04, MOD02-P2-T01, MOD02-P2-T02) | 4 | Passed | The app starts and shows the tab bar. Settings has the Notifications entry. SCR-A-20 is shown before any system prompt; after it, the iOS prompt appeared and the tester allowed it (permission went from not determined to granted). SCR-A-21 showed "No notification categories are available", because the categories come from a backend the phone cannot reach. The choices file is written and read back in the app's own container. CFG-11 is off: no crash report is sent and no usage event is collected |
| `notifications_device_test.dart`, the push adapter | (in the 4) | Passed | With no push credential, subscribing and unsubscribing end with `PushError(apns-token-not-set)` and unregistering with `PushError(invalid-request)`. No call hangs or crashes the app |
| `download_adapters_test.dart` (MOD06-P2-T02, MOD06-P2-T03) | 4 | Passed | The private folder and free space; a copy kept across a restart and deleted; a cut connection resumed with a byte range; a file with the wrong hash never kept |
| `ic03_offline_opening_test.dart` (IC-03) | 1 | Passed | A downloaded issue opens in full in the reader with the network gone |
| `reader_pdfrx_test.dart` (MOD07-P2-T01) | 5 | Passed | FX-PDF-01 and FX-PDF-02 open with their pages; the truncated FX-PDF-10 is `fileCorrupt`; a missing file is `notFound`; SCR-A-14 turns pages with the buttons and a swipe |

14 tests, all passed.

## 3. Not run, and why

- **Push delivery (AC-9.1 to AC-9.7 on a device):** needs MFW's Apple push credential and a Firebase project (MOD11-P2-T01, OQ-40). A personal team cannot enable Push Notifications.
- **`library_rules_test.dart` and `ic07_catalogue_publication_test.dart`:** they need the backend emulators reachable from the phone, which SEC-CHK-01's cleartext ban and the emulators' local-only address prevent.
- **OQ-55 (whether unregistering alone ends topic subscriptions):** cannot be observed without push; the app ends each subscription itself, so it does not rely on the answer.
- **A forced crash reaching MFW's crash service:** no service is connected (DEC-028, C-07).
