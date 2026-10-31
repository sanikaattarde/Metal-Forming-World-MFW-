import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/domain/apply_query.dart';
import 'package:mfw_app/features/catalogue/domain/catalogue_reads.dart';
import 'package:mfw_app/features/catalogue/presentation/catalogue_failure_view.dart';
import 'package:mfw_app/features/catalogue/presentation/catalogue_text.dart';
import 'package:mfw_app/features/catalogue/presentation/issue_cover_source.dart';
import 'package:mfw_app/features/catalogue/presentation/issue_tile.dart';

/// The catalogue with search (SCR-A-11). Public: no sign-in needed
/// (RS FR-MAG-001, FR-SRCH-006).
///
/// Shows the latest issue, then the archive (FR-MAG-004). Text in the
/// search box lists only the matching issues (FR-SRCH-001). Loading, empty
/// and error states (FR-STATE-001 to FR-STATE-003).
///
/// Not built here: the filter controls, which wait for OQ-13 (applyQuery
/// already filters); pull-to-refresh (T-04.4); the offline catalogue
/// (OQ-10).
class CatalogueScreen extends StatefulWidget {
  /// Creates the screen.
  const CatalogueScreen({
    required this.catalogue,
    required this.covers,
    this.onOpenIssue,
    super.key,
  });

  /// MOD-05's source of published issues.
  final CatalogueRepository catalogue;

  /// Draws the covers.
  final IssueCoverSource covers;

  /// Opens an issue's details (SCR-A-12) by its ID.
  final void Function(String issueId)? onOpenIssue;

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  late Future<Result<CatalogueSnapshot>> _load = loadCatalogue(
    widget.catalogue,
  );
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _retry() {
    setState(() {
      _load = loadCatalogue(widget.catalogue);
    });
  }

  void _clearSearch() {
    setState(_search.clear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CatalogueText.title)),
      // Keeps clear of side insets; the list pads the bottom itself.
      body: SafeArea(
        top: false,
        bottom: false,
        child: FutureBuilder<Result<CatalogueSnapshot>>(
          future: _load,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<Result<CatalogueSnapshot>> snapshot,
              ) => switch (snapshot.connectionState == ConnectionState.done
              ? snapshot.data
              : null) {
                null => const Center(child: CircularProgressIndicator()),
                Err<CatalogueSnapshot>(:final AppFailure failure) =>
                  CatalogueFailureView(failure: failure, onRetry: _retry),
                Ok<CatalogueSnapshot>(:final CatalogueSnapshot value) =>
                  value.issues.isEmpty
                      ? const Center(child: Text(CatalogueText.empty))
                      : _loaded(value),
              },
        ),
      ),
    );
  }

  Widget _loaded(CatalogueSnapshot snapshot) {
    final String text = _search.text.trim();
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              labelText: CatalogueText.searchLabel,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: CatalogueText.clearSearch,
                      style: IconButton.styleFrom(
                        minimumSize: const Size.square(48),
                      ),
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
            onChanged: (String _) => setState(() {}),
          ),
        ),
        Expanded(
          child: text.isEmpty ? _sections(snapshot) : _results(snapshot, text),
        ),
      ],
    );
  }

  Widget _sections(CatalogueSnapshot snapshot) {
    final IssueSummary? latest = snapshot.latest;
    final List<IssueSummary> archive = snapshot.archive;
    return ListView(
      children: <Widget>[
        if (latest != null) ...<Widget>[
          const _Heading(CatalogueText.latest),
          _tile(snapshot, latest),
        ],
        if (archive.isNotEmpty) ...<Widget>[
          const _Heading(CatalogueText.archive),
          for (final IssueSummary issue in archive) _tile(snapshot, issue),
        ],
      ],
    );
  }

  Widget _results(CatalogueSnapshot snapshot, String text) {
    final List<IssueSummary> matches = applyQuery(
      snapshot.issues,
      IssueQuery(text: text),
      categoryNames: snapshot.categoryNames,
    );
    if (matches.isEmpty) {
      return const Center(child: Text(CatalogueText.noResults));
    }
    return ListView(
      children: <Widget>[
        for (final IssueSummary issue in matches) _tile(snapshot, issue),
      ],
    );
  }

  Widget _tile(CatalogueSnapshot snapshot, IssueSummary issue) {
    final void Function(String issueId)? open = widget.onOpenIssue;
    return IssueTile(
      issue: issue,
      categoryName: snapshot.categoryNames[issue.categoryId],
      covers: widget.covers,
      onTap: open == null ? null : () => open(issue.issueId),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Semantics(
        header: true,
        child: Text(label, style: Theme.of(context).textTheme.titleSmall),
      ),
    );
  }
}
