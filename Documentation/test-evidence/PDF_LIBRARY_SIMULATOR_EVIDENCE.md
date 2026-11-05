# PDF Library Simulator Evidence: Metal Forming World (MFW) Mobile Application

## 1. Document Control

| Field | Detail |
|---|---|
| Document | PDF Library Simulator Evidence |
| File | `Documentation/test-evidence/PDF_LIBRARY_SIMULATOR_EVIDENCE.md` |
| Phase | 4: Testing, Release and Risk Management. A test evidence report (`TESTING_STRATEGY.md` §13) |
| Version | 0.1 |
| Status | Draft for review. Not reviewed. **Every result is simulator and debug build.** No result here was taken on a phone, and none is valid for AC-2.1. It ranks no library. DEC-005 stays OPEN. Nothing is AGREED, and nothing here has gone to MFW |
| Date | 6 November 2026 |
| Tests run by | Yuvraj Gaykhe (WS-B), 31 October and 1 November 2026, in the WB-05 spike (T-02.3) |
| Approval required | Both developers |

**Change history**

| Version | Date | Change |
|---|---|---|
| 0.1 | 6 November 2026 | First report: the simulator part of the WB-05 reader library comparison (T-02.3) |

### 1.1 Related documents

| Document | Status |
|---|---|
| `TESTING_STRATEGY.md` §8.1, §13 | Exists, draft. AC-2.1 is measured on the mid-range test phone with a screen recording. The evidence location |
| `TEST_DATA_AND_FIXTURES.md` section 7 | Exists, draft. FX-PDF-01, FX-PDF-05, FX-PDF-10 and FX-PDF-11, the files used here |
| `PDF_READER_AND_OFFLINE_DESIGN.md` RD-08 | Exists, draft. How FR-READ-010 is read for a damaged file that a library can repair |
| `DECISION_LOG.md` DEC-005 | Exists, draft. The reader library, OPEN |
| `DEPENDENCY_REGISTER.md` DEP-64, DEP-65 | Exist, draft. pdfrx and pdfx, candidates for the comparison |
| `DEVELOPMENT_WORKFLOW.md` §13 item 5 | Exists, draft. A spike is not merged into `main` as production code. Its findings are merged as a document. This report is that document |
| Branch `spike/yg-pdf-compare`, commit `b06df83` | Not merged to `main`. On GitHub since 5 November 2026. Holds the harness (`tools/spikes/pdf_compare/`), the fixture generator (`tools/fixtures/make_pdfs.py`) and the three small fixtures (`tools/fixtures/pdf/`) |

## 2. What This Report Is

1. It records what the WB-05 harness measured on the iOS simulator for two PDF libraries, pdfrx and pdfx: time to the first page, 20 page turns, a render at 300%, memory, and two damaged files (FX-PDF-10 and FX-PDF-11).
2. It records a repair check: what pdfrx drew when it opened FX-PDF-11, compared pixel by pixel with FX-PDF-01.
3. It lists what the run could not show, and what to repeat on the test phone.

**What it is not.**

- It is not a result for AC-2.1, AC-2.3 or AC-2.5. They are measured on the test phone. The harness times a render to an image, which is a part of AC-2.1 and not the same thing.
- It does not rank the two libraries, recommend one, or change DEC-005, any requirement, any status label or any decision.
- It does not use MFW's sample PDFs. T-02.3 needs them on the test phone before DEC-005 can close (DEC-024, and row 3 of the tracker in `DEVELOPMENT_ROADMAP.md` section 4.2).

**Why simulator results are limited.**

- The simulator on Apple silicon runs the iOS code natively on the Mac's processor, and the build is a debug (JIT) build. Every Dart-side step carries that cost.
- pdfx on iOS draws through the platform's PDF engine. What that engine does on a phone's chip was not measured.
- The figures are for the render calls only. Neither library's own viewer widget was used.

## 3. The Run

