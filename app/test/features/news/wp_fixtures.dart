import 'dart:convert';

import 'package:mfw_app/features/news/news.dart';

import '../../fakes/fixture_loader.dart';

/// One recorded WordPress response from test/fixtures/wordpress/.
final class WpFixture {
  /// Creates a fixture response.
  const WpFixture({
    required this.fixtureId,
    required this.status,
    required this.headers,
    required this.body,
    this.delay = Duration.zero,
  });

  /// Reads `test/fixtures/wordpress/[fileName]`.
  factory WpFixture.load(String fileName) {
    final Map<String, Object?> json =
        readJsonFixture('wordpress/$fileName') as Map<String, Object?>;
    return WpFixture(
      fixtureId: json['fixtureId'] as String,
      status: json['status'] as int,
      headers: (json['headers'] as Map<String, Object?>).map(
        (String name, Object? value) =>
            MapEntry<String, String>(name, value as String),
      ),
      body: switch (json['rawBody']) {
        final String raw => raw,
        _ => jsonEncode(json['body']),
      },
      delay: Duration(milliseconds: (json['delayMs'] as int?) ?? 0),
    );
  }

  /// FX-WP ID.
  final String fixtureId;

  /// HTTP status.
  final int status;

  /// Response headers as recorded.
  final Map<String, String> headers;

  /// Response body as sent.
  final String body;

  /// Wait before the response (FX-WP-11).
  final Duration delay;

  /// The fixture as a transport response.
  HttpResponse get response =>
      HttpResponse(statusCode: status, headers: headers, body: body);

  /// The decoded JSON body.
  Object? get json => jsonDecode(body);
}

/// The post objects in a list fixture.
List<Map<String, Object?>> wpPostsIn(String fileName) =>
    (WpFixture.load(fileName).json! as List<Object?>)
        .cast<Map<String, Object?>>();

/// The post object in a single-post fixture.
Map<String, Object?> wpPostIn(String fileName) =>
    WpFixture.load(fileName).json! as Map<String, Object?>;

/// A synthetic post in the FX-WP shape, for page 2 of the site, which has
/// no fixture file.
Map<String, Object?> syntheticWpPost(
  int id, {
  List<int> categories = const <int>[11],
  DateTime? dateGmt,
}) {
  final DateTime date = dateGmt ?? DateTime.utc(2026, 3, id - 100, 9, 30);
  final String gmt = date.toIso8601String().substring(0, 19);
  return <String, Object?>{
    'id': id,
    'date_gmt': gmt,
    'link': 'https://wordpress.example/news/test-post-$id/',
    'title': <String, Object?>{'rendered': 'Test post $id'},
    'content': <String, Object?>{
      'rendered': '<p>Synthetic body text for post $id.</p>',
    },
    'categories': categories,
    '_embedded': <String, Object?>{
      'wp:featuredmedia': <Object?>[
        <String, Object?>{
          'source_url': 'https://wordpress.example/img/$id.jpg',
        },
      ],
    },
  };
}
