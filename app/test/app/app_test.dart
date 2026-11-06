import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/app.dart';

void main() {
  testWidgets('starts and shows the placeholder shell [T-01.1]', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MfwApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text(placeholderShellLabel), findsOneWidget);
  });
}
