import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../../fakes/fake_download_manager.dart';
import 'fake_pdf_renderer.dart';
import 'reader_test_support.dart';

ReaderSession sessionFor(
  String issueId,
  FakeDownloadManager downloads,
  FakePdfRenderer renderer, {
  int initialPage = 1,
}) {
  final ReaderSession session = ReaderSession(
    downloads: downloads,
    renderer: renderer,
    issueId: issueId,
    mode: ReaderMode.pageTurn,
    initialPage: initialPage,
  );
  addTearDown(session.dispose);
  return session;
}

FailureCode? failureCodeIn(ReaderViewState state) =>
    state is ReaderFailed ? state.failure.code : null;

void main() {
  group('ReaderSession [MOD-07, IC-03]', () {
    test('opens a complete copy at the requested page', () async {
      final ReaderSession session = sessionFor(
        'fx-iss-01',
        downloadsHolding(<String>['fx-iss-01']),
        FakePdfRenderer(pageCounts: <String, int>{'fx-iss-01': 12}),
        initialPage: 4,
      );
      expect(session.state, isA<ReaderOpening>());

      await session.open();

      final ReaderViewState state = session.state;
      expect(state, isA<ReaderReady>());
      state as ReaderReady;
      expect(state.document.pageCount, 12);
      expect(state.controller.currentPage, 4);
    });

    for (final String damaged in <String>['fx-pdf-10', 'fx-pdf-11']) {
      test('a damaged file (${damaged.toUpperCase()}) fails with fileCorrupt '
          'and a retry [FR-READ-010, AC-2.6]', () async {
        final ReaderSession session = sessionFor(
          damaged,
          downloadsHolding(<String>[damaged]),
          FakePdfRenderer(
            pageCounts: <String, int>{damaged: 4},
            damagedIssueIds: <String>{damaged},
          ),
        );

        await session.open();

        expect(failureCodeIn(session.state), FailureCode.fileCorrupt);
        expect((session.state as ReaderFailed).failure.retryable, isTrue);
      });
    }

    test('a copy that fails its check on the device is fileCorrupt', () async {
      final ReaderSession session = sessionFor(
        'fx-iss-01',
        downloadsHolding(
          <String>['fx-iss-01'],
          damagedCopies: <String>{'fx-iss-01'},
        ),
        FakePdfRenderer(pageCounts: <String, int>{'fx-iss-01': 12}),
      );

      await session.open();

      expect(failureCodeIn(session.state), FailureCode.fileCorrupt);
    });

    test('an issue with no copy on the device is notFound', () async {
      final ReaderSession session = sessionFor(
        'fx-iss-01',
        downloadsHolding(<String>[]),
        FakePdfRenderer(pageCounts: <String, int>{'fx-iss-01': 12}),
      );

      await session.open();

      expect(failureCodeIn(session.state), FailureCode.notFound);
    });

    test('a document with no pages is fileCorrupt', () async {
      final ReaderSession session = sessionFor(
        'fx-iss-01',
        downloadsHolding(<String>['fx-iss-01']),
        FakePdfRenderer(pageCounts: <String, int>{'fx-iss-01': 0}),
      );

      await session.open();

      expect(failureCodeIn(session.state), FailureCode.fileCorrupt);
    });

    test('retry opens again once the file can be read', () async {
      final FakePdfRenderer renderer = FakePdfRenderer(
        pageCounts: <String, int>{'fx-pdf-10': 4},
        damagedIssueIds: <String>{'fx-pdf-10'},
      );
      final ReaderSession session = sessionFor(
        'fx-pdf-10',
        downloadsHolding(<String>['fx-pdf-10']),
        renderer,
      );
      await session.open();
      expect(session.state, isA<ReaderFailed>());

      renderer.damagedIssueIds.clear();
      await session.retry();

      expect(session.state, isA<ReaderReady>());
    });

    test('dispose closes the open document', () async {
      final FakePdfRenderer renderer = FakePdfRenderer(
        pageCounts: <String, int>{'fx-iss-01': 12},
      );
      final ReaderSession session = ReaderSession(
        downloads: downloadsHolding(<String>['fx-iss-01']),
        renderer: renderer,
        issueId: 'fx-iss-01',
        mode: ReaderMode.pageTurn,
      );
      await session.open();

      session.dispose();
      await Future<void>.delayed(Duration.zero);

      expect(renderer.opened.single.closed, isTrue);
    });
  });
}
