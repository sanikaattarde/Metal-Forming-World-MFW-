// Design frames for MOD16-P1-T02: the reader-side screens SCR-A-10 to
// SCR-A-19 and SCR-A-22, with the states of SCREEN_INVENTORY_AND_NAVIGATION.md
// section 7 (loading, empty, no network, low storage, download failed and
// WordPress unreachable).
//
// These are designs drawn with the app's theme and tokens (#57), not app
// screens: they hold no logic and nothing in `lib/` imports them. The
// wording is PLACEHOLDER until the M2 designs, except where it comes from
// the code (`messageFor` of #61 and `DownloadsText` of #65). The open points
// each frame waits for are in Documentation/design/READER_SCREEN_DESIGNS.md.
// All values shown are synthetic (DEC-024): no MFW issue, cover, article or
// logo is drawn.

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';
import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/errors/failure_messages.dart';
import 'package:mfw_app/features/downloads/presentation/downloads_text.dart';

/// One frame: a file name and the screen it draws.
typedef ReaderFrame = ({String name, String title, Widget screen});

const int _issueBytes = 48200000;

String _network() =>
    messageFor(const AppFailure(FailureCode.network, retryable: true));

/// Every frame, in the order of the design record.
final List<ReaderFrame> readerFrames = <ReaderFrame>[
  (name: 'r10_home', title: 'SCR-A-10 Home', screen: const _Home()),
  (
    name: 'r10_home_loading',
    title: 'SCR-A-10 Home: loading',
    screen: const _Home(state: _Load.loading),
  ),
  (
    name: 'r10_home_no_network',
    title: 'SCR-A-10 Home: no network',
    screen: const _Home(state: _Load.error),
  ),
  (
    name: 'r11_catalogue',
    title: 'SCR-A-11 Catalogue',
    screen: const _Catalogue(),
  ),
  (
    name: 'r11_catalogue_no_results',
    title: 'SCR-A-11 Catalogue: no results',
    screen: const _Catalogue(empty: true),
  ),
  (
    name: 'r12_issue_details',
    title: 'SCR-A-12 Issue details',
    screen: const _IssueDetails(),
  ),
  (
    name: 'r12_issue_details_visitor',
    title: 'SCR-A-12 Issue details: visitor',
    screen: const _IssueDetails(visitor: true),
  ),
  (
    name: 'r13_download_choice',
    title: 'SCR-A-13 Download: read or download',
    screen: const _DownloadSheet(_Sheet.choice),
  ),
  (
    name: 'r13_download_mobile_data',
    title: 'SCR-A-13 Download: mobile data',
    screen: const _DownloadSheet(_Sheet.mobileData),
  ),
  (
    name: 'r13_download_progress',
    title: 'SCR-A-13 Download: in progress',
    screen: const _DownloadSheet(_Sheet.progress),
  ),
  (
    name: 'r13_download_waiting',
    title: 'SCR-A-13 Download: waiting for the network',
    screen: const _DownloadSheet(_Sheet.waiting),
  ),
  (
    name: 'r13_download_low_storage',
    title: 'SCR-A-13 Download: low storage',
    screen: const _DownloadSheet(_Sheet.lowStorage),
  ),
  (
    name: 'r13_download_failed',
    title: 'SCR-A-13 Download: failed',
    screen: const _DownloadSheet(_Sheet.failed),
  ),
  (name: 'r14_reader', title: 'SCR-A-14 Reader', screen: const _Reader()),
  (
    name: 'r14_reader_damaged',
    title: 'SCR-A-14 Reader: damaged file',
    screen: const _Reader(damaged: true),
  ),
  (
    name: 'r15_downloads',
    title: 'SCR-A-15 Downloads',
    screen: const _Downloads(),
  ),
  (
    name: 'r15_downloads_failed',
    title: 'SCR-A-15 Downloads: a download failed',
    screen: const _Downloads(failed: true),
  ),
  (
    name: 'r15_downloads_empty',
    title: 'SCR-A-15 Downloads: empty',
    screen: const _Downloads(empty: true),
  ),
  (
    name: 'r16_bookmarks',
    title: 'SCR-A-16 Bookmarks',
    screen: const _Library(tab: 0),
  ),
  (
    name: 'r16_bookmarks_empty',
    title: 'SCR-A-16 Bookmarks: empty',
    screen: const _Library(tab: 0, empty: true),
  ),
  (
    name: 'r17_favourites',
    title: 'SCR-A-17 Favourites',
    screen: const _Library(tab: 1),
  ),
  (name: 'r18_news', title: 'SCR-A-18 News', screen: const _News()),
  (
    name: 'r18_news_loading',
    title: 'SCR-A-18 News: loading',
    screen: const _News(state: _NewsState.loading),
  ),
  (
    name: 'r18_news_category_empty',
    title: 'SCR-A-18 News: empty category',
    screen: const _News(state: _NewsState.emptyCategory),
  ),
  (
    name: 'r18_news_unreachable',
    title: 'SCR-A-18 News: site unreachable',
    screen: const _News(state: _NewsState.unreachable),
  ),
  (name: 'r19_article', title: 'SCR-A-19 Article', screen: const _Article()),
  (
    name: 'r19_article_offline',
    title: 'SCR-A-19 Article: offline',
    screen: const _Article(offline: true),
  ),
  (
    name: 'r22_not_found',
    title: 'SCR-A-22 Not found',
    screen: const _NotFound(),
  ),
];

