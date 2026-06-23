import '../../domain/entities/class_student_entity.dart';

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
      id: json['id'].toString(),
      name: json['name'] as String,
      rollNo: (json['roll_no'] ?? json['rollNo'] ?? '').toString(),
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
