import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/demo_data_service.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/entities/teacher_exam_entity.dart';
import '../../domain/entities/teacher_exam_result_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../models/exam_model.dart';
import '../models/teacher_exam_model.dart';
import '../models/teacher_exam_result_model.dart';

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

  @override
  FutureEither<List<TeacherExamEntity>> getTeacherExams(String teacherId) async {
    return runTask(() async {
      final response = await _dio.get('/teachers/$teacherId/exams');
      AppLogger.info('Raw teacher exams response: ${response.data}');
      final responseData = response.data;
      final data = (responseData is Map ? responseData['data'] : responseData) as List? ?? [];
      AppLogger.info('Parsed ${data.length} teacher exams');
      return data
          .map((j) => TeacherExamModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    });
  }

  @override
  FutureEither<List<TeacherExamResultEntity>> getTeacherExamResults(String teacherId) async {
    return runTask(() async {
      final response = await _dio.get('/teachers/$teacherId/exam-results');
      AppLogger.info('Raw teacher exam results response: ${response.data}');
      final responseData = response.data;
      final data = (responseData is Map ? responseData['data'] : responseData) as List? ?? [];
      AppLogger.info('Parsed ${data.length} teacher exam results');
      return data
          .map((j) => TeacherExamResultModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    });
  }
}
