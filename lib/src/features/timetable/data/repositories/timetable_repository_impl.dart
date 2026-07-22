import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/timetable_entity.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../models/timetable_model.dart';

/// Implementation of [TimetableRepository].
class TimetableRepositoryImpl implements TimetableRepository {
  final Dio _dio;

  TimetableRepositoryImpl({Dio? dio}) : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<TimetableEntity> getWeeklyTimetable(
    String studentId,
  ) async {
    return runTask(() async {
      final response = await _dio.get('/students/$studentId/timetable');
      final data = response.data['data'] as Map<String, dynamic>;
      return TimetableModel.fromJson(data).toEntity();
    }, requiresNetwork: true);
  }
}
