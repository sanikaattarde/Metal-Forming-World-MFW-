import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// SEC-CHK-01 by configuration inspection: cleartext is off on both
// platforms (RS NFR-SEC-001, MOD01-P2-T03 step 3). Tests run from `app/`.
// The proxy observation of SEC-CHK-01 is manual, on a device.
void main() {
  group('SEC-CHK-01 configuration [NFR-SEC-001]', () {
    test('Android: the app manifest turns cleartext off', () {
      final String manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();

      expect(manifest, contains('android:usesCleartextTraffic="false"'));
      expect(manifest, isNot(contains('networkSecurityConfig')));
    });

    test('Android: no other manifest turns cleartext on', () {
      for (final FileSystemEntity f in Directory(
        'android/app/src',
      ).listSync(recursive: true)) {
        if (f is File && f.path.endsWith('AndroidManifest.xml')) {
          expect(
            f.readAsStringSync(),
            isNot(contains('usesCleartextTraffic="true"')),
            reason: f.path,
          );
        }
      }
    });

    test('iOS: App Transport Security has no exception', () {
      final String plist = File('ios/Runner/Info.plist').readAsStringSync();

      for (final String key in <String>[
        'NSAllowsArbitraryLoads',
        'NSAllowsArbitraryLoadsInWebContent',
        'NSAllowsLocalNetworking',
        'NSExceptionDomains',
        'NSExceptionAllowsInsecureHTTPLoads',
      ]) {
        expect(plist, isNot(contains(key)), reason: key);
      }
    });
  });
}
