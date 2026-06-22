import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../models/activity_model.dart';

/// Implementation of [ActivityRepository].
class ActivityRepositoryImpl implements ActivityRepository {
  final Dio _dio;

  ActivityRepositoryImpl({Dio? dio}) : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<List<ActivityEntity>> getActivities() async {
    return runTask(() async {
      final response = await _dio.get('/activities');
      final responseData = response.data;

      List<dynamic> rawList;
      final data = responseData['data'];

      if (data is List) {
        rawList = data;
      } else {
        AppLogger.warning(
          '[Activities] Unexpected response shape: ${responseData.runtimeType}',
        );
        rawList = [];
      }

      return rawList
          .map(
            (j) =>
                ActivityModel.fromJson(j as Map<String, dynamic>).toEntity(),
          )
          .where((a) => a.mobileVisible)
          .toList();
    });
  }
}
