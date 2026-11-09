// Design frames for MOD16-P1-T03: the account, profile, settings and
// notification screens SCR-A-01 to SCR-A-08, SCR-A-20 and SCR-A-21, with
// their states (SCREEN_INVENTORY_AND_NAVIGATION.md sections 5 and 7).
//
// These are designs drawn with the app's theme and tokens (#57), not app
// screens: they hold no logic and nothing in `lib/` imports them. The
// wording is PLACEHOLDER until the M2 designs, and the open points each
// frame waits for are in Documentation/design/ACCOUNT_SCREEN_DESIGNS.md.
// All values shown are synthetic (DEC-024).

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';
import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/errors/failure_messages.dart';

/// One frame: a file name and the screen it draws.
typedef DesignFrame = ({String name, String title, Widget screen});

/// Every frame, in the order of the design record.
final List<DesignFrame> accountFrames = <DesignFrame>[
  (name: 'a01_sign_in', title: 'SCR-A-01 Sign in', screen: const _SignIn()),
  (
    name: 'a01_sign_in_error',
    title: 'SCR-A-01 Sign in: wrong email or password',
    screen: const _SignIn(error: 'The email or password is not right.'),
  ),
  (
    name: 'a01_sign_in_no_network',
    title: 'SCR-A-01 Sign in: no network',
    screen: _SignIn(
      error: messageFor(const AppFailure(FailureCode.network, retryable: true)),
      retry: true,
    ),
  ),
  (
    name: 'a01_sign_in_loading',
    title: 'SCR-A-01 Sign in: signing in',
    screen: const _SignIn(busy: true),
  ),
  (name: 'a02_register', title: 'SCR-A-02 Register', screen: const _Register()),
  (
    name: 'a02_register_address_in_use',
    title: 'SCR-A-02 Register: address in use',
    screen: const _Register(
      error: 'An account with this email address exists. Sign in instead.',
    ),
  ),
  (
    name: 'a03_verify_email',
    title: 'SCR-A-03 Verify email',
    screen: const _VerifyEmail(),
  ),
  (
    name: 'a03_verify_email_not_yet',
    title: 'SCR-A-03 Verify email: not verified yet',
    screen: const _VerifyEmail(notYet: true),
  ),
  (
    name: 'a04_password_reset',
    title: 'SCR-A-04 Password reset',
    screen: const _PasswordReset(),
  ),
  (
    name: 'a04_password_reset_sent',
    title: 'SCR-A-04 Password reset: sent',
    screen: const _PasswordReset(sent: true),
  ),
  (
    name: 'a05_complete_profile',
    title: 'SCR-A-05 Complete profile',
    screen: const _CompleteProfile(),
  ),
  (
    name: 'a05_complete_profile_invalid',
    title: 'SCR-A-05 Complete profile: fields to check',
    screen: const _CompleteProfile(invalid: true),
  ),
  (name: 'a06_profile', title: 'SCR-A-06 Profile', screen: const _Profile()),
  (
    name: 'a06_profile_loading',
    title: 'SCR-A-06 Profile: loading',
    screen: const _Profile(state: _Load.loading),
  ),
  (
    name: 'a06_profile_error',
    title: 'SCR-A-06 Profile: could not load',
    screen: const _Profile(state: _Load.error),
  ),
  (name: 'a07_settings', title: 'SCR-A-07 Settings', screen: const _Settings()),
  (
    name: 'a07_settings_visitor',
    title: 'SCR-A-07 Settings: visitor',
    screen: const _Settings(visitor: true),
  ),
  (
    name: 'a08_delete_confirm',
    title: 'SCR-A-08 Delete account',
    screen: const _DeleteAccount(),
  ),
  (
    name: 'a08_delete_reauth',
    title: 'SCR-A-08 Delete account: sign in again',
    screen: const _DeleteAccount(reauth: true),
  ),
  (
    name: 'a08_deleting',
    title: 'SCR-A-08 Delete account: deleting',
    screen: const _DeleteAccount(busy: true),
  ),
  (
    name: 'a20_notification_explanation',
    title: 'SCR-A-20 Notification explanation',
    screen: const _NotificationExplanation(),
  ),
  (
    name: 'a21_categories',
    title: 'SCR-A-21 Notification categories',
    screen: const _Categories(),
  ),
  (
    name: 'a21_categories_error',
    title: 'SCR-A-21 Notification categories: no network',
    screen: const _Categories(error: true),
  ),
];

