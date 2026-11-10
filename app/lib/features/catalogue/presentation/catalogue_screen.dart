import 'package:flutter/material.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../core/ui/content_widgets.dart';
import '../../../core/ui/reloadable.dart';
import '../domain/issue_search.dart';
import 'catalogue_text.dart';
import 'issue_row.dart';

/// The catalogue (SCR-A-11): every published issue, newest first, with its
/// cover, title, date, description and category (RS FR-MAG-001 to
/// FR-MAG-004), and search and filters on that metadata (FR-SRCH-001 to
/// FR-SRCH-007). Open to everyone (FR-MAG-001, FR-SRCH-006).
class CatalogueScreen extends StatefulWidget {
  /// Creates the screen.
  const CatalogueScreen({
    required this.catalogue,
    required this.onOpenIssue,
    this.segments,
    this.onBack,
    super.key,
  });

  /// MOD-05's catalogue.
  final CatalogueRepository catalogue;

  /// The segment names; without them the segment filter shows identifiers.
  final SegmentSource? segments;

  /// Opens SCR-A-12 for an issue.
  final ValueChanged<String> onOpenIssue;

  /// Goes back, when the screen was opened from another.
  final VoidCallback? onBack;

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen>
    with Reloadable<CatalogueScreen, CatalogueContent> {
  final TextEditingController _search = TextEditingController();
  IssueQuery _query = const IssueQuery();

  @override
  Future<Result<CatalogueContent>> fetch() =>
      loadCatalogue(widget.catalogue, segments: widget.segments);

  void _setQuery(IssueQuery query) {
    setState(() {
      _query = query;
    });
  }

  void _clear() {
    _search.clear();
    _setQuery(const IssueQuery());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
      body: switch (result) {
        null => const LoadingContent(label: CatalogueText.loading),
        Err<CatalogueContent>(:final AppFailure failure) => RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(MfwSpace.lg),
            children: <Widget>[
              ContentNotice(
                CatalogueText.failure(failure),
                kind: failure.code == FailureCode.network
                    ? NoticeKind.offline
                    : NoticeKind.error,
                action: TextButton(
                  onPressed: retry,
                  child: const Text(CatalogueText.retry),
                ),
              ),
            ],
          ),
        ),
        Ok<CatalogueContent>(:final CatalogueContent value) => RefreshIndicator(
          onRefresh: refresh,
          child: _CatalogueList(
            content: value,
            search: _search,
            query: _query,
            onQuery: _setQuery,
            onClear: _clear,
            onOpen: widget.onOpenIssue,
          ),
        ),
      },
    );
  }
}

class _CatalogueList extends StatelessWidget {
  const _CatalogueList({
    required this.content,
    required this.search,
    required this.query,
    required this.onQuery,
    required this.onClear,
    required this.onOpen,
  });

  final CatalogueContent content;
  final TextEditingController search;
  final IssueQuery query;
  final ValueChanged<IssueQuery> onQuery;
  final VoidCallback onClear;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (content.issues.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const <Widget>[
          EmptyState(
            icon: Icons.menu_book_outlined,
            heading: CatalogueText.emptyHeading,
            text: CatalogueText.emptyText,
          ),
        ],
      );
    }
    final Map<String, String> categoryNames = <String, String>{
      for (final IssueCategory category in content.categories)
        category.categoryId: category.name,
    };
    final List<IssueSummary> shown = applyQuery(
      content.issues,
      query,
      categoryNames: categoryNames,
    );
    final bool filtering = _isFiltering(query);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        _SearchField(
          controller: search,
          onChanged: (String text) => onQuery(_withText(query, text)),
        ),
        const SizedBox(height: MfwSpace.md),
        _FilterBar(
          choices: FilterChoices.of(content.issues),
          query: query,
          categoryNames: categoryNames,
          segmentNames: content.segmentNames,
          onQuery: onQuery,
        ),
        const SizedBox(height: MfwSpace.md),
        if (shown.isEmpty)
          EmptyState(
            icon: Icons.search_off,
            heading: CatalogueText.noMatchHeading,
            text: CatalogueText.noMatchText,
            action: OutlinedButton(
              onPressed: onClear,
              child: const Text(CatalogueText.clearFilters),
            ),
          )
        else ...<Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    CatalogueText.issueCount(shown.length),
                    style: MfwType.small,
                  ),
                ),
              ),
              if (filtering)
                TextButton(
                  onPressed: onClear,
                  child: const Text(CatalogueText.clearFilters),
                ),
            ],
          ),
          const SizedBox(height: MfwSpace.sm),
          for (final IssueSummary issue in shown)
            IssueRow(
              key: ValueKey<String>(issue.issueId),
              issue: issue,
              categoryName: categoryNameOf(
                issue.categoryId,
                content.categories,
              ),
              onOpen: () => onOpen(issue.issueId),
            ),
        ],
      ],
    );
  }
}

