import '../../domain/entities/notification_entity.dart';

/// DTO for [NotificationEntity].
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String category;
  final bool isRead;
  final String createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      body: json['message'] as String? ?? json['body'] as String? ?? '',
      category: json['type'] as String? ?? json['category'] as String? ?? 'notice',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? json['time'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category,
        'is_read': isRead,
        'created_at': createdAt,
      };

  NotificationEntity toEntity() => NotificationEntity(
        id: id,
        title: title,
        body: body,
        category: NotificationCategory.fromString(category),
        isRead: isRead,
        createdAt: createdAt,
      );
}
