import 'package:flutter/material.dart';

import '../../app/theme/mfw_tokens.dart';

/// Parts shared by the reader-side screens (catalogue, home, library,
/// downloads, news), drawn as in `Documentation/design/READER_SCREEN_DESIGNS.md`
/// section 4. PROPOSED until MFW approves the screens at M2.

/// A section heading in the website's style: a small capital label and a
/// short red rule (`BRAND_REFERENCE.md` section 6).
class SectionHeading extends StatelessWidget {
  /// Creates the heading.
  const SectionHeading(this.text, {super.key});

  /// The heading text, shown in capitals.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: MfwSpace.xl, bottom: MfwSpace.md),
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
    );
  }
}

/// What a [ContentNotice] reports.
enum NoticeKind {
  /// A failure.
  error,

  /// No connection, or a site that cannot be reached.
  offline,

  /// Information.
  info,
}

/// A notice: a bar in the error, warning or divider colour, an icon and the
/// message in a dark colour, so colour is never the only signal
/// (`DESIGN_TOKENS.md` sections 3.2 and 5).
class ContentNotice extends StatelessWidget {
  /// Creates the notice.
  const ContentNotice(
    this.text, {
    this.kind = NoticeKind.error,
    this.action,
    super.key,
  });

  /// The message.
  final String text;

  /// What it reports.
  final NoticeKind kind;

  /// An action, such as Retry.
  final Widget? action;

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

/// An empty state: an icon, a heading and one line, with an optional action.
class EmptyState extends StatelessWidget {
  /// Creates the state.
  const EmptyState({
    required this.icon,
    required this.heading,
    required this.text,
    this.action,
    super.key,
  });

  /// The icon above the heading.
  final IconData icon;

  /// The heading.
  final String heading;

  /// One line under the heading.
  final String text;

  /// An action, such as clearing the filters.
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

/// An issue cover at [width], four to three tall. Shows a placeholder while
/// the image loads, when it fails, and when the issue has none.
class CoverImage extends StatelessWidget {
  /// Creates the cover.
  const CoverImage({
    required this.url,
    required this.semanticLabel,
    this.width = 96,
    this.showLabel = false,
    super.key,
  });

  /// The cover address, or null when the issue has none.
  final Uri? url;

  /// What a screen reader says, such as "Cover of Issue 12".
  final String semanticLabel;

  /// The width; the height follows.
  final double width;

  /// Whether the placeholder says "Cover" under its icon.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final Widget placeholder = _CoverPlaceholder(showLabel: showLabel);
    final Uri? address = url;
    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: width,
          height: width * 4 / 3,
          child: address == null
              ? placeholder
              : Image.network(
                  address.toString(),
                  fit: BoxFit.cover,
                  loadingBuilder: (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? progress,
                  ) => progress == null ? child : placeholder,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? _,
                  ) => placeholder,
                ),
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder({required this.showLabel});

  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MfwColours.inputFill,
        border: Border.all(color: MfwColours.divider),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.menu_book_outlined, color: MfwColours.body),
          if (showLabel) ...<Widget>[
            const SizedBox(height: MfwSpace.xs),
            Text('Cover', style: MfwType.small),
          ],
        ],
      ),
    );
  }
}

/// A loading state: a progress bar named [label] over grey blocks that
/// stand for the content.
class LoadingContent extends StatelessWidget {
  /// Creates the state.
  const LoadingContent({required this.label, super.key});

  /// What is loading, for screen readers.
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        LinearProgressIndicator(semanticsLabel: label),
        const SizedBox(height: MfwSpace.xl),
        for (int i = 0; i < 4; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: MfwSpace.lg),
            child: Row(
              children: <Widget>[
                Container(width: 54, height: 72, color: MfwColours.inputFill),
                const SizedBox(width: MfwSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(height: 18, color: MfwColours.inputFill),
                      const SizedBox(height: MfwSpace.sm),
                      Container(
                        width: 160,
                        height: 14,
                        color: MfwColours.inputFill,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
