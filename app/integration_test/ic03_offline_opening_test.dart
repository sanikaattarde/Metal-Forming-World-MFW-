// IC-03 (`API_AND_MODULE_CONTRACTS.md` section 9) on a device: MOD-06
// downloads and verifies an issue, then hands MOD-07 the complete copy
// through `openLocal`, and the reader opens it with the network gone
// (RS FR-DL-007, AC-4.2, MOD06-P3-T03). The file is the generated
// FX-PDF-01, served from inside the test (DEC-024).
//
// Run from `app/`:
//   flutter test integration_test/ic03_offline_opening_test.dart -d <id>
import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mfw_app/app/reader_route.dart';
import 'package:mfw_app/app/theme/mfw_theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/downloads/downloads.dart';
import 'package:mfw_app/features/reader/reader.dart';

import '../test/fixtures/synthetic_pdf.dart';

const String _host = '127.0.0.1';

final class FixedGrant implements IssueFileService {
  FixedGrant(this.grant);

  final IssueFileGrant grant;

  @override
  Future<Result<IssueFileGrant>> requestIssueFile(String issueId) async =>
      Ok<IssueFileGrant>(grant);
}

/// The connection as the test sets it.
final class SetConnectivity implements ConnectivityService {
  ConnectionType type = ConnectionType.wifi;

  @override
  Future<ConnectionType> current() async => type;

  @override
  Stream<ConnectionType> watch() => const Stream<ConnectionType>.empty();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a downloaded issue opens in full in the reader with the '
      'network gone [IC-03, AC-4.2, FR-DL-007]', (WidgetTester tester) async {
    final List<int> pdf = fxPdf01();
    final HttpServer server = await HttpServer.bind(_host, 0);
    server.listen((HttpRequest request) async {
      request.response.contentLength = pdf.length;
      request.response.add(pdf);
      await request.response.close();
    });
    final SetConnectivity connectivity = SetConnectivity();
    final PlatformIssueStorage storage = PlatformIssueStorage();
    final IssueDownloadManager downloads = IssueDownloadManager(
      files: FixedGrant(
        IssueFileGrant(
          issueId: 'fx-iss-ic03',
          access: Uri.parse('http://$_host:${server.port}/fx-pdf-01'),
          expiresAt: DateTime.now().toUtc().add(const Duration(minutes: 5)),
          sizeBytes: pdf.length,
          contentHash: sha256.convert(pdf).toString(),
          revision: 1,
        ),
      ),
      transport: HttpFileTransport(plainHttpHosts: <String>{_host}),
      store: IoFileStore(storage),
      verifier: const Sha256HashVerifier(),
      registry: JsonDownloadRegistry(storage),
      connectivity: connectivity,
      currentUserId: () => 'fx-usr-ic03',
      pending: JsonPendingDownloads(storage),
    );

    final Result<void> downloaded = await tester.runAsync(
      () => downloads.start('fx-iss-ic03', mobileDataAccepted: true),
    ) as Result<void>;
    expect(downloaded, isA<Ok<void>>());

    // The network goes: no server, no connection.
    await tester.runAsync(() => server.close(force: true));
    connectivity.type = ConnectionType.none;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildMfwTheme(),
        home: ReaderRoute(
          issueId: 'fx-iss-ic03',
          downloads: downloads,
          renderer: const PdfrxRenderer(),
          titleOf: (String _) async => 'FX-PDF-01',
        ),
      ),
    );
    await _until(tester, find.text('1 / 4'));
    expect(find.text('FX-PDF-01'), findsOneWidget);

    await tester.tap(find.widgetWithIcon(IconButton, Icons.chevron_right));
    await _until(tester, find.text('2 / 4'));

    await tester.runAsync(() => downloads.delete('fx-iss-ic03'));
  });
}

Future<void> _until(WidgetTester tester, Finder finder) async {
  for (int i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  expect(finder, findsOneWidget);
}
