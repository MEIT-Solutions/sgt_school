import '../../domain/entities/teacher_exam_result_entity.dart';

/// DTO for [TeacherExamResultEntity] — handles JSON serialization.
class TeacherExamResultModel {
  final String id;
  final String studentId;
  final String studentName;
  final String admissionNo;
  final String examId;
  final String examName;
  final String? classId;
  final String? className;
  final String? subjectId;
  final String? subjectName;
  final int marksObtained;
  final int maxMarks;
  final String grade;
  final String status;

  const TeacherExamResultModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.admissionNo,
    required this.examId,
    required this.examName,
    this.classId,
    this.className,
    this.subjectId,
    this.subjectName,
    required this.marksObtained,
    required this.maxMarks,
    required this.grade,
    required this.status,
  });

  factory TeacherExamResultModel.fromJson(Map<String, dynamic> json) {
    return TeacherExamResultModel(
      id: (json['id'] ?? '').toString(),
      studentId: (json['student_id'] ?? '').toString(),
      studentName: json['student_name'] as String? ?? '',
      admissionNo: (json['admission_no'] ?? '').toString(),
      examId: (json['exam_id'] ?? '').toString(),
      examName: json['exam_name'] as String? ?? '',
      classId: json['class_id']?.toString(),
      className: json['class_name'] as String?,
      subjectId: json['subject_id']?.toString(),
      subjectName: json['subject_name'] as String?,
      marksObtained: json['marks_obtained'] as int? ?? 0,
      maxMarks: json['max_marks'] as int? ?? 0,
      grade: json['grade'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'student_name': studentName,
        'admission_no': admissionNo,
        'exam_id': examId,
        'exam_name': examName,
        'class_id': classId,
        'class_name': className,
        'subject_id': subjectId,
        'subject_name': subjectName,
        'marks_obtained': marksObtained,
        'max_marks': maxMarks,
        'grade': grade,
        'status': status,
      };

  TeacherExamResultEntity toEntity() => TeacherExamResultEntity(
        id: id,
        studentId: studentId,
        studentName: studentName,
        admissionNo: admissionNo,
        examId: examId,
        examName: examName,
        classId: classId,
        className: className,
        subjectId: subjectId,
        subjectName: subjectName,
        marksObtained: marksObtained,
        maxMarks: maxMarks,
        grade: grade,
        status: status,
      );
}
