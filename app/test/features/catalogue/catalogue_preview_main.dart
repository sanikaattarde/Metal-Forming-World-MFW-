// Preview of the catalogue and issue details over the fake catalogue, for
// the simulator probe (P-SIM):
//   flutter run -t test/features/catalogue/catalogue_preview_main.dart
// Not a test, and not part of the app. The routes in app/lib/app/ still
// show placeholders. The issues are copied from the FX-ISS fixtures in
// code, because the fixture file is not on the device.

import 'package:flutter/material.dart';
import 'package:mfw_app/app/theme.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/features/catalogue/catalogue.dart';

import '../../fakes/fake_catalogue_repository.dart';
import 'labelled_cover_source.dart';

IssueSummary _issue(
  String number,
  String categoryId,
  DateTime date,
  String description, {
  String? title,
}) => IssueSummary(
  issueId: 'fx-iss-$number',
  title: title ?? 'Test Issue $number',
  description: description,
  categoryId: categoryId,
  publicationDate: date,
  year: date.year,
);

void main() {
  final FakeCatalogueRepository catalogue = FakeCatalogueRepository(
    categories: const <IssueCategory>[
      IssueCategory(categoryId: 'fx-cat-01', name: 'Test Category A'),
      IssueCategory(categoryId: 'fx-cat-02', name: 'Test Category B'),
      IssueCategory(categoryId: 'fx-cat-03', name: 'Test Category C'),
      IssueCategory(categoryId: 'fx-cat-04', name: 'Test Category D'),
    ],
    issues: <IssueSummary>[
      _issue(
        '01',
        'fx-cat-01',
        DateTime.utc(2026, 10),
        'Latest synthetic issue, linked to FX-PDF-01.',
      ),
      _issue(
        '02',
        'fx-cat-02',
        DateTime.utc(2026, 7),
        'Synthetic archive issue.',
      ),
      _issue(
        '03',
        'fx-cat-03',
        DateTime.utc(2026, 4),
        'Synthetic archive issue with two segments.',
      ),
      _issue('04', 'fx-cat-04', DateTime.utc(2026), 'Synthetic archive issue.'),
      _issue(
        '05',
        'fx-cat-01',
        DateTime.utc(2025, 10),
        'Synthetic archive issue.',
      ),
      _issue(
        '06',
        'fx-cat-02',
        DateTime.utc(2025, 7),
        'Synthetic archive issue.',
      ),
      _issue(
        '09',
        'fx-cat-04',
        DateTime.utc(2025),
        'Synthetic issue with special characters.',
        title:
            'Test Issue 09: "Forming" & Pressing - ₹ prices, Café notes and '
            'Größe tables, a deliberately long title for layout and search '
            'tests',
      ),
    ],
  );
  runApp(
    MaterialApp(
      theme: placeholderTheme,
      home: Builder(
        builder: (BuildContext context) => CatalogueScreen(
          catalogue: catalogue,
          covers: const LabelledCoverSource(),
          onOpenIssue: (String issueId) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => IssueDetailsScreen(
                catalogue: catalogue,
                covers: const LabelledCoverSource(),
                issueId: issueId,
                actionBuilder: (BuildContext context, IssueSummary issue) =>
                    const FilledButton(
                      onPressed: null,
                      child: Text('Read or download (MOD-06, not wired)'),
                    ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
