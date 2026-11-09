import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kReleaseMode;

import 'redaction.dart';

/// The logger every module uses (MOD-02, `API_AND_MODULE_CONTRACTS.md`
/// section 6.2). Never use `print` (`CODING_STANDARDS.md` section 6.2).
abstract interface class AppLogger {
  /// Development builds only.
  void debug(String message, {Map<String, Object?> context = const {}});

  /// Normal events.
  void info(String message, {Map<String, Object?> context = const {}});

  /// Something unexpected that the app recovered from.
  void warning(String message, {Map<String, Object?> context = const {}});

  /// A failure, with the [error] and [stackTrace] if there are any.
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  });
}

/// Log levels (`CODING_STANDARDS.md` section 6.2, rule 2).
enum LogLevel {
  /// Development builds only.
  debug,

  /// Normal events.
  info,

  /// Recovered problems.
  warning,

  /// Failures.
  error,
}

/// One log line after redaction.
final class LogRecord {
  /// Creates a record. Every text in it is already redacted.
  const LogRecord({
    required this.time,
    required this.level,
    required this.message,
    this.context = const <String, Object?>{},
    this.error,
    this.stackTrace,
  });

  /// When it was logged, from the logger's clock.
  final DateTime time;

  /// The level.
  final LogLevel level;

  /// The message, redacted.
  final String message;

  /// The context, with sensitive keys replaced and values redacted.
  final Map<String, Object?> context;

  /// The error's text, redacted.
  final String? error;

  /// The stack trace: code locations only, with no values.
  final StackTrace? stackTrace;
}

/// Where redacted records go.
typedef LogSink = void Function(LogRecord record);

/// [AppLogger] that redacts every message, context value and error text
/// (`Redactor`) before a record reaches its sink, so no caller can write
/// personal data or a secret that the rules recognise (SC-16, SEC-CHK-10).
///
/// It never throws (`API_AND_MODULE_CONTRACTS.md` section 6.2): a sink that
/// fails is reported once on the development console and the record is
/// dropped.
final class RedactingLogger implements AppLogger {
  /// Creates a logger. [sink] defaults to [developerLogSink]; [debugEnabled]
  /// defaults to true outside release builds; [clock] is injected for tests.
  RedactingLogger({
    LogSink? sink,
    bool? debugEnabled,
    DateTime Function()? clock,
  }) : _sink = sink ?? developerLogSink,
       _debugEnabled = debugEnabled ?? !kReleaseMode,
       _clock = clock ?? DateTime.now;

  final LogSink _sink;
  final bool _debugEnabled;
  final DateTime Function() _clock;

  @override
  void debug(String message, {Map<String, Object?> context = const {}}) {
    if (_debugEnabled) {
      _emit(LogLevel.debug, message, context);
    }
  }

  @override
  void info(String message, {Map<String, Object?> context = const {}}) =>
      _emit(LogLevel.info, message, context);

  @override
  void warning(String message, {Map<String, Object?> context = const {}}) =>
      _emit(LogLevel.warning, message, context);

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) => _emit(LogLevel.error, message, context, error, stackTrace);

  void _emit(
    LogLevel level,
    String message,
    Map<String, Object?> context, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    try {
      _sink(
        LogRecord(
          time: _clock(),
          level: level,
          message: Redactor.text(message),
          context: Redactor.context(context),
          error: error == null ? null : Redactor.error(error),
          stackTrace: stackTrace,
        ),
      );
    } on Object catch (e) {
      // The logger never throws. Only the failure's type is written.
      developer.log('log sink failed: ${e.runtimeType}', name: 'mfw');
    }
  }
}

/// Writes a record to the development console through `dart:developer`.
void developerLogSink(LogRecord record) {
  final String context = record.context.isEmpty ? '' : ' ${record.context}';
  developer.log(
    '${record.message}$context',
    time: record.time,
    name: 'mfw',
    level: switch (record.level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
    },
    error: record.error,
    stackTrace: record.stackTrace,
  );
}
