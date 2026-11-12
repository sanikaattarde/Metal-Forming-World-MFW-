# Reader Test on MFW's Sample Issues: Metal Forming World (MFW) Mobile Application

| Field | Detail |
|---|---|
| File | `Documentation/test-evidence/READER_SAMPLES_DEVICE_EVIDENCE.md` |
| Tasks | MOD07-P1-T02 (reader test on MFW's PDFs) and MOD07-P3-T01 (reader performance) |
| Status | Draft. One device, ENV-LOCAL. The agreed device set (MOD17-P1-T02) and a tablet are still to come |
| Date | 12 November 2026 |
| Run by | Sanika Attarde, on her own iPhone |
| Build | `main` at the merge of MOD15-P2-T01, with `app/integration_test/reader_mfw_samples_test.dart`; profile build, pdfrx behind `PdfRenderer` (DEC-005 still OPEN) |

## 1. Set-up

- **Device:** iPhone 17 (iPhone18,3), USB, Auto-Lock off.
- **Files:** MFW's three sample issues of `inputs/sample-issues/` (FX-PDF-03, FX-PDF-04), copied into the test app's own folder as `sample-1.pdf` to `sample-3.pdf`, and removed with the app after the run. They are not in Git. The record holds numbers only: no title, text or image.
- **Run:** built with `flutter build ios --profile --dart-define=MFW_ENV=local -t integration_test/reader_mfw_samples_test.dart`, installed and read from the console as in `IPHONE_DEVICE_TEST_EVIDENCE.md`.

## 2. MOD07-P1-T02: Every Page Renders

Each page drawn by PDFium at 1170 pixels wide, a phone's width at 3x.

| Sample | Size | Pages | Wider than tall | Opened in | Failed | Mean per page | Slowest page |
|---|---|---|---|---|---|---|---|
| sample-1 | 7 MB | 28 | 0 | 74 ms | 0 | 9 ms | 40 ms |
| sample-2 | 8 MB | 32 | 0 | 72 ms | 0 | 18 ms | 162 ms |
| sample-3 | 14 MB | 44 | 0 | 98 ms | 0 | 12 ms | 48 ms |

All 104 pages of the three issues render (AC-2.2). None is wider than tall, so a spread in landscape always pairs two pages after the cover.

## 3. MOD07-P3-T01: SCR-A-14 on the Samples

The real reader screen, in each mode, for each sample: the first page, 20 page turns with the Next button, and a pinch to 300% followed by the sharper redraw.

| Measure | Page-turn mode | Swipe mode | Target |
|---|---|---|---|
| First page shown (AC-2.1) | 100 to 147 ms | 147 ms | 3 s |
| 20 page turns (AC-2.5) | 20 of 20, every page drawn within the test's 0.5 s window, no crash | The same | No crash |
| Zoom (FR-READ-005) | 3.00x, redrawn at 3x | 3.00x, redrawn at 3x | 300% |
| Memory while reading | 173 to 226 MB | 174 to 208 MB | Not set |
| Peak memory of the run | 465 MB, over all six readings and the full-render pass | | Not set |
| Frames requested after a turn has ended | None | None | None |

The turn times printed by the run (about 775 ms) are the test's own fixed wait of 30 frames per turn, not the reader's time: the page was ready at the end of that wait every time. The 12-million-pixel budget for a zoomed page (MOD07-P2-T03) kept memory flat: zooming to 300% did not raise it.

## 4. Findings

1. **No defect in the reader.** The targets of AC-2.1 and AC-2.5 are met with a wide margin on this phone. No tuning was needed.
2. **The first two attempts stalled.** One waited for the screen to settle after each turn and never returned, and iOS ended the app. The phone had also locked during earlier attempts. With a fixed run of frames in place of the settle wait, the run passed, and the reader requests no frames once a turn ends, so the stall came from the test's wait. Why the settle wait did not return is not explained, and it is recorded here so a later run does not repeat it.
3. **AC-2.3 (sharp text at 300%) is judged by eye** and was not checked here: the run proves the redraw happens at 3x, not how it looks.

## 5. Not Run

- A tablet and the two-page spread on one (AC-2.4, R25).
- The low-cost Android phone and the older iPhone of NFR-COMP-003; the device set is MOD17-P1-T02.
- The reader test MFW sees at M2 (MOD16-P2-T01).
