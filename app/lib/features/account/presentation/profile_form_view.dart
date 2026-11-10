import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';
import '../../../contracts/contracts.dart';
import '../domain/profile_form.dart';
import 'account_text.dart';
import 'account_widgets.dart';

/// What the profile form hands back on submit.
typedef ProfileSubmit = Future<void> Function(
  ReaderProfile profile, {
  required bool consented,
});

/// The profile fields of SCR-A-05 and SCR-A-06, from the configured list
/// (MOD04-P2-T01), checked before they are sent: text present and at most
/// 200 characters, age a whole number from 1 to 120 (OQ-02 working
/// position; no age gate, FR-PROF-005).
class ProfileFormView extends StatefulWidget {
  /// Creates the form.
  const ProfileFormView({
    super.key,
    required this.spec,
    required this.submitLabel,
    required this.onSubmit,
    this.busy = false,
    this.consentLinks,
  });

  /// The fields, the segments, the saved values and whether consent is
  /// asked.
  final ProfileFormSpec spec;

  /// The submit button's label.
  final String submitLabel;

  /// Called with the checked profile.
  final ProfileSubmit onSubmit;

  /// Whether a save is running.
  final bool busy;

  /// The links to the policy and terms, under the consent action.
  final Widget? consentLinks;

  @override
  State<ProfileFormView> createState() => _ProfileFormViewState();
}

class _ProfileFormViewState extends State<ProfileFormView> {
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _occupation;
  String? _gender;
  String? _segment;
  bool _consented = false;
  final Map<ProfileField, String> _errors = <ProfileField, String>{};
  String? _consentError;

  bool _asks(ProfileField field) => widget.spec.fields.contains(field);

  @override
  void initState() {
    super.initState();
    final ReaderProfile? current = widget.spec.current;
    _name = TextEditingController(text: current?.name ?? '');
    _age = TextEditingController(text: current?.age?.toString() ?? '');
    _occupation = TextEditingController(text: current?.occupation ?? '');
    _gender = ProfileRules.genderOptions.contains(current?.gender)
        ? current?.gender
        : null;
    _segment =
        widget.spec.segments.any(
          (SegmentOption s) => s.id == current?.domainOfWork,
        )
        ? current?.domainOfWork
        : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _occupation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final Map<ProfileField, String> errors = <ProfileField, String>{};
    if (_asks(ProfileField.fullName) && !ProfileRules.isText(_name.text)) {
      errors[ProfileField.fullName] = AccountText.nameInvalid;
    }
    final int? age = ProfileRules.ageFrom(_age.text);
    if (_asks(ProfileField.age) && age == null) {
      errors[ProfileField.age] = AccountText.ageInvalid;
    }
    if (_asks(ProfileField.gender) && _gender == null) {
      errors[ProfileField.gender] = AccountText.chooseOption;
    }
    if (_asks(ProfileField.jobTitle) &&
        !ProfileRules.isText(_occupation.text)) {
      errors[ProfileField.jobTitle] = AccountText.occupationInvalid;
    }
    if (_asks(ProfileField.industrySegment) && _segment == null) {
      errors[ProfileField.industrySegment] = widget.spec.segments.isEmpty
          ? AccountText.noSegments
          : AccountText.chooseOption;
    }
    final bool consentMissing = widget.spec.needsConsent && !_consented;
    setState(() {
      _errors
        ..clear()
        ..addAll(errors);
      _consentError = consentMissing ? AccountText.consentMissing : null;
    });
    if (errors.isNotEmpty || consentMissing) {
      return;
    }
    await widget.onSubmit(
      ReaderProfile(
        name: _asks(ProfileField.fullName) ? _name.text.trim() : null,
        age: _asks(ProfileField.age) ? age : null,
        gender: _asks(ProfileField.gender) ? _gender : null,
        occupation: _asks(ProfileField.jobTitle)
            ? _occupation.text.trim()
            : null,
        domainOfWork: _asks(ProfileField.industrySegment) ? _segment : null,
      ),
      consented: widget.spec.needsConsent && _consented,
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? error,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MfwSpace.lg),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        style: MfwType.input.copyWith(color: MfwColours.heading),
        decoration: InputDecoration(labelText: label, errorText: error),
        items: items,
        onChanged: widget.busy ? null : onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool busy = widget.busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_asks(ProfileField.fullName))
          AccountField(
            label: AccountText.fullName,
            controller: _name,
            error: _errors[ProfileField.fullName],
            enabled: !busy,
            autofillHints: const <String>[AutofillHints.name],
          ),
        if (_asks(ProfileField.age))
          AccountField(
            label: AccountText.age,
            controller: _age,
            error: _errors[ProfileField.age],
            hint: AccountText.ageHint,
            enabled: !busy,
            keyboardType: TextInputType.number,
          ),
        if (_asks(ProfileField.gender))
          _dropdown(
            label: AccountText.gender,
            value: _gender,
            error: _errors[ProfileField.gender],
            items: <DropdownMenuItem<String>>[
              for (final String option in ProfileRules.genderOptions)
                DropdownMenuItem<String>(value: option, child: Text(option)),
            ],
            onChanged: (String? value) => setState(() => _gender = value),
          ),
        if (_asks(ProfileField.jobTitle))
          AccountField(
            label: AccountText.occupation,
            controller: _occupation,
            error: _errors[ProfileField.jobTitle],
            enabled: !busy,
            autofillHints: const <String>[AutofillHints.jobTitle],
          ),
        if (_asks(ProfileField.industrySegment))
          _dropdown(
            label: AccountText.domainOfWork,
            value: _segment,
            error: _errors[ProfileField.industrySegment],
            items: <DropdownMenuItem<String>>[
              for (final SegmentOption segment in widget.spec.segments)
                DropdownMenuItem<String>(
                  value: segment.id,
                  child: Text(segment.name),
                ),
            ],
            onChanged: (String? value) => setState(() => _segment = value),
          ),
        if (widget.spec.needsConsent) ...<Widget>[
          CheckboxListTile(
            value: _consented,
            onChanged: busy
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
          ?widget.consentLinks,
        ],
        const AccountGap(),
        AccountPrimaryButton(
          widget.submitLabel,
          onPressed: _submit,
          busy: busy,
        ),
      ],
    );
  }
}
