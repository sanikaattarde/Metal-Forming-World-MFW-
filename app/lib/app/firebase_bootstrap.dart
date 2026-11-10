import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../core/config/firebase_settings.dart';
import '../features/account/account.dart';

/// The Firebase services the app's adapters use, once Firebase has started.
final class FirebaseServices {
  /// Creates the set.
  const FirebaseServices({
    required this.identity,
    required this.backend,
    required this.firestore,
  });

  /// MOD-03's identity provider.
  final IdentityProvider identity;

  /// The backend operations.
  final BackendCalls backend;

  /// The database, for the reader's own records.
  final FirebaseFirestore firestore;
}

/// Starts Firebase for [settings] and connects the emulators in ENV-LOCAL
/// (DEC-023). Runs once, before the first frame.
///
/// Runs only on a device or simulator: the plugins have no implementation
/// in `flutter test`, which uses fakes through the ports instead.
Future<FirebaseServices> startFirebase(FirebaseSettings settings) async {
  final bool android = defaultTargetPlatform == TargetPlatform.android;
  final FirebaseAppIds ids = android ? settings.android : settings.ios;
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: ids.apiKey,
      appId: ids.appId,
      messagingSenderId: settings.messagingSenderId,
      projectId: settings.projectId,
      storageBucket: settings.storageBucket,
    ),
  );
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFunctions functions = FirebaseFunctions.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String? host = settings.emulatorHost;
  if (host != null) {
    // The Android emulator sees the developer's machine as 10.0.2.2.
    final String target = host.isNotEmpty
        ? host
        : (android ? '10.0.2.2' : '127.0.0.1');
    // The ports of backend/firebase.json.
    await auth.useAuthEmulator(target, 9099);
    functions.useFunctionsEmulator(target, 5001);
    firestore.useFirestoreEmulator(target, 8080);
  }

  return FirebaseServices(
    identity: FirebaseIdentityProvider(auth),
    backend: FirebaseBackendCalls(functions),
    firestore: firestore,
  );
}
