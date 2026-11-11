// MOD02-P2-T01: crash reports with no reader identity (NFR-OBS-001,
// DATA-014), redacted, off unless CFG-11 switches them on, and never
// throwing. No crash service is connected (DEC-028, C-07), so the forced
// crash on Android and iOS waits for it.
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/core/monitoring/crash_reporter.dart';

import '../../fakes/recording_app_logger.dart';

final class RecordingCrashSink implements CrashSink {
  final List<CrashReport> sent = <CrashReport>[];
  bool fail = false;

  @override
  Future<void> send(CrashReport report) async {
    if (fail) {
      throw StateError('down');
    }
    sent.add(report);
  }
}

void main() {
  late RecordingCrashSink sink;
  late RecordingAppLogger logger;

  setUp(() {
    sink = RecordingCrashSink();
    logger = RecordingAppLogger();
  });

  test('switched off, nothing is sent', () async {
    final GuardedCrashReporter reporter = GuardedCrashReporter(
      enabled: false,
      sink: sink,
    );
    await reporter.recordFatal(StateError('x'), StackTrace.current);
    await reporter.recordNonFatal(StateError('x'), StackTrace.current);
    expect(sink.sent, isEmpty);
  });

  test('DATA-014: a report is redacted, so an address or a signed link never leaves the device', () async {
    final GuardedCrashReporter reporter = GuardedCrashReporter(
      enabled: true,
      sink: sink,
    );
    await reporter.recordNonFatal(
      StateError(
        'failed for reader@example.test at '
        'https://storage.example.test/f.pdf?X-Goog-Signature=abc123',
      ),
      StackTrace.current,
    );
    final CrashReport report = sink.sent.single;
    expect(report.fatal, isFalse);
    expect(report.error, isNot(contains('reader@example.test')));
    expect(report.error, isNot(contains('abc123')));
    expect(report.stack, contains('crash_reporter_test.dart'));
  });

  test('a fatal crash is marked fatal', () async {
    await GuardedCrashReporter(
      enabled: true,
      sink: sink,
    ).recordFatal(StateError('x'), StackTrace.current);
    expect(sink.sent.single.fatal, isTrue);
  });

  test(
    'a sink that fails writes one log line, and nothing is thrown',
    () async {
      sink.fail = true;
      await GuardedCrashReporter(
        enabled: true,
        sink: sink,
        logger: logger,
      ).recordFatal(StateError('x'), StackTrace.current);
      expect(logger.records.single.message, 'crash report not sent');
    },
  );

  test('the handlers send uncaught Flutter and platform errors as fatal, after the earlier ones', () async {
    final FlutterExceptionHandler? flutterBefore = FlutterError.onError;
    final ErrorCallback? platformBefore = PlatformDispatcher.instance.onError;
    final List<Object> earlier = <Object>[];
    FlutterError.onError = (FlutterErrorDetails d) => earlier.add(d.exception);
    PlatformDispatcher.instance.onError = (Object e, StackTrace s) {
      earlier.add(e);
      return true;
    };
    try {
      installCrashHandlers(GuardedCrashReporter(enabled: true, sink: sink));
      FlutterError.onError!(
        FlutterErrorDetails(
          exception: StateError('frame'),
          stack: StackTrace.current,
        ),
      );
      final bool handled = PlatformDispatcher.instance.onError!(
        StateError('platform'),
        StackTrace.current,
      );
      await Future<void>.delayed(Duration.zero);
      expect(handled, isTrue);
      expect(earlier, hasLength(2));
      expect(sink.sent.map((CrashReport r) => r.fatal), <bool>[true, true]);
      expect(sink.sent.first.error, contains('frame'));
    } finally {
      FlutterError.onError = flutterBefore;
      PlatformDispatcher.instance.onError = platformBefore;
    }
  });
}
