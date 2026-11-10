import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../contracts/contracts.dart';
import '../../../core/errors/failure_messages.dart';
import '../domain/profile_form.dart';
import 'account_text.dart';
import 'account_widgets.dart';
import 'profile_form_view.dart';

/// SCR-A-06, the reader's own profile, and editing it with the same checks
/// as SCR-A-05 (MOD04-P2-T03; FR-PROF-006, FR-PROF-007). Saved through
/// OP-10 and read from the reader's own record, so a change shows on every
/// device. PROVISIONAL: the fields wait for OQ-01.
class ProfileScreen extends StatefulWidget {
  /// Creates the screen.
  const ProfileScreen({
    super.key,
    required this.forms,
    required this.profiles,
    this.email,
    this.onBack,
    this.consentLinks,
  });

  /// Loads the form and the saved values.
  final ProfileForms forms;

  /// Saves the profile.
  final ProfileRepository profiles;

  /// The account's address, shown to its owner only, or null.
  final String? email;

  /// The back control's action, or null for none.
  final VoidCallback? onBack;

  /// The policy and terms links, when the acceptance is asked.
  final Widget? consentLinks;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Result<ProfileFormSpec>? _form;
  bool _editing = false;
  bool _busy = false;
  String? _notice;
  bool _noticeIsSuccess = false;

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
    switch (result) {
      case Ok<ProfileSaveResult>(:final ProfileSaveResult value):
        setState(() {
          _busy = false;
          _editing = value.status != ProfileStatus.complete;
          _notice = _editing
              ? AccountText.stillMissing
              : AccountText.profileSaved;
          _noticeIsSuccess = !_editing;
        });
        if (!_editing) {
          await _load();
        }
      case Err<ProfileSaveResult>(:final AppFailure failure):
        setState(() {
          _busy = false;
          _notice = messageFor(failure);
          _noticeIsSuccess = false;
        });
    }
  }

  List<Widget> _view(ProfileFormSpec spec) {
    final ReaderProfile? profile = spec.current;
    String shown(Object? value) =>
        value == null || value == '' ? AccountText.notGiven : '$value';
    String segmentName(String? id) {
      for (final SegmentOption segment in spec.segments) {
        if (segment.id == id) {
          return segment.name;
        }
      }
      return shown(id);
    }

    return <Widget>[
      if (widget.email != null) _Row(AccountText.email, widget.email!),
      for (final ProfileField field in spec.fields)
        switch (field) {
          ProfileField.fullName => _Row(
            AccountText.fullName,
            shown(profile?.name),
          ),
          ProfileField.age => _Row(AccountText.age, shown(profile?.age)),
          ProfileField.gender => _Row(
            AccountText.gender,
            shown(profile?.gender),
          ),
          ProfileField.jobTitle => _Row(
            AccountText.occupation,
            shown(profile?.occupation),
          ),
          ProfileField.industrySegment => _Row(
            AccountText.domainOfWork,
            segmentName(profile?.domainOfWork),
          ),
        },
      const AccountGap(),
      AccountPrimaryButton(
        AccountText.editProfile,
        onPressed: () => setState(() {
          _editing = true;
          _notice = null;
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Result<ProfileFormSpec>? form = _form;
    return AccountPage(
      title: AccountText.profileTitle,
      onBack: _editing ? null : widget.onBack,
      children: <Widget>[
        if (_notice != null) AccountNotice(_notice!, success: _noticeIsSuccess),
        ...switch (form) {
          null => const <Widget>[
            Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(semanticsLabel: 'Loading'),
              ),
            ),
          ],
          Err<ProfileFormSpec>(:final AppFailure failure) => <Widget>[
            AccountNotice(
              messageFor(failure),
              onRetry: failure.retryable ? _load : null,
            ),
          ],
          Ok<ProfileFormSpec>(:final ProfileFormSpec value) when !_editing =>
            _view(value),
          Ok<ProfileFormSpec>(:final ProfileFormSpec value) => <Widget>[
            ProfileFormView(
              spec: value,
              submitLabel: AccountText.saveChanges,
              onSubmit: _save,
              busy: _busy,
              consentLinks: widget.consentLinks,
            ),
            AccountLink(
              AccountText.cancel,
              onPressed: _busy
                  ? null
                  : () => setState(() {
                      _editing = false;
                      _notice = null;
                    }),
            ),
          ],
        },
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: MfwSpace.md),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MfwColours.divider)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: MfwType.small),
          const SizedBox(height: MfwSpace.xs),
          Text(value, style: MfwType.body.copyWith(color: MfwColours.heading)),
        ],
      ),
    );
  }
}
