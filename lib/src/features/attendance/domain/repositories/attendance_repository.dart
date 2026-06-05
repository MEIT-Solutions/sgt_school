import 'package:sgt_school/src/utils/utils.dart';
import '../entities/attendance_record.dart';

/// Abstract contract for attendance operations.
///
/// All methods return [FutureEither] for predictable error handling.
/// When the backend is ready, the implementation simply removes the demo
/// fallback — no changes needed in the domain or presentation layers.
abstract class AttendanceRepository {
  /// Records time-in for today. Returns the updated record.
  ///
  /// Returns [Left(Failure)] if API fails or no internet — the caller
  /// should show an error and keep the check-in button enabled for retry.
  FutureEither<AttendanceRecord> checkIn(String studentId);

  /// Records time-out for today. Returns the updated record.
  ///
  /// Returns [Left(Failure)] if API fails or no internet.
  FutureEither<AttendanceRecord> checkOut(String studentId);

  /// Gets combined attendance summary and records for a student and optional month.
  FutureEither<StudentAttendanceData> getAttendance(
    String studentId, {
    String? month,
  });
}
