import 'package:mfw_app/features/catalogue/catalogue.dart';

/// In-memory catalogue documents, shaped as the database holds them
/// (`DATABASE_AND_DATA_MODEL.md` section 12). Unpublished issues are kept
/// but, as under the access rules, never returned.
final class FakeCatalogueDocuments implements CatalogueDocuments {
  /// Creates the store.
  FakeCatalogueDocuments({
    Map<String, Map<String, Object?>>? issues,
    Map<String, Map<String, Object?>>? categories,
    Map<String, Map<String, Object?>>? segments,
  }) : issues = issues ?? <String, Map<String, Object?>>{},
       categoriesById = categories ?? <String, Map<String, Object?>>{},
       segmentsById = segments ?? <String, Map<String, Object?>>{};

  /// Issue documents by identifier.
  final Map<String, Map<String, Object?>> issues;

  /// Category documents by identifier.
  final Map<String, Map<String, Object?>> categoriesById;

  /// Segment documents by identifier.
  final Map<String, Map<String, Object?>> segmentsById;

  /// When set, every read throws it.
  CatalogueReadError? error;

  /// How many reads were made.
  int reads = 0;

  /// What [lastReadFromCache] answers, as for a device that is offline.
  bool fromCache = false;

  @override
  bool get lastReadFromCache => fromCache;

  Map<String, Object?> _withId(String id, Map<String, Object?> data) =>
      <String, Object?>{...data, CatalogueDocuments.idKey: id};

  void _check() {
    reads++;
    final CatalogueReadError? set = error;
    if (set != null) {
      throw set;
    }
  }

  @override
  Future<List<Map<String, Object?>>> publishedIssues() async {
    _check();
    return <Map<String, Object?>>[
      for (final MapEntry<String, Map<String, Object?>> entry in issues.entries)
        if (entry.value['publication_state'] == 'published')
          _withId(entry.key, entry.value),
    ];
  }

  @override
  Future<Map<String, Object?>?> issue(String issueId) async {
    _check();
    final Map<String, Object?>? data = issues[issueId];
    return data == null || data['publication_state'] != 'published'
        ? null
        : _withId(issueId, data);
  }

  @override
  Future<List<Map<String, Object?>>> categories() async {
    _check();
    return <Map<String, Object?>>[
      for (final MapEntry<String, Map<String, Object?>> entry
          in categoriesById.entries)
        _withId(entry.key, entry.value),
    ];
  }

  @override
  Future<List<Map<String, Object?>>> segments() async {
    _check();
    return <Map<String, Object?>>[
      for (final MapEntry<String, Map<String, Object?>> entry
          in segmentsById.entries)
        _withId(entry.key, entry.value),
    ];
  }
}

/// A published issue document with every public field set, synthetic.
Map<String, Object?> issueDocument({
  String title = 'Test Issue',
  String date = '2026-10-01',
  String categoryId = 'fx-cat-01',
  String state = 'published',
  Object? year = 2026,
  List<String> segments = const <String>['fx-seg-01'],
  String? edition = 'E1',
  String? coverPath,
  Object? sizeBytes = 800000,
}) => <String, Object?>{
  'title': title,
  'description': 'Synthetic description.',
  'category_id': categoryId,
  'publication_date': date,
  'year': year,
  'segment_ids': segments,
  'edition': ?edition,
  'cover_path': ?coverPath,
  'file_size_bytes': sizeBytes,
  'publication_state': state,
  'current_revision': 1,
};
