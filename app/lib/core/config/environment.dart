/// Deployment environments: ENV-LOCAL, ENV-TEST and ENV-PROD (DEC-023,
/// PROPOSED).
///
/// Chosen at build time with `--dart-define=MFW_ENV=<name>`. No secret and
/// no address is kept here; per-environment settings follow DEC-003.
enum AppEnvironment {
  /// ENV-LOCAL.
  local,

  /// ENV-TEST, the non-production project.
  test,

  /// ENV-PROD.
  prod;

  /// The environment called [name]. Throws [ArgumentError] for any other
  /// name, so a wrong build setting fails at start-up.
  static AppEnvironment fromName(String name) {
    for (final AppEnvironment environment in values) {
      if (environment.name == name) {
        return environment;
      }
    }
    throw ArgumentError.value(name, 'name', 'not an environment');
  }
}

/// The build-time environment name; `local` when none is given.
const String environmentName = String.fromEnvironment(
  'MFW_ENV',
  defaultValue: 'local',
);
