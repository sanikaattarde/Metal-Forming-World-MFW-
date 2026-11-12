import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/download_resumer.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

final class CountingResumer implements ResumableDownloads {
  int calls = 0;

  @override
  Future<void> resumePending() async => calls++;
}

void main() {
  testWidgets('returning to the foreground resumes stopped downloads '
      '[MOD06-P2-T03, rule 6]', (WidgetTester tester) async {
    final CountingResumer downloads = CountingResumer();
    await tester.pumpWidget(
      DownloadResumer(downloads: downloads, child: const SizedBox()),
    );
    expect(downloads.calls, 0);

    for (final AppLifecycleState state in <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    expect(downloads.calls, 1);
  });

  testWidgets('the copies of deleted issues are swept at the start and on '
      'each return [MOD06-P3-T02]', (WidgetTester tester) async {
    int sweeps = 0;
    await tester.pumpWidget(
      DownloadResumer(
        downloads: CountingResumer(),
        sweep: () async => sweeps++,
        child: const SizedBox(),
      ),
    );
    expect(sweeps, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(sweeps, 2);
  });

  testWidgets('a sweep that fails does not stop the app', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      DownloadResumer(
        downloads: CountingResumer(),
        sweep: () async => throw StateError('offline'),
        child: const Text('app', textDirection: TextDirection.ltr),
      ),
    );
    await tester.pump();
    expect(find.text('app'), findsOneWidget);
  });
}
