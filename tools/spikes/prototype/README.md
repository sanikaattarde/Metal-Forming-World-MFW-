# MFW low-fi prototype (T-02.1, spike)

A clickable, greyscale prototype of the app screens of
`Documentation/SCREEN_INVENTORY_AND_NAVIGATION.md` section 5, for the
walk-through of T-02.1 (MOD16-P1-T05). It is a spike: it is never shipped,
it does not use the app's code under `app/`, and its look is not a design.
The M2 designs set the look, the arrangement of the tabs and the wording.

- Every screen shows its SCR-A-nn ID under the title.
- The tune icon opens the prototype controls, which are not part of the app.
  They switch the access state (section 3), what content screens show
  (loading, empty), the network, mobile data, the news site, low storage,
  a damaged file, an unpublished issue, and how the next download ends
  (completes, breaks and resumes, fails its check). They also open a
  notification for an issue and an unknown link.
- All content is made up. No MFW content, logo or file is used (DEC-024).

## Run

```bash
flutter run -d <device>
```

## Tests

`test/walkthrough_test.dart` walks every screen and the entry rule:

```bash
flutter test
```

`test/screen_shots_test.dart` draws each screen and state to
`test/shots/*.png` at 1170 by 2532 pixels, with the Roboto and Material
Icons fonts of the Flutter SDK (without them the test font draws boxes, so
the test is skipped):

```bash
flutter test test/screen_shots_test.dart --update-goldens \
  --dart-define=FONT_DIR=<flutter>/bin/cache/artifacts/material_fonts
```