| Field | Detail |
|---|---|
| Harness | A Flutter app in `tools/spikes/pdf_compare/` with its own pubspec. It is never shipped, and its packages are not in `app/pubspec.yaml` |
| Libraries | pdfrx 2.11.0 and pdfx 2.11.0, one library per process |
| Commit | `b06df83` on `spike/yg-pdf-compare` |
| Device | iPhone 18 Pro simulator, iOS 27.2, on a Mac with 8 processors. Debug build, Dart 3.13.7 |
| Date | 1 November 2026, Mac local time. Two launches per library for the timings (runs 1 and 2) and one per library for the repair check (run 3) |
| Inputs | Synthetic and deterministic, made by `tools/fixtures/make_pdfs.py`. FX-PDF-01: 4 text pages, 7,363 bytes. FX-PDF-05: 120 pages of random-noise images, 144,657,028 bytes (its SHA-256 is in `app/test/fixtures/large_files_manifest.json` on the branch). FX-PDF-10: FX-PDF-01 truncated. FX-PDF-11: FX-PDF-01 with every cross-reference offset wrong. No MFW PDF and no third-party text (DEC-024) |
| Result | 0 uncaught errors in every launch. Both libraries opened FX-PDF-01 and FX-PDF-05 in every run. The damaged-file results are in section 5 |
| Raw output | **Not filed.** The result files, run logs and screenshots hold local paths and stay on the developer's Mac. When this report was prepared, the timing, memory and size figures in sections 4 and 5 were compared with the result files and they match. The logs and screenshots were not part of that comparison |
| Note on run 3 | The result file of the pdfx launch for the repair check was written at 13:48 on 1 November, Mac local time, later than the pdfrx file of the same run (02:04) and later than the run log of that launch (02:06). The log and the file give the same open error for FX-PDF-11, and different timings (for example the first page of FX-PDF-01 in repetitions 1, 2 and 3: 224.1, 26.6 and 29.1 ms in the log, and 242.7, 93.4 and 42.0 ms in the file). Why the file was written again was not looked into. No timing from run 3 is used |

## 4. Numbers

Simulator, debug build, Mac host. Times are in milliseconds. "Run 1" and "run 2" are separate launches. These are not device numbers.

### 4.1 Time to the first page

Total ms for repetitions 1, 2 and 3. Repetition 1 includes first-use start-up work in the process, and for FX-PDF-05 a cold file cache.

| Library | File | Run 1 | Run 2 |
|---|---|---|---|
| pdfrx | FX-PDF-01 (4 pages) | 107.0 / 21.8 / 8.8 | 107.2 / 13.3 / 8.0 |
| pdfrx | FX-PDF-05 (120 pages) | 141.4 / 44.3 / 46.7 | 183.0 / 36.7 / 46.0 |
| pdfx | FX-PDF-01 | 305.1 / 37.8 / 25.3 | 302.0 / 23.0 / 40.4 |
| pdfx | FX-PDF-05 | 132.9 / 101.1 / 102.0 | 144.4 / 106.6 / 111.6 |

The total is the open, the render and the decode. The decode is not the same work for the two libraries: pdfrx hands over raw pixels, which the harness copies into a Flutter image, and pdfx hands over a JPEG, which Flutter decodes. The sum is the time to a drawable image.

Library start-up before the first document, not part of the figures above: pdfrx `pdfrxFlutterInitialize` 4,380.7 ms (run 1) and 5,473.3 ms (run 2). pdfx `hasPdfSupport` 0.8 ms and 0.4 ms.

pdfx output at 1080 pixels wide (JPEG, quality 100, the library default): 404,702 bytes for page 1 of FX-PDF-01 and 5,154,320 bytes for page 1 of FX-PDF-05. At 3240 pixels wide: 1,887,402 and 27,355,984 bytes.

### 4.2 Twenty consecutive page turns (AC-2.5)

One open, then 20 renders in a row (a short file wraps back to page 1). A failed turn is counted and the next turn still runs. Turn time (render plus decode) in ms, median / 95th percentile / maximum.

| Library | File | Run 1 | Run 2 | Turns without error |
|---|---|---|---|---|
| pdfrx | FX-PDF-01 | 5.3 / 9.9 / 14.7 | 6.9 / 10.7 / 11.0 | 20 of 20 in both runs |
| pdfrx | FX-PDF-05 | 8.5 / 11.0 / 13.7 | 7.2 / 8.6 / 11.3 | 20 of 20 in both runs |
| pdfx | FX-PDF-01 | 20.5 / 23.3 / 23.4 | 21.8 / 39.2 / 52.8 | 20 of 20 in both runs |
| pdfx | FX-PDF-05 | 103.4 / 108.6 / 111.0 | 107.9 / 117.2 / 121.1 | 20 of 20 in both runs |

