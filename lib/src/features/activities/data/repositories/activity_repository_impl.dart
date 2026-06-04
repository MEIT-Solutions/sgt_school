import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/demo_data_service.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';

/// Implementation of [ActivityRepository].
///
/// Tries API first, falls back to [DemoDataService].
class ActivityRepositoryImpl implements ActivityRepository {
  final Dio _dio;
  final DemoDataService _demo;

  ActivityRepositoryImpl({Dio? dio, DemoDataService? demo})
      : _dio = dio ?? AppConfig.dio,
        _demo = demo ?? DemoDataService.instance;

  @override
  FutureEither<List<ActivityEntity>> getActivities({
    ActivityStatus? status,
  }) async {
    return runTask(() async {
      try {
        final response = await _dio.get(
          '/activities',
          queryParameters: {if (status != null) 'status': status.name},
        );
        return (response.data['data'] as List)
            .map((j) => ActivityModel.fromJson(j as Map<String, dynamic>).toEntity())
            .toList();
      } on DioException {
        AppLogger.warning('API unavailable, using demo activities data');
      }

      var activities = _demo
          .getActivities()
          .map((j) => ActivityModel.fromJson(j).toEntity())
          .toList();

      if (status != null) {
        activities = activities.where((a) => a.status == status).toList();
      }

      return activities;
    });
  }
}
