import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mfw_app/app/placeholder_screens.dart';
import 'package:mfw_app/app/router.dart';
import 'package:mfw_app/app/router_app_navigator.dart';
import 'package:mfw_app/app/theme.dart';
import 'package:mfw_app/app/unavailable_auth_service.dart';
import 'package:mfw_app/contracts/contracts.dart';

export 'placeholder_screens.dart'
    show PlaceholderShellScreen, placeholderShellLabel;

/// MOD-03's AuthService. WS-A provides the real one; until then
/// [UnavailableAuthService]. Tests override it with a fake.
final Provider<AuthService> authServiceProvider = Provider<AuthService>(
  (Ref ref) => const UnavailableAuthService(),
);

/// The current access state (API_AND_MODULE_CONTRACTS section 4.1).
///
/// No automatic retry: the shell shows an error with a Retry control.
final StreamProvider<AccessState> accessStateProvider =
    StreamProvider<AccessState>(
      (Ref ref) => ref.watch(authServiceProvider).watchAccessState(),
      retry: _noAutomaticRetry,
    );

Duration? _noAutomaticRetry(int retryCount, Object error) => null;

/// The router: the route table and the access guard on the latest access
/// state.
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
  final GoRouter router = buildRouter(accessState);
  ref.onDispose(() {
    router.dispose();
    accessState.dispose();
  });
  return router;
});

/// The AppNavigator for MOD-11: through the router and its guard (BR-005).
final Provider<AppNavigator> appNavigatorProvider = Provider<AppNavigator>(
  (Ref ref) => RouterAppNavigator(ref.watch(routerProvider)),
);

/// Root widget of the app.
///
/// Shows a loading screen until the first access state arrives, an error
/// screen with Retry if it cannot be read, and the router after that.
class MfwApp extends ConsumerWidget {
  /// Creates the root widget.
  const MfwApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AccessState> accessState = ref.watch(accessStateProvider);
    if (accessState.hasValue) {
      return MaterialApp.router(
        theme: placeholderTheme,
        routerConfig: ref.watch(routerProvider),
      );
    }
    if (accessState.hasError) {
      return MaterialApp(
        theme: placeholderTheme,
        home: ShellErrorScreen(
          onRetry: () => ref.invalidate(accessStateProvider),
        ),
      );
    }
    return MaterialApp(
      theme: placeholderTheme,
      home: const ShellLoadingScreen(),
    );
  }
}
