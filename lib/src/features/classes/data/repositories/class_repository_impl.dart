import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/demo_data_service.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/class_student_entity.dart';
import '../../domain/repositories/class_repository.dart';
import '../models/class_model.dart';

/// Implementation of [ClassRepository].
class ClassRepositoryImpl implements ClassRepository {
  final Dio _dio;
  final DemoDataService _demo;

  ClassRepositoryImpl({Dio? dio, DemoDataService? demo})
      : _dio = dio ?? AppConfig.dio,
        _demo = demo ?? DemoDataService.instance;

  @override
  FutureEither<List<ClassEntity>> getTeacherClasses(String teacherId) async {
    return runTask(() async {
      try {
        final response = await _dio.get('/teachers/$teacherId/classes');
        return (response.data['data'] as List)
            .map((j) => ClassModel.fromJson(j as Map<String, dynamic>).toEntity())
            .toList();
      } on DioException {
        AppLogger.warning('API unavailable, using demo classes');
      }
      return _demo
          .getTeacherClasses(teacherId)
          .map((j) => ClassModel.fromJson(j).toEntity())
          .toList();
    });
  }

  @override
  FutureEither<List<ClassStudentEntity>> getClassStudents(String classId) async {
    return runTask(() async {
      try {
        final response = await _dio.get('/classes/$classId/students');
        return (response.data['data'] as List)
            .map((j) => ClassStudentModel.fromJson(j as Map<String, dynamic>).toEntity())
            .toList();
      } on DioException {
        AppLogger.warning('API unavailable, using demo students');
      }
      return _demo
          .getClassStudents(classId)
          .map((j) => ClassStudentModel.fromJson(j).toEntity())
          .toList();
    });
  }
}
