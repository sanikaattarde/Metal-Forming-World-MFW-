import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../logging/app_logger.dart';
import '../logging/redaction.dart';

/// Crash reporting (MOD02-P2-T01, RS NFR-OBS-001, `API_AND_MODULE_CONTRACTS.md`
/// section 6.2).
abstract interface class CrashReporter {
  /// Records a crash that stopped the app or a frame.
  Future<void> recordFatal(Object error, StackTrace stackTrace);

  /// Records a failure the app recovered from.
  Future<void> recordNonFatal(Object error, StackTrace stackTrace);
}

/// A crash as it leaves the device: redacted text only, and nothing that
/// names a reader (DATA-014).
final class CrashReport {
  /// Creates a report.
  const CrashReport({
    required this.error,
    required this.stack,
    required this.fatal,
  });

  /// The error's text, redacted (`CODING_STANDARDS.md` section 6.2).
  final String error;

  /// The stack trace, redacted.
  final String stack;

  /// Whether it stopped the app or a frame.
  final bool fatal;
}

/// Where reports go: MFW's crash service, which DEC-028 and C-07 leave to
/// confirm. It has no way to name a reader: no user identifier can be set
/// (NFR-OBS-001). None is connected, so [NoCrashSink] is the only one.
abstract interface class CrashSink {
  /// Sends [report].
  Future<void> send(CrashReport report);
}

/// Sends nothing: no crash service is connected yet.
final class NoCrashSink implements CrashSink {
  /// Creates the sink.
  const NoCrashSink();

  @override
  Future<void> send(CrashReport report) async {}
}

/// [CrashReporter] over a [CrashSink] (MOD02-P2-T01): off unless CFG-11
/// switches it on, every text redacted, and never throwing. A report that
/// cannot be sent writes one local log line.
final class GuardedCrashReporter implements CrashReporter {
  /// Creates the reporter.
  GuardedCrashReporter({
    required this._enabled,
    this._sink = const NoCrashSink(),
    this._logger,
  });

  final bool _enabled;
  final CrashSink _sink;
  final AppLogger? _logger;

  @override
  Future<void> recordFatal(Object error, StackTrace stackTrace) =>
      _record(error, stackTrace, fatal: true);

  @override
  Future<void> recordNonFatal(Object error, StackTrace stackTrace) =>
      _record(error, stackTrace, fatal: false);

  Future<void> _record(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
  }) async {
    if (!_enabled) {
      return;
    }
    try {
      await _sink.send(
        CrashReport(
          error: Redactor.error(error),
          stack: Redactor.text(stackTrace.toString()),
          fatal: fatal,
        ),
      );
    } on Object {
      _logger?.warning('crash report not sent');
    }
  }
}

/// Sends uncaught Flutter and platform errors to [reporter] as fatal, after
/// the handler that was there before, so a debug build still prints them.
/// `runMfwApp` calls it only when CFG-11 switches crash reporting on.
void installCrashHandlers(CrashReporter reporter) {
  final FlutterExceptionHandler? flutterBefore = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    flutterBefore?.call(details);
    unawaited(
      reporter.recordFatal(
        details.exception,
        details.stack ?? StackTrace.empty,
      ),
    );
  };
  final ErrorCallback? platformBefore = PlatformDispatcher.instance.onError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    unawaited(reporter.recordFatal(error, stack));
    return platformBefore?.call(error, stack) ?? false;
  };
}
