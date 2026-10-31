import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_compare/src/config.dart';
import 'package:pdf_compare/src/engines.dart';

void main() {
  test('defaults run both libraries with the AC-2.5 turn count [AC-2.5]', () {
    final config = HarnessConfig.parse(<String, String>{});
    expect(config.libs, <String>['pdfrx', 'pdfx']);
    expect(config.turns, 20);
    expect(config.firstPageReps, 3);
    expect(config.zoomFactor, 3.0);
    expect(config.largePdf, isEmpty);
    expect(config.autorun, isTrue);
  });

  test('values come from the defines, trimmed [T-02.3]', () {
    final config = HarnessConfig.parse(<String, String>{
      'LIBS': ' pdfx ',
      'LARGE_PDF': '/tmp/fx_pdf_05.pdf',
      'BASE_WIDTH': '720',
      'AUTORUN': 'false',
      'DEVICE_LABEL': 'phone A',
    });
    expect(config.libs, <String>['pdfx']);
    expect(config.largePdf, '/tmp/fx_pdf_05.pdf');
    expect(config.baseWidthPx, 720);
    expect(config.autorun, isFalse);
    expect(config.deviceLabel, 'phone A');
  });

  test('an unknown library name is rejected [T-02.3]', () {
    expect(
      () => HarnessConfig.parse(<String, String>{'LIBS': 'pdfrx,other'}),
      throwsArgumentError,
    );
  });

  test('recorded versions match pubspec.lock [P-DEP]', () {
    final lock = File('pubspec.lock').readAsStringSync();
    String versionOf(String name) {
      final match = RegExp(
        '^  $name:\\n(?:    .*\\n)*?    version: "([^"]+)"',
        multiLine: true,
      ).firstMatch(lock);
      return match!.group(1)!;
    }

    expect(pdfrxVersion, versionOf('pdfrx'));
    expect(pdfxVersion, versionOf('pdfx'));
  });
}
