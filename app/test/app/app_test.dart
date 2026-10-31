import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

void main() {
  testWidgets('starts on the catalogue, which says it is unavailable until '
      'a catalogue source exists [T-01.1, FR-STATE-003]', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MfwApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text(CatalogueText.title), findsOneWidget);
    expect(
      find.text(
        CatalogueText.failure(const AppFailure(FailureCode.serviceUnavailable)),
      ),
      findsOneWidget,
    );
    expect(find.text(CatalogueText.retry), findsNothing);
  });
}
