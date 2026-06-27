import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/fee_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/fee_repository.dart';
import '../models/fee_model.dart';
import '../models/payment_model.dart';

/// Implementation of [FeeRepository].
///
/// Tries API first, falls back to [DemoDataService].
class FeeRepositoryImpl implements FeeRepository {
  final Dio _dio;

  FeeRepositoryImpl({Dio? dio})
      : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<StudentFeeData> getFees(String studentId) async {
    return runTask(() async {
      final response = await _dio.get('/students/$studentId/fees');
      final data = response.data;

      final feesList = (data['data'] as List)
          .map((j) => FeeModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();

      final summary = FeeSummaryModel.fromJson(
        data['summary'] as Map<String, dynamic>,
      ).toEntity();

      return StudentFeeData(fees: feesList, summary: summary);
    }, requiresNetwork: true);
  }

  @override
  FutureEither<List<PaymentEntity>> getPaymentHistory(String studentId) async {
    return runTask(() async {
      final response = await _dio.get('/students/$studentId/payments');
      return (response.data['data'] as List)
          .map((j) =>
              PaymentModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    }, requiresNetwork: true);
  }
}
