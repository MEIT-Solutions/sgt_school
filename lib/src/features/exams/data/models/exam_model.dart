import '../../domain/entities/exam_entity.dart';
import '../../domain/entities/exam_subject_score.dart';

/// DTO for [ExamSubjectScore].
class ExamSubjectScoreModel {
  final String name;
  final int marks;
  final int total;

  const ExamSubjectScoreModel({
    required this.name,
    required this.marks,
    required this.total,
  });

  factory ExamSubjectScoreModel.fromJson(Map<String, dynamic> json) {
    return ExamSubjectScoreModel(
      name: json['name'] as String,
      marks: json['marks'] as int,
      total: json['total'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'marks': marks,
        'total': total,
      };

  ExamSubjectScore toEntity() => ExamSubjectScore(
        name: name,
        marks: marks,
        total: total,
      );
}

/// DTO for [ExamEntity] — handles JSON serialization.
class ExamModel {
  final String id;
  final String name;
  final String className;
  final String date;
  final String status;
  final double? percentage;
  final String? grade;
  final List<ExamSubjectScoreModel> subjects;

  const ExamModel({
    required this.id,
    required this.name,
    required this.className,
    required this.date,
    required this.status,
    this.percentage,
    this.grade,
    this.subjects = const [],
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      className: (json['class_name'] ?? json['class']) as String? ?? '',
      date: json['date'] as String,
      status: json['status'] as String,
      percentage: (json['percentage'] as num?)?.toDouble(),
      grade: json['grade'] as String?,
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((s) => ExamSubjectScoreModel.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'class_name': className,
        'date': date,
        'status': status,
        'percentage': percentage,
        'grade': grade,
        'subjects': subjects.map((s) => s.toJson()).toList(),
      };

  ExamEntity toEntity() => ExamEntity(
        id: id,
        name: name,
        className: className,
        date: date,
        status: ExamStatus.fromString(status),
        percentage: percentage,
        grade: grade,
        subjects: subjects.map((s) => s.toEntity()).toList(),
      );
}
