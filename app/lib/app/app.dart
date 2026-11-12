import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../contracts/contracts.dart';
import '../core/config/app_config.dart';
import '../core/config/firebase_settings.dart';
import '../core/logging/app_logger.dart';
import '../core/monitoring/crash_reporter.dart';
import '../core/monitoring/monitoring_config.dart';
import '../core/monitoring/usage_events.dart';
import '../features/account/account.dart';
import '../features/catalogue/catalogue.dart';
import '../features/downloads/downloads.dart';
import '../features/library/library.dart';
import '../features/news/news.dart';
import '../features/notifications/notifications.dart';
import '../features/reader/reader.dart';
import '../core/config/wordpress_config.dart';
import '../core/network/https_client.dart';
import '../core/network/connectivity_service.dart';
import 'account_routes.dart';
import 'content_routes.dart';
import 'download_resumer.dart';
import 'firebase_bootstrap.dart';
import 'notification_bridge.dart';
import 'placeholder_screens.dart';
import 'router.dart';
import 'router_app_navigator.dart';
import 'theme/font_licences.dart';
import 'theme/mfw_theme.dart';
import 'unavailable_auth_service.dart';

/// The Firebase services, set by [runMfwApp] once Firebase has started.
/// Null in tests, which use fakes.
final Provider<FirebaseServices?> firebaseServicesProvider =
    Provider<FirebaseServices?>((Ref ref) => null);

/// MOD-04's profile repository (MOD04-P2-T01) over Firebase once it has
/// started, or null without it, in which case the profile screens stay
/// placeholders. Tests override it with a fake.
final Provider<AccountProfileRepository?> profileRepositoryProvider =
    Provider<AccountProfileRepository?>((Ref ref) {
      final FirebaseServices? firebase = ref.watch(firebaseServicesProvider);
      if (firebase == null) {
        return null;
      }
      return AccountProfileRepository(
        firebase.identity,
        firebase.backend,
        FirestoreProfileDocuments(firebase.firestore),
      );
    });

/// MOD-05's catalogue (MOD05-P2-T01) over Firebase once it has started, or
/// null without it, in which case the catalogue screens stay placeholders.
/// Tests override it with a fake.
final Provider<CatalogueRepository?> catalogueRepositoryProvider =
    Provider<CatalogueRepository?>((Ref ref) {
      final FirebaseServices? firebase = ref.watch(firebaseServicesProvider);
      if (firebase == null) {
        return null;
      }
      return DocumentCatalogueRepository(
        FirestoreCatalogueDocuments(firebase.firestore),
        covers: firebase.covers,
      );
    });

/// MOD-09's news from MFW's WordPress site (MOD09-P1-T01) with the copies
/// kept on the device for reading offline and the saved articles
/// (MOD09-P2-T02), or null when the build names no site (CFG-03).
final Provider<OfflineNewsRepository?> offlineNewsProvider =
    Provider<OfflineNewsRepository?>((Ref ref) {
      final WordPressSiteConfig? site = ref.watch(appConfigProvider).wordPress;
      if (site == null) {
        return null;
      }
      return OfflineNewsRepository(
        news: WordPressNewsRepository(client: IoHttpsGetClient(), config: site),
        store: JsonNewsCache(ref.watch(issueStorageProvider).issueDirectory),
      );
    });

/// The news the screens read: [offlineNewsProvider] with, once Firebase has
/// started, the admin's hidden and breaking controls on top (MOD09-P2-T03,
/// OP-04), so they apply to the copies on the device too. Null when the
/// build names no site. Tests override it with a fake.
final Provider<NewsRepository?> newsRepositoryProvider =
    Provider<NewsRepository?>((Ref ref) {
      final OfflineNewsRepository? news = ref.watch(offlineNewsProvider);
      if (news == null) {
        return null;
      }
      final FirebaseServices? firebase = ref.watch(firebaseServicesProvider);
      if (firebase == null) {
        return news;
      }
      return ControlledNewsRepository(
        news: news,
        controls: FirestoreNewsControlsService(firebase.firestore),
      );
    });

