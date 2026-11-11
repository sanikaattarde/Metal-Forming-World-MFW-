/// Public API of notifications, app side (MOD-11).
///
/// The shell builds [DeviceNotificationService] over the Firebase adapters,
/// puts SCR-A-21 on its route and forwards tapped notifications to the
/// `AppNavigator`. The ports keep the plugins in the adapters, so everything
/// else is tested with fakes.
library;

export 'data/device_notification_service.dart';
export 'data/firebase_push_messaging.dart';
export 'data/firestore_notification_documents.dart';
export 'data/json_device_choices.dart';
export 'domain/device_choices.dart';
export 'domain/notification_documents.dart';
export 'domain/push_messaging.dart';
export 'presentation/notification_settings_screen.dart';
export 'presentation/notification_settings_tile.dart';
export 'presentation/notification_text.dart';