That is 20 turns with no exception and no crash on the simulator, for each library, in both runs. AC-2.5 asks for 20 consecutive turns on each test device with no crash. No device was tested.

### 4.3 Render at 300% (3240 by 4585 pixels)

Page 1 as a full page at three times the base width. A viewer would render the visible part only, so this is a pessimistic size. Total ms for repetitions 1, 2 and 3.

| Library | File | Run 1 | Run 2 |
|---|---|---|---|
| pdfrx | FX-PDF-01 | 77.1 / 54.9 / 50.5 | 90.8 / 59.4 / 52.5 |
| pdfrx | FX-PDF-05 | 86.8 / 58.8 / 68.6 | 70.0 / 60.6 / 63.0 |
| pdfx | FX-PDF-01 | 141.9 / 135.1 / 143.4 | 145.2 / 135.4 / 139.6 |
| pdfx | FX-PDF-05 | 738.9 / 724.6 / 742.6 | 734.9 / 723.7 / 729.9 |

Every 300% render drew a page. The share of non-white pixels was 0.042 (pdfrx) and 0.046 (pdfx) for the text file, and 1.0 for the noise file. Sharpness of text at 300% was not judged. AC-2.3 needs a person on the test phone.

### 4.4 Memory

Resident memory of the whole process in MiB, read every 20 ms during a step (the highest value seen). It includes the Flutter engine and, on the simulator, the debug VM, so it is not the share of either library. A peak shorter than 20 ms can be missed.

| Library | Process at the start of the first file (run 1 / run 2) | FX-PDF-01: first page, turns, 300% (run 1) | FX-PDF-05: first page, turns, 300% (run 1) | Process peak (run 1 / run 2) |
|---|---|---|---|---|
| pdfrx | 447.9 / 414.5 | 468.9, 495.6, 656.1 | 626.8, 618.2, 724.0 | 727.9 / 687.0 |
| pdfx | 269.8 / 406.9 | 289.4, 320.4, 435.2 | 380.2, 361.2, 516.2 | 517.3 / 464.9 |

The start-of-process figure for pdfx differs between launches (269.8 and 406.9), so the baseline is not stable on the simulator.

## 5. Damaged Files

### 5.1 Results

| File | pdfrx | pdfx |
|---|---|---|
| FX-PDF-10 (truncated) | Error at open in every repetition, in both runs: `PdfException: Failed to load PDF document (FPDF_ERR_FORMAT: 3)` | Error at open in every repetition, in both runs: `PlatformException(RENDER_ERROR, Invalid PDF format, null, null)` |
| FX-PDF-11 (wrong cross-reference offsets) | **Opened and rendered page 1** (4 pages; 18.6 / 8.4 / 19.7 ms in run 1 and 23.1 / 7.1 / 16.8 ms in run 2). No error | Error at open in every repetition, in both runs: the same `PlatformException` |

Neither library crashed on either file. macOS PDFKit also did not open FX-PDF-10 or FX-PDF-11 on the Mac on 31 October 2026 (its output is not filed).

For pdfrx, FX-PDF-11 did not give the error that the fixture was made to give. PDFium appears to rebuild the cross-reference table. That is an inference from the result and was not read from PDFium's source. The harness marks the outcome "not as expected" and does not hide it.

### 5.2 Repair check

pdfrx and pdfx were each asked to draw every page of FX-PDF-11 at 1080 pixels wide, and the same page of FX-PDF-01, in one launch (run 3). A page is checked as drawn or blank (the share of non-white pixels, over every pixel) and compared with its counterpart pixel by pixel.

**pdfrx 2.11.0.** Both files report 4 pages. All four pages of FX-PDF-11 were drawn, none failed to render, and every page equals the same page of FX-PDF-01 in every byte of its pixel buffer.

| Page | FX-PDF-01 non-white share | FX-PDF-11 non-white share | Size (pixels) | Differing pixels | Largest channel difference |
|---|---|---|---|---|---|
| 1 | 0.068 | 0.068 | 1080 by 1528 | 0 of 1,650,240 | 0 |
| 2 | 0.068 | 0.068 | 1080 by 1528 | 0 of 1,650,240 | 0 |
| 3 | 0.068 | 0.068 | 1080 by 1528 | 0 of 1,650,240 | 0 |
| 4 | 0.068 | 0.068 | 1080 by 1528 | 0 of 1,650,240 | 0 |

