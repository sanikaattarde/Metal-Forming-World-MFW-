// EmulatorBackendCalls: the callable protocol over plain HTTP to the local
// Functions emulator, for an iPhone on the developer's network (ENV-LOCAL).
// A stand-in server on this machine answers as the emulator does.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mfw_app/features/account/account.dart';

void main() {
  late HttpServer server;
  late List<(String, String?, Object?)> seen;
  late Map<String, Object?> Function() answer;

  setUp(() async {
    seen = <(String, String?, Object?)>[];
    answer = () => <String, Object?>{
      'result': <String, Object?>{'ok': true},
    };
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((HttpRequest request) async {
      final Object? body = jsonDecode(await utf8.decodeStream(request));
      seen.add((
        request.uri.path,
        request.headers.value(HttpHeaders.authorizationHeader),
        body,
      ));
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(answer()));
      await request.response.close();
    });
  });

  tearDown(() async {
    try {
      await server.close(force: true);
    } on Object {
      // Already closed by the test.
    }
  });

  EmulatorBackendCalls client({String? token = 'emulator-token'}) =>
      EmulatorBackendCalls(
        origin: Uri(scheme: 'http', host: '127.0.0.1', port: server.port),
        projectId: 'demo-mfw',
        idToken: () async => token,
      );

  test(
    'posts {data} with the token to the operation, and returns the result',
    () async {
      final Map<String, Object?> reply = await client().call(
        'saveProfile',
        <String, Object?>{'request_id': 'r1'},
      );
      expect(reply, <String, Object?>{'ok': true});
      expect(seen.single.$1, '/demo-mfw/us-central1/saveProfile');
      expect(seen.single.$2, 'Bearer emulator-token');
      expect(seen.single.$3, <String, Object?>{
        'data': <String, Object?>{'request_id': 'r1'},
      });
    },
  );

  test('signed out, no token is sent', () async {
    await client(token: null).call('getMyAdminRole', const <String, Object?>{});
    expect(seen.single.$2, isNull);
  });

  test('an error is the backend error, with its reason and fields', () async {
    answer = () => <String, Object?>{
      'error': <String, Object?>{
        'status': 'FAILED_PRECONDITION',
        'message': 'ignored',
        'details': <String, Object?>{'reason': 'PROFILE_INCOMPLETE'},
      },
    };
    await expectLater(
      client().call('getIssueFile', const <String, Object?>{}),
      throwsA(
        isA<BackendCallError>()
            .having((e) => e.category, 'category', 'FAILED_PRECONDITION')
            .having((e) => e.reason, 'reason', 'PROFILE_INCOMPLETE'),
      ),
    );
    answer = () => <String, Object?>{
      'error': <String, Object?>{
        'status': 'INVALID_ARGUMENT',
        'details': <String, Object?>{
          'fields': <String>['age_value'],
        },
      },
    };
    await expectLater(
      client().call('saveProfile', const <String, Object?>{}),
      throwsA(
        isA<BackendCallError>()
            .having((e) => e.category, 'category', 'INVALID_ARGUMENT')
            .having((e) => e.fields, 'fields', <String>['age_value']),
      ),
    );
  });

  test('a server that cannot be reached is UNAVAILABLE', () async {
    final EmulatorBackendCalls unreachable = client();
    await server.close(force: true);
    await expectLater(
      unreachable.call('saveProfile', const <String, Object?>{}),
      throwsA(
        isA<BackendCallError>().having(
          (e) => e.category,
          'category',
          'UNAVAILABLE',
        ),
      ),
    );
  });
}
