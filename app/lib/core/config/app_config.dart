import 'wordpress_config.dart';

/// The deployment environments of `DEPLOYMENT_PLAN.md` section 4: ENV-LOCAL,
/// ENV-TEST and ENV-PROD (DEC-023, AGREED as an internal position).
enum AppEnvironment {
  /// ENV-LOCAL: the developers' machines, with emulators and fakes.
  local,

  /// ENV-TEST: the non-production project, synthetic data only (DEC-024).
  test,

  /// ENV-PROD: the live service.
  prod,
}

/// Thrown at start-up when the build-time configuration is wrong, so a bad
/// build fails at once instead of showing readers a broken screen.
///
/// [keys] names the settings that are wrong. Their values are never
/// included, so the message can be logged.
final class AppConfigException implements Exception {
  /// Creates the exception for [keys].
  const AppConfigException(this.keys);

  /// The settings that are missing or not valid.
  final List<String> keys;

  @override
  String toString() => 'AppConfigException: check ${keys.join(', ')}';
}

/// The app's non-secret settings for one environment (MOD01-P2-T04):
/// CFG-03, CFG-04, CFG-07 and CFG-08 of `DEPLOYMENT_PLAN.md` section 5.2.
///
/// The values come from build-time defines, normally a file made from
/// `config/config.example.env` and passed with `--dart-define-from-file`,
/// so switching environment needs no code change. Nothing here is a secret:
/// anything passed at build time can be read from the app.
///
/// A setting that is empty or still `replace-me` counts as not set. In
/// ENV-PROD the site, its categories and both policy addresses must be set.
/// The store links may be missing until the apps are listed (OQ-15). Every
/// address must be HTTPS (RS NFR-SEC-001).
final class AppConfig {
  /// Creates a configuration. Prefer [AppConfig.fromDefines].
  const AppConfig({
    required this.environment,
    this.wordPress,
    this.privacyPolicy,
    this.termsOfUse,
    this.storeLinkAndroid,
    this.storeLinkIos,
  });

  /// Reads the settings from [defines], keyed as in the example file.
  ///
  /// Throws [AppConfigException] for an unknown environment, a value that is
  /// not valid, or a setting that ENV-PROD needs and does not have.
  factory AppConfig.fromDefines(Map<String, String> defines) {
    final List<String> bad = <String>[];
    String? read(String key) {
      final String value = (defines[key] ?? '').trim();
      return value.isEmpty || value == _placeholder ? null : value;
    }

    Uri? https(String key) {
      final String? value = read(key);
      if (value == null) {
        return null;
      }
      final Uri? uri = Uri.tryParse(value);
      if (uri == null || !uri.isScheme('https') || uri.host.isEmpty) {
        bad.add(key);
        return null;
      }
      return uri;
    }

    final String environmentName = read(environmentKey) ?? 'local';
    AppEnvironment? environment;
    for (final AppEnvironment e in AppEnvironment.values) {
      if (e.name == environmentName) {
        environment = e;
      }
    }
    if (environment == null) {
      bad.add(environmentKey);
    }

    final Uri? site = https(wordPressSiteKey);
    final String? categoryText = read(wordPressCategoriesKey);
    List<String>? categories;
    if (categoryText != null) {
      categories = categoryText
          .split(',')
          .map((String id) => id.trim())
          .where((String id) => id.isNotEmpty)
          .toList();
      if (categories.isEmpty || !categories.every(_numericId.hasMatch)) {
        bad.add(wordPressCategoriesKey);
        categories = null;
      }
    }
    final Uri? privacy = https(privacyPolicyKey);
    final Uri? terms = https(termsOfUseKey);
    final Uri? android = https(storeLinkAndroidKey);
    final Uri? ios = https(storeLinkIosKey);

    if (environment == AppEnvironment.prod) {
      for (final (String key, Object? value) in <(String, Object?)>[
        (wordPressSiteKey, site),
        (wordPressCategoriesKey, categories),
        (privacyPolicyKey, privacy),
        (termsOfUseKey, terms),
      ]) {
        if (value == null && !bad.contains(key)) {
          bad.add(key);
        }
      }
    }
    if (bad.isNotEmpty) {
      throw AppConfigException(List<String>.unmodifiable(bad));
    }
    return AppConfig(
      environment: environment!,
      wordPress: site == null || categories == null
          ? null
          : WordPressSiteConfig(siteUri: site, categoryIds: categories),
      privacyPolicy: privacy,
      termsOfUse: terms,
      storeLinkAndroid: android,
      storeLinkIos: ios,
    );
  }

  /// Reads the settings passed to this build.
  factory AppConfig.fromEnvironment() =>
      AppConfig.fromDefines(const <String, String>{
        environmentKey: String.fromEnvironment(environmentKey),
        wordPressSiteKey: String.fromEnvironment(wordPressSiteKey),
        wordPressCategoriesKey: String.fromEnvironment(wordPressCategoriesKey),
        privacyPolicyKey: String.fromEnvironment(privacyPolicyKey),
        termsOfUseKey: String.fromEnvironment(termsOfUseKey),
        storeLinkAndroidKey: String.fromEnvironment(storeLinkAndroidKey),
        storeLinkIosKey: String.fromEnvironment(storeLinkIosKey),
      });

  /// The environment's name: `local`, `test` or `prod`. `local` if unset.
  static const String environmentKey = 'MFW_ENV';

  /// CFG-03.
  static const String wordPressSiteKey = 'CFG_03_WORDPRESS_SITE_URL';

  /// CFG-04, category IDs separated by commas, in the order shown.
  static const String wordPressCategoriesKey = 'CFG_04_WORDPRESS_CATEGORIES';

  /// CFG-07, the privacy policy.
  static const String privacyPolicyKey = 'CFG_07_PRIVACY_POLICY_URL';

  /// CFG-07, the terms of use.
  static const String termsOfUseKey = 'CFG_07_TERMS_OF_USE_URL';

  /// CFG-08, the Android store link.
  static const String storeLinkAndroidKey = 'CFG_08_STORE_LINK_ANDROID';

  /// CFG-08, the iOS store link.
  static const String storeLinkIosKey = 'CFG_08_STORE_LINK_IOS';

  static const String _placeholder = 'replace-me';
  static final RegExp _numericId = RegExp(r'^[0-9]{1,18}$');

  /// Which environment this build is for.
  final AppEnvironment environment;

  /// CFG-03 and CFG-04, or null when either is not set: the news screens
  /// then show that news is not available.
  final WordPressSiteConfig? wordPress;

  /// CFG-07, or null when not set.
  final Uri? privacyPolicy;

  /// CFG-07, or null when not set.
  final Uri? termsOfUse;

  /// CFG-08, or null until the app is listed (OQ-15).
  final Uri? storeLinkAndroid;

  /// CFG-08, or null until the app is listed (OQ-15).
  final Uri? storeLinkIos;
}
