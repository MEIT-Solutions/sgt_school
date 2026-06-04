import '../../domain/entities/result_entity.dart';

/// DTO for [ResultEntity].
class ResultModel {
  final String id;
  final String subject;
  final int marks;
  final int total;
  final String grade;
  final String status;
  final String? admissionNo;

  const ResultModel({
    required this.id,
    required this.subject,
    required this.marks,
    required this.total,
    required this.grade,
    required this.status,
    this.admissionNo,
  });

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    final marksVal = (json['marks_obtained'] as num?)?.toInt() ?? (json['marks'] as num?)?.toInt() ?? 0;
    return ResultModel(
      id: json['id']?.toString() ?? '',
      subject: json['exam']?.toString() ?? json['subject']?.toString() ?? 'Exam',
      marks: marksVal,
      total: (json['total'] as num?)?.toInt() ?? 100,
      grade: json['grade']?.toString() ?? 'F',
      status: json['status']?.toString() ?? (marksVal >= 40 ? 'pass' : 'fail'),
      admissionNo: json['admission_no']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'exam': subject,
        'marks_obtained': marks,
        'total': total,
        'grade': grade,
        'status': status,
        'admission_no': admissionNo,
      };

  ResultEntity toEntity() => ResultEntity(
        id: id,
        subject: subject,
        marks: marks,
        total: total,
        grade: grade,
        status: status,
        admissionNo: admissionNo,
      );
}

/// DTO for [ResultSummary].
class ResultSummaryModel {
  final String examId;
  final String examName;
  final List<ResultModel> results;
  final int totalMarks;
  final int totalPossible;
  final double percentage;
  final String overallGrade;

  const ResultSummaryModel({
    required this.examId,
    required this.examName,
    required this.results,
    required this.totalMarks,
    required this.totalPossible,
    required this.percentage,
    required this.overallGrade,
  });

  factory ResultSummaryModel.fromJson(Map<String, dynamic> json) {
    return ResultSummaryModel(
      examId: json['exam_id'] as String? ?? '',
      examName: json['exam_name'] as String? ?? '',
      results: (json['results'] as List<dynamic>?)
              ?.map((r) => ResultModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      totalMarks: json['total_marks'] as int? ?? 0,
      totalPossible: json['total_possible'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      overallGrade: json['overall_grade'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'exam_id': examId,
        'exam_name': examName,
        'results': results.map((r) => r.toJson()).toList(),
        'total_marks': totalMarks,
        'total_possible': totalPossible,
        'percentage': percentage,
        'overall_grade': overallGrade,
      };

  ResultSummary toEntity() => ResultSummary(
        examId: examId,
        examName: examName,
        results: results.map((r) => r.toEntity()).toList(),
        totalMarks: totalMarks,
        totalPossible: totalPossible,
        percentage: percentage,
        overallGrade: overallGrade,
      );
}
