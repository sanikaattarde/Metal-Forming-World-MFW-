import 'package:flutter/material.dart';

import '../domain/link_opener.dart';
import 'account_text.dart';
import 'account_widgets.dart';

/// The links to MFW's privacy policy and terms of use (CFG-07; FR-PRIV-002,
/// DATA-012). A document whose address is not set has its link disabled
/// with a note, which happens only outside ENV-PROD: a production build
/// stops at start-up without both addresses (MOD01-P2-T04).
class PolicyLinks extends StatefulWidget {
  /// Creates the links.
  const PolicyLinks({
    super.key,
    required this.privacyPolicy,
    required this.termsOfUse,
    required this.opener,
  });

  /// The privacy policy's address, or null when not set.
  final Uri? privacyPolicy;

  /// The terms of use's address, or null when not set.
  final Uri? termsOfUse;

  /// Opens the page.
  final LinkOpener opener;

  @override
  State<PolicyLinks> createState() => _PolicyLinksState();
}

class _PolicyLinksState extends State<PolicyLinks> {
  bool _failed = false;

  Future<void> _open(Uri uri) async {
    final bool opened = await widget.opener.open(uri);
    if (mounted) {
      setState(() => _failed = !opened);
    }
  }

  Widget _link(String label, Uri? uri) =>
      AccountLink(label, onPressed: uri == null ? null : () => _open(uri));

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (_failed) const AccountNotice(AccountText.linkFailed),
        _link(AccountText.readPrivacyPolicy, widget.privacyPolicy),
        _link(AccountText.readTermsOfUse, widget.termsOfUse),
        if (widget.privacyPolicy == null || widget.termsOfUse == null)
          const AccountBody(AccountText.policiesNotSet),
      ],
    );
  }
}
