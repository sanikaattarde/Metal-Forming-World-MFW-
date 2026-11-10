import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

/// A document whose pages say "Page n".
final class FakeDocument implements ReaderDocument {
  FakeDocument(this.pageCount, {this.landscapePages = const <int>{}});

  @override
  final int pageCount;
  final Set<int> landscapePages;
  int closed = 0;

  @override
  Widget page(int pageNumber) => Center(child: Text('Page $pageNumber'));

  @override
  bool isLandscape(int pageNumber) => landscapePages.contains(pageNumber);

  @override
  Future<void> close() async => closed++;
}

/// Opens [result] for any file.
final class FakeRenderer implements PdfRenderer {
  FakeRenderer(this.result);

  final Result<PdfDocumentHandle> result;
  final List<LocalIssueFile> opened = <LocalIssueFile>[];

  @override
  Future<Result<PdfDocumentHandle>> open(LocalIssueFile file) async {
    opened.add(file);
    return result;
  }
}

const LocalIssueFile file = LocalIssueFile(
  issueId: 'fx-iss-01',
  fileRevision: 1,
  path: '/private/issues/issue-fx-iss-01-r1.pdf',
);

Future<void> pumpReader(
  WidgetTester tester,
  PdfRenderer renderer, {
  int? initialPage,
  VoidCallback? onDownloadAgain,
  VoidCallback? onClose,
  List<Widget> Function(ReaderController reader)? actions,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildMfwTheme(),
      home: ReaderScreen(
        file: file,
        title: 'Test Issue 01',
        renderer: renderer,
        initialPage: initialPage,
        onDownloadAgain: onDownloadAgain,
        onClose: onClose,
        actions: actions,
      ),
    ),
  );
}

void main() {
  group('ReaderScreen, SCR-A-14 [MOD07-P2-T01]', () {
    testWidgets('opens the handed-over file at the first page [FR-READ-001, '
        'IC-03]', (WidgetTester tester) async {
      final FakeRenderer renderer = FakeRenderer(
        Ok<PdfDocumentHandle>(FakeDocument(4)),
      );
      await pumpReader(tester, renderer);
      expect(find.bySemanticsLabel('Opening the issue'), findsOneWidget);
      await tester.pumpAndSettle();

      expect(renderer.opened.single.path, file.path);
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('1 / 4'), findsOneWidget);
      expect(find.text('Test Issue 01'), findsOneWidget);
    });

    testWidgets('the buttons turn pages, and stop at either end '
        '[FR-READ-003, CODING_STANDARDS 9 rule 6]', (
      WidgetTester tester,
    ) async {
      await pumpReader(
        tester,
        FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(3))),
      );
      await tester.pumpAndSettle();
      final Finder previous = find.widgetWithIcon(
        IconButton,
        Icons.chevron_left,
      );
      final Finder next = find.widgetWithIcon(IconButton, Icons.chevron_right);
      expect(tester.widget<IconButton>(previous).onPressed, isNull);

      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('2 / 3'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);

      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('3 / 3'), findsOneWidget);
      expect(tester.widget<IconButton>(next).onPressed, isNull);

      await tester.tap(previous);
      await tester.pumpAndSettle();
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('a swipe turns the page [FR-READ-007]', (
      WidgetTester tester,
    ) async {
      await pumpReader(
        tester,
        FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(3))),
      );
      await tester.pumpAndSettle();
      await tester.fling(find.byType(PageView), const Offset(-400, 0), 1000);
      await tester.pumpAndSettle();
      expect(find.text('2 / 3'), findsOneWidget);
    });

    testWidgets('opens at a given page, clamped to the document '
        '[section 4.3]', (WidgetTester tester) async {
      await pumpReader(
        tester,
        FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(4))),
        initialPage: 9,
      );
      await tester.pumpAndSettle();
      expect(find.text('4 / 4'), findsOneWidget);
      expect(find.text('Page 4'), findsOneWidget);
    });

    testWidgets('the reader reports each page it shows, and goes to a page '
        'on request [ReaderController]', (WidgetTester tester) async {
      ReaderController? reader;
      final List<int> pages = <int>[];
      await pumpReader(
        tester,
        FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(5))),
        actions: (ReaderController given) {
          if (reader == null) {
            reader = given;
            given.watchCurrentPage().listen(pages.add);
          }
          return const <Widget>[];
        },
      );
      await tester.pumpAndSettle();
      expect(reader!.mode, ReaderMode.swipe);

      await reader!.goToPage(4);
      await tester.pumpAndSettle();
      expect(find.text('4 / 5'), findsOneWidget);
      expect(pages, <int>[1, 4]);
    });

    testWidgets('a damaged file says so and offers to download it again '
        '[FR-READ-010, AC-2.6]', (WidgetTester tester) async {
      int again = 0;
      await pumpReader(
        tester,
        FakeRenderer(
          const Err<PdfDocumentHandle>(
            AppFailure(FailureCode.fileCorrupt, retryable: true),
          ),
        ),
        onDownloadAgain: () => again++,
      );
      await tester.pumpAndSettle();
      expect(find.text('This issue could not be opened'), findsOneWidget);
      expect(find.byTooltip('Next page'), findsNothing);
      await tester.tap(find.text('Download again'));
      expect(again, 1);
    });

    testWidgets('a missing file says it cannot be opened, with Close', (
      WidgetTester tester,
    ) async {
      int closed = 0;
      await pumpReader(
        tester,
        FakeRenderer(
          const Err<PdfDocumentHandle>(AppFailure(FailureCode.notFound)),
        ),
        onClose: () => closed++,
      );
      await tester.pumpAndSettle();
      expect(find.text('This issue cannot be opened'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Close'));
      expect(closed, 1);
    });

    testWidgets('leaving the reader closes the document', (
      WidgetTester tester,
    ) async {
      final FakeDocument document = FakeDocument(2);
      await pumpReader(tester, FakeRenderer(Ok<PdfDocumentHandle>(document)));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(document.closed, 1);
    });

    testWidgets('meets the tap-target and label guidelines', (
      WidgetTester tester,
    ) async {
      await pumpReader(
        tester,
        FakeRenderer(Ok<PdfDocumentHandle>(FakeDocument(4))),
        onClose: () {},
      );
      await tester.pumpAndSettle();
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    });
  });
}
