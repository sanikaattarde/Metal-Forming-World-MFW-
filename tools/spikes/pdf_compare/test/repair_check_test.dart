import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_compare/src/config.dart';
import 'package:pdf_compare/src/engines.dart';
import 'package:pdf_compare/src/memory.dart';
import 'package:pdf_compare/src/runner.dart';

const _referencePath = '/x/fx_pdf_01.pdf';
const _subjectPath = '/x/fx_pdf_11.pdf';

/// Four pixels of one grey level; level 255 is a blank (white) page.
Uint8List _page(int level) => Uint8List(16)..fillRange(0, 16, level);

/// A scripted engine: pages are four-pixel images whose grey level follows the
/// path and page number, so a test can make any page equal, different or blank.
class _ScriptedEngine implements PdfEngine {
  _ScriptedEngine({
    this.pageCounts = const <String, int>{},
    this.failOpen = const <String>{},
    this.levels = const <(String, int), int>{},
    this.failRender = const <(String, int)>{},
  });

  final Map<String, int> pageCounts;
  final Set<String> failOpen;
  final Map<(String, int), int> levels;
  final Set<(String, int)> failRender;
  int opens = 0;
  int closes = 0;

  @override
  String get name => 'fake';

  @override
  String get version => '0.0.0';

  @override
  Future<void> initialize() async {}

  @override
  Future<EngineDocument> open(String path) async {
    opens++;
    if (failOpen.contains(path)) {
      throw const FormatException('cannot open this file');
    }
    return _ScriptedDocument(this, path);
  }
}

class _ScriptedDocument implements EngineDocument {
  _ScriptedDocument(this._engine, this._path);

  final _ScriptedEngine _engine;
  final String _path;

  @override
  int get pageCount => _engine.pageCounts[_path] ?? 4;

  @override
  Future<PageRender> render(int pageNumber, {required int widthPx}) async {
    if (_engine.failRender.contains((_path, pageNumber))) {
      throw StateError('render failed for page $pageNumber');
    }
    final level = _engine.levels[(_path, pageNumber)] ?? 10 * pageNumber;
    return PageRender(
      pageNumber: pageNumber,
      width: 2,
      height: 2,
      renderMs: 1,
      decodeMs: 1,
      readRgba: () async => _page(level),
      dispose: () {},
    );
  }

  @override
  Future<void> close() async {
    _engine.closes++;
  }
}

const _reference = PdfInput(
  id: 'FX-PDF-01',
  path: _referencePath,
  expectError: false,
  fullScenarios: true,
);
const _subject = PdfInput(
  id: 'FX-PDF-11',
  path: _subjectPath,
  expectError: true,
  fullScenarios: false,
);

Future<Map<String, Object?>> _run(
  _ScriptedEngine engine, {
  RepairCheck? check = const RepairCheck(
    reference: _reference,
    subject: _subject,
  ),
}) async {
  final result = await HarnessRunner(
    config: HarnessConfig.parse(const <String, String>{}),
    engines: <PdfEngine>[engine],
    inputs: const <PdfInput>[],
    repairCheck: check,
    sampler: RssSampler(readRss: () => 100 * 1024 * 1024),
    environment: const <String, Object?>{'os': 'test'},
    log: (_) {},
    onSnapshot: (_) {},
  ).run();
  final engines = result['engines']! as Map<String, Object?>;
  final fake = engines['fake']! as Map<String, Object?>;
  return fake.containsKey('repairCheck')
      ? fake['repairCheck']! as Map<String, Object?>
      : <String, Object?>{};
}

List<Map<String, Object?>> _pages(Map<String, Object?> check) =>
    (check['pages']! as List<Object?>).cast<Map<String, Object?>>();

