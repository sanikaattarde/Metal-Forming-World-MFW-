import 'dart:async';

import 'package:mfw_app/contracts/contracts.dart';

/// A [ConnectivityService] whose connection the test sets (MOD-01).
final class FakeConnectivityService implements ConnectivityService {
  /// Starts on [type], Wi-Fi unless given.
  FakeConnectivityService([this._type = ConnectionType.wifi]);

  ConnectionType _type;
  final StreamController<ConnectionType> _changes =
      StreamController<ConnectionType>.broadcast(sync: true);

  /// Changes the connection and tells every listener.
  set type(ConnectionType type) {
    _type = type;
    _changes.add(type);
  }

  @override
  Future<ConnectionType> current() async => _type;

  @override
  Stream<ConnectionType> watch() => _changes.stream;
}
