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

  /// Gets today's record (if any).
  ///
  /// This is how the app knows if the user already checked in
  /// after clearing or reopening the app.
  FutureEither<AttendanceRecord?> getTodayRecord(String studentId);

  /// Gets attendance record for a specific date.
  ///
  /// Used when user taps a date on the calendar.
  FutureEither<AttendanceRecord?> getRecordByDate(
    String studentId,
    String date,
  );

  /// Gets attendance records for a given month.
  FutureEither<List<AttendanceRecord>> getMonthlyRecords(
    String studentId, {
    String? month,
  });

  /// Gets attendance summary statistics.
  FutureEither<AttendanceSummary> getSummary(
    String studentId, {
    String? month,
  });
}
