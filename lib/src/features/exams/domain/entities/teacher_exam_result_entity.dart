import 'package:equatable/equatable.dart';

/// Represents a single exam result record from the teacher's perspective.
class TeacherExamResultEntity extends Equatable {
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

  const TeacherExamResultEntity({
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

  bool get isPassed => status.toLowerCase() == 'pass';

  double get percentage => maxMarks > 0 ? (marksObtained / maxMarks) * 100 : 0;

  @override
  List<Object?> get props => [
        id, studentId, studentName, admissionNo, examId, examName,
        classId, className, subjectId, subjectName,
        marksObtained, maxMarks, grade, status,
      ];
}
