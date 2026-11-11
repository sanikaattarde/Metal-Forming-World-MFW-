// MOD11-P2-T02: the device's notification record as a JSON file, in a
// temporary folder.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/features/notifications/notifications.dart';

void main() {
  late Directory folder;

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('mfw-notification-choices');
  });

  tearDown(() async {
    await folder.delete(recursive: true);
  });

  JsonDeviceChoices store() => JsonDeviceChoices(() async => folder);
  File file() => File('${folder.path}/notification_choices.json');

  test('nothing saved yet is an empty record', () async {
    final DeviceChoicesRecord record = await store().load();
    expect(record.explained, isFalse);
    expect(record.visitorCategories, isEmpty);
    expect(record.subscribedTopics, isEmpty);
  });

  test('a saved record is read back by a new store, from the file', () async {
    await store().save(
      const DeviceChoicesRecord(
        explained: true,
        visitorCategories: <String>{'b', 'a'},
        subscribedTopics: <String>{'a'},
      ),
    );
    final DeviceChoicesRecord again = await store().load();
    expect(again.explained, isTrue);
    expect(again.visitorCategories, <String>{'a', 'b'});
    expect(again.subscribedTopics, <String>{'a'});
    expect(await File('${file().path}.tmp').exists(), isFalse);
  });

  test('a damaged file counts as empty', () async {
    await file().writeAsString('{not json');
    expect((await store().load()).explained, isFalse);
    await file().writeAsString(
      '{"explained": "yes", "subscribed_topics": [1, "a"]}',
    );
    final DeviceChoicesRecord record = await store().load();
    expect(record.explained, isFalse);
    expect(record.subscribedTopics, <String>{'a'});
  });
}
