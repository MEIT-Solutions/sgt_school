import 'package:sgt_school/src/utils/utils.dart';
import '../entities/exam_entity.dart';

/// Abstract contract for exam data operations.
abstract class ExamRepository {
  /// Gets all exams for a student, optionally filtered by status.
  FutureEither<List<ExamEntity>> getExams(
    String studentId, {
    ExamStatus? status,
  });
}
