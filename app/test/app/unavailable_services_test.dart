import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/contracts/contracts.dart';

void expectUnavailable<T>(Result<T> result) {
  final AppFailure failure = (result as Err<T>).failure;
  expect(failure.code, FailureCode.serviceUnavailable);
  expect(failure.retryable, isFalse);
}

const LocalIssueFile _file = LocalIssueFile(
  issueId: 'fx-iss-01',
  fileRevision: 1,
  path: 'unused',
);

void main() {
  group('Placeholders until the real sources exist [MOD-01]', () {
    test('the catalogue fails every read with serviceUnavailable, without '
        'a retry [OP-CAT-01, OP-CAT-02, OP-CAT-03]', () async {
      const UnavailableCatalogueRepository catalogue =
          UnavailableCatalogueRepository();

      expectUnavailable(await catalogue.listPublishedIssues());
      expectUnavailable(await catalogue.getIssue('fx-iss-01'));
      expectUnavailable(await catalogue.listCategories());
    });

    test('downloads hold nothing: no status, no kept copy, no local file, '
        'and every action is unavailable [MOD-06]', () async {
      const UnavailableDownloadManager downloads = UnavailableDownloadManager();

      expect(await downloads.watch('fx-iss-01').toList(), <Matcher>[
        isA<NotDownloaded>(),
      ]);
      expect(await downloads.listDownloaded(), isEmpty);
      final AppFailure openFailure = (await downloads.openLocal(
        'fx-iss-01',
      ) as Err<LocalIssueFile>).failure;
      expect(openFailure.code, FailureCode.notFound);
      expectUnavailable(await downloads.prepare('fx-iss-01'));
      expectUnavailable(
        await downloads.start('fx-iss-01', mobileDataAccepted: false),
      );
      expectUnavailable(await downloads.cancel('fx-iss-01'));
      expectUnavailable(await downloads.delete('fx-iss-01'));
    });

    test('the renderer opens nothing until DEC-005 [MOD-07]', () async {
      const UnavailablePdfRenderer renderer = UnavailablePdfRenderer();

      expectUnavailable(await renderer.open(_file));
    });

    test('news fails every read with serviceUnavailable, without a retry '
        '[MOD-09, OQ-39]', () async {
      const UnavailableNewsRepository news = UnavailableNewsRepository();

      expectUnavailable(await news.listPosts());
      expectUnavailable(await news.getPost('101'));
      expectUnavailable(await news.listCategories());
    });
  });
}
