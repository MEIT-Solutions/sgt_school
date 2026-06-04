import '../../domain/entities/class_entity.dart';
import '../../domain/entities/class_student_entity.dart';

/// DTO for [ClassEntity].
class ClassModel {
  final String id;
  final String name;
  final String section;
  final String subject;
  final int studentCount;

  const ClassModel({
    required this.id,
    required this.name,
    required this.section,
    required this.subject,
    required this.studentCount,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] as String,
      name: json['name'] as String,
      section: json['section'] as String,
      subject: json['subject'] as String,
      studentCount: (json['student_count'] ?? json['studentCount']) as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'section': section,
        'subject': subject,
        'student_count': studentCount,
      };

  ClassEntity toEntity() => ClassEntity(
        id: id,
        name: name,
        section: section,
        subject: subject,
        studentCount: studentCount,
      );
}

/// DTO for [ClassStudentEntity].
class ClassStudentModel {
  final String id;
  final String name;
  final String rollNo;
  final String? attendanceStatus;

  const ClassStudentModel({
    required this.id,
    required this.name,
    required this.rollNo,
    this.attendanceStatus,
  });

  factory ClassStudentModel.fromJson(Map<String, dynamic> json) {
    return ClassStudentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      rollNo: (json['roll_no'] ?? json['rollNo']) as String,
      attendanceStatus: (json['attendance_status'] ?? json['attendanceStatus']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'roll_no': rollNo,
        'attendance_status': attendanceStatus,
      };

  ClassStudentEntity toEntity() => ClassStudentEntity(
        id: id,
        name: name,
        rollNo: rollNo,
        attendanceStatus: attendanceStatus,
      );
}
