import '../../domain/entities/teacher_class_entity.dart';

/// DTO for [TeacherClassEntity] — handles JSON serialization.
class TeacherClassModel {
  final String id;
  final String name;
  final String? section;
  final String? grade;
  final String academicYear;
  final int studentCount;

  const TeacherClassModel({
    required this.id,
    required this.name,
    this.section,
    this.grade,
    required this.academicYear,
    required this.studentCount,
  });

  factory TeacherClassModel.fromJson(Map<String, dynamic> json) {
    return TeacherClassModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      section: json['section'] as String?,
      grade: json['grade'] as String?,
      academicYear: (json['academic_year'] ?? '').toString(),
      studentCount: json['student_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'section': section,
        'grade': grade,
        'academic_year': academicYear,
        'student_count': studentCount,
      };

  TeacherClassEntity toEntity() => TeacherClassEntity(
        id: id,
        name: name,
        section: section,
        grade: grade,
        academicYear: academicYear,
        studentCount: studentCount,
      );
}
