import 'package:equatable/equatable.dart';

/// Category of a notification.
enum NotificationCategory {
  exam,
  event,
  fee,
  notice,
  assignment,
  attendance;

  static NotificationCategory fromString(String value) {
    return NotificationCategory.values.firstWhere(
      (c) => c.name == value.toLowerCase(),
      orElse: () => NotificationCategory.notice,
    );
  }
}

/// Represents a notification/notice sent to a user.
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final bool isRead;
  final String createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, body, category, isRead, createdAt];
}
