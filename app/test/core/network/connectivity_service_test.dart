import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/core/network/connectivity_service.dart';

/// The plugin, with what it reports set by the test.
final class _FakeConnectivity implements Connectivity {
  List<ConnectivityResult> now = <ConnectivityResult>[ConnectivityResult.wifi];
  Object? failure;
  final StreamController<List<ConnectivityResult>> changes =
      StreamController<List<ConnectivityResult>>();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    final Object? f = failure;
    if (f != null) {
      throw f;
    }
    return now;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => changes.stream;
}

void main() {
  group('connectionTypeOf [FR-DL-004]', () {
    for (final (List<ConnectivityResult> results, ConnectionType expected)
        in <(List<ConnectivityResult>, ConnectionType)>[
          (<ConnectivityResult>[ConnectivityResult.wifi], ConnectionType.wifi),
          (
            <ConnectivityResult>[ConnectivityResult.mobile],
            ConnectionType.mobile,
          ),
          (
            <ConnectivityResult>[
              ConnectivityResult.mobile,
              ConnectivityResult.wifi,
            ],
            ConnectionType.wifi,
          ),
          (
            <ConnectivityResult>[ConnectivityResult.ethernet],
            ConnectionType.other,
          ),
          (
            <ConnectivityResult>[
              ConnectivityResult.mobile,
              ConnectivityResult.ethernet,
            ],
            ConnectionType.other,
          ),
          (
            <ConnectivityResult>[
              ConnectivityResult.vpn,
              ConnectivityResult.mobile,
            ],
            ConnectionType.mobile,
          ),
          (
            <ConnectivityResult>[ConnectivityResult.satellite],
            ConnectionType.mobile,
          ),
          (<ConnectivityResult>[ConnectivityResult.vpn], ConnectionType.other),
          (
            <ConnectivityResult>[ConnectivityResult.bluetooth],
            ConnectionType.other,
          ),
          (
            <ConnectivityResult>[ConnectivityResult.other],
            ConnectionType.other,
          ),
          (<ConnectivityResult>[ConnectivityResult.none], ConnectionType.none),
          (<ConnectivityResult>[], ConnectionType.none),
        ]) {
      test('${results.map((ConnectivityResult r) => r.name).join('+')} is '
          '${expected.name}', () {
        expect(connectionTypeOf(results), expected);
      });
    }
  });

  group('PluginConnectivityService [MOD01-P2-T03]', () {
    test('current reads the plugin', () async {
      final _FakeConnectivity plugin = _FakeConnectivity()
        ..now = <ConnectivityResult>[ConnectivityResult.mobile];

      expect(
        await PluginConnectivityService(connectivity: plugin).current(),
        ConnectionType.mobile,
      );
    });

    test(
      'a platform failure reads as mobile, so the reader is warned',
      () async {
        final _FakeConnectivity plugin = _FakeConnectivity()
          ..failure = PlatformException(code: 'synthetic');

        expect(
          await PluginConnectivityService(connectivity: plugin).current(),
          ConnectionType.mobile,
        );
      },
    );

    test('watch emits each change once, and maps a platform failure to '
        'mobile without ending', () async {
      final _FakeConnectivity plugin = _FakeConnectivity();
      final List<ConnectionType> seen = <ConnectionType>[];
      final StreamSubscription<ConnectionType> sub = PluginConnectivityService(
        connectivity: plugin,
      ).watch().listen(seen.add);

      plugin.changes
        ..add(<ConnectivityResult>[ConnectivityResult.wifi])
        ..add(<ConnectivityResult>[
          ConnectivityResult.wifi,
          ConnectivityResult.mobile,
        ])
        ..add(<ConnectivityResult>[ConnectivityResult.mobile])
        ..addError(PlatformException(code: 'synthetic'))
        ..add(<ConnectivityResult>[ConnectivityResult.none]);
      await pumpEventQueue();
      await sub.cancel();

      expect(seen, <ConnectionType>[
        ConnectionType.wifi,
        ConnectionType.mobile,
        ConnectionType.none,
      ]);
    });

    test('an Error is a programming error and is passed on', () async {
      final _FakeConnectivity plugin = _FakeConnectivity();
      final List<Object> errors = <Object>[];
      final StreamSubscription<ConnectionType> sub = PluginConnectivityService(
        connectivity: plugin,
      ).watch().listen((_) {}, onError: errors.add);

      plugin.changes.addError(StateError('synthetic'));
      await pumpEventQueue();
      await sub.cancel();

      expect(errors.single, isA<StateError>());
    });
  });
}
