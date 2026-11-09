import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme/mfw_tokens.dart';

import 'brand.dart';
import 'model.dart';
import 'widgets.dart';

// The account screens follow Sanika Attarde's frames of MOD16-P1-T03
// (test/design/account_frames.dart): their fields, wording and layout. The
// prototype adds the steps of the entry rule and a link on some screens
// that shows an error state; those links are marked "Prototype".

/// The entry rule of SCREEN_INVENTORY_AND_NAVIGATION section 3: shows the
/// missing steps in order and returns true once the state is fullAccess.
/// Backing out of a step returns false.
Future<bool> ensureFullAccess(BuildContext context) async {
  final ProtoModel model = Proto.read(context);
  final NavigatorState navigator = Navigator.of(context);
  while (model.access != Access.fullAccess) {
    final Access before = model.access;
    final Widget step = switch (before) {
      Access.signedOut => const SignInScreen(),
      Access.emailUnverified => const VerifyEmailScreen(),
      Access.profileIncomplete => const CompleteProfileScreen(),
      Access.fullAccess => const SizedBox.shrink(),
    };
    await navigator.push<void>(
      MaterialPageRoute<void>(builder: (BuildContext context) => step),
    );
    if (model.access == before) {
      return false;
    }
  }
  return true;
}

/// A form page of the account frames: a list with the page padding.
class _Form extends StatelessWidget {
  const _Form(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(MfwSpace.lg), children: children);
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

class _Field extends StatelessWidget {
  const _Field(
    this.label, {
    this.error,
    this.obscure = false,
    this.hint,
    this.keyboard,
  });

  final String label;
  final String? error;
  final bool obscure;
  final String? hint;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: MfwSpace.lg),
    child: TextField(
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        helperText: error == null ? hint : null,
        errorText: error,
      ),
    ),
  );
}

class _Link extends StatelessWidget {
  const _Link(this.label, this.onPressed);

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton(onPressed: onPressed, child: Text(label)),
  );
}

/// SCR-A-01.
class SignInScreen extends StatefulWidget {
  /// Creates the screen.
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _wrong = false;

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return LofiScreen(
      id: 'SCR-A-01',
      title: 'Sign in',
      body: _Form(<Widget>[
        const _Body(
          'Sign in to read and download full issues. Browsing and news stay '
          'open without an account.',
        ),
        if (_wrong) const Notice('The email or password is not right.'),
        const _Field('Email', keyboard: TextInputType.emailAddress),
        const _Field('Password', obscure: true),
        FilledButton(
          onPressed: () {
            model.access = Access.fullAccess;
            Navigator.of(context).pop();
          },
          child: const Text('Sign in'),
        ),
        _Link(
          'Forgot your password?',
          () => Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const PasswordResetScreen(),
            ),
          ),
        ),
        const SizedBox(height: MfwSpace.sm),
        OutlinedButton.icon(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () {
            model.access = Access.profileIncomplete;
            Navigator.of(context).pop();
          },
          label: const Text('Continue with Google'),
        ),
        const SizedBox(height: MfwSpace.xl),
        _Link('New here? Create an account', () async {
          final NavigatorState navigator = Navigator.of(context);
          await navigator.push<void>(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const RegisterScreen(),
            ),
          );
          if (model.access != Access.signedOut) {
            navigator.pop();
          }
        }),
        _Link(
          'Prototype: show the wrong password message',
          () => setState(() => _wrong = true),
        ),
      ]),
    );
  }
}

/// SCR-A-02.
class RegisterScreen extends StatefulWidget {
  /// Creates the screen.
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _consent = false;
  bool _inUse = false;

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return LofiScreen(
      id: 'SCR-A-02',
      title: 'Create an account',
      body: _Form(<Widget>[
        if (_inUse)
          const Notice(
            'An account with this email address exists. Sign in instead.',
          ),
        _Field(
          'Email',
          keyboard: TextInputType.emailAddress,
          error: _inUse ? 'This address is in use.' : null,
        ),
        const _Field('Password', obscure: true, hint: 'At least 8 characters'),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: _consent,
          onChanged: (bool? on) => setState(() => _consent = on ?? false),
          title: const Text(
            'I accept the privacy policy and the terms of use.',
          ),
        ),
        const SizedBox(height: MfwSpace.lg),
        FilledButton(
          onPressed: _consent
              ? () {
                  model.access = Access.emailUnverified;
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Create account'),
        ),
        _Link('Already registered? Sign in', () => Navigator.of(context).pop()),
        _Link(
          'Prototype: show the address in use message',
          () => setState(() => _inUse = true),
        ),
      ]),
    );
  }
}

