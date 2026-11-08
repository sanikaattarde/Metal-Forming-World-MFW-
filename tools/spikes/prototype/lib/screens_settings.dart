import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mfw_prototype/model.dart';
import 'package:mfw_prototype/screens_auth.dart';
import 'package:mfw_prototype/widgets.dart';

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
        children: <Widget>[
          if (signedIn)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () => _push(context, const ProfileScreen()),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign in or create an account'),
              onTap: () => unawaited(ensureFullAccess(context)),
            ),
          const Divider(),
          const ListTile(
            title: Text('Notifications (SCR-A-21)'),
            subtitle: Text('Three fixed categories set by the developers'),
          ),
          if (!model.notificationsExplained)
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('Turn on notifications'),
              onTap: () =>
                  _push(context, const NotificationExplanationScreen()),
            )
          else
            for (final MapEntry<String, bool> category
                in model.notificationCategories.entries)
              SwitchListTile(
                title: Text(category.key),
                value: category.value,
                onChanged: (bool on) => model.setCategory(category.key, on),
              ),
          const Divider(),
          SwitchListTile(
            title: const Text('Plain swipe reading'),
            subtitle: const Text('Off: page-turn mode (GS-Q55)'),
            value: model.swipeMode,
            onChanged: (bool on) => model.swipeMode = on,
          ),
          ListTile(
            title: const Text('Privacy policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () =>
                _push(context, const _PolicyScreen(title: 'Privacy policy')),
          ),
          ListTile(
            title: const Text('Terms of use'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () =>
                _push(context, const _PolicyScreen(title: 'Terms of use')),
          ),
          if (signedIn) ...<Widget>[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: model.signOut,
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever_outlined),
              title: const Text('Delete account'),
              onTap: () => _push(context, const DeleteAccountScreen()),
            ),
          ],
        ],
      ),
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
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          for (int part = 1; part <= 5; part++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GreyBox(label: '$title, part $part', height: 64),
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
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Your account, profile, bookmarks, favourites and downloads are '
            'deleted at once. This cannot be undone.',
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Enter your password to confirm',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.black),
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
      title: 'Notifications',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Icon(Icons.notifications_active_outlined, size: 64),
          const SizedBox(height: 16),
          const Text(
            'We can tell you when a new issue is out, about expo specials '
            'and about major news. You choose which, and you can change '
            'it in Settings.',
          ),
          const SizedBox(height: 16),
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
        text: 'This page does not exist.',
        action: 'Go to Home',
        onAction: () =>
            Navigator.of(context).popUntil((Route<void> r) => r.isFirst),
      ),
    );
  }
}
