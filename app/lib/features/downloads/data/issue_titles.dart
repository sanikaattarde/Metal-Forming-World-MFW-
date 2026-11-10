import 'dart:convert';
import 'dart:io';

import 'io_file_store.dart';

/// The titles of downloaded issues, kept beside the files so the Downloads
/// screen can name them with no network (RS NFR-OFF-001). A title is public
/// metadata (FR-MAG-002). Written when a download starts; a missing title
/// shows the issue identifier.
final class IssueTitles {
  /// Creates the store in [storage]'s folder.
  IssueTitles(this._storage);

  final IssueStorage _storage;
  Map<String, String>? _titles;
  Future<void> _writing = Future<void>.value();

  static const String _fileName = 'titles.json';

  Future<File> _file() async =>
      File('${(await _storage.issueDirectory()).path}/$_fileName');

  /// Every title known, by issue identifier.
  Future<Map<String, String>> load() async {
    final Map<String, String>? known = _titles;
    if (known != null) {
      return Map<String, String>.of(known);
    }
    final Map<String, String> loaded = <String, String>{};
    final File file = await _file();
    if (await file.exists()) {
      try {
        final Object? json = jsonDecode(await file.readAsString());
        if (json is Map) {
          for (final MapEntry<Object?, Object?> entry in json.entries) {
            if (entry.key is String && entry.value is String) {
              loaded[entry.key! as String] = entry.value! as String;
            }
          }
        }
      } on FormatException {
        // An unreadable file counts as empty.
      }
    }
    _titles = loaded;
    return Map<String, String>.of(loaded);
  }

  /// Keeps [title] for [issueId].
  Future<void> remember(String issueId, String title) async {
    final Map<String, String> titles = await load();
    if (titles[issueId] == title) {
      return;
    }
    titles[issueId] = title;
    _titles = titles;
    final String text = jsonEncode(titles);
    final Future<void> write = _writing.then((_) async {
      final File file = await _file();
      final File temporary = File('${file.path}.tmp');
      await temporary.writeAsString(text, flush: true);
      await temporary.rename(file.path);
    });
    // A failed write fails its own caller only; the next one still runs.
    _writing = write.catchError((Object _) {});
    return write;
  }

  /// The title kept for [issueId], from memory: null before [load] has
  /// read the file, or when none is kept. A title kept after the load is
  /// found at once.
  String? titleOf(String issueId) => _titles?[issueId];
}
