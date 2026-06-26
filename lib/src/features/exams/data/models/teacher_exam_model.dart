import '../../domain/entities/teacher_exam_entity.dart';

/// DTO for [TeacherExamEntity] — handles JSON serialization.
class TeacherExamModel {
  final String id;
  final String name;
  final String? classId;
  final String? className;
  final String? subjectId;
  final String? subjectName;
  final String examDatetime;
  final int maxMarks;
  final int passingMarks;

  const TeacherExamModel({
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

  factory TeacherExamModel.fromJson(Map<String, dynamic> json) {
    return TeacherExamModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      classId: json['class_id']?.toString(),
      className: json['class_name'] as String?,
      subjectId: json['subject_id']?.toString(),
      subjectName: json['subject_name'] as String?,
      examDatetime: json['exam_datetime'] as String? ?? '',
      maxMarks: json['max_marks'] as int? ?? 0,
      passingMarks: json['passing_marks'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'class_id': classId,
        'class_name': className,
        'subject_id': subjectId,
        'subject_name': subjectName,
        'exam_datetime': examDatetime,
        'max_marks': maxMarks,
        'passing_marks': passingMarks,
      };

  TeacherExamEntity toEntity() => TeacherExamEntity(
        id: id,
        name: name,
        classId: classId,
        className: className,
        subjectId: subjectId,
        subjectName: subjectName,
        examDatetime: examDatetime,
        maxMarks: maxMarks,
        passingMarks: passingMarks,
      );
}
