import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/entities/teacher_subject_entity.dart';
import '../../domain/repositories/subject_repository.dart';
import '../models/subject_model.dart';
import '../models/teacher_subject_model.dart';

/// Implementation of [SubjectRepository].
class SubjectRepositoryImpl implements SubjectRepository {
  final Dio _dio;

  SubjectRepositoryImpl({Dio? dio})
      : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<List<SubjectEntity>> getSubjects(String studentId) async {
    return runTask(() async {
      final response = await _dio.get('/students/$studentId/subjects');
      return (response.data['data'] as List)
          .map((j) => SubjectModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    }, requiresNetwork: true);
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
