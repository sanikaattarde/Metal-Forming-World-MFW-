import 'package:flutter/widgets.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/reader/reader.dart';

const AppFailure _unavailable = AppFailure(FailureCode.serviceUnavailable);

/// PLACEHOLDER until the catalogue reads exist (OP-CAT-01 to OP-CAT-03,
/// WS-A). Every read fails with `serviceUnavailable`, without a retry.
final class UnavailableCatalogueRepository implements CatalogueRepository {
  /// Creates the placeholder.
  const UnavailableCatalogueRepository();

  @override
  Future<Result<List<IssueSummary>>> listPublishedIssues() async =>
      const Err<List<IssueSummary>>(_unavailable);

  @override
  Future<Result<IssueSummary>> getIssue(String issueId) async =>
      const Err<IssueSummary>(_unavailable);

  @override
  Future<Result<List<IssueCategory>>> listCategories() async =>
      const Err<List<IssueCategory>>(_unavailable);
}

/// PLACEHOLDER until MOD-06 has its device ports (file store, transfer)
/// and the issue file grant (IssueFileService, WS-A).
///
/// The device holds nothing: no copy is downloaded or kept, so `openLocal`
/// fails with `notFound`, as the contract allows, and every action fails
/// with `serviceUnavailable`.
final class UnavailableDownloadManager implements DownloadManager {
  /// Creates the placeholder.
  const UnavailableDownloadManager();

  @override
  Stream<DownloadStatus> watch(String issueId) =>
      Stream<DownloadStatus>.value(const NotDownloaded());

  @override
  Future<Result<DownloadPlan>> prepare(String issueId) async =>
      const Err<DownloadPlan>(_unavailable);

  @override
  Future<Result<void>> start(
    String issueId, {
    required bool mobileDataAccepted,
  }) async => const Err<void>(_unavailable);

  @override
  Future<Result<void>> cancel(String issueId) async =>
      const Err<void>(_unavailable);

  @override
  Future<Result<void>> delete(String issueId) async =>
      const Err<void>(_unavailable);

  @override
  Future<List<DownloadedIssue>> listDownloaded() async =>
      const <DownloadedIssue>[];

  @override
  Future<Result<LocalIssueFile>> openLocal(String issueId) async =>
      const Err<LocalIssueFile>(AppFailure(FailureCode.notFound));
}

/// PLACEHOLDER until the reader library is chosen (DEC-005, WB-05).
final class UnavailablePdfRenderer implements PdfRenderer {
  /// Creates the placeholder.
  const UnavailablePdfRenderer();

  @override
  Future<Result<PdfDocumentHandle>> open(LocalIssueFile file) async =>
      const Err<PdfDocumentHandle>(_unavailable);
}

/// PLACEHOLDER page source for [UnavailablePdfRenderer], which opens no
/// document, so no page is ever built.
final class UnavailablePageSource implements ReaderPageSource {
  /// Creates the placeholder.
  const UnavailablePageSource();

  @override
  Widget buildPage(
    BuildContext context,
    PdfDocumentHandle document,
    int page,
  ) => const SizedBox.shrink();
}

/// PLACEHOLDER until the app has a WordPress transport and MFW's site
/// address (OQ-39). Every read fails with `serviceUnavailable`, without a
/// retry.
final class UnavailableNewsRepository implements NewsRepository {
  /// Creates the placeholder.
  const UnavailableNewsRepository();

  @override
  Future<Result<NewsPage>> listPosts({
    String? categoryId,
    int page = 1,
  }) async => const Err<NewsPage>(_unavailable);

  @override
  Future<Result<NewsPost>> getPost(String postId) async =>
      const Err<NewsPost>(_unavailable);

  @override
  Future<Result<List<NewsCategory>>> listCategories() async =>
      const Err<List<NewsCategory>>(_unavailable);
}
