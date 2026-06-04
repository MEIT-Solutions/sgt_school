import 'package:sgt_school/src/utils/utils.dart';
import '../entities/timetable_slot.dart';

/// Abstract contract for timetable data operations.
abstract class TimetableRepository {
  /// Gets the full weekly timetable for a student.
  /// Returns a map of day name → list of slots.
  FutureEither<Map<String, List<TimetableSlot>>> getWeeklyTimetable(
    String studentId,
  );
}
