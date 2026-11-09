import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../../fakes/test_users.dart';
import 'download_test_support.dart';

/// A rig with fx-iss-01 downloaded, then a new manager, as after a restart.
Future<DownloadRig> _rigWithCopy() async {
  final DownloadRig rig = DownloadRig();
  expect(
    await rig.manager.start('fx-iss-01', mobileDataAccepted: false),
    isA<Ok<void>>(),
  );
  return rig;
}

String _onlyPath(DownloadRig rig) => rig.store.files.keys.single;

void main() {
  group('Repair at start [PDF_READER_AND_OFFLINE_DESIGN 4.4]', () {
    test('a row whose file has the right length is kept', () async {
      final DownloadRig rig = await _rigWithCopy();

      rig.manager = rig.newManager();

      expect(
        (await rig.manager.listDownloaded()).map(
          (DownloadedIssue c) => c.issueId,
        ),
        <String>['fx-iss-01'],
      );
    });

    test('a file of the wrong length is deleted with its row, and the issue '
        'shows as not downloaded [FR-STATE-004]', () async {
      final DownloadRig rig = await _rigWithCopy();
      rig.store.files[_onlyPath(rig)]!.removeLast();

      rig.manager = rig.newManager();

      expect(await rig.manager.listDownloaded(), isEmpty);
      expect(rig.store.files, isEmpty);
      expect(rig.registry.rows, isEmpty);
      expect(await rig.manager.watch('fx-iss-01').first, isA<NotDownloaded>());
    });

    test('a row whose file is missing is dropped', () async {
      final DownloadRig rig = await _rigWithCopy();
      rig.store.files.clear();

      rig.manager = rig.newManager();

      expect(await rig.manager.listDownloaded(), isEmpty);
      expect(rig.registry.rows, isEmpty);
    });

    test('an orphan file with no row is deleted (I-3)', () async {
      final DownloadRig rig = await _rigWithCopy();
      rig.registry.rows.clear();

      rig.manager = rig.newManager();
      await rig.manager.listDownloaded();

      expect(rig.store.files, isEmpty);
    });

    test('another reader\'s copy is left alone and not shown (6.2)', () async {
      final DownloadRig rig = await _rigWithCopy();
      rig.auth.signInAs(fxUsr06);

      rig.manager = rig.newManager();

      expect(await rig.manager.listDownloaded(), isEmpty);
      expect(rig.store.files, hasLength(1));
      expect(rig.registry.rows, hasLength(1));
    });

    test('listing checks the rows again, after a file goes while the app '
        'runs', () async {
      final DownloadRig rig = await _rigWithCopy();
      expect(await rig.manager.listDownloaded(), hasLength(1));

      rig.store.files.clear();

      expect(await rig.manager.listDownloaded(), isEmpty);
    });
  });
}
