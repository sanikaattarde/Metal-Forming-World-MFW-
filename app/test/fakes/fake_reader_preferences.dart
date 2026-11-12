import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

/// Keeps the mode in memory; [fails] makes reads and writes fail.
final class MemoryReaderPreferences implements ReaderPreferences {
  MemoryReaderPreferences([this.kept]);

  ReaderMode? kept;
  bool fails = false;
  final List<ReaderMode> written = <ReaderMode>[];

  @override
  Future<ReaderMode> mode() async {
    if (fails) {
      throw StateError('unreadable');
    }
    return kept ?? ReaderPreferences.defaultMode;
  }

  @override
  Future<void> setMode(ReaderMode mode) async {
    if (fails) {
      throw StateError('unwritable');
    }
    written.add(mode);
    kept = mode;
  }
}