/// SCR-A-03.
class VerifyEmailScreen extends StatelessWidget {
  /// Creates the screen.
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return LofiScreen(
      id: 'SCR-A-03',
      title: 'Verify your email',
      body: _Form(<Widget>[
        const _Body(
          'We sent a link to reader@example.test. Open it to verify your '
          'address, then come back here.',
        ),
        FilledButton(
          onPressed: () {
            model.access = Access.profileIncomplete;
            Navigator.of(context).pop();
          },
          child: const Text('I have verified my email'),
        ),
        _Link(
          'Send the email again',
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('We sent the email again.')),
          ),
        ),
        _Link('Sign out', () {
          model.signOut();
          Navigator.of(context).pop();
        }),
      ]),
    );
  }
}

/// SCR-A-04. Missing from the route list (SN-01).
class PasswordResetScreen extends StatefulWidget {
  /// Creates the screen.
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return LofiScreen(
      id: 'SCR-A-04',
      title: 'Reset your password',
      body: _Form(<Widget>[
        if (_sent)
          // The same message for a known and an unknown address (SC-21).
          const Notice(
            'If an account uses this address, we have sent it a link to set '
            'a new password.',
            kind: NoticeKind.info,
          )
        else
          const _Body('Enter your email address, and we will send a link.'),
        const _Field('Email', keyboard: TextInputType.emailAddress),
        FilledButton(
          onPressed: () => setState(() => _sent = true),
          child: Text(_sent ? 'Send again' : 'Send link'),
        ),
        _Link('Back to sign in', () => Navigator.of(context).pop()),
      ]),
    );
  }
}

/// SCR-A-05. The fields follow the account frames and are PROVISIONAL
/// (OQ-01, OQ-02).
class CompleteProfileScreen extends StatelessWidget {
  /// Creates the screen.
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return LofiScreen(
      id: 'SCR-A-05',
      title: 'Complete your profile',
      body: _Form(<Widget>[
        const _Body('MFW asks for these details before you read full issues.'),
        const _Field('Full name'),
        const _Field(
          'Age',
          hint: 'In whole years',
          keyboard: TextInputType.number,
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
        const SizedBox(height: MfwSpace.lg),
        const _Field('Occupation'),
        const _Field('Domain of work'),
        FilledButton(
          onPressed: () {
            model.access = Access.fullAccess;
            Navigator.of(context).pop();
          },
          child: const Text('Save and continue'),
        ),
      ]),
    );
  }
}

/// SCR-A-06. Viewing is CONFIRMED; editing is an ASSUMPTION.
class ProfileScreen extends StatelessWidget {
  /// Creates the screen.
  const ProfileScreen({super.key});

  static const List<(String, String)> _rows = <(String, String)>[
    ('Email', 'reader@example.test'),
    ('Full name', 'Test Reader'),
    ('Age', '30'),
    ('Gender', 'Prefer not to say'),
    ('Occupation', 'Test Engineer'),
    ('Domain of work', 'Test Domain'),
  ];

  @override
  Widget build(BuildContext context) {
    return LofiScreen(
      id: 'SCR-A-06',
      title: 'Your profile',
      body: _Form(<Widget>[
        for (final (String label, String value) in _rows)
          Container(
            padding: const EdgeInsets.symmetric(vertical: MfwSpace.md),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: MfwColours.divider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: MfwType.small),
                const SizedBox(height: MfwSpace.xs),
                Text(
                  value,
                  style: MfwType.body.copyWith(color: MfwColours.heading),
                ),
              ],
            ),
          ),
        const SizedBox(height: MfwSpace.lg),
        FilledButton(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Editing is an ASSUMPTION')),
          ),
          child: const Text('Edit profile'),
        ),
      ]),
    );
  }
}
