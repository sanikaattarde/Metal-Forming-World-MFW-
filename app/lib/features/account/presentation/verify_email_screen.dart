import 'package:flutter/material.dart';

import '../../../contracts/contracts.dart';
import '../../../core/errors/failure_messages.dart';
import 'account_text.dart';
import 'account_widgets.dart';

/// SCR-A-03, verify the email address (MOD03-P2-T01; FR-AUTH-002, BR-002).
///
/// Once the address is verified the access state moves on and the router's
/// guard leaves this screen, so it does not navigate itself.
class VerifyEmailScreen extends StatefulWidget {
  /// Creates the screen.
  const VerifyEmailScreen({super.key, required this.auth});

  /// MOD-03.
  final AuthService auth;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _busy = false;
  String? _notice;
  bool _noticeIsSuccess = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _notice = null;
    });
    await action();
    if (mounted) {
      setState(() => _busy = false);
    }
  }

  void _show(String text, {bool success = false}) {
    if (mounted) {
      setState(() {
        _notice = text;
        _noticeIsSuccess = success;
      });
    }
  }

  Future<void> _checkVerified() => _run(() async {
    final Result<void> result = await widget.auth.reloadVerificationStatus();
    if (result case Err<void>(:final AppFailure failure)) {
      _show(messageFor(failure));
      return;
    }
    final AuthSession? session = await widget.auth.watchSession().first;
    if (session != null && !session.emailVerified) {
      _show(AccountText.notVerifiedYet);
    }
  });

  Future<void> _resend() => _run(() async {
    final Result<void> result = await widget.auth.resendVerificationEmail();
    switch (result) {
      case Ok<void>():
        _show(AccountText.resent, success: true);
      case Err<void>(:final AppFailure failure):
        _show(messageFor(failure));
    }
  });

  Future<void> _signOut() => _run(widget.auth.signOut);

  @override
  Widget build(BuildContext context) {
    return AccountPage(
      title: AccountText.verifyTitle,
      children: <Widget>[
        if (_notice != null) AccountNotice(_notice!, success: _noticeIsSuccess),
        const AccountBody(AccountText.verifyBody),
        AccountPrimaryButton(
          AccountText.verifiedButton,
          onPressed: _checkVerified,
          busy: _busy,
        ),
        AccountLink(AccountText.resend, onPressed: _busy ? null : _resend),
        AccountLink(AccountText.signOut, onPressed: _busy ? null : _signOut),
      ],
    );
  }
}