enum _Load { data, loading, error }

// The tabs drawn selected; Settings is the fifth tab and is drawn in #67.
enum _Tab { home, news, library, downloads }

// Shared parts.

/// A tab screen with the navigation bar of the shell.
class _TabPage extends StatelessWidget {
  const _TabPage({
    required this.tab,
    required this.body,
    this.title,
    this.titleWidget,
    this.bottom,
  });

  final _Tab tab;
  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: titleWidget ?? Text(title ?? ''),
        bottom: bottom,
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.index,
        onDestinationSelected: (_) {},
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.article_outlined),
            label: 'News',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            label: 'Downloads',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// A screen opened from a tab, with a back action.
class _Page extends StatelessWidget {
  const _Page({required this.title, required this.body, this.actions});

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text(title),
        actions: actions,
      ),
      body: body,
    );
  }
}

/// The logo stays a placeholder: MFW's file stays out of the repository
/// (DEC-024), and the app shows it only from that file (BRAND_REFERENCE.md
/// section 8).
class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all(color: MfwColours.divider)),
      child: Text('MFW logo', style: MfwType.small),
    );
  }
}

/// A section heading in the website's style: a small capital label and a
/// short red rule (BRAND_REFERENCE.md section 6).
class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: MfwSpace.xl, bottom: MfwSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(text.toUpperCase(), style: MfwType.label),
          const SizedBox(height: MfwSpace.xs),
          Container(width: 32, height: 2, color: MfwColours.action),
        ],
      ),
    );
  }
}

/// A cover placeholder. Covers are MFW content and are not drawn.
class _Cover extends StatelessWidget {
  const _Cover({this.width = 96, this.label});

  final double width;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 4 / 3,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MfwColours.inputFill,
        border: Border.all(color: MfwColours.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.menu_book_outlined, color: MfwColours.body),
          if (label != null) ...<Widget>[
            const SizedBox(height: MfwSpace.xs),
            Text(label!, style: MfwType.small),
          ],
        ],
      ),
    );
  }
}

/// An article picture placeholder.
class _Picture extends StatelessWidget {
  const _Picture({this.width, this.height = 72});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: MfwColours.inputFill,
      child: const Icon(Icons.image_outlined, color: MfwColours.body),
    );
  }
}

/// A notice: a bar in the error, success or warning colour, an icon and the
/// message in a dark colour, so colour is never the only signal
/// (DESIGN_TOKENS.md sections 3.2 and 5).
class _Notice extends StatelessWidget {
  const _Notice(this.text, {this.kind = _NoticeKind.error, this.action});

