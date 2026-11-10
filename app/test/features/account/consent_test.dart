// MOD04-P2-T02: the acceptance of the privacy policy and the terms of use
// at registration, kept for the first profile save through OP-10, and the
// CFG-07 links (FR-PRIV-001, FR-PRIV-002, DATA-012, PAC-08). Synthetic
// values only (DEC-024).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/account/account.dart';

import 'fake_identity_provider.dart';
import 'fake_link_opener.dart';
import 'fake_profile_backend.dart';

final Uri privacy = Uri.parse('https://example.test/privacy');
final Uri terms = Uri.parse('https://example.test/terms');

Future<void> pump(WidgetTester tester, Widget screen) async {
  await tester.pumpWidget(MaterialApp(theme: buildMfwTheme(), home: screen));
  await tester.pumpAndSettle();
}

Finder field(String label) => find.widgetWithText(TextField, label);

void main() {
  late FakeIdentityProvider identity;
  late FakeProfileBackend backend;
  late AccountAuthService auth;
  late AccountProfileRepository profiles;
  late FakeLinkOpener links;

  setUp(() {
    identity = FakeIdentityProvider();
    backend = FakeProfileBackend(identity);
    auth = AccountAuthService(identity);
    profiles = AccountProfileRepository(identity, backend, backend);
    links = FakeLinkOpener();
  });

  Widget register({Uri? privacyPolicy, Uri? termsOfUse}) => RegisterScreen(
    auth: auth,
    profiles: profiles,
    onSignIn: () {},
    policyLinks: PolicyLinks(
      privacyPolicy: privacyPolicy,
      termsOfUse: termsOfUse,
      opener: links,
    ),
  );

  Future<void> fill(WidgetTester tester) async {
    await tester.enterText(field(AccountText.email), 'reader@example.test');
    await tester.enterText(field(AccountText.password), 'long-enough-1');
  }

  testWidgets(
    'registration needs the acceptance, and without it nothing is sent [FR-PRIV-001]',
    (WidgetTester tester) async {
      await pump(tester, register(privacyPolicy: privacy, termsOfUse: terms));
      await fill(tester);
      await tester.tap(find.text(AccountText.registerButton));
      await tester.pumpAndSettle();
      expect(find.text(AccountText.consentMissing), findsOneWidget);
      expect(identity.calls, isEmpty);
    },
  );

  testWidgets(
    'accepted at registration, it is kept and goes with the first profile save, so SCR-A-05 does not ask again',
    (WidgetTester tester) async {
      await pump(tester, register(privacyPolicy: privacy, termsOfUse: terms));
      await fill(tester);
      await tester.tap(find.text(AccountText.consent));
      await tester.tap(find.text(AccountText.registerButton));
      await tester.pumpAndSettle();
      expect(identity.accounts.containsKey('reader@example.test'), isTrue);

      final ProfileFormSpec spec =
          (await profiles.loadForm() as Ok<ProfileFormSpec>).value;
      expect(spec.needsConsent, isFalse);

      await profiles.saveOwnProfile(const ReaderProfile(name: 'Test Reader'));
      expect(backend.calls.single.$2['accepted_versions'], <String, Object?>{
        'privacy_policy': 'pp-test-1',
        'terms_of_use': 'tou-test-1',
      });
    },
  );

  testWidgets('the two links open the CFG-07 addresses [FR-PRIV-002]', (
    WidgetTester tester,
  ) async {
    await pump(tester, register(privacyPolicy: privacy, termsOfUse: terms));
    await tester.tap(find.text(AccountText.readPrivacyPolicy));
    await tester.tap(find.text(AccountText.readTermsOfUse));
    await tester.pumpAndSettle();
    expect(links.opened, <Uri>[privacy, terms]);
    expect(find.text(AccountText.policiesNotSet), findsNothing);
  });

  testWidgets('a page that cannot be opened says so', (
    WidgetTester tester,
  ) async {
    links.works = false;
    await pump(tester, register(privacyPolicy: privacy, termsOfUse: terms));
    await tester.tap(find.text(AccountText.readPrivacyPolicy));
    await tester.pumpAndSettle();
    expect(find.text(AccountText.linkFailed), findsOneWidget);
  });

  testWidgets(
    'an address not set in this build disables its link, with a note',
    (WidgetTester tester) async {
      await pump(tester, register(termsOfUse: terms));
      final TextButton policy = tester.widget(
        find.widgetWithText(TextButton, AccountText.readPrivacyPolicy),
      );
      expect(policy.onPressed, isNull);
      expect(find.text(AccountText.policiesNotSet), findsOneWidget);
    },
  );

  testWidgets(
    'SCR-A-05 shows the links with the acceptance when it asks for it',
    (WidgetTester tester) async {
      identity.addAccount(
        'reader@example.test',
        'right-password',
        verified: true,
      );
      await identity.signIn(
        email: 'reader@example.test',
        password: 'right-password',
      );
      await pump(
        tester,
        CompleteProfileScreen(
          forms: profiles,
          profiles: profiles,
          consentLinks: PolicyLinks(
            privacyPolicy: privacy,
            termsOfUse: terms,
            opener: links,
          ),
        ),
      );
      expect(find.text(AccountText.consent), findsOneWidget);
      expect(find.text(AccountText.readPrivacyPolicy), findsOneWidget);
    },
  );
}
