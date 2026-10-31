// Preview of the news list and article over the fake WordPress site, for
// the simulator probe (P-SIM):
//   flutter run -t test/features/news/news_preview_main.dart
// Not a test, and not part of the app. No network call is made: the fake
// site answers in memory. The posts are built in code in the FX-WP shape,
// because the fixture files are not on the device.

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme.dart';
import 'package:mfw_app/features/news/news.dart';

import 'fake_wordpress_site.dart';
import 'labelled_news_image_source.dart';
import 'wp_fixtures.dart';

void main() {
  final Map<String, Object?> withScript = syntheticWpPost(
    126,
    dateGmt: DateTime.utc(2026, 3, 26, 9, 30),
  );
  withScript['title'] = <String, Object?>{
    'rendered':
        'Test post 126 &#8211; &#8216;Quoted&#8217; &#038; &#x20B9; prices, '
        'Café notes',
  };
  withScript['content'] = <String, Object?>{
    'rendered':
        '<p>Synthetic text before the script.</p>'
        '<script>document.title = "fx-wp-05-script-ran";</script>'
        '<style>p { color: red; }</style>'
        '<iframe src="https://video.example/embed/1">fx-wp-05-iframe</iframe>'
        '<p>Synthetic text after the script &amp; the embed.</p>',
  };
  final FakeWordPressSite site = FakeWordPressSite(
    posts: <Map<String, Object?>>[
      withScript,
      for (int id = 125; id > 113; id--)
        syntheticWpPost(id, categories: <int>[if (id.isOdd) 11 else 12]),
    ],
    categories: const <Map<String, Object?>>[
      <String, Object?>{'id': 11, 'name': 'Test News A'},
      <String, Object?>{'id': 12, 'name': 'Test News B &amp; Events'},
      <String, Object?>{'id': 13, 'name': 'Test News C'},
    ],
  );
  final WordPressNewsRepository news = WordPressNewsRepository(
    transport: site,
    site: WordPressSite(
      baseUrl: Uri.parse('https://wordpress.example/'),
      categoryIds: const <String>['11', '12', '13'],
    ),
  );
  runApp(
    MaterialApp(
      theme: placeholderTheme,
      home: Builder(
        builder: (BuildContext context) => NewsListScreen(
          news: news,
          images: const LabelledNewsImageSource(),
          onOpenPost: (String postId) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => NewsArticleScreen(
                news: news,
                images: const LabelledNewsImageSource(),
                postId: postId,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
