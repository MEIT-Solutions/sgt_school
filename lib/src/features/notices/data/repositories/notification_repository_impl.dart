import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

/// Implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;

  NotificationRepositoryImpl({Dio? dio}) : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<List<NotificationEntity>> getNotifications(String role) async {
    return runTask(() async {
      final response = await _dio.get('/notifications');
      final responseData = response.data;

      // Safely extract the raw list — handles both flat and nested shapes:
      //   Shape A: { "data": [ ... ] }
      //   Shape B: { "data": { "notifications": [ ... ] } }
      List<dynamic> rawList;
      final data = responseData['data'];

      if (data is List) {
        rawList = data;
      } else if (data is Map<String, dynamic>) {
        // Try common nested list keys
        final nested =
            data['notifications'] ?? data['results'] ?? data['items'];
        if (nested is List) {
          rawList = nested;
        } else {
          AppLogger.warning(
            '[Notifications] Unexpected nested data shape: ${data.runtimeType} — $data',
          );
          rawList = [];
        }
      } else {
        AppLogger.warning(
          '[Notifications] Unexpected response shape: ${responseData.runtimeType} — $responseData',
        );
        rawList = [];
      }

      return rawList
          .map((j) =>
              NotificationModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    });
  }

  @override
  FutureEither<void> markAsRead(String notificationId) async {
    return runTask(() async {
      await _dio.post('/notifications/$notificationId/read');
    });
  }
}
