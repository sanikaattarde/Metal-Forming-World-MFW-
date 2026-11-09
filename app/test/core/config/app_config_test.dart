import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/core/config/app_config.dart';

// Synthetic addresses only (DEC-024).
const Map<String, String> _complete = <String, String>{
  AppConfig.wordPressSiteKey: 'https://news.example.test',
  AppConfig.wordPressCategoriesKey: '7, 11,12',
  AppConfig.privacyPolicyKey: 'https://example.test/privacy',
  AppConfig.termsOfUseKey: 'https://example.test/terms',
};

Map<String, String> _with(Map<String, String> extra) => <String, String>{
  ..._complete,
  ...extra,
};

/// The keys and values of an `.env` file, as `--dart-define-from-file`
/// reads them: `KEY=value` lines, with `#` comments skipped.
Map<String, String> _readEnvFile(String path) => <String, String>{
  for (final String line in File(path).readAsLinesSync())
    if (line.trim().isNotEmpty && !line.trimLeft().startsWith('#'))
      line.substring(0, line.indexOf('=')): line.substring(
        line.indexOf('=') + 1,
      ),
};

void main() {
  group('AppConfig.fromDefines [MOD01-P2-T04]', () {
    test('reads the four settings and the environment', () {
      final AppConfig config = AppConfig.fromDefines(
        _with(<String, String>{
          AppConfig.environmentKey: 'test',
          AppConfig.storeLinkIosKey: 'https://apps.example.test/app/1',
        }),
      );

      expect(config.environment, AppEnvironment.test);
      expect(config.wordPress!.siteUri, Uri.parse('https://news.example.test'));
      expect(config.wordPress!.categoryIds, <String>['7', '11', '12']);
      expect(config.privacyPolicy, Uri.parse('https://example.test/privacy'));
      expect(config.termsOfUse, Uri.parse('https://example.test/terms'));
      expect(config.storeLinkAndroid, isNull);
      expect(config.storeLinkIos, Uri.parse('https://apps.example.test/app/1'));
    });

    test('an unset environment is local', () {
      expect(
        AppConfig.fromDefines(const <String, String>{}).environment,
        AppEnvironment.local,
      );
    });

    test('ENV-LOCAL runs with nothing set, and news is then unavailable', () {
      final AppConfig config = AppConfig.fromDefines(const <String, String>{
        AppConfig.wordPressSiteKey: 'replace-me',
        AppConfig.wordPressCategoriesKey: '',
      });

      expect(config.wordPress, isNull);
      expect(config.privacyPolicy, isNull);
    });

    test('the site without categories gives no news configuration', () {
      final AppConfig config = AppConfig.fromDefines(const <String, String>{
        AppConfig.wordPressSiteKey: 'https://news.example.test',
      });

      expect(config.wordPress, isNull);
    });

    test('a release build must name its environment', () {
      expect(
        () => AppConfig.fromDefines(_complete, releaseBuild: true),
        throwsA(
          isA<AppConfigException>().having(
            (AppConfigException e) => e.keys,
            'keys',
            <String>[AppConfig.environmentKey],
          ),
        ),
      );
      expect(
        AppConfig.fromDefines(
          _with(<String, String>{AppConfig.environmentKey: 'test'}),
          releaseBuild: true,
        ).environment,
        AppEnvironment.test,
      );
    });

    test('an unknown environment fails at start-up', () {
      expect(
        () => AppConfig.fromDefines(
          _with(<String, String>{AppConfig.environmentKey: 'staging'}),
        ),
        throwsA(
          isA<AppConfigException>().having(
            (AppConfigException e) => e.keys,
            'keys',
            <String>[AppConfig.environmentKey],
          ),
        ),
      );
    });

    test('an address that is not HTTPS fails [NFR-SEC-001]', () {
      for (final String key in <String>[
        AppConfig.wordPressSiteKey,
        AppConfig.privacyPolicyKey,
        AppConfig.termsOfUseKey,
        AppConfig.storeLinkAndroidKey,
        AppConfig.storeLinkIosKey,
      ]) {
        expect(
          () => AppConfig.fromDefines(
            _with(<String, String>{key: 'http://example.test/x'}),
          ),
          throwsA(
            isA<AppConfigException>().having(
              (AppConfigException e) => e.keys,
              'keys',
              <String>[key],
            ),
          ),
          reason: key,
        );
      }
    });

    test('a category that is not a number fails', () {
      expect(
        () => AppConfig.fromDefines(
          _with(<String, String>{AppConfig.wordPressCategoriesKey: '7,news'}),
        ),
        throwsA(isA<AppConfigException>()),
      );
    });

    test('ENV-PROD needs the site, its categories and both policies', () {
      expect(
        () => AppConfig.fromDefines(const <String, String>{
          AppConfig.environmentKey: 'prod',
        }),
        throwsA(
          isA<AppConfigException>().having(
            (AppConfigException e) => e.keys,
            'keys',
            <String>[
              AppConfig.wordPressSiteKey,
              AppConfig.wordPressCategoriesKey,
              AppConfig.privacyPolicyKey,
              AppConfig.termsOfUseKey,
            ],
          ),
        ),
      );
    });

    test('ENV-PROD runs without store links until the apps are listed '
        '[OQ-15]', () {
      final AppConfig config = AppConfig.fromDefines(
        _with(<String, String>{AppConfig.environmentKey: 'prod'}),
      );

      expect(config.environment, AppEnvironment.prod);
      expect(config.storeLinkAndroid, isNull);
    });

    test('the error names the settings and never their values', () {
      const String secretLooking = 'http://reader@example.test/x';
      try {
        AppConfig.fromDefines(
          _with(<String, String>{AppConfig.privacyPolicyKey: secretLooking}),
        );
        fail('expected AppConfigException');
      } on AppConfigException catch (e) {
        expect(e.toString(), isNot(contains('example.test')));
        expect(e.toString(), contains(AppConfig.privacyPolicyKey));
      }
    });

    test('the configuration example loads as ENV-LOCAL with nothing set', () {
      final Map<String, String> defines = _readEnvFile(
        '../config/config.example.env',
      );
      final AppConfig config = AppConfig.fromDefines(defines);

      expect(defines[AppConfig.environmentKey], 'local');
      expect(config.environment, AppEnvironment.local);
      expect(config.wordPress, isNull);
      for (final String key in <String>[
        AppConfig.wordPressSiteKey,
        AppConfig.wordPressCategoriesKey,
        AppConfig.privacyPolicyKey,
        AppConfig.termsOfUseKey,
        AppConfig.storeLinkAndroidKey,
        AppConfig.storeLinkIosKey,
      ]) {
        expect(defines.containsKey(key), isTrue, reason: key);
      }
    });

    test('this test build has no defines, so it reads as ENV-LOCAL', () {
      expect(AppConfig.fromEnvironment().environment, AppEnvironment.local);
    });
  });
}