enum _Load { data, loading, error }

// Shared parts.

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.children, this.back = true});

  final String title;
  final List<Widget> children;
  final bool back;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: back
            ? IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {},
              )
            : null,
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(MfwSpace.lg),
        children: children,
      ),
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap([this.size = MfwSpace.lg]);

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

class _Field extends StatelessWidget {
  const _Field(
    this.label, {
    this.value,
    this.error,
    this.obscure = false,
    this.hint,
  });

  final String label;
  final String? value;
  final String? error;
  final bool obscure;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MfwSpace.lg),
      // initialValue, not a controller made in build: nothing to dispose.
      child: TextFormField(
        initialValue: value,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          helperText: error == null ? hint : null,
          errorText: error,
        ),
      ),
    );
  }
}

/// A notice above a form, in the error or the success colour, with an icon
/// so that colour is not the only signal (CODING_STANDARDS.md section 9).
class _Notice extends StatelessWidget {
  const _Notice(this.text, {this.success = false, this.onRetry});

  final String text;
  final bool success;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final Color edge = success ? MfwColours.success : MfwColours.error;
    return Container(
      margin: const EdgeInsets.only(bottom: MfwSpace.lg),
      padding: const EdgeInsets.all(MfwSpace.md),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: edge, width: 4)),
        color: MfwColours.inputFill,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            success ? Icons.check_circle_outline : Icons.error_outline,
            color: MfwColours.heading,
            semanticLabel: success ? 'Done' : 'Problem',
          ),
          const SizedBox(width: MfwSpace.md),
          Expanded(
            child: Text(
              text,
              style: MfwType.body.copyWith(color: MfwColours.heading),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _Primary extends StatelessWidget {
  const _Primary(this.label, {this.busy = false});

  final String label;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : () {},
      child: busy
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                semanticsLabel: 'Working',
              ),
            )
          : Text(label),
    );
  }
}

/// The style of an irreversible action: an outline in the error colour, a
/// delete icon, and the label in the heading colour, which meets the
/// contrast baseline where red text does not (DESIGN_TOKENS.md section 5).
class _Destructive extends StatelessWidget {
  const _Destructive(this.label, {this.busy = false});

  final String label;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: busy ? null : () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: MfwColours.heading,
        side: const BorderSide(color: MfwColours.error, width: 2),
      ),
      icon: busy
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                semanticsLabel: 'Deleting',
              ),
            )
          : const Icon(Icons.delete_outline),
      label: Text(busy ? 'Deleting' : label),
    );
  }
}

class _Link extends StatelessWidget {
  const _Link(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(onPressed: () {}, child: Text(label)),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: MfwSpace.lg),
    child: Text(text, style: MfwType.body),
  );
}

// SCR-A-01.

class _SignIn extends StatelessWidget {
  const _SignIn({this.error, this.retry = false, this.busy = false});

  final String? error;
  final bool retry;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Sign in',
      children: <Widget>[
        const _Body('Sign in to read and download full issues.'),
        if (error != null) _Notice(error!, onRetry: retry ? () {} : null),
        const _Field('Email', value: 'reader@example.test'),
        const _Field('Password', value: 'password', obscure: true),
        _Primary('Sign in', busy: busy),
        const _Link('Forgot your password?'),
        const _Gap(MfwSpace.sm),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.account_circle_outlined),
          label: const Text('Continue with Google'),
        ),
        const _Gap(MfwSpace.xl),
        const _Link('New here? Create an account'),
      ],
    );
  }
}

// SCR-A-02.

