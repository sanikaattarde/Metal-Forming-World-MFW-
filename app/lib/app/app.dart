import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Text shown by the placeholder shell.
///
/// PLACEHOLDER: brand assets not received. No MFW name, logo, colour or font
/// is used until they arrive.
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

/// Root widget of the app.
class MfwApp extends ConsumerWidget {
  /// Creates the root widget.
  const MfwApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(routerConfig: ref.watch(routerProvider));
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
