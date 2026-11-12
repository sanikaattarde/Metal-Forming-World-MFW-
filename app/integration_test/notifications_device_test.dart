// MOD11-P2-T02, MOD11-P2-T04, MOD02-P2-T01 and MOD02-P2-T02 on a device: the
// real app reaches SCR-A-20 and the system's permission prompt; the Firebase
// Cloud Messaging adapter answers on a device that has no push credential
// (MOD11-P2-T01 is not done, so a topic subscription is expected to fail);
// the device's choices file lives in the app's own folder; and crash reports
// and usage events are off. A person answers the system prompt on the phone.
//
// Run from `app/` (ENV-LOCAL, no backend reachable from the phone):
//   flutter test integration_test/notifications_device_test.dart -d <id>
// Where the test host cannot attach (the USB port forward refused on an
// iPhone 17 with Flutter 3.47.9), build it as a profile app with
// `flutter build ios --profile -t <this file>`, install it with
// `xcrun devicectl device install app`, and read the console of
// `xcrun devicectl device process launch --console`.
//
// Lines starting with `DEVICE:` are the facts for the test record.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/core/monitoring/crash_reporter.dart';
import 'package:mfw_app/core/monitoring/monitoring_config.dart';
import 'package:mfw_app/core/monitoring/usage_events.dart';
import 'package:mfw_app/features/downloads/downloads.dart';
import 'package:mfw_app/features/notifications/notifications.dart';

void fact(String line) => debugPrint('DEVICE: $line');

/// Pumps until one of [finders] shows, or fails after [timeout].
Future<Finder> pumpUntilAny(
  WidgetTester tester,
  List<Finder> finders, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  final DateTime end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 250));
    for (final Finder finder in finders) {
      if (finder.evaluate().isNotEmpty) {
        return finder;
      }
    }
  }
  throw TestFailure('none of $finders showed within $timeout');
}

Future<String> outcomeOf(Future<void> Function() call) async {
  try {
    await call().timeout(const Duration(seconds: 30));
    return 'ok';
  } on PushError catch (error) {
    return 'PushError(${error.kind})';
  } on TimeoutException {
    return 'timed out after 30 s';
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // A marker for a run read from the device's console, with no test host.
  tearDownAll(() => fact('finished'));

  testWidgets('the app starts, and SCR-A-20 comes before the system prompt', (
    WidgetTester tester,
  ) async {
    // A fresh device record, so an earlier run's answer does not skip the
    // explanation. The system's own answer cannot be reset from here.
    final Directory folder = await PlatformIssueStorage().issueDirectory();
    final File record = File('${folder.path}/notification_choices.json');
    if (await record.exists()) {
      await record.delete();
    }
    await runMfwApp();
    await pumpUntilAny(tester, <Finder>[find.byType(NavigationBar)]);
    fact('the app started and shows the tab bar');

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Settings'),
      ),
    );
    await pumpUntilAny(tester, <Finder>[find.text(NotificationText.title)]);
    fact('Settings shows the Notifications entry');
    await tester.tap(find.text(NotificationText.title));

    final Finder choices = find.text(
      NotificationText.chooseHeading.toUpperCase(),
    );
    final Finder explanation = find.text(NotificationText.explainBody);
    final Finder first = await pumpUntilAny(tester, <Finder>[
      explanation,
      choices,
    ]);
    final PermissionOutcome before = await FirebasePushMessaging()
        .permissionStatus();
    fact('permission before: ${before.name}');

    if (first == explanation) {
      fact('SCR-A-20 explanation shown before any system prompt');
      await tester.tap(find.text(NotificationText.allow));
      fact('ANSWER THE SYSTEM PROMPT ON THE PHONE NOW');
      await pumpUntilAny(tester, <Finder>[
        choices,
      ], timeout: const Duration(minutes: 3));
    } else {
      fact('the explanation was answered on an earlier run');
    }

    final PermissionOutcome after = await FirebasePushMessaging()
        .permissionStatus();
    fact('permission after: ${after.name}');
    expect(after, isNot(PermissionOutcome.notDetermined));

    final int switches = find.byType(SwitchListTile).evaluate().length;
    final bool none = find
        .text(NotificationText.noCategories)
        .evaluate()
        .isNotEmpty;
    final bool failed = find
        .text(NotificationText.loadFailed)
        .evaluate()
        .isNotEmpty;
    fact(
      'SCR-A-21: $switches category switches, '
      'no-categories notice: $none, load-failed notice: $failed',
    );
    if (after == PermissionOutcome.denied) {
      expect(find.text(NotificationText.blocked), findsOneWidget);
      fact('the blocked notice is shown');
    }
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets('the push adapter on a device with no push credential', (
    WidgetTester tester,
  ) async {
    final FirebasePushMessaging push = FirebasePushMessaging();
    final String subscribe = await outcomeOf(
      () => push.subscribe('notif-new-issues'),
    );
    fact('subscribe to notif-new-issues: $subscribe');
    final String unsubscribe = await outcomeOf(
      () => push.unsubscribe('notif-new-issues'),
    );
    fact('unsubscribe from notif-new-issues: $unsubscribe');
    final String unregister = await outcomeOf(push.unregister);
    fact('unregister: $unregister');
    // Each call ends, as an outcome or a PushError, with no crash.
    for (final String outcome in <String>[subscribe, unsubscribe, unregister]) {
      expect(outcome, isNot(startsWith('timed out')));
    }
  });

  testWidgets('the device keeps its notification choices in the app folder', (
    WidgetTester tester,
  ) async {
    final PlatformIssueStorage storage = PlatformIssueStorage();
    final Directory folder = await storage.issueDirectory();
    final JsonDeviceChoices store = JsonDeviceChoices(storage.issueDirectory);
    await store.save(
      const DeviceChoicesRecord(
        explained: true,
        visitorCategories: <String>{'notif-expo-specials'},
      ),
    );
    final DeviceChoicesRecord again = await JsonDeviceChoices(
      storage.issueDirectory,
    ).load();
    expect(again.visitorCategories, <String>{'notif-expo-specials'});
    final File file = File('${folder.path}/notification_choices.json');
    expect(await file.exists(), isTrue);
    fact(
      'choices file written and read back, under the app container: '
      '${folder.path.contains('/Containers/Data/Application/') || folder.path.contains('/Application/')}',
    );
  });

  testWidgets('crash reports and usage events are off in this build', (
    WidgetTester tester,
  ) async {
    final MonitoringConfig config = MonitoringConfig.fromEnvironment();
    expect(config.crashReportingEnabled, isFalse);
    expect(config.usageEventsEnabled, isFalse);
    final AllowlistedUsageEvents events = AllowlistedUsageEvents(enabled: true);
    expect(events.collecting, isFalse);
    final List<CrashReport> sent = <CrashReport>[];
    await GuardedCrashReporter(
      enabled: config.crashReportingEnabled,
      sink: _Recording(sent),
    ).recordFatal(StateError('forced'), StackTrace.current);
    expect(sent, isEmpty);
    fact(
      'CFG-11 off: crash reporting ${config.crashReportingEnabled}, '
      'usage events ${config.usageEventsEnabled}; with the shipped list '
      'usage events collect: ${events.collecting}; a forced crash sent: '
      '${sent.length}',
    );
  });
}

final class _Recording implements CrashSink {
  _Recording(this.sent);

  final List<CrashReport> sent;

  @override
  Future<void> send(CrashReport report) async => sent.add(report);
}
