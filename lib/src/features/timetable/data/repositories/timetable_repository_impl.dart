import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/services/demo_data_service.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/timetable_slot.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../models/timetable_model.dart';

/// Implementation of [TimetableRepository].
///
/// Tries API first, falls back to [DemoDataService].
class TimetableRepositoryImpl implements TimetableRepository {
  final Dio _dio;
  final DemoDataService _demo;

  TimetableRepositoryImpl({Dio? dio, DemoDataService? demo})
      : _dio = dio ?? AppConfig.dio,
        _demo = demo ?? DemoDataService.instance;

  @override
  FutureEither<Map<String, List<TimetableSlot>>> getWeeklyTimetable(
    String studentId,
  ) async {
    return runTask(() async {
      // Try API first
      try {
        final response = await _dio.get('/students/$studentId/timetable');
        final data = response.data['data'] as Map<String, dynamic>;
        return data.map((day, slots) => MapEntry(
              day,
              (slots as List)
                  .map((s) => TimetableSlotModel.fromJson(s as Map<String, dynamic>).toEntity())
                  .toList(),
            ));
      } on DioException {
        AppLogger.warning('API unavailable, using demo timetable data');
      }

      // Fallback to demo data
      final demoData = _demo.getStudentTimetable(studentId);
      return demoData.map((day, slots) => MapEntry(
            day,
            slots.map((s) => TimetableSlotModel.fromJson(s).toEntity()).toList(),
          ));
    });
  }
}
