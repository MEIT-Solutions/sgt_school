import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/demo_data_service.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subject_repository.dart';
import '../models/subject_model.dart';

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
}
