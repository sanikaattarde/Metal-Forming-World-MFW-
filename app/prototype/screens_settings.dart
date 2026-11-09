import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';

import 'model.dart';
import 'screens_auth.dart';
import 'widgets.dart';

/// SCR-A-07, with the notification categories of SCR-A-21 in it. Signed
/// out, it has fewer items (OQ-09).
class SettingsScreen extends StatelessWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  void _push(BuildContext context, Widget screen) => unawaited(
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext context) => screen),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    final bool signedIn = model.access != Access.signedOut;
    return LofiScreen(
      id: 'SCR-A-07',
      title: 'Settings',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: MfwSpace.lg),
        children: <Widget>[
          const _Section('Notifications'),
          if (!model.notificationsExplained)
            _Tile(
              'Turn on notifications',
              icon: Icons.notifications_none,
              onTap: () =>
                  _push(context, const NotificationExplanationScreen()),
            )
          else
            for (final MapEntry<String, bool> category
                in model.notificationCategories.entries)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(category.key),
                value: category.value,
                onChanged: (bool on) => model.setCategory(category.key, on),
              ),
          const _Section('Reading'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Plain swipe reading'),
            subtitle: const Text('Off: page-turn mode (GS-Q55)'),
            value: model.swipeMode,
            onChanged: (bool on) => model.swipeMode = on,
          ),
          const _Section('Account'),
          if (signedIn) ...<Widget>[
            _Tile(
              'Your profile',
              icon: Icons.person_outline,
              onTap: () => _push(context, const ProfileScreen()),
            ),
            _Tile('Sign out', icon: Icons.logout, onTap: model.signOut),
            _Tile(
              'Delete account',
              icon: Icons.delete_outline,
              onTap: () => _push(context, const DeleteAccountScreen()),
            ),
          ] else
            _Tile(
              'Sign in or create an account',
              icon: Icons.login,
              onTap: () => unawaited(ensureFullAccess(context)),
            ),
          const _Section('About'),
          _Tile(
            'Privacy policy',
            icon: Icons.open_in_new,
            onTap: () =>
                _push(context, const _PolicyScreen(title: 'Privacy policy')),
          ),
          _Tile(
            'Terms of use',
            icon: Icons.open_in_new,
            onTap: () =>
                _push(context, const _PolicyScreen(title: 'Terms of use')),
          ),
          const SizedBox(height: MfwSpace.lg),
        ],
      ),
    );
  }
}

/// A settings group label, as the account frames draw it.
class _Section extends StatelessWidget {
  const _Section(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: MfwSpace.xl, bottom: MfwSpace.sm),
    child: Semantics(
      header: true,
      child: Text(
        label.toUpperCase(),
        style: MfwType.label.copyWith(color: MfwColours.heading),
      ),
    ),
  );
}

/// A settings row, as the account frames draw it.
class _Tile extends StatelessWidget {
  const _Tile(this.label, {required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: MfwColours.heading),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: MfwColours.body),
      onTap: onTap,
    );
  }
}

class _PolicyScreen extends StatelessWidget {
  const _PolicyScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return LofiScreen(
      id: 'FR-PRIV-002',
      title: title,
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          for (int part = 1; part <= 5; part++)
            Padding(
              padding: const EdgeInsets.only(bottom: MfwSpace.md),
              child: Text(
                '$title, part $part. The text is MFW\'s, published on its '
                'website, and the app links to it (FR-PRIV-002).',
                style: MfwType.body,
              ),
            ),
        ],
      ),
    );
  }
}

/// SCR-A-08: confirm, then immediate deletion (GS-Q50). The sign-in must be
/// recent (OP-12), so the password is asked again.
class DeleteAccountScreen extends StatelessWidget {
  /// Creates the screen.
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return LofiScreen(
      id: 'SCR-A-08',
      title: 'Delete account',
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          Text(
            'Deleting your account removes your profile, bookmarks, '
            'favourites, notification choices and downloaded issues at '
            'once. It cannot be undone.',
            style: MfwType.body,
          ),
          const SizedBox(height: MfwSpace.lg),
          FilledButton(
            onPressed: () {
              model.signOut(deleteAccount: true);
              Navigator.of(context).popUntil((Route<void> r) => r.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Your account was deleted.')),
              );
            },
            child: const Text('Delete my account'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep my account'),
          ),
        ],
      ),
    );
  }
}

/// SCR-A-20: shown before the system permission prompt. Visitors can
/// accept notifications (GS-Q46; OQ-09 stays open).
class NotificationExplanationScreen extends StatelessWidget {
  /// Creates the screen.
  const NotificationExplanationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return LofiScreen(
      id: 'SCR-A-20',
      title: 'Stay up to date',
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          const SizedBox(height: MfwSpace.xl),
          const Icon(
            Icons.notifications_outlined,
            size: 64,
            color: MfwColours.heading,
            semanticLabel: 'Notifications',
          ),
          const SizedBox(height: MfwSpace.xl),
          Text(
            'MFW can tell you when a new issue is out, about expo specials '
            'and about major news. You choose which, and you can change it '
            'in Settings at any time.',
            style: MfwType.body,
          ),
          const SizedBox(height: MfwSpace.lg),
          Text(
            'Your phone asks next whether to allow notifications.',
            style: MfwType.body,
          ),
          const SizedBox(height: MfwSpace.lg),
          FilledButton(
            onPressed: () async {
              final NavigatorState navigator = Navigator.of(context);
              await showDialog<void>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('System prompt (iOS or Android)'),
                  content: const Text('Allow notifications?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Allow'),
                    ),
                  ],
                ),
              );
              model.notificationsExplained = true;
              navigator.pop();
            },
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not now'),
          ),
        ],
      ),
    );
  }
}

/// SCR-A-22, for any unknown route.
class NotFoundScreen extends StatelessWidget {
  /// Creates the screen.
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LofiScreen(
      id: 'SCR-A-22',
      title: 'Not found',
      body: Message(
        icon: Icons.help_outline,
        text: 'This page does not exist',
        detail: 'The link may be old, or the item may have been removed.',
        action: 'Go to home',
        onAction: () =>
            Navigator.of(context).popUntil((Route<void> r) => r.isFirst),
      ),
    );
  }
}
