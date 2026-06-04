import 'package:equatable/equatable.dart';

/// Represents a class taught by a teacher.
class ClassEntity extends Equatable {
  final String id;
  final String name;
  final String section;
  final String subject;
  final int studentCount;

  const ClassEntity({
    required this.id,
    required this.name,
    required this.section,
    required this.subject,
    required this.studentCount,
  });

  /// Display name like "Grade 10 - A".
  String get displayName => '$name - $section';

  @override
  List<Object?> get props => [id, name, section, subject, studentCount];
}