  final String text;
  final _NoticeKind kind;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final (Color edge, IconData icon, String label) = switch (kind) {
      _NoticeKind.error => (MfwColours.error, Icons.error_outline, 'Problem'),
      _NoticeKind.offline => (
        MfwColours.warning,
        Icons.cloud_off_outlined,
        'Offline',
      ),
      _NoticeKind.info => (MfwColours.divider, Icons.info_outline, 'Note'),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: MfwSpace.lg),
      padding: const EdgeInsets.all(MfwSpace.md),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: edge, width: 4)),
        color: MfwColours.inputFill,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: MfwColours.heading, semanticLabel: label),
          const SizedBox(width: MfwSpace.md),
          Expanded(
            child: Text(
              text,
              style: MfwType.body.copyWith(color: MfwColours.heading),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

enum _NoticeKind { error, offline, info }

class _Retry extends StatelessWidget {
  const _Retry();

  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: () {}, child: const Text('Retry'));
}

/// An empty state: an icon, a heading and one line, with an optional action.
class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.heading,
    required this.text,
    this.action,
  });

  final IconData icon;
  final String heading;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MfwSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: MfwSpace.xxl),
          Icon(icon, size: 48, color: MfwColours.body),
          const SizedBox(height: MfwSpace.lg),
          Text(heading, style: MfwType.h3, textAlign: TextAlign.center),
          const SizedBox(height: MfwSpace.sm),
          Text(text, style: MfwType.body, textAlign: TextAlign.center),
          if (action != null) ...<Widget>[
            const SizedBox(height: MfwSpace.lg),
            action!,
          ],
        ],
      ),
    );
  }
}

/// A grey block that stands for content while it loads.
class _Skeleton extends StatelessWidget {
  const _Skeleton({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    margin: const EdgeInsets.only(bottom: MfwSpace.sm),
    color: MfwColours.inputFill,
  );
}

class _Loading extends StatelessWidget {
  const _Loading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        LinearProgressIndicator(semanticsLabel: label),
        const SizedBox(height: MfwSpace.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _Skeleton(width: 120, height: 160),
            const SizedBox(width: MfwSpace.lg),
            Expanded(
              child: Column(
                children: const <Widget>[
                  _Skeleton(height: 24),
                  _Skeleton(height: 16),
                  _Skeleton(height: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: MfwSpace.xl),
        for (int i = 0; i < 4; i++) ...<Widget>[
          const _Skeleton(height: 20),
          const _Skeleton(width: 160, height: 14),
          const SizedBox(height: MfwSpace.md),
        ],
      ],
    );
  }
}

class _IssueRow extends StatelessWidget {
  const _IssueRow(this.title, this.meta, {this.trailing});

