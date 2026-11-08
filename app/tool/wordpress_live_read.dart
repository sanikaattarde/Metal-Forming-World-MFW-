// A development read of MFW's public WordPress API with the app's client
// (MOD09-P1-T01 step 3, T-08.1). For development only.
//
// Run from app/ with:
//   dart run tool/wordpress_live_read.dart
//
// It prints counts, IDs, dates and yes or no answers, and never a title,
// an article or an image, so no content is copied or stored. The site and
// the categories are the working position of 8 November 2026
// (DEPLOYMENT_PLAN.md CFG-03 and CFG-04, both OPEN until OQ-39 is answered
// in writing), so this read is not the recorded live read that closes
// T-08.1.

import 'dart:io';

import 'package:mfw_app/contracts/news.dart';
import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/config/wordpress_config.dart';
import 'package:mfw_app/core/network/https_client.dart';
import 'package:mfw_app/features/news/news.dart';

Future<void> main() async {
  final WordPressSiteConfig config = WordPressSiteConfig(
    siteUri: Uri.parse('https://metalformingworld.com'),
    categoryIds: <String>['7', '11', '12', '13', '14', '15', '16', '17', '18'],
  );
  final IoHttpsGetClient client = IoHttpsGetClient();
  final WordPressNewsRepository news = WordPressNewsRepository(
    client: client,
    config: config,
  );
  final DateTime started = DateTime.now().toUtc();
  stdout.writeln('Read at ${started.toIso8601String()}');

  final Result<List<NewsCategory>> categories = await news.listCategories();
  switch (categories) {
    case Ok<List<NewsCategory>>(:final List<NewsCategory> value):
      stdout.writeln(
        'Categories: ${value.length}, IDs in order: '
        '${value.map((NewsCategory c) => c.categoryId).join(', ')}',
      );
    case Err<List<NewsCategory>>(:final AppFailure failure):
      stdout.writeln('Categories failed: ${failure.code} ${failure.detail}');
  }

  final Result<NewsPage> first = await news.listPosts();
  String? newestId;
  switch (first) {
    case Ok<NewsPage>(:final NewsPage value):
      final List<NewsPost> posts = value.posts;
      newestId = posts.isEmpty ? null : posts.first.postId;
      stdout.writeln(
        'First page: ${posts.length} posts, more pages: ${value.hasMore}, '
        'with an image: ${posts.where((NewsPost p) => p.imageUrl != null).length}',
      );
      if (posts.isNotEmpty) {
        stdout.writeln(
          'Dates: newest ${_day(posts.first.publishedAt)}, '
          'oldest on the page ${_day(posts.last.publishedAt)}; '
          'newest first: ${_newestFirst(posts)}',
        );
        stdout.writeln(
          'Category IDs on the page: '
          '${posts.expand((NewsPost p) => p.categoryIds).toSet().join(', ')}',
        );
        stdout.writeln(
          'Titles still holding an entity: '
          '${posts.where((NewsPost p) => p.title.contains(RegExp('&#?[a-zA-Z0-9]+;'))).length}',
        );
      }
    case Err<NewsPage>(:final AppFailure failure):
      stdout.writeln('First page failed: ${failure.code} ${failure.detail}');
  }

  for (final String id in <String>['11', '7']) {
    final Result<NewsPage> page = await news.listPosts(categoryId: id);
    switch (page) {
      case Ok<NewsPage>(:final NewsPage value):
        stdout.writeln('Category $id: ${value.posts.length} posts');
      case Err<NewsPage>(:final AppFailure failure):
        stdout.writeln('Category $id failed: ${failure.code}');
    }
  }

  final Result<NewsPage> beyond = await news.listPosts(page: 99);
  switch (beyond) {
    case Ok<NewsPage>(:final NewsPage value):
      stdout.writeln(
        'Page 99: ${value.posts.length} posts, more: ${value.hasMore}',
      );
    case Err<NewsPage>(:final AppFailure failure):
      stdout.writeln('Page 99 failed: ${failure.code} ${failure.detail}');
  }

  if (newestId != null) {
    final Result<NewsPost> post = await news.getPost(newestId);
    switch (post) {
      case Ok<NewsPost>(:final NewsPost value):
        final String html = value.contentHtml;
        stdout.writeln(
          'Newest post $newestId: body ${html.length} characters, '
          'script element: ${html.contains('<script')}, '
          'iframe element: ${html.contains('<iframe')}, '
          'image: ${value.imageUrl != null}',
        );
      case Err<NewsPost>(:final AppFailure failure):
        stdout.writeln('Post $newestId failed: ${failure.code}');
    }
  }

  final Result<NewsPost> missing = await news.getPost('999999999');
  if (missing case Err<NewsPost>(:final AppFailure failure)) {
    stdout.writeln('Unknown post: ${failure.code}');
  }
  client.close();
}

String _day(DateTime time) => time.toIso8601String().substring(0, 10);

bool _newestFirst(List<NewsPost> posts) {
  for (int i = 1; i < posts.length; i++) {
    if (posts[i].publishedAt.isAfter(posts[i - 1].publishedAt)) {
      return false;
    }
  }
  return true;
}
