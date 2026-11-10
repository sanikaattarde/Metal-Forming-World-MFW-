import 'package:flutter/material.dart';

import '../../../contracts/contracts.dart';
import '../../../core/errors/failure_messages.dart';
import '../domain/account_rules.dart';
import 'account_text.dart';
import 'account_widgets.dart';

/// SCR-A-01, sign in with an email address and a password (MOD03-P2-T02;
/// FR-AUTH-003, SEC-CHK-17).
///
/// After a sign-in the access state changes and the router's guard moves
/// on, to the step still missing or back to where the reader was going, so
/// this screen does not navigate. Google Sign-In is not shown: it waits for
/// DEC-006 (MOD03-P3-T02).
class SignInScreen extends StatefulWidget {
  /// Creates the screen.
  const SignInScreen({
    super.key,
    required this.auth,
    required this.onRegister,
    required this.onForgotPassword,
    this.onBack,
  });

  /// MOD-03.
  final AuthService auth;

  /// Opens registration.
  final VoidCallback onRegister;

  /// Opens the password reset.
  final VoidCallback onForgotPassword;

  /// The back control's action, or null for none.
  final VoidCallback? onBack;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;
  String? _notice;
  bool _canRetry = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String email = _email.text;
    final String password = _password.text;
    setState(() {
      _notice = null;
      _canRetry = false;
      _emailError = AccountRules.isEmail(email)
          ? null
          : AccountText.emailInvalid;
      _passwordError = password.isEmpty ? AccountText.passwordMissing : null;
    });
    if (_emailError != null || _passwordError != null) {
      return;
    }
    setState(() => _busy = true);
    final Result<void> result = await widget.auth.signInWithEmail(
      email: email,
      password: password,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      if (result case Err<void>(:final AppFailure failure)) {
        _notice = failure.code == FailureCode.unauthenticated
            ? AccountText.wrongCredentials
            : messageFor(failure);
        _canRetry = failure.retryable;
        // The password is not kept after a failed attempt.
        _password.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AccountPage(
      title: AccountText.signInTitle,
      onBack: widget.onBack,
      children: <Widget>[
        const AccountBody(AccountText.signInBody),
        if (_notice != null)
          AccountNotice(_notice!, onRetry: _canRetry ? _submit : null),
        AccountField(
          label: AccountText.email,
          controller: _email,
          error: _emailError,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const <String>[AutofillHints.email],
        ),
        AccountField(
          label: AccountText.password,
          controller: _password,
          error: _passwordError,
          obscure: true,
          enabled: !_busy,
          autofillHints: const <String>[AutofillHints.password],
          onSubmitted: (_) => _submit(),
        ),
        AccountPrimaryButton(
          AccountText.signInButton,
          onPressed: _submit,
          busy: _busy,
        ),
        AccountLink(
          AccountText.forgotPassword,
          onPressed: _busy ? null : widget.onForgotPassword,
        ),
        const AccountGap(),
        AccountLink(
          AccountText.toRegister,
          onPressed: _busy ? null : widget.onRegister,
        ),
      ],
    );
  }
}