/// Where issue files live, from the platform (MOD06-P2-T02, section 8.2).
final Provider<IssueStorage> issueStorageProvider = Provider<IssueStorage>(
  (Ref ref) => PlatformIssueStorage(),
);

/// The titles of downloaded issues, for the Downloads screen offline.
/// Tests set it to null, so the screen shows identifiers.
final Provider<IssueTitles?> issueTitlesProvider = Provider<IssueTitles?>(
  (Ref ref) => IssueTitles(ref.watch(issueStorageProvider)),
);

/// MOD-06's download manager over the real adapters (MOD06-P2-T02) once
/// Firebase has started, or null without it, in which case Download is not
/// offered and the Downloads tab stays a placeholder. Tests override it.
final Provider<DownloadManager?> downloadManagerProvider =
    Provider<DownloadManager?>((Ref ref) {
      final FirebaseServices? firebase = ref.watch(firebaseServicesProvider);
      if (firebase == null) {
        return null;
      }
      final IssueStorage storage = ref.watch(issueStorageProvider);
      final String? emulator = firebase.emulatorHost;
      return IssueDownloadManager(
        files: FunctionsIssueFileService(firebase.backend),
        transport: HttpFileTransport(
          plainHttpHosts: emulator == null
              ? const <String>{}
              : <String>{emulator},
        ),
        store: IoFileStore(storage),
        verifier: const Sha256HashVerifier(),
        registry: JsonDownloadRegistry(storage),
        connectivity: ref.watch(connectivityServiceProvider),
        currentUserId: () => firebase.identity.currentUser?.uid,
        pending: JsonPendingDownloads(storage),
      );
    });

/// MOD-07's renderer (MOD07-P2-T01): pdfrx, YG's position on DEC-005
/// (PROPOSED). Tests override it with a fake, because PDFium is not loaded
/// in `flutter test`.
final Provider<PdfRenderer> pdfRendererProvider = Provider<PdfRenderer>(
  (Ref ref) => const PdfrxRenderer(),
);

/// MOD-08's bookmarks and favourites (MOD08-P2-T01, MOD08-P2-T02) over
/// Firebase once it has started, or null without it, in which case the
/// library stays a placeholder. Tests override it with a fake.
final Provider<LibraryRepository?> libraryRepositoryProvider =
    Provider<LibraryRepository?>((Ref ref) {
      final FirebaseServices? firebase = ref.watch(firebaseServicesProvider);
      if (firebase == null) {
        return null;
      }
      return DocumentLibraryRepository(
        FirestoreLibraryDocuments(firebase.firestore),
        currentUserId: () => firebase.identity.currentUser?.uid,
        accessState: () =>
            ref.read(accessStateProvider).value ?? AccessState.signedOut,
        userChanges: firebase.identity.userChanges().map(
          (IdentityUser? user) => user?.uid,
        ),
      );
    });

/// MOD-11's notification choices and taps (MOD11-P2-T02) over Firebase Cloud
/// Messaging once Firebase has started, or null without it, in which case
/// settings has no notifications entry. The device keeps its own choices
/// next to the download records. Tests override it with fakes.
final Provider<DeviceNotificationService?> notificationServiceProvider =
    Provider<DeviceNotificationService?>((Ref ref) {
      final FirebaseServices? firebase = ref.watch(firebaseServicesProvider);
      if (firebase == null) {
        return null;
      }
      final IssueStorage storage = ref.watch(issueStorageProvider);
      return DeviceNotificationService(
        push: FirebasePushMessaging(),
        documents: FirestoreNotificationDocuments(firebase.firestore),
        device: JsonDeviceChoices(storage.issueDirectory),
        currentUserId: () => firebase.identity.currentUser?.uid,
      );
    });

/// Opens MFW's policy pages outside the app (CFG-07, MOD04-P2-T02). Tests
/// override it with a fake.
final Provider<LinkOpener> linkOpenerProvider = Provider<LinkOpener>(
  (Ref ref) => const UrlLauncherLinkOpener(),
);

