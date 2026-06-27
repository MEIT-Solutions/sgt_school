import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/entities/teacher_exam_entity.dart';
import '../../domain/entities/teacher_exam_result_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../models/exam_model.dart';
import '../models/teacher_exam_model.dart';
import '../models/teacher_exam_result_model.dart';

/// Implementation of [ExamRepository].
class ExamRepositoryImpl implements ExamRepository {
  final Dio _dio;

  ExamRepositoryImpl({Dio? dio})
      : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<List<ExamEntity>> getExams(
    String studentId, {
    ExamStatus? status,
  }) async {
    return runTask(() async {
      final response = await _dio.get(
        '/students/$studentId/exams',
        queryParameters: {if (status != null) 'status': status.name},
      );
      return (response.data['data'] as List)
          .map((j) => ExamModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    }, requiresNetwork: true);
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
