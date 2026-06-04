import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

/// Implementation of [NotificationRepository].
class NotificationRepositoryImpl implements NotificationRepository {
  final Dio _dio;

  NotificationRepositoryImpl({Dio? dio})
      : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<List<NotificationEntity>> getNotifications(String role) async {
    return runTask(() async {
      final response = await _dio.get('/notifications');
      return (response.data['data'] as List)
          .map((j) => NotificationModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();
    });
  }

  @override
  FutureEither<void> markAsRead(String notificationId) async {
    return runTask(() async {
      await _dio.patch('/notifications/$notificationId/read');
    });
  }
}
