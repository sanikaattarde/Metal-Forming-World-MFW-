// Preview of the routed app over fakes, for the simulator only (P-SIM):
// flutter run -t test/app/wired_app_preview_main.dart
//
// Signed in as FX-USR-01 (full access). Synthetic issues, issue files and
// news; nothing is read from a server. Fixtures are built in code, because
// the simulator cannot read files under test/.
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mfw_app/app/app.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/news/news.dart';

import '../fakes/fake_auth_service.dart';
import '../fakes/fake_catalogue_repository.dart';
import '../fakes/fake_download_manager.dart';
import '../fakes/fake_issue_file_service.dart';
import '../fakes/fake_server.dart';
import '../fakes/test_users.dart';
import '../features/catalogue/labelled_cover_source.dart';
import '../features/news/fake_wordpress_site.dart';
import '../features/news/labelled_news_image_source.dart';
import '../features/news/wp_fixtures.dart';
import '../features/reader/fake_pdf_renderer.dart';
import '../features/reader/numbered_page_source.dart';
import '../fixtures/fx_issue_files.dart';

IssueSummary _issue(String number, String categoryId, DateTime date) =>
    IssueSummary(
      issueId: 'fx-iss-$number',
      title: 'Test Issue $number',
      description: 'Synthetic issue $number.',
      categoryId: categoryId,
      publicationDate: date,
      year: date.year,
    );

void main() {
  final FakeAuthService auth = FakeAuthService(
    FakeServer(),
    signedInAs: fxUsr01,
  );
  runApp(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        appServicesProvider.overrideWithValue(
          AppServices(
            catalogue: FakeCatalogueRepository(
              categories: const <IssueCategory>[
                IssueCategory(categoryId: 'fx-cat-01', name: 'Test Category A'),
                IssueCategory(categoryId: 'fx-cat-02', name: 'Test Category B'),
              ],
              issues: <IssueSummary>[
                _issue('01', 'fx-cat-01', DateTime.utc(2026, 10)),
                _issue('02', 'fx-cat-02', DateTime.utc(2026, 7)),
                _issue('03', 'fx-cat-01', DateTime.utc(2026, 4)),
              ],
            ),
            covers: const LabelledCoverSource(),
            downloads: FakeDownloadManager(
              auth,
              FakeIssueFileService(auth, files: fxIssueFiles),
            ),
            // Only fx-iss-01 has an issue file in the fixtures.
            renderer: FakePdfRenderer(
              pageCounts: <String, int>{'fx-iss-01': 12},
            ),
            pages: const NumberedPageSource(),
            news: WordPressNewsRepository(
              transport: FakeWordPressSite(
                posts: <Map<String, Object?>>[
                  for (int id = 125; id > 113; id--)
                    syntheticWpPost(
                      id,
                      categories: <int>[if (id.isOdd) 11 else 12],
                    ),
                ],
                categories: const <Map<String, Object?>>[
                  <String, Object?>{'id': 11, 'name': 'Test News A'},
                  <String, Object?>{'id': 12, 'name': 'Test News B'},
                ],
              ),
              site: WordPressSite(
                baseUrl: Uri.parse('https://wordpress.example/'),
                categoryIds: const <String>['11', '12'],
              ),
            ),
            newsImages: const LabelledNewsImageSource(),
          ),
        ),
      ],
      child: const MfwApp(),
    ),
  );
}
