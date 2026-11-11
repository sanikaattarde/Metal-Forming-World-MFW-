# MFW app

The Flutter app for Android and iOS (WS-B, `TASK_OWNERSHIP_MATRIX.md`). The identifiers are placeholders until MFW confirms the app name and store identifiers (OQ-42), so do not publish a build.

## What is here

| Folder | Holds |
|---|---|
| `lib/contracts/` | The shared contracts of `API_AND_MODULE_CONTRACTS.md` (MOD-00) |
| `lib/app/` | The app root and the theme on MFW's website colours and fonts (`DESIGN_TOKENS.md`) |
| `lib/core/` | Configuration and the HTTPS client |
| `lib/features/` | One folder for each feature module, for example `news/` and `account/` (MOD-03, MOD-04) |
| `test/` | Unit and widget tests, the fakes of the contracts and the synthetic fixtures (`TEST_DATA_AND_FIXTURES.md`) |
| `tool/` | Development scripts, not part of the app |

## Set-up

1. Install Flutter 3.47.9 with Dart 3.13.7, as pinned in `pubspec.yaml` (DEP-35, DEP-36). A later 3.47 patch release is allowed, and 3.48 needs a deliberate change to `pubspec.yaml`.
2. For iOS, install Xcode on a Mac. For Android, install the Android SDK (DEP-37). `flutter doctor` says what is missing.
3. From this folder, get the locked packages:

   ```bash
   flutter pub get --enforce-lockfile
   ```

## Checks before a pull request

The pull-request workflow (`.github/workflows/pr.yml`, QG-01 to QG-04) runs these from this folder, and they must pass on your machine first:

```bash
dart format --output=none --set-exit-if-changed .
```

```bash
flutter analyze
```

```bash
flutter test
```

The workflow also builds a debug Android APK (QG-05) and an iOS build without code signing (QG-06).

The drawing tests (goldens) are skipped unless `--dart-define=MFW_GOLDENS=true` is given, because text is drawn differently on another machine. Each such test says how to run and redraw it.

## Running the app

```bash
flutter run
```

It runs on a simulator, an emulator or a test phone. The app holds no backend address yet: no cloud project exists (`CLOUD_ACCESS_SETUP_CHECKLIST.md`), and the backend is reached through fakes in the tests only.

## Configuration

The app's non-secret settings (CFG-03, CFG-04, CFG-07 and CFG-08 of `DEPLOYMENT_PLAN.md` section 5.2) come from build-time defines, read by `AppConfig` in `lib/core/config/app_config.dart` (MOD01-P2-T04). Keep one file for each environment in `../config/`, made from `config.example.env`: for example `local.env`, `test.env` and `prod.env`. Git ignores every file there except the example.

```bash
flutter run --dart-define-from-file=../config/local.env
```

- `MFW_ENV` in the file picks the environment: `local`, `test` or `prod` (DEC-023). It is `local` when not set, except in a profile or release build, which stops at start-up unless it is set.
- A value that is empty or still `replace-me` counts as not set. ENV-LOCAL and ENV-TEST run with nothing set, and the news screens then say that news is not available.
- A `prod` build stops at start-up with `AppConfigException` if the WordPress site, its categories or either policy address is not set, or if any address is not HTTPS. The store links may stay unset until the apps are listed (OQ-15).
- The signed-build step (T-12.2, MOD18-P1-T02) must read the configuration before signing, so that a build that would stop at start-up never ships (review of pull request #64).
- Switching environment needs no code change. The Android and iOS flavours (a separate app identifier for each environment) wait for the identifiers (OQ-42) and the cloud projects (DEC-023, OQ-40).

Flutter 3.47.9 reads this `.env` format, comments included (checked on 9 November 2026). Never put a secret in these files: anything passed at build time can be read from the app.

### Firebase (CFG-01)

`FirebaseSettings` in `lib/core/config/firebase_settings.dart` reads the Firebase project from the same file: `CFG_01_BACKEND_PROJECT_ID` and the public app identifiers `FIREBASE_*` (MOD03-P2-T03). `runMfwApp` starts Firebase with them before the first frame (`lib/app/firebase_bootstrap.dart`).

- **ENV-LOCAL with no project set** runs against the backend's emulators (`npm test` style: `firebase emulators:start` in `backend/`) under the demo project `demo-mfw`, at `MFW_EMULATOR_HOST`, by default 10.0.2.2 on the Android emulator and 127.0.0.1 on iOS.
- **ENV-TEST and ENV-PROD** must set the project, the sender ID and both platforms' API key and app ID, or the app stops at start-up with `AppConfigException`. A `demo-` project or an emulator host is refused there.
- **Known limit:** the emulators speak plain HTTP, and SEC-CHK-01 keeps cleartext off on both platforms with no exception (`test/core/network/cleartext_config_test.dart`). A device or simulator therefore cannot reach them until both developers decide on a debug-only exception; until then the account flows run against fakes in the tests, and against a real project once ENV-TEST exists (OQ-40).
- **Notifications (MOD-11).** `lib/features/notifications/` holds SCR-A-20 and SCR-A-21 under Settings, at `/settings/notifications`, open to visitors (GS-Q46). The device subscribes to one push topic per chosen category, named by the category identifier as the backend sends (TD-13, PROPOSED), and to nothing else. A signed-in reader's choices are the account's records (OP-09) and follow the reader to another device; a visitor's stay in `notification_choices.json` in the app's private folder. A tapped notification opens its issue or post through the router's guard. When a session ends, by sign-out or account deletion, the device ends each subscription, unregisters from push and forgets a visitor's choices (OQ-55 working position, MOD11-P2-T04); the account's records come back at the next sign-in. Push is not set up in MFW's accounts (MOD11-P2-T01): iOS needs the push credential (CFG-10), the Push Notifications capability and the remote-notification background mode before a topic can be subscribed, so no notification has reached a real device yet.
- **Usage events (MOD02-P2-T02).** `lib/core/monitoring/usage_events.dart` records only events on `approvedUsageEvents`, which is empty until MFW answers OQ-23, so nothing is recorded in any build, whatever `CFG_11_USAGE_EVENTS_ENABLED` says. A parameter that would name a reader, an issue, a post or a page is refused even if a list ever names it (NFR-PRIV-003, PAC-09). No analytics service is connected (DEC-028). `CFG_11_*` must be `true`, `false` or unset; any other value stops the app at start-up.
- The Firebase plugins have no implementation in `flutter test`. The account logic is tested through its ports (`lib/features/account/domain/`) with fakes; the adapters are compiled and analysed only.