  final String title;
  final String meta;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MfwSpace.sm),
      child: Row(
        children: <Widget>[
          const _Cover(width: 54),
          const SizedBox(width: MfwSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: MfwType.h5),
                const SizedBox(height: MfwSpace.xs),
                Text(meta, style: MfwType.small),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _NewsRow extends StatelessWidget {
  const _NewsRow(this.title, this.meta, {this.breaking = false});

  final String title;
  final String meta;
  final bool breaking;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MfwSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _Picture(width: 96),
          const SizedBox(width: MfwSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (breaking)
                  Padding(
                    padding: const EdgeInsets.only(bottom: MfwSpace.xs),
                    child: Text('BREAKING', style: MfwType.label),
                  ),
                Text(title, style: MfwType.h5),
                const SizedBox(height: MfwSpace.xs),
                Text(meta, style: MfwType.small),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// SCR-A-10.

class _Home extends StatelessWidget {
  const _Home({this.state = _Load.data});

  final _Load state;

  @override
  Widget build(BuildContext context) {
    return _TabPage(
      tab: _Tab.home,
      titleWidget: const _LogoPlaceholder(),
      body: switch (state) {
        _Load.loading => const _Loading(label: 'Loading the latest issues'),
        _Load.error => ListView(
          padding: const EdgeInsets.all(MfwSpace.lg),
          children: <Widget>[
            _Notice(_network(), action: const _Retry()),
            const _Empty(
              icon: Icons.cloud_off_outlined,
              heading: 'The latest issues need a connection',
              text: 'Issues you downloaded are still on this device.',
            ),
            Center(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Open Downloads'),
              ),
            ),
          ],
        ),
        _Load.data => ListView(
          padding: const EdgeInsets.symmetric(horizontal: MfwSpace.lg),
          children: <Widget>[
            const _Section('Latest issue'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _Cover(width: 120, label: 'Cover'),
                const SizedBox(width: MfwSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Sample issue 12', style: MfwType.h3),
                      const SizedBox(height: MfwSpace.xs),
                      Text('Category A', style: MfwType.small),
                      const SizedBox(height: MfwSpace.lg),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('View issue'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const _Section('Archive'),
            SizedBox(
              height: 168,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  for (final String n in <String>['11', '10', '09', '08'])
                    Padding(
                      padding: const EdgeInsets.only(right: MfwSpace.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const _Cover(),
                          const SizedBox(height: MfwSpace.xs),
                          Text('Sample issue $n', style: MfwType.small),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {},
                child: const Text('See the catalogue'),
              ),
            ),
            const _Section('Latest news'),
            const _NewsRow(
              'Sample breaking article',
              '21 March 2026 · Category A',
              breaking: true,
            ),
            const _NewsRow('Sample article four', '18 March 2026 · Category A'),
            const SizedBox(height: MfwSpace.lg),
          ],
        ),
      },
    );
  }
}

// SCR-A-11.

class _Catalogue extends StatelessWidget {
  const _Catalogue({this.empty = false});

  final bool empty;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Catalogue',
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          // A text field with the search field's rounded ends, not Flutter's
          // SearchBar, whose text field is a 17 point tap target for
          // accessibility (see the design record).
          TextField(
            controller: TextEditingController(
              text: empty ? 'synthetic search' : null,
            ),
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
          ),
          const SizedBox(height: MfwSpace.md),
          Wrap(
            spacing: MfwSpace.sm,
            children: <Widget>[
              for (final (String label, bool on) in <(String, bool)>[
                ('All', !empty),
                ('Category A', empty),
                ('Category B', false),
                ('2026', false),
              ])
                FilterChip(
                  label: Text(label),
                  selected: on,
                  onSelected: (_) {},
                ),
            ],
          ),
          const SizedBox(height: MfwSpace.md),
          if (empty)
            _Empty(
              icon: Icons.search_off,
              heading: 'No issues match',
              text: 'Try other words, or clear the filters.',
              action: OutlinedButton(
                onPressed: () {},
                child: const Text('Clear the filters'),
              ),
            )
          else ...<Widget>[
            Text('48 issues', style: MfwType.small),
            const SizedBox(height: MfwSpace.sm),
            for (final (String n, String c, int p) in <(String, String, int)>[
              ('12', 'A', 64),
              ('11', 'B', 72),
              ('10', 'A', 56),
              ('09', 'A', 60),
            ])
              _IssueRow('Sample issue $n', 'Category $c · $p pages'),
          ],
        ],
      ),
    );
  }
}

// SCR-A-12.

class _IssueDetails extends StatelessWidget {
  const _IssueDetails({this.visitor = false});

  final bool visitor;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Sample issue 12',
      actions: <Widget>[
        if (!visitor)
          IconButton(
            tooltip: 'Add to favourites',
            icon: const Icon(Icons.star_border),
            onPressed: () {},
          ),
        IconButton(
          tooltip: 'Share',
          icon: const Icon(Icons.share_outlined),
          onPressed: () {},
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          const Center(child: _Cover(width: 180, label: 'Cover')),
          const SizedBox(height: MfwSpace.lg),
          Text('Sample issue 12', style: MfwType.h2),
          const SizedBox(height: MfwSpace.xs),
          Text(
            'Category A · 64 pages · ${DownloadsText.sizeLabel(_issueBytes)}',
            style: MfwType.small,
          ),
          const SizedBox(height: MfwSpace.lg),
          Text(
            'A short synthetic description of the issue and what it holds. '
            'Visitors see this public part only.',
            style: MfwType.body,
          ),
          const SizedBox(height: MfwSpace.xl),
          if (visitor) ...<Widget>[
            const _Notice(
              'Sign in to read and download full issues.',
              kind: _NoticeKind.info,
            ),
            FilledButton(onPressed: () {}, child: const Text('Sign in')),
            const SizedBox(height: MfwSpace.sm),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Create an account'),
            ),
          ] else ...<Widget>[
            FilledButton(onPressed: () {}, child: const Text('Read')),
            const SizedBox(height: MfwSpace.sm),
            OutlinedButton(
              onPressed: () {},
              child: const Text(DownloadsText.download),
            ),
          ],
        ],
      ),
    );
  }
}

// SCR-A-13: a sheet over the issue details.

enum _Sheet { choice, mobileData, progress, waiting, lowStorage, failed }

class _DownloadSheet extends StatelessWidget {
  const _DownloadSheet(this.sheet);

