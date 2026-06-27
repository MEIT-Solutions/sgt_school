import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/timetable_slot.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../models/timetable_model.dart';

/// Implementation of [TimetableRepository].
class TimetableRepositoryImpl implements TimetableRepository {
  final Dio _dio;

  TimetableRepositoryImpl({Dio? dio})
      : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<Map<String, List<TimetableSlot>>> getWeeklyTimetable(
    String studentId,
  ) async {
    return runTask(() async {
      final response = await _dio.get('/students/$studentId/timetable');
      final data = response.data['data'] as Map<String, dynamic>;
      return data.map((day, slots) => MapEntry(
            day,
            (slots as List)
                .map((s) => TimetableSlotModel.fromJson(s as Map<String, dynamic>).toEntity())
                .toList(),
          ));
    }, requiresNetwork: true);
  }
}