class _Register extends StatelessWidget {
  const _Register({this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Create an account',
      children: <Widget>[
        if (error != null) _Notice(error!),
        _Field(
          'Email',
          value: 'reader@example.test',
          error: error == null ? null : 'This address is in use.',
        ),
        const _Field('Password', obscure: true, hint: 'At least 8 characters'),
        CheckboxListTile(
          value: true,
          onChanged: (_) {},
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'I accept the privacy policy and the terms of use.',
          ),
        ),
        const _Link('Read the privacy policy'),
        const _Link('Read the terms of use'),
        const _Gap(),
        const _Primary('Create account'),
        const _Link('Already registered? Sign in'),
      ],
    );
  }
}

// SCR-A-03.

class _VerifyEmail extends StatelessWidget {
  const _VerifyEmail({this.notYet = false});

  final bool notYet;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Verify your email',
      back: false,
      children: <Widget>[
        if (notYet)
          const _Notice(
            'Your address is not verified yet. Open the link in the email, '
            'then try again.',
          ),
        const _Body(
          'We sent a link to reader@example.test. Open it to verify your '
          'address, then come back here.',
        ),
        const _Primary('I have verified my email'),
        const _Link('Send the email again'),
        const _Link('Sign out'),
      ],
    );
  }
}

// SCR-A-04.

class _PasswordReset extends StatelessWidget {
  const _PasswordReset({this.sent = false});

  final bool sent;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Reset your password',
      children: <Widget>[
        if (sent)
          // The same message for a known and an unknown address (SC-21).
          const _Notice(
            'If an account uses this address, we have sent it a link to set '
            'a new password.',
            success: true,
          )
        else
          const _Body('Enter your email address, and we will send a link.'),
        const _Field('Email', value: 'reader@example.test'),
        _Primary(sent ? 'Send again' : 'Send link'),
        const _Link('Back to sign in'),
      ],
    );
  }
}

// SCR-A-05.

class _CompleteProfile extends StatelessWidget {
  const _CompleteProfile({this.invalid = false});

  final bool invalid;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Complete your profile',
      back: false,
      children: <Widget>[
        const _Body('MFW asks for these details before you read full issues.'),
        if (invalid)
          _Notice(messageFor(const AppFailure(FailureCode.invalidInput))),
        _Field(
          'Full name',
          value: invalid ? '' : 'Test Reader',
          error: invalid ? 'Enter your name.' : null,
        ),
        _Field(
          'Age',
          value: invalid ? '200' : '30',
          error: invalid ? 'Enter an age from 1 to 120.' : null,
          hint: 'In whole years',
        ),
        DropdownButtonFormField<String>(
          initialValue: 'Prefer not to say',
          style: MfwType.input.copyWith(color: MfwColours.heading),
          decoration: const InputDecoration(labelText: 'Gender'),
          items: const <DropdownMenuItem<String>>[
            DropdownMenuItem<String>(value: 'Female', child: Text('Female')),
            DropdownMenuItem<String>(value: 'Male', child: Text('Male')),
            DropdownMenuItem<String>(
              value: 'Prefer not to say',
              child: Text('Prefer not to say'),
            ),
          ],
          onChanged: (_) {},
        ),
        const _Gap(),
        const _Field('Occupation', value: 'Test Engineer'),
        const _Field('Domain of work', value: 'Test Domain'),
        const _Primary('Save and continue'),
      ],
    );
  }
}

// SCR-A-06.

class _Profile extends StatelessWidget {
  const _Profile({this.state = _Load.data});

  final _Load state;

