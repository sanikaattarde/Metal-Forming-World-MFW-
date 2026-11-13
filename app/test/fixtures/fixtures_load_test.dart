// Every fixture file loads and holds the IDs that TEST_DATA_AND_FIXTURES
// gives it (MOD17-P1-T01). All values are synthetic (DEC-024).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../fakes/test_users.dart';
import 'synthetic_pdf.dart';

List<String> ids(String prefix, int from, int to) => <String>[
  for (int n = from; n <= to; n++) '$prefix-${n.toString().padLeft(2, '0')}',
];

Object? readJson(String path) =>
    jsonDecode(File('test/fixtures/$path').readAsStringSync());

void main() {
  group('fixtures load [MOD17-P1-T01]', () {
    test('the catalogue holds FX-CAT-01 to 04 and FX-ISS-01 to 10', () {
      final Map<String, dynamic> catalogue =
          readJson('catalogue/fx_catalogue.json')! as Map<String, dynamic>;
      String idOf(Object? row) =>
          (row! as Map<String, dynamic>)['fixtureId'] as String;
      expect(
        (catalogue['categories'] as List<dynamic>).map(idOf),
        ids('FX-CAT', 1, 4),
      );
      expect(
        (catalogue['issues'] as List<dynamic>).map(idOf),
        ids('FX-ISS', 1, 10),
      );
    });

    test('the notification payloads are FX-NTF-01 to 08', () {
      final Map<String, dynamic> payloads =
          readJson('notifications/fx_ntf_payloads.json')!
              as Map<String, dynamic>;
      expect(
        payloads.keys.where((String k) => k.startsWith('FX-NTF-')),
        ids('FX-NTF', 1, 8),
      );
    });

    test('every WordPress file parses', () {
      final List<File> files =
          Directory('test/fixtures/wordpress')
              .listSync()
              .whereType<File>()
              .toList()
            ..sort((File a, File b) => a.path.compareTo(b.path));
      expect(files, hasLength(12));
      for (final File file in files) {
        final String text = file.readAsStringSync();
        if (file.path.endsWith('.json')) {
          expect(() => jsonDecode(text), returnsNormally, reason: file.path);
        } else {
          expect(text, contains('<html'), reason: file.path);
        }
      }
    });

    test('the reader personas are FX-USR-01 to 07, on example.com', () {
      expect(
        readerPersonas.map((TestUser u) => u.fixtureId),
        ids('FX-USR', 1, 7),
      );
      for (final TestUser user in readerPersonas) {
        expect(user.email, endsWith('@example.com'));
      }
      expect(fxUsr13.known, fxUsr01.email);
      expect(
        readerPersonas.map((TestUser u) => u.email),
        isNot(contains(fxUsr13.unknown)),
      );
    });

    test('the generated PDFs are whole, and FX-PDF-10 is cut short', () {
      String ascii(List<int> bytes) => latin1.decode(bytes);
      for (final List<int> pdf in <List<int>>[fxPdf01(), fxPdf02()]) {
        expect(ascii(pdf.sublist(0, 5)), '%PDF-');
        expect(ascii(pdf).trimRight(), endsWith('%%EOF'));
      }
      final List<int> truncated = fxPdf10();
      expect(ascii(truncated.sublist(0, 5)), '%PDF-');
      expect(truncated.length, lessThan(fxPdf01().length));
      expect(ascii(truncated), isNot(contains('%%EOF')));
    });
  });
}
