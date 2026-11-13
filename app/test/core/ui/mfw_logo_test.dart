import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/core/ui/mfw_logo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MfwLogo', () {
    test('the asset is bundled and decodes at its full size', () async {
      final ByteData data = await rootBundle.load(MfwLogo.asset);
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
      );
      final ui.FrameInfo frame = await codec.getNextFrame();
      expect(frame.image.width, 1200);
      expect(frame.image.height, 264);
    });

    testWidgets('sets only the height and is labelled for screen readers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Center(child: MfwLogo(height: 36))),
      );
      final Image image = tester.widget<Image>(find.byType(Image));
      expect(image.height, 36);
      expect(image.width, isNull);
      expect(image.fit, BoxFit.contain);
      expect(find.bySemanticsLabel(MfwLogo.label), findsOneWidget);
    });
  });
}
