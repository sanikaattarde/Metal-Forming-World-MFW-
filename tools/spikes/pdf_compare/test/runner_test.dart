import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_compare/src/config.dart';
import 'package:pdf_compare/src/engines.dart';
import 'package:pdf_compare/src/memory.dart';
import 'package:pdf_compare/src/runner.dart';

/// A scripted engine: no PDF library, so the runner's bookkeeping is tested alone.
class _FakeEngine implements PdfEngine {
  _FakeEngine({this.failOpen = false, this.failRenderOnCall});

  final int pageCount = 4;
  final bool failOpen;
  final int? failRenderOnCall;
  final List<int> renderedPages = <int>[];
  int opens = 0;
  int closes = 0;
  int _renderCalls = 0;

  @override
  String get name => 'fake';

  @override
  String get version => '0.0.0';

  @override
  Future<void> initialize() async {}

  @override
  Future<EngineDocument> open(String path) async {
    opens++;
    if (failOpen) {
      throw const FormatException('cannot open this file');
    }
    return _FakeDocument(this);
  }
}

class _FakeDocument implements EngineDocument {
  _FakeDocument(this._engine);

  final _FakeEngine _engine;

  @override
  int get pageCount => _engine.pageCount;

  @override
  Future<PageRender> render(int pageNumber, {required int widthPx}) async {
    _engine._renderCalls++;
    if (_engine.failRenderOnCall == _engine._renderCalls) {
      throw StateError('render failed on call ${_engine._renderCalls}');
    }
    _engine.renderedPages.add(pageNumber);
    final height = (widthPx * 1.4).round();
    return PageRender(
      pageNumber: pageNumber,
      width: widthPx,
      height: height,
      renderMs: 2,
      decodeMs: 1,
      readRgba: () async => Uint8List(16)..fillRange(0, 16, 255),
      dispose: () {},
    );
  }

  @override
  Future<void> close() async {
    _engine.closes++;
  }
}

HarnessRunner _runner(
  _FakeEngine engine, {
  required List<PdfInput> inputs,
  int turns = 20,
  List<Map<String, Object?>>? snapshots,
}) {
  return HarnessRunner(
    config: HarnessConfig.parse(<String, String>{'TURNS': '$turns'}),
    engines: <PdfEngine>[engine],
    inputs: inputs,
    sampler: RssSampler(readRss: () => 100 * 1024 * 1024),
    environment: const <String, Object?>{'os': 'test'},
    log: (_) {},
    onSnapshot: (snapshot) => snapshots?.add(snapshot),
  );
}

Map<String, Object?> _file(Map<String, Object?> result, String id) {
  final engines = result['engines']! as Map<String, Object?>;
  final fake = engines['fake']! as Map<String, Object?>;
  final files = fake['files']! as List<Object?>;
  return files.cast<Map<String, Object?>>().firstWhere((f) => f['id'] == id);
}

