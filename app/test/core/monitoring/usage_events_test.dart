// MOD02-P2-T02: usage events from an approved list only, never naming which
// reader opened which issue or page (NFR-OBS-002, NFR-PRIV-003, PAC-09), and
// off in every build until OQ-23 sets the list.
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/core/config/app_config.dart';
import 'package:mfw_app/core/monitoring/monitoring_config.dart';
import 'package:mfw_app/core/monitoring/usage_events.dart';

import '../../fakes/recording_app_logger.dart';

final class RecordingSink implements UsageEventSink {
  final List<UsageEvent> sent = <UsageEvent>[];
  bool fail = false;

  @override
  Future<void> send(UsageEvent event) async {
    if (fail) {
      throw StateError('down');
    }
    sent.add(event);
  }
}

// A TEST list. The real list is empty until OQ-23.
const Map<String, Set<String>> testList = <String, Set<String>>{
  'app_open': <String>{'build'},
  'search_used': <String>{'result_count', 'filtered'},
  'issue_opened': <String>{'issue_id'},
};

void main() {
  late RecordingSink sink;
  late RecordingAppLogger logger;

  setUp(() {
    sink = RecordingSink();
    logger = RecordingAppLogger();
  });

  AllowlistedUsageEvents recorder({
    bool enabled = true,
    Map<String, Set<String>> list = testList,
  }) => AllowlistedUsageEvents(
    enabled: enabled,
    sink: sink,
    approved: list,
    logger: logger,
  );

  test(
    'PAC-09: with the shipped list, nothing is recorded even when switched on',
    () {
      final AllowlistedUsageEvents shipped = AllowlistedUsageEvents(
        enabled: true,
        sink: sink,
      );
      expect(approvedUsageEvents, isEmpty);
      expect(shipped.collecting, isFalse);
      shipped.record(const UsageEvent('app_open'));
      expect(sink.sent, isEmpty);
    },
  );

  test('switched off, nothing is recorded and nothing is logged', () {
    recorder(enabled: false).record(const UsageEvent('app_open'));
    expect(sink.sent, isEmpty);
    expect(logger.records, isEmpty);
  });

  test('an approved event with approved plain values is sent', () async {
    recorder().record(
      const UsageEvent('search_used', <String, Object>{
        'result_count': 4,
        'filtered': true,
      }),
    );
    await Future<void>.delayed(Duration.zero);
    expect(sink.sent.single.name, 'search_used');
  });

  for (final (String why, UsageEvent event) in <(String, UsageEvent)>[
    ('name', const UsageEvent('page_view')),
    ('name', const UsageEvent('App Open')),
    (
      'parameter',
      const UsageEvent('app_open', <String, Object>{'colour': 'red'}),
    ),
    (
      'parameter',
      const UsageEvent('issue_opened', <String, Object>{'issue_id': 'i-1'}),
    ),
    (
      'value',
      const UsageEvent('app_open', <String, Object>{
        'build': 'reader@example.test',
      }),
    ),
    (
      'value',
      const UsageEvent('app_open', <String, Object>{
        'build': 'https://x.example.test/?token=abc',
      }),
    ),
    (
      'value',
      const UsageEvent('search_used', <String, Object>{'result_count': 1.5}),
    ),
  ]) {
    test(
      'refused for its $why: ${event.name} ${event.parameters.keys}',
      () async {
        final AllowlistedUsageEvents events = recorder();
        expect(events.refusal(event), why);
        events.record(event);
        await Future<void>.delayed(Duration.zero);
        expect(sink.sent, isEmpty);
        expect(logger.records.single.message, 'usage event refused');
        expect(logger.records.single.context, <String, Object?>{'why': why});
      },
    );
  }

  test(
    'a parameter naming a reader, an issue or a page is refused even if listed',
    () {
      final AllowlistedUsageEvents events = recorder(
        list: <String, Set<String>>{
          'x': <String>{'user_id', 'page_number', 'post_ref', 'reader_type'},
        },
      );
      for (final String key in <String>[
        'user_id',
        'page_number',
        'post_ref',
        'reader_type',
      ]) {
        expect(
          events.refusal(UsageEvent('x', <String, Object>{key: 1})),
          'parameter',
          reason: key,
        );
      }
    },
  );

  test('a sink that fails is logged once, and record never throws', () async {
    sink.fail = true;
    recorder().record(const UsageEvent('app_open'));
    await Future<void>.delayed(Duration.zero);
    expect(logger.records.single.message, 'usage event not sent');
  });

  group('CFG-11 switches', () {
    test('true, false, empty and replace-me', () {
      expect(
        MonitoringConfig.fromDefines(const <String, String>{})
            .usageEventsEnabled,
        isFalse,
      );
      expect(
        MonitoringConfig.fromDefines(const <String, String>{
          MonitoringConfig.usageEventsKey: 'true',
          MonitoringConfig.crashReportingKey: 'replace-me',
        }).usageEventsEnabled,
        isTrue,
      );
    });

    test('any other value stops the build, naming the key only', () {
      expect(
        () => MonitoringConfig.fromDefines(const <String, String>{
          MonitoringConfig.usageEventsKey: 'yes',
        }),
        throwsA(
          isA<AppConfigException>().having((e) => e.keys, 'keys', <String>[
            MonitoringConfig.usageEventsKey,
          ]),
        ),
      );
    });
  });
}
