import 'package:equatable/equatable.dart';

/// Represents a subject assigned to a student.
class SubjectEntity extends Equatable {
  final String id;
  final String name;
  final String teacher;
  final String icon;

  const SubjectEntity({
    required this.id,
    required this.name,
    required this.teacher,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, name, teacher, icon];
}
