import 'package:sgt_school/src/utils/utils.dart';
import '../entities/exam_entity.dart';
import '../entities/teacher_exam_entity.dart';
import '../entities/teacher_exam_result_entity.dart';

/// Abstract contract for exam data operations.
abstract class ExamRepository {
  /// Gets all exams for a student, optionally filtered by status.
  FutureEither<List<ExamEntity>> getExams(
    String studentId, {
    ExamStatus? status,
  });

  /// Gets all exams for a teacher.
  FutureEither<List<TeacherExamEntity>> getTeacherExams(String teacherId);

  /// Gets all exam results for a teacher.
  FutureEither<List<TeacherExamResultEntity>> getTeacherExamResults(String teacherId);
}
