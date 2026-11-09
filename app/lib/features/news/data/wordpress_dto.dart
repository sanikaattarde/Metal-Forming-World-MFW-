import '../../../contracts/news.dart';
import 'html_entities.dart';

/// Thrown when a WordPress response does not have the expected shape. The
/// repository turns it into `invalidResponse`.
final class WordPressShapeError implements Exception {
  /// Creates the error; [field] names what was missing or wrong.
  const WordPressShapeError(this.field);

  /// The field that failed, for the log detail only.
  final String field;

  @override
  String toString() => 'WordPressShapeError($field)';
}

/// Maps one post of `/wp-json/wp/v2/posts` to [NewsPost]
/// (`API_AND_MODULE_CONTRACTS.md` section 9.1).
///
/// Tolerant reader (`CODING_STANDARDS.md` section 7): unknown fields are
/// ignored, and a missing or wrong required field throws
/// [WordPressShapeError]. The featured image is optional. News controls are
/// applied later (MOD09-P2-T03), so [NewsPost.isBreaking] is false here.
NewsPost newsPostFromJson(Object? json) {
  final Map<String, Object?> post = _map(json, 'post');
  final Object? id = post['id'];
  if (id is! int) {
    throw const WordPressShapeError('id');
  }
  return NewsPost(
    postId: '$id',
    title: decodeHtmlEntities(_rendered(post, 'title')),
    contentHtml: _rendered(post, 'content'),
    publishedAt: _gmt(post['date_gmt']),
    categoryIds: _categoryIds(post['categories']),
    link: _uri(post['link'], 'link'),
    isBreaking: false,
    imageUrl: _featuredImage(post['_embedded']),
  );
}

/// Maps one category of `/wp-json/wp/v2/categories` to [NewsCategory].
NewsCategory newsCategoryFromJson(Object? json) {
  final Map<String, Object?> category = _map(json, 'category');
  final Object? id = category['id'];
  final Object? name = category['name'];
  if (id is! int) {
    throw const WordPressShapeError('category id');
  }
  if (name is! String) {
    throw const WordPressShapeError('category name');
  }
  return NewsCategory(categoryId: '$id', name: decodeHtmlEntities(name));
}

/// The `code` of a WordPress error body, or null if the body has none.
String? wordPressErrorCode(Object? json) {
  if (json is Map<String, Object?>) {
    final Object? code = json['code'];
    if (code is String) {
      return code;
    }
  }
  return null;
}

Map<String, Object?> _map(Object? json, String field) {
  if (json is Map<String, Object?>) {
    return json;
  }
  throw WordPressShapeError(field);
}

String _rendered(Map<String, Object?> post, String field) {
  final Object? value = post[field];
  if (value is Map<String, Object?>) {
    final Object? rendered = value['rendered'];
    if (rendered is String) {
      return rendered;
    }
  }
  throw WordPressShapeError('$field.rendered');
}

/// `date_gmt` has no offset: it is UTC (WP-PV-10).
DateTime _gmt(Object? value) {
  if (value is String) {
    final bool hasZone = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(value);
    final DateTime? parsed = DateTime.tryParse(hasZone ? value : '${value}Z');
    if (parsed != null) {
      return parsed.toUtc();
    }
  }
  throw const WordPressShapeError('date_gmt');
}

List<String> _categoryIds(Object? value) {
  if (value is List<Object?> && value.every((Object? id) => id is int)) {
    return List<String>.unmodifiable(value.map((Object? id) => '$id'));
  }
  throw const WordPressShapeError('categories');
}

Uri _uri(Object? value, String field) {
  if (value is String) {
    final Uri? uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      return uri;
    }
  }
  throw WordPressShapeError(field);
}

/// The full-size address of the first featured media item, if any. A
/// missing, private or malformed item gives no image, not a failure.
Uri? _featuredImage(Object? embedded) {
  if (embedded is! Map<String, Object?>) {
    return null;
  }
  final Object? media = embedded['wp:featuredmedia'];
  if (media is! List<Object?> || media.isEmpty) {
    return null;
  }
  final Object? first = media.first;
  if (first is! Map<String, Object?>) {
    return null;
  }
  final Object? source = first['source_url'];
  if (source is! String) {
    return null;
  }
  final Uri? uri = Uri.tryParse(source);
  return uri != null && uri.isScheme('https') ? uri : null;
}
