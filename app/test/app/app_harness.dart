import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/app.dart';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';
import 'package:mfw_app/features/notifications/notifications.dart';

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
  DownloadManager? downloads,
  PdfRenderer? renderer,
  LibraryRepository? library,
}) async {
  final ProviderContainer container = ProviderContainer.test(
    overrides: [
      authServiceProvider.overrideWithValue(auth),
      catalogueRepositoryProvider.overrideWithValue(catalogue),
      downloadManagerProvider.overrideWithValue(downloads),
      issueTitlesProvider.overrideWithValue(null),
      if (renderer != null) pdfRendererProvider.overrideWithValue(renderer),
      libraryRepositoryProvider.overrideWithValue(library),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MfwApp()),
  );
  await tester.pumpAndSettle();
  return container.read(routerProvider);
}

/// As [pumpApp], with MOD-11's [notifications] and the [navigator] its taps
/// go to (MOD11-P2-T02). The router is the real one when [navigator] is null.
Future<GoRouter> pumpAppWithNotifications(
  WidgetTester tester,
  AuthService auth,
  DeviceNotificationService notifications, {
  AppNavigator? navigator,
}) async {
  final ProviderContainer container = ProviderContainer.test(
    overrides: [
      authServiceProvider.overrideWithValue(auth),
      notificationServiceProvider.overrideWithValue(notifications),
      if (navigator != null) appNavigatorProvider.overrideWithValue(navigator),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const MfwApp()),
  );
  await tester.pumpAndSettle();
  return container.read(routerProvider);
}
