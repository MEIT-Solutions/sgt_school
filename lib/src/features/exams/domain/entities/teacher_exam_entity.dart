import 'package:equatable/equatable.dart';

/// Represents an exam from the teacher's perspective.
class TeacherExamEntity extends Equatable {
  final String id;
  final String name;
  final String? classId;
  final String? className;
  final String? subjectId;
  final String? subjectName;
  final String examDatetime;
  final int maxMarks;
  final int passingMarks;

  const TeacherExamEntity({
    required this.id,
    required this.name,
    this.classId,
    this.className,
    this.subjectId,
    this.subjectName,
    required this.examDatetime,
    required this.maxMarks,
    required this.passingMarks,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        classId,
        className,
        subjectId,
        subjectName,
        examDatetime,
        maxMarks,
        passingMarks,
      ];
}
