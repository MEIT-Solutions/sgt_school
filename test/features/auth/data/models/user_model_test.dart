import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgt_school/src/features/auth/data/models/user_model.dart';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';

void main() {
  const testJson = {
    'id': '123',
    'name': 'Test User',
    'phone': '09123456789',
    'grade': 'Grade 10',
    'photo_url': 'https://example.com/photo.jpg',
  };

  const testRole = 'student';

  group('UserModel.fromJson', () {
    test('parses a complete profile JSON with role', () {
      final model = UserModel.fromJson(testJson, role: testRole);

      expect(model.id, '123');
      expect(model.name, 'Test User');
      expect(model.phone, '09123456789');
      expect(model.role, 'student');
      expect(model.grade, 'Grade 10');
      expect(model.photoUrl, 'https://example.com/photo.jpg');
    });

    test('handles missing optional fields gracefully', () {
      final model = UserModel.fromJson(
        const {'id': '1', 'name': 'Min', 'phone': '09111'},
        role: 'teacher',
      );

      expect(model.id, '1');
      expect(model.role, 'teacher');
      expect(model.grade, isNull);
      expect(model.photoUrl, isNull);
    });

    test('handles null values with fallback to empty strings', () {
      final model = UserModel.fromJson(
        const {'id': null, 'name': null, 'phone': null},
        role: 'parent',
      );

      expect(model.id, '');
      expect(model.name, '');
      expect(model.phone, '');
      expect(model.role, 'parent');
    });
  });

  group('UserModel.toJson', () {
    test('serializes all fields including nulls', () {
      const model = UserModel(
        id: '123',
        name: 'Test',
        phone: '09123',
        role: 'student',
        grade: 'Grade 10',
        photoUrl: null,
      );

      final json = model.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'Test');
      expect(json['phone'], '09123');
      expect(json['role'], 'student');
      expect(json['grade'], 'Grade 10');
      expect(json['photo_url'], isNull);
    });
  });

  group('UserModel storage serialization', () {
    test('toStorageJson produces valid JSON string', () {
      const model = UserModel(
        id: '123',
        name: 'Test',
        phone: '09123',
        role: 'student',
      );

      final jsonString = model.toStorageJson();
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(decoded['id'], '123');
      expect(decoded['role'], 'student');
    });

    test('fromStorageJson round-trips correctly', () {
      const original = UserModel(
        id: '456',
        name: 'Round Trip',
        phone: '09999',
        role: 'teacher',
        grade: 'Grade 12',
        photoUrl: 'https://photo.url',
      );

      final jsonString = original.toStorageJson();
      final restored = UserModel.fromStorageJson(jsonString);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.phone, original.phone);
      expect(restored.role, original.role);
      expect(restored.grade, original.grade);
      expect(restored.photoUrl, original.photoUrl);
    });
  });

  group('UserModel.toEntity', () {
    test('maps to AppUser domain entity correctly', () {
      const model = UserModel(
        id: '123',
        name: 'Entity Test',
        phone: '09123',
        role: 'student',
        grade: 'Grade 10',
        photoUrl: 'https://photo.url',
      );

      final entity = model.toEntity();

      expect(entity, isA<AppUser>());
      expect(entity.id, '123');
      expect(entity.name, 'Entity Test');
      expect(entity.phone, '09123');
      expect(entity.role, UserRole.student);
      expect(entity.grade, 'Grade 10');
      expect(entity.photoUrl, 'https://photo.url');
    });

    test('maps unknown role string to UserRole.student', () {
      const model = UserModel(
        id: '1',
        name: 'X',
        phone: '09',
        role: 'superadmin',
      );

      expect(model.toEntity().role, UserRole.student);
    });
  });

  group('UserModel equality', () {
    test('two models with same props are equal', () {
      const a = UserModel(id: '1', name: 'A', phone: '09', role: 'student');
      const b = UserModel(id: '1', name: 'A', phone: '09', role: 'student');
      expect(a, equals(b));
    });

    test('two models with different props are not equal', () {
      const a = UserModel(id: '1', name: 'A', phone: '09', role: 'student');
      const b = UserModel(id: '2', name: 'B', phone: '09', role: 'teacher');
      expect(a, isNot(equals(b)));
    });
  });
}
