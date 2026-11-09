import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/contracts/result.dart';
import 'package:mfw_app/core/logging/redaction.dart';

// All values are synthetic (DEC-024). The tokens are made of repeated
// characters, and the JSON Web Token carries {"alg":"none"} and
// {"sub":"test"} with no signature key.
const String _jwt =
    'eyJhbGciOiJub25lIn0.eyJzdWIiOiJ0ZXN0In0.c2lnbmF0dXJlLXRlc3Q';

final String _pushToken = 'fx${'Ab1-' * 40}:APA91b${'Cd2_' * 20}';

final class _ChattyObject {
  @override
  String toString() => 'profile of reader@example.test, gender X';
}

void main() {
  group('Redactor.text [SC-16, SEC-CHK-10]', () {
    test('removes email addresses', () {
      expect(
        Redactor.text('sign-in failed for reader.one+test@example.test'),
        'sign-in failed for [email]',
      );
    });

    test('removes the query of a signed link and keeps the path', () {
      expect(
        Redactor.text(
          'GET https://storage.example.test/bucket/issues/fx-issue-01.pdf'
          '?X-Goog-Algorithm=GOOG4-RSA-SHA256&X-Goog-Signature=0a1b2c',
        ),
        'GET https://storage.example.test/bucket/issues/fx-issue-01.pdf'
        '?[redacted]',
      );
    });

    test('removes a download token in a query', () {
      expect(
        Redactor.text(
          'https://files.example.test/v0/b/x/o/fx-issue-02.pdf'
          '?alt=media&token=1234-abcd',
        ),
        'https://files.example.test/v0/b/x/o/fx-issue-02.pdf?[redacted]',
      );
    });

    test('removes the user part and the fragment of a link', () {
      expect(
        Redactor.text('https://user:secret@example.test:8443/a#frag'),
        'https://example.test:8443/a?[redacted]',
      );
    });

    test('keeps a link with no query, such as a news post [CODING_STANDARDS 6.2 rule 5]', () {
      const String link = 'https://news.example.test/wp-json/wp/v2/posts/12';
      expect(Redactor.text(link), link);
    });

    test('removes a token in the path of a link', () {
      expect(
        Redactor.text('https://example.test/grant/$_jwt/file'),
        'https://example.test/grant/[token]/file',
      );
    });

    test('removes JSON Web Tokens and bearer tokens', () {
      expect(Redactor.text('id token $_jwt seen'), 'id token [token] seen');
      expect(
        Redactor.text('Authorization: Bearer abc.DEF-123_xyz'),
        'Authorization: [redacted] [token]',
      );
      expect(
        Redactor.text('sent Bearer abc.DEF-123_xyz'),
        'sent Bearer [token]',
      );
    });

    test('removes values given as key=value or JSON', () {
      expect(Redactor.text('password=hunter2 ok'), 'password=[redacted] ok');
      expect(
        Redactor.text('{"idToken":"abc123","issueId":"fx-issue-01"}'),
        '{"idToken":[redacted],"issueId":"fx-issue-01"}',
      );
      expect(Redactor.text('uid: Ab12Cd34'), 'uid: [redacted]');
      expect(Redactor.text("api_key='k-1'"), 'api_key=[redacted]');
    });

    test('removes long opaque tokens such as push device tokens', () {
      expect(Redactor.text('push token $_pushToken'), 'push token [token]');
      expect(Redactor.text('device ${'0f' * 32}'), 'device [token]');
    });

    test('keeps ordinary words after "token"', () {
      const String line = 'token refresh failed, retrying';
      expect(Redactor.text(line), line);
    });

    test('keeps issue IDs, post IDs, counts and short words', () {
      const String line = 'opened fx-issue-03 page 4 of 120, post 12 cached';
      expect(Redactor.text(line), line);
    });
  });

  group('Redactor.context [SC-16]', () {
    test('replaces keys that name personal data or a secret', () {
      final Map<String, Object?> out = Redactor.context(<String, Object?>{
        'email': 'reader@example.test',
        'readerId': 'Ab12Cd34',
        'uid': 'Ab12Cd34',
        'displayName': 'Test Reader',
        'occupation': 'Engineer',
        'domain_of_work': 'Forging',
        'age': 30,
        'gender': 'X',
        'deviceToken': 'abc',
        'grantUrl': 'https://example.test/x',
        'refresh_token': 'abc',
        'responseBody': '{}',
        'issueId': 'fx-issue-01',
        'postId': 12,
        'count': 3,
        'ok': true,
      });
      for (final String key in <String>[
        'email',
        'readerId',
        'uid',
        'displayName',
        'occupation',
        'domain_of_work',
        'age',
        'gender',
        'deviceToken',
        'grantUrl',
        'refresh_token',
        'responseBody',
      ]) {
        expect(out[key], Redactor.removed, reason: key);
      }
      expect(out['issueId'], 'fx-issue-01');
      expect(out['postId'], 12);
      expect(out['count'], 3);
      expect(out['ok'], true);
    });

    test('redacts nested maps, lists and string values', () {
      final Map<String, Object?> out = Redactor.context(<String, Object?>{
        'request': <String, Object?>{
          'password': 'x',
          'note': 'from reader@example.test',
        },
        'links': <String>['https://example.test/f.pdf?sig=1'],
      });
      expect(out['request'], <String, Object?>{
        'password': Redactor.removed,
        'note': 'from [email]',
      });
      expect(out['links'], <String>['https://example.test/f.pdf?[redacted]']);
    });

    test('writes only the type of other objects', () {
      final Map<String, Object?> out = Redactor.context(<String, Object?>{
        'thing': _ChattyObject(),
      });
      expect(out['thing'], '<_ChattyObject>');
    });

    test('writes a failure with its code and redacted detail', () {
      final Map<String, Object?> out = Redactor.context(<String, Object?>{
        'failure': const AppFailure(
          FailureCode.network,
          retryable: true,
          detail: 'socket to reader@example.test',
        ),
      });
      expect(
        out['failure'],
        'AppFailure(network, retryable: true, socket to [email])',
      );
    });

    test('writes dates in UTC', () {
      final Map<String, Object?> out = Redactor.context(<String, Object?>{
        'at': DateTime.utc(2026, 11, 9, 10),
      });
      expect(out['at'], '2026-11-09T10:00:00.000Z');
    });
  });

  group('Redactor.error', () {
    test('redacts the text of an exception', () {
      expect(
        Redactor.error(Exception('no account for reader@example.test')),
        'Exception: no account for [email]',
      );
    });
  });
}
