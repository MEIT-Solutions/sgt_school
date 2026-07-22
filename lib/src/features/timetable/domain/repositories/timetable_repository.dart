import 'package:sgt_school/src/utils/utils.dart';
import '../entities/timetable_entity.dart';

/// Abstract contract for timetable data operations.
abstract class TimetableRepository {
  /// Gets the full weekly timetable for a student.
  FutureEither<TimetableEntity> getWeeklyTimetable(String studentId);
}
