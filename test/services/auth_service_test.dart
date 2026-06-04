import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/auth_service.dart';

class MockAdapter implements HttpClientAdapter {
  ResponseBody Function(RequestOptions options)? handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) {
      return handler!(options);
    }
    return ResponseBody.fromString(
      jsonEncode({'success': false, 'message': 'No handler configured'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockAdapter mockAdapter;
  late AuthService authService;

  setUpAll(() {
    final dio = Dio(BaseOptions(baseUrl: 'http://150.95.85.135:8070/api/v1'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    try {
      AppConfig.dio = dio;
    } catch (_) {
      AppConfig.dio.httpClientAdapter = mockAdapter;
    }
    
    authService = AuthService.instance;
  });

  group('AuthService login', () {
    test('returns data map on success', () async {
      final successResponse = {
        'success': true,
        'message': 'Success',
        'data': {
          'token': 'mock-jwt-token',
          'role': 'student',
          'profile': {
            'id': 147,
            'name': 'Ellena',
            'phone': '09451512324',
          }
        }
      };

      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode(successResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await authService.login(
        phone: '09451512324',
        password: 'password',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected right, got left with: ${failure.message}'),
        (data) {
          expect(data['token'], 'mock-jwt-token');
          expect(data['role'], 'student');
          expect(data['profile']['name'], 'Ellena');
        },
      );
    });

    test('returns ServerFailure when API success is false', () async {
      final errorResponse = {
        'success': false,
        'message': 'Invalid credentials',
        'data': null
      };

      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          jsonEncode(errorResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await authService.login(
        phone: '09451512324',
        password: 'password',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure.message, 'Invalid credentials');
        },
        (_) => fail('Expected left, got right'),
      );
    });

    test('returns ServerFailure on HTTP error status code', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          'Internal Server Error',
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.textPlainContentType],
          },
        );
      };

      final result = await authService.login(
        phone: '09451512324',
        password: 'password',
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
