// T-02.1 low-fi clickable prototype of the app screens (MOD16-P1-T05).
// A spike: never shipped, not built on the app's code, and its look is not
// a design. Every screen shows its SCR-A-nn ID from
// SCREEN_INVENTORY_AND_NAVIGATION section 5. The prototype controls (the
// tune icon) switch the states of sections 3 and 7. No MFW content is used.

import 'package:flutter/material.dart';
import 'package:mfw_prototype/model.dart';
import 'package:mfw_prototype/screens_catalogue.dart';
import 'package:mfw_prototype/screens_library.dart';
import 'package:mfw_prototype/screens_news.dart';
import 'package:mfw_prototype/screens_settings.dart';
import 'package:mfw_prototype/widgets.dart';

void main() {
  runApp(PrototypeApp(model: ProtoModel()));
}

/// The prototype app.
class PrototypeApp extends StatelessWidget {
  /// Creates the app over [model].
  const PrototypeApp({required this.model, super.key});

  /// The prototype state.
  final ProtoModel model;

  @override
  Widget build(BuildContext context) {
    return Proto(
      model: model,
      child: MaterialApp(
        title: 'MFW prototype (low-fi)',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.grey,
            dynamicSchemeVariant: DynamicSchemeVariant.monochrome,
          ),
        ),
        home: const Shell(),
        onGenerateRoute: (RouteSettings settings) {
          final List<String> parts = Uri.parse(settings.name ?? '')
              .pathSegments;
          if (parts.length == 2 && parts.first == 'issues') {
            final Issue issue = sampleIssues.firstWhere(
              (Issue issue) => issue.id == parts[1],
              orElse: () => sampleIssues.first,
            );
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (BuildContext context) =>
                  IssueDetailsScreen(issue: issue),
            );
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (BuildContext context) => const NotFoundScreen(),
        ),
      ),
    );
  }
}

/// The tabs. Their arrangement is an M2 design decision
/// (SCREEN_INVENTORY_AND_NAVIGATION section 4); this one is PROPOSED for
/// the walk-through only.
class Shell extends StatefulWidget {
  /// Creates the shell.
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    NewsListScreen(),
    LibraryScreen(),
    DownloadsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (int tab) => setState(() => _tab = tab),
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.feed_outlined), label: 'News'),
          NavigationDestination(
            icon: Icon(Icons.collections_bookmark_outlined),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
