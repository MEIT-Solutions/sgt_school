import 'package:equatable/equatable.dart';

/// Represents a student within a class (teacher's view).
class ClassStudentEntity extends Equatable {
  final String id;
  final String name;
  final String rollNo;
  final String? attendanceStatus;

  const ClassStudentEntity({
    required this.id,
    required this.name,
    required this.rollNo,
    this.attendanceStatus,
  });

  @override
  List<Object?> get props => [id, name, rollNo, attendanceStatus];
}
