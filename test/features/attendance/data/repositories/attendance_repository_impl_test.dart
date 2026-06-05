import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sgt_school/src/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:sgt_school/src/features/attendance/domain/entities/attendance_record.dart';

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
  late AttendanceRepositoryImpl repository;

  setUp(() {
    mockAdapter = MockAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://example.com/api/v1'));
    dio.httpClientAdapter = mockAdapter;
    repository = AttendanceRepositoryImpl(dio: dio);
  });

  group('getAttendance', () {
    test('returns StudentAttendanceData on successful API response', () async {
      final apiResponse = {
        'success': true,
        'message': 'Success',
        'data': {
          'summary': {
            'present': 17,
            'absent': 1,
            'late': 4
          },
          'records': [
            {
              'date': '2026-06-01',
              'status': 'present',
              'check_in': '08:45:00',
              'check_out': '16:30:00'
            }
          ]
        }
      };

      mockAdapter.handler = (options) {
        expect(options.path, '/students/147/attendance');
        expect(options.queryParameters['month'], '2026-06');
        return ResponseBody.fromString(
          jsonEncode(apiResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getAttendance('147', month: '2026-06');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected right, got left'),
        (data) {
          expect(data.records, hasLength(1));
          expect(data.records.first.date, '2026-06-01');
          expect(data.records.first.status, AttendanceStatus.present);
          expect(data.summary.present, 17);
          expect(data.summary.absent, 1);
          expect(data.summary.late, 4);
          expect(data.summary.totalDays, 22);
        },
      );
    });

    test('returns Failure on API error status code', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          'Internal Server Error',
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.textPlainContentType],
          },
        );
      };

      final result = await repository.getAttendance('147');

      expect(result.isLeft(), isTrue);
    });
  });

  group('checkIn', () {
    test('calls post with student_id and returns AttendanceRecord on success', () async {
      final apiResponse = {
        'success': true,
        'message': 'Checked in successfully',
        'data': {
          'id': 105,
          'student_id': 147,
          'date': '2026-06-04',
          'check_in': '09:15:00',
          'check_out': null,
          'status': 'late'
        }
      };

      mockAdapter.handler = (options) {
        expect(options.path, '/attendance/check-in');
        final rawData = options.data;
        final Map<String, dynamic> data = rawData is String
            ? jsonDecode(rawData) as Map<String, dynamic>
            : rawData as Map<String, dynamic>;
        expect(data['student_id'], 147);
        return ResponseBody.fromString(
          jsonEncode(apiResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.checkIn('147');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected right, got left'),
        (record) {
          expect(record.id, '105');
          expect(record.studentId, '147');
          expect(record.date, '2026-06-04');
          expect(record.timeIn, DateTime.parse('2026-06-04T09:15:00'));
          expect(record.timeOut, isNull);
          expect(record.status, AttendanceStatus.late);
        },
      );
    });

    test('returns Failure on checkIn API error status code', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          'Bad Request',
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.textPlainContentType],
          },
        );
      };

      final result = await repository.checkIn('147');

      expect(result.isLeft(), isTrue);
    });
  });

  group('checkOut', () {
    test('calls post with student_id and returns AttendanceRecord on success', () async {
      final apiResponse = {
        'success': true,
        'message': 'Checked out successfully',
        'data': {
          'id': 105,
          'student_id': 147,
          'date': '2026-06-04',
          'check_in': '09:15:00',
          'check_out': '16:45:00',
          'status': 'late'
        }
      };

      mockAdapter.handler = (options) {
        expect(options.path, '/attendance/check-out');
        final rawData = options.data;
        final Map<String, dynamic> data = rawData is String
            ? jsonDecode(rawData) as Map<String, dynamic>
            : rawData as Map<String, dynamic>;
        expect(data['student_id'], 147);
        return ResponseBody.fromString(
          jsonEncode(apiResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.checkOut('147');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected right, got left'),
        (record) {
          expect(record.id, '105');
          expect(record.studentId, '147');
          expect(record.date, '2026-06-04');
          expect(record.timeIn, DateTime.parse('2026-06-04T09:15:00'));
          expect(record.timeOut, DateTime.parse('2026-06-04T16:45:00'));
          expect(record.status, AttendanceStatus.late);
        },
      );
    });

    test('returns Failure on checkOut API error status code', () async {
      mockAdapter.handler = (options) {
        return ResponseBody.fromString(
          'Bad Request',
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.textPlainContentType],
          },
        );
      };

      final result = await repository.checkOut('147');

      expect(result.isLeft(), isTrue);
    });
  });
}
