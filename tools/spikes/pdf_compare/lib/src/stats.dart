import 'dart:math' as math;

/// Rounds to one decimal place, the precision the result files use for times.
double round1(double value) => (value * 10).round() / 10;

/// The middle value of [samples], or the mean of the middle two.
double median(List<double> samples) {
  final sorted = <double>[...samples]..sort();
  final middle = sorted.length ~/ 2;
  return sorted.length.isOdd
      ? sorted[middle]
      : (sorted[middle - 1] + sorted[middle]) / 2;
}

/// The nearest-rank percentile of [samples]; [fraction] is 0 to 1.
double percentile(List<double> samples, double fraction) {
  final sorted = <double>[...samples]..sort();
  final rank = math.max(1, (fraction * sorted.length - 1e-9).ceil());
  return sorted[math.min(rank, sorted.length) - 1];
}

/// Count, minimum, median, 95th percentile, maximum and mean of millisecond
/// [samples]. An empty list gives only the count, never invented numbers.
Map<String, Object?> summarize(List<double> samples) {
  if (samples.isEmpty) {
    return <String, Object?>{'count': 0};
  }
  final total = samples.fold<double>(0, (sum, value) => sum + value);
  return <String, Object?>{
    'count': samples.length,
    'minMs': round1(samples.reduce(math.min)),
    'medianMs': round1(median(samples)),
    'p95Ms': round1(percentile(samples, 0.95)),
    'maxMs': round1(samples.reduce(math.max)),
    'meanMs': round1(total / samples.length),
  };
}