bool _isFiltering(IssueQuery query) =>
    searchWords(query.text ?? '').isNotEmpty ||
    query.categoryId != null ||
    query.industrySegmentId != null ||
    query.year != null ||
    query.edition != null;

IssueQuery _withText(IssueQuery query, String text) => IssueQuery(
  text: text,
  categoryId: query.categoryId,
  industrySegmentId: query.industrySegmentId,
  year: query.year,
  edition: query.edition,
);

/// A text field with the search field's rounded ends, not Flutter's
/// `SearchBar`, whose text field is a 17 point tap target for accessibility
/// (`READER_SCREEN_DESIGNS.md` section 5).
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const OutlineInputBorder rounded = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(MfwShape.searchRadius)),
      borderSide: BorderSide.none,
    );
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, Widget? _) =>
          TextField(
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: CatalogueText.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: value.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: CatalogueText.clearSearch,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
              border: rounded,
              enabledBorder: rounded,
            ),
          ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.choices,
    required this.query,
    required this.categoryNames,
    required this.segmentNames,
    required this.onQuery,
  });

  final FilterChoices choices;
  final IssueQuery query;
  final Map<String, String> categoryNames;
  final Map<String, String> segmentNames;
  final ValueChanged<IssueQuery> onQuery;

  IssueQuery _with({
    Object? categoryId = _keep,
    Object? segmentId = _keep,
    Object? year = _keep,
    Object? edition = _keep,
  }) => IssueQuery(
    text: query.text,
    categoryId: identical(categoryId, _keep)
        ? query.categoryId
        : categoryId as String?,
    industrySegmentId: identical(segmentId, _keep)
        ? query.industrySegmentId
        : segmentId as String?,
    year: identical(year, _keep) ? query.year : year as int?,
    edition: identical(edition, _keep) ? query.edition : edition as String?,
  );

  @override
  Widget build(BuildContext context) {
    final List<String> categoryIds = choices.categoryIds.toList()
      ..sort(
        (String a, String b) =>
            (categoryNames[a] ?? a).compareTo(categoryNames[b] ?? b),
      );
    final List<String> segmentIds = choices.segmentIds.toList()
      ..sort(
        (String a, String b) =>
            (segmentNames[a] ?? a).compareTo(segmentNames[b] ?? b),
      );
    return Wrap(
      spacing: MfwSpace.sm,
      runSpacing: MfwSpace.sm,
      children: <Widget>[
        _FilterButton<String>(
          name: CatalogueText.filterCategory,
          anyLabel: CatalogueText.anyCategory,
          options: <(String, String)>[
            for (final String id in categoryIds) (id, categoryNames[id] ?? id),
          ],
          selected: query.categoryId,
          onSelected: (String? id) => onQuery(_with(categoryId: id)),
        ),
        if (segmentIds.isNotEmpty)
          _FilterButton<String>(
            name: CatalogueText.filterSegment,
            anyLabel: CatalogueText.anySegment,
            options: <(String, String)>[
              for (final String id in segmentIds) (id, segmentNames[id] ?? id),
            ],
            selected: query.industrySegmentId,
            onSelected: (String? id) => onQuery(_with(segmentId: id)),
          ),
        _FilterButton<int>(
          name: CatalogueText.filterYear,
          anyLabel: CatalogueText.anyYear,
          options: <(int, String)>[
            for (final int year in choices.years) (year, '$year'),
          ],
          selected: query.year,
          onSelected: (int? year) => onQuery(_with(year: year)),
        ),
        if (choices.editions.isNotEmpty)
          _FilterButton<String>(
            name: CatalogueText.filterEdition,
            anyLabel: CatalogueText.anyEdition,
            options: <(String, String)>[
              for (final String edition in choices.editions) (edition, edition),
            ],
            selected: query.edition,
            onSelected: (String? edition) => onQuery(_with(edition: edition)),
          ),
      ],
    );
  }
}

