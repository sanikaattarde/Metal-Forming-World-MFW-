import 'dart:convert';

import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/domain/html_text.dart';
import 'package:mfw_app/features/news/domain/news_ports.dart';

/// Reading WordPress REST JSON (API_AND_MODULE_CONTRACTS section 9.1),
/// as a tolerant reader (CODING_STANDARDS section 7): unknown fields are
/// ignored, and a missing or wrongly typed required field makes the value
/// unreadable (null).
abstract final class WordPressJson {
  /// The decoded [body], or null when it is not JSON (FX-WP-12).
  static Object? decode(String body) {
    try {
      return jsonDecode(body);
    } on FormatException {
      return null;
    }
  }

  /// A post: `id`, `date_gmt`, `link`, `title.rendered`,
  /// `content.rendered` and `categories` are required; the featured image
  /// comes from `_embedded`.
  ///
  /// The title has its tags removed and entities decoded. The content is
  /// kept as sent; the screen shows it through htmlToPlainText.
  /// TODO(yg): isBreaking comes from the news controls (T-08.4, OQ-17).
  static NewsPost? post(Object? json) => switch (json) {
    final Map<Object?, Object?> fields &&
        {
          'id': final int id,
          'date_gmt': final String dateGmt,
          'link': final String link,
          'title': {'rendered': final String title},
          'content': {'rendered': final String content},
          'categories': final List<Object?> categories,
        } =>
      _post(id, dateGmt, link, title, content, categories, fields['_embedded']),
    _ => null,
  };

  static NewsPost? _post(
    int id,
    String dateGmt,
    String link,
    String title,
    String content,
    List<Object?> categories,
    Object? embedded,
  ) {
    final DateTime? publishedAt = _gmt(dateGmt);
    final Uri? address = Uri.tryParse(link);
    if (publishedAt == null ||
        address == null ||
        !(address.isScheme('https') || address.isScheme('http')) ||
        categories.any((Object? category) => category is! int)) {
      return null;
    }
    return NewsPost(
      postId: '$id',
      title: decodeEntities(stripTags(title)).trim(),
      contentHtml: content,
      imageUrl: _featuredImage(embedded),
      publishedAt: publishedAt,
      categoryIds: <String>[
        for (final Object? category in categories) '$category',
      ],
      link: address,
      isBreaking: false,
    );
  }

  /// `date_gmt` has no offset; it is UTC.
  static DateTime? _gmt(String value) {
    final bool hasOffset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(value);
    return DateTime.tryParse(hasOffset ? value : '${value}Z')?.toUtc();
  }

  /// The first featured media's `source_url`, if it is https.
  static Uri? _featuredImage(Object? embedded) => switch (embedded) {
    {'wp:featuredmedia': [{'source_url': final String url}, ...]} =>
      switch (Uri.tryParse(url)) {
        final Uri image when image.isScheme('https') && image.host.isNotEmpty =>
          image,
        _ => null,
      },
    _ => null,
  };

  /// A category: `id` and `name` are required; the name is decoded.
  static NewsCategory? category(Object? json) => switch (json) {
    {'id': final int id, 'name': final String name} => NewsCategory(
      categoryId: '$id',
      name: decodeEntities(name).trim(),
    ),
    _ => null,
  };

  /// Every item read by [read], or null when one is unreadable or [json]
  /// is not a list.
  static List<T>? listOf<T>(Object? json, T? Function(Object? item) read) {
    if (json is! List<Object?>) {
      return null;
    }
    final List<T> items = <T>[];
    for (final Object? item in json) {
      final T? value = read(item);
      if (value == null) {
        return null;
      }
      items.add(value);
    }
    return items;
  }

  /// The WordPress error `code` in [body], if any.
  static String? errorCode(String body) => switch (decode(body)) {
    {'code': final String code} => code,
    _ => null,
  };

  /// The failure for a response that is not a success
  /// (API_AND_MODULE_CONTRACTS section 4.2; FX-WP-08 to FX-WP-10).
  ///
  /// PROPOSED: a blocked API (401, 403) and a wrong route (404
  /// `rest_no_route`) are `serviceUnavailable` without a retry, because
  /// retrying does not help; 429 and 5xx are `serviceUnavailable` with a
  /// retry; any other 404 is `notFound`; the rest are `invalidResponse`.
  static AppFailure failureFor(HttpResponse response) {
    final int status = response.statusCode;
    final String? code = errorCode(response.body);
    final String detail = 'wordpress $status${code == null ? '' : ' $code'}';
    return switch (status) {
      401 || 403 => AppFailure(FailureCode.serviceUnavailable, detail: detail),
      404 when code == 'rest_no_route' => AppFailure(
        FailureCode.serviceUnavailable,
        detail: detail,
      ),
      404 => AppFailure(FailureCode.notFound, detail: detail),
      429 || (>= 500 && < 600) => AppFailure(
        FailureCode.serviceUnavailable,
        retryable: true,
        detail: detail,
      ),
      _ => AppFailure(FailureCode.invalidResponse, detail: detail),
    };
  }
}
