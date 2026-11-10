import 'package:flutter/material.dart';

import '../../../contracts/contracts.dart';
import '../../../core/errors/failure_messages.dart';
import '../domain/profile_form.dart';
import 'account_text.dart';
import 'account_widgets.dart';
import 'profile_form_view.dart';

/// SCR-A-05, complete the mandatory profile (MOD04-P2-T01; FR-PROF-001 to
/// FR-PROF-005, BR-003). PROVISIONAL: the fields wait for OQ-01 to OQ-03.
///
/// When the profile is complete the access state becomes `fullAccess` and
/// the router's guard moves on, so this screen does not navigate. If the
/// reader has not accepted the policy and terms in this session (after a
/// restart, for example), the first save asks for it here too.
class CompleteProfileScreen extends StatefulWidget {
  /// Creates the screen.
  const CompleteProfileScreen({
    super.key,
    required this.forms,
    required this.profiles,
    this.consentLinks,
  });

  /// Loads the form.
  final ProfileForms forms;

  /// Saves the profile and the consent.
  final ProfileRepository profiles;

  /// The policy and terms links, under the consent action.
  final Widget? consentLinks;

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  Result<ProfileFormSpec>? _form;
  bool _busy = false;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _form = null);
    final Result<ProfileFormSpec> form = await widget.forms.loadForm();
    if (mounted) {
      setState(() => _form = form);
    }
  }

  Future<void> _save(ReaderProfile profile, {required bool consented}) async {
    setState(() {
      _busy = true;
      _notice = null;
    });
    if (consented) {
      await widget.profiles.recordConsent(
        ConsentRecord(
          agreedTo: 'privacy_policy,terms_of_use',
          agreedAt: DateTime.now().toUtc(),
        ),
      );
    }
    final Result<ProfileSaveResult> result = await widget.profiles
        .saveOwnProfile(profile);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      switch (result) {
        case Ok<ProfileSaveResult>(:final ProfileSaveResult value):
          if (value.status != ProfileStatus.complete) {
            _notice = AccountText.stillMissing;
          }
        case Err<ProfileSaveResult>(:final AppFailure failure):
          _notice = messageFor(failure);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Result<ProfileFormSpec>? form = _form;
    return AccountPage(
      title: AccountText.completeTitle,
      children: <Widget>[
        const AccountBody(AccountText.completeBody),
        if (_notice != null) AccountNotice(_notice!),
        switch (form) {
          null => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading'),
            ),
          ),
          Err<ProfileFormSpec>(:final AppFailure failure) => AccountNotice(
            messageFor(failure),
            onRetry: failure.retryable ? _load : null,
          ),
          Ok<ProfileFormSpec>(:final ProfileFormSpec value) => ProfileFormView(
            spec: value,
            submitLabel: AccountText.saveAndContinue,
            onSubmit: _save,
            busy: _busy,
            consentLinks: widget.consentLinks,
          ),
        },
      ],
    );
  }
}
