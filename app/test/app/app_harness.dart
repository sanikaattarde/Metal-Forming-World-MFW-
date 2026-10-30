import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/contracts/contracts.dart';

/// Pumps [MfwApp] with [auth] as the AuthService, waits for the first
/// access state, and returns the router.
Future<GoRouter> pumpApp(WidgetTester tester, AuthService auth) async {
  final ProviderContainer container = ProviderContainer.test(
    overrides: [authServiceProvider.overrideWithValue(auth)],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MfwApp()),
  );
  await tester.pumpAndSettle();
  return container.read(routerProvider);
}
