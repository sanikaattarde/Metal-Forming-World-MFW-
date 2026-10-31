import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

void main() {
  group('NewsText', () {
    test('a date reads as day, month name and year', () {
      expect(NewsText.date(DateTime(2026, 3, 25, 15)), '25 March 2026');
      expect(NewsText.date(DateTime(2026, 12, 1)), '1 December 2026');
    });

    test('failures map to messages [FR-STATE-003, FR-STATE-005]', () {
      expect(
        NewsText.failure(const AppFailure(FailureCode.network)),
        NewsText.offline,
      );
      expect(
        NewsText.failure(const AppFailure(FailureCode.notFound)),
        NewsText.notAvailable,
      );
      for (final FailureCode code in <FailureCode>[
        FailureCode.timeout,
        FailureCode.serviceUnavailable,
        FailureCode.invalidResponse,
        FailureCode.unknown,
      ]) {
        expect(
          NewsText.failure(AppFailure(code)),
          NewsText.unreachable,
          reason: code.name,
        );
      }
    });
  });

  group('NetworkNewsImageSource [FR-NEWS-001]', () {
    NewsPost postWithImage(String? url) => NewsPost(
      postId: '1',
      title: 'Title',
      contentHtml: '<p>Body</p>',
      publishedAt: DateTime.utc(2026, 3, 1, 9, 30),
      categoryIds: const <String>['11'],
      link: Uri.parse('https://wordpress.example/news/1/'),
      isBreaking: false,
      imageUrl: url == null ? null : Uri.parse(url),
    );

    Future<void> pumpImage(WidgetTester tester, NewsPost post) =>
        tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (BuildContext context) => SizedBox(
                width: 88,
                height: 66,
                child: const NetworkNewsImageSource().buildImage(context, post),
              ),
            ),
          ),
        );

    testWidgets('a post without an image shows the placeholder', (
      WidgetTester tester,
    ) async {
      await pumpImage(tester, postWithImage(null));

      expect(find.byType(NewsImagePlaceholder), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('an image address that is not https is never loaded', (
      WidgetTester tester,
    ) async {
      await pumpImage(
        tester,
        postWithImage('http://wordpress.example/img/1.jpg'),
      );

      expect(find.byType(NewsImagePlaceholder), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });
  });
}
