# Scaffold Run Evidence: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Scaffold Run Evidence |
| File | `Documentation/test-evidence/SCAFFOLD_RUN_EVIDENCE.md` |
| Phase | 4: Testing, Release and Risk Management. A test evidence report (`TESTING_STRATEGY.md` §13) |
| Version | 0.1 |
| Status | Draft for review. **Simulator and emulator only, debug builds.** No physical phone was used (OQ-26). It is the record of the T-01.1 exit check, and it approves nothing. |
| Date | 8 November 2026 |
| Tests run by | Yuvraj Gaykhe (WS-B), 7 November 2026 |
| Approval required | Both developers |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 8 November 2026 | First report: the T-01.1 run on `main` at `5a77910`, first posted as a comment on pull request #30, with the two screenshots that the comment could not carry |

### 1.1 Related documents

| Document | Status |
|---|---|
| `DEVELOPMENT_ROADMAP.md` T-01.1 | Exists, draft. The exit criterion: builds and runs on an Android emulator and an iOS simulator, and `flutter analyze` is clean |
| `TESTING_STRATEGY.md` §13 | Exists, draft. Evidence reports go in `Documentation/test-evidence/`, and large media in an MFW-approved place. The two screenshots here are small and show no MFW content |
| Pull request #30 | Merged as `250190a`. The scaffold. The comment of 7 November 2026 on it holds the same results as section 2 |

## 2. The Run

On 7 November 2026, on `main` at `5a77910` (the scaffold of pull request #30, with only document changes since), from an export of `app/` outside the repository.

| Check | Result |
|---|---|
| Toolchain | Flutter 3.47.9 (revision `c197ca5`), Dart 3.13.7, Xcode 27.2 (27B52), Android SDK platform 36 with build-tools 36.0.0, Java 17 (Homebrew OpenJDK 17) |
| `flutter pub get --enforce-lockfile` | Passes with the lock file as committed |
| `dart format --output=none --set-exit-if-changed .` | 3 files, 0 changed |
| `flutter analyze` | No issues found |
| `flutter test` | 1 test, passed |
| `flutter build ios --simulator --debug` | Built `Runner.app` |
| Runs on an iOS simulator | Yes. iPhone 18 Pro simulator, iOS 27.2. The app shows "Placeholder shell" with the debug banner (section 3, figure 1). The first launch went back to the home screen, and a second launch with `xcrun simctl launch` stayed open |
| `flutter build apk --debug` | Built `app-debug.apk` |
| Runs on an Android emulator | Yes. Emulator 37.2.13, image `system-images;android-36;default;arm64-v8a` (revision 2), Pixel 8 profile, Android 16 (API 36). Installed with `adb install` and started with `am start`. The app's activity is in the foreground and shows "Placeholder shell" with the debug banner (section 3, figure 2). On the first boot the emulator's own System UI showed an "isn't responding" dialog over the app, and it went away after "Wait" |

## 3. Screenshots

Taken on 7 November 2026 during the run above. They show the placeholder app only: no MFW content and no personal data.

| Figure | File | Size | SHA-256 |
|---|---|---|---|
| 1. iOS simulator | `scaffold_run/t011_ios_simulator_5a77910.png` | 95,227 bytes | `8f2b17bb3f6462b88380f166f684e234d7e965d61f3febe40af1bebfc38515ec` |
| 2. Android emulator | `scaffold_run/t011_android_emulator_5a77910.png` | 33,768 bytes | `f44d4e74edf3c3fc9a6f36ea59b09e43f3acfbd2dc008769b5c80b30827f5e0f` |

![Figure 1. The scaffold on the iOS simulator](scaffold_run/t011_ios_simulator_5a77910.png)

![Figure 2. The scaffold on the Android emulator](scaffold_run/t011_android_emulator_5a77910.png)

## 4. What This Run Does Not Show

- No physical phone was used (OQ-26).
- The release build and signing are later tasks (QG-13).
- The Android minimum, target and compile SDK levels and the iOS deployment target 15.0 are Flutter's defaults, not the answer to OQ-26.
- On Android the status bar icons are white on the light placeholder background (figure 2). That is a theme point for T-02.1, not a scaffold defect.

With this, the exit criterion of T-01.1 is met on `main`. The same checks run in CI once pull request #48 (T-01.5) merges.
