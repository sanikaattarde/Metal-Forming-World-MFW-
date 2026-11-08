import 'package:flutter/material.dart';
import 'package:mfw_prototype/model.dart';

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

/// A screen with its inventory ID in the app bar, so that a walk-through
/// can tick it off against SCREEN_INVENTORY_AND_NAVIGATION section 5.
class LofiScreen extends StatelessWidget {
  /// Creates the screen.
  const LofiScreen({
    required this.id,
    required this.title,
    required this.body,
    this.actions = const <Widget>[],
    this.bottom,
    this.floating,
    super.key,
  });

  /// The SCR-A-nn ID.
  final String id;

  /// The screen title.
  final String title;

  /// The content.
  final Widget body;

  /// App bar actions.
  final List<Widget> actions;

  /// Shown under the app bar, for example tabs.
  final PreferredSizeWidget? bottom;

  /// A floating action button.
  final Widget? floating;

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title),
            Text(id, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
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
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Text(
          'No connection. Downloaded issues are still available.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// A grey box that stands for an image, a cover or a page.
class GreyBox extends StatelessWidget {
  /// Creates the box.
  const GreyBox({
    required this.label,
    this.width,
    this.height,
    this.aspectRatio,
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

  @override
  Widget build(BuildContext context) {
    final Widget box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(color: Colors.grey.shade500),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade800),
      ),
    );
    final double? ratio = aspectRatio;
    return ratio == null ? box : AspectRatio(aspectRatio: ratio, child: box);
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

  @override
  Widget build(BuildContext context) {
    if (offline) {
      return Message(
        icon: Icons.cloud_off,
        text: 'This needs a connection.',
        action: 'Try again',
        onAction: () => Proto.of(context).online = true,
      );
    }
    return switch (content) {
      Content.loading => Center(
        child: Semantics(
          label: 'Loading',
          child: const CircularProgressIndicator(),
        ),
      ),
      Content.empty => Message(icon: Icons.inbox_outlined, text: emptyText),
      Content.normal => child,
    };
  }
}

/// A centred message with an optional action.
class Message extends StatelessWidget {
  /// Creates the message.
  const Message({
    required this.icon,
    required this.text,
    this.action,
    this.onAction,
    super.key,
  });

  /// The icon.
  final IconData icon;

  /// The message.
  final String text;

  /// The action label.
  final String? action;

  /// The action.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final String? label = action;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            if (label != null) ...<Widget>[
              const SizedBox(height: 12),
              FilledButton(onPressed: onAction, child: Text(label)),
            ],
          ],
        ),
      ),
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
