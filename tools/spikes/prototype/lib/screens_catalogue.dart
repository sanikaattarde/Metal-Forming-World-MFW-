import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_prototype/model.dart';
import 'package:mfw_prototype/screens_auth.dart';
import 'package:mfw_prototype/screens_news.dart';
import 'package:mfw_prototype/screens_reader.dart';
import 'package:mfw_prototype/widgets.dart';

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
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Text(
                'Latest issue',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => openIssue(context, latest),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const GreyBox(label: 'Cover', width: 120, height: 160),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            latest.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(latest.category),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () => openIssue(context, latest),
                            child: const Text('View issue'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Archive',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            const CatalogueScreen(),
                      ),
                    ),
                    child: const Text('See all'),
                  ),
                ],
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
                                const SizedBox(height: 4),
                                Text(issue.title, maxLines: 2),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Latest news',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              for (final Article article in sampleArticles.take(2))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(article.title),
                  subtitle: Text(article.category),
                  onTap: () => openArticle(context, article),
                ),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search issues',
              ),
              onChanged: (String text) => setState(() => _query = text),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              offline: !model.online,
              child: ListView(
                children: <Widget>[
                  for (final Issue issue in results)
                    ListTile(
                      leading: const GreyBox(label: '', width: 40, height: 56),
                      title: Text(issue.title),
                      subtitle: Text(
                        '${issue.category} · ${issue.pages} pages',
                      ),
                      trailing: model.isDownloaded(issue)
                          ? const Icon(
                              Icons.download_done,
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
          icon: const Icon(Icons.share),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The system share sheet opens')),
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Center(child: GreyBox(label: 'Cover', width: 180, height: 240)),
          const SizedBox(height: 16),
          Text(issue.title, style: Theme.of(context).textTheme.headlineSmall),
          Text('${issue.category} · ${issue.pages} pages'),
          Text('Size: ${issue.sizeMb.toStringAsFixed(1)} MB'),
          const SizedBox(height: 8),
          const Text(
            'Short description of the issue. Visitors see public details '
            'only (OQ-13).',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.menu_book),
            onPressed: () => unawaited(_readOrDownload(context, keep: false)),
            label: Text(downloaded ? 'Open' : 'Read'),
          ),
          const SizedBox(height: 8),
          if (downloaded)
            const ListTile(
              leading: Icon(Icons.download_done),
              title: Text('Downloaded for offline reading'),
            )
          else
            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              onPressed: () => unawaited(_readOrDownload(context, keep: true)),
              label: const Text('Download'),
            ),
          const SizedBox(height: 8),
          Text(
            'Read opens a temporary copy; Download keeps one (working '
            'position, OQ-08).',
            style: Theme.of(context).textTheme.bodySmall,
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
  const DownloadSheet({required this.issue, required this.keep, super.key});

  /// The issue.
  final Issue issue;

  /// Whether the copy is kept.
  final bool keep;

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
    final String size = '${widget.issue.sizeMb.toStringAsFixed(1)} MB';
    final List<Widget> body = switch (_phase) {
      _Phase.plan when model.lowStorage => <Widget>[
        Text('This issue is $size.'),
        const SizedBox(height: 8),
        const Text(
          'There is not enough free space on this device for this issue.',
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Close'),
        ),
      ],
      _Phase.plan => <Widget>[
        Text('This issue is $size.'),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _start,
          child: Text(widget.keep ? 'Download' : 'Download and read'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
      _Phase.mobileWarning => <Widget>[
        Text('You are on mobile data. This issue is $size.'),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _start,
          child: const Text('Download on mobile data'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
      ],
      _Phase.running => <Widget>[
        LinearProgressIndicator(value: _progress),
        const SizedBox(height: 8),
        Text('${(_progress * 100).round()}% of $size'),
        TextButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel download'),
        ),
      ],
      _Phase.waiting => <Widget>[
        LinearProgressIndicator(value: _progress),
        const SizedBox(height: 8),
        Text('${(_progress * 100).round()}% of $size kept'),
        const Text('The download stopped because the connection was lost.'),
        const SizedBox(height: 8),
        FilledButton(onPressed: _start, child: const Text('Resume')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel and delete the part downloaded'),
        ),
      ],
      _Phase.failed => <Widget>[
        const Text('The downloaded file did not pass its check.'),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () {
            model.outcome = DownloadOutcome.completes;
            _start();
          },
          child: const Text('Retry'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Close'),
        ),
      ],
    };
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'SCR-A-13 · ${widget.issue.title}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...body,
          ],
        ),
      ),
    );
  }
}
