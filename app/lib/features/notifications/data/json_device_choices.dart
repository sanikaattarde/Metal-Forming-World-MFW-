import 'dart:convert';
import 'dart:io';

import '../domain/device_choices.dart';

/// [DeviceChoices] as a JSON file in the app's private folder, next to the
/// download records. Written to a temporary file and renamed, so a write
/// cut short leaves the last whole record. A file that cannot be read
/// counts as empty: the explanation shows again, and a visitor chooses
/// again.
final class JsonDeviceChoices implements DeviceChoices {
  /// Creates the store in the folder that [directory] gives.
  JsonDeviceChoices(this._directory);

  final Future<Directory> Function() _directory;
  DeviceChoicesRecord? _record;
  Future<void>? _writing;

  static const String _fileName = 'notification_choices.json';

  Future<File> _file() async => File('${(await _directory()).path}/$_fileName');

  static Set<String> _texts(Object? value) => value is List
      ? <String>{
          for (final Object? item in value) ?(item is String ? item : null),
        }
      : <String>{};

  @override
  Future<DeviceChoicesRecord> load() async {
    final DeviceChoicesRecord? known = _record;
    if (known != null) {
      return known;
    }
    DeviceChoicesRecord record = const DeviceChoicesRecord();
    try {
      final File file = await _file();
      if (await file.exists()) {
        final Object? json = jsonDecode(await file.readAsString());
        if (json is Map) {
          record = DeviceChoicesRecord(
            explained: json['explained'] == true,
            visitorCategories: _texts(json['visitor_categories']),
            subscribedTopics: _texts(json['subscribed_topics']),
          );
        }
      }
    } on FormatException {
      // An unreadable file counts as empty.
    } on FileSystemException {
      // So does one that cannot be opened.
    }
    return _record = record;
  }

  @override
  Future<void> save(DeviceChoicesRecord record) {
    _record = record;
    final Future<void> next = (_writing ?? Future<void>.value()).then((
      _,
    ) async {
      final File file = await _file();
      final File temporary = File('${file.path}.tmp');
      await temporary.writeAsString(
        jsonEncode(<String, Object>{
          'explained': record.explained,
          'visitor_categories': (record.visitorCategories.toList()..sort()),
          'subscribed_topics': (record.subscribedTopics.toList()..sort()),
        }),
        flush: true,
      );
      await temporary.rename(file.path);
    });
    _writing = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }
}
