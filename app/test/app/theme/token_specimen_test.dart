// The token specimen golden (MOD01-P2-T02 "Tests").
//
// Run on a Mac with:
//   flutter test --dart-define=MFW_GOLDENS=true test/app/theme/token_specimen_test.dart
// and add --update-goldens to redraw it. Without MFW_GOLDENS the test is
// skipped, because text drawing differs between macOS and the Linux runner
// of the pull-request checks.
//
// It passes only where text is drawn exactly as on the Mac that drew the
// golden (YG's). On another Mac it can fail by a few pixels of text, as the
// drawing tests of the T-02.1 prototype do; redraw it there before using it.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';

import 'brand_fonts.dart';

const bool _goldens = bool.fromEnvironment('MFW_GOLDENS');

void main() {
  testWidgets('token specimen matches the recorded golden [NFR-UX-001]', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(loadBrandFonts);
    tester.view.physicalSize = const Size(780, 2900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildMfwTheme(),
        home: const TokenSpecimen(),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TokenSpecimen),
      matchesGoldenFile('goldens/token_specimen.png'),
    );
  }, skip: !_goldens);
}

/// Every token on one page, for the golden and for review against the
/// Figma variables.
class TokenSpecimen extends StatelessWidget {
  /// Creates the specimen.
  const TokenSpecimen({super.key});

  static const List<(String, Color)> _colours = <(String, Color)>[
    ('action #F0233B', MfwColours.action),
    ('actionPressed #161616', MfwColours.actionPressed),
    ('heading #282828', MfwColours.heading),
    ('body #48586A', MfwColours.body),
    ('surface #FFFFFF', MfwColours.surface),
    ('inputFill #F5F7F8', MfwColours.inputFill),
    ('divider #DCDCDE', MfwColours.divider),
    ('error #F0233B (proposed)', MfwColours.error),
    ('success #3DD800 (proposed)', MfwColours.success),
    ('warning #FFAE25 (proposed)', MfwColours.warning),
  ];

  @override
  Widget build(BuildContext context) {
    final List<(String, TextStyle)> type = <(String, TextStyle)>[
      ('Display, Fraunces 600 32', MfwType.display),
      ('Heading 1, Fraunces 600 30', MfwType.h1),
      ('Heading 2, Fraunces 600 24', MfwType.h2),
      ('Heading 3, Fraunces 600 20', MfwType.h3),
      ('Heading 4, Fraunces 400 18', MfwType.h4),
      ('Heading 5, Fraunces 500 15', MfwType.h5),
      ('LABEL, PLUS JAKARTA SANS 600 12', MfwType.label),
      ('Body text, Inter 400 14. Metal forming news.', MfwType.body),
      ('Input text, Inter 400 12', MfwType.input),
      ('Form label, Fraunces 600 14', MfwType.formLabel),
      ('Small text, Inter 400 11', MfwType.small),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Token specimen')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.download), label: 'Downloads'),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            label: 'News',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          for (final (String name, Color colour) in _colours)
            Padding(
              padding: const EdgeInsets.only(bottom: MfwSpace.xs),
              child: Row(
                children: <Widget>[
                  Container(
                    width: MfwSpace.xxxl,
                    height: MfwSpace.xl,
                    decoration: BoxDecoration(
                      color: colour,
                      border: Border.all(color: MfwColours.divider),
                    ),
                  ),
                  const SizedBox(width: MfwSpace.md),
                  Text(name, style: MfwType.body),
                ],
              ),
            ),
          const Divider(height: MfwSpace.xl),
          for (final (String sample, TextStyle style) in type)
            Padding(
              padding: const EdgeInsets.only(bottom: MfwSpace.sm),
              child: Text(sample, style: style),
            ),
          const Divider(height: MfwSpace.xl),
          Wrap(
            spacing: MfwSpace.sm,
            runSpacing: MfwSpace.sm,
            children: <Widget>[
              FilledButton(onPressed: () {}, child: const Text('Read')),
              OutlinedButton(onPressed: () {}, child: const Text('Download')),
              TextButton(onPressed: () {}, child: const Text('Read more')),
              const FilledButton(onPressed: null, child: Text('Disabled')),
            ],
          ),
          const SizedBox(height: MfwSpace.lg),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Email address',
              hintText: 'name@example.com',
            ),
          ),
          const SizedBox(height: MfwSpace.md),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: 'Enter your password',
              prefixIcon: Icon(Icons.error_outline, color: MfwColours.error),
            ),
          ),
          const SizedBox(height: MfwSpace.md),
          const SearchBar(
            hintText: 'Search issues',
            leading: Icon(Icons.search),
          ),
          const SizedBox(height: MfwSpace.md),
          Wrap(
            spacing: MfwSpace.sm,
            children: <Widget>[
              FilterChip(
                label: const Text('Industry News'),
                selected: true,
                onSelected: (_) {},
              ),
              FilterChip(
                label: const Text('Case Studies'),
                selected: false,
                onSelected: (_) {},
              ),
            ],
          ),
          const SizedBox(height: MfwSpace.md),
          const _StatusBar(
            colour: MfwColours.success,
            icon: Icons.check_circle_outline,
            text: 'Downloaded. Available offline.',
          ),
          const SizedBox(height: MfwSpace.sm),
          const _StatusBar(
            colour: MfwColours.warning,
            icon: Icons.warning_amber_outlined,
            text: 'Low storage: 120 MB free.',
          ),
          const SizedBox(height: MfwSpace.md),
          const LinearProgressIndicator(value: 0.4),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.colour,
    required this.icon,
    required this.text,
  });

  final Color colour;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colour,
      child: Padding(
        padding: const EdgeInsets.all(MfwSpace.md),
        child: Row(
          children: <Widget>[
            Icon(icon, color: MfwColours.onStatus),
            const SizedBox(width: MfwSpace.sm),
            Text(
              text,
              style: MfwType.body.copyWith(color: MfwColours.onStatus),
            ),
          ],
        ),
      ),
    );
  }
}
