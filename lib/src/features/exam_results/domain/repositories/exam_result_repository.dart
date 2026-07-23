import 'package:sgt_school/src/utils/utils.dart';
import '../entities/exam_result_entity.dart';

/// Abstract contract for exam result data operations.
abstract class ExamResultRepository {
  /// Gets results for a student.
  FutureEither<ExamResultSummary> getResults(String studentId);
}
