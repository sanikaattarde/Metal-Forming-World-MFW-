import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../contracts/contracts.dart';
import '../domain/link_opener.dart';
import 'account_text.dart';
import 'account_widgets.dart';

/// SCR-A-07, settings (MOD04-P2-T04): the reader's account (profile,
/// sign-out, deletion) or, for a visitor, sign-in; and MFW's policy, terms
/// and the open-source licences.
///
/// The notification choices (SCR-A-21, MOD11-P2-T02) and the reader-mode
/// setting (MOD-07) are slots the shell fills once those features exist;
/// until then they are left out rather than shown empty.
class SettingsScreen extends StatefulWidget {
  /// Creates the screen.
  const SettingsScreen({
    super.key,
    required this.auth,
    required this.links,
    required this.onOpenProfile,
    required this.onSignIn,
    required this.onDeleteAccount,
    this.privacyPolicy,
    this.termsOfUse,
    this.notifications,
    this.readerMode,
  });

  /// MOD-03.
  final AuthService auth;

  /// Opens the policy pages.
  final LinkOpener links;

  /// Opens SCR-A-06.
  final VoidCallback onOpenProfile;

  /// Opens SCR-A-01.
  final VoidCallback onSignIn;

  /// Opens SCR-A-08.
  final VoidCallback onDeleteAccount;

  /// CFG-07, or null when not set.
  final Uri? privacyPolicy;

  /// CFG-07, or null when not set.
  final Uri? termsOfUse;

  /// SCR-A-21 inside settings, once MOD11-P2-T02 provides it.
  final Widget? notifications;

  /// The reader-mode setting, once MOD-07 provides it.
  final Widget? readerMode;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Stream<AuthSession?> _session = widget.auth.watchSession();
  bool _busy = false;
  String? _notice;

  Future<void> _open(Uri uri) async {
    final bool opened = await widget.links.open(uri);
    if (mounted) {
      setState(() => _notice = opened ? null : AccountText.linkFailed);
    }
  }

  Future<void> _signOut() async {
    setState(() => _busy = true);
    await widget.auth.signOut();
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthSession?>(
      stream: _session,
      builder: (BuildContext context, AsyncSnapshot<AuthSession?> snapshot) {
        final bool signedIn = snapshot.data != null;
        final bool known = snapshot.connectionState != ConnectionState.waiting;
        return AccountPage(
          title: AccountText.settingsTitle,
          children: <Widget>[
            if (_notice != null) AccountNotice(_notice!),
            ?widget.notifications,
            ?widget.readerMode,
            const _Section(AccountText.accountSection),
            if (!known)
              const LinearProgressIndicator(semanticsLabel: 'Loading')
            else if (signedIn) ...<Widget>[
              _Tile(
                AccountText.yourProfile,
                icon: Icons.person_outline,
                onTap: widget.onOpenProfile,
              ),
              _Tile(
                AccountText.signOut,
                icon: Icons.logout,
                onTap: _busy ? null : _signOut,
              ),
              _Tile(
                AccountText.deleteAccount,
                icon: Icons.delete_outline,
                onTap: widget.onDeleteAccount,
              ),
            ] else
              _Tile(
                AccountText.signInOrRegister,
                icon: Icons.login,
                onTap: widget.onSignIn,
              ),
            const _Section(AccountText.aboutSection),
            _Tile(
              AccountText.privacyPolicy,
              icon: Icons.open_in_new,
              onTap: widget.privacyPolicy == null
                  ? null
                  : () => _open(widget.privacyPolicy!),
            ),
            _Tile(
              AccountText.termsOfUse,
              icon: Icons.open_in_new,
              onTap: widget.termsOfUse == null
                  ? null
                  : () => _open(widget.termsOfUse!),
            ),
            _Tile(
              AccountText.licences,
              icon: Icons.description_outlined,
              onTap: () => showLicensePage(context: context),
            ),
          ],
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: MfwSpace.xl, bottom: MfwSpace.sm),
    child: Semantics(
      header: true,
      child: Text(
        label,
        style: MfwType.label.copyWith(color: MfwColours.heading),
      ),
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, {required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      enabled: onTap != null,
      leading: Icon(icon, color: MfwColours.heading),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: MfwColours.body),
      onTap: onTap,
    );
  }
}
