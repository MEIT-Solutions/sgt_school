import '../../domain/entities/timetable_slot.dart';
import '../../domain/entities/timetable_entity.dart';

/// DTO for [TimetableSlot] — handles JSON serialization for a period row.
class TimetableSlotModel {
  final int id;
  final String time;
  final String typeRaw;
  final int duration;
  final String? monday;
  final String? tuesday;
  final String? wednesday;
  final String? thursday;
  final String? friday;

  const TimetableSlotModel({
    required this.id,
    required this.time,
    required this.typeRaw,
    required this.duration,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
  });

  factory TimetableSlotModel.fromJson(Map<String, dynamic> json) {
    return TimetableSlotModel(
      id: json['id'] as int,
      time: json['time'] as String,
      typeRaw: json['type'] as String,
      duration: json['duration'] as int,
      monday: json['monday'] as String?,
      tuesday: json['tuesday'] as String?,
      wednesday: json['wednesday'] as String?,
      thursday: json['thursday'] as String?,
      friday: json['friday'] as String?,
    );
  }

  static PeriodType _parseType(String raw) => switch (raw) {
        'recess' => PeriodType.recess,
        'lunch' => PeriodType.lunch,
        _ => PeriodType.subject,
      };

  TimetableSlot toEntity() => TimetableSlot(
        id: id,
        time: time,
        type: _parseType(typeRaw),
        duration: duration,
        monday: monday,
        tuesday: tuesday,
        wednesday: wednesday,
        thursday: thursday,
        friday: friday,
      );
}

/// DTO for the full timetable response.
class TimetableModel {
  final int id;
  final String name;
  final String academicYear;
  final String className;
  final int teacherId;
  final String teacherName;
  final List<TimetableSlotModel> periods;

  const TimetableModel({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.className,
    required this.teacherId,
    required this.teacherName,
    required this.periods,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    final teacher = json['teacher'] as Map<String, dynamic>;
    final rawPeriods = json['periods'] as List<dynamic>;

    return TimetableModel(
      id: json['id'] as int,
      name: json['name'] as String,
      academicYear: json['academic_year'] as String,
      className: json['class'] as String,
      teacherId: teacher['id'] as int,
      teacherName: teacher['name'] as String,
      periods: rawPeriods
          .map((p) => TimetableSlotModel.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  TimetableEntity toEntity() => TimetableEntity(
        id: id,
        name: name,
        academicYear: academicYear,
        className: className,
        teacher: TimetableTeacher(id: teacherId, name: teacherName),
        periods: periods.map((p) => p.toEntity()).toList(),
      );
}