**pdfx 2.11.0.** FX-PDF-11 gives the open error above, so there is nothing to compare: 0 pages compared. FX-PDF-01 opened as before.

**What this means for the documents.** Under the proposed reading of FR-READ-010 (RD-08), a repaired open that shows every page of the PDF it was made from, in order, passes. In this run pdfrx meets that on FX-PDF-11 and pdfx gives an error. Which library the reader uses is DEC-005, and it stays OPEN. Whether the upload accepts a file like FX-PDF-11 is OQ-61.

**Gaps of the repair check.**

1. One launch per library and one width (1080 pixels). The 300% size and other widths were not compared.
2. Raster only. Text, links, annotations and fonts were not extracted or compared. FX-PDF-01 is plain text in the standard Helvetica font with no images, so the check says nothing about how a library repairs a damaged file that holds images or embedded fonts.
3. "Identical" means that each page matched its own counterpart. FX-PDF-01 pages were not compared with each other. The comparison function is tested on a difference of 7 in one channel of one pixel, in unit tests, and was not run on a known-different pair of real renders.
4. What pdfrx or PDFium did inside to open the file was not inspected.
5. Simulator and debug build. Nothing was run on a phone, and Android was not run.

## 6. What This Run Did Not Show

1. **No device number.** AC-2.1, AC-2.3 and AC-2.5 stay open until a phone is used (OQ-26).
2. **Not the AC-2.1 method.** The harness times an open and one render to an image. It does not include a tap, a route change, the viewer widget, a first frame on screen or a screen recording.
3. **Render to image, not a viewer.** The viewer widgets of both libraries (tiling, gestures, cache, zoom animation) were not used. MFW's reader may use the widgets or the render calls.
4. **One pdfrx opening mode.** pdfrx was opened with `PdfDocument.openFile` and default options. Its progressive mode and its optional CoreGraphics backend for iOS, which its README calls experimental, were not measured. pdfx was run with JPEG output only.
5. **Noise images.** FX-PDF-05 has uniform random noise and plain text. It does not stand for photographs, vector art, embedded fonts, transparency or scanned pages. Real issues may behave differently in both directions.
6. **Few repetitions.** Three repetitions and two launches are not enough for a statistic. The spread between the launches is visible in the tables (for example the pdfx page turns on FX-PDF-01, maximum 23.4 ms and 52.8 ms).
7. **Cold and warm.** Repetition 1 includes first-use work and a cold file cache for the 144 MB file. A fresh app start on a phone was not measured.
8. **Android was only built.** A debug APK was built and not installed. pdfx on Android was never run. The statement that its Android engine is a platform component is a report of the developer, not something the harness exercised.
9. **A damaged file and a bad path look alike.** Both show as an exception at open. The paths were checked: the files exist and the valid ones open.

## 7. To Repeat on the Test Phone

The harness README (`tools/spikes/pdf_compare/README.md` on the branch) says how to run it. On a phone:

1. Build in profile or release mode, so that the timings mean something. Run `LIBS=pdfrx` and `LIBS=pdfx` as two separate launches.
2. Put FX-PDF-05 where the app can read it, and give its path in `LARGE_PDF`. Its SHA-256 is in the manifest on the branch.
3. Name the device in `DEVICE_LABEL`. Keep the result files, and file the figures in a new version of this report, with the model and the OS version of the phone.
4. Run the same files again with MFW's sample PDFs, once MFW has approved a place for them (DEC-024, and row 3 of the tracker in `DEVELOPMENT_ROADMAP.md` section 4.2).
5. Run FX-PDF-10 and FX-PDF-11 again on the phone with both libraries, because the damaged-file results bear on AC-2.6 (FX-PDF-10) and on RD-08 (FX-PDF-11).

## 8. Points for Other Documents

These came out of the harness build. They are reported here and are not yet in the registers.

- The pdfx plugin applies the Kotlin Gradle plugin, and Flutter warns that future versions may fail to build with plugins that do this. It is worth a line in `DEPENDENCY_REGISTER.md` if pdfx stays a candidate.
- The PDFium binaries that pdfrx uses for iOS and Android are fetched at build time, from two third-party GitHub release locations. Where those binaries come from and whether a build may depend on them is a supply-chain point for the register and for the CI plan.
