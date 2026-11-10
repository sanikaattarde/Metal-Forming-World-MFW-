import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_documents.dart';

void main() {
  const CoverUrls covers = CoverUrls(bucket: 'demo-mfw.appspot.com');

  late FakeCatalogueDocuments documents;
  late DocumentCatalogueRepository repository;

  setUp(() {
    documents = FakeCatalogueDocuments(
      issues: <String, Map<String, Object?>>{
        'old': issueDocument(title: 'Old', date: '2025-03-01', year: 2025),
        'new': issueDocument(
          title: 'New',
          date: '2026-10-01',
          coverPath: 'covers/new/1',
        ),
        'hidden': issueDocument(title: 'Hidden', state: 'unpublished'),
      },
      categories: <String, Map<String, Object?>>{
        'fx-cat-02': <String, Object?>{'name': 'Test Category B'},
        'fx-cat-01': <String, Object?>{'name': 'Test Category A'},
      },
    );
    repository = DocumentCatalogueRepository(documents, covers: covers);
  });

  group('listPublishedIssues [FR-MAG-001, FR-MAG-002]', () {
    test('lists published issues only, newest first', () async {
      final List<IssueSummary> issues =
          (await repository.listPublishedIssues() as Ok<List<IssueSummary>>)
              .value;
      expect(issues.map((IssueSummary i) => i.issueId), <String>['new', 'old']);
    });

    test('reads every public field of the OQ-13 working position', () async {
      final IssueSummary issue =
          (await repository.listPublishedIssues() as Ok<List<IssueSummary>>)
              .value
              .first;
      expect(issue.title, 'New');
      expect(issue.description, 'Synthetic description.');
      expect(issue.categoryId, 'fx-cat-01');
      expect(issue.publicationDate, DateTime.utc(2026, 10, 1));
      expect(issue.year, 2026);
      expect(issue.industrySegmentIds, <String>['fx-seg-01']);
      expect(issue.edition, 'E1');
      expect(issue.fileSizeBytes, 800000);
      expect(
        issue.coverImageUrl.toString(),
        'https://firebasestorage.googleapis.com/v0/b/demo-mfw.appspot.com/o/'
        'covers%2Fnew%2F1?alt=media',
      );
    });

    test('leaves out a document that is not a usable issue', () async {
      documents.issues['no-title'] = issueDocument()..remove('title');
      documents.issues['bad-date'] = issueDocument(date: '2026-02-30');
      documents.issues['bad-state'] = issueDocument()
        ..['publication_state'] = 'draft';
      final List<IssueSummary> issues =
          (await repository.listPublishedIssues() as Ok<List<IssueSummary>>)
              .value;
      expect(issues.map((IssueSummary i) => i.issueId), <String>['new', 'old']);
    });

    test('takes the year from the date when the year is missing', () async {
      documents.issues['no-year'] = issueDocument(
        date: '2024-05-06',
        year: null,
        sizeBytes: null,
        edition: null,
      );
      final IssueSummary issue =
          (await repository.getIssue('no-year') as Ok<IssueSummary>).value;
      expect(issue.year, 2024);
      expect(issue.fileSizeBytes, isNull);
      expect(issue.edition, isNull);
      expect(issue.coverImageUrl, isNull);
    });

    test('a lost connection is a retryable network failure', () async {
      documents.error = const CatalogueReadError('unavailable');
      final AppFailure failure =
          (await repository.listPublishedIssues() as Err<List<IssueSummary>>)
              .failure;
      expect(failure.code, FailureCode.network);
      expect(failure.retryable, isTrue);
    });
  });

  group('getIssue [FR-MAG-005]', () {
    test('returns a published issue', () async {
      final Result<IssueSummary> result = await repository.getIssue('old');
      expect((result as Ok<IssueSummary>).value.title, 'Old');
    });

    test('an unpublished issue is notFound [FR-MAG-008]', () async {
      final Result<IssueSummary> result = await repository.getIssue('hidden');
      expect((result as Err<IssueSummary>).failure.code, FailureCode.notFound);
    });

    test('a missing issue is notFound', () async {
      final Result<IssueSummary> result = await repository.getIssue('none');
      expect((result as Err<IssueSummary>).failure.code, FailureCode.notFound);
    });

    test('a broken issue document is invalidResponse', () async {
      documents.issues['broken'] = issueDocument()..remove('category_id');
      final Result<IssueSummary> result = await repository.getIssue('broken');
      expect(
        (result as Err<IssueSummary>).failure.code,
        FailureCode.invalidResponse,
      );
    });
  });

  group('listCategories [FR-MAG-003]', () {
    test('lists categories by name', () async {
      final List<IssueCategory> categories =
          (await repository.listCategories() as Ok<List<IssueCategory>>).value;
      expect(categories.map((IssueCategory c) => c.name), <String>[
        'Test Category A',
        'Test Category B',
      ]);
    });
  });

  group('failureFromRead', () {
    for (final (String code, FailureCode expected, bool retryable)
        in <(String, FailureCode, bool)>[
          ('unavailable', FailureCode.network, true),
          ('deadline-exceeded', FailureCode.timeout, true),
          ('permission-denied', FailureCode.notFound, false),
          ('resource-exhausted', FailureCode.serviceUnavailable, true),
          ('something-else', FailureCode.unknown, true),
        ]) {
      test('$code is ${expected.name}', () {
        final AppFailure failure = failureFromRead(code);
        expect(failure.code, expected);
        expect(failure.retryable, retryable);
        expect(failure.detail, 'catalogue read $code');
      });
    }
  });

  group('CoverUrls', () {
    test('gives no address outside covers/', () {
      expect(covers.forPath('issues/x/files/1/file.pdf'), isNull);
      expect(covers.forPath('covers/../issues/x'), isNull);
      expect(covers.forPath(null), isNull);
    });

    test('uses the emulator over HTTP in ENV-LOCAL', () {
      const CoverUrls local = CoverUrls.emulator(
        bucket: 'demo-mfw.appspot.com',
        host: '10.0.2.2',
      );
      expect(
        local.forPath('covers/a/1').toString(),
        'http://10.0.2.2:9199/v0/b/demo-mfw.appspot.com/o/covers%2Fa%2F1'
        '?alt=media',
      );
    });
  });
}
