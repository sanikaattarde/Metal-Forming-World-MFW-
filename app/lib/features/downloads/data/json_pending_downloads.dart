import 'dart:convert';
import 'dart:io';

import '../domain/download_ports.dart';
import 'io_file_store.dart';

/// [PendingDownloads] as a JSON file in the issue folder, so a download
/// stopped by closing the app resumes the next time it is open (section
/// 6.6 rule 6). Written to a temporary file and renamed; a file that
/// cannot be read counts as empty, and the partial files it named are then
/// removed by the next download of their issue or kept until one starts.
final class JsonPendingDownloads implements PendingDownloads {
  /// Creates the store in [storage]'s folder.
  JsonPendingDownloads(this._storage);

  final IssueStorage _storage;
  List<PendingDownload>? _rows;
  Future<void> _writing = Future<void>.value();

  static const String _fileName = 'pending.json';

  Future<File> _file() async =>
      File('${(await _storage.issueDirectory()).path}/$_fileName');

  @override
  Future<List<PendingDownload>> load() async {
    final List<PendingDownload>? rows = _rows;
    if (rows != null) {
      return List<PendingDownload>.of(rows);
    }
    final List<PendingDownload> loaded = <PendingDownload>[];
    final File file = await _file();
    if (await file.exists()) {
      try {
        final Object? json = jsonDecode(await file.readAsString());
        if (json is List) {
          for (final Object? row in json) {
            if (row is Map &&
                row['owner_user_id'] is String &&
                row['issue_id'] is String &&
                row['mobile_data_accepted'] is bool) {
              loaded.add(
                PendingDownload(
                  ownerUserId: row['owner_user_id'] as String,
                  issueId: row['issue_id'] as String,
                  mobileDataAccepted: row['mobile_data_accepted'] as bool,
                ),
              );
            }
          }
        }
      } on FormatException {
        // An unreadable file counts as empty.
      }
    }
    _rows = loaded;
    return List<PendingDownload>.of(loaded);
  }

  @override
  Future<void> save(PendingDownload pending) async {
    final List<PendingDownload> rows = await load()
      ..removeWhere(
        (PendingDownload row) =>
            row.ownerUserId == pending.ownerUserId &&
            row.issueId == pending.issueId,
      )
      ..add(pending);
    return _write(rows);
  }

  @override
  Future<void> remove({
    required String ownerUserId,
    required String issueId,
  }) async {
    final List<PendingDownload> rows = await load();
    final int before = rows.length;
    rows.removeWhere(
      (PendingDownload row) =>
          row.ownerUserId == ownerUserId && row.issueId == issueId,
    );
    if (rows.length != before) {
      await _write(rows);
    }
  }

  Future<void> _write(List<PendingDownload> rows) {
    _rows = rows;
    final String text = jsonEncode(<Object?>[
      for (final PendingDownload row in rows)
        <String, Object?>{
          'owner_user_id': row.ownerUserId,
          'issue_id': row.issueId,
          'mobile_data_accepted': row.mobileDataAccepted,
        },
    ]);
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
}
