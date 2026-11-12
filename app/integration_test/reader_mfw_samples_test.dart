// MOD07-P1-T02 and MOD07-P3-T01 on a device: the reader on MFW's sample
// issues (FX-PDF-03, FX-PDF-04). The samples are not in Git: they are
// copied into the test app's Documents/mfw-samples folder before the run,
// as sample-1.pdf, sample-2.pdf and so on. The run prints numbers only:
// page counts, timings and memory, never a title, text or image.
//
// Build and run (see Documentation/test-evidence/READER_SAMPLES_DEVICE_EVIDENCE.md):
//   flutter build ios --profile --dart-define=MFW_ENV=local \
//     -t integration_test/reader_mfw_samples_test.dart
//
// Lines starting with `DEVICE:` are the facts for the test record.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';
import 'package:pdfrx/pdfrx.dart';

void fact(String line) => debugPrint('DEVICE: $line');

String mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(0);

/// The samples copied in before the run, in name order.
List<File> samples() {
  final Directory container = Directory.systemTemp.parent;
  final Directory folder = Directory('${container.path}/Documents/mfw-samples');
  if (!folder.existsSync()) {
    return <File>[];
  }
  return folder
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.endsWith('.pdf'))
      .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));
}

String nameOf(File file) => file.uri.pathSegments.last;

