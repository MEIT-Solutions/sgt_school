import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/demo_data_service.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/assignment_repository.dart';
import '../models/assignment_model.dart';

/// Implementation of [AssignmentRepository].
class AssignmentRepositoryImpl implements AssignmentRepository {
  final Dio _dio;
  final DemoDataService _demo;

  AssignmentRepositoryImpl({Dio? dio, DemoDataService? demo})
      : _dio = dio ?? AppConfig.dio,
        _demo = demo ?? DemoDataService.instance;

  @override
  FutureEither<List<AssignmentEntity>> getAssignments(
    String teacherId, {
    AssignmentStatus? status,
  }) async {
    return runTask(() async {
      try {
        final response = await _dio.get(
          '/teachers/$teacherId/assignments',
          queryParameters: {if (status != null) 'status': status.name},
        );
        return (response.data['data'] as List)
            .map((j) => AssignmentModel.fromJson(j as Map<String, dynamic>).toEntity())
            .toList();
      } on DioException {
        AppLogger.warning('API unavailable, using demo assignments');
      }

      var assignments = _demo
          .getAssignments(teacherId)
          .map((j) => AssignmentModel.fromJson(j).toEntity())
          .toList();
      if (status != null) {
        assignments = assignments.where((a) => a.status == status).toList();
      }
      return assignments;
    });
  }
}
