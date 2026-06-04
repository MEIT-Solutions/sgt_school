import 'package:flutter_test/flutter_test.dart';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';

void main() {
  group('UserRole', () {
    test('fromString parses valid role strings', () {
      expect(UserRole.fromString('student'), UserRole.student);
      expect(UserRole.fromString('parent'), UserRole.parent);
      expect(UserRole.fromString('teacher'), UserRole.teacher);
    });

    test('fromString is case-insensitive', () {
      expect(UserRole.fromString('Student'), UserRole.student);
      expect(UserRole.fromString('PARENT'), UserRole.parent);
      expect(UserRole.fromString('Teacher'), UserRole.teacher);
    });

    test('fromString defaults to student for unknown values', () {
      expect(UserRole.fromString('admin'), UserRole.student);
      expect(UserRole.fromString(''), UserRole.student);
      expect(UserRole.fromString('unknown'), UserRole.student);
    });
  });

  group('AppUser', () {
    test('creates with required fields', () {
      const user = AppUser(
        id: '123',
        name: 'Test User',
        phone: '09123456789',
        role: UserRole.student,
      );

      expect(user.id, '123');
      expect(user.name, 'Test User');
      expect(user.phone, '09123456789');
      expect(user.role, UserRole.student);
      expect(user.grade, isNull);
      expect(user.photoUrl, isNull);
    });

    test('creates with all fields including optional', () {
      const user = AppUser(
        id: '456',
        name: 'Full User',
        phone: '09987654321',
        role: UserRole.teacher,
        grade: 'Grade 10',
        photoUrl: 'https://example.com/photo.jpg',
      );

      expect(user.grade, 'Grade 10');
      expect(user.photoUrl, 'https://example.com/photo.jpg');
    });

    test('empty factory creates sentinel with empty fields', () {
      final user = AppUser.empty();

      expect(user.id, '');
      expect(user.name, '');
      expect(user.phone, '');
      expect(user.role, UserRole.student);
      expect(user.isEmpty, isTrue);
      expect(user.isNotEmpty, isFalse);
    });

    test('isEmpty returns true when id is empty', () {
      const user = AppUser(id: '', name: 'Test', phone: '09123', role: UserRole.student);
      expect(user.isEmpty, isTrue);
    });

    test('isNotEmpty returns true when id is populated', () {
      const user = AppUser(id: '1', name: 'Test', phone: '09123', role: UserRole.student);
      expect(user.isNotEmpty, isTrue);
    });

    test('equality compares all props', () {
      const user1 = AppUser(
        id: '1',
        name: 'A',
        phone: '09123',
        role: UserRole.student,
        grade: 'Grade 10',
      );
      const user2 = AppUser(
        id: '1',
        name: 'A',
        phone: '09123',
        role: UserRole.student,
        grade: 'Grade 10',
      );
      const user3 = AppUser(
        id: '2',
        name: 'B',
        phone: '09456',
        role: UserRole.parent,
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });
}