/// MOD-03's `AuthService` (MOD03-P2-T01 to T03): [AccountAuthService] over
/// Firebase, with MOD-04's profile status, once Firebase has started, and
/// [UnavailableAuthService] without it, so a test that sets neither runs as
/// a visitor. Tests override it with a fake.
///
/// Riverpod is used in `app/lib/app/` only (DEC-013).
final Provider<AuthService> authServiceProvider = Provider<AuthService>((
  Ref ref,
) {
  final FirebaseServices? firebase = ref.watch(firebaseServicesProvider);
  if (firebase == null) {
    return const UnavailableAuthService();
  }
  final AccountProfileRepository? profiles = ref.watch(
    profileRepositoryProvider,
  );
  return AccountAuthService(
    firebase.identity,
    profileStatus: profiles?.watchStatus,
    backend: firebase.backend,
  );
});

/// The current access state (`API_AND_MODULE_CONTRACTS.md` section 4.1).
///
/// No automatic retry: the shell shows an error with a Retry control.
final StreamProvider<AccessState> accessStateProvider =
    StreamProvider<AccessState>(
      (Ref ref) => ref.watch(authServiceProvider).watchAccessState(),
      retry: _noAutomaticRetry,
    );

Duration? _noAutomaticRetry(int retryCount, Object error) => null;

/// The router: the route table and the access guard on the latest access
/// state (MOD01-P2-T01, DEC-014).
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<AccessState> accessState = ValueNotifier<AccessState>(
    AccessState.signedOut,
  );
  ref.listen<AsyncValue<AccessState>>(accessStateProvider, (
    AsyncValue<AccessState>? previous,
    AsyncValue<AccessState> next,
  ) {
    final AccessState? value = next.value;
    if (value != null) {
      accessState.value = value;
      // A stopped download resumes the next time the app is open with the
      // reader who started it signed in (MOD06-P2-T03, rule 6).
      if (value == AccessState.fullAccess) {
        final DownloadManager? downloads = ref.read(downloadManagerProvider);
        if (downloads is ResumableDownloads) {
          unawaited((downloads as ResumableDownloads).resumePending());
        }
      }
    }
  }, fireImmediately: true);
  final GoRouter router = buildRouter(
    accessState,
    screens: withContentScreens(
      accountScreens(
        auth: ref.read(authServiceProvider),
        profiles: ref.read(profileRepositoryProvider),
        config: ref.read(appConfigProvider),
        links: ref.read(linkOpenerProvider),
        email: () =>
            ref.read(firebaseServicesProvider)?.identity.currentUser?.email,
        notifications: ref.read(notificationServiceProvider),
      ),
      accessState: accessState,
      catalogue: ref.read(catalogueRepositoryProvider),
      news: ref.read(newsRepositoryProvider),
      offlineNews: ref.read(offlineNewsProvider),
      downloads: ref.read(downloadManagerProvider),
      titles: ref.read(issueTitlesProvider),
      renderer: ref.read(pdfRendererProvider),
      library: ref.read(libraryRepositoryProvider),
      links: ref.read(linkOpenerProvider),
    ),
  );
  ref.onDispose(() {
    router.dispose();
    accessState.dispose();
  });
  return router;
});

/// The build's settings for its environment (MOD01-P2-T04). `runMfwApp`
/// reads them once and puts that value here, so a wrong build fails before
/// any screen. Without that override (in tests) it reads them itself.
final Provider<AppConfig> appConfigProvider = Provider<AppConfig>(
  (Ref ref) => AppConfig.fromEnvironment(),
);

/// CFG-11, the crash-reporting and usage-event switches (MOD02-P2-T01,
/// MOD02-P2-T02). `runMfwApp` reads them once, so a wrong value fails at
/// start-up; without that override (in tests) everything is off.
final Provider<MonitoringConfig> monitoringConfigProvider =
    Provider<MonitoringConfig>((Ref ref) => const MonitoringConfig());

