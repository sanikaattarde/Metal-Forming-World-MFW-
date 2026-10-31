import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/domain/catalogue_reads.dart';
import 'package:mfw_app/features/catalogue/presentation/catalogue_failure_view.dart';
import 'package:mfw_app/features/catalogue/presentation/catalogue_text.dart';
import 'package:mfw_app/features/catalogue/presentation/issue_cover_source.dart';

/// Builds the read or download action for an issue (MOD-06 and the access
/// guard provide it).
typedef IssueActionBuilder = Widget Function(
  BuildContext context,
  IssueSummary issue,
);

/// Issue details (SCR-A-12): the issue's public metadata and the action to
/// read or download it (RS FR-MAG-005).
///
/// Shows the cover, title, publication date, category and description.
/// TODO(yg): edition, industry segment and file size wait for OQ-13, which
/// sets the public fields (FR-MAG-009). An unpublished issue is no longer
/// available (OP-CAT-02).
class IssueDetailsScreen extends StatefulWidget {
  /// Creates the screen for [issueId].
  const IssueDetailsScreen({
    required this.catalogue,
    required this.covers,
    required this.issueId,
    this.actionBuilder,
    super.key,
  });

  /// MOD-05's source of published issues.
  final CatalogueRepository catalogue;

  /// Draws the cover.
  final IssueCoverSource covers;

  /// The issue shown.
  final String issueId;

  /// The read or download action; none when null.
  final IssueActionBuilder? actionBuilder;

  @override
  State<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends State<IssueDetailsScreen> {
  late Future<Result<IssueDetails>> _load = loadIssueDetails(
    widget.catalogue,
    widget.issueId,
  );

  void _retry() {
    setState(() {
      _load = loadIssueDetails(widget.catalogue, widget.issueId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CatalogueText.details)),
      body: SafeArea(
        top: false,
        child: FutureBuilder<Result<IssueDetails>>(
          future: _load,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<Result<IssueDetails>> snapshot,
              ) => switch (snapshot.connectionState == ConnectionState.done
              ? snapshot.data
              : null) {
                null => const Center(child: CircularProgressIndicator()),
                Err<IssueDetails>(:final AppFailure failure) =>
                  CatalogueFailureView(failure: failure, onRetry: _retry),
                Ok<IssueDetails>(:final IssueDetails value) => _details(value),
              },
        ),
      ),
    );
  }

  Widget _details(IssueDetails details) {
    final TextTheme text = Theme.of(context).textTheme;
    final IssueSummary issue = details.issue;
    final String? category = details.categoryName;
    final IssueActionBuilder? action = widget.actionBuilder;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: SizedBox(
              width: 160,
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: ExcludeSemantics(
                  child: widget.covers.buildCover(context, issue),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(issue.title, style: text.headlineSmall),
          ),
          const SizedBox(height: 8),
          Text(CatalogueText.date(issue.publicationDate)),
          if (category != null) Text(category),
          const SizedBox(height: 16),
          Text(issue.description, style: text.bodyLarge),
          if (action != null) ...<Widget>[
            const SizedBox(height: 24),
            action(context, issue),
          ],
        ],
      ),
    );
  }
}
