import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import 'notification_text.dart';

/// The settings entry that opens SCR-A-21, for SCR-A-07's notifications
/// slot (MOD11-P2-T02).
class NotificationSettingsTile extends StatelessWidget {
  /// Creates the entry.
  const NotificationSettingsTile({super.key, required this.onOpen});

  /// Opens the notification choices.
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(
      Icons.notifications_outlined,
      color: MfwColours.heading,
    ),
    title: const Text(NotificationText.title),
    subtitle: const Text(NotificationText.settingsLine),
    trailing: const Icon(Icons.chevron_right, color: MfwColours.body),
    onTap: onOpen,
  );
}
