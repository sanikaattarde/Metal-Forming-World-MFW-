import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_compare/src/stats.dart';

void main() {
  test('median of an odd count is the middle value [T-02.3]', () {
    expect(median(<double>[9, 1, 5]), 5);
  });

  test('median of an even count averages the middle two [T-02.3]', () {
    expect(median(<double>[4, 1, 3, 2]), 2.5);
  });

  test('percentile uses the nearest rank [T-02.3]', () {
    final samples = List<double>.generate(20, (index) => index + 1.0);
    expect(percentile(samples, 0.95), 19);
    expect(percentile(samples, 1), 20);
    expect(percentile(samples, 0), 1);
  });

  test(
    'summary of no samples says so instead of inventing numbers [T-02.3]',
    () {
      expect(summarize(<double>[]), <String, Object?>{'count': 0});
    },
  );

  test('summary reports count, min, median, p95, max and mean [T-02.3]', () {
    final summary = summarize(<double>[10, 20, 30, 40]);
    expect(summary['count'], 4);
    expect(summary['minMs'], 10);
    expect(summary['medianMs'], 25);
    expect(summary['p95Ms'], 40);
    expect(summary['maxMs'], 40);
    expect(summary['meanMs'], 25);
  });

  test('round1 keeps one decimal place [T-02.3]', () {
    expect(round1(12.3456), 12.3);
    expect(round1(0.05), 0.1);
  });
}
