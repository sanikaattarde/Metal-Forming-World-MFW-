import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../contracts/contracts.dart';
import '../../../core/ui/content_widgets.dart';
import '../data/device_notification_service.dart';
import '../domain/notification_documents.dart';
import 'notification_text.dart';

/// SCR-A-21 notification categories, part of SCR-A-07 (MOD11-P2-T02,
/// FR-NOTIF-002, FR-NOTIF-003, FR-NOTIF-006, FR-NOTIF-007), with SCR-A-20,
/// the explanation shown before the system's permission prompt
/// (FR-NOTIF-001), the first time.
///
/// Each switch saves at once. Visitors can choose too, on this device only
/// (GS-Q46; OQ-09 is OPEN). The three categories are the developers' seed
/// (GS-Q47; OQ-18 is OPEN).
class NotificationSettingsScreen extends StatefulWidget {
  /// Creates the screen.
  const NotificationSettingsScreen({
    super.key,
    required this.notifications,
    required this.onBack,
  });

  /// MOD-11 on this device.
  final DeviceNotificationService notifications;

  /// Back to settings.
  final VoidCallback onBack;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _loading = true;
  bool _explaining = false;
  bool _busy = false;
  String? _loadError;
  String? _saveError;
  PermissionOutcome _permission = PermissionOutcome.notDetermined;
  List<NotificationCategory> _categories = const <NotificationCategory>[];
  Set<String> _chosen = <String>{};

  DeviceNotificationService get _service => widget.notifications;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final PermissionOutcome permission = await _service.permission();
    final bool explained = await _service.explained();
    final Result<List<NotificationCategory>> categories = await _service
        .categories();
    final Result<NotificationPreferences> preferences = await _service
        .getPreferences();
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      _permission = permission;
      _explaining = !explained && permission == PermissionOutcome.notDetermined;
      if (categories is Ok<List<NotificationCategory>> &&
          preferences is Ok<NotificationPreferences>) {
        _categories = categories.value;
        _chosen = preferences.value.categoryIds.toSet();
      } else {
        _loadError = NotificationText.loadFailed;
      }
    });
  }

  Future<void> _allow() async {
    setState(() => _busy = true);
    final Result<PermissionOutcome> outcome = await _service
        .explainAndRequestPermission();
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _explaining = false;
      if (outcome is Ok<PermissionOutcome>) {
        _permission = outcome.value;
      }
    });
  }

  Future<void> _notNow() async {
    await _service.declineExplanation();
    if (mounted) {
      setState(() => _explaining = false);
    }
  }

  Future<void> _toggle(String categoryId, bool on) async {
    final Set<String> before = _chosen;
    final Set<String> after = on
        ? <String>{...before, categoryId}
        : (Set<String>.of(before)..remove(categoryId));
    setState(() {
      _busy = true;
      _saveError = null;
      _chosen = after;
    });
    final Result<void> saved = await _service.savePreferences(
      NotificationPreferences(
        optedIn: after.isNotEmpty,
        categoryIds: after.toList()..sort(),
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      if (saved is Err<void>) {
        _chosen = before;
        _saveError = NotificationText.saveFailed;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text(NotificationText.title),
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    if (_loading) {
      return const LoadingContent(label: NotificationText.loading);
    }
    if (_explaining) {
      return ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: <Widget>[
          const Icon(
            Icons.notifications_outlined,
            size: 48,
            color: MfwColours.heading,
          ),
          const SizedBox(height: MfwSpace.lg),
          Semantics(
            header: true,
            child: Text(
              NotificationText.explainHeading,
              style: MfwType.h3.copyWith(color: MfwColours.heading),
            ),
          ),
          const SizedBox(height: MfwSpace.md),
          const Text(NotificationText.explainBody, style: MfwType.body),
          const SizedBox(height: MfwSpace.xl),
          FilledButton(
            onPressed: _busy ? null : _allow,
            child: const Text(NotificationText.allow),
          ),
          const SizedBox(height: MfwSpace.sm),
          TextButton(
            onPressed: _busy ? null : _notNow,
            child: const Text(NotificationText.notNow),
          ),
        ],
      );
    }
    return ListView(
      padding: const EdgeInsets.all(MfwSpace.lg),
      children: <Widget>[
        if (_loadError != null)
          ContentNotice(
            _loadError!,
            action: TextButton(
              onPressed: _load,
              child: const Text(NotificationText.retry),
            ),
          ),
        if (_saveError != null) ContentNotice(_saveError!),
        if (_permission == PermissionOutcome.denied)
          const ContentNotice(NotificationText.blocked, kind: NoticeKind.info),
        if (_permission == PermissionOutcome.notDetermined)
          ContentNotice(
            NotificationText.notAllowed,
            kind: NoticeKind.info,
            action: TextButton(
              onPressed: _busy ? null : _allow,
              child: const Text(NotificationText.askAgain),
            ),
          ),
        if (!_service.signedIn)
          const ContentNotice(
            NotificationText.visitorNote,
            kind: NoticeKind.info,
          ),
        if (_loadError == null) ...<Widget>[
          const SectionHeading(NotificationText.chooseHeading),
          if (_categories.isEmpty)
            const Text(NotificationText.noCategories, style: MfwType.body),
          for (final NotificationCategory category in _categories)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(category.name),
              value: _chosen.contains(category.id),
              onChanged: _busy ? null : (bool on) => _toggle(category.id, on),
            ),
        ],
      ],
    );
  }
}
