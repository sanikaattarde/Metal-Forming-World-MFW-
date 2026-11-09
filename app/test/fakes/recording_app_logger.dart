import 'package:mfw_app/core/logging/app_logger.dart';

/// An [AppLogger] for tests that keeps every record in [records], after the
/// same redaction as in the app (MOD-02, maintained by WS-A).
///
/// Debug lines are kept, and the clock is fixed at 9 November 2026, so a
/// test can check what a module logs without reading the console.
final class RecordingAppLogger implements AppLogger {
  /// Creates a logger with no records.
  RecordingAppLogger() {
    _logger = RedactingLogger(
      sink: records.add,
      debugEnabled: true,
      clock: () => DateTime.utc(2026, 11, 9),
    );
  }

  /// The records, oldest first, already redacted.
  final List<LogRecord> records = <LogRecord>[];

  late final RedactingLogger _logger;

  @override
  void debug(String message, {Map<String, Object?> context = const {}}) =>
      _logger.debug(message, context: context);

  @override
  void info(String message, {Map<String, Object?> context = const {}}) =>
      _logger.info(message, context: context);

  @override
  void warning(String message, {Map<String, Object?> context = const {}}) =>
      _logger.warning(message, context: context);

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) => _logger.error(
    message,
    error: error,
    stackTrace: stackTrace,
    context: context,
  );
}
