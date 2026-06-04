import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sgt_school/src/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:sgt_school/src/services/secure_storage_service.dart';
import 'package:sgt_school/src/utils/failure.dart';

/// A fake implementation of [SecureStorageService] for testing.
///
/// Uses an in-memory map to simulate secure storage without
/// needing platform channels.
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

void main() {
  late FakeSecureStorageService fakeStorage;
  late AuthLocalDatasource datasource;

  setUp(() {
    fakeStorage = FakeSecureStorageService();
    datasource = AuthLocalDatasource(storage: fakeStorage);
  });

  group('saveSession', () {
    test('persists token and profile JSON', () async {
      await datasource.saveSession(
        token: 'test-token',
        profileJson: '{"id":"1","name":"Test"}',
      );

      final token = await datasource.getToken();
      final profile = await datasource.getProfileJson();

      expect(token, 'test-token');
      expect(profile, '{"id":"1","name":"Test"}');
    });
  });

  group('getToken', () {
    test('returns null when no token is stored', () async {
      final token = await datasource.getToken();
      expect(token, isNull);
    });

    test('returns stored token', () async {
      await datasource.saveSession(token: 'abc', profileJson: '{}');
      final token = await datasource.getToken();
      expect(token, 'abc');
    });
  });

  group('getProfileJson', () {
    test('returns null when no profile is stored', () async {
      final profile = await datasource.getProfileJson();
      expect(profile, isNull);
    });
  });

  group('clearSession', () {
    test('removes all session data', () async {
      await datasource.saveSession(token: 'tok', profileJson: '{}');
      await datasource.clearSession();

      final token = await datasource.getToken();
      final profile = await datasource.getProfileJson();

      expect(token, isNull);
      expect(profile, isNull);
    });
  });

  group('hasSession', () {
    test('returns false when no session exists', () async {
      expect(await datasource.hasSession(), isFalse);
    });

    test('returns true when token is stored', () async {
      await datasource.saveSession(token: 'tok', profileJson: '{}');
      expect(await datasource.hasSession(), isTrue);
    });

    test('returns false after clearSession', () async {
      await datasource.saveSession(token: 'tok', profileJson: '{}');
      await datasource.clearSession();
      expect(await datasource.hasSession(), isFalse);
    });
  });
}
