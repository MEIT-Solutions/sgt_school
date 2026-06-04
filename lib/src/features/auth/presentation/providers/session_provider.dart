import 'dart:async';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';
import 'package:sgt_school/src/features/auth/domain/repositories/auth_repository.dart';

import '../../../../imports/imports.dart';

/// Session lifecycle states.
enum SessionStatus { unknown, authenticated, unauthenticated }

/// Manages the global authentication session.
///
/// On creation, attempts to restore a persisted session from secure storage.
/// Exposes [status] and [user] for the rest of the app to react to.
class SessionProvider extends ChangeNotifier {
  final AuthRepository _repository;

  SessionStatus _status = SessionStatus.unknown;
  AppUser? _user;

  SessionStatus get status => _status;
  AppUser? get user => _user;
  bool get isAuthenticated => _status == SessionStatus.authenticated;

  SessionProvider({required AuthRepository repository})
      : _repository = repository {
    _init();
  }

  /// Attempts to restore a previous session on app startup.
  Future<void> _init() async {
    final result = await _repository.restoreSession();
    result.fold(
      (_) {
        _status = SessionStatus.unauthenticated;
        notifyListeners();
      },
      (user) {
        if (user != null && user.isNotEmpty) {
          _user = user;
          _status = SessionStatus.authenticated;
        } else {
          _status = SessionStatus.unauthenticated;
        }
        notifyListeners();
      },
    );
  }

  /// Signs out the current user and clears the persisted session.
  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _status = SessionStatus.unauthenticated;
    notifyListeners();
  }

  /// Called after a successful login to update the session state.
  void setAuthenticated(AppUser user) {
    _user = user;
    _status = SessionStatus.authenticated;
    notifyListeners();
  }
}
