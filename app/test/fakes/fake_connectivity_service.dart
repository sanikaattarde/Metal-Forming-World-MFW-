import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';

import 'fake_streams.dart';

/// Fake MOD-01 connectivity, set by the test.
final class FakeConnectivityService implements ConnectivityService {
  /// Creates the fake on [type].
  FakeConnectivityService([this._type = ConnectionType.wifi]);

  ConnectionType _type;
  final StreamController<void> _changes = StreamController<void>.broadcast(
    sync: true,
  );

  /// The connection type now.
  ConnectionType get type => _type;

  /// Changes the connection type.
  set type(ConnectionType next) {
    _type = next;
    _changes.add(null);
  }

  @override
  Stream<ConnectionType> watch() =>
      watchDerived(() => _type, <Stream<void>>[_changes.stream]);

  @override
  Future<ConnectionType> current() async => _type;
}
