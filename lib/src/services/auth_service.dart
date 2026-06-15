import '../imports/packages_imports.dart';
import '../utils/utils.dart';
import 'dio_service.dart';

/// Low-level authentication service.
///
/// Handles authentication endpoints by making HTTP calls to the backend.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  /// Test-only constructor — allows fakes to extend this class.
  AuthService.forTesting();

  /// Authenticates with phone and password.
  ///
  /// Returns a map matching the API contract:
  /// ```json
  /// { "token": "...", "role": "student", "profile": { ... } }
  /// ```
  FutureEither<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final responseEither = await DioService.instance.post(
      '/school/login',
      data: {
        'phone': phone,
        'password': password,
      },
    );

    return responseEither.flatMap((response) {
      try {
        final data = response.data;
        if (data == null) {
          return left(
              const ServerFailure('No response data received from server'));
        }

        if (data is! Map<String, dynamic>) {
          return left(ServerFailure('Invalid response format: $data'));
        }

        final success = data['success'] as bool? ?? false;

        if (!success) {
          final errorObj = data['error'] as Map<String, dynamic>?;
          final errorMessage = errorObj?['message'] as String? ??
              data['message'] as String? ??
              'Authentication failed';
          return left(ServerFailure(errorMessage));
        }

        final responseData = data['data'] as Map<String, dynamic>?;
        if (responseData == null) {
          return left(const ServerFailure(
              'Response data is missing from server response'));
        }

        return right(responseData);
      } catch (e) {
        return left(ServerFailure('Failed to parse login response: $e'));
      }
    });
  }
}
