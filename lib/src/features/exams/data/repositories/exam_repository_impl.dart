import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/demo_data_service.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../models/exam_model.dart';

/// Implementation of [ExamRepository].
///
/// Tries API first, falls back to [DemoDataService].
class ExamRepositoryImpl implements ExamRepository {
  final Dio _dio;
  final DemoDataService _demo;

  ExamRepositoryImpl({Dio? dio, DemoDataService? demo})
      : _dio = dio ?? AppConfig.dio,
        _demo = demo ?? DemoDataService.instance;

  @override
  FutureEither<List<ExamEntity>> getExams(
    String studentId, {
    ExamStatus? status,
  }) async {
    return runTask(() async {
      try {
        final response = await _dio.get(
          '/students/$studentId/exams',
          queryParameters: {if (status != null) 'status': status.name},
        );
        return (response.data['data'] as List)
            .map((j) => ExamModel.fromJson(j as Map<String, dynamic>).toEntity())
            .toList();
      } on DioException {
        AppLogger.warning('API unavailable, using demo exams data');
      }

      var exams = _demo
          .getExams(studentId)
          .map((j) => ExamModel.fromJson(j).toEntity())
          .toList();

      if (status != null) {
        exams = exams.where((e) => e.status == status).toList();
      }

      return exams;
    });
  }
}
