// The look of the design frames (MOD16-P1-T02 in
// test/design/reader_frames.dart, MOD16-P1-T03 in
// test/design/account_frames.dart), as public widgets for the branded
// prototype. The frames keep theirs private, so these follow them; if a
// frame changes, the matching widget here follows it.

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';

/// The logo stays a placeholder: MFW's file stays out of the repository
/// (DEC-024).
class LogoPlaceholder extends StatelessWidget {
  /// Creates the placeholder.
  const LogoPlaceholder({super.key});

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
class SectionHeading extends StatelessWidget {
  /// Creates the heading, with an optional [trailing] action on its line.
  const SectionHeading(this.text, {this.trailing, super.key});

  /// The heading.
  final String text;

  /// An action on the same line, for example "See all".
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: MfwSpace.xl, bottom: MfwSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Semantics(
              header: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(text.toUpperCase(), style: MfwType.label),
                  const SizedBox(height: MfwSpace.xs),
                  Container(width: 32, height: 2, color: MfwColours.action),
                ],
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A placeholder for MFW content that is not drawn: a cover, a page, an
/// article picture or text. A cover gets the book icon, a picture the image
/// icon.
class ContentPlaceholder extends StatelessWidget {
  /// Creates the placeholder.
  const ContentPlaceholder({
    required this.label,
    this.width,
    this.height,
    this.aspectRatio,
    this.icon,
    super.key,
  });

  /// What it stands for, shown small under the icon. Empty for none.
  final String label;

  /// Fixed width.
  final double? width;

  /// Fixed height.
  final double? height;

  /// Width over height, when no height is given.
  final double? aspectRatio;

  /// The icon; none for a text block.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final IconData? glyph = icon;
    final Widget box = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MfwColours.inputFill,
        border: Border.all(color: MfwColours.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (glyph != null) Icon(glyph, color: MfwColours.body),
          if (label.isNotEmpty) ...<Widget>[
            if (glyph != null) const SizedBox(height: MfwSpace.xs),
            Text(label, style: MfwType.small, textAlign: TextAlign.center),
          ],
        ],
      ),
    );
    final double? ratio = aspectRatio;
    return ratio == null ? box : AspectRatio(aspectRatio: ratio, child: box);
  }
}

/// The kinds of [Notice].
enum NoticeKind {
  /// Something failed.
  error,

  /// No connection, or a site that does not answer.
  offline,

  /// A note.
  info,
}

/// A notice: a bar in the error, warning or divider colour, an icon and the
/// message in a dark colour, so colour is never the only signal
/// (DESIGN_TOKENS.md sections 3.2 and 5).
class Notice extends StatelessWidget {
  /// Creates the notice.
  const Notice(
    this.text, {
    this.kind = NoticeKind.error,
    this.action,
    this.margin = const EdgeInsets.only(bottom: MfwSpace.lg),
    super.key,
  });

  /// The message.
  final String text;

  /// Its kind.
  final NoticeKind kind;

  /// An action at the end, for example Retry.
  final Widget? action;

  /// Space around it.
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final (Color edge, IconData icon, String label) = switch (kind) {
      NoticeKind.error => (MfwColours.error, Icons.error_outline, 'Problem'),
      NoticeKind.offline => (
        MfwColours.warning,
        Icons.cloud_off_outlined,
        'Offline',
      ),
      NoticeKind.info => (MfwColours.divider, Icons.info_outline, 'Note'),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: margin,
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
      ),
    );
  }
}

/// An empty or blocked state: an icon, a heading, an optional line and an
/// optional action.
class EmptyState extends StatelessWidget {
  /// Creates the state.
  const EmptyState({
    required this.icon,
    required this.heading,
    this.text,
    this.action,
    super.key,
  });

  /// The icon.
  final IconData icon;

  /// The heading.
  final String heading;

  /// One line under the heading.
  final String? text;

  /// An action under it.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final String? line = text;
    final Widget? button = action;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MfwSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: MfwColours.body),
            const SizedBox(height: MfwSpace.lg),
            Text(heading, style: MfwType.h3, textAlign: TextAlign.center),
            if (line != null) ...<Widget>[
              const SizedBox(height: MfwSpace.sm),
              Text(line, style: MfwType.body, textAlign: TextAlign.center),
            ],
            if (button != null) ...<Widget>[
              const SizedBox(height: MfwSpace.lg),
              button,
            ],
          ],
        ),
      ),
    );
  }
}

/// Grey blocks that stand for content while it loads, under a thin
/// progress bar.
class LoadingSkeleton extends StatelessWidget {
  /// Creates the view; [label] is spoken for the progress bar.
  const LoadingSkeleton({required this.label, super.key});

  /// What is loading.
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        LinearProgressIndicator(semanticsLabel: label),
        const SizedBox(height: MfwSpace.xl),
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Block(width: 120, height: 160),
            SizedBox(width: MfwSpace.lg),
            Expanded(
              child: Column(
                children: <Widget>[
                  _Block(height: 24),
                  _Block(height: 16),
                  _Block(height: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: MfwSpace.xl),
        for (int i = 0; i < 4; i++) ...<Widget>[
          const _Block(height: 20),
          const _Block(width: 160, height: 14),
          const SizedBox(height: MfwSpace.md),
        ],
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({this.width, required this.height});

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

/// A row for an issue: a small cover, the title and a line under it.
class IssueRow extends StatelessWidget {
  /// Creates the row.
  const IssueRow({
    required this.title,
    required this.meta,
    this.trailing,
    this.onTap,
    this.horizontalPadding = MfwSpace.lg,
    super.key,
  });

  /// The title.
  final String title;

  /// The line under it.
  final String meta;

  /// At the end, for example a downloaded mark.
  final Widget? trailing;

  /// Opens the issue.
  final VoidCallback? onTap;

  /// Space at the sides; none inside a list that has its own.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: MfwSpace.sm,
        ),
        child: Row(
          children: <Widget>[
            const ContentPlaceholder(
              label: '',
              width: 54,
              height: 72,
              icon: Icons.menu_book_outlined,
            ),
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
      ),
    );
  }
}

/// A row for an article: a picture, an optional breaking label, the title
/// and a line under it.
class NewsRow extends StatelessWidget {
  /// Creates the row.
  const NewsRow({
    required this.title,
    required this.meta,
    this.breaking = false,
    this.onTap,
    this.horizontalPadding = MfwSpace.lg,
    super.key,
  });

  /// The title.
  final String title;

  /// The line under it.
  final String meta;

  /// Breaking news (a placeholder until OQ-17).
  final bool breaking;

  /// Opens the article.
  final VoidCallback? onTap;

  /// Space at the sides; none inside a list that has its own.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: MfwSpace.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const ContentPlaceholder(
              label: '',
              width: 96,
              height: 72,
              icon: Icons.image_outlined,
            ),
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
      ),
    );
  }
}
