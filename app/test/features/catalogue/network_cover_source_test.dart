import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

IssueSummary issueWithCover(String? url) => IssueSummary(
  issueId: 'a',
  title: 'Title a',
  description: 'Description a',
  categoryId: 'fx-cat-01',
  publicationDate: DateTime.utc(2026, 3, 1),
  year: 2026,
  coverImageUrl: url == null ? null : Uri.parse(url),
);

Future<void> pumpCover(WidgetTester tester, IssueSummary issue) =>
    tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) => SizedBox(
            width: 64,
            height: 85,
            child: const NetworkCoverSource().buildCover(context, issue),
          ),
        ),
      ),
    );

void main() {
  group('NetworkCoverSource [FR-MAG-002]', () {
    testWidgets('an issue without a cover shows the placeholder', (
      WidgetTester tester,
    ) async {
      await pumpCover(tester, issueWithCover(null));

      expect(find.byType(CoverPlaceholder), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('a cover address that is not https is never loaded', (
      WidgetTester tester,
    ) async {
      await pumpCover(
        tester,
        issueWithCover('http://storage.example/covers/a.jpg'),
      );

      expect(find.byType(CoverPlaceholder), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
