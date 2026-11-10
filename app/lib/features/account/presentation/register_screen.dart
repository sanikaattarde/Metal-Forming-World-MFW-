import 'package:flutter/material.dart';

import '../../../contracts/contracts.dart';
import '../../../core/errors/failure_messages.dart';
import '../domain/account_rules.dart';
import 'account_text.dart';
import 'account_widgets.dart';

/// SCR-A-02, register with an email address and a password
/// (MOD03-P2-T01; FR-AUTH-001, FR-AUTH-002).
///
/// After a registration the access state becomes `emailUnverified`, and the
/// router's guard moves on to SCR-A-03, so this screen does not navigate.
class RegisterScreen extends StatefulWidget {
  /// Creates the screen.
  const RegisterScreen({
    super.key,
    required this.auth,
    required this.onSignIn,
    this.onBack,
  });

  /// MOD-03.
  final AuthService auth;

  /// Opens sign-in instead.
  final VoidCallback onSignIn;

  /// The back control's action, or null for none.
  final VoidCallback? onBack;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;
  String? _notice;
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
      _emailError = AccountRules.isEmail(email)
          ? null
          : AccountText.emailInvalid;
      _passwordError = AccountRules.isPasswordLongEnough(password)
          ? null
          : AccountText.passwordTooShort;
    });
    if (_emailError != null || _passwordError != null) {
      return;
    }
    setState(() => _busy = true);
    final Result<void> result = await widget.auth.registerWithEmail(
      email: email,
      password: password,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      if (result case Err<void>(:final AppFailure failure)) {
        if (failure.code == FailureCode.conflict) {
          _notice = AccountText.addressInUse;
          _emailError = AccountText.addressInUseField;
        } else {
          _notice = messageFor(failure);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AccountPage(
      title: AccountText.registerTitle,
      onBack: widget.onBack,
      children: <Widget>[
        if (_notice != null) AccountNotice(_notice!),
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
          hint: AccountText.passwordHint,
          obscure: true,
          enabled: !_busy,
          autofillHints: const <String>[AutofillHints.newPassword],
          onSubmitted: (_) => _submit(),
        ),
        const AccountGap(),
        AccountPrimaryButton(
          AccountText.registerButton,
          onPressed: _submit,
          busy: _busy,
        ),
        AccountLink(
          AccountText.toSignIn,
          onPressed: _busy ? null : widget.onSignIn,
        ),
      ],
    );
  }
}
