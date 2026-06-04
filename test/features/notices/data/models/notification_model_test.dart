import 'package:flutter_test/flutter_test.dart';
import 'package:sgt_school/src/features/notices/data/models/notification_model.dart';
import 'package:sgt_school/src/features/notices/domain/entities/notification_entity.dart';

void main() {
  group('NotificationModel', () {
    test('should parse fromJson correctly with backend response structure', () {
      final json = {
        'id': 3,
        'title': 'Fee Payment Received',
        'message': 'Payment received: 2000.0',
        'type': 'fee',
        'is_read': false
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, '3');
      expect(model.title, 'Fee Payment Received');
      expect(model.body, 'Payment received: 2000.0');
      expect(model.category, 'fee');
      expect(model.isRead, false);
    });

    test('should convert toEntity correctly', () {
      const model = NotificationModel(
        id: '2',
        title: 'Attendance Update',
        body: 'You are marked present on 2026-06-03',
        category: 'attendance',
        isRead: true,
        createdAt: '2026-06-03',
      );

      final entity = model.toEntity();

      expect(entity.id, '2');
      expect(entity.title, 'Attendance Update');
      expect(entity.body, 'You are marked present on 2026-06-03');
      expect(entity.category, NotificationCategory.attendance);
      expect(entity.isRead, true);
      expect(entity.createdAt, '2026-06-03');
    });

    test('should serialize toJson correctly', () {
      const model = NotificationModel(
        id: '1',
        title: 'Title',
        body: 'Body',
        category: 'notice',
        isRead: false,
        createdAt: 'date',
      );

      final json = model.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Title');
      expect(json['body'], 'Body');
      expect(json['category'], 'notice');
      expect(json['is_read'], false);
      expect(json['created_at'], 'date');
    });
  });
}
