import 'package:flutter/material.dart';

import '../../../contracts/contracts.dart';
import '../../../core/errors/failure_messages.dart';
import '../domain/account_rules.dart';
import 'account_text.dart';
import 'account_widgets.dart';

/// SCR-A-04, ask for a password reset link (MOD03-P2-T02; FR-AUTH-004).
///
/// The same message whether or not an account uses the address (SC-21).
class PasswordResetScreen extends StatefulWidget {
  /// Creates the screen.
  const PasswordResetScreen({
    super.key,
    required this.auth,
    required this.onBackToSignIn,
  });

  /// MOD-03.
  final AuthService auth;

  /// Returns to sign-in.
  final VoidCallback onBackToSignIn;

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _email = TextEditingController();
  bool _busy = false;
  bool _sent = false;
  String? _notice;
  String? _emailError;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String email = _email.text;
    setState(() {
      _notice = null;
      _emailError = AccountRules.isEmail(email)
          ? null
          : AccountText.emailInvalid;
    });
    if (_emailError != null) {
      return;
    }
    setState(() => _busy = true);
    final Result<void> result = await widget.auth.sendPasswordReset(email);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      switch (result) {
        case Ok<void>():
          _sent = true;
        case Err<void>(:final AppFailure failure):
          _notice = messageFor(failure);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AccountPage(
      title: AccountText.resetTitle,
      onBack: widget.onBackToSignIn,
      children: <Widget>[
        if (_notice != null)
          AccountNotice(_notice!)
        else if (_sent)
          const AccountNotice(AccountText.resetSent, success: true)
        else
          const AccountBody(AccountText.resetBody),
        AccountField(
          label: AccountText.email,
          controller: _email,
          error: _emailError,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const <String>[AutofillHints.email],
          onSubmitted: (_) => _submit(),
        ),
        AccountPrimaryButton(
          _sent ? AccountText.resetAgainButton : AccountText.resetButton,
          onPressed: _submit,
          busy: _busy,
        ),
        AccountLink(
          AccountText.backToSignIn,
          onPressed: _busy ? null : widget.onBackToSignIn,
        ),
      ],
    );
  }
}
