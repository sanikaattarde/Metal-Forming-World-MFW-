/// Public API of the reader's account, app side (MOD-03, MOD-04).
///
/// The shell builds [AccountAuthService] over the Firebase adapters and puts
/// the screens on their routes. The ports keep the platform plugins in the
/// adapters, so everything else is tested with fakes.
library;

export 'data/account_auth_service.dart';
export 'data/firebase_backend_calls.dart';
export 'data/firebase_identity_provider.dart';
export 'domain/account_rules.dart';
export 'domain/backend_calls.dart';
export 'domain/identity_provider.dart';
export 'presentation/account_text.dart';
export 'presentation/account_widgets.dart';
export 'presentation/password_reset_screen.dart';
export 'presentation/register_screen.dart';
export 'presentation/sign_in_screen.dart';
export 'presentation/verify_email_screen.dart';
