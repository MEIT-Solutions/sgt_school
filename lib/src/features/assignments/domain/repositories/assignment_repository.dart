import 'package:sgt_school/src/utils/utils.dart';
import '../entities/assignment_entity.dart';

/// Abstract contract for assignment operations (teacher feature).
abstract class AssignmentRepository {
  /// Gets assignments for a teacher, optionally filtered by status.
  FutureEither<List<AssignmentEntity>> getAssignments(
    String teacherId, {
    AssignmentStatus? status,
  });
}
