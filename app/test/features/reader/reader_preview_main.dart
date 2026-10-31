// Preview of the reader over the fakes, for the simulator probe (P-SIM):
//   flutter run -t test/features/reader/reader_preview_main.dart
// Not a test, and not part of the app. The reader route in app/lib/app/
// still shows a placeholder until the reader is wired in there.

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

import 'fake_pdf_renderer.dart';
import 'numbered_page_source.dart';
import 'reader_test_support.dart';

void main() {
  runApp(
    MaterialApp(
      theme: placeholderTheme,
      home: ReaderScreen(
        downloads: downloadsHolding(<String>['fx-iss-01']),
        renderer: FakePdfRenderer(pageCounts: <String, int>{'fx-iss-01': 12}),
        pages: const NumberedPageSource(),
        issueId: 'fx-iss-01',
        mode: ReaderMode.pageTurn,
      ),
    ),
  );
}
