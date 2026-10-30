import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

String statusName(DownloadStatus status) => switch (status) {
  NotDownloaded() => 'notDownloaded',
  Queued() => 'queued',
  InProgress() => 'inProgress',
  WaitingForNetwork() => 'waitingForNetwork',
  Verifying() => 'verifying',
  Downloaded() => 'downloaded',
  Failed() => 'failed',
};

List<String> namesOf(List<Enum> values) =>
    values.map((Enum value) => value.name).toList();

void main() {
  test('AccessState lists the four states in evaluation order [IC-01]', () {
    expect(namesOf(AccessState.values), <String>[
      'signedOut',
      'emailUnverified',
      'profileIncomplete',
      'fullAccess',
    ]);
  });

  test('DownloadStatus has the seven documented states [MOD-06]', () {
    final DownloadedIssue copy = DownloadedIssue(
      issueId: 'fx-iss-01',
      ownerUserId: 'fx-usr-01',
      fileRevision: 1,
      localFile: const LocalIssueFile(
        issueId: 'fx-iss-01',
        fileRevision: 1,
        path: '/fake-app-private/issues/fx-iss-01.pdf',
      ),
      sizeBytes: 800000,
      downloadedAt: DateTime.utc(2026),
      contentHash: 'fx-hash-iss-01',
    );
    final List<DownloadStatus> states = <DownloadStatus>[
      const NotDownloaded(),
      const Queued(),
      const InProgress(1, 2),
      const WaitingForNetwork(1, 2),
      const Verifying(),
      Downloaded(copy),
      const Failed(AppFailure(FailureCode.fileCorrupt)),
    ];

    expect(states.map(statusName).toSet(), hasLength(7));
  });

  test('enums carry only the documented values [MOD-00]', () {
    expect(namesOf(ConnectionType.values), <String>[
      'none',
      'wifi',
      'mobile',
      'other',
    ]);
    expect(namesOf(SignInMethod.values), <String>['email', 'google']);
    expect(namesOf(ProfileStatus.values), <String>[
      'unknown',
      'incomplete',
      'complete',
    ]);
    expect(namesOf(ReaderMode.values), <String>['pageTurn', 'swipe']);
    expect(namesOf(PermissionOutcome.values), <String>[
      'granted',
      'denied',
      'notDetermined',
    ]);
    expect(namesOf(NotificationTargetType.values), <String>[
      'issue',
      'article',
    ]);
  });

  test(
    'IssueSummary leaves the OQ-13 fields empty unless set [FR-MAG-002, OQ-13]',
    () {
      final IssueSummary issue = IssueSummary(
        issueId: 'fx-iss-01',
        title: 'Test Issue 01',
        description: 'Synthetic issue for tests.',
        categoryId: 'fx-cat-01',
        publicationDate: DateTime.utc(2026, 10),
        year: 2026,
      );

      expect(issue.industrySegmentIds, isEmpty);
      expect(issue.edition, isNull);
      expect(issue.coverImageUrl, isNull);
      expect(issue.fileSizeBytes, isNull);
    },
  );
}
