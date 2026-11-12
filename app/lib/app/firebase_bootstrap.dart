import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../core/config/firebase_settings.dart';
import '../features/account/account.dart';
import '../features/catalogue/catalogue.dart';

/// The addresses at which the emulators are the device's own.
const Set<String> _loopback = <String>{'127.0.0.1', 'localhost', '::1'};

/// The Firebase services the app's adapters use, once Firebase has started.
final class FirebaseServices {
  /// Creates the set.
  const FirebaseServices({
    required this.identity,
    required this.backend,
    required this.firestore,
    required this.covers,
    this.emulatorHost,
  });

  /// MOD-03's identity provider.
  final IdentityProvider identity;

  /// The backend operations.
  final BackendCalls backend;

  /// The database, for the reader's own records.
  final FirebaseFirestore firestore;

  /// Where issue covers are loaded from (MOD05-P2-T01).
  final CoverUrls covers;

  /// The emulators' host as the device sees it, in ENV-LOCAL only. Links
  /// to it may use plain HTTP (DEC-023).
  final String? emulatorHost;
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

  // A project's default bucket: the newer name for a cloud project created
  // since October 2024, as ENV-TEST and ENV-PROD will be, and the older one
  // that the emulators give a demo project.
  final String bucket =
      settings.storageBucket ??
      (settings.emulatorHost == null
          ? '${settings.projectId}.firebasestorage.app'
          : '${settings.projectId}.appspot.com');
  CoverUrls covers = CoverUrls(bucket: bucket);
  String? emulatorTarget;
  BackendCalls backend = FirebaseBackendCalls(functions);
  final String? host = settings.emulatorHost;
  if (host != null) {
    // The Android emulator sees the developer's machine as 10.0.2.2.
    final String target = host.isNotEmpty
        ? host
        : (android ? '10.0.2.2' : '127.0.0.1');
    covers = CoverUrls.emulator(bucket: bucket, host: target);
    emulatorTarget = target;
    // The ports of backend/firebase.json.
    await auth.useAuthEmulator(target, 9099);
    functions.useFunctionsEmulator(target, 5001);
    firestore.useFirestoreEmulator(target, 8080);
    // An iPhone reaching the emulators at the developer machine's address:
    // the Firebase Apple SDK will not send the sign-in token over plain HTTP
    // there, so the calls go through EmulatorBackendCalls (ENV-LOCAL only).
    if (!android && !_loopback.contains(target)) {
      backend = EmulatorBackendCalls(
        origin: Uri(scheme: 'http', host: target, port: 5001),
        projectId: settings.projectId,
        idToken: () async => auth.currentUser?.getIdToken(),
      );
    }
  }

  return FirebaseServices(
    identity: FirebaseIdentityProvider(auth),
    backend: backend,
    firestore: firestore,
    covers: covers,
    emulatorHost: emulatorTarget,
  );
}
