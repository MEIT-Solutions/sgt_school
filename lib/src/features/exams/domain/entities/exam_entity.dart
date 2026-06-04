import 'package:equatable/equatable.dart';

import 'exam_subject_score.dart';

/// Status of an exam.
enum ExamStatus {
  upcoming,
  completed;

  static ExamStatus fromString(String value) {
    return ExamStatus.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => ExamStatus.upcoming,
    );
  }
}

/// Represents an exam with optional per-subject scores.
class ExamEntity extends Equatable {
  final String id;
  final String name;
  final String className;
  final String date;
  final ExamStatus status;
  final double? percentage;
  final String? grade;
  final List<ExamSubjectScore> subjects;

  const ExamEntity({
    required this.id,
    required this.name,
    required this.className,
    required this.date,
    required this.status,
    this.percentage,
    this.grade,
    this.subjects = const [],
  });

  bool get isCompleted => status == ExamStatus.completed;
  bool get isUpcoming => status == ExamStatus.upcoming;

  @override
  List<Object?> get props => [id, name, className, date, status, percentage, grade, subjects];
}