void main() {
  test(
    'four equal pages are all drawn and all identical [FX-PDF-11]',
    () async {
      final check = await _run(_ScriptedEngine());
      expect(check['reference'], 'FX-PDF-01');
      expect(check['subject'], 'FX-PDF-11');
      expect(check['pageCountsMatch'], isTrue);
      expect(check['pagesCompared'], 4);
      expect(check['pagesIdentical'], 4);
      expect(check['pagesDifferent'], 0);
      expect(check['pagesFailed'], 0);
      expect(check['subjectPagesDrawn'], 4);
      expect(check['allPagesIdentical'], isTrue);
      expect(_pages(check).map((page) => page['page']), <int>[1, 2, 3, 4]);
    },
  );

  test('a page that differs is named and counted [FX-PDF-11]', () async {
    final check = await _run(
      _ScriptedEngine(
        levels: const <(String, int), int>{(_subjectPath, 3): 90},
      ),
    );
    expect(check['pagesIdentical'], 3);
    expect(check['pagesDifferent'], 1);
    expect(check['allPagesIdentical'], isFalse);
    final page3 = _pages(check)[2];
    final comparison = page3['comparison']! as Map<String, Object?>;
    expect(comparison['identical'], isFalse);
    expect(comparison['differingPixels'], 4);
    expect(comparison['maxChannelDifference'], 60);
  });

  test(
    'a blank page in the repaired file is reported as blank [FX-PDF-11]',
    () async {
      final check = await _run(
        _ScriptedEngine(
          levels: const <(String, int), int>{(_subjectPath, 2): 255},
        ),
      );
      expect(check['subjectPagesDrawn'], 3);
      final page2 = _pages(check)[1];
      expect(page2['subjectDrawn'], isFalse);
      expect(page2['referenceDrawn'], isTrue);
      expect(check['pagesDifferent'], 1);
    },
  );

  test('a render error on one page is recorded and the others still compare [FX-PDF-11]', () async {
    final check = await _run(
      _ScriptedEngine(failRender: const <(String, int)>{(_subjectPath, 4)}),
    );
    expect(check['pagesFailed'], 1);
    expect(check['pagesCompared'], 3);
    expect(check['pagesIdentical'], 3);
    expect(check['allPagesIdentical'], isFalse);
    final page4 = _pages(check)[3];
    expect(page4['ok'], isFalse);
    final error = page4['subjectError']! as Map<String, Object?>;
    expect(error['type'], 'StateError');
    expect(page4['referenceDrawn'], isTrue);
  });

  test('a subject that cannot be opened gives an error and nothing to compare [FX-PDF-11]', () async {
    final engine = _ScriptedEngine(failOpen: const <String>{_subjectPath});
    final check = await _run(engine);
    final error = check['subjectOpenError']! as Map<String, Object?>;
    expect(error['type'], 'FormatException');
    expect(check['pagesCompared'], 0);
    expect(check.containsKey('pages'), isFalse);
    expect(check['allPagesIdentical'], isFalse);
    // The reference was opened and closed; the subject never opened.
    expect(engine.opens, 2);
    expect(engine.closes, 1);
  });

  test('a different page count is recorded and only the shared pages compare [FX-PDF-11]', () async {
    final check = await _run(
      _ScriptedEngine(pageCounts: const <String, int>{_subjectPath: 3}),
    );
    expect(check['referencePageCount'], 4);
    expect(check['subjectPageCount'], 3);
    expect(check['pageCountsMatch'], isFalse);
    expect(check['pagesCompared'], 3);
    expect(check['allPagesIdentical'], isFalse);
  });

  test('every document the check opens is closed [FX-PDF-11]', () async {
    final engine = _ScriptedEngine();
    await _run(engine);
    expect(engine.opens, 2);
    expect(engine.closes, 2);
  });

  test(
    'an input that was skipped skips the check with its reason [FX-PDF-11]',
    () async {
      final check = await _run(
        _ScriptedEngine(),
        check: const RepairCheck(
          reference: _reference,
          subject: PdfInput(
            id: 'FX-PDF-11',
            path: '',
            expectError: true,
            fullScenarios: false,
            skipReason: 'no file',
          ),
        ),
      );
      expect(check['skipReason'], 'no file');
      expect(check.containsKey('pages'), isFalse);
    },
  );

  test(
    'without a repair check the result has no repairCheck entry [FX-PDF-11]',
    () async {
      final check = await _run(_ScriptedEngine(), check: null);
      expect(check, isEmpty);
    },
  );
}
