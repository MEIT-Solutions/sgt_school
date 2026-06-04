import 'package:sgt_school/src/utils/utils.dart';
import '../entities/result_entity.dart';

/// Abstract contract for result data operations.
abstract class ResultRepository {
  /// Gets results for a student.
  FutureEither<ResultSummary> getResults(String studentId);
}