/// MOD-02's crash reporter (MOD02-P2-T01): off unless CFG-11 switches it on,
/// redacted, and with no reader identity. No crash service is connected
/// (DEC-028, C-07), so a report goes nowhere yet.
final Provider<CrashReporter> crashReporterProvider = Provider<CrashReporter>(
  (Ref ref) => GuardedCrashReporter(
    enabled: ref.watch(monitoringConfigProvider).crashReportingEnabled,
    logger: RedactingLogger(),
  ),
);

/// MOD-02's usage events (MOD02-P2-T02): the approved list only, which is
/// empty until OQ-23, so nothing is recorded in any build. No analytics
/// service is connected (DEC-028).
final Provider<UsageEvents> usageEventsProvider = Provider<UsageEvents>(
  (Ref ref) => AllowlistedUsageEvents(
    enabled: ref.watch(monitoringConfigProvider).usageEventsEnabled,
    logger: RedactingLogger(),
  ),
);

/// The connection type for the mobile-data warning (MOD01-P2-T03,
/// RS FR-DL-004). Tests override it with `FakeConnectivityService`.
final Provider<ConnectivityService> connectivityServiceProvider =
    Provider<ConnectivityService>((Ref ref) => PluginConnectivityService());

/// The `AppNavigator` for MOD-11: through the router and its guard
/// (BR-005).
final Provider<AppNavigator> appNavigatorProvider = Provider<AppNavigator>(
  (Ref ref) => RouterAppNavigator(ref.watch(routerProvider)),
);

/// Starts Firebase and then the app inside its Riverpod scope.
///
/// Riverpod is used in `app/lib/app/` only (DEC-013), so the scope is created
/// here and not in `main.dart`.
Future<void> runMfwApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A wrong build fails here, before any screen (MOD01-P2-T04), and the
  // values read here are the ones the app uses, so they are read once.
  final AppConfig config = AppConfig.fromEnvironment();
  final FirebaseSettings firebaseSettings = FirebaseSettings.fromEnvironment(
    config.environment,
  );
  final MonitoringConfig monitoring = MonitoringConfig.fromEnvironment();
  // Uncaught errors are reported only when CFG-11 says so (MOD02-P2-T01).
  if (monitoring.crashReportingEnabled) {
    installCrashHandlers(
      GuardedCrashReporter(enabled: true, logger: RedactingLogger()),
    );
  }
  final FirebaseServices firebase = await startFirebase(firebaseSettings);
  registerFontLicences();
  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        monitoringConfigProvider.overrideWithValue(monitoring),
        firebaseServicesProvider.overrideWithValue(firebase),
      ],
      child: const MfwApp(),
    ),
  );
}

/// Root widget of the app.
///
/// Shows a loading screen until the first access state arrives, an error
/// screen with Retry if it cannot be read, and the router after that. The
/// theme uses the website's colours and fonts (working position of
/// 8 November 2026, OQ-63). PLACEHOLDER: no MFW name or logo is shown yet,
/// because the logo file stays out of the repository (DEC-024).
class MfwApp extends ConsumerWidget {
  /// Creates the root widget.
  const MfwApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AccessState> accessState = ref.watch(accessStateProvider);
    final ThemeData theme = buildMfwTheme();
    if (accessState.hasValue) {
      final DownloadManager? downloads = ref.read(downloadManagerProvider);
      return MaterialApp.router(
        theme: theme,
        themeMode: ThemeMode.light,
        routerConfig: ref.watch(routerProvider),
        builder: (BuildContext context, Widget? child) => NotificationBridge(
          notifications: ref.read(notificationServiceProvider),
          sessions: () => ref.read(authServiceProvider).watchSession(),
          navigator: () => ref.read(appNavigatorProvider),
          child: DownloadResumer(
            downloads: downloads is ResumableDownloads
                ? downloads as ResumableDownloads
                : null,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      );
    }
    if (accessState.hasError) {
      return MaterialApp(
        theme: theme,
        themeMode: ThemeMode.light,
        home: ShellErrorScreen(
          onRetry: () => ref.invalidate(accessStateProvider),
        ),
      );
    }
    return MaterialApp(
      theme: theme,
      themeMode: ThemeMode.light,
      home: const ShellLoadingScreen(),
    );
  }
}
