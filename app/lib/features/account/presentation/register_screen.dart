import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../contracts/contracts.dart';
import '../../../core/errors/failure_messages.dart';
import '../domain/account_rules.dart';
import 'account_text.dart';
import 'account_widgets.dart';

/// SCR-A-02, register with an email address and a password
/// (MOD03-P2-T01; FR-AUTH-001, FR-AUTH-002), accepting the privacy policy
/// and the terms of use (MOD04-P2-T02; FR-PRIV-001, FR-PRIV-002).
///
/// The acceptance is required to register. It is noted with MOD-04 at once
/// ([ProfileRepository.recordConsent]) and stored, with the current
/// versions and the server's time, by the first profile save through OP-10
/// (PROPOSED; how consent is recorded is OQ-27).
///
/// After a registration the access state becomes `emailUnverified`, and the
/// router's guard moves on to SCR-A-03, so this screen does not navigate.
class RegisterScreen extends StatefulWidget {
  /// Creates the screen.
  const RegisterScreen({
    super.key,
    required this.auth,
    required this.onSignIn,
    this.profiles,
    this.policyLinks,
    this.onBack,
  });

  /// MOD-03.
  final AuthService auth;

  /// MOD-04, which keeps the acceptance for the first profile save. Null
  /// before Firebase has started.
  final ProfileRepository? profiles;

  /// The links to the policy and terms, under the acceptance.
  final Widget? policyLinks;

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
  bool _consented = false;
  String? _notice;
  String? _emailError;
  String? _passwordError;
  String? _consentError;

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
      _consentError = _consented ? null : AccountText.consentMissing;
    });
    if (_emailError != null || _passwordError != null || !_consented) {
      return;
    }
    setState(() => _busy = true);
    final Result<void> result = await widget.auth.registerWithEmail(
      email: email,
      password: password,
    );
    if (result is Ok<void>) {
      await widget.profiles?.recordConsent(
        ConsentRecord(
          agreedTo: 'privacy_policy,terms_of_use',
          agreedAt: DateTime.now().toUtc(),
        ),
      );
    }
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
        CheckboxListTile(
          value: _consented,
          onChanged: _busy
              ? null
              : (bool? value) => setState(() => _consented = value ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(AccountText.consent),
          subtitle: _consentError == null
              ? null
              : Text(
                  _consentError!,
                  style: MfwType.small.copyWith(color: MfwColours.error),
                ),
        ),
        ?widget.policyLinks,
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
