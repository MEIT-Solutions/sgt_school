import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../models/attendance_model.dart';

/// Implementation of [AttendanceRepository] connecting to Odoo API.
class AttendanceRepositoryImpl implements AttendanceRepository {
  final Dio _dio;

  AttendanceRepositoryImpl({Dio? dio}) : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<AttendanceRecord> checkIn(String studentId) async {
    return runTask(() async {
      final studentIdVal = int.tryParse(studentId) ?? studentId;
      final response = await _dio.post('/attendance/check-in', data: {
        'student_id': studentIdVal,
      });
      return AttendanceModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      ).toEntity();
    }, requiresNetwork: true);
  }

  @override
  FutureEither<AttendanceRecord> checkOut(String studentId) async {
    return runTask(() async {
      final studentIdVal = int.tryParse(studentId) ?? studentId;
      final response = await _dio.post('/attendance/check-out', data: {
        'student_id': studentIdVal,
      });
      return AttendanceModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      ).toEntity();
    }, requiresNetwork: true);
  }

  @override
  FutureEither<StudentAttendanceData> getAttendance(
    String studentId, {
    String? month,
  }) async {
    return runTask(() async {
      final response = await _dio.get(
        '/students/$studentId/attendance',
        queryParameters: {if (month != null) 'month': month},
      );

      final data = response.data['data'] as Map<String, dynamic>;

      final summary = AttendanceSummaryModel.fromJson(
        data['summary'] as Map<String, dynamic>,
      ).toEntity();

      final records = (data['records'] as List)
          .map((j) => AttendanceModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();

      return StudentAttendanceData(
        summary: summary,
        records: records,
      );
    }, requiresNetwork: true);
  }
}
