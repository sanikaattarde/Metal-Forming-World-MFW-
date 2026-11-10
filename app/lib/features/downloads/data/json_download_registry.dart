import 'dart:convert';
import 'dart:io';

import 'package:mfw_app/contracts/contracts.dart';

import '../domain/download_ports.dart';
import 'io_file_store.dart';

/// The [DownloadRegistry] as a JSON file in the issue folder (RS DATA-013;
/// `DATABASE_AND_DATA_MODEL.md` section 7.1). Nothing in it is sent to the
/// server.
///
/// Rows keep the file's name, not its full path, because iOS may move the
/// app's folders when the app is updated; the path is rebuilt on load. The
/// file is written to a temporary file and renamed, so a crash leaves the
/// old registry or the new one, never half of one. A registry that cannot
/// be read counts as empty, and the repair at start then removes the files
/// it no longer lists (`PDF_READER_AND_OFFLINE_DESIGN.md` section 4.4).
final class JsonDownloadRegistry implements DownloadRegistry {
  /// Creates the registry in [storage]'s folder.
  JsonDownloadRegistry(this._storage);

  final IssueStorage _storage;
  List<DownloadedIssue>? _rows;
  Future<void> _writing = Future<void>.value();

  static const String _fileName = 'registry.json';

  Future<File> _file() async =>
      File('${(await _storage.issueDirectory()).path}/$_fileName');

  @override
  Future<List<DownloadedIssue>> load() async {
    final List<DownloadedIssue>? rows = _rows;
    if (rows != null) {
      return List<DownloadedIssue>.of(rows);
    }
    final Directory directory = await _storage.issueDirectory();
    final File file = await _file();
    final List<DownloadedIssue> loaded = <DownloadedIssue>[];
    if (await file.exists()) {
      try {
        final Object? json = jsonDecode(await file.readAsString());
        if (json is Map && json['rows'] is List) {
          for (final Object? row in json['rows'] as List<Object?>) {
            final DownloadedIssue? copy = _rowFrom(row, directory);
            if (copy != null) {
              loaded.add(copy);
            }
          }
        }
      } on FormatException {
        // An unreadable registry counts as empty (see above).
      }
    }
    _rows = loaded;
    return List<DownloadedIssue>.of(loaded);
  }

  @override
  Future<void> save(DownloadedIssue copy) async {
    final List<DownloadedIssue> rows = await load();
    rows
      ..removeWhere(
        (DownloadedIssue row) =>
            row.ownerUserId == copy.ownerUserId && row.issueId == copy.issueId,
      )
      ..add(copy);
    await _write(rows);
  }

  @override
  Future<void> remove({
    required String ownerUserId,
    required String issueId,
  }) async {
    final List<DownloadedIssue> rows = await load()
      ..removeWhere(
        (DownloadedIssue row) =>
            row.ownerUserId == ownerUserId && row.issueId == issueId,
      );
    await _write(rows);
  }

  /// Writes [rows], one write after another.
  Future<void> _write(List<DownloadedIssue> rows) {
    _rows = rows;
    final String text = jsonEncode(<String, Object?>{
      'version': 1,
      'rows': <Object?>[for (final DownloadedIssue row in rows) _rowTo(row)],
    });
    return _writing = _writing.then((_) async {
      final File file = await _file();
      final File temporary = File('${file.path}.tmp');
      await temporary.writeAsString(text, flush: true);
      await temporary.rename(file.path);
    });
  }

  static Map<String, Object?> _rowTo(DownloadedIssue row) => <String, Object?>{
    'issue_id': row.issueId,
    'owner_user_id': row.ownerUserId,
    'file_revision': row.fileRevision,
    'file_name': row.localFile.path.substring(
      row.localFile.path.lastIndexOf('/') + 1,
    ),
    'size_bytes': row.sizeBytes,
    'downloaded_at': row.downloadedAt.toUtc().toIso8601String(),
    'content_hash': row.contentHash,
  };

  static DownloadedIssue? _rowFrom(Object? row, Directory directory) {
    if (row is! Map) {
      return null;
    }
    final Object? issueId = row['issue_id'];
    final Object? owner = row['owner_user_id'];
    final Object? revision = row['file_revision'];
    final Object? name = row['file_name'];
    final Object? size = row['size_bytes'];
    final Object? at = row['downloaded_at'];
    final Object? hash = row['content_hash'];
    final DateTime? downloadedAt = at is String ? DateTime.tryParse(at) : null;
    if (issueId is! String ||
        owner is! String ||
        revision is! int ||
        name is! String ||
        name.contains('/') ||
        size is! int ||
        downloadedAt == null ||
        hash is! String) {
      return null;
    }
    return DownloadedIssue(
      issueId: issueId,
      ownerUserId: owner,
      fileRevision: revision,
      localFile: LocalIssueFile(
        issueId: issueId,
        fileRevision: revision,
        path: '${directory.path}/$name',
      ),
      sizeBytes: size,
      downloadedAt: downloadedAt.toUtc(),
      contentHash: hash,
    );
  }
}
