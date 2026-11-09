import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';

import 'brand.dart';

import 'model.dart';

/// Gives every screen the prototype's state.
class Proto extends InheritedNotifier<ProtoModel> {
  /// Creates the scope.
  const Proto({required ProtoModel model, required super.child, super.key})
    : super(notifier: model);

  /// The model, and a rebuild when it changes.
  static ProtoModel of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Proto>()!.notifier!;

  /// The model, without a rebuild, for use in callbacks.
  static ProtoModel read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<Proto>()!.notifier!;
}

/// A screen with the app's look and, while the walk-through needs it, its
/// inventory ID under the title, so that it can be ticked off against
/// SCREEN_INVENTORY_AND_NAVIGATION section 5.
class LofiScreen extends StatelessWidget {
  /// Creates the screen.
  const LofiScreen({
    required this.id,
    required this.title,
    required this.body,
    this.titleWidget,
    this.actions = const <Widget>[],
    this.bottom,
    this.floating,
    this.background,
    super.key,
  });

  /// The SCR-A-nn ID.
  final String id;

  /// The screen title.
  final String title;

  /// Drawn in place of [title], for example the logo on Home.
  final Widget? titleWidget;

  /// The content.
  final Widget body;

  /// App bar actions.
  final List<Widget> actions;

  /// Shown under the app bar, for example tabs.
  final PreferredSizeWidget? bottom;

  /// A floating action button.
  final Widget? floating;

  /// The page ground, when not the surface colour.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final Widget heading = titleWidget ?? Text(title);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: model.showIds
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  heading,
                  Text(id, style: MfwType.small),
                ],
              )
            : heading,
        actions: <Widget>[...actions, const ControlsButton()],
        bottom: bottom,
      ),
      body: Column(
        children: <Widget>[
          if (!model.online) const OfflineBanner(),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floating,
    );
  }
}

/// The FR-STATE-003 notice.
class OfflineBanner extends StatelessWidget {
  /// Creates the banner.
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Notice(
      'No connection. Downloaded issues are still available.',
      kind: NoticeKind.offline,
      margin: EdgeInsets.zero,
    );
  }
}

/// A placeholder for MFW content, which the prototype never shows
/// (DEC-024): a cover, a page, a picture or a block of text.
class GreyBox extends StatelessWidget {
  /// Creates the box.
  const GreyBox({
    required this.label,
    this.width,
    this.height,
    this.aspectRatio,
    this.icon,
    super.key,
  });

  /// What the box stands for.
  final String label;

  /// Fixed width.
  final double? width;

  /// Fixed height.
  final double? height;

  /// Width over height, when no height is given.
  final double? aspectRatio;

  /// The icon; by default a book for a cover and none for the rest.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ContentPlaceholder(
      label: label,
      width: width,
      height: height,
      aspectRatio: aspectRatio,
      icon: icon ?? (label == 'Cover' ? Icons.menu_book_outlined : null),
    );
  }
}

/// The loading, empty and no-network views (FR-STATE-001 to 003).
class StateView extends StatelessWidget {
  /// Creates the view for [content], or for no network when [offline].
  const StateView({
    required this.content,
    required this.emptyText,
    required this.child,
    this.offline = false,
    this.emptyIcon = Icons.inbox_outlined,
    super.key,
  });

  /// What to show.
  final Content content;

  /// The empty-state text for this screen.
  final String emptyText;

  /// The normal view.
  final Widget child;

  /// The screen needs the network and there is none.
  final bool offline;

  /// The icon of the empty state.
  final IconData emptyIcon;

  @override
  Widget build(BuildContext context) {
    if (offline) {
      return Message(
        icon: Icons.cloud_off_outlined,
        text: 'This needs a connection.',
        detail: 'Issues you downloaded are still on this device.',
        action: 'Try again',
        onAction: () => Proto.of(context).online = true,
      );
    }
    return switch (content) {
      Content.loading => const LoadingSkeleton(label: 'Loading'),
      Content.empty => Message(icon: emptyIcon, text: emptyText),
      Content.normal => child,
    };
  }
}

/// A centred message with an optional action, drawn as the frames' empty
/// state.
class Message extends StatelessWidget {
  /// Creates the message.
  const Message({
    required this.icon,
    required this.text,
    this.detail,
    this.action,
    this.onAction,
    super.key,
  });

  /// The icon.
  final IconData icon;

  /// The message, drawn as the heading.
  final String text;

  /// One line under it.
  final String? detail;

  /// The action label.
  final String? action;

  /// The action.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final String? label = action;
    return EmptyState(
      icon: icon,
      heading: text,
      text: detail,
      action: label == null
          ? null
          : FilledButton(onPressed: onAction, child: Text(label)),
    );
  }
}

/// Opens the prototype controls.
class ControlsButton extends StatelessWidget {
  /// Creates the button.
  const ControlsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Prototype controls',
      icon: const Icon(Icons.tune),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) => const ControlsSheet(),
      ),
    );
  }
}

/// The prototype controls: not part of the app. They switch the states
/// that SCREEN_INVENTORY_AND_NAVIGATION sections 3 and 7 list.
class ControlsSheet extends StatelessWidget {
  /// Creates the sheet.
  const ControlsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (BuildContext context, ScrollController scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(
              'Prototype controls (not part of the app)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text('Access state'),
            _choices<Access>(
              Access.values,
              model.access,
              (Access a) => a.label,
              (Access a) => model.access = a,
            ),
            const Text('Content screens show'),
            _choices<Content>(
              Content.values,
              model.content,
              (Content c) => c.label,
              (Content c) => model.content = c,
            ),
            const Text('The next download'),
            _choices<DownloadOutcome>(
              DownloadOutcome.values,
              model.outcome,
              (DownloadOutcome o) => o.label,
              (DownloadOutcome o) => model.outcome = o,
            ),
            SwitchListTile(
              title: const Text('Show screen IDs'),
              value: model.showIds,
              onChanged: (bool on) => model.showIds = on,
            ),
            SwitchListTile(
              title: const Text('Network connection'),
              value: model.online,
              onChanged: (bool on) => model.online = on,
            ),
            SwitchListTile(
              title: const Text('On mobile data'),
              value: model.mobileData,
              onChanged: (bool on) => model.mobileData = on,
            ),
            SwitchListTile(
              title: const Text('News site reachable'),
              value: model.newsReachable,
              onChanged: (bool on) => model.newsReachable = on,
            ),
            SwitchListTile(
              title: const Text('Low storage on the device'),
              value: model.lowStorage,
              onChanged: (bool on) => model.lowStorage = on,
            ),
            SwitchListTile(
              title: const Text('Next issue file is damaged'),
              value: model.damagedFile,
              onChanged: (bool on) => model.damagedFile = on,
            ),
            SwitchListTile(
              title: const Text('Linked issue is unpublished'),
              value: model.unpublished,
              onChanged: (bool on) => model.unpublished = on,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Tap a notification for an issue'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/issues/i12');
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_off),
              title: const Text('Open an unknown link'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/no-such-page');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _choices<T>(
    List<T> values,
    T selected,
    String Function(T) label,
    void Function(T) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: <Widget>[
          for (final T value in values)
            ChoiceChip(
              label: Text(label(value)),
              selected: value == selected,
              onSelected: (_) => onSelected(value),
            ),
        ],
      ),
    );
  }
}
