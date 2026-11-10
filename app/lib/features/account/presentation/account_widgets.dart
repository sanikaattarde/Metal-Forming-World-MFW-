import 'package:flutter/material.dart';

import '../../../app/theme/mfw_tokens.dart';

/// The parts the account screens share, as drawn in the MOD16-P1-T03
/// frames (`Documentation/design/ACCOUNT_SCREEN_DESIGNS.md`).

/// A page with a title, an optional back control, and a scrolling body.
class AccountPage extends StatelessWidget {
  /// Creates the page.
  const AccountPage({
    super.key,
    required this.title,
    required this.children,
    this.onBack,
  });

  /// The page title.
  final String title;

  /// The body, top to bottom.
  final List<Widget> children;

  /// The back control's action, or null for no back control.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: onBack == null
            ? null
            : IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: onBack,
              ),
        title: Text(title),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(MfwSpace.lg),
          children: children,
        ),
      ),
    );
  }
}

/// Vertical space.
class AccountGap extends StatelessWidget {
  /// Creates the gap.
  const AccountGap([this.size = MfwSpace.lg, Key? key]) : super(key: key);

  /// The height.
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size);
}

/// Body text.
class AccountBody extends StatelessWidget {
  /// Creates the text.
  const AccountBody(this.text, {super.key});

  /// The text.
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: MfwSpace.lg),
    child: Text(text, style: MfwType.body),
  );
}

/// A notice above a form, in the error or the success colour, with an icon
/// so that colour is not the only signal (CODING_STANDARDS.md section 9).
/// Announced to screen readers when it appears.
class AccountNotice extends StatelessWidget {
  /// Creates the notice.
  const AccountNotice(
    this.text, {
    super.key,
    this.success = false,
    this.onRetry,
  });

  /// The message.
  final String text;

  /// Whether it reports a success.
  final bool success;

  /// A Retry action, for a failure that can be retried.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final Color edge = success ? MfwColours.success : MfwColours.error;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
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
      ),
    );
  }
}

/// A text field with a label, an optional hint and an error.
class AccountField extends StatelessWidget {
  /// Creates the field.
  const AccountField({
    super.key,
    required this.label,
    required this.controller,
    this.error,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.autofillHints,
    this.enabled = true,
    this.onSubmitted,
  });

  /// The label.
  final String label;

  /// The field's text.
  final TextEditingController controller;

  /// The error under the field, or null.
  final String? error;

  /// The hint under the field when there is no error.
  final String? hint;

  /// Whether the text is hidden, for a password.
  final bool obscure;

  /// The keyboard to show.
  final TextInputType? keyboardType;

  /// Autofill hints for the platform.
  final Iterable<String>? autofillHints;

  /// Whether the field can be edited.
  final bool enabled;

  /// Called when the keyboard's action is pressed.
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MfwSpace.lg),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        enabled: enabled,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        autocorrect: !obscure,
        enableSuggestions: !obscure,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          helperText: error == null ? hint : null,
          errorText: error,
        ),
      ),
    );
  }
}

/// The filled button for a screen's main action, with a spinner while it
/// runs. It cannot be pressed again while busy.
class AccountPrimaryButton extends StatelessWidget {
  /// Creates the button.
  const AccountPrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.busy = false,
  });

  /// The label.
  final String label;

  /// The action, or null to disable the button.
  final VoidCallback? onPressed;

  /// Whether the action is running.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: busy ? null : onPressed,
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
/// delete icon, and the label in the heading colour (review of #67).
class AccountDestructiveButton extends StatelessWidget {
  /// Creates the button.
  const AccountDestructiveButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.busy = false,
    this.busyLabel = 'Deleting',
  });

  /// The label.
  final String label;

  /// The action, or null to disable the button.
  final VoidCallback? onPressed;

  /// Whether the action is running.
  final bool busy;

  /// The label while it runs.
  final String busyLabel;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: busy ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: MfwColours.heading,
        side: const BorderSide(color: MfwColours.error, width: 2),
      ),
      icon: busy
          ? SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                semanticsLabel: busyLabel,
              ),
            )
          : const Icon(Icons.delete_outline),
      label: Text(busy ? busyLabel : label),
    );
  }
}

/// A text link that runs an action.
class AccountLink extends StatelessWidget {
  /// Creates the link.
  const AccountLink(this.label, {super.key, required this.onPressed});

  /// The label.
  final String label;

  /// The action, or null to disable it.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
