import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/core/config/environment.dart';

void main() {
  group('AppEnvironment [DEC-023]', () {
    test('names the three proposed environments', () {
      expect(
        AppEnvironment.values.map((AppEnvironment e) => e.name).toList(),
        <String>['local', 'test', 'prod'],
      );
    });

    test('reads an environment by name and refuses an unknown one', () {
      expect(AppEnvironment.fromName('test'), AppEnvironment.test);
      expect(() => AppEnvironment.fromName('staging'), throwsArgumentError);
    });
  });
}
