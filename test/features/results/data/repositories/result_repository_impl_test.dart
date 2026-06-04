import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sgt_school/src/features/results/data/repositories/result_repository_impl.dart';
import 'package:sgt_school/src/features/results/domain/entities/result_entity.dart';

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
  late ResultRepositoryImpl repository;

  setUp(() {
    mockAdapter = MockAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://example.com/api/v1'));
    dio.httpClientAdapter = mockAdapter;
    repository = ResultRepositoryImpl(dio: dio);
  });

  group('getResults', () {
    test('returns ResultSummary on successful API response', () async {
      final apiResponse = {
        'data': [
          {
            'id': 7,
            'student_id': 147,
            'admission_no': 'A005',
            'exam': 'Programming Exam',
            'marks_obtained': 50,
            'grade': 'B',
            'status': 'pass'
          }
        ],
        'count': 1
      };

      mockAdapter.handler = (options) {
        expect(options.path, '/students/147/results');
        return ResponseBody.fromString(
          jsonEncode(apiResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getResults('147');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected right, got left'),
        (summary) {
          expect(summary.results, hasLength(1));
          expect(summary.results.first.id, '7');
          expect(summary.results.first.subject, 'Programming Exam');
          expect(summary.results.first.marks, 50);
          expect(summary.results.first.total, 100);
          expect(summary.results.first.grade, 'B');
          expect(summary.results.first.status, 'pass');
          expect(summary.results.first.admissionNo, 'A005');
          expect(summary.totalMarks, 50);
          expect(summary.totalPossible, 100);
          expect(summary.percentage, 50.0);
          expect(summary.overallGrade, 'C'); // 50% => C based on _computeGrade
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

      final result = await repository.getResults('147');

      expect(result.isLeft(), isTrue);
    });
  });
}