  @override
  Widget build(BuildContext context) {
    final List<Widget> body = switch (state) {
      _Load.loading => const <Widget>[
        _Gap(MfwSpace.xxxl),
        Center(child: CircularProgressIndicator(semanticsLabel: 'Loading')),
      ],
      _Load.error => <Widget>[
        _Notice(
          messageFor(const AppFailure(FailureCode.network, retryable: true)),
          onRetry: () {},
        ),
      ],
      _Load.data => const <Widget>[
        _Row('Email', 'reader@example.test'),
        _Row('Full name', 'Test Reader'),
        _Row('Age', '30'),
        _Row('Gender', 'Prefer not to say'),
        _Row('Occupation', 'Test Engineer'),
        _Row('Domain of work', 'Test Domain'),
        _Gap(),
        _Primary('Edit profile'),
      ],
    };
    return _Page(title: 'Your profile', children: body);
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

// SCR-A-07 with SCR-A-21 inside.

class _Settings extends StatelessWidget {
  const _Settings({this.visitor = false});

  final bool visitor;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Settings',
      children: <Widget>[
        const _Section('Notifications'),
        const _CategorySwitches(),
        if (!visitor) ...<Widget>[
          const _Section('Account'),
          _Tile('Your profile', icon: Icons.person_outline),
          _Tile('Sign out', icon: Icons.logout),
          _Tile('Delete account', icon: Icons.delete_outline),
        ] else ...<Widget>[
          const _Section('Account'),
          _Tile('Sign in or create an account', icon: Icons.login),
        ],
        const _Section('About'),
        _Tile('Privacy policy', icon: Icons.open_in_new),
        _Tile('Terms of use', icon: Icons.open_in_new),
        _Tile('Open-source licences', icon: Icons.description_outlined),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: MfwSpace.xl, bottom: MfwSpace.sm),
    child: Text(
      label,
      style: MfwType.label.copyWith(color: MfwColours.heading),
    ),
  );
}

class _Tile extends StatelessWidget {
  const _Tile(this.label, {required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: MfwColours.heading),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: MfwColours.body),
      onTap: () {},
    );
  }
}

// The three fixed categories of GS-Q47 (OQ-18 stays open).
class _CategorySwitches extends StatelessWidget {
  const _CategorySwitches();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final (String name, bool on) in <(String, bool)>[
          ('New issues', true),
          ('Expo specials', false),
          ('Major news', true),
        ])
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: on,
            onChanged: (_) {},
            title: Text(name),
          ),
      ],
    );
  }
}

// SCR-A-08.

class _DeleteAccount extends StatelessWidget {
  const _DeleteAccount({this.reauth = false, this.busy = false});

  final bool reauth;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Delete account',
      children: <Widget>[
        const _Body(
          'Deleting your account removes your profile, bookmarks, favourites, '
          'notification choices and downloaded issues at once. It cannot be '
          'undone.',
        ),
        if (reauth) ...<Widget>[
          _Notice(
            '${messageFor(const AppFailure(FailureCode.unauthenticated))} '
            'For your safety, enter your password again.',
          ),
          const _Field('Password', obscure: true),
        ],
        // The safe choice is the filled button, and the irreversible one has
        // its own style: an outline in the error colour with a delete icon
        // (review of pull request #67).
        const _Primary('Keep my account'),
        const _Gap(MfwSpace.md),
        _Destructive(
          reauth ? 'Confirm and delete' : 'Delete my account',
          busy: busy,
        ),
      ],
    );
  }
}

// SCR-A-20.

class _NotificationExplanation extends StatelessWidget {
  const _NotificationExplanation();

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Stay up to date',
      back: false,
      children: const <Widget>[
        _Gap(MfwSpace.xl),
        Center(
          child: Icon(
            Icons.notifications_outlined,
            size: 64,
            color: MfwColours.heading,
            semanticLabel: 'Notifications',
          ),
        ),
        _Gap(MfwSpace.xl),
        _Body(
          'MFW can tell you when a new issue is out, about expo specials and '
          'about major news. You choose which, and you can change it in '
          'Settings at any time.',
        ),
        _Body('Your phone asks next whether to allow notifications.'),
        _Primary('Continue'),
        _Link('Not now'),
      ],
    );
  }
}

// SCR-A-21 on its own, as it appears inside settings.

class _Categories extends StatelessWidget {
  const _Categories({this.error = false});

  final bool error;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Notifications',
      children: <Widget>[
        const _Body('Choose what MFW tells you about.'),
        if (error)
          _Notice(
            messageFor(const AppFailure(FailureCode.network, retryable: true)),
            onRetry: () {},
          )
        else
          const _CategorySwitches(),
      ],
    );
  }
}
