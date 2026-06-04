import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sgt_school/src/features/notices/domain/entities/notification_entity.dart';
import 'package:sgt_school/src/features/notices/domain/repositories/notification_repository.dart';
import 'package:sgt_school/src/features/notices/presentation/providers/notification_provider.dart';
import 'package:sgt_school/src/utils/failure.dart';
import 'package:sgt_school/src/utils/typedefs.dart';

class FakeNotificationRepository implements NotificationRepository {
  bool shouldFail = false;
  String failMessage = 'Mock notification repository error';

  final List<NotificationEntity> notificationsList = const [
    NotificationEntity(
      id: '3',
      title: 'Fee Payment Received',
      body: 'Payment received: 2000.0',
      category: NotificationCategory.fee,
      isRead: false,
      createdAt: '2026-06-03',
    ),
    NotificationEntity(
      id: '2',
      title: 'Attendance Update',
      body: 'You are marked present on 2026-06-03',
      category: NotificationCategory.attendance,
      isRead: true,
      createdAt: '2026-06-03',
    ),
  ];

  @override
  FutureEither<List<NotificationEntity>> getNotifications(String role) async {
    if (shouldFail) return left(ServerFailure(failMessage));
    return right(notificationsList);
  }

  @override
  FutureEither<void> markAsRead(String notificationId) async {
    if (shouldFail) return left(ServerFailure(failMessage));
    return right(null);
  }
}

void main() {
  late FakeNotificationRepository fakeRepository;
  late NotificationProvider provider;

  setUp(() {
    fakeRepository = FakeNotificationRepository();
    provider = NotificationProvider(repository: fakeRepository);
  });

  group('NotificationProvider loadNotifications', () {
    test('loads notifications list on success', () async {
      expect(provider.isLoading, isFalse);
      expect(provider.notifications, isEmpty);
      expect(provider.error, isNull);
      expect(provider.unreadCount, 0);

      final future = provider.loadNotifications('student');
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.notifications, hasLength(2));
      expect(provider.unreadCount, 1);
      expect(provider.notifications.first.title, 'Fee Payment Received');
      expect(provider.error, isNull);
    });

    test('sets error message on failure', () async {
      fakeRepository.shouldFail = true;
      fakeRepository.failMessage = 'Server error loading notifications';

      await provider.loadNotifications('student');

      expect(provider.isLoading, isFalse);
      expect(provider.notifications, isEmpty);
      expect(provider.error, 'Server error loading notifications');
    });
  });

  group('NotificationProvider markAsRead', () {
    test('calls repository markAsRead successfully', () async {
      final result = provider.markAsRead('3');
      await expectLater(result, completes);
    });
  });
}
