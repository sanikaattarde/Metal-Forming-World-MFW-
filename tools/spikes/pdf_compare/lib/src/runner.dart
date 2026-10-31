import 'dart:async';

import 'config.dart';
import 'engines.dart';
import 'memory.dart';
import 'pixels.dart';
import 'stats.dart';

/// One PDF the harness is given. [fullScenarios] adds the page turns and the
/// 300% render to the first-page timing. A [skipReason] means it is not run.
class PdfInput {
  const PdfInput({
    required this.id,
    required this.path,
    required this.expectError,
    required this.fullScenarios,
    this.skipReason,
  });

  final String id;
  final String path;

  /// True for FX-PDF-10 and FX-PDF-11, which must produce an error.
  final bool expectError;
  final bool fullScenarios;
  final String? skipReason;
}

/// Runs the same scenarios on each engine and each input, and builds the
/// result map that is written as JSON. Nothing here throws on a PDF problem:
/// every exception becomes an entry in the result.
class HarnessRunner {
  HarnessRunner({
    required this.config,
    required this.engines,
    required this.inputs,
    required this.sampler,
    required this.environment,
    required this.log,
    required this.onSnapshot,
    this.uncaughtErrors = const <Map<String, Object?>>[],
  });

  final HarnessConfig config;
  final List<PdfEngine> engines;
  final List<PdfInput> inputs;
  final RssSampler sampler;
  final Map<String, Object?> environment;
  final void Function(String line) log;

  /// Called with the whole result after each file, so a crash keeps what ran.
  final void Function(Map<String, Object?> snapshot) onSnapshot;

  /// Errors that reached the Flutter error hooks instead of a try block.
  final List<Map<String, Object?>> uncaughtErrors;

  Future<Map<String, Object?>> run() async {
    final engineResults = <String, Object?>{};
    final harness = <String, Object?>{
      'name': 'pdf_compare',
      'schema': 1,
      'startedAt': DateTime.now().toUtc().toIso8601String(),
      'baseWidthPx': config.baseWidthPx,
      'zoomFactor': config.zoomFactor,
      'turns': config.turns,
      'firstPageReps': config.firstPageReps,
      'zoomReps': config.zoomReps,
      'enginesInThisProcess': engines.map((e) => e.name).toList(),
    };
    final result = <String, Object?>{
      'harness': harness,
      'environment': environment,
      'engines': engineResults,
      'uncaughtErrors': uncaughtErrors,
    };

    for (final engine in engines) {
      final files = <Map<String, Object?>>[];
      final entry = <String, Object?>{
        'version': engine.version,
        'files': files,
      };
      engineResults[engine.name] = entry;
      try {
        final (_, initMs) = await _timed(engine.initialize);
        entry['initMs'] = round1(initMs);
      } on Object catch (error, stack) {
        entry['initError'] = errorRecord('initialize', error, stack);
      }
      for (final input in inputs) {
        log('${engine.name} ${input.id}: start');
        files.add(await _runFile(engine, input));
        onSnapshot(result);
      }
      entry['processMaxRssMiBAfterThisEngine'] = round1(sampler.processMaxMiB);
    }
    harness['finishedAt'] = DateTime.now().toUtc().toIso8601String();
    onSnapshot(result);
    return result;
  }

  Future<Map<String, Object?>> _runFile(
    PdfEngine engine,
    PdfInput input,
  ) async {
    final file = <String, Object?>{
      'id': input.id,
      'file': input.path.split('/').last,
      'expectError': input.expectError,
    };
    final skipReason = input.skipReason;
    if (skipReason != null) {
      file['outcome'] = 'skipped';
      file['skipReason'] = skipReason;
      log('${engine.name} ${input.id}: skipped ($skipReason)');
      return file;
    }

    final firstPage = await _firstPage(engine, input);
    file['firstPage'] = firstPage;
    final reps = (firstPage['reps']! as List<Object?>)
        .cast<Map<String, Object?>>();
    final okRep = reps.where((rep) => rep['ok'] == true).firstOrNull;
    file['outcome'] = okRep == null ? 'error' : 'opened';
    file['matchesExpectation'] = (okRep == null) == input.expectError;
    if (okRep != null) {
      file['pageCount'] = okRep['pageCount'];
    }
    if (input.fullScenarios && okRep != null) {
      file['pageTurns'] = await _pageTurns(engine, input);
      file['zoom300'] = await _zoom(engine, input);
    }
    log('${engine.name} ${input.id}: ${file['outcome']}');
    return file;
  }

