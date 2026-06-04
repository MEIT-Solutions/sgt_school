import 'package:sgt_school/src/utils/utils.dart';
import '../entities/notification_entity.dart';

/// Abstract contract for notification operations.
abstract class NotificationRepository {
  /// Gets all notifications for the current user.
  FutureEither<List<NotificationEntity>> getNotifications(String role);

  /// Marks a notification as read.
  FutureEither<void> markAsRead(String notificationId);
}
