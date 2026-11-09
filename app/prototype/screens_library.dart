import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/features/downloads/presentation/downloads_text.dart';

import 'brand.dart';

import 'model.dart';
import 'screens_auth.dart';
import 'screens_catalogue.dart';
import 'screens_reader.dart';
import 'widgets.dart';

/// What a fullAccess screen shows before the reader has full access.
class NeedsFullAccess extends StatelessWidget {
  /// Creates the notice.
  const NeedsFullAccess({required this.what, super.key});

  /// What the screen holds, for the sentence.
  final String what;

  @override
  Widget build(BuildContext context) {
    return Message(
      icon: Icons.lock_outline,
      text: 'Sign in to see your $what.',
      action: 'Continue',
      onAction: () => unawaited(ensureFullAccess(context)),
    );
  }
}

/// SCR-A-15. Works with no network. Partial downloads and temporary copies
/// are not listed (GS-Q43).
class DownloadsScreen extends StatelessWidget {
  /// Creates the screen.
  const DownloadsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Issue issue) async {
    final ProtoModel model = Proto.read(context);
    final bool? delete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete this download?'),
        content: Text(
          'This frees ${issue.sizeMb.toStringAsFixed(1)} MB. You can '
          'download the issue again later.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (delete == true) {
      model.removeDownload(issue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final List<Issue> downloads = model.content == Content.empty
        ? <Issue>[]
        : model.downloads;
    return LofiScreen(
      id: 'SCR-A-15',
      title: 'Downloads',
      body: model.access != Access.fullAccess
          ? const NeedsFullAccess(what: 'downloads')
          : StateView(
              content: downloads.isEmpty ? Content.empty : Content.normal,
              emptyText: DownloadsText.empty,
              emptyIcon: Icons.download_outlined,
              child: ListView(
                children: <Widget>[
                  for (final Issue issue in downloads)
                    IssueRow(
                      title: issue.title,
                      meta:
                          '${DownloadsText.downloaded} · '
                          '${DownloadsText.sizeLabel(issue.bytes)}',
                      onTap: () => Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              ReaderScreen(issue: issue),
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: DownloadsText.deleteDownload,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            unawaited(_confirmDelete(context, issue)),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

/// SCR-A-16 and SCR-A-17 as two tabs of one screen. Two screens or two
/// views of one is SN-05.
class LibraryScreen extends StatelessWidget {
  /// Creates the screen.
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return DefaultTabController(
      length: 2,
      child: LofiScreen(
        id: 'SCR-A-16 and SCR-A-17',
        title: 'Library',
        bottom: const TabBar(
          tabs: <Widget>[
            Tab(text: 'Bookmarks'),
            Tab(text: 'Favourites'),
          ],
        ),
        body: model.access != Access.fullAccess
            ? const NeedsFullAccess(what: 'bookmarks and favourites')
            : TabBarView(
                children: <Widget>[_bookmarks(context), _favourites(context)],
              ),
      ),
    );
  }

  Widget _bookmarks(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final List<(Issue, int)> bookmarks = model.content == Content.empty
        ? <(Issue, int)>[]
        : model.bookmarks;
    return StateView(
      content: bookmarks.isEmpty ? Content.empty : Content.normal,
      emptyText: 'No bookmarks yet. Bookmark a page in the reader.',
      emptyIcon: Icons.bookmark_border,
      child: ListView(
        children: <Widget>[
          for (final (Issue issue, int page) in bookmarks)
            IssueRow(
              title: issue.title,
              meta: 'Page $page',
              onTap: () => Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      ReaderScreen(issue: issue, initialPage: page),
                ),
              ),
              trailing: IconButton(
                tooltip: 'Remove bookmark',
                icon: const Icon(Icons.close),
                onPressed: () => model.toggleBookmark(issue, page),
              ),
            ),
        ],
      ),
    );
  }

  Widget _favourites(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final List<Issue> favourites = model.content == Content.empty
        ? <Issue>[]
        : model.favourites;
    return StateView(
      content: favourites.isEmpty ? Content.empty : Content.normal,
      emptyText: 'No favourites yet. Use the star on an issue.',
      emptyIcon: Icons.star_border,
      child: ListView(
        children: <Widget>[
          for (final Issue issue in favourites)
            IssueRow(
              title: issue.title,
              meta: '${issue.category} · ${issue.pages} pages',
              onTap: () => openIssue(context, issue),
            ),
        ],
      ),
    );
  }
}
