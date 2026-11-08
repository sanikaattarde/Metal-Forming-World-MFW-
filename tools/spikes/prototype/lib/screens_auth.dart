import 'package:flutter/material.dart';
import 'package:mfw_prototype/model.dart';
import 'package:mfw_prototype/widgets.dart';

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

/// SCR-A-01.
class SignInScreen extends StatefulWidget {
  /// Creates the screen.
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return LofiScreen(
      id: 'SCR-A-01',
      title: 'Sign in',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'Sign in to read and download full issues. Browsing and news '
            'stay open without an account.',
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'Email address'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _error,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              model.access = Access.fullAccess;
              Navigator.of(context).pop();
            },
            child: const Text('Sign in'),
          ),
          OutlinedButton(
            onPressed: () => setState(
              () => _error = 'The email address or password is not right.',
            ),
            child: const Text('Show a wrong-password error'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              model.access = Access.profileIncomplete;
              Navigator.of(context).pop();
            },
            label: const Text('Continue with Google (PROVISIONAL, OQ-29)'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const PasswordResetScreen(),
              ),
            ),
            child: const Text('Forgot your password?'),
          ),
          TextButton(
            onPressed: () async {
              final NavigatorState navigator = Navigator.of(context);
              await navigator.push<void>(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const RegisterScreen(),
                ),
              );
              if (model.access != Access.signedOut) {
                navigator.pop();
              }
            },
            child: const Text('Create an account'),
          ),
        ],
      ),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          TextField(
            decoration: InputDecoration(
              labelText: 'Email address',
              errorText: _inUse
                  ? 'An account already uses this address. Sign in instead.'
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _consent,
            onChanged: (bool? on) => setState(() => _consent = on ?? false),
            title: const Text(
              'I accept the privacy policy and the terms of use '
              '(how consent is recorded: OQ-27)',
            ),
          ),
          FilledButton(
            onPressed: _consent
                ? () {
                    model.access = Access.emailUnverified;
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Create account'),
          ),
          OutlinedButton(
            onPressed: () => setState(() => _inUse = true),
            child: const Text('Show the address-in-use message'),
          ),
        ],
      ),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Icon(Icons.mark_email_unread_outlined, size: 64),
          const SizedBox(height: 16),
          const Text(
            'We sent a link to your email address. Open it to verify the '
            'address, then come back here. No requirement asks for a resend '
            'control.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              model.access = Access.profileIncomplete;
              Navigator.of(context).pop();
            },
            child: const Text('I have verified it'),
          ),
          TextButton(
            onPressed: () {
              model.signOut();
              Navigator.of(context).pop();
            },
            child: const Text('Use another account'),
          ),
        ],
      ),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const TextField(
            decoration: InputDecoration(labelText: 'Email address'),
          ),
          const SizedBox(height: 16),
          if (_sent)
            const Text(
              'If an account uses this address, we sent it a link to reset '
              'the password.',
            )
          else
            FilledButton(
              onPressed: () => setState(() => _sent = true),
              child: const Text('Send the link'),
            ),
        ],
      ),
    );
  }
}

/// SCR-A-05. The fields are PROVISIONAL (OQ-01, OQ-02).
class CompleteProfileScreen extends StatelessWidget {
  /// Creates the screen.
  const CompleteProfileScreen({super.key});

  static const List<String> _fields = <String>[
    'Full name',
    'Company',
    'Job title',
    'City',
  ];

  @override
  Widget build(BuildContext context) {
    final ProtoModel model = Proto.of(context);
    return LofiScreen(
      id: 'SCR-A-05',
      title: 'Complete your profile',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Text(
            'A few details before you read full issues. The fields are '
            'PROVISIONAL (OQ-01, OQ-02).',
          ),
          for (final String field in _fields)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextField(decoration: InputDecoration(labelText: field)),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              model.access = Access.fullAccess;
              Navigator.of(context).pop();
            },
            child: const Text('Save and continue'),
          ),
        ],
      ),
    );
  }
}

/// SCR-A-06. Viewing is CONFIRMED; editing is an ASSUMPTION.
class ProfileScreen extends StatelessWidget {
  /// Creates the screen.
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LofiScreen(
      id: 'SCR-A-06',
      title: 'Profile',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          for (final String field in CompleteProfileScreen._fields)
            ListTile(title: Text(field), subtitle: const Text('Sample value')),
          const ListTile(
            title: Text('Email address'),
            subtitle: Text('reader@example.com'),
          ),
          OutlinedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Editing is an ASSUMPTION')),
            ),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}
