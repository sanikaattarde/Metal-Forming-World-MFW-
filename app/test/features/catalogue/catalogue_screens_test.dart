import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_repository.dart';

Future<void> pumpCatalogue(
  WidgetTester tester,
  CatalogueRepository catalogue, {
  ValueChanged<String>? onOpen,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildMfwTheme(),
      home: CatalogueScreen(
        catalogue: catalogue,
        onOpenIssue: onOpen ?? (String _) {},
      ),
    ),
  );
}

final class Recorded {
  final List<String> calls = <String>[];

  IssueDetailsActions actions({bool download = true}) => IssueDetailsActions(
    onRead: (IssueSummary issue) => calls.add('read ${issue.issueId}'),
    onDownload: download
        ? (IssueSummary issue) => calls.add('download ${issue.issueId}')
        : null,
    onSignIn: () => calls.add('sign in'),
    onRegister: () => calls.add('register'),
    onContinueSignUp: () => calls.add('continue'),
  );
}

Future<void> pumpDetails(
  WidgetTester tester,
  CatalogueRepository catalogue,
  ValueListenable<AccessState> state,
  IssueDetailsActions actions, {
  String issueId = 'fx-iss-01',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildMfwTheme(),
      home: IssueDetailsScreen(
        issueId: issueId,
        catalogue: catalogue,
        accessState: state,
        actions: actions,
      ),
    ),
  );
}

