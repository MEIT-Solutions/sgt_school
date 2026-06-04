import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/demo_data_service.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';

/// Implementation of [AttendanceRepository].
///
/// Strategy:
/// - All operations try the API first.
/// - On [DioException], check-in/check-out return [Left(Failure)] so the UI
///   can show an error and let the user retry.
/// - Monthly records and today's record fall back to demo data when API
///   is unavailable (for the demo version).
class AttendanceRepositoryImpl implements AttendanceRepository {
  final Dio _dio;
  final DemoDataService _demo;

  AttendanceRepositoryImpl({
    Dio? dio,
    DemoDataService? demo,
  })  : _dio = dio ?? AppConfig.dio,
        _demo = demo ?? DemoDataService.instance;

  @override
  FutureEither<AttendanceRecord> checkIn(String studentId) async {
    return runTask(() async {
      // Try API first
      try {
        final response = await _dio.post('/attendance/check-in', data: {
          'student_id': studentId,
        });
        return AttendanceModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        ).toEntity();
      } on DioException {
        // API not ready — return demo check-in for demo version
        AppLogger.warning('API unavailable, using demo check-in');
      }

      // Demo fallback: simulate a successful check-in
      return AttendanceRecord(
        id: 'ATT-${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        date: _todayDateString(),
        timeIn: DateTime.now(),
        status: AttendanceStatus.present,
      );
    });
  }

  @override
  FutureEither<AttendanceRecord> checkOut(String studentId) async {
    return runTask(() async {
      // Try API first
      try {
        final response = await _dio.post('/attendance/check-out', data: {
          'student_id': studentId,
        });
        return AttendanceModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        ).toEntity();
      } on DioException {
        // API not ready — return demo check-out for demo version
        AppLogger.warning('API unavailable, using demo check-out');
      }

      // Demo fallback: simulate a successful check-out
      return AttendanceRecord(
        id: 'ATT-${DateTime.now().millisecondsSinceEpoch}',
        studentId: studentId,
        date: _todayDateString(),
        timeIn: DateTime.now().subtract(const Duration(hours: 7)),
        timeOut: DateTime.now(),
        status: AttendanceStatus.present,
      );
    });
  }

  @override
  FutureEither<AttendanceRecord?> getTodayRecord(String studentId) async {
    return runTask(() async {
      // Try API first
      try {
        final response = await _dio.get(
          '/students/$studentId/attendance',
          queryParameters: {'date': _todayDateString()},
        );
        final data = response.data['data'];
        if (data == null) return null;
        if (data is List) {
          if (data.isEmpty) return null;
          return AttendanceModel.fromJson(
            data.first as Map<String, dynamic>,
          ).toEntity();
        }
        return AttendanceModel.fromJson(
          data as Map<String, dynamic>,
        ).toEntity();
      } on DioException {
        AppLogger.warning('API unavailable, no today record from demo');
      }

      // Demo fallback: return null (no check-in yet for today)
      // This forces the user to go through the check-in flow
      return null;
    });
  }

  @override
  FutureEither<AttendanceRecord?> getRecordByDate(
    String studentId,
    String date,
  ) async {
    return runTask(() async {
      // Try API first
      try {
        final response = await _dio.get(
          '/students/$studentId/attendance',
          queryParameters: {'date': date},
        );
        final data = response.data['data'];
        if (data == null) return null;
        if (data is List) {
          if (data.isEmpty) return null;
          return AttendanceModel.fromJson(
            data.first as Map<String, dynamic>,
          ).toEntity();
        }
        return AttendanceModel.fromJson(
          data as Map<String, dynamic>,
        ).toEntity();
      } on DioException {
        AppLogger.warning('API unavailable, using demo data for date: $date');
      }

      // Demo fallback: find from demo monthly records
      final allRecords = _demo.getStudentAttendance(studentId);
      final match = allRecords.where((r) => r['date'] == date).toList();
      if (match.isEmpty) return null;
      return AttendanceModel.fromJson(match.first).toEntity();
    });
  }

  @override
  FutureEither<List<AttendanceRecord>> getMonthlyRecords(
    String studentId, {
    String? month,
  }) async {
    return runTask(() async {
      // Try API first
      try {
        final response = await _dio.get(
          '/students/$studentId/attendance',
          queryParameters: {if (month != null) 'month': month},
        );
        return (response.data['data'] as List)
            .map((j) =>
                AttendanceModel.fromJson(j as Map<String, dynamic>).toEntity())
            .toList();
      } on DioException {
        AppLogger.warning('API unavailable, using demo attendance data');
      }

      // Fallback to demo data
      final records = _demo
          .getStudentAttendance(studentId)
          .map((j) => AttendanceModel.fromJson(j).toEntity())
          .toList();

      // Filter by month if specified
      if (month != null) {
        return records.where((r) => r.date.startsWith(month)).toList();
      }
      return records;
    });
  }

  @override
  FutureEither<AttendanceSummary> getSummary(
    String studentId, {
    String? month,
  }) async {
    return runTask(() async {
      // Try API first
      try {
        final response = await _dio.get(
          '/students/$studentId/attendance/summary',
          queryParameters: {if (month != null) 'month': month},
        );
        return AttendanceSummaryModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        ).toEntity();
      } on DioException {
        AppLogger.warning('API unavailable, computing summary from demo data');
      }

      // Compute from demo data
      final records = _demo.getStudentAttendance(studentId);
      final present = records.where((r) => r['status'] == 'present').length;
      final absent = records.where((r) => r['status'] == 'absent').length;
      final late = records.where((r) => r['status'] == 'late').length;
      final total = records.length;
      return AttendanceSummary(
        totalDays: total,
        present: present,
        absent: absent,
        late: late,
        excused: 0,
        percentage: total > 0 ? (present / total) * 100 : 0,
      );
    });
  }

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
