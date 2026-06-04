import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sgt_school/src/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sgt_school/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';
import 'package:sgt_school/src/services/auth_service.dart';
import 'package:sgt_school/src/services/secure_storage_service.dart';
import 'package:sgt_school/src/utils/failure.dart';

// ── Fakes ──────────────────────────────────────────────────────────────

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _store = {};

  FakeSecureStorageService() : super.forTesting();

  @override
  Future<Either<Failure, void>> write(String key, String value) async {
    _store[key] = value;
    return right(null);
  }

  @override
  Future<Either<Failure, String?>> read(String key) async {
    return right(_store[key]);
  }

  @override
  Future<Either<Failure, void>> delete(String key) async {
    _store.remove(key);
    return right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAll() async {
    _store.clear();
    return right(null);
  }

  @override
  Future<Either<Failure, bool>> containsKey(String key) async {
    return right(_store.containsKey(key));
  }
}

/// A fake AuthService that returns controlled results.
class FakeAuthService extends AuthService {
  FakeAuthService() : super.forTesting();

  bool shouldFail = false;
  String failMessage = 'Mock error';

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String phone,
    required String password,
  }) async {
    if (shouldFail) {
      return left(ServerFailure(failMessage));
    }
    return right({
      'token': 'fake-token-123',
      'role': 'student',
      'profile': {
        'id': 'stu-1',
        'name': 'Test Student',
        'phone': phone,
        'grade': 'Grade 10',
        'photo_url': null,
      },
    });
  }
}

void main() {
  late FakeAuthService fakeAuthService;
  late FakeSecureStorageService fakeStorage;
  late AuthLocalDatasource localDatasource;
  late AuthRepositoryImpl repository;

  setUp(() {
    fakeAuthService = FakeAuthService();
    fakeStorage = FakeSecureStorageService();
    localDatasource = AuthLocalDatasource(storage: fakeStorage);
    repository = AuthRepositoryImpl(
      authService: fakeAuthService,
      localDatasource: localDatasource,
    );
  });

  group('login', () {
    test('returns AppUser on success', () async {
      final result = await repository.login(
        phone: '09123456789',
        password: 'password123',
      );

      expect(result.isRight(), isTrue);
      final user = result.getOrElse((_) => AppUser.empty());
      expect(user.id, 'stu-1');
      expect(user.name, 'Test Student');
      expect(user.phone, '09123456789');
      expect(user.role, UserRole.student);
      expect(user.grade, 'Grade 10');
    });

    test('persists session to storage on success', () async {
      await repository.login(phone: '09123', password: 'pass123');

      final token = await localDatasource.getToken();
      final profile = await localDatasource.getProfileJson();

      expect(token, 'fake-token-123');
      expect(profile, isNotNull);
      expect(profile, contains('stu-1'));
    });

    test('returns Failure when service fails', () async {
      fakeAuthService.shouldFail = true;
      fakeAuthService.failMessage = 'Invalid credentials';

      final result = await repository.login(
        phone: '09000',
        password: 'wrong',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'Invalid credentials'),
        (_) => fail('Expected failure'),
      );
    });
  });

  group('restoreSession', () {
    test('returns null when no session exists', () async {
      final result = await repository.restoreSession();

      expect(result.isRight(), isTrue);
      final user = result.getOrElse((_) => AppUser.empty());
      expect(user, isNull);
    });

    test('returns AppUser from stored profile', () async {
      // First login to store a session
      await repository.login(phone: '09123', password: 'pass123');

      // Then restore
      final result = await repository.restoreSession();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Expected success'),
        (user) {
          expect(user, isNotNull);
          expect(user!.id, 'stu-1');
          expect(user.role, UserRole.student);
        },
      );
    });

    test('returns null and clears storage on corrupted data', () async {
      // Manually store invalid JSON
      await fakeStorage.write('user_profile', 'not-valid-json');
      await fakeStorage.write('auth_token', 'some-token');

      final result = await repository.restoreSession();

      expect(result.isRight(), isTrue);
      final user = result.getOrElse((_) => AppUser.empty());
      expect(user, isNull);
    });
  });

  group('logout', () {
    test('clears stored session', () async {
      await repository.login(phone: '09123', password: 'pass123');
      expect(await localDatasource.hasSession(), isTrue);

      await repository.logout();

      expect(await localDatasource.hasSession(), isFalse);
      expect(await localDatasource.getToken(), isNull);
      expect(await localDatasource.getProfileJson(), isNull);
    });

    test('returns Right(void) on success', () async {
      final result = await repository.logout();
      expect(result.isRight(), isTrue);
    });
  });
}
