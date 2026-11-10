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
}