/// Pumps until a page image shows (pdfrx draws a RawImage once rendered),
/// and returns how long it took.
Future<Duration> untilImage(
  WidgetTester tester, {
  Duration limit = const Duration(seconds: 30),
  int atLeast = 1,
}) async {
  final Stopwatch watch = Stopwatch()..start();
  while (watch.elapsed < limit) {
    await tester.pump(const Duration(milliseconds: 16));
    if (find.byType(RawImage).evaluate().length >= atLeast) {
      return watch.elapsed;
    }
  }
  throw TestFailure('no page image within $limit');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  tearDownAll(() => fact('finished'));

  test('the samples are there', () {
    final List<File> files = samples();
    fact('samples found: ${files.length}');
    expect(files, isNotEmpty);
  });

  test('MOD07-P1-T02: every page of every sample renders [AC-2.2]', () async {
    await pdfrxFlutterInitialize();
    for (final File file in samples()) {
      final Stopwatch open = Stopwatch()..start();
      final PdfDocument document = await PdfDocument.openFile(file.path);
      open.stop();
      int failed = 0;
      int wide = 0;
      int slowestMs = 0;
      int totalMs = 0;
      for (final PdfPage page in document.pages) {
        if (page.width > page.height) {
          wide++;
        }
        // A phone's width at 3x, the size the reader draws at 100%.
        const double width = 1170;
        final double height = width * page.height / page.width;
        final Stopwatch render = Stopwatch()..start();
        final PdfImage? image = await page.render(
          fullWidth: width,
          fullHeight: height,
        );
        render.stop();
        if (image == null) {
          failed++;
        } else {
          image.dispose();
        }
        totalMs += render.elapsedMilliseconds;
        if (render.elapsedMilliseconds > slowestMs) {
          slowestMs = render.elapsedMilliseconds;
        }
      }
      final int pages = document.pages.length;
      fact(
        '${nameOf(file)}: ${mb(file.lengthSync())} MB, $pages pages '
        '($wide wider than tall), opened in ${open.elapsedMilliseconds} ms; '
        'every page drawn at 1170 px wide: $failed failed, '
        'mean ${pages == 0 ? 0 : totalMs ~/ pages} ms, slowest $slowestMs ms',
      );
      await document.dispose();
      expect(failed, 0);
    }
  });

  for (final ReaderMode mode in ReaderMode.values) {
    testWidgets('MOD07-P3-T01: first page, 20 turns and 300% zoom '
        '(${mode.name}) [AC-2.1, AC-2.3, AC-2.5]', (WidgetTester tester) async {
      for (final File file in samples()) {
        final int rssBefore = ProcessInfo.currentRss;
        final Stopwatch first = Stopwatch()..start();
        await tester.pumpWidget(
          MaterialApp(
            theme: buildMfwTheme(),
            home: ReaderScreen(
              key: ValueKey<String>('${file.path} $mode'),
              file: LocalIssueFile(
                issueId: nameOf(file),
                fileRevision: 1,
                path: file.path,
              ),
              title: 'Sample',
              renderer: const PdfrxRenderer(),
              preferences: _Fixed(mode),
            ),
          ),
        );
        final Duration firstPage = await untilImage(tester);
        first.stop();
        fact(
          '${nameOf(file)} ${mode.name}: first page ${firstPage.inMilliseconds} '
          'ms, memory ${mb(ProcessInfo.currentRss)} MB',
        );

        // AC-2.5: 20 page turns with the Next button, each until its page
        // image shows.
        final Finder next = find.widgetWithIcon(
          IconButton,
          Icons.chevron_right,
        );
        final List<int> turns = <int>[];
        for (int i = 0; i < 20; i++) {
          if (tester.widget<IconButton>(next).onPressed == null) {
            break;
          }
          final Stopwatch turn = Stopwatch()..start();
          await tester.tap(next);
          await tester.pumpAndSettle(const Duration(milliseconds: 16));
          await untilImage(tester);
          turns.add(turn.elapsedMilliseconds);
          if (i % 5 == 4) {
            fact(
              '${nameOf(file)} ${mode.name}: turn ${i + 1}, memory '
              '${mb(ProcessInfo.currentRss)} MB',
            );
          }
        }
        turns.sort();
        final int rssPaged = ProcessInfo.currentRss;

        // AC-2.3: zoom to 300% with a pinch, then the sharper redraw.
        final Offset centre = tester.getCenter(
          find.byKey(ReaderScreen.pagesKey),
        );
        final TestGesture a = await tester.startGesture(
          centre - const Offset(20, 0),
          pointer: 11,
        );
        final TestGesture b = await tester.startGesture(
          centre + const Offset(20, 0),
          pointer: 12,
        );
        await tester.pump();
        for (int i = 0; i < 10; i++) {
          await a.moveBy(const Offset(-15, 0));
          await b.moveBy(const Offset(15, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await a.up();
        await b.up();
        fact(
          '${nameOf(file)} ${mode.name}: pinched, memory '
          '${mb(ProcessInfo.currentRss)} MB',
        );
        final Stopwatch sharp = Stopwatch()..start();
        // Give the redraw time: it keeps the old image until the new one.
        for (int i = 0; i < 300; i++) {
          await tester.pump(const Duration(milliseconds: 16));
        }
        sharp.stop();
        final ZoomableUnitState zoom = tester.state<ZoomableUnitState>(
          find.byType(ZoomableUnit),
        );
        final int rssZoomed = ProcessInfo.currentRss;

        fact(
          '${nameOf(file)} ${mode.name}: first page in '
          '${firstPage.inMilliseconds} ms; ${turns.length} turns, median '
          '${turns.isEmpty ? 0 : turns[turns.length ~/ 2]} ms, slowest '
          '${turns.isEmpty ? 0 : turns.last} ms; zoom ${zoom.scale.toStringAsFixed(2)}x '
          'drawn at ${zoom.sharpness}x; memory ${mb(rssBefore)} MB before, '
          '${mb(rssPaged)} MB after the turns, ${mb(rssZoomed)} MB zoomed, '
          'peak ${mb(ProcessInfo.maxRss)} MB',
        );
        expect(firstPage, lessThan(const Duration(seconds: 3)));
        expect(turns.length, 20);

        // Close the reader before the next sample.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 200));
      }
    }, timeout: const Timeout(Duration(minutes: 10)));
  }
}

final class _Fixed implements ReaderPreferences {
  const _Fixed(this._mode);

  final ReaderMode _mode;

  @override
  Future<ReaderMode> mode() async => _mode;

  @override
  Future<void> setMode(ReaderMode mode) async {}
}
