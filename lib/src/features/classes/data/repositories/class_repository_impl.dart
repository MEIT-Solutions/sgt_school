import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/class_student_entity.dart';
import '../../domain/repositories/class_repository.dart';
import '../models/class_model.dart';

/// Implementation of [ClassRepository].
class ClassRepositoryImpl implements ClassRepository {
  final Dio _dio;

  ClassRepositoryImpl({Dio? dio}) : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<List<ClassStudentEntity>> getTeacherClasses(String teacherId) async {
    return runTask(() async {
      final response = await _dio.get(
        '/teachers/$teacherId/classes',
        queryParameters: {'page': 1, 'per_page': 100},
      );
      AppLogger.info('Raw classes response: ${response.data}');
      final responseData = response.data;
      final data = (responseData is Map ? responseData['data'] : responseData) as List? ?? [];
      AppLogger.info('Parsed ${data.length} students');
      return data
          .map((j) => ClassStudentModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    });
  }
}
