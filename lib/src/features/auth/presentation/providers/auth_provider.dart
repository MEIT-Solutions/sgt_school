import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';

import 'package:sgt_school/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';

/// Manages the login form state and delegates to [AuthRepository].
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({required AuthRepository repository}) : _repository = repository;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Attempts login with phone and password.
  ///
  /// On success, updates [SessionProvider] with the user data so that
  /// the session is available before navigation happens.
  void login({
    required BuildContext context,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);

    final result = await _repository.login(phone: phone, password: password);

    _setLoading(false);
    result.fold(
      (failure) {
        showToast(context, message: failure.message, status: 'error');
      },
      (user) {
        if (context.mounted) {
          // Update session provider FIRST so user data is available everywhere
          final session = context.read<SessionProvider>();
          session.setAuthenticated(user);
          // SessionListenerWrapper will handle navigation to home
        }
      },
    );
  }
}