void main() {
  group('CatalogueScreen, SCR-A-11 [MOD05-P2-T01]', () {
    testWidgets('lists the published issues newest first with category and '
        'date [FR-MAG-001, FR-MAG-002, FR-MAG-003, AC-1.1]', (
      WidgetTester tester,
    ) async {
      await pumpCatalogue(tester, FakeCatalogueRepository.fromFixtures());
      expect(find.bySemanticsLabel('Loading the catalogue'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('9 issues'), findsOneWidget);
      expect(find.text('Test Issue 08'), findsNothing);
      expect(find.text('Test Category A · 1 October 2026'), findsOneWidget);
      final double first = tester.getTopLeft(find.text('Test Issue 01')).dy;
      final double second = tester.getTopLeft(find.text('Test Issue 02')).dy;
      expect(first, lessThan(second));
    });

    testWidgets('opens an issue when it is tapped', (
      WidgetTester tester,
    ) async {
      final List<String> opened = <String>[];
      await pumpCatalogue(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        onOpen: opened.add,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Issue 02'));
      expect(opened, <String>['fx-iss-02']);
    });

    testWidgets('shows the empty state when nothing is published', (
      WidgetTester tester,
    ) async {
      await pumpCatalogue(
        tester,
        FakeCatalogueRepository(
          issues: const <IssueSummary>[],
          categories: const <IssueCategory>[],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No issues yet'), findsOneWidget);
    });

    testWidgets('shows a lost connection with Retry, which reads again '
        '[FR-STATE-002]', (WidgetTester tester) async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures()
            ..failure = const AppFailure(FailureCode.network, retryable: true);
      await pumpCatalogue(tester, catalogue);
      await tester.pumpAndSettle();
      expect(
        find.text('No connection. Check your connection.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);

      catalogue.failure = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('9 issues'), findsOneWidget);
    });

    testWidgets('a long title wraps without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpCatalogue(tester, FakeCatalogueRepository.fromFixtures());
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining('a deliberately long title'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('Search and filters on SCR-A-11 [MOD05-P2-T02]', () {
    testWidgets('typing a word lists only the matches, and Clear brings back '
        'every issue [FR-SRCH-001, AC-1.2]', (WidgetTester tester) async {
      await pumpCatalogue(tester, FakeCatalogueRepository.fromFixtures());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'cafe');
      await tester.pump();
      expect(find.text('1 issue'), findsOneWidget);
      expect(find.text('Test Issue 01'), findsNothing);

      await tester.tap(find.text('Clear the filters'));
      await tester.pump();
      expect(find.text('9 issues'), findsOneWidget);
      expect(find.text('cafe'), findsNothing);
    });

    testWidgets('a search with no match shows the empty state with Clear', (
      WidgetTester tester,
    ) async {
      await pumpCatalogue(tester, FakeCatalogueRepository.fromFixtures());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();
      expect(find.text('No issues match'), findsOneWidget);
      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Clear the filters'),
      );
      await tester.pump();
      expect(find.text('9 issues'), findsOneWidget);
    });

    testWidgets('the category and year filters combine [FR-SRCH-002, '
        'FR-SRCH-004, AC-1.3]', (WidgetTester tester) async {
      await pumpCatalogue(tester, FakeCatalogueRepository.fromFixtures());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, 'Category'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Test Category A'));
      await tester.pumpAndSettle();
      expect(find.text('3 issues'), findsOneWidget);
      expect(
        find.widgetWithText(FilterChip, 'Test Category A'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(FilterChip, 'Year'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, '2025'));
      await tester.pumpAndSettle();
      expect(find.text('2 issues'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, '2025'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Any year'));
      await tester.pumpAndSettle();
      expect(find.text('3 issues'), findsOneWidget);
    });

    testWidgets('the segment filter uses the segment names [FR-SRCH-003, '
        'PAC-07]', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildMfwTheme(),
          home: CatalogueScreen(
            catalogue: FakeCatalogueRepository.fromFixtures(),
            segments: const FixedSegments(<IndustrySegment>[
              IndustrySegment(segmentId: 'fx-seg-01', name: 'Segment One'),
              IndustrySegment(segmentId: 'fx-seg-02', name: 'Segment Two'),
            ]),
            onOpenIssue: (String _) {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Industry segment'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Segment Two'));
      await tester.pumpAndSettle();
      expect(find.text('5 issues'), findsOneWidget);
    });

    testWidgets('every filter chip is a large enough tap target with a label', (
      WidgetTester tester,
    ) async {
      await pumpCatalogue(tester, FakeCatalogueRepository.fromFixtures());
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });

  group('Refresh and publication changes [MOD05-P2-T04, IC-07]', () {
    Future<void> pull(WidgetTester tester) async {
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, 400),
        1000,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a newly published issue appears after pull to refresh, and '
        'goes after it is unpublished [FR-MAG-007, FR-MAG-008, AC-1.4, '
        'AC-8.7]', (WidgetTester tester) async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures();
      await pumpCatalogue(tester, catalogue);
      await tester.pumpAndSettle();
      expect(find.text('9 issues'), findsOneWidget);

      catalogue.publish('fx-iss-08');
      await pull(tester);
      expect(find.text('10 issues'), findsOneWidget);

      catalogue.unpublish('fx-iss-08');
      await pull(tester);
      expect(find.text('9 issues'), findsOneWidget);
    });

    testWidgets('a refresh that fails keeps the list and says why', (
      WidgetTester tester,
    ) async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures();
      await pumpCatalogue(tester, catalogue);
      await tester.pumpAndSettle();
      catalogue.failure = const AppFailure(
        FailureCode.network,
        retryable: true,
      );
      await pull(tester);
      expect(find.text('9 issues'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('No connection. Check your connection.'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the search is kept across a refresh', (
      WidgetTester tester,
    ) async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures();
      await pumpCatalogue(tester, catalogue);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Test Issue 08');
      await tester.pump();
      expect(find.text('No issues match'), findsOneWidget);

      catalogue.publish('fx-iss-08');
      await pull(tester);
      expect(find.text('1 issue'), findsOneWidget);
    });

    testWidgets('an open issue that is unpublished shows as gone after a '
        'refresh [FR-MAG-008]', (WidgetTester tester) async {
      final FakeCatalogueRepository catalogue =
          FakeCatalogueRepository.fromFixtures();
      await pumpDetails(
        tester,
        catalogue,
        ValueNotifier<AccessState>(AccessState.fullAccess),
        Recorded().actions(),
        issueId: 'fx-iss-02',
      );
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsOneWidget);

      catalogue.unpublish('fx-iss-02');
      await pull(tester);
      expect(find.text('This issue is no longer available'), findsOneWidget);
      expect(find.text('Read'), findsNothing);
    });
  });

  group('IssueDetailsScreen, SCR-A-12 [MOD05-P2-T01]', () {
    testWidgets('shows the public metadata [FR-MAG-005, AC-1.1]', (
      WidgetTester tester,
    ) async {
      await pumpDetails(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        ValueNotifier<AccessState>(AccessState.fullAccess),
        Recorded().actions(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Test Issue 01'), findsWidgets);
      expect(
        find.text('Test Category A · 1 October 2026 · 800 KB'),
        findsOneWidget,
      );
      expect(
        find.text('Latest synthetic issue, linked to FX-PDF-01.'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Cover of Test Issue 01'), findsOneWidget);
    });

    testWidgets('full access shows Read and Download', (
      WidgetTester tester,
    ) async {
      final Recorded recorded = Recorded();
      await pumpDetails(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        ValueNotifier<AccessState>(AccessState.fullAccess),
        recorded.actions(),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Read'));
      await tester.tap(find.text('Download'));
      expect(recorded.calls, <String>['read fx-iss-01', 'download fx-iss-01']);
    });

    testWidgets('a visitor sees sign in and register, not Read '
        '[FR-AUTH-010, BR-001]', (WidgetTester tester) async {
      final Recorded recorded = Recorded();
      await pumpDetails(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        ValueNotifier<AccessState>(AccessState.signedOut),
        recorded.actions(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsNothing);
      expect(find.text('Download'), findsNothing);
      expect(
        find.text('Sign in to read and download full issues.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Sign in'));
      await tester.tap(find.text('Create an account'));
      expect(recorded.calls, <String>['sign in', 'register']);
    });

    for (final (AccessState state, String action) in <(AccessState, String)>[
      (AccessState.emailUnverified, 'Verify email'),
      (AccessState.profileIncomplete, 'Complete profile'),
    ]) {
      testWidgets('${state.name} is sent to the missing step '
          '[BR-002, BR-003, FR-PROF-004]', (WidgetTester tester) async {
        final Recorded recorded = Recorded();
        await pumpDetails(
          tester,
          FakeCatalogueRepository.fromFixtures(),
          ValueNotifier<AccessState>(state),
          recorded.actions(),
        );
        await tester.pumpAndSettle();
        expect(find.text('Read'), findsNothing);
        await tester.tap(find.text(action));
        expect(recorded.calls, <String>['continue']);
      });
    }

    testWidgets('the actions follow a change of access state', (
      WidgetTester tester,
    ) async {
      final ValueNotifier<AccessState> state = ValueNotifier<AccessState>(
        AccessState.signedOut,
      );
      await pumpDetails(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        state,
        Recorded().actions(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsNothing);
      state.value = AccessState.fullAccess;
      await tester.pump();
      expect(find.text('Read'), findsOneWidget);
    });

    testWidgets('without downloads only Read is shown', (
      WidgetTester tester,
    ) async {
      await pumpDetails(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        ValueNotifier<AccessState>(AccessState.fullAccess),
        Recorded().actions(download: false),
      );
      await tester.pumpAndSettle();
      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Download'), findsNothing);
    });

    testWidgets('an unpublished issue says it is no longer available, with '
        'no Retry [FR-MAG-008]', (WidgetTester tester) async {
      await pumpDetails(
        tester,
        FakeCatalogueRepository.fromFixtures(),
        ValueNotifier<AccessState>(AccessState.fullAccess),
        Recorded().actions(),
        issueId: 'fx-iss-08',
      );
      await tester.pumpAndSettle();
      expect(find.text('This issue is no longer available'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      expect(find.text('Read'), findsNothing);
    });
  });
}

final class FixedSegments implements SegmentSource {
  const FixedSegments(this.segments);

  final List<IndustrySegment> segments;

  @override
  Future<Result<List<IndustrySegment>>> listSegments() async =>
      Ok<List<IndustrySegment>>(segments);
}
