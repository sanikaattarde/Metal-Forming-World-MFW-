import 'engines.dart';

/// Settings read from --dart-define values. Missing or empty means the default.
///
///   LIBS          pdfrx, pdfx or pdfrx,pdfx (default both)
///   LARGE_PDF     path of FX-PDF-05 on the device; the file is never bundled
///   OUT_DIR       folder for the result JSON (default: the app's temp folder)
///   DEVICE_LABEL  free text for the result file, for example "Pixel 7, phone"
///   BASE_WIDTH    pixel width of "100%" (default 1080)
///   TURNS         page turns for AC-2.5 (default 20)
///   AUTORUN       start on launch (default true)
///   EXIT_WHEN_DONE  end the process after the run (default false)
class HarnessConfig {
  const HarnessConfig({
    required this.libs,
    required this.largePdf,
    required this.outDir,
    required this.deviceLabel,
    required this.baseWidthPx,
    required this.turns,
    required this.firstPageReps,
    required this.zoomReps,
    required this.zoomFactor,
    required this.autorun,
    required this.exitWhenDone,
  });

  factory HarnessConfig.fromEnvironment() =>
      HarnessConfig.parse(const <String, String>{
        'LIBS': String.fromEnvironment('LIBS'),
        'LARGE_PDF': String.fromEnvironment('LARGE_PDF'),
        'OUT_DIR': String.fromEnvironment('OUT_DIR'),
        'DEVICE_LABEL': String.fromEnvironment('DEVICE_LABEL'),
        'BASE_WIDTH': String.fromEnvironment('BASE_WIDTH'),
        'TURNS': String.fromEnvironment('TURNS'),
        'AUTORUN': String.fromEnvironment('AUTORUN'),
        'EXIT_WHEN_DONE': String.fromEnvironment('EXIT_WHEN_DONE'),
      });

  factory HarnessConfig.parse(Map<String, String> values) {
    String text(String key) => (values[key] ?? '').trim();
    int number(String key, int fallback) => int.tryParse(text(key)) ?? fallback;

    final names = text('LIBS').isEmpty
        ? <String>['pdfrx', 'pdfx']
        : text('LIBS')
              .split(',')
              .map((name) => name.trim())
              .where((name) => name.isNotEmpty)
              .toList();
    for (final name in names) {
      if (!knownEngineNames.contains(name)) {
        throw ArgumentError.value(name, 'LIBS', 'unknown library');
      }
    }
    return HarnessConfig(
      libs: names,
      largePdf: text('LARGE_PDF'),
      outDir: text('OUT_DIR'),
      deviceLabel: text('DEVICE_LABEL'),
      baseWidthPx: number('BASE_WIDTH', 1080),
      turns: number('TURNS', 20),
      firstPageReps: 3,
      zoomReps: 3,
      zoomFactor: 3.0,
      autorun: text('AUTORUN') != 'false',
      exitWhenDone: text('EXIT_WHEN_DONE') == 'true',
    );
  }

  final List<String> libs;
  final String largePdf;
  final String outDir;
  final String deviceLabel;

  /// Pixel width that stands for 100%: the page fitted to a 1080 px wide screen.
  final int baseWidthPx;

  /// Consecutive page turns (AC-2.5).
  final int turns;
  final int firstPageReps;
  final int zoomReps;

  /// 3.0 is the 300% of AC-2.3.
  final double zoomFactor;
  final bool autorun;
  final bool exitWhenDone;
}