  final _Sheet sheet;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(child: ExcludeSemantics(child: _IssueDetails())),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: 0.4)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: MfwColours.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                MfwSpace.lg,
                MfwSpace.xl,
                MfwSpace.lg,
                MfwSpace.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _content(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _content() {
    final Widget cancel = TextButton(
      onPressed: () {},
      child: const Text(DownloadsText.cancel),
    );
    switch (sheet) {
      case _Sheet.choice:
        return <Widget>[
          Text('Sample issue 12', style: MfwType.h3),
          const SizedBox(height: MfwSpace.xs),
          Text(DownloadsText.size(_issueBytes), style: MfwType.small),
          const SizedBox(height: MfwSpace.lg),
          FilledButton(onPressed: () {}, child: const Text('Read')),
          Padding(
            padding: const EdgeInsets.only(bottom: MfwSpace.md),
            child: Text(
              'Opens a temporary copy, removed when you leave the issue.',
              style: MfwType.small,
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: const Text(DownloadsText.download),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: MfwSpace.md),
            child: Text(
              'Keeps a copy on this device for reading offline.',
              style: MfwType.small,
            ),
          ),
          cancel,
        ];
      case _Sheet.mobileData:
        return <Widget>[
          Text(DownloadsText.mobileDataTitle, style: MfwType.h3),
          const SizedBox(height: MfwSpace.sm),
          Text(DownloadsText.mobileDataBody(_issueBytes), style: MfwType.body),
          const SizedBox(height: MfwSpace.lg),
          FilledButton(
            onPressed: () {},
            child: const Text(DownloadsText.useMobileData),
          ),
          const SizedBox(height: MfwSpace.sm),
          cancel,
        ];
      case _Sheet.progress:
        return <Widget>[
          Text('Downloading Sample issue 12', style: MfwType.h4),
          const SizedBox(height: MfwSpace.lg),
          const LinearProgressIndicator(
            value: 0.42,
            semanticsLabel: 'Download progress',
            semanticsValue: '42',
          ),
          const SizedBox(height: MfwSpace.sm),
          Text(
            DownloadsText.progress(20244000, _issueBytes),
            style: MfwType.small,
          ),
          const SizedBox(height: MfwSpace.lg),
          cancel,
        ];
      case _Sheet.waiting:
        return <Widget>[
          Text('Downloading Sample issue 12', style: MfwType.h4),
          const SizedBox(height: MfwSpace.lg),
          const LinearProgressIndicator(
            value: 0.42,
            semanticsLabel: 'Download progress',
            semanticsValue: '42',
          ),
          const SizedBox(height: MfwSpace.sm),
          Text(
            DownloadsText.progress(20244000, _issueBytes),
            style: MfwType.small,
          ),
          const SizedBox(height: MfwSpace.lg),
          const _Notice(
            'Waiting for the network. The download goes on from where it '
            'stopped.',
            kind: _NoticeKind.offline,
          ),
          cancel,
        ];
      case _Sheet.lowStorage:
        return <Widget>[
          Text('Sample issue 12', style: MfwType.h3),
          const SizedBox(height: MfwSpace.xs),
          Text(DownloadsText.size(_issueBytes), style: MfwType.small),
          const SizedBox(height: MfwSpace.lg),
          const _Notice(DownloadsText.notEnoughSpace),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Manage downloads'),
          ),
          const SizedBox(height: MfwSpace.sm),
          cancel,
        ];
      case _Sheet.failed:
        return <Widget>[
          Text('Sample issue 12', style: MfwType.h3),
          const SizedBox(height: MfwSpace.lg),
          const _Notice(DownloadsText.failedCorrupt),
          FilledButton(
            onPressed: () {},
            child: const Text(DownloadsText.retry),
          ),
          const SizedBox(height: MfwSpace.sm),
          cancel,
        ];
    }
  }
}

// SCR-A-14.

class _Reader extends StatelessWidget {
  const _Reader({this.damaged = false});

