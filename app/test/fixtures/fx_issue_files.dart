import '../fakes/fake_issue_file_service.dart';

/// Grantable files for the synthetic issues (TEST_DATA_AND_FIXTURES
/// sections 6 and 7). Sizes and hashes are synthetic; no PDF is behind them.
const Map<String, FakeIssueFile> fxIssueFiles = <String, FakeIssueFile>{
  // FX-ISS-01 is linked to FX-PDF-01, 1 MB or less.
  'fx-iss-01': FakeIssueFile(
    sizeBytes: 800000,
    contentHash: 'fx-hash-iss-01',
    revision: 1,
  ),
  // FX-ISS-10 is linked to FX-PDF-05, just below the limit L under both
  // readings of "MB" (OQ-30).
  'fx-iss-10': FakeIssueFile(
    sizeBytes: 145000000,
    contentHash: 'fx-hash-iss-10',
    revision: 1,
  ),
};
