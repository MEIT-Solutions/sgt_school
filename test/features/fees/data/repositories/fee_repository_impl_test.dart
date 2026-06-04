import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:sgt_school/src/features/fees/data/repositories/fee_repository_impl.dart';
import 'package:sgt_school/src/features/fees/domain/entities/fee_entity.dart';

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
  late Dio dio;
  late FeeRepositoryImpl repository;

  setUp(() {
    mockAdapter = MockAdapter();
    dio = Dio(BaseOptions(baseUrl: 'http://example.com/api/v1'));
    dio.httpClientAdapter = mockAdapter;
    repository = FeeRepositoryImpl(dio: dio);
  });

  group('getFees', () {
    test('returns StudentFeeData on successful API response', () async {
      final apiResponse = {
        'data': [
          {
            'id': 7,
            'student_name': 'Ellena',
            'fee_type': 'Monthy',
            'amount_paid': 2000.0,
            'total_paid': 2000.0,
            'due': 0.0,
            'total_due': 0.0,
            'payment_status': 'paid',
            'payment_date': '2026-06-03',
            'fees_paid_by': 'parents',
            'payment_mode': 'cash'
          }
        ],
        'summary': {
          'total_fees': 2000.0,
          'total_paid': 2000.0,
          'total_due': 0.0
        }
      };

      mockAdapter.handler = (options) {
        expect(options.path, '/students/147/fees');
        return ResponseBody.fromString(
          jsonEncode(apiResponse),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getFees('147');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected right, got left with: ${failure.message}'),
        (feeData) {
          expect(feeData.fees, hasLength(1));
          expect(feeData.fees.first.id, '7');
          expect(feeData.fees.first.name, 'Monthy');
          expect(feeData.fees.first.amount, 2000.0);
          expect(feeData.fees.first.status, FeeStatus.paid);
          expect(feeData.fees.first.dueDate, '2026-06-03');

          expect(feeData.summary.totalFees, 2000.0);
          expect(feeData.summary.totalPaid, 2000.0);
          expect(feeData.summary.totalDue, 0.0);
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

      final result = await repository.getFees('147');

      expect(result.isLeft(), isTrue);
    });
  });
}
