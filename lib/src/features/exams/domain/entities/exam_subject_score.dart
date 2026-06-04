import 'package:equatable/equatable.dart';

/// Per-subject score within an exam.
class ExamSubjectScore extends Equatable {
  final String name;
  final int marks;
  final int total;

  const ExamSubjectScore({
    required this.name,
    required this.marks,
    required this.total,
  });

  double get percentage => total > 0 ? (marks / total) * 100 : 0;

  @override
  List<Object?> get props => [name, marks, total];
}
