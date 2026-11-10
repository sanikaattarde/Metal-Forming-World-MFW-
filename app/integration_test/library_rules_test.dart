// MOD-08 on a device against the local Firestore and Auth emulators: the
// real FirestoreLibraryDocuments under `backend/firestore.rules`, for the
// parts of IC-04 one device can show (MOD08-P2-T01, MOD08-P2-T02). The two
// device check stays with MOD08-P2-T03.
//
// Run with the emulators started from `backend/`:
//   sh scripts/run-with-env.sh npx firebase emulators:start \
//     --only firestore,auth --project demo-mfw
// then, from `app/`:
//   flutter test integration_test/library_rules_test.dart -d <id>
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mfw_app/contracts/contracts.dart';
import 'package:mfw_app/core/config/firebase_settings.dart';
import 'package:mfw_app/features/library/library.dart';

import 'support/emulator_admin.dart';

const String _definedHost = String.fromEnvironment('MFW_EMULATOR_HOST');

String get emulatorHost => _definedHost.isNotEmpty
    ? _definedHost
    : (Platform.isAndroid ? '10.0.2.2' : '127.0.0.1');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseAuth auth;
  late FirestoreLibraryDocuments documents;
  late DocumentLibraryRepository library;
  final String stamp = DateTime.now().millisecondsSinceEpoch.toString();

  Future<String> signUp(String name) async {
    final UserCredential made = await auth.createUserWithEmailAndPassword(
      email: '$name-$stamp@example.com',
      password: 'synthetic-password-1',
    );
    return made.user!.uid;
  }

  setUpAll(() async {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: FirebaseSettings.emulatorApiKey,
        appId: Platform.isAndroid ? '1:0:android:0' : '1:0:ios:0',
        messagingSenderId: '0',
        projectId: FirebaseSettings.emulatorProjectId,
      ),
    );
    auth = FirebaseAuth.instance;
    await auth.useAuthEmulator(emulatorHost, 9099);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.useFirestoreEmulator(emulatorHost, 8080);
    await EmulatorAdmin(host: emulatorHost).clear();
    documents = FirestoreLibraryDocuments(firestore);
    library = DocumentLibraryRepository(
      documents,
      currentUserId: () => auth.currentUser?.uid,
      // Full access is the app's check (section 4.1); the rules check the
      // owner only, which is what this test is about.
      accessState: () => AccessState.fullAccess,
      userChanges: auth.userChanges().map((User? user) => user?.uid),
    );
  });

  test(
    'a bookmark is written under the rules, and a repeat on a later '
    'revision returns the first one unchanged [rule 2, FR-BKM-001]',
    () async {
      await signUp('reader-a');
      final Bookmark first =
          (await library.addBookmark('fx-iss-01', 7, 1) as Ok<Bookmark>).value;
      expect(first.bookmarkId, 'fx-iss-01_7');

      final Bookmark again =
          (await library.addBookmark('fx-iss-01', 7, 3) as Ok<Bookmark>).value;
      expect(again.fileRevision, 1);
      expect(
        again.createdAt.millisecondsSinceEpoch,
        first.createdAt.millisecondsSinceEpoch,
      );

      final List<Bookmark> listed = await library.watchBookmarks().firstWhere(
        (List<Bookmark> all) => all.isNotEmpty,
      );
      expect(listed.single.page, 7);

      expect(await library.removeBookmark('fx-iss-01_7'), isA<Ok<void>>());
      expect(
        failureCodeOf(await library.removeBookmark('fx-iss-01_7')),
        FailureCode.notFound,
      );
    },
  );

  test('a reader cannot read or write another reader\'s bookmarks '
      '[FR-BKM-005, SEC-CHK-05]', () async {
    final String owner = await signUp('reader-b');
    await library.addBookmark('fx-iss-02', 4, 1);
    await auth.signOut();

    await signUp('reader-c');
    final List<Bookmark> own = await library.watchBookmarks().first;
    expect(own, isEmpty);

    await expectLater(
      documents.writeBookmark(owner, 'fx-iss-02_5', <String, Object?>{
        'bookmark_id': 'fx-iss-02_5',
        'user_id': owner,
        'issue_id': 'fx-iss-02',
        'page_number': 5,
        'file_revision': 1,
        'created_at': DateTime.now().toUtc(),
      }),
      throwsA(
        isA<LibraryWriteError>().having(
          (LibraryWriteError e) => e.code,
          'code',
          'permission-denied',
        ),
      ),
    );
    await expectLater(
      documents.readBookmark(owner, 'fx-iss-02_4'),
      throwsA(isA<LibraryWriteError>()),
    );
  });

  test('favourites mark and unmark under the rules, idempotently '
      '[FR-BKM-003, OP-LIB-05]', () async {
    await signUp('reader-d');
    expect(await library.setFavourite('fx-iss-03', true), isA<Ok<void>>());
    expect(await library.setFavourite('fx-iss-03', true), isA<Ok<void>>());
    expect(
      await library.watchFavouriteIssueIds().firstWhere(
        (Set<String> ids) => ids.isNotEmpty,
      ),
      <String>{'fx-iss-03'},
    );
    expect(await library.setFavourite('fx-iss-03', false), isA<Ok<void>>());
    expect(await library.setFavourite('fx-iss-03', false), isA<Ok<void>>());
    expect(
      await library.watchFavouriteIssueIds().firstWhere(
        (Set<String> ids) => ids.isEmpty,
      ),
      isEmpty,
    );
  });
}

FailureCode? failureCodeOf<T>(Result<T> result) => switch (result) {
  Err<T>(:final AppFailure failure) => failure.code,
  Ok<T>() => null,
};
