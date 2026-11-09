import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/core/config/wordpress_config.dart';

void main() {
  group('WordPressSiteConfig [CFG-03, CFG-04]', () {
    test('accepts an HTTPS site and a list of categories', () {
      final WordPressSiteConfig config = WordPressSiteConfig(
        siteUri: Uri.parse('https://news.example.test'),
        categoryIds: <String>['7', '11'],
      );

      expect(config.pageSize, 10, reason: 'small pages [INT-WP-004]');
      expect(() => config.categoryIds.add('1'), throwsUnsupportedError);
    });

    test('refuses a site that is not HTTPS [NFR-SEC-001]', () {
      expect(
        () => WordPressSiteConfig(
          siteUri: Uri.parse('http://news.example.test'),
          categoryIds: <String>['7'],
        ),
        throwsArgumentError,
      );
    });

    test('refuses no categories, and a page size WordPress refuses', () {
      final Uri site = Uri.parse('https://news.example.test');

      expect(
        () => WordPressSiteConfig(siteUri: site, categoryIds: <String>[]),
        throwsArgumentError,
      );
      expect(
        () => WordPressSiteConfig(
          siteUri: site,
          categoryIds: <String>['7'],
          pageSize: 101,
        ),
        throwsRangeError,
      );
    });
  });
}
