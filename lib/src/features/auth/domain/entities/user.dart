import 'package:equatable/equatable.dart';

/// The roles a user can have in the SGT School system.
enum UserRole {
  student,
  parent,
  teacher;

  /// Parses a role string from the API into a [UserRole].
  ///
  /// Defaults to [UserRole.student] if the string is unrecognized.
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value.toLowerCase(),
      orElse: () => UserRole.student,
    );
  }
}

/// Pure domain entity representing an authenticated user.
///
/// This entity is role-agnostic at the domain level — the [role] field
/// determines which features the user has access to.
class AppUser extends Equatable {
  final String id;
  final String name;
  final String phone;
  final UserRole role;

  // Student-specific
  final String? grade;
  final String? section;
  final String? rollNo;
  final String? admissionNo;

  // Common profile
  final String? email;
  final String? photoUrl;
  final String? dateOfBirth;
  final String? gender;
  final String? address;

  // Class info (student)
  final String? classTeacher;
  final String? academicYear;

  // Parent/emergency contact info
  final String? parentName;
  final String? parentPhone;
  final String? parentRelation;
  final String? emergencyContact;
  final String? emergencyName;

  // Teacher-specific
  final String? subject;
  final String? department;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.grade,
    this.section,
    this.rollNo,
    this.admissionNo,
    this.email,
    this.photoUrl,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.classTeacher,
    this.academicYear,
    this.parentName,
    this.parentPhone,
    this.parentRelation,
    this.emergencyContact,
    this.emergencyName,
    this.subject,
    this.department,
  });

  /// Creates an empty sentinel value for null-safety convenience.
  factory AppUser.empty() => const AppUser(
        id: '',
        name: '',
        phone: '',
        role: UserRole.student,
      );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  @override
  List<Object?> get props => [
        id, name, phone, role, grade, section, rollNo, admissionNo,
        email, photoUrl, dateOfBirth, gender, address,
        classTeacher, academicYear,
        parentName, parentPhone, parentRelation,
        emergencyContact, emergencyName,
        subject, department,
      ];
}