const Object _keep = Object();

/// A filter: a chip that names the filter, or its value when set, and opens
/// a list of the values with "any" first.
class _FilterButton<T extends Object> extends StatelessWidget {
  const _FilterButton({
    required this.name,
    required this.anyLabel,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String name;
  final String anyLabel;
  final List<(T, String)> options;
  final T? selected;
  final ValueChanged<T?> onSelected;

  String? get _selectedLabel {
    for (final (T value, String label) in options) {
      if (value == selected) {
        return label;
      }
    }
    return null;
  }

  Future<void> _choose(BuildContext context) async {
    final ({T? value})? picked = await showModalBottomSheet<({T? value})>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MfwSpace.lg),
              child: Semantics(
                header: true,
                child: Text(name, style: MfwType.h4),
              ),
            ),
            _option(context, anyLabel, null),
            for (final (T value, String label) in options)
              _option(context, label, value),
          ],
        ),
      ),
    );
    if (picked != null) {
      onSelected(picked.value);
    }
  }

  Widget _option(BuildContext context, String label, T? value) {
    final bool on = value == selected;
    return ListTile(
      title: Text(label),
      selected: on,
      trailing: on ? const Icon(Icons.check) : null,
      onTap: () => Navigator.of(context).pop((value: value)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? label = _selectedLabel;
    return FilterChip(
      label: Text(label ?? name),
      tooltip: CatalogueText.filterTooltip(name, label),
      selected: label != null,
      onSelected: (_) => _choose(context),
    );
  }
}

/// The published issues, the categories and the segment names, read
/// together.
typedef CatalogueContent = ({
  List<IssueSummary> issues,
  List<IssueCategory> categories,
  Map<String, String> segmentNames,
});

/// Reads the published issues, the categories and, from [segments], the
/// segment names from [catalogue] at once. Fails when the issues or the
/// categories fail; without segment names the filter shows identifiers.
Future<Result<CatalogueContent>> loadCatalogue(
  CatalogueRepository catalogue, {
  SegmentSource? segments,
}) async {
  final (
    Result<List<IssueSummary>> issues,
    Result<List<IssueCategory>> categories,
    Result<List<IndustrySegment>> segmentList,
  ) = await (
    catalogue.listPublishedIssues(),
    catalogue.listCategories(),
    segments?.listSegments() ??
        Future<Result<List<IndustrySegment>>>.value(
          const Ok<List<IndustrySegment>>(<IndustrySegment>[]),
        ),
  ).wait;
  final Map<String, String> segmentNames = switch (segmentList) {
    Ok<List<IndustrySegment>>(:final List<IndustrySegment> value) =>
      <String, String>{
        for (final IndustrySegment segment in value)
          segment.segmentId: segment.name,
      },
    Err<List<IndustrySegment>>() => const <String, String>{},
  };
  return switch ((issues, categories)) {
    (Err<List<IssueSummary>>(:final AppFailure failure), _) =>
      Err<CatalogueContent>(failure),
    (_, Err<List<IssueCategory>>(:final AppFailure failure)) =>
      Err<CatalogueContent>(failure),
    (
      Ok<List<IssueSummary>>(value: final List<IssueSummary> list),
      Ok<List<IssueCategory>>(value: final List<IssueCategory> names),
    ) =>
      Ok<CatalogueContent>((
        issues: list,
        categories: names,
        segmentNames: segmentNames,
      )),
  };
}
