import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../data/repositories/notification_repository_impl.dart';

/// Provider for notifications.
class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository;

  NotificationProvider({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepositoryImpl();

  List<NotificationEntity> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getNotifications(role);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load notifications: ${failure.message}');
      },
      (data) => _notifications = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await _repository.markAsRead(notificationId);
    result.fold(
      (failure) {
        AppLogger.error(
            'Failed to mark notification as read: ${failure.message}');
      },
      (_) {
        // Update the local list to reflect the read state immediately.
        _notifications = _notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationEntity(
              id: n.id,
              title: n.title,
              body: n.body,
              category: n.category,
              isRead: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        notifyListeners();
      },
    );
  }
}
