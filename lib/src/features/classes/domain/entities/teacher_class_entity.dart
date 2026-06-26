import 'package:equatable/equatable.dart';

/// Represents a class assigned to a teacher.
class TeacherClassEntity extends Equatable {
  final String id;
  final String name;
  final String? section;
  final String? grade;
  final String academicYear;
  final int studentCount;

  const TeacherClassEntity({
    required this.id,
    required this.name,
    this.section,
    this.grade,
    required this.academicYear,
    required this.studentCount,
  });

  @override
  List<Object?> get props => [id, name, section, grade, academicYear, studentCount];
}
