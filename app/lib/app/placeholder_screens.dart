import 'package:flutter/material.dart';
import 'package:mfw_app/app/shell_text.dart';

/// Text shown by the placeholder home screen.
///
/// PLACEHOLDER: brand assets not received. No MFW name, logo, colour or font
/// is used until they arrive.
const String placeholderShellLabel = 'Placeholder shell';

/// The home screen (SCR-A-10). Its content waits for the M2 designs.
class PlaceholderShellScreen extends StatelessWidget {
  /// Creates the placeholder home screen.
  const PlaceholderShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ShellText.home)),
      body: const Center(child: Text(placeholderShellLabel)),
    );
  }
}

/// A screen whose design waits for M2 (SCREEN_INVENTORY_AND_NAVIGATION
/// section 5).
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

/// Shown for an unknown route (MOD-01, SCR-A-22).
class NotFoundScreen extends StatelessWidget {
  /// Creates the not-found screen.
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ShellText.notFound)),
      body: const Center(child: Text(ShellText.notFoundBody)),
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
