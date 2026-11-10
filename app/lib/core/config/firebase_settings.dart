import 'app_config.dart';

/// The app's Firebase project for its environment (CFG-01, DEC-003): the
/// public identifiers the platform plugins need, or the local emulators.
///
/// Nothing here is a secret: Firebase's app identifiers and API keys are
/// public, and access is decided by the backend's rules and functions
/// (DEC-009). They come from build-time defines, as [AppConfig] does, so an
/// environment needs no code change. A value that is empty or still
/// `replace-me` counts as not set.
///
/// - ENV-LOCAL with no project set runs against the Firebase emulators,
///   under the demo project `demo-mfw` (DEC-023), at [emulatorHost].
/// - ENV-TEST and ENV-PROD must name a project and both platforms' app
///   identifiers, or the app stops at start-up ([AppConfigException]).
final class FirebaseSettings {
  /// Creates the settings. Prefer [FirebaseSettings.fromDefines].
  const FirebaseSettings({
    required this.projectId,
    required this.messagingSenderId,
    required this.android,
    required this.ios,
    this.storageBucket,
    this.emulatorHost,
  });

  /// Reads the settings for [environment] from [defines], keyed as in
  /// `config/config.example.env`.
  factory FirebaseSettings.fromDefines(
    Map<String, String> defines,
    AppEnvironment environment,
  ) {
    String? read(String key) {
      final String value = (defines[key] ?? '').trim();
      return value.isEmpty || value == 'replace-me' ? null : value;
    }

    final String? projectId = read(projectIdKey);
    final String? emulatorHost = read(emulatorHostKey);
    if (projectId == null && environment == AppEnvironment.local) {
      return FirebaseSettings.emulators(host: emulatorHost);
    }

    final List<String> missing = <String>[];
    String need(String key) {
      final String? value = read(key);
      if (value == null) {
        missing.add(key);
      }
      return value ?? '';
    }

    final String project = need(projectIdKey);
    final String sender = need(messagingSenderIdKey);
    final FirebaseAppIds android = FirebaseAppIds(
      apiKey: need(androidApiKeyKey),
      appId: need(androidAppIdKey),
    );
    final FirebaseAppIds ios = FirebaseAppIds(
      apiKey: need(iosApiKeyKey),
      appId: need(iosAppIdKey),
    );
    if (project.startsWith('demo-')) {
      missing.add(projectIdKey);
    }
    if (emulatorHost != null && environment != AppEnvironment.local) {
      missing.add(emulatorHostKey);
    }
    if (missing.isNotEmpty) {
      throw AppConfigException(missing);
    }
    return FirebaseSettings(
      projectId: project,
      messagingSenderId: sender,
      android: android,
      ios: ios,
      storageBucket: read(storageBucketKey),
      emulatorHost: environment == AppEnvironment.local ? emulatorHost : null,
    );
  }

  /// The local emulators under the demo project. [host] is the machine
  /// running them as the device sees it; null means the platform's default.
  factory FirebaseSettings.emulators({String? host}) => FirebaseSettings(
    projectId: emulatorProjectId,
    messagingSenderId: '0',
    android: const FirebaseAppIds(
      apiKey: emulatorApiKey,
      appId: '1:0:android:0',
    ),
    ios: const FirebaseAppIds(apiKey: emulatorApiKey, appId: '1:0:ios:0'),
    emulatorHost: host ?? '',
  );

  /// Reads the settings passed to this build for [environment].
  factory FirebaseSettings.fromEnvironment(AppEnvironment environment) =>
      FirebaseSettings.fromDefines(const <String, String>{
        projectIdKey: String.fromEnvironment(projectIdKey),
        messagingSenderIdKey: String.fromEnvironment(messagingSenderIdKey),
        androidApiKeyKey: String.fromEnvironment(androidApiKeyKey),
        androidAppIdKey: String.fromEnvironment(androidAppIdKey),
        iosApiKeyKey: String.fromEnvironment(iosApiKeyKey),
        iosAppIdKey: String.fromEnvironment(iosAppIdKey),
        storageBucketKey: String.fromEnvironment(storageBucketKey),
        emulatorHostKey: String.fromEnvironment(emulatorHostKey),
      }, environment);

  /// The demo project the emulators run, with no cloud project.
  static const String emulatorProjectId = 'demo-mfw';

  /// The API key used with the emulators. Not a real key: the emulators
  /// accept any. It has the shape Firebase checks on iOS (39 characters,
  /// starting with `A`, URL-safe), because Firebase Installations stops the
  /// app at start-up on any other shape. It avoids the `AIza` prefix of real
  /// keys, so a secrets scan does not take it for one.
  static const String emulatorApiKey =
      'A-emulator-only-placeholder-not-a-key-0';

  /// CFG-01, the Firebase project identifier.
  static const String projectIdKey = 'CFG_01_BACKEND_PROJECT_ID';

  /// The project's messaging sender ID, shared by both platforms.
  static const String messagingSenderIdKey = 'FIREBASE_MESSAGING_SENDER_ID';

  /// The Android app's API key.
  static const String androidApiKeyKey = 'FIREBASE_ANDROID_API_KEY';

  /// The Android app's identifier.
  static const String androidAppIdKey = 'FIREBASE_ANDROID_APP_ID';

  /// The iOS app's API key.
  static const String iosApiKeyKey = 'FIREBASE_IOS_API_KEY';

  /// The iOS app's identifier.
  static const String iosAppIdKey = 'FIREBASE_IOS_APP_ID';

  /// The default storage bucket, optional.
  static const String storageBucketKey = 'FIREBASE_STORAGE_BUCKET';

  /// ENV-LOCAL only: the emulators' host as the device sees it.
  static const String emulatorHostKey = 'MFW_EMULATOR_HOST';

  /// The project identifier.
  final String projectId;

  /// The messaging sender ID.
  final String messagingSenderId;

  /// The Android app's identifiers.
  final FirebaseAppIds android;

  /// The iOS app's identifiers.
  final FirebaseAppIds ios;

  /// The default storage bucket, or null for the project's default.
  final String? storageBucket;

  /// Non-null when the app runs against the local emulators: the host, or
  /// an empty string for the platform's default.
  final String? emulatorHost;

  /// Whether the app runs against the local emulators.
  bool get usesEmulators => emulatorHost != null;
}

/// One platform app's public identifiers in the Firebase project.
final class FirebaseAppIds {
  /// Creates the identifiers.
  const FirebaseAppIds({required this.apiKey, required this.appId});

  /// The API key, a public identifier.
  final String apiKey;

  /// The app identifier.
  final String appId;
}
