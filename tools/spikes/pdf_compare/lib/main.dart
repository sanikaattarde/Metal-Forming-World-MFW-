import 'dart:ui';

import 'package:flutter/material.dart';

import 'src/config.dart';
import 'src/results_screen.dart';
import 'src/runner.dart';

/// WB-05 reader library comparison harness (a spike for DEC-005, never shipped).
/// See README.md for the --dart-define values.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Anything that escapes a try block still ends up in the result file.
  final uncaught = <Map<String, Object?>>[];
  FlutterError.onError = (details) {
    uncaught.add(
      errorRecord(
        'FlutterError (${details.library})',
        details.exception,
        details.stack ?? StackTrace.empty,
      ),
    );
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    uncaught.add(errorRecord('PlatformDispatcher', error, stack));
    return true;
  };

  runApp(
    MaterialApp(
      title: 'PDF compare',
      theme: ThemeData(useMaterial3: true),
      home: ResultsScreen(
        config: HarnessConfig.fromEnvironment(),
        uncaught: uncaught,
      ),
    ),
  );
}
