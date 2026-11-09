import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';
import 'package:mfw_app/features/downloads/presentation/downloads_text.dart';

import 'brand.dart';

import 'model.dart';
import 'screens_auth.dart';
import 'screens_news.dart';
import 'screens_reader.dart';
import 'widgets.dart';

/// Opens issue details for [issue].
void openIssue(BuildContext context, Issue issue) {
  unawaited(
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => IssueDetailsScreen(issue: issue),
      ),
    ),
  );
}

/// SCR-A-10. Its content is set in the M2 designs (SCP-002). One screen
/// with the catalogue, or two, is SN-03.
class HomeScreen extends StatelessWidget {
  /// Creates the screen.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final Issue latest = sampleIssues.first;
    return LofiScreen(
      id: 'SCR-A-10',
      title: 'Home',
      titleWidget: const LogoPlaceholder(),
      actions: <Widget>[
        IconButton(
          tooltip: 'Search the catalogue',
          icon: const Icon(Icons.search),
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const CatalogueScreen(),
            ),
          ),
        ),
      ],
      body: StateView(
        content: model.content,
        emptyText: 'No issues are published yet.',
        offline: !model.online,
        child: RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: MfwSpace.lg),
            children: <Widget>[
              const SectionHeading('Latest issue'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const GreyBox(label: 'Cover', width: 120, height: 160),
                  const SizedBox(width: MfwSpace.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(latest.title, style: MfwType.h3),
                        const SizedBox(height: MfwSpace.xs),
                        Text(latest.category, style: MfwType.small),
                        const SizedBox(height: MfwSpace.lg),
                        FilledButton(
                          onPressed: () => openIssue(context, latest),
                          child: const Text('View issue'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SectionHeading(
                'Archive',
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          const CatalogueScreen(),
                    ),
                  ),
                  child: const Text('See all'),
                ),
              ),
              SizedBox(
                height: 190,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    for (final Issue issue in sampleIssues.skip(1))
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () => openIssue(context, issue),
                          child: SizedBox(
                            width: 100,
                            child: Column(
                              children: <Widget>[
                                const GreyBox(
                                  label: 'Cover',
                                  width: 100,
                                  height: 140,
                                ),
                                const SizedBox(height: MfwSpace.xs),
                                Text(
                                  issue.title,
                                  maxLines: 2,
                                  style: MfwType.small,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SectionHeading('Latest news'),
              for (final Article article in sampleArticles.take(2))
                NewsRow(
                  title: article.title,
                  meta: article.category,
                  breaking: article.breaking,
                  horizontalPadding: 0,
                  onTap: () => openArticle(context, article),
                ),
              const SizedBox(height: MfwSpace.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// SCR-A-11.
class CatalogueScreen extends StatefulWidget {
  /// Creates the screen.
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final List<Issue> results = model.content == Content.empty
        ? <Issue>[]
        : sampleIssues
              .where(
                (Issue issue) =>
                    (_category == null || issue.category == _category) &&
                    issue.title.toLowerCase().contains(_query.toLowerCase()),
              )
              .toList();
    final Set<String> categories = <String>{
      for (final Issue issue in sampleIssues) issue.category,
    };
    return LofiScreen(
      id: 'SCR-A-11',
      title: 'Catalogue',
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              MfwSpace.lg,
              MfwSpace.lg,
              MfwSpace.lg,
              0,
            ),
            // The search field's rounded ends on a text field, not
            // Flutter's SearchBar (READER_SCREEN_DESIGNS.md section 5).
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search issues',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(MfwShape.searchRadius),
                  ),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(MfwShape.searchRadius),
                  ),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (String text) => setState(() => _query = text),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: MfwSpace.lg,
              vertical: MfwSpace.md,
            ),
            child: Row(
              children: <Widget>[
                FilterChip(
                  label: const Text('All'),
                  selected: _category == null,
                  onSelected: (_) => setState(() => _category = null),
                ),
                for (final String category in categories)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: StateView(
              content: model.content == Content.loading
                  ? Content.loading
                  : results.isEmpty
                  ? Content.empty
                  : Content.normal,
              emptyText: 'No issues match. Try another word or filter.',
              emptyIcon: Icons.search_off,
              offline: !model.online,
              child: ListView(
                children: <Widget>[
                  for (final Issue issue in results)
                    IssueRow(
                      title: issue.title,
                      meta: '${issue.category} · ${issue.pages} pages',
                      trailing: model.isDownloaded(issue)
                          ? const Icon(
                              Icons.download_done,
                              color: MfwColours.body,
                              semanticLabel: 'Downloaded',
                            )
                          : null,
                      onTap: () => openIssue(context, issue),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// SCR-A-12. Public metadata for every state; Read and Download go through
/// the entry rule.
class IssueDetailsScreen extends StatelessWidget {
  /// Creates the screen for [issue].
  const IssueDetailsScreen({required this.issue, super.key});

  /// The issue.
  final Issue issue;

  Future<void> _readOrDownload(
    BuildContext context, {
    required bool keep,
  }) async {
    final ProtoModel model = Proto.read(context);
    final NavigatorState navigator = Navigator.of(context);
    if (!await ensureFullAccess(context)) {
      return;
    }
    if (model.isDownloaded(issue)) {
      if (!keep) {
        await navigator.push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => ReaderScreen(issue: issue),
          ),
        );
      }
      return;
    }
    if (!navigator.mounted) {
      return;
    }
    final bool? done = await showModalBottomSheet<bool>(
      context: navigator.context,
      isDismissible: false,
      builder: (BuildContext context) =>
          DownloadSheet(issue: issue, keep: keep),
    );
    if (done == true && !keep) {
      await navigator.push<void>(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ReaderScreen(issue: issue),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    if (model.unpublished) {
      return const LofiScreen(
        id: 'SCR-A-12',
        title: 'Issue',
        body: Message(
          icon: Icons.block,
          text: 'This issue is no longer available.',
        ),
      );
    }
    final bool downloaded = model.isDownloaded(issue);
    return LofiScreen(
      id: 'SCR-A-12',
      title: issue.title,
      actions: <Widget>[
        IconButton(
          tooltip: model.isFavourite(issue)
              ? 'Remove from favourites'
              : 'Add to favourites',
          icon: Icon(model.isFavourite(issue) ? Icons.star : Icons.star_border),
          onPressed: () async {
            if (await ensureFullAccess(context)) {
              model.toggleFavourite(issue);
            }
          },
        ),
        IconButton(
          tooltip: 'Share',
          icon: const Icon(Icons.share_outlined),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The system share sheet opens')),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          const Center(child: GreyBox(label: 'Cover', width: 180, height: 240)),
          const SizedBox(height: MfwSpace.lg),
          Text(issue.title, style: MfwType.h2),
          const SizedBox(height: MfwSpace.xs),
          Text(
            '${issue.category} · ${issue.pages} pages · '
            '${DownloadsText.sizeLabel(issue.bytes)}',
            style: MfwType.small,
          ),
          const SizedBox(height: MfwSpace.lg),
          Text(
            'A short synthetic description of the issue and what it holds. '
            'Visitors see this public part only (OQ-13).',
            style: MfwType.body,
          ),
          const SizedBox(height: MfwSpace.xl),
          if (model.access != Access.fullAccess)
            const Notice(
              'Sign in to read and download full issues.',
              kind: NoticeKind.info,
            ),
          FilledButton(
            onPressed: () => unawaited(_readOrDownload(context, keep: false)),
            child: Text(downloaded ? 'Open' : 'Read'),
          ),
          const SizedBox(height: MfwSpace.sm),
          if (downloaded)
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.download_done, color: MfwColours.body),
              title: Text('Downloaded for offline reading'),
            )
          else
            OutlinedButton(
              onPressed: () => unawaited(_readOrDownload(context, keep: true)),
              child: const Text(DownloadsText.download),
            ),
          const SizedBox(height: MfwSpace.md),
          Text(
            'Read opens a temporary copy; Download keeps one (working '
            'position, OQ-08).',
            style: MfwType.small,
          ),
        ],
      ),
    );
  }
}

/// SCR-A-13: size, mobile-data warning, progress, waiting for the network,
/// and failure with retry. Pops true when the copy is complete.
class DownloadSheet extends StatefulWidget {
  /// Creates the sheet for [issue]. [keep] is Download; otherwise Read.
  const DownloadSheet({
    required this.issue,
    required this.keep,
    this.waitingAt,
    super.key,
  });

  /// The issue.
  final Issue issue;

  /// Whether the copy is kept.
  final bool keep;

  /// Opens the sheet waiting for the network at this fraction, for the
  /// screen images only.
  @visibleForTesting
  final double? waitingAt;

  @override
  State<DownloadSheet> createState() => _DownloadSheetState();
}

enum _Phase { plan, mobileWarning, running, waiting, failed }

class _DownloadSheetState extends State<DownloadSheet> {
  _Phase _phase = _Phase.plan;
  double _progress = 0;
  bool _brokeOnce = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final double? at = widget.waitingAt;
    if (at != null) {
      _phase = _Phase.waiting;
      _progress = at;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    final ProtoModel model = Proto.read(context);
    if (model.mobileData && _phase == _Phase.plan) {
      setState(() => _phase = _Phase.mobileWarning);
      return;
    }
    setState(() => _phase = _Phase.running);
    _timer = Timer.periodic(const Duration(milliseconds: 60), (Timer timer) {
      setState(() => _progress = (_progress + 0.02).clamp(0, 1));
      if (model.outcome == DownloadOutcome.breaks &&
          !_brokeOnce &&
          _progress >= 0.5) {
        timer.cancel();
        _brokeOnce = true;
        setState(() => _phase = _Phase.waiting);
      } else if (_progress >= 1) {
        timer.cancel();
        if (model.outcome == DownloadOutcome.corrupt) {
          setState(() {
            _phase = _Phase.failed;
            _progress = 0;
          });
          return;
        }
        if (widget.keep) {
          model.addDownload(widget.issue);
        }
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final int bytes = widget.issue.bytes;
    final int received = (bytes * _progress).round();
    final Widget cancel = TextButton(
      onPressed: () => Navigator.of(context).pop(false),
      child: const Text(DownloadsText.cancel),
    );
    final Widget progress = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LinearProgressIndicator(
          value: _progress,
          semanticsLabel: 'Download progress',
          semanticsValue: '${(_progress * 100).round()}',
        ),
        const SizedBox(height: MfwSpace.sm),
        Text(
          _phase == _Phase.waiting
              ? '${DownloadsText.progress(received, bytes)} kept'
              : DownloadsText.progress(received, bytes),
          style: MfwType.small,
        ),
        const SizedBox(height: MfwSpace.lg),
      ],
    );
    final List<Widget> body = switch (_phase) {
      _Phase.plan when model.lowStorage => <Widget>[
        Text(DownloadsText.size(bytes), style: MfwType.small),
        const SizedBox(height: MfwSpace.lg),
        const Notice(DownloadsText.notEnoughSpace),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Close'),
        ),
      ],
      _Phase.plan => <Widget>[
        Text(DownloadsText.size(bytes), style: MfwType.small),
        const SizedBox(height: MfwSpace.lg),
        FilledButton(
          onPressed: _start,
          child: Text(widget.keep ? 'Download' : 'Download and read'),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: MfwSpace.md),
          child: Text(
            widget.keep
                ? 'Keeps a copy on this device for reading offline.'
                : 'Opens a temporary copy, removed when you leave the issue.',
            style: MfwType.small,
          ),
        ),
        cancel,
      ],
      _Phase.mobileWarning => <Widget>[
        Text(DownloadsText.mobileDataTitle, style: MfwType.h4),
        const SizedBox(height: MfwSpace.sm),
        Text(DownloadsText.mobileDataBody(bytes), style: MfwType.body),
        const SizedBox(height: MfwSpace.lg),
        FilledButton(
          onPressed: _start,
          child: const Text(DownloadsText.useMobileData),
        ),
        const SizedBox(height: MfwSpace.sm),
        cancel,
      ],
      _Phase.running => <Widget>[
        progress,
        TextButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel download'),
        ),
      ],
      _Phase.waiting => <Widget>[
        progress,
        const Notice(
          'The download stopped because the connection was lost. Resume '
          'goes on from where it stopped.',
          kind: NoticeKind.offline,
        ),
        FilledButton(onPressed: _start, child: const Text('Resume')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel and delete the part downloaded'),
        ),
      ],
      _Phase.failed => <Widget>[
        const Notice(DownloadsText.failedCorrupt),
        FilledButton(
          onPressed: () {
            model.outcome = DownloadOutcome.completes;
            _start();
          },
          child: const Text(DownloadsText.retry),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Close'),
        ),
      ],
    };
    final bool moving = _phase == _Phase.running || _phase == _Phase.waiting;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MfwSpace.lg,
          MfwSpace.xl,
          MfwSpace.lg,
          MfwSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (model.showIds) Text('SCR-A-13', style: MfwType.small),
            Text(
              moving ? 'Downloading ${widget.issue.title}' : widget.issue.title,
              style: moving ? MfwType.h4 : MfwType.h3,
            ),
            const SizedBox(height: MfwSpace.xs),
            ...body,
          ],
        ),
      ),
    );
  }
}
