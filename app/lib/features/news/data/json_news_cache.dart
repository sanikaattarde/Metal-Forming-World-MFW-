import 'dart:convert';
import 'dart:io';

import '../../../contracts/news.dart';
import '../domain/news_cache.dart';

/// [NewsCacheStore] as a JSON file in the app's private folder, next to the
/// download records (MOD09-P2-T02). Written to a temporary file and
/// renamed, so a write cut short leaves the last whole record. A file that
/// cannot be read counts as empty, and so does a post in it that has lost
/// a field. The articles are public, so the file holds no personal data.
final class JsonNewsCache implements NewsCacheStore {
  /// Creates the store in the folder that [directory] gives.
  JsonNewsCache(this._directory);

  final Future<Directory> Function() _directory;
  NewsCacheRecord? _record;
  Future<void>? _writing;

  static const String _fileName = 'news_cache.json';

  Future<File> _file() async => File('${(await _directory()).path}/$_fileName');

  @override
  Future<NewsCacheRecord> load() async {
    final NewsCacheRecord? known = _record;
    if (known != null) {
      return known;
    }
    NewsCacheRecord record = const NewsCacheRecord();
    try {
      final File file = await _file();
      if (await file.exists()) {
        final Object? json = jsonDecode(await file.readAsString());
        if (json is Map) {
          final Object? lists = json['lists'];
          record = NewsCacheRecord(
            recent: _posts(json['recent']),
            saved: _posts(json['saved']),
            lists: lists is Map
                ? <String, List<NewsPost>>{
                    for (final MapEntry<Object?, Object?> entry
                        in lists.entries)
                      if (entry.key is String)
                        entry.key! as String: _posts(entry.value),
                  }
                : const <String, List<NewsPost>>{},
          );
        }
      }
    } on FormatException {
      // An unreadable file counts as empty.
    } on FileSystemException {
      // So does one that cannot be opened.
    }
    return _record = record;
  }

  @override
  Future<void> save(NewsCacheRecord record) {
    _record = record;
    final Future<void> next = (_writing ?? Future<void>.value()).then((
      _,
    ) async {
      final File file = await _file();
      final File temporary = File('${file.path}.tmp');
      await temporary.writeAsString(
        jsonEncode(<String, Object>{
          'recent': record.recent.map(newsPostToJson).toList(),
          'saved': record.saved.map(newsPostToJson).toList(),
          'lists': <String, Object>{
            for (final MapEntry<String, List<NewsPost>> entry
                in record.lists.entries)
              entry.key: entry.value.map(newsPostToJson).toList(),
          },
        }),
        flush: true,
      );
      await temporary.rename(file.path);
    });
    _writing = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }

  static List<NewsPost> _posts(Object? value) => value is List
      ? <NewsPost>[
          for (final Object? item in value) ?newsPostFromCacheJson(item),
        ]
      : <NewsPost>[];
}

/// [post] as the cache writes it.
Map<String, Object?> newsPostToJson(NewsPost post) => <String, Object?>{
  'id': post.postId,
  'title': post.title,
  'content': post.contentHtml,
  'published_at': post.publishedAt.toUtc().toIso8601String(),
  'categories': post.categoryIds,
  'link': post.link.toString(),
  'breaking': post.isBreaking,
  'image': post.imageUrl?.toString(),
};

/// A post the cache wrote, or null when a field is missing or wrong.
NewsPost? newsPostFromCacheJson(Object? json) {
  if (json is! Map) {
    return null;
  }
  final Object? id = json['id'];
  final Object? title = json['title'];
  final Object? content = json['content'];
  final Object? published = json['published_at'];
  final Object? categories = json['categories'];
  final Object? link = json['link'];
  final Object? image = json['image'];
  if (id is! String ||
      title is! String ||
      content is! String ||
      published is! String ||
      categories is! List ||
      link is! String) {
    return null;
  }
  final DateTime? date = DateTime.tryParse(published);
  final Uri? address = Uri.tryParse(link);
  if (date == null || address == null) {
    return null;
  }
  return NewsPost(
    postId: id,
    title: title,
    contentHtml: content,
    publishedAt: date.toUtc(),
    categoryIds: <String>[
      for (final Object? category in categories)
        ?(category is String ? category : null),
    ],
    link: address,
    isBreaking: json['breaking'] == true,
    imageUrl: image is String ? Uri.tryParse(image) : null,
  );
}
