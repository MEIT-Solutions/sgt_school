import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/demo_data_service.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/teacher_subject_entity.dart';
import '../../domain/repositories/subject_repository.dart';
import '../models/subject_model.dart';
import '../models/teacher_subject_model.dart';

/// Implementation of [SubjectRepository].
///
/// Tries API first, falls back to [DemoDataService].
class SubjectRepositoryImpl implements SubjectRepository {
  final Dio _dio;
  final DemoDataService _demo;

  SubjectRepositoryImpl({Dio? dio, DemoDataService? demo})
      : _dio = dio ?? AppConfig.dio,
        _demo = demo ?? DemoDataService.instance;

  @override
  FutureEither<List<SubjectEntity>> getSubjects(String studentId) async {
    return runTask(() async {
      try {
        final response = await _dio.get('/students/$studentId/subjects');
        return (response.data['data'] as List)
            .map((j) => SubjectModel.fromJson(j as Map<String, dynamic>).toEntity())
            .toList();
      } on DioException {
        AppLogger.warning('API unavailable, using demo subjects data');
      }

      return _demo
          .getSubjects(studentId)
          .map((j) => SubjectModel.fromJson(j).toEntity())
          .toList();
    });
  }

  @override
  FutureEither<List<TeacherSubjectEntity>> getTeacherSubjects(String teacherId) async {
    return runTask(() async {
      final response = await _dio.get('/teachers/$teacherId/subjects');
      AppLogger.info('Raw teacher subjects response: ${response.data}');
      final responseData = response.data;
      final data = (responseData is Map ? responseData['data'] : responseData) as List? ?? [];
      AppLogger.info('Parsed ${data.length} teacher subjects');
      return data
          .map((j) => TeacherSubjectModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    });
  }
}
