import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../core/ui/content_widgets.dart';
import 'catalogue_text.dart';
import 'issue_row.dart';

/// The catalogue (SCR-A-11): every published issue, newest first, with its
/// cover, title, date, description and category (RS FR-MAG-001 to
/// FR-MAG-004). Open to everyone (FR-MAG-001).
class CatalogueScreen extends StatefulWidget {
  /// Creates the screen.
  const CatalogueScreen({
    required this.catalogue,
    required this.onOpenIssue,
    this.onBack,
    super.key,
  });

  /// MOD-05's catalogue.
  final CatalogueRepository catalogue;

  /// Opens SCR-A-12 for an issue.
  final ValueChanged<String> onOpenIssue;

  /// Goes back, when the screen was opened from another.
  final VoidCallback? onBack;

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  late Future<Result<CatalogueContent>> _content = loadCatalogue(
    widget.catalogue,
  );

  void _reload() {
    setState(() {
      _content = loadCatalogue(widget.catalogue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.onBack == null
            ? null
            : IconButton(
                tooltip: CatalogueText.back,
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
        title: const Text(CatalogueText.title),
      ),
      body: FutureBuilder<Result<CatalogueContent>>(
        future: _content,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<Result<CatalogueContent>> snapshot,
            ) => switch (snapshot.data) {
              null => const LoadingContent(label: CatalogueText.loading),
              Err<CatalogueContent>(:final AppFailure failure) => ListView(
                padding: const EdgeInsets.all(MfwSpace.lg),
                children: <Widget>[
                  ContentNotice(
                    CatalogueText.failure(failure),
                    kind: failure.code == FailureCode.network
                        ? NoticeKind.offline
                        : NoticeKind.error,
                    action: TextButton(
                      onPressed: _reload,
                      child: const Text(CatalogueText.retry),
                    ),
                  ),
                ],
              ),
              Ok<CatalogueContent>(:final CatalogueContent value) =>
                _CatalogueList(content: value, onOpen: widget.onOpenIssue),
            },
      ),
    );
  }
}

class _CatalogueList extends StatelessWidget {
  const _CatalogueList({required this.content, required this.onOpen});

  final CatalogueContent content;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (content.issues.isEmpty) {
      return ListView(
        children: const <Widget>[
          EmptyState(
            icon: Icons.menu_book_outlined,
            heading: CatalogueText.emptyHeading,
            text: CatalogueText.emptyText,
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        Text(
          CatalogueText.issueCount(content.issues.length),
          style: MfwType.small,
        ),
        const SizedBox(height: MfwSpace.sm),
        for (final IssueSummary issue in content.issues)
          IssueRow(
            key: ValueKey<String>(issue.issueId),
            issue: issue,
            categoryName: categoryNameOf(issue.categoryId, content.categories),
            onOpen: () => onOpen(issue.issueId),
          ),
      ],
    );
  }
}

/// The published issues and the categories, read together.
typedef CatalogueContent = ({
  List<IssueSummary> issues,
  List<IssueCategory> categories,
});

/// Reads the published issues and the categories from [catalogue] at once.
/// Fails when either read fails.
Future<Result<CatalogueContent>> loadCatalogue(
  CatalogueRepository catalogue,
) async {
  final (
    Result<List<IssueSummary>> issues,
    Result<List<IssueCategory>> categories,
  ) = await (
    catalogue.listPublishedIssues(),
    catalogue.listCategories(),
  ).wait;
  return switch ((issues, categories)) {
    (Err<List<IssueSummary>>(:final AppFailure failure), _) =>
      Err<CatalogueContent>(failure),
    (_, Err<List<IssueCategory>>(:final AppFailure failure)) =>
      Err<CatalogueContent>(failure),
    (
      Ok<List<IssueSummary>>(value: final List<IssueSummary> list),
      Ok<List<IssueCategory>>(value: final List<IssueCategory> names),
    ) =>
      Ok<CatalogueContent>((issues: list, categories: names)),
  };
}
