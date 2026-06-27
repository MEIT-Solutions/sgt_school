import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/child_repository.dart';
import '../models/child_model.dart';

/// Implementation of [ChildRepository].
class ChildRepositoryImpl implements ChildRepository {
  final Dio _dio;

  ChildRepositoryImpl({Dio? dio})
      : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<List<ChildEntity>> getChildren(String parentId) async {
    return runTask(() async {
      final response = await _dio.get('/parents/$parentId/children');
      return (response.data['data'] as List)
          .map((j) => ChildModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    }, requiresNetwork: true);
  }
}
