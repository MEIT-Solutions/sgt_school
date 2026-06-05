import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sgt_school/src/utils/error_handler.dart';

void main() {
  group('AppErrorHandler.format', () {
    test('returns the error string directly if the error is a String', () {
      final result = AppErrorHandler.format('Test error message');
      expect(result, 'Test error message');
    });

    test('extracts nested error message from DioException response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {
            'success': false,
            'error': {
              'code': 'INVALID_CREDENTIALS',
              'message': 'Invalid phone number or password'
            }
          },
        ),
      );

      final result = AppErrorHandler.format(dioException);
      expect(result, 'Invalid phone number or password');
    });

    test('extracts legacy message from DioException response when nested error is absent', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {
            'success': false,
            'message': 'Legacy error message'
          },
        ),
      );

      final result = AppErrorHandler.format(dioException);
      expect(result, 'Legacy error message');
    });

    test('falls back to DioException message when response data does not contain messages', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: 'Dio connection timeout',
      );

      final result = AppErrorHandler.format(dioException);
      expect(result, 'Dio connection timeout');
    });

    test('handles other exceptions using error.message or toString', () {
      final exception = Exception('Custom exception message');
      final result = AppErrorHandler.format(exception);
      expect(result.contains('Custom exception message'), isTrue);
    });
  });
}
