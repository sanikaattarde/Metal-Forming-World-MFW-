import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../contracts/platform.dart';

/// The connection type for a list of active connections, as the platform
/// reports them (MOD01-P2-T03, RS FR-DL-004).
///
/// The mobile-data warning needs to know whether a download would use a
/// metered connection, so an unmetered one is preferred when several are
/// listed: Wi-Fi, then Ethernet (as [ConnectionType.other]), then mobile.
/// A satellite link counts as mobile, because it is usually metered. A VPN
/// or Bluetooth link alone is [ConnectionType.other], because the network
/// beneath it is not reported. An empty list, or one with only `none`, is
/// [ConnectionType.none].
///
/// The platform reports an interface, not whether the internet can be
/// reached, so a reader can be "on Wi-Fi" with no internet. Requests still
/// fail with `network` then (`HttpsGetClient`).
ConnectionType connectionTypeOf(List<ConnectivityResult> results) {
  if (results.contains(ConnectivityResult.wifi)) {
    return ConnectionType.wifi;
  }
  if (results.contains(ConnectivityResult.ethernet)) {
    return ConnectionType.other;
  }
  if (results.contains(ConnectivityResult.mobile) ||
      results.contains(ConnectivityResult.satellite)) {
    return ConnectionType.mobile;
  }
  if (results.any((ConnectivityResult r) => r != ConnectivityResult.none)) {
    return ConnectionType.other;
  }
  return ConnectionType.none;
}

/// [ConnectivityService] on the `connectivity_plus` plugin (DEP-50).
final class PluginConnectivityService implements ConnectivityService {
  /// Creates the service. [connectivity] replaces the plugin in tests.
  PluginConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Emits the type when it changes. A platform exception is reported as
  /// [ConnectionType.mobile], for the reason [current] gives, and the
  /// stream goes on. An [Error] is a programming error and passes through.
  @override
  Stream<ConnectionType> watch() => _connectivity.onConnectivityChanged
      .map(connectionTypeOf)
      .transform(_exceptionsAsMobile)
      .distinct();

  /// The type now. If the platform cannot say, it is reported as
  /// [ConnectionType.mobile], so the reader is warned before a download
  /// rather than surprised by its data use (PROPOSED).
  @override
  Future<ConnectionType> current() async {
    try {
      return connectionTypeOf(await _connectivity.checkConnectivity());
    } on Exception {
      return ConnectionType.mobile;
    }
  }

  static final StreamTransformer<ConnectionType, ConnectionType>
  _exceptionsAsMobile =
      StreamTransformer<ConnectionType, ConnectionType>.fromHandlers(
        handleError:
            (
              Object error,
              StackTrace stackTrace,
              EventSink<ConnectionType> sink,
            ) {
              if (error is Exception) {
                sink.add(ConnectionType.mobile);
              } else {
                sink.addError(error, stackTrace);
              }
            },
      );
}
