import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/app/shell_text.dart';
import 'package:mfw_app/contracts/contracts.dart';

void main() {
  testWidgets('starts as a visitor and shows home [T-01.1, MOD-01]', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MfwApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text(ShellText.home), findsOneWidget);
  });

  testWidgets('without MOD-03, opening a full issue asks to sign in', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer.test();
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MfwApp()),
    );
    await tester.pumpAndSettle();

    container.read(appNavigatorProvider).openIssue('fx-iss-01');
    await tester.pumpAndSettle();

    expect(find.text(ShellText.signIn), findsOneWidget);
    final Result<void> result = await container
        .read(authServiceProvider)
        .signInWithEmail(email: 'reader@example.test', password: 'x');
    expect((result as Err<void>).failure.code, FailureCode.serviceUnavailable);
  });
}
