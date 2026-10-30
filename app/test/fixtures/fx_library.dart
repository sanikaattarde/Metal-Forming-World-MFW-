import '../fakes/fake_server.dart';
import '../fakes/test_users.dart';

/// Seeds FX-LIB-01 (reader A) and FX-LIB-02 (reader B), from
/// TEST_DATA_AND_FIXTURES section 9. FX-LIB-03 waits for OQ-11 and OQ-21.
void seedLibraryFixtures(FakeServer server) {
  server
    ..addBookmark(fxUsr01.userId, 'fx-iss-01', 7)
    ..addBookmark(fxUsr01.userId, 'fx-iss-02', 12)
    ..setFavourite(fxUsr01.userId, 'fx-iss-03', true)
    ..addBookmark(fxUsr06.userId, 'fx-iss-01', 3)
    ..setFavourite(fxUsr06.userId, 'fx-iss-04', true);
}
