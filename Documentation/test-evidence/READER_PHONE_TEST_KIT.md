# Reader Phone Test Kit: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | Reader Phone Test Kit |
| File | `Documentation/test-evidence/READER_PHONE_TEST_KIT.md` |
| Phase | 4: Testing, Release and Risk Management. The plan and result template for the phone part of T-02.3 (`TESTING_STRATEGY.md` §8.1, §13) |
| Version | 0.1 |
| Status | Draft for review. **PLANNED: not run.** No result is recorded here. It ranks no library, and DEC-005 stays OPEN. |
| Date | 8 November 2026 |
| Prepared by | Yuvraj Gaykhe (WS-B), for the developer who runs T-02.3 on the test phones |
| Approval required | Both developers. The repetitions are agreed with this test (`TESTING_STRATEGY.md` §8.1, PROPOSED) |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 8 November 2026 | First version: the steps, the rules for MFW's PDFs, and the result tables, after MFW's three issues were recorded (pull request #46) |

### 1.1 Related documents

| Document | Status |
|---|---|
| `DEVELOPMENT_ROADMAP.md` T-02.3 | Exists, draft. Reader test on MFW's sample PDFs: first-page time, sharpness at 300% zoom, 20 page turns on the mid-range test phone; candidate libraries assessed, including licence (DEC-005) |
| `ACCEPTANCE_CRITERIA.md` AC-2.1, AC-2.3, AC-2.5 | Exist, draft. First page within 3 seconds; text sharp at 300%; no crash in 20 page turns |
| `TESTING_STRATEGY.md` §8.1 | Exists, draft. The methods, PROPOSED |
| `test-evidence/PDF_LIBRARY_SIMULATOR_EVIDENCE.md` | Exists, draft. The simulator part of the comparison, and what to repeat on a phone |
| `inputs/README.md` | Exists. MFW's logo file and three issues, with size and SHA-256. The files are not in Git |
| `DECISION_LOG.md` DEC-005, DEC-024 | Exist, draft. The reader library (OPEN); the test data policy (AGREED; where MFW's samples may be kept is still open) |
| Branch `spike/yg-pdf-compare`, commit `b06df83` | Not merged to `main`. The harness in `tools/spikes/pdf_compare/`, with its README |

## 2. Rules for MFW's PDFs

MFW's sample PDFs are confidential (DEC-024), and the repository is public.

1. The PDFs stay on the developer's machine and the test phones. They are never committed, attached to an issue or a pull request, or sent to any service.
2. No screenshot, screen recording or rendered image of an MFW page goes into the repository or a pull request. Recordings for AC-2.1 go in an MFW-approved place, which does not exist yet (`TESTING_STRATEGY.md` §13). Until MFW names one, they stay on the developer's machine.
3. The result report records numbers, pass or fail, and short notes only. Each issue is named by its edition (for example "April-May 2026") and the first 12 characters of its SHA-256 from `inputs/README.md`, so that the file can be checked.
4. Before a run, check each local copy against `inputs/README.md` (`shasum -a 256 <file>`). A file that does not match is not used.
5. Keeping local copies before MFW names a place is a working position that departs from the wording of DEC-024, as the review of pull request #46 noted. It is not a decision.

## 3. Devices

| Role | Device (fill in) | OS version | RAM | Notes |
|---|---|---|---|---|
| Mid-range Android phone (GS-Q54) | | | | AC-2.1 is measured on this one |
| Current iPhone (GS-Q54) | | | | |
| Tablet, if available (AC-2.4) | | | | Not part of T-02.3 |

The device list is OQ-26 and is not answered. Record what was used, and say that it is not the agreed list.

## 4. Part A: the harness on each phone

The harness measures, for pdfrx and for pdfx in separate launches: time to the first page (three repetitions), 20 consecutive page turns, a render of page 1 at 300%, memory, and an error count. Its README on the spike branch has the details. It takes one large file in `LARGE_PDF`, so run it once per issue and per library.

1. Check out `spike/yg-pdf-compare` at `b06df83` in its own worktree, and run `flutter pub get` in `tools/spikes/pdf_compare/`.
2. Build in profile mode. Debug timings are not meaningful on a phone.
3. Put the issue where the app can read it, and pass that path in `LARGE_PDF`:
   - Android: the harness's application ID is `invalid.placeholder.pdf_compare`. Install the app once, then `adb push <issue>.pdf /sdcard/Android/data/invalid.placeholder.pdf_compare/files/` and use that path.
   - iPhone: the bundle ID is `invalid.placeholder.pdfCompare`, so Xcode needs your own signing team and a bundle ID you own before it installs on a phone. Copy the file into the app's Documents folder (for example with `xcrun devicectl device copy to` and the app data container), and pass the full path that the app reports for its Documents folder.
   - These steps are NOT TESTED on a phone. If a path is refused, note it and use the method that works.
4. Run, for each issue and each library:

```bash
flutter run --profile -d <device> --dart-define=LIBS=pdfrx --dart-define=LARGE_PDF=<path on the phone> --dart-define=DEVICE_LABEL=<device> --dart-define=EXIT_WHEN_DONE=true
```

   Then the same with `LIBS=pdfx`.

5. Keep the `results_<libs>.json` files and the `PDFCMP` log lines on the developer's machine. They hold local paths and stay out of Git, as in the simulator report. Copy the numbers into the tables of section 6.

## 5. Part B: the checks by hand

| Check | How | Pass | Note |
|---|---|---|---|
| AC-2.1 first page | `TESTING_STRATEGY.md` §8.1: a screen recording from tapping Open to the first page fully drawn, on the mid-range Android phone. The reader app does not exist yet, so record the harness's time to the first page now, and repeat with the reader app in T-05.1 | 3 seconds or less | The harness times a render to an image. That is part of AC-2.1, not the same thing |
| AC-2.3 sharpness at 300% | Look at text-heavy pages at 300% on each phone. The harness renders page 1 at 3240 pixels wide but shows only small first-page previews, so it cannot be used to judge sharpness. Use a viewer built on the library (T-05.1) | Text is sharp to the tester | Until a viewer exists, record "not judged" |
| AC-2.5 twenty page turns | The harness's 20 turns, on each phone, for each issue | No crash, 20 of 20 | |
| Licence (DEC-005) | Read from `DEPENDENCY_REGISTER.md` DEP-64 (pdfrx) and DEP-65 (pdfx), and the native engines they use | Recorded | No new reading is needed unless the version changes |

## 6. Result Tables (fill in)

Copy these into a new report, `READER_PHONE_TEST_EVIDENCE.md`, when the run is done. Times in milliseconds: repetitions 1, 2 and 3.

### 6.1 Time to the first page

| Device | Library | Issue (edition, SHA-256 prefix) | totalMs | openMs | renderMs | decodeMs |
|---|---|---|---|---|---|---|
| | pdfrx | | | | | |
| | pdfx | | | | | |

### 6.2 Twenty page turns

| Device | Library | Issue | Turns completed | Per-turn ms (min, median, max) | Errors | Crash |
|---|---|---|---|---|---|---|
| | pdfrx | | | | | |
| | pdfx | | | | | |

### 6.3 Render at 300% and memory

| Device | Library | Issue | 300% render ms | Peak memory (RSS) | Sharp to the tester | Notes |
|---|---|---|---|---|---|---|
| | pdfrx | | | | | |
| | pdfx | | | | | |

## 7. After the Run

1. File `READER_PHONE_TEST_EVIDENCE.md` in this folder, with numbers only (section 2).
2. Propose a library in DEC-005, with the evidence. DEC-005 stays OPEN until both developers agree it, and MFW confirms the reader approach at M2.
3. Confirm the AC-2 targets with MFW, or record an adjustment (S2 AC-2).
4. Record whether the largest expected issue was among the three (DEP-03, FX-PDF-04).
