import 'package:flutter/material.dart';

import '../../../contracts/contracts.dart';
import '../../../core/errors/failure_messages.dart';
import 'account_text.dart';
import 'account_widgets.dart';

/// SCR-A-08, delete the account (MOD03-P4-T01; FR-AUTH-009, FR-PRIV-003,
/// FR-PRIV-004). PROVISIONAL: immediate deletion, nothing kept (DEC-029,
/// OQ-24).
///
/// This screen is the confirmation: the safe choice is the filled button,
/// and deleting is the outlined one in the error colour (review of #67).
/// When the backend asks for a recent sign-in, the password is asked again
/// first. After a deletion the reader is signed out, and the router's guard
/// leaves this screen.
class DeleteAccountScreen extends StatefulWidget {
  /// Creates the screen.
  const DeleteAccountScreen({
    super.key,
    required this.auth,
    required this.onKeep,
  });

  /// MOD-03.
  final AuthService auth;

  /// Leaves without deleting.
  final VoidCallback onKeep;

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _password = TextEditingController();
  bool _busy = false;
  bool _reauth = false;
  String? _notice;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  String _messageFor(AppFailure failure) => switch (failure.code) {
    FailureCode.conflict => AccountText.lastAdmin,
    FailureCode.forbidden => AccountText.alreadyDeleting,
    _ => messageFor(failure),
  };

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _notice = null;
    });
    if (_reauth) {
      final Result<void> confirmed = await widget.auth.reauthenticateWithEmail(
        password: _password.text,
      );
      _password.clear();
      if (confirmed case Err<void>(:final AppFailure failure)) {
        if (mounted) {
          setState(() {
            _busy = false;
            _notice = failure.code == FailureCode.unauthenticated
                ? AccountText.wrongCredentials
                : messageFor(failure);
          });
        }
        return;
      }
    }
    final Result<void> result = await widget.auth.deleteAccount();
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      if (result case Err<void>(:final AppFailure failure)) {
        if (failure.code == FailureCode.unauthenticated) {
          _reauth = true;
          _notice = AccountText.reauthNeeded;
        } else {
          _notice = _messageFor(failure);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AccountPage(
      title: AccountText.deleteAccount,
      onBack: _busy ? null : widget.onKeep,
      children: <Widget>[
        const AccountBody(AccountText.deleteBody),
        if (_notice != null) AccountNotice(_notice!),
        if (_reauth)
          AccountField(
            label: AccountText.password,
            controller: _password,
            obscure: true,
            enabled: !_busy,
            autofillHints: const <String>[AutofillHints.password],
          ),
        AccountPrimaryButton(
          AccountText.keepAccount,
          onPressed: _busy ? null : widget.onKeep,
        ),
        const AccountGap(12),
        AccountDestructiveButton(
          _reauth ? AccountText.confirmAndDelete : AccountText.deleteMyAccount,
          onPressed: _delete,
          busy: _busy,
        ),
      ],
    );
  }
}
