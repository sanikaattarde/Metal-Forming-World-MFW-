import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/app.dart';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

/// Pumps [MfwApp] with [auth] as the `AuthService`, waits for the first
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

/// As [pumpApp], with MOD-04's [profiles] for the profile screens.
Future<GoRouter> pumpAppWithProfiles(
  WidgetTester tester,
  AuthService auth,
  AccountProfileRepository profiles,
) async {
  final ProviderContainer container = ProviderContainer.test(
    overrides: [
      authServiceProvider.overrideWithValue(auth),
      profileRepositoryProvider.overrideWithValue(profiles),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MfwApp()),
  );
  await tester.pumpAndSettle();
  return container.read(routerProvider);
}

/// As [pumpApp], with the given reader-side services (MOD-05 onwards).
Future<GoRouter> pumpAppWithContent(
  WidgetTester tester,
  AuthService auth, {
  CatalogueRepository? catalogue,
}) async {
  final ProviderContainer container = ProviderContainer.test(
    overrides: [
      authServiceProvider.overrideWithValue(auth),
      catalogueRepositoryProvider.overrideWithValue(catalogue),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MfwApp()),
  );
  await tester.pumpAndSettle();
  return container.read(routerProvider);
}
