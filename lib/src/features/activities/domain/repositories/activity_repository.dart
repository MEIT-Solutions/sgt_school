import 'package:sgt_school/src/utils/utils.dart';
import '../entities/activity_entity.dart';

/// Abstract contract for school activity/event operations.
abstract class ActivityRepository {
  /// Gets all school activities.
  FutureEither<List<ActivityEntity>> getActivities();

  /// Gets activities for a specific teacher.
  FutureEither<List<ActivityEntity>> getTeacherActivities(String teacherId);
}
