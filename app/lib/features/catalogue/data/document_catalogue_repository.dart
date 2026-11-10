import 'package:mfw_app/contracts/contracts.dart';

import '../domain/catalogue_documents.dart';
import '../domain/cover_urls.dart';
import '../domain/issue_search.dart';

/// MOD-05's [CatalogueRepository] over the catalogue documents
/// (MOD05-P2-T01).
///
/// - Only published issues are returned, newest first, and never a file
///   location: the issue's file revision and storage path are not read.
/// - The public fields follow the working position of OQ-13 (PROPOSED):
///   title, description, category, publication date, year, segments,
///   edition, cover and file size.
/// - An issue document that cannot be read as an issue is left out of the
///   list, so one bad record does not hide the catalogue; read on its own
///   it fails with `invalidResponse`.
/// - Failures: `network` (no connection, retryable), `timeout` (retryable),
///   `serviceUnavailable` (retryable), `notFound` (missing or unpublished),
///   `invalidResponse`.
final class DocumentCatalogueRepository
    implements CatalogueRepository, SegmentSource {
  /// Creates the repository over [documents], with covers from [covers].
  DocumentCatalogueRepository(this._documents, {required this.covers});

  final CatalogueDocuments _documents;

  /// Where covers are loaded from.
  final CoverUrls covers;

  @override
  Future<Result<List<IssueSummary>>> listPublishedIssues() => _guard(() async {
    final List<IssueSummary> issues = <IssueSummary>[
      for (final Map<String, Object?> document
          in await _documents.publishedIssues())
        ?issueFrom(document, covers),
    ]..sort(newestFirst);
    return Ok<List<IssueSummary>>(issues);
  });

  @override
  Future<Result<IssueSummary>> getIssue(String issueId) => _guard(() async {
    final Map<String, Object?>? document = await _documents.issue(issueId);
    if (document == null) {
      return const Err<IssueSummary>(
        AppFailure(FailureCode.notFound, detail: 'issue not published'),
      );
    }
    final IssueSummary? issue = issueFrom(document, covers);
    return issue == null
        ? const Err<IssueSummary>(
            AppFailure(FailureCode.invalidResponse, detail: 'issue shape'),
          )
        : Ok<IssueSummary>(issue);
  });

  @override
  Future<Result<List<IssueCategory>>> listCategories() => _guard(() async {
    final List<IssueCategory> categories = <IssueCategory>[
      for (final Map<String, Object?> document in await _documents.categories())
        if (_text(document[CatalogueDocuments.idKey]) case final String id)
          IssueCategory(categoryId: id, name: _text(document['name']) ?? id),
    ]..sort((IssueCategory a, IssueCategory b) => byName(a.name, b.name));
    return Ok<List<IssueCategory>>(categories);
  });

  @override
  Future<Result<List<IndustrySegment>>> listSegments() => _guard(() async {
    final List<IndustrySegment> segments = <IndustrySegment>[
      for (final Map<String, Object?> document in await _documents.segments())
        if (_text(document[CatalogueDocuments.idKey]) case final String id)
          IndustrySegment(segmentId: id, name: _text(document['name']) ?? id),
    ]..sort((IndustrySegment a, IndustrySegment b) => byName(a.name, b.name));
    return Ok<List<IndustrySegment>>(segments);
  });

  Future<Result<T>> _guard<T>(Future<Result<T>> Function() read) async {
    try {
      return await read();
    } on CatalogueReadError catch (error) {
      return Err<T>(failureFromRead(error.code));
    }
  }
}

/// The failure for a read that failed with the database's [code].
AppFailure failureFromRead(String code) {
  final String detail = 'catalogue read $code';
  return switch (code) {
    'unavailable' => AppFailure(
      FailureCode.network,
      retryable: true,
      detail: detail,
    ),
    'deadline-exceeded' => AppFailure(
      FailureCode.timeout,
      retryable: true,
      detail: detail,
    ),
    'permission-denied' ||
    'not-found' => AppFailure(FailureCode.notFound, detail: detail),
    'resource-exhausted' || 'internal' || 'aborted' => AppFailure(
      FailureCode.serviceUnavailable,
      retryable: true,
      detail: detail,
    ),
    _ => AppFailure(FailureCode.unknown, retryable: true, detail: detail),
  };
}

/// Names in alphabetical order, ignoring case.
int byName(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

/// Newest publication date first; the same date in title order.
int newestFirst(IssueSummary a, IssueSummary b) {
  final int byDate = b.publicationDate.compareTo(a.publicationDate);
  return byDate != 0 ? byDate : a.title.compareTo(b.title);
}

/// The issue in [document], or null when it is not a published issue with
/// the fields the app needs.
IssueSummary? issueFrom(Map<String, Object?> document, CoverUrls covers) {
  final String? id = _text(document[CatalogueDocuments.idKey]);
  final String? title = _text(document['title']);
  final String? categoryId = _text(document['category_id']);
  final DateTime? date = _calendarDate(document['publication_date']);
  if (document['publication_state'] != 'published' ||
      id == null ||
      title == null ||
      categoryId == null ||
      date == null) {
    return null;
  }
  final Object? year = document['year'];
  final Object? size = document['file_size_bytes'];
  final Object? segments = document['segment_ids'];
  return IssueSummary(
    issueId: id,
    title: title,
    description: switch (document['description']) {
      final String text => text,
      _ => '',
    },
    categoryId: categoryId,
    publicationDate: date,
    year: year is int && year > 0 ? year : date.year,
    industrySegmentIds: segments is List
        ? List<String>.unmodifiable(segments.whereType<String>())
        : const <String>[],
    edition: _text(document['edition']),
    coverImageUrl: covers.forPath(_text(document['cover_path'])),
    fileSizeBytes: size is int && size > 0 ? size : null,
  );
}

String? _text(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

final RegExp _isoDate = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

/// A `YYYY-MM-DD` publication date as midnight UTC, or null.
DateTime? _calendarDate(Object? value) {
  if (value is! String) {
    return null;
  }
  final RegExpMatch? match = _isoDate.firstMatch(value);
  if (match == null) {
    return null;
  }
  final int year = int.parse(match.group(1)!);
  final int month = int.parse(match.group(2)!);
  final int day = int.parse(match.group(3)!);
  final DateTime date = DateTime.utc(year, month, day);
  return date.month == month && date.day == day ? date : null;
}
