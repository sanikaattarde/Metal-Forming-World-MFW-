import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('contracts import no Flutter library, no platform library and no package [MOD-00]', () {
    final List<File> files = Directory('lib/contracts')
        .listSync()
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList();
    final RegExp directive = RegExp(
      r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
      multiLine: true,
    );

    expect(files, isNotEmpty);
    for (final File file in files) {
      for (final RegExpMatch match in directive.allMatches(
        file.readAsStringSync(),
      )) {
        final String uri = match.group(1)!;
        expect(
          uri.startsWith('package:') || uri.startsWith('dart:'),
          isFalse,
          reason: '${file.path} imports $uri',
        );
      }
    }
  });
}