  final bool damaged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Close the issue',
          icon: const Icon(Icons.close),
          onPressed: () {},
        ),
        title: const Text('Sample issue 12'),
        actions: <Widget>[
          if (!damaged)
            IconButton(
              tooltip: 'Bookmark this page',
              icon: const Icon(Icons.bookmark_border),
              onPressed: () {},
            ),
        ],
      ),
      backgroundColor: MfwColours.inputFill,
      body: damaged
          ? ListView(
              padding: const EdgeInsets.all(MfwSpace.lg),
              children: <Widget>[
                _Notice(messageFor(const AppFailure(FailureCode.fileCorrupt))),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Download it again'),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Container(
                      width: 300,
                      height: 424,
                      padding: const EdgeInsets.all(MfwSpace.xl),
                      decoration: BoxDecoration(
                        color: MfwColours.surface,
                        border: Border.all(color: MfwColours.divider),
                      ),
                      child: ExcludeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Page 7', style: MfwType.small),
                            const SizedBox(height: MfwSpace.lg),
                            const _Skeleton(width: 180, height: 18),
                            const SizedBox(height: MfwSpace.sm),
                            for (int i = 0; i < 9; i++)
                              _Skeleton(width: i.isEven ? 236 : 210, height: 8),
                            const SizedBox(height: MfwSpace.md),
                            const _Picture(width: 236, height: 96),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: MfwColours.surface,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MfwSpace.sm,
                      ),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            tooltip: 'Previous page',
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {},
                          ),
                          Expanded(
                            child: Slider(
                              value: 7,
                              min: 1,
                              max: 64,
                              label: 'Page 7',
                              semanticFormatterCallback: (double v) =>
                                  'Page ${v.round()} of 64',
                              onChanged: (_) {},
                            ),
                          ),
                          Text('7 / 64', style: MfwType.small),
                          IconButton(
                            tooltip: 'Next page',
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// SCR-A-15.

class _Downloads extends StatelessWidget {
  const _Downloads({this.empty = false, this.failed = false});

  final bool empty;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    Widget delete() => IconButton(
      tooltip: DownloadsText.deleteDownload,
      icon: const Icon(Icons.delete_outline),
      onPressed: () {},
    );
    return _TabPage(
      tab: _Tab.downloads,
      title: DownloadsText.title,
      body: empty
          ? const _Empty(
              icon: Icons.download_outlined,
              heading: DownloadsText.empty,
              text: 'Download an issue to read it without a connection.',
            )
          : ListView(
              padding: const EdgeInsets.all(MfwSpace.lg),
              children: <Widget>[
                Text(
                  '3 issues · ${DownloadsText.sizeLabel(142600000)} on this device',
                  style: MfwType.small,
                ),
                const SizedBox(height: MfwSpace.sm),
                if (failed) ...<Widget>[
                  _IssueRow(
                    'Sample issue 12',
                    DownloadsText.failedNetwork,
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text(DownloadsText.retry),
                    ),
                  ),
                  const Divider(),
                ],
                _IssueRow(
                  'Sample issue 11',
                  DownloadsText.size(46100000),
                  trailing: delete(),
                ),
                _IssueRow(
                  'Sample issue 10',
                  DownloadsText.size(51300000),
                  trailing: delete(),
                ),
                _IssueRow(
                  'Sample issue 09',
                  DownloadsText.size(45200000),
                  trailing: delete(),
                ),
              ],
            ),
    );
  }
}

// SCR-A-16 and SCR-A-17: two views of one screen (SN-05).

class _Library extends StatelessWidget {
  const _Library({required this.tab, this.empty = false});

  final int tab;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: tab,
      child: _TabPage(
        tab: _Tab.library,
        title: 'Library',
        bottom: const TabBar(
          tabs: <Widget>[
            Tab(text: 'Bookmarks'),
            Tab(text: 'Favourites'),
          ],
        ),
        body: empty
            ? const _Empty(
                icon: Icons.bookmark_border,
                heading: 'No bookmarks yet',
                text: 'Bookmark a page in the reader to come back to it.',
              )
            : ListView(
                padding: const EdgeInsets.all(MfwSpace.lg),
                children: tab == 0
                    ? const <Widget>[
                        _IssueRow('Sample issue 12', 'Page 7'),
                        _IssueRow('Sample issue 11', 'Page 12'),
                        _IssueRow('Sample issue 09', 'Page 3'),
                      ]
                    : const <Widget>[
                        _IssueRow('Sample issue 10', 'Category A · 56 pages'),
                        _IssueRow('Sample issue 08', 'Category B · 60 pages'),
                      ],
              ),
      ),
    );
  }
}

