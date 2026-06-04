import 'package:sgt_school/src/services/secure_storage_service.dart';

/// Manages authentication session data in secure storage.
///
/// This datasource wraps [SecureStorageService] with auth-specific
/// key constants, enforcing a single source of truth for session persistence.
class AuthLocalDatasource {
  final SecureStorageService _storage;

  /// Storage key constants — kept private to this datasource.
  static const _tokenKey = 'auth_token';
  static const _profileKey = 'user_profile';

  const AuthLocalDatasource({required SecureStorageService storage})
      : _storage = storage;

  /// Convenience constructor using the singleton storage instance.
  factory AuthLocalDatasource.instance() => AuthLocalDatasource(
        storage: SecureStorageService.instance,
      );

  /// Persists the full session (token + profile JSON).
  Future<void> saveSession({
    required String token,
    required String profileJson,
  }) async {
    await _storage.write(_tokenKey, token);
    await _storage.write(_profileKey, profileJson);
  }

  /// Reads the stored auth token. Returns `null` if not found.
  Future<String?> getToken() async {
    final result = await _storage.read(_tokenKey);
    return result.fold((_) => null, (value) => value);
  }

  /// Reads the stored profile JSON string. Returns `null` if not found.
  Future<String?> getProfileJson() async {
    final result = await _storage.read(_profileKey);
    return result.fold((_) => null, (value) => value);
  }

  /// Clears all auth-related data from secure storage.
  Future<void> clearSession() async {
    await _storage.delete(_tokenKey);
    await _storage.delete(_profileKey);
  }

  /// Checks whether a session exists (i.e., a token is stored).
  Future<bool> hasSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
