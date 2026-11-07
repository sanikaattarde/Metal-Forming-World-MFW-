import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/contracts.dart';

import '../fixtures/fx_issue_files.dart';
import 'fake_auth_service.dart';
import 'fake_issue_file_service.dart';
import 'fake_server.dart';
import 'test_helpers.dart';
import 'test_users.dart';

void main() {
  group('FakeIssueFileService [IC-02]', () {
    test('implements IssueFileService', () {
      final FakeAuthService auth = FakeAuthService(FakeServer());

      expect(
        FakeIssueFileService(auth, files: fxIssueFiles),
        isA<IssueFileService>(),
      );
    });

    for (final (TestUser? user, FailureCode? expected)
        in <(TestUser?, FailureCode?)>[
          (null, FailureCode.unauthenticated),
          (fxUsr02, FailureCode.emailNotVerified),
          (fxUsr03, FailureCode.profileIncomplete),
          (fxUsr05, FailureCode.profileIncomplete),
          (fxUsr01, null),
          (fxUsr04, null),
        ]) {
      test(
        '${user?.fixtureId ?? 'FX-USR-09'} gets ${expected?.name ?? 'a grant'} [OP-FILE-01]',
        () async {
          final FakeAuthService auth = FakeAuthService(
            FakeServer(),
            signedInAs: user,
          );
          final FakeIssueFileService service = FakeIssueFileService(
            auth,
            files: fxIssueFiles,
          );

          expect(
            failureCodeOf(await service.requestIssueFile('fx-iss-01')),
            expected,
          );
        },
      );
    }

    test(
      'a grant carries the size, hash, revision and expiry [DEC-020]',
      () async {
        final FakeIssueFileService service = FakeIssueFileService(
          FakeAuthService(FakeServer(), signedInAs: fxUsr01),
          files: fxIssueFiles,
          clock: () => DateTime.utc(2026),
          grantLifetime: const Duration(minutes: 5),
        );

        final IssueFileGrant grant = valueOf(
          await service.requestIssueFile('fx-iss-01'),
        );

        expect(grant.issueId, 'fx-iss-01');
        expect(grant.sizeBytes, 800000);
        expect(grant.contentHash, 'fx-hash-iss-01');
        expect(grant.revision, 1);
        expect(grant.expiresAt, DateTime.utc(2026, 1, 1, 0, 5));
      },
    );

    test('each request issues a new grant', () async {
      final FakeIssueFileService service = FakeIssueFileService(
        FakeAuthService(FakeServer(), signedInAs: fxUsr01),
        files: fxIssueFiles,
      );

      final IssueFileGrant first = valueOf(
        await service.requestIssueFile('fx-iss-01'),
      );
      final IssueFileGrant second = valueOf(
        await service.requestIssueFile('fx-iss-01'),
      );

      expect(service.grantsIssued, 2);
      expect(identical(first.access, second.access), isFalse);
    });

    test('an unknown or unpublished issue is notFound [OP-FILE-01]', () async {
      final FakeAuthService auth = FakeAuthService(
        FakeServer(),
        signedInAs: fxUsr01,
      );

      expect(
        failureCodeOf(
          await FakeIssueFileService(
            auth,
            files: fxIssueFiles,
          ).requestIssueFile('fx-iss-99'),
        ),
        FailureCode.notFound,
      );
      expect(
        failureCodeOf(
          await FakeIssueFileService(
            auth,
            files: fxIssueFiles,
            isPublished: (String issueId) => false,
          ).requestIssueFile('fx-iss-01'),
        ),
        FailureCode.notFound,
      );
    });
  });
}
