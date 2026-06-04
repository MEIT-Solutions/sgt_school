import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';

/// Data Transfer Object for the user profile returned by the API.
///
/// Handles JSON serialization and maps to the domain [AppUser] entity.
class UserModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String role;
  final String? grade;
  final String? section;
  final String? rollNo;
  final String? admissionNo;
  final String? email;
  final String? photoUrl;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? classTeacher;
  final String? academicYear;
  final String? parentName;
  final String? parentPhone;
  final String? parentRelation;
  final String? emergencyContact;
  final String? emergencyName;
  final String? subject;
  final String? department;

  const UserModel({
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

  /// Deserializes from the API `profile` JSON object.
  factory UserModel.fromJson(Map<String, dynamic> json, {required String role}) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: role,
      grade: json['grade']?.toString(),
      section: json['section']?.toString(),
      rollNo: json['roll_no']?.toString(),
      admissionNo: json['admission_no']?.toString(),
      email: json['email']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      classTeacher: json['class_teacher']?.toString(),
      academicYear: json['academic_year']?.toString(),
      parentName: json['parent_name']?.toString(),
      parentPhone: json['parent_phone']?.toString(),
      parentRelation: json['parent_relation']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      emergencyName: json['emergency_name']?.toString(),
      subject: json['subject']?.toString(),
      department: json['department']?.toString(),
    );
  }

  /// Deserializes from a JSON string stored in secure storage.
  factory UserModel.fromStorageJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? 'student',
      grade: json['grade']?.toString(),
      section: json['section']?.toString(),
      rollNo: json['roll_no']?.toString(),
      admissionNo: json['admission_no']?.toString(),
      email: json['email']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      gender: json['gender']?.toString(),
      address: json['address']?.toString(),
      classTeacher: json['class_teacher']?.toString(),
      academicYear: json['academic_year']?.toString(),
      parentName: json['parent_name']?.toString(),
      parentPhone: json['parent_phone']?.toString(),
      parentRelation: json['parent_relation']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      emergencyName: json['emergency_name']?.toString(),
      subject: json['subject']?.toString(),
      department: json['department']?.toString(),
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'grade': grade,
      'section': section,
      'roll_no': rollNo,
      'admission_no': admissionNo,
      'email': email,
      'photo_url': photoUrl,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'address': address,
      'class_teacher': classTeacher,
      'academic_year': academicYear,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_relation': parentRelation,
      'emergency_contact': emergencyContact,
      'emergency_name': emergencyName,
      'subject': subject,
      'department': department,
    };
  }

  /// Serializes to a JSON string for secure storage.
  String toStorageJson() => jsonEncode(toJson());

  /// Maps to the domain [AppUser] entity.
  AppUser toEntity() {
    return AppUser(
      id: id,
      name: name,
      phone: phone,
      role: UserRole.fromString(role),
      grade: grade,
      section: section,
      rollNo: rollNo,
      admissionNo: admissionNo,
      email: email,
      photoUrl: photoUrl,
      dateOfBirth: dateOfBirth,
      gender: gender,
      address: address,
      classTeacher: classTeacher,
      academicYear: academicYear,
      parentName: parentName,
      parentPhone: parentPhone,
      parentRelation: parentRelation,
      emergencyContact: emergencyContact,
      emergencyName: emergencyName,
      subject: subject,
      department: department,
    );
  }

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
