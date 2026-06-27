import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/assignment_repository.dart';
import '../models/assignment_model.dart';

/// Implementation of [AssignmentRepository].
class AssignmentRepositoryImpl implements AssignmentRepository {
  final Dio _dio;

  AssignmentRepositoryImpl({Dio? dio})
      : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<List<AssignmentEntity>> getAssignments(
    String teacherId, {
    AssignmentStatus? status,
  }) async {
    return runTask(() async {
      final response = await _dio.get(
        '/teachers/$teacherId/assignments',
        queryParameters: {if (status != null) 'status': status.name},
      );
      return (response.data['data'] as List)
          .map((j) => AssignmentModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    }, requiresNetwork: true);
  }
}
