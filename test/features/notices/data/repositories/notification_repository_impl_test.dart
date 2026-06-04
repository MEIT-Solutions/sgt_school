import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sgt_school/src/features/notices/data/repositories/notification_repository_impl.dart';
import 'package:sgt_school/src/features/notices/domain/entities/notification_entity.dart';

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
      jsonEncode({'success': false, 'message': 'No handler'}),
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
  late Dio dio;
  late NotificationRepositoryImpl repository;

  setUp(() {
    mockAdapter = MockAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://example.com/api/v1'));
    dio.httpClientAdapter = mockAdapter;
    repository = NotificationRepositoryImpl(dio: dio);
  });

  group('getNotifications', () {
    test('returns notifications list on successful API response', () async {
      final apiResponse = {
        'success': true,
        'message': 'Success',
        'data': [
          {
            'id': 3,
            'title': 'Fee Payment Received',
            'message': 'Payment received: 2000.0',
            'type': 'fee',
            'is_read': false
          },
          {
            'id': 2,
            'title': 'Attendance Update',
            'message': 'You are marked present on 2026-06-03',
            'type': 'attendance',
            'is_read': true
          }
        ]
      };

      mockAdapter.handler = (options) {
        expect(options.path, '/notifications');
        return ResponseBody.fromString(
          jsonEncode(apiResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getNotifications('student');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected right, got left'),
        (notifications) {
          expect(notifications, hasLength(2));
          expect(notifications[0].id, '3');
          expect(notifications[0].title, 'Fee Payment Received');
          expect(notifications[0].body, 'Payment received: 2000.0');
          expect(notifications[0].category, NotificationCategory.fee);
          expect(notifications[0].isRead, false);

          expect(notifications[1].id, '2');
          expect(notifications[1].category, NotificationCategory.attendance);
          expect(notifications[1].isRead, true);
        },
      );
    });

    test('returns Failure on API error status code', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          'Internal Error',
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.textPlainContentType],
          },
        );
      };

      final result = await repository.getNotifications('student');

      expect(result.isLeft(), isTrue);
    });
  });

  group('markAsRead', () {
    test('sends patch request successfully', () async {
      mockAdapter.handler = (options) {
        expect(options.method, 'PATCH');
        expect(options.path, '/notifications/3/read');
        return ResponseBody.fromString(
          '',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.markAsRead('3');
      expect(result.isRight(), isTrue);
    });

    test('returns Failure on API error status code during markAsRead', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          'Internal Error',
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.textPlainContentType],
          },
        );
      };

      final result = await repository.markAsRead('3');
      expect(result.isLeft(), isTrue);
    });
  });
}
