import 'package:sgt_school/src/utils/utils.dart';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';

/// Contract for authentication operations.
///
/// Implementations live in the Data layer and are injected into Providers.
abstract class AuthRepository {
  /// Authenticates a user with phone number and password.
  ///
  /// On success, returns the authenticated [AppUser].
  /// On failure, returns a [Failure] with a user-facing message.
  FutureEither<AppUser> login({
    required String phone,
    required String password,
  });

  /// Attempts to restore a previous session from secure storage.
  ///
  /// Returns the stored [AppUser] if a valid session exists, or `null`
  /// if no session is found.
  FutureEither<AppUser?> restoreSession();

  /// Signs out the current user and clears all persisted session data.
  FutureEither<void> logout();
}
