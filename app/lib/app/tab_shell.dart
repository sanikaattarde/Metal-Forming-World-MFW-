import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shell_text.dart';

/// The app's five tabs, from the reader frames (READER_SCREEN_DESIGNS
/// section 4, PROPOSED): Home, News, Library, Downloads and Settings. The
/// order follows the route branches of `buildRouter`.
///
/// Library and Downloads need full access, so the guard sends a visitor who
/// taps them to the missing step (DEC-014).
class TabShell extends StatelessWidget {
  /// Creates the shell around [shell].
  const TabShell({required this.shell, super.key});

  /// The branch navigators.
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Tapping the open tab again returns it to its first page.
        onDestinationSelected: (int index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: ShellText.home,
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            selectedIcon: Icon(Icons.article),
            label: ShellText.news,
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: ShellText.library,
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: ShellText.downloads,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: ShellText.settings,
          ),
        ],
      ),
    );
  }
}
