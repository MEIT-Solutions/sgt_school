import '../../domain/entities/child_entity.dart';

/// DTO for [ChildEntity].
class ChildModel {
  final String studentId;
  final String name;
  final String grade;
  final String section;
  final String rollNo;
  final int attendancePercentage;
  final String? photoUrl;

  const ChildModel({
    required this.studentId,
    required this.name,
    required this.grade,
    required this.section,
    required this.rollNo,
    required this.attendancePercentage,
    this.photoUrl,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      studentId: (json['student_id'] ?? json['studentId']) as String,
      name: json['name'] as String,
      grade: json['grade'] as String,
      section: json['section'] as String,
      rollNo: (json['roll_no'] ?? json['rollNo']) as String,
      attendancePercentage: (json['attendance_percentage'] ?? json['attendancePercentage']) as int? ?? 0,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'name': name,
        'grade': grade,
        'section': section,
        'roll_no': rollNo,
        'attendance_percentage': attendancePercentage,
        'photo_url': photoUrl,
      };

  ChildEntity toEntity() => ChildEntity(
        studentId: studentId,
        name: name,
        grade: grade,
        section: section,
        rollNo: rollNo,
        attendancePercentage: attendancePercentage,
        photoUrl: photoUrl,
      );
}
