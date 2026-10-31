// Preview of the download panel and the Downloads screen over the fakes,
// for the simulator probe (P-SIM):
//   flutter run -t test/features/downloads/downloads_preview_main.dart
// Not a test, and not part of the app. The issue and downloads routes in
// app/lib/app/ still show placeholders.

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme.dart';
import 'package:mfw_app/features/downloads/downloads.dart';

import 'download_test_support.dart';

void main() {
  final DownloadRig rig = DownloadRig(
    sizes: const <String, int>{'fx-iss-01': 1200000, 'fx-iss-02': 800000},
    capacityBytes: 1000000000,
    chunkDelay: const Duration(milliseconds: 150),
  );
  rig.transport.chunkBytes = 60000;
  runApp(
    MaterialApp(
      theme: placeholderTheme,
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(title: const Text('Issue fx-iss-01')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DownloadPanel(downloads: rig.manager, issueId: 'fx-iss-01'),
                  const SizedBox(height: 32),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) =>
                            DownloadsScreen(downloads: rig.manager),
                      ),
                    ),
                    child: const Text(DownloadsText.title),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
