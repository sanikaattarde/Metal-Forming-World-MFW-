import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../contracts/contracts.dart';
import '../core/config/app_config.dart';
import '../core/config/firebase_settings.dart';
import '../features/account/account.dart';
import '../core/network/connectivity_service.dart';
import 'account_routes.dart';
import 'firebase_bootstrap.dart';
import 'placeholder_screens.dart';
import 'router.dart';
import 'router_app_navigator.dart';
import 'theme/font_licences.dart';
import 'theme/mfw_theme.dart';
import 'unavailable_auth_service.dart';

/// The Firebase services, set by [runMfwApp] once Firebase has started.
/// Null in tests, which use fakes.
final Provider<FirebaseServices?> firebaseServicesProvider =
    Provider<FirebaseServices?>((Ref ref) => null);

/// MOD-04's profile repository (MOD04-P2-T01) over Firebase once it has
/// started, or null without it, in which case the profile screens stay
/// placeholders. Tests override it with a fake.
final Provider<AccountProfileRepository?> profileRepositoryProvider =
    Provider<AccountProfileRepository?>((Ref ref) {
      final FirebaseServices? firebase = ref.watch(firebaseServicesProvider);
      if (firebase == null) {
        return null;
      }
      return AccountProfileRepository(
        firebase.identity,
        firebase.backend,
        FirestoreProfileDocuments(firebase.firestore),
      );
    });

/// MOD-03's `AuthService` (MOD03-P2-T01 to T03): [AccountAuthService] over
/// Firebase, with MOD-04's profile status, once Firebase has started, and
/// [UnavailableAuthService] without it, so a test that sets neither runs as
/// a visitor. Tests override it with a fake.
///
/// Riverpod is used in `app/lib/app/` only (DEC-013).
final Provider<AuthService> authServiceProvider = Provider<AuthService>((
  Ref ref,
) {
  final FirebaseServices? firebase = ref.watch(firebaseServicesProvider);
  if (firebase == null) {
    return const UnavailableAuthService();
  }
  final AccountProfileRepository? profiles = ref.watch(
    profileRepositoryProvider,
  );
  return AccountAuthService(
    firebase.identity,
    profileStatus: profiles?.watchStatus,
  );
});

/// The current access state (`API_AND_MODULE_CONTRACTS.md` section 4.1).
///
/// No automatic retry: the shell shows an error with a Retry control.
final StreamProvider<AccessState> accessStateProvider =
    StreamProvider<AccessState>(
      (Ref ref) => ref.watch(authServiceProvider).watchAccessState(),
      retry: _noAutomaticRetry,
    );

Duration? _noAutomaticRetry(int retryCount, Object error) => null;

/// The router: the route table and the access guard on the latest access
/// state (MOD01-P2-T01, DEC-014).
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<AccessState> accessState = ValueNotifier<AccessState>(
    AccessState.signedOut,
  );
  ref.listen<AsyncValue<AccessState>>(accessStateProvider, (
    AsyncValue<AccessState>? previous,
    AsyncValue<AccessState> next,
  ) {
    final AccessState? value = next.value;
    if (value != null) {
      accessState.value = value;
    }
  }, fireImmediately: true);
  final GoRouter router = buildRouter(
    accessState,
    screens: accountScreens(
      auth: ref.read(authServiceProvider),
      profiles: ref.read(profileRepositoryProvider),
    ),
  );
  ref.onDispose(() {
    router.dispose();
    accessState.dispose();
  });
  return router;
});

/// The build's settings for its environment (MOD01-P2-T04). `runMfwApp`
/// reads them once and puts that value here, so a wrong build fails before
/// any screen. Without that override (in tests) it reads them itself.
final Provider<AppConfig> appConfigProvider = Provider<AppConfig>(
  (Ref ref) => AppConfig.fromEnvironment(),
);

/// The connection type for the mobile-data warning (MOD01-P2-T03,
/// RS FR-DL-004). Tests override it with `FakeConnectivityService`.
final Provider<ConnectivityService> connectivityServiceProvider =
    Provider<ConnectivityService>((Ref ref) => PluginConnectivityService());

/// The `AppNavigator` for MOD-11: through the router and its guard
/// (BR-005).
final Provider<AppNavigator> appNavigatorProvider = Provider<AppNavigator>(
  (Ref ref) => RouterAppNavigator(ref.watch(routerProvider)),
);

/// Starts Firebase and then the app inside its Riverpod scope.
///
/// Riverpod is used in `app/lib/app/` only (DEC-013), so the scope is created
/// here and not in `main.dart`.
Future<void> runMfwApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A wrong build fails here, before any screen (MOD01-P2-T04), and the
  // values read here are the ones the app uses, so they are read once.
  final AppConfig config = AppConfig.fromEnvironment();
  final FirebaseSettings firebaseSettings = FirebaseSettings.fromEnvironment(
    config.environment,
  );
  final FirebaseServices firebase = await startFirebase(firebaseSettings);
  registerFontLicences();
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        firebaseServicesProvider.overrideWithValue(firebase),
      ],
      child: const MfwApp(),
    ),
  );
}

/// Root widget of the app.
///
/// Shows a loading screen until the first access state arrives, an error
/// screen with Retry if it cannot be read, and the router after that. The
/// theme uses the website's colours and fonts (working position of
/// 8 November 2026, OQ-63). PLACEHOLDER: no MFW name or logo is shown yet,
/// because the logo file stays out of the repository (DEC-024).
class MfwApp extends ConsumerWidget {
  /// Creates the root widget.
  const MfwApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AccessState> accessState = ref.watch(accessStateProvider);
    final ThemeData theme = buildMfwTheme();
    if (accessState.hasValue) {
      return MaterialApp.router(
        theme: theme,
        themeMode: ThemeMode.light,
        routerConfig: ref.watch(routerProvider),
      );
    }
    if (accessState.hasError) {
      return MaterialApp(
        theme: theme,
        themeMode: ThemeMode.light,
        home: ShellErrorScreen(
          onRetry: () => ref.invalidate(accessStateProvider),
        ),
      );
    }
    return MaterialApp(
      theme: theme,
      themeMode: ThemeMode.light,
      home: const ShellLoadingScreen(),
    );
  }
}
