import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme/font_licences.dart';
import 'theme/mfw_theme.dart';

/// Text shown by the placeholder shell.
///
/// The theme uses the website's colours and fonts (working position of
/// 8 November 2026, OQ-63). PLACEHOLDER: no MFW name or logo is shown yet,
/// because the logo file stays out of the repository (DEC-024).
const String placeholderShellLabel = 'Placeholder shell';

/// Router stub with one route. The route table of `API_AND_MODULE_CONTRACTS.md`
/// section 6.1 replaces it in a later task.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) =>
            const PlaceholderShellScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

/// Starts the app inside its Riverpod scope.
///
/// Riverpod is used in `app/lib/app/` only (DEC-013), so the scope is created
/// here and not in `main.dart`.
void runMfwApp() {
  registerFontLicences();
  runApp(const ProviderScope(child: MfwApp()));
}

/// Root widget of the app.
class MfwApp extends ConsumerWidget {
  /// Creates the root widget.
  const MfwApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      theme: buildMfwTheme(),
      themeMode: ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

/// The only screen of the scaffold.
class PlaceholderShellScreen extends StatelessWidget {
  /// Creates the placeholder screen.
  const PlaceholderShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text(placeholderShellLabel)));
  }
}
