// CFG-01: the app's Firebase settings for each environment (DEC-003,
// DEC-023). Placeholder values only; nothing here is a real project.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/core/config/app_config.dart';
import 'package:mfw_app/core/config/firebase_settings.dart';

const Map<String, String> project = <String, String>{
  FirebaseSettings.projectIdKey: 'mfw-test-placeholder',
  FirebaseSettings.messagingSenderIdKey: '123',
  FirebaseSettings.androidApiKeyKey: 'android-key-placeholder',
  FirebaseSettings.androidAppIdKey: '1:123:android:abc',
  FirebaseSettings.iosApiKeyKey: 'ios-key-placeholder',
  FirebaseSettings.iosAppIdKey: '1:123:ios:abc',
};

void main() {
  test(
    'ENV-LOCAL with no project runs against the emulators, under demo-mfw',
    () {
      final FirebaseSettings settings = FirebaseSettings.fromDefines(
        const <String, String>{FirebaseSettings.projectIdKey: 'replace-me'},
        AppEnvironment.local,
      );
      expect(settings.usesEmulators, isTrue);
      expect(settings.projectId, 'demo-mfw');
      expect(settings.emulatorHost, '');
    },
  );

  test('ENV-LOCAL can name the emulators host, as the device sees it', () {
    final FirebaseSettings settings = FirebaseSettings.fromDefines(
      const <String, String>{FirebaseSettings.emulatorHostKey: '192.168.1.20'},
      AppEnvironment.local,
    );
    expect(settings.emulatorHost, '192.168.1.20');
  });

  for (final AppEnvironment environment in <AppEnvironment>[
    AppEnvironment.test,
    AppEnvironment.prod,
  ]) {
    test(
      '${environment.name} with a full project uses it, not the emulators',
      () {
        final FirebaseSettings settings = FirebaseSettings.fromDefines(
          <String, String>{
            ...project,
            FirebaseSettings.storageBucketKey: 'bucket-placeholder',
          },
          environment,
        );
        expect(settings.usesEmulators, isFalse);
        expect(settings.projectId, 'mfw-test-placeholder');
        expect(settings.android.appId, '1:123:android:abc');
        expect(settings.ios.apiKey, 'ios-key-placeholder');
        expect(settings.storageBucket, 'bucket-placeholder');
      },
    );

    test(
      '${environment.name} with nothing set stops at start-up, naming every key',
      () {
        expect(
          () => FirebaseSettings.fromDefines(
            const <String, String>{},
            environment,
          ),
          throwsA(
            isA<AppConfigException>().having(
              (AppConfigException e) => e.keys,
              'keys',
              unorderedEquals(project.keys),
            ),
          ),
        );
      },
    );

    test('${environment.name} refuses a demo project and an emulator host', () {
      expect(
        () => FirebaseSettings.fromDefines(<String, String>{
          ...project,
          FirebaseSettings.projectIdKey: 'demo-mfw',
          FirebaseSettings.emulatorHostKey: '127.0.0.1',
        }, environment),
        throwsA(
          isA<AppConfigException>().having(
            (AppConfigException e) => e.keys,
            'keys',
            unorderedEquals(<String>[
              FirebaseSettings.projectIdKey,
              FirebaseSettings.emulatorHostKey,
            ]),
          ),
        ),
      );
    });
  }

  test('ENV-LOCAL with a project named must name the apps too', () {
    expect(
      () => FirebaseSettings.fromDefines(const <String, String>{
        FirebaseSettings.projectIdKey: 'mfw-dev-placeholder',
      }, AppEnvironment.local),
      throwsA(isA<AppConfigException>()),
    );
  });

  test('the configuration example names every key', () {
    // Read from app/, as the tests run.
    final String example = File('../config/config.example.env')
        .readAsStringSync();
    for (final String key in <String>[
      ...project.keys,
      FirebaseSettings.storageBucketKey,
      FirebaseSettings.emulatorHostKey,
    ]) {
      expect(example, contains('$key='), reason: key);
    }
  });
}
