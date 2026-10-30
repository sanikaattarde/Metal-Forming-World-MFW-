# Backend spike notes 02: local toolchain and harness check

| Field | Detail |
|---|---|
| Branch | `spike/sa-backend-rules` (a spike: not merged to `main`) |
| Date | 30 October 2026 |
| Status | Working notes. PROPOSED. Not reviewed. Results are "emulator only" |
| Rests on | DEC-003 and DEC-020 (OPEN); TD-03 and TD-17 (PROPOSED) |

## 1. What was installed

| Item | Version | Where | Licence as stated by the package | Notes |
|---|---|---|---|---|
| OpenJDK | 21.0.13.0.3 (Homebrew `openjdk@21`) | `/opt/homebrew/Cellar/openjdk@21`, keg-only | GPL-2.0 with Classpath exception (Homebrew metadata) | Not on `PATH`. No shell profile was changed. Homebrew also upgraded its dependency `xz` from 5.8.3 to 5.8.4 |
| `firebase-tools` | 15.34.2 | `backend/spike/node_modules` | MIT | Its source says Java before 21 is not supported |
| `@firebase/rules-unit-testing` | 6.0.0 | `backend/spike/node_modules` | Apache-2.0 | Peer dependency `firebase` ^13 |
| `firebase` (client SDK) | 13.1.0 | `backend/spike/node_modules` | Apache-2.0 | Used by the rules tests only |
| Cloud Firestore emulator | v1.22.0 jar, 136,707,194 bytes | `backend/spike/node_modules/.cache/firebase-emulators` | not read | Downloaded by the CLI from `storage.googleapis.com/firebase-preview-drop`. Size matches the CLI's own table |
| Cloud Storage rules runtime | v1.1.3 jar, 52,892,936 bytes | same folder | not read | Same source. Size matches |

The npm packages are pinned to exact versions and were installed with lifecycle scripts switched off (`--ignore-scripts`). Node.js stays at the installed v26.0.0, and the test runner is Node's built-in one, so no test-framework package was added.

**Not verified.** Licences above come from each package's own `package.json` field or Homebrew metadata. `DEPENDENCY_REGISTER.md` requires them to be read from the LICENSE file or the official page. `@firebase/rules-unit-testing` and `firebase` have no top-level LICENSE file in their npm packages. No register entry has been written. The entries belong in the pull request that promotes this work (`DEPENDENCY_REGISTER.md` section 3).

## 2. Run

```text
npm --prefix backend/spike test
```

The script runs `scripts/run-with-env.sh`, which points the emulator downloads at the project folder, puts Homebrew's Java 21 first on `PATH` for that command only, and then runs `firebase emulators:exec` for the Auth, Firestore and Storage emulators with the project name `demo-mfw-spike`. No login and no cloud project are used.

## 3. Result

Run on 30 October 2026, twice (the second time after adding a positive control to the storage test): 4 tests, 4 passed, 0 failed. Emulator only.

| Test | Shows |
|---|---|
| Firestore, unlisted path | A path no rule lists is refused for a visitor and for a signed-in user. The emulator log shows the rule that refused it |
| Firestore, owner-only record | The owner can write and read; another reader and a visitor are refused |
| Storage, private path | With rules switched off the file exists and can be read back (positive control). A visitor and a signed-in reader are then refused a read, and a signed-in reader is refused a write |
| Auth emulator | Sign-up works, and the verification code for the new account can be read back from the emulator |

These are a check of the harness, not the product's access tests. The rules in `firestore.rules` and `storage.rules` are a baseline, and the path layout in them is a spike choice.

## 4. Assumptions tested

| Assumption | Result |
|---|---|
| A "demo" project name keeps the emulators from touching a cloud project | The CLI printed that it "will use a demo configuration" and that attempts to reach non-emulated services for the project "will fail". That is the tool's own statement. No test tried to reach a cloud service |
| The Auth emulator exposes verification codes | Yes, on this version, through `/emulator/v1/projects/<project>/oobCodes` |
| Node.js 26 can run the emulators | The Auth, Firestore and Storage emulators ran under Node 26.0.0. `npm` warned that `superstatic` 10.0.0, a dependency of the hosting emulator, supports only Node 20, 22 and 24. The hosting emulator was not started. The functions emulator has not been tried |
| Java 21 is enough | The Firestore emulator started and served on `openjdk` 21.0.13 |

## 5. Side effects, for the record

1. `firestore-debug.log` is written into `backend/spike` on each run. It is ignored by the repository's `.gitignore` (`*.log`).
2. The CLI created `~/.config/configstore/firebase-tools.json` (316 bytes, one key, a cached message of the day). It holds no token. Nothing was written to `~/.cache/firebase`.
3. `npm audit` reports 10 advisories (5 moderate, 5 high) in the test dependencies. The fixes it offers are downgrades to `firebase` 9.14.0 and `@firebase/rules-unit-testing` 2.0.7, which were not applied. For the register, not a decision.
4. The Firestore emulator started its UI websocket on port 9150 although the UI is disabled in `firebase.json`.
