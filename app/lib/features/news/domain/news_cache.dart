import '../../../contracts/news.dart';

/// What the device keeps of the news (MOD09-P2-T02, RS FR-NEWS-005,
/// FR-NEWS-006, OQ-16 working position).
final class NewsCacheRecord {
  /// Creates the record.
  const NewsCacheRecord({
    this.recent = const <NewsPost>[],
    this.saved = const <NewsPost>[],
    this.lists = const <String, List<NewsPost>>{},
  });

  /// Articles opened lately, newest first; the oldest rotate out.
  final List<NewsPost> recent;

  /// Articles the reader saved, newest first, kept until removed.
  final List<NewsPost> saved;

  /// The first page of each list, by [allKey] or category ID.
  final Map<String, List<NewsPost>> lists;

  /// The key of the list with every selected category.
  static const String allKey = '*';

  /// This record with the given parts replaced.
  NewsCacheRecord copyWith({
    List<NewsPost>? recent,
    List<NewsPost>? saved,
    Map<String, List<NewsPost>>? lists,
  }) => NewsCacheRecord(
    recent: recent ?? this.recent,
    saved: saved ?? this.saved,
    lists: lists ?? this.lists,
  );
}

/// Where the device keeps [NewsCacheRecord] (a port; the adapter is a JSON
/// file in the app's private folder).
abstract interface class NewsCacheStore {
  /// The record, or an empty one when nothing is kept or it cannot be read.
  Future<NewsCacheRecord> load();

  /// Replaces the record.
  Future<void> save(NewsCacheRecord record);
}

/// The reader's saved articles (FR-NEWS-006). Saving needs no account: the
/// articles are public and stay on this device.
abstract interface class SavedArticles {
  /// Whether [postId] is saved.
  Future<bool> isSaved(String postId);

  /// Keeps [post] for reading offline until it is removed.
  Future<void> save(NewsPost post);

  /// Removes [postId] from the saved articles.
  Future<void> remove(String postId);

  /// The saved articles, newest saved first.
  Future<List<NewsPost>> saved();
}