void main() {
  const healthy = PdfInput(
    id: 'FX-PDF-01',
    path: '/x/fx_pdf_01.pdf',
    expectError: false,
    fullScenarios: true,
  );
  const damaged = PdfInput(
    id: 'FX-PDF-10',
    path: '/x/fx_pdf_10.pdf',
    expectError: true,
    fullScenarios: false,
  );

  test(
    '20 page turns on a healthy file finish with no error [AC-2.5]',
    () async {
      final engine = _FakeEngine();
      final result = await _runner(engine, inputs: [healthy]).run();
      final turns =
          _file(result, 'FX-PDF-01')['pageTurns']! as Map<String, Object?>;
      expect(turns['turnsRequested'], 20);
      expect(turns['turnsRun'], 20);
      expect(turns['turnsOk'], 20);
      expect(turns['errorCount'], 0);
      expect(turns['passed'], isTrue);
    },
  );

  test('page numbers wrap around a four-page file [FX-PDF-01]', () async {
    final engine = _FakeEngine();
    final result = await _runner(engine, inputs: [healthy]).run();
    final turns =
        _file(result, 'FX-PDF-01')['pageTurns']! as Map<String, Object?>;
    final pages = (turns['turns']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((t) => t['page'])
        .toList();
    expect(pages.take(5), <int>[2, 3, 4, 1, 2]);
    expect(pages.length, 20);
  });

  test('a render error on one turn is counted and the other turns still run [AC-2.5]', () async {
    // Calls: 3 first-page renders, then 1 initial page-turn render, then the turns.
    final engine = _FakeEngine(failRenderOnCall: 6);
    final result = await _runner(engine, inputs: [healthy]).run();
    final turns =
        _file(result, 'FX-PDF-01')['pageTurns']! as Map<String, Object?>;
    expect(turns['turnsRun'], 20);
    expect(turns['turnsOk'], 19);
    expect(turns['errorCount'], 1);
    expect(turns['passed'], isFalse);
    final first =
        (turns['errors']! as List<Object?>).first! as Map<String, Object?>;
    expect(first['type'], 'StateError');
  });

  test('a file that cannot be opened is recorded as an error, not thrown [FX-PDF-10]', () async {
    final engine = _FakeEngine(failOpen: true);
    final result = await _runner(engine, inputs: [damaged]).run();
    final file = _file(result, 'FX-PDF-10');
    final reps =
        (file['firstPage']! as Map<String, Object?>)['reps']! as List<Object?>;
    expect(reps, hasLength(3));
    final rep = reps.first! as Map<String, Object?>;
    expect(rep['ok'], isFalse);
    expect((rep['error']! as Map<String, Object?>)['type'], 'FormatException');
    expect(file['outcome'], 'error');
    expect(file['matchesExpectation'], isTrue);
    expect(file.containsKey('pageTurns'), isFalse);
  });

  test(
    'a healthy file that was expected to fail is flagged [FX-PDF-11]',
    () async {
      final engine = _FakeEngine();
      final result = await _runner(engine, inputs: [damaged]).run();
      final file = _file(result, 'FX-PDF-10');
      expect(file['outcome'], 'opened');
      expect(file['matchesExpectation'], isFalse);
    },
  );

  test(
    'first-page time is repeated three times and each open is closed [AC-2.1]',
    () async {
      final engine = _FakeEngine();
      await _runner(engine, inputs: [healthy]).run();
      expect(engine.opens, greaterThanOrEqualTo(3));
      expect(engine.closes, engine.opens);
    },
  );

  test('300% zoom renders at three times the base width [AC-2.3]', () async {
    final engine = _FakeEngine();
    final result = await _runner(engine, inputs: [healthy]).run();
    final zoom = _file(result, 'FX-PDF-01')['zoom300']! as Map<String, Object?>;
    final reps = (zoom['reps']! as List<Object?>).cast<Map<String, Object?>>();
    expect(reps, hasLength(3));
    expect(reps.first['pixelWidth'], 3 * 1080);
    expect(zoom['zoomFactor'], 3.0);
  });

  test(
    'an input without a path is skipped with its reason [FX-PDF-05]',
    () async {
      final engine = _FakeEngine();
      const missing = PdfInput(
        id: 'FX-PDF-05',
        path: '',
        expectError: false,
        fullScenarios: true,
        skipReason: 'LARGE_PDF was not given',
      );
      final result = await _runner(engine, inputs: [missing]).run();
      final file = _file(result, 'FX-PDF-05');
      expect(file['outcome'], 'skipped');
      expect(file['skipReason'], 'LARGE_PDF was not given');
      expect(engine.opens, 0);
    },
  );

  test('a snapshot is delivered after each file so a crash leaves partial results [T-02.3]', () async {
    final engine = _FakeEngine();
    final snapshots = <Map<String, Object?>>[];
    await _runner(
      engine,
      inputs: [healthy, damaged],
      snapshots: snapshots,
    ).run();
    expect(snapshots.length, greaterThanOrEqualTo(2));
  });
}
