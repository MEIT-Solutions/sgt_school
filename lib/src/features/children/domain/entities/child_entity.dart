import 'package:equatable/equatable.dart';

/// Represents a child linked to a parent account.
class ChildEntity extends Equatable {
  final String studentId;
  final String name;
  final String grade;
  final String section;
  final String rollNo;
  final int attendancePercentage;
  final String? photoUrl;

  const ChildEntity({
    required this.studentId,
    required this.name,
    required this.grade,
    required this.section,
    required this.rollNo,
    required this.attendancePercentage,
    this.photoUrl,
  });

  /// Display name like "Grade 10 - A".
  String get classDisplay => '$grade - $section';

  @override
  List<Object?> get props => [
        studentId, name, grade, section,
        rollNo, attendancePercentage, photoUrl,
      ];
}
