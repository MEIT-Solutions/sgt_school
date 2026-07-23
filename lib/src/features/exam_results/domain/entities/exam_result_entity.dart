import 'package:equatable/equatable.dart';

/// Per-subject result from an exam.
class ExamResultEntity extends Equatable {
  final String id;
  final String subject;
  final int marks;
  final int total;
  final String grade;
  final String status;
  final String? admissionNo;

  const ExamResultEntity({
    required this.id,
    required this.subject,
    required this.marks,
    required this.total,
    required this.grade,
    required this.status,
    this.admissionNo,
  });

  bool get isPass => status.toLowerCase() == 'pass';
  double get percentage => total > 0 ? (marks / total) * 100 : 0;

  @override
  List<Object?> get props => [id, subject, marks, total, grade, status, admissionNo];
}

/// Aggregated result wrapper for an exam.
class ExamResultSummary extends Equatable {
  final String examId;
  final String examName;
  final List<ExamResultEntity> results;
  final int totalMarks;
  final int totalPossible;
  final double percentage;
  final String overallGrade;

  const ExamResultSummary({
    required this.examId,
    required this.examName,
    required this.results,
    required this.totalMarks,
    required this.totalPossible,
    required this.percentage,
    required this.overallGrade,
  });

  @override
  List<Object?> get props => [
        examId, examName, results, totalMarks,
        totalPossible, percentage, overallGrade,
      ];
}
