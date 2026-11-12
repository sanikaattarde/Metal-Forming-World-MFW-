import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/sharing/sharing.dart';

import '../../fakes/fake_catalogue_repository.dart';
import '../../fakes/fake_news_repository.dart';

/// A share sheet that records what it was given and answers [outcome].
final class RecordingShareSheet implements ShareSheet {
  RecordingShareSheet({this.outcome = ShareSheetOutcome.shared});

  ShareSheetOutcome outcome;
  bool fails = false;
  final List<({String text, String? subject, Rect? origin})> shared =
      <({String text, String? subject, Rect? origin})>[];

  @override
  Future<ShareSheetOutcome> share({
    required String text,
    String? subject,
    Rect? origin,
  }) async {
    if (fails) {
      throw StateError('no sheet');
    }
    shared.add((text: text, subject: subject, origin: origin));
    return outcome;
  }
}

final StoreLinks _both = StoreLinks(
  android: Uri.parse('https://play.example.test/store/apps/details?id=x'),
  ios: Uri.parse('https://apps.example.test/app/id1'),
);

Future<IssueSummary> _issue() async {
  final Result<IssueSummary> issue =
      await FakeCatalogueRepository.fromFixtures().getIssue('fx-iss-01');
  return (issue as Ok<IssueSummary>).value;
}

void main() {
  group('the shared words [FR-SHR-001 to FR-SHR-005]', () {
    test(
      'an issue: its title and both store links [OQ-15 working position]',
      () async {
        final String text = ShareTexts.issue(await _issue(), _both)!;

        expect(text, startsWith('Test Issue 01\n'));
        expect(text, contains('Android: ${_both.android}'));
        expect(text, contains('iPhone and iPad: ${_both.ios}'));
        expect(text, isNot(contains('mfw://')));
      },
    );

    test('an issue with one listing names that one only', () async {
      final String text = ShareTexts.issue(
        await _issue(),
        StoreLinks(ios: _both.ios),
      )!;

      expect(text, isNot(contains('Android')));
      expect(text, contains('${_both.ios}'));
    });

    test('an issue before any listing has nothing to share', () async {
      expect(ShareTexts.issue(await _issue(), const StoreLinks()), isNull);
    });

    test('an article: its title and its website address', () {
      expect(
        ShareTexts.article(syntheticPost('9001')),
        'Synthetic post 9001\nhttps://news.example.test/synthetic-post-9001/',
      );
    });
  });

  group('AppShareService [MOD10-P1-T01, FR-SHR-006]', () {
    test(
      'shares text only, with the title as the subject and the origin',
      () async {
        final RecordingShareSheet sheet = RecordingShareSheet();
        const Rect origin = Rect.fromLTWH(10, 20, 48, 48);
        final ShareService service = AppShareService(
          sheet: sheet,
          links: _both,
          origin: origin,
        );

        expect(
          await service.shareArticle(syntheticPost('9001')),
          isA<Ok<void>>(),
        );
        expect(sheet.shared.single.subject, 'Synthetic post 9001');
        expect(sheet.shared.single.origin, origin);
        expect(sheet.shared.single.text, isNot(contains('.pdf')));
      },
    );

    test(
      'closing the sheet is cancelled; an unknown answer is success',
      () async {
        final RecordingShareSheet sheet = RecordingShareSheet(
          outcome: ShareSheetOutcome.dismissed,
        );
        final ShareService service = AppShareService(
          sheet: sheet,
          links: _both,
        );

        final Result<void> closed = await service.shareIssue(await _issue());
        expect((closed as Err<void>).failure.code, FailureCode.cancelled);

        sheet.outcome = ShareSheetOutcome.unknown;
        expect(await service.shareIssue(await _issue()), isA<Ok<void>>());
      },
    );

    test(
      'a sheet that cannot open, or an issue with no listing, is unknown',
      () async {
        final RecordingShareSheet sheet = RecordingShareSheet()..fails = true;
        final Result<void> broken = await AppShareService(
          sheet: sheet,
          links: _both,
        ).shareArticle(syntheticPost('1'));
        expect((broken as Err<void>).failure.code, FailureCode.unknown);

        sheet.fails = false;
        final Result<void> unlisted = await AppShareService(
          sheet: sheet,
          links: const StoreLinks(),
        ).shareIssue(await _issue());
        expect((unlisted as Err<void>).failure.code, FailureCode.unknown);
        expect(sheet.shared, isEmpty);
      },
    );
  });

  group('ShareButton', () {
    Future<void> pump(
      WidgetTester tester,
      Future<Result<void>> Function(Rect?) onShare,
    ) => tester.pumpWidget(
      MaterialApp(
        theme: buildMfwTheme(),
        home: Scaffold(
          appBar: AppBar(actions: <Widget>[ShareButton(onShare: onShare)]),
        ),
      ),
    );

    testWidgets('passes where it sits, and says nothing when closed', (
      WidgetTester tester,
    ) async {
      Rect? seen;
      await pump(tester, (Rect? origin) async {
        seen = origin;
        return const Err<void>(AppFailure(FailureCode.cancelled));
      });

      await tester.tap(find.byTooltip(ShareButton.label));
      await tester.pumpAndSettle();

      expect(seen, isNotNull);
      expect(seen!.size.width, greaterThan(0));
      expect(find.text(ShareButton.failed), findsNothing);
    });

    testWidgets('says so when the sheet cannot open', (
      WidgetTester tester,
    ) async {
      await pump(
        tester,
        (Rect? origin) async =>
            const Err<void>(AppFailure(FailureCode.unknown)),
      );

      await tester.tap(find.byTooltip(ShareButton.label));
      await tester.pumpAndSettle();

      expect(find.text(ShareButton.failed), findsOneWidget);
    });
  });
}
