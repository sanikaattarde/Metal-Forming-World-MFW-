import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/core/logging/app_logger.dart';
import 'package:mfw_app/core/logging/redaction.dart';

import '../../fakes/recording_app_logger.dart';

void main() {
  group('RedactingLogger [SC-16, SEC-CHK-10]', () {
    test('redacts the message, the context and the error text', () {
      final RecordingAppLogger log = RecordingAppLogger();

      log.error(
        'download failed for reader@example.test',
        error: Exception('grant https://example.test/f.pdf?token=1 refused'),
        stackTrace: StackTrace.empty,
        context: <String, Object?>{'email': 'x', 'issueId': 'fx-issue-01'},
      );

      final LogRecord r = log.records.single;
      expect(r.level, LogLevel.error);
      expect(r.message, 'download failed for [email]');
      expect(
        r.error,
        'Exception: grant https://example.test/f.pdf?[redacted] refused',
      );
      expect(r.context, <String, Object?>{
        'email': Redactor.removed,
        'issueId': 'fx-issue-01',
      });
      expect(r.stackTrace, StackTrace.empty);
    });

    test('writes each level', () {
      final RecordingAppLogger log = RecordingAppLogger();

      log
        ..debug('d')
        ..info('i')
        ..warning('w')
        ..error('e');

      expect(log.records.map((LogRecord r) => r.level), <LogLevel>[
        LogLevel.debug,
        LogLevel.info,
        LogLevel.warning,
        LogLevel.error,
      ]);
    });

    test('drops debug lines when debug is off, as in a release build', () {
      final List<LogRecord> records = <LogRecord>[];
      final RedactingLogger log = RedactingLogger(
        sink: records.add,
        debugEnabled: false,
      );

      log
        ..debug('hidden')
        ..info('shown');

      expect(records.map((LogRecord r) => r.message), <String>['shown']);
    });

    test('takes the time from the injected clock', () {
      final List<LogRecord> records = <LogRecord>[];
      final DateTime at = DateTime.utc(2026, 11, 9, 8, 30);
      RedactingLogger(sink: records.add, clock: () => at).info('x');

      expect(records.single.time, at);
    });

    test('never throws, even when the sink fails', () {
      final RedactingLogger log = RedactingLogger(
        sink: (LogRecord r) => throw StateError('sink down'),
      );

      expect(() => log.error('x', error: Object()), returnsNormally);
    });

    test('writes to the development console by default', () {
      expect(() => RedactingLogger().info('console line'), returnsNormally);
    });
  });
}
