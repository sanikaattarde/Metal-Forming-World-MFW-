import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// Pumps [MfwApp] with [auth] as the AuthService and [services] behind the
/// routed screens, on a tall surface so that issue details fit, waits for
/// the first access state, and returns the router.
Future<GoRouter> pumpApp(
  WidgetTester tester,
  AuthService auth, {
  AppServices services = const AppServices(),
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final ProviderContainer container = ProviderContainer.test(
    overrides: [
      authServiceProvider.overrideWithValue(auth),
      appServicesProvider.overrideWithValue(services),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MfwApp()),
  );
  await tester.pumpAndSettle();
  return container.read(routerProvider);
}
