import 'dart:convert';
import 'dart:io';

import 'package:mfw_app/contracts/contracts.dart';

import '../domain/reader_preferences.dart';

/// [ReaderPreferences] as a JSON file in the app's private folder. Written
/// to a temporary file and renamed. A file that cannot be read gives the
/// default mode.
final class JsonReaderPreferences implements ReaderPreferences {
  /// Creates the store in the folder that [directory] gives.
  JsonReaderPreferences(this._directory);

  final Future<Directory> Function() _directory;
  ReaderMode? _mode;

  static const String _fileName = 'reader_preferences.json';

  Future<File> _file() async => File('${(await _directory()).path}/$_fileName');

  @override
  Future<ReaderMode> mode() async {
    final ReaderMode? known = _mode;
    if (known != null) {
      return known;
    }
    ReaderMode mode = ReaderPreferences.defaultMode;
    try {
      final File file = await _file();
      if (await file.exists()) {
        final Object? json = jsonDecode(await file.readAsString());
        if (json is Map) {
          mode = switch (json['mode']) {
            'swipe' => ReaderMode.swipe,
            'page_turn' => ReaderMode.pageTurn,
            _ => ReaderPreferences.defaultMode,
          };
        }
      }
    } on FormatException {
      // An unreadable file gives the default.
    } on FileSystemException {
      // So does one that cannot be opened.
    }
    return _mode = mode;
  }

  @override
  Future<void> setMode(ReaderMode mode) async {
    _mode = mode;
    final File file = await _file();
    final File temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode(<String, String>{
        'mode': switch (mode) {
          ReaderMode.swipe => 'swipe',
          ReaderMode.pageTurn => 'page_turn',
        },
      }),
      flush: true,
    );
    await temporary.rename(file.path);
  }
}
