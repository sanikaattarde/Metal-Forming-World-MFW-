# pdf_compare - reader library comparison harness (WB-05, T-02.3)

A spike that produces numbers for DEC-005 (which PDF library the reader uses). DEC-005 stays OPEN. This app is never shipped, and its packages (pdfrx, pdfx) are not in `app/pubspec.yaml`.

For each library it measures, on the same files:

| What | How it is measured |
|---|---|
| Time to first page | A fresh open, then page 1 as a Flutter image. Three repetitions. `openMs`, `renderMs`, `decodeMs` and the wall `totalMs` are listed separately. |
| 20 page turns (AC-2.5) | One open, then 20 renders in a row (a short file wraps back to page 1). Every error is counted; a failed turn does not stop the next one. |
| 300% render (AC-2.3) | Page 1 at three times the base width. Three repetitions. |
| Memory | `ProcessInfo.currentRss` read every 20 ms during a step (a peak between samples can be missed), and `ProcessInfo.maxRss` for the whole process. Run one library per process for a clean process peak. |
| Repair check | Every page of FX-PDF-11 (wrong cross-reference offsets) is drawn at the base width and compared with the same page of FX-PDF-01 (same content, good offsets): drawn or blank (`nonWhiteFraction` over every pixel) and a pixel-by-pixel comparison (`compareRgba`: differing pixels, largest channel difference). A library that errors at open has nothing to compare; the error is recorded. Result key: `repairCheck` in each library's entry. |
| Exceptions | Every exception becomes an entry with its step, type, message and the top of its stack. Errors that escape a `try` are listed under `uncaughtErrors`. |

"100%" is the page fitted to 1080 physical pixels wide (`BASE_WIDTH`), so numbers do not depend on a device's screen. A blank-page check (`nonWhiteFraction`) tells a drawn page from an empty one; it is not an image quality measure.

pdfrx hands over raw pixels (the harness copies them into a Flutter image). pdfx hands over an encoded image (JPEG, the library default) that Flutter decodes. That is why `decodeMs` means two different things; the sum is the time to a drawable image.

## Inputs

| ID | File | Where it comes from |
|---|---|---|
| FX-PDF-01 | `fx_pdf_01.pdf` (4 text pages) | bundled, `assets/pdf/` |
| FX-PDF-10 | `fx_pdf_10.pdf` (truncated; must give an error) | bundled |
| FX-PDF-11 | `fx_pdf_11.pdf` (bad cross-reference table; must give an error) | bundled |
| FX-PDF-05 | `fx_pdf_05.pdf` (120 pages, 144,657,028 bytes) | **not bundled**; pass its path in `LARGE_PDF` |

The files in `assets/pdf/` are byte copies of `tools/fixtures/pdf/`. They and FX-PDF-05 are made by `tools/fixtures/make_pdfs.py` (synthetic, deterministic; see `app/test/fixtures/large_files_manifest.json` for the FX-PDF-05 SHA-256). Noise images are a pessimistic proxy for file size, not for the look or rendering cost of MFW's real pages. No MFW file is used.

## Run

Defines (all optional): `LIBS` (`pdfrx`, `pdfx` or `pdfrx,pdfx`), `LARGE_PDF`, `OUT_DIR`, `DEVICE_LABEL`, `BASE_WIDTH`, `TURNS`, `AUTORUN`, `EXIT_WHEN_DONE`.

iOS simulator (the host path works from the simulator; debug mode only, so correctness only):

```bash
flutter run -d <simulator> --dart-define=LIBS=pdfrx --dart-define=LARGE_PDF=<path>/fx_pdf_05.pdf --dart-define=OUT_DIR=<folder>
```

On a phone, build in `--profile` or `--release` (debug timings are not meaningful), put FX-PDF-05 somewhere the app can read, and pass that on-device path in `LARGE_PDF`. Run `LIBS=pdfrx` and `LIBS=pdfx` as two separate launches. The result is shown on screen (Copy JSON), printed as `PDFCMP` log lines, and written to `results_<libs>.json` in `OUT_DIR` (default: the app's temporary folder). The file is rewritten after every input, so a crash keeps what already ran.

```bash
flutter test      # unit tests of the bookkeeping (no PDF library involved)
flutter analyze
```
