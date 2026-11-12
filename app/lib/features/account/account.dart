/// Public API of the reader's account, app side (MOD-03, MOD-04).
///
/// The shell builds [AccountAuthService] over the Firebase adapters and puts
/// the screens on their routes. The ports keep the platform plugins in the
/// adapters, so everything else is tested with fakes.
library;

export 'data/account_auth_service.dart';
export 'data/account_profile_repository.dart';
export 'data/emulator_backend_calls.dart';
export 'data/firebase_backend_calls.dart';
export 'data/firebase_identity_provider.dart';
export 'data/firestore_profile_documents.dart';
export 'data/url_launcher_link_opener.dart';
export 'domain/account_rules.dart';
export 'domain/backend_calls.dart';
export 'domain/identity_provider.dart';
export 'domain/link_opener.dart';
export 'domain/profile_form.dart';
export 'presentation/account_text.dart';
export 'presentation/account_widgets.dart';
export 'presentation/complete_profile_screen.dart';
export 'presentation/delete_account_screen.dart';
export 'presentation/password_reset_screen.dart';
export 'presentation/policy_links.dart';
export 'presentation/profile_form_view.dart';
export 'presentation/profile_screen.dart';
export 'presentation/register_screen.dart';
export 'presentation/settings_screen.dart';
export 'presentation/sign_in_screen.dart';
export 'presentation/verify_email_screen.dart';
