import 'package:flutter/material.dart';

import 'shell_text.dart';

/// A screen whose design and feature wait for later tasks
/// (`SCREEN_INVENTORY_AND_NAVIGATION.md` section 5).
class PlaceholderScreen extends StatelessWidget {
  /// Creates a placeholder titled [title], showing [detail] if given.
  const PlaceholderScreen({required this.title, this.detail, super.key});

  /// Screen title.
  final String title;

  /// What the screen would show, for example an ID.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(detail ?? ShellText.placeholderBody)),
    );
  }
}

/// SCR-A-22, shown for an unknown route (MOD-01), with a way home.
class NotFoundScreen extends StatelessWidget {
  /// Creates the not-found screen; [onGoHome] opens home.
  const NotFoundScreen({required this.onGoHome, super.key});

  /// Called by the home action.
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ShellText.notFound)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(ShellText.notFoundBody, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onGoHome,
                child: const Text(ShellText.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown until the first access state arrives (RS FR-STATE-001).
class ShellLoadingScreen extends StatelessWidget {
  /// Creates the loading screen.
  const ShellLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(ShellText.loading),
          ],
        ),
      ),
    );
  }
}

/// Shown when the access state cannot be read, with a retry
/// (RS FR-STATE-003).
class ShellErrorScreen extends StatelessWidget {
  /// Creates the error screen; [onRetry] asks for the access state again.
  const ShellErrorScreen({required this.onRetry, super.key});

  /// Called by the Retry control.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(ShellText.shellError, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: const Text(ShellText.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
