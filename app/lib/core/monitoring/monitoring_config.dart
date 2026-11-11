import '../config/app_config.dart';

/// CFG-11, the crash-reporting and usage-event switches
/// (`config/config.example.env`, DEC-028; OQ-23 and C-07 are OPEN).
///
/// Each switch is `true` or `false`; empty or `replace-me` counts as false.
/// Any other value stops the app at start-up, as the other settings do.
/// Usage events stay off in every build until OQ-23 sets the list: with no
/// approved event, the switch changes nothing (MOD02-P2-T02).
final class MonitoringConfig {
  /// Creates the configuration.
  const MonitoringConfig({
    this.crashReportingEnabled = false,
    this.usageEventsEnabled = false,
  });

  /// Reads the switches from [defines], keyed as in the example file.
  factory MonitoringConfig.fromDefines(Map<String, String> defines) {
    final List<String> bad = <String>[];
    bool flag(String key) {
      final String value = (defines[key] ?? '').trim();
      return switch (value) {
        'true' => true,
        'false' || '' || 'replace-me' => false,
        _ => () {
          bad.add(key);
          return false;
        }(),
      };
    }

    final MonitoringConfig config = MonitoringConfig(
      crashReportingEnabled: flag(crashReportingKey),
      usageEventsEnabled: flag(usageEventsKey),
    );
    if (bad.isNotEmpty) {
      throw AppConfigException(bad);
    }
    return config;
  }

  /// Reads the switches given at build time.
  factory MonitoringConfig.fromEnvironment() =>
      MonitoringConfig.fromDefines(const <String, String>{
        crashReportingKey: String.fromEnvironment(crashReportingKey),
        usageEventsKey: String.fromEnvironment(usageEventsKey),
      });

  /// Whether crashes are reported (MOD02-P2-T01).
  final bool crashReportingEnabled;

  /// Whether usage events may be recorded (MOD02-P2-T02).
  final bool usageEventsEnabled;

  /// The key of [crashReportingEnabled].
  static const String crashReportingKey = 'CFG_11_CRASH_REPORTING_ENABLED';

  /// The key of [usageEventsEnabled].
  static const String usageEventsKey = 'CFG_11_USAGE_EVENTS_ENABLED';
}