  Future<Map<String, Object?>> _firstPage(
    PdfEngine engine,
    PdfInput input,
  ) async {
    final reps = <Map<String, Object?>>[];
    for (var index = 1; index <= config.firstPageReps; index++) {
      final rep = await _firstPageRep(engine, input);
      rep['rep'] = index;
      reps.add(rep);
      log(
        '${engine.name} ${input.id} first page rep $index: '
        '${rep['ok'] == true ? '${rep['totalMs']} ms' : 'error'}',
      );
    }
    final totals = reps
        .where((rep) => rep['ok'] == true)
        .map((rep) => rep['totalMs']! as double)
        .toList();
    return <String, Object?>{
      'widthPx': config.baseWidthPx,
      'reps': reps,
      'totalMs': summarize(totals),
    };
  }

  /// A fresh open, then page 1 as a Flutter image: the time a reader waits.
  Future<Map<String, Object?>> _firstPageRep(
    PdfEngine engine,
    PdfInput input,
  ) async {
    final rep = <String, Object?>{'rssBeforeMiB': round1(sampler.currentMiB)};
    EngineDocument? document;
    PageRender? page;
    sampler.begin();
    try {
      final wall = Stopwatch()..start();
      final (opened, openMs) = await _timed(() => engine.open(input.path));
      document = opened;
      rep['openMs'] = round1(openMs);
      rep['pageCount'] = document.pageCount;
      page = await document.render(1, widthPx: config.baseWidthPx);
      wall.stop();
      rep['renderMs'] = round1(page.renderMs);
      rep['decodeMs'] = round1(page.decodeMs);
      rep['totalMs'] = round1(wall.elapsedMicroseconds / 1000);
      rep['pixelWidth'] = page.width;
      rep['pixelHeight'] = page.height;
      rep['encodedBytes'] = page.encodedBytes;
      rep['nonWhiteFraction'] = _round3(
        nonWhiteFraction(await page.readRgba()),
      );
      rep['ok'] = true;
    } on Object catch (error, stack) {
      rep['ok'] = false;
      rep['error'] = errorRecord('firstPage', error, stack);
    } finally {
      rep['rssPeakMiB'] = round1(sampler.end());
      page?.dispose();
      await _closeQuietly(document, rep);
      rep['rssAfterMiB'] = round1(sampler.currentMiB);
    }
    return rep;
  }

  /// One open, then [HarnessConfig.turns] page turns in a row (AC-2.5). A page
  /// that fails is counted and the next turn still runs.
  Future<Map<String, Object?>> _pageTurns(
    PdfEngine engine,
    PdfInput input,
  ) async {
    final out = <String, Object?>{
      'widthPx': config.baseWidthPx,
      'turnsRequested': config.turns,
      'rssBeforeMiB': round1(sampler.currentMiB),
    };
    final turns = <Map<String, Object?>>[];
    final errors = <Map<String, Object?>>[];
    EngineDocument? document;
    sampler.begin();
    try {
      final (opened, openMs) = await _timed(() => engine.open(input.path));
      document = opened;
      out['openMs'] = round1(openMs);
      out['pageCount'] = document.pageCount;
      try {
        final first = await document.render(1, widthPx: config.baseWidthPx);
        first.dispose();
      } on Object catch (error, stack) {
        errors.add(errorRecord('initialPage', error, stack));
      }
      for (var turn = 1; turn <= config.turns; turn++) {
        // Starts on page 1; a short file wraps back to its first page.
        final pageNumber = turn % document.pageCount + 1;
        turns.add(await _turn(document, turn, pageNumber, errors));
      }
    } on Object catch (error, stack) {
      out['openError'] = errorRecord('open', error, stack);
      errors.add(out['openError']! as Map<String, Object?>);
    } finally {
      out['rssPeakMiB'] = round1(sampler.end());
      await _closeQuietly(document, out);
      out['rssAfterMiB'] = round1(sampler.currentMiB);
    }
    final okTurns = turns.where((turn) => turn['ok'] == true).toList();
    out['turns'] = turns;
    out['turnsRun'] = turns.length;
    out['turnsOk'] = okTurns.length;
    out['errorCount'] = errors.length;
    out['errors'] = errors;
    out['passed'] = okTurns.length == config.turns && errors.isEmpty;
    out['totalMs'] = summarize(
      okTurns.map((turn) => turn['totalMs']! as double).toList(),
    );
    out['renderMs'] = summarize(
      okTurns.map((turn) => turn['renderMs']! as double).toList(),
    );
    log(
      '${engine.name} ${input.id} page turns: ${okTurns.length} of '
      '${config.turns} ok, ${errors.length} errors',
    );
    return out;
  }

