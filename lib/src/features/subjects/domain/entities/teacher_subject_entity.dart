import 'package:equatable/equatable.dart';

/// Represents a subject assigned to a teacher.
class TeacherSubjectEntity extends Equatable {
  final String id;
  final String name;
  final String subjectCode;
  final String? description;

  const TeacherSubjectEntity({
    required this.id,
    required this.name,
    required this.subjectCode,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, subjectCode, description];
}
