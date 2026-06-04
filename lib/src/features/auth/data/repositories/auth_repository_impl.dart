import 'package:sgt_school/src/imports/packages_imports.dart';

import 'package:sgt_school/src/features/auth/domain/entities/user.dart';
import 'package:sgt_school/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:sgt_school/src/features/auth/data/models/user_model.dart';
import 'package:sgt_school/src/features/auth/data/datasources/auth_local_datasource.dart';

import 'package:sgt_school/src/services/auth_service.dart';
import 'package:sgt_school/src/utils/utils.dart';

/// Concrete implementation of [AuthRepository].
///
/// Orchestrates between [AuthService] (API calls) and
/// [AuthLocalDatasource] (secure storage) to manage the auth lifecycle.
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  final AuthLocalDatasource _localDatasource;

  AuthRepositoryImpl({
    AuthService? authService,
    AuthLocalDatasource? localDatasource,
  })  : _authService = authService ?? AuthService.instance,
        _localDatasource = localDatasource ?? AuthLocalDatasource.instance();

  @override
  FutureEither<AppUser> login({
    required String phone,
    required String password,
  }) async {
    final result = await _authService.login(phone: phone, password: password);

    return result.flatMap((data) {
      try {
        final token = data['token'] as String? ?? '';
        final role = data['role'] as String? ?? 'student';
        final profileJson = data['profile'] as Map<String, dynamic>?;

        if (profileJson == null) {
          return left(const ServerFailure('Login failed: missing profile data'));
        }

        final userModel = UserModel.fromJson(profileJson, role: role);

        // Persist session to secure storage (fire and forget)
        _localDatasource.saveSession(
          token: token,
          profileJson: userModel.toStorageJson(),
        );

        return right(userModel.toEntity());
      } catch (e) {
        return left(ServerFailure('Login failed: $e'));
      }
    });
  }

  @override
  FutureEither<AppUser?> restoreSession() async {
    try {
      final hasSession = await _localDatasource.hasSession();
      if (!hasSession) {
        return right(null);
      }

      final profileJson = await _localDatasource.getProfileJson();
      if (profileJson == null || profileJson.isEmpty) {
        return right(null);
      }

      final userModel = UserModel.fromStorageJson(profileJson);
      return right(userModel.toEntity());
    } catch (e) {
      // If storage is corrupted, clear it and return null
      await _localDatasource.clearSession();
      return right(null);
    }
  }

  @override
  FutureEither<void> logout() async {
    try {
      await _localDatasource.clearSession();
      return right(null);
    } catch (e) {
      return left(ServerFailure('Logout failed: $e'));
    }
  }
}
