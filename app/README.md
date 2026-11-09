# MFW app

The Flutter app for Android and iOS (WS-B, `TASK_OWNERSHIP_MATRIX.md`). The identifiers are placeholders until MFW confirms the app name and store identifiers (OQ-42), so do not publish a build.

## What is here

| Folder | Holds |
|---|---|
| `lib/contracts/` | The shared contracts of `API_AND_MODULE_CONTRACTS.md` (MOD-00) |
| `lib/app/` | The app root and the theme on MFW's website colours and fonts (`DESIGN_TOKENS.md`) |
| `lib/core/` | Configuration and the HTTPS client |
| `lib/features/` | One folder for each feature module, for example `news/` |
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

Build-time values come from a file made from `../config/config.example.env`, passed with `--dart-define-from-file`, for example:

```bash
flutter run --dart-define-from-file=../config/local.env
```

Flutter 3.47.9 reads that `.env` format, comments included (checked on 9 November 2026). No code reads a CFG value this way yet. Never put a secret in that file: anything passed at build time can be read from the app.
