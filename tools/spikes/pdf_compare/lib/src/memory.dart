import 'dart:async';
import 'dart:io';

const double _mebibyte = 1024 * 1024;

/// Reads the process's resident memory. The peak between [begin] and [end] is
/// the highest value seen by a timer, so it can miss a spike shorter than
/// [interval]. [processMaxMiB] is the whole process's peak since it started,
/// which never goes down, so it mixes everything run before it.
class RssSampler {
  RssSampler({
    this.interval = const Duration(milliseconds: 20),
    int Function()? readRss,
    int Function()? readMaxRss,
  }) : _readRss = readRss ?? (() => ProcessInfo.currentRss),
       _readMaxRss = readMaxRss ?? (() => ProcessInfo.maxRss);

  final Duration interval;
  final int Function() _readRss;
  final int Function() _readMaxRss;
  Timer? _timer;
  int _peak = 0;

  double get currentMiB => _safe(_readRss) / _mebibyte;

  double get processMaxMiB => _safe(_readMaxRss) / _mebibyte;

  /// Starts sampling; the peak starts at the current value.
  void begin() {
    _timer?.cancel();
    _peak = _safe(_readRss);
    _timer = Timer.periodic(interval, (_) {
      final now = _safe(_readRss);
      if (now > _peak) {
        _peak = now;
      }
    });
  }

  /// Stops sampling and returns the peak in MiB.
  double end() {
    _timer?.cancel();
    _timer = null;
    final now = _safe(_readRss);
    if (now > _peak) {
      _peak = now;
    }
    return _peak / _mebibyte;
  }

  int _safe(int Function() read) {
    try {
      return read();
    } on Object {
      return 0;
    }
  }
}