// SCR-A-18.

enum _NewsState { data, loading, emptyCategory, unreachable }

class _News extends StatelessWidget {
  const _News({this.state = _NewsState.data});

  final _NewsState state;

  @override
  Widget build(BuildContext context) {
    final bool categoryChosen = state == _NewsState.emptyCategory;
    final Widget chips = Wrap(
      spacing: MfwSpace.sm,
      children: <Widget>[
        for (final (String label, bool on) in <(String, bool)>[
          ('All', !categoryChosen),
          ('Category A', false),
          ('Category B', categoryChosen),
        ])
          FilterChip(label: Text(label), selected: on, onSelected: (_) {}),
      ],
    );
    const List<Widget> rows = <Widget>[
      _NewsRow(
        'Sample breaking article',
        '21 March 2026 · Category A',
        breaking: true,
      ),
      _NewsRow('Sample article four', '18 March 2026 · Category A'),
      _NewsRow('Sample article three', '16 March 2026 · Category A'),
      _NewsRow('Sample article two', '12 March 2026 · Category A'),
    ];
    return _TabPage(
      tab: _Tab.news,
      title: 'News',
      body: switch (state) {
        _NewsState.loading => const _Loading(label: 'Loading the news'),
        _NewsState.emptyCategory => ListView(
          padding: const EdgeInsets.all(MfwSpace.lg),
          children: <Widget>[
            chips,
            const _Empty(
              icon: Icons.article_outlined,
              heading: 'No news in this category yet',
              text: 'Choose another category, or come back later.',
            ),
          ],
        ),
        _NewsState.unreachable => ListView(
          padding: const EdgeInsets.all(MfwSpace.lg),
          children: <Widget>[
            const _Notice(
              'The news site cannot be reached. These are the articles '
              'loaded before.',
              kind: _NoticeKind.offline,
              action: _Retry(),
            ),
            chips,
            const SizedBox(height: MfwSpace.sm),
            ...rows.take(2),
          ],
        ),
        _NewsState.data => ListView(
          padding: const EdgeInsets.all(MfwSpace.lg),
          children: <Widget>[
            chips,
            const SizedBox(height: MfwSpace.sm),
            ...rows,
          ],
        ),
      },
    );
  }
}

// SCR-A-19.

class _Article extends StatelessWidget {
  const _Article({this.offline = false});

  final bool offline;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'News',
      actions: <Widget>[
        IconButton(
          tooltip: 'Save for reading offline',
          icon: const Icon(Icons.bookmark_add_outlined),
          onPressed: () {},
        ),
        IconButton(
          tooltip: 'Share',
          icon: const Icon(Icons.share_outlined),
          onPressed: () {},
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          if (offline)
            const _Notice(
              'You are offline. This article was loaded earlier.',
              kind: _NoticeKind.offline,
            ),
          Text('CATEGORY A', style: MfwType.label),
          const SizedBox(height: MfwSpace.sm),
          Text('Sample breaking article', style: MfwType.h2),
          const SizedBox(height: MfwSpace.xs),
          Text('21 March 2026', style: MfwType.small),
          const SizedBox(height: MfwSpace.lg),
          const _Picture(height: 200),
          const SizedBox(height: MfwSpace.lg),
          for (int i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: MfwSpace.lg),
              child: Text(
                'Synthetic paragraph ${i + 1} of the article. The body is '
                'shown as WordPress sent it, without running any script, '
                'and links open outside the app.',
                style: MfwType.body,
              ),
            ),
        ],
      ),
    );
  }
}

// SCR-A-22.

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Not found',
      body: _Empty(
        icon: Icons.help_outline,
        heading: 'This page does not exist',
        text: 'The link may be old, or the item may have been removed.',
        action: FilledButton(onPressed: () {}, child: const Text('Go to home')),
      ),
    );
  }
}