  Future<Map<String, Object?>> _turn(
    EngineDocument document,
    int turn,
    int pageNumber,
    List<Map<String, Object?>> errors,
  ) async {
    final record = <String, Object?>{'turn': turn, 'page': pageNumber};
    PageRender? page;
    try {
      final wall = Stopwatch()..start();
      page = await document.render(pageNumber, widthPx: config.baseWidthPx);
      wall.stop();
      record['renderMs'] = round1(page.renderMs);
      record['decodeMs'] = round1(page.decodeMs);
      record['totalMs'] = round1(wall.elapsedMicroseconds / 1000);
      record['nonWhiteFraction'] = _round3(
        nonWhiteFraction(await page.readRgba(), stride: 31),
      );
      record['ok'] = true;
    } on Object catch (error, stack) {
      record['ok'] = false;
      final failure = errorRecord(
        'turn $turn (page $pageNumber)',
        error,
        stack,
      );
      record['error'] = failure;
      errors.add(failure);
    } finally {
      page?.dispose();
    }
    return record;
  }

  /// Page 1 at [HarnessConfig.zoomFactor] times the base width (AC-2.3).
  Future<Map<String, Object?>> _zoom(PdfEngine engine, PdfInput input) async {
    final widthPx = (config.baseWidthPx * config.zoomFactor).round();
    final out = <String, Object?>{
      'zoomFactor': config.zoomFactor,
      'widthPx': widthPx,
    };
    final reps = <Map<String, Object?>>[];
    EngineDocument? document;
    try {
      final (opened, openMs) = await _timed(() => engine.open(input.path));
      document = opened;
      out['openMs'] = round1(openMs);
      for (var index = 1; index <= config.zoomReps; index++) {
        reps.add(await _zoomRep(document, index, widthPx));
      }
    } on Object catch (error, stack) {
      out['openError'] = errorRecord('open', error, stack);
    } finally {
      await _closeQuietly(document, out);
    }
    out['reps'] = reps;
    out['totalMs'] = summarize(
      reps
          .where((rep) => rep['ok'] == true)
          .map((rep) => rep['totalMs']! as double)
          .toList(),
    );
    log(
      '${engine.name} ${input.id} 300%: '
      '${reps.where((rep) => rep['ok'] == true).length} of '
      '${config.zoomReps} ok',
    );
    return out;
  }

  Future<Map<String, Object?>> _zoomRep(
    EngineDocument document,
    int index,
    int widthPx,
  ) async {
    final rep = <String, Object?>{
      'rep': index,
      'rssBeforeMiB': round1(sampler.currentMiB),
    };
    PageRender? page;
    sampler.begin();
    try {
      final wall = Stopwatch()..start();
      page = await document.render(1, widthPx: widthPx);
      wall.stop();
      rep['renderMs'] = round1(page.renderMs);
      rep['decodeMs'] = round1(page.decodeMs);
      rep['totalMs'] = round1(wall.elapsedMicroseconds / 1000);
      rep['pixelWidth'] = page.width;
      rep['pixelHeight'] = page.height;
      rep['encodedBytes'] = page.encodedBytes;
      rep['nonWhiteFraction'] = _round3(
        nonWhiteFraction(await page.readRgba(), stride: 53),
      );
      rep['ok'] = true;
    } on Object catch (error, stack) {
      rep['ok'] = false;
      rep['error'] = errorRecord('zoom render', error, stack);
    } finally {
      rep['rssPeakMiB'] = round1(sampler.end());
      page?.dispose();
      rep['rssAfterMiB'] = round1(sampler.currentMiB);
    }
    return rep;
  }

  Future<void> _closeQuietly(
    EngineDocument? document,
    Map<String, Object?> record,
  ) async {
    if (document == null) {
      return;
    }
    try {
      await document.close();
    } on Object catch (error, stack) {
      record['closeError'] = errorRecord('close', error, stack);
    }
  }
}

Future<(T, double)> _timed<T>(Future<T> Function() body) async {
  final watch = Stopwatch()..start();
  final value = await body();
  watch.stop();
  return (value, watch.elapsedMicroseconds / 1000);
}

double _round3(double value) => (value * 1000).round() / 1000;

/// One exception as a JSON-ready record: where it happened, its type, a
/// trimmed message and the first lines of its stack.
Map<String, Object?> errorRecord(String step, Object error, StackTrace stack) {
  final message = error.toString();
  return <String, Object?>{
    'step': step,
    'type': error.runtimeType.toString(),
    'message': message.length > 400
        ? '${message.substring(0, 400)}...'
        : message,
    'stack': stack.toString().split('\n').take(6).toList(),
  };
}
