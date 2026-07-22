import 'package:equatable/equatable.dart';

/// The type of a timetable period.
enum PeriodType { subject, recess, lunch }

/// Represents a single period row in the weekly timetable.
///
/// Each period has a time range and a subject for each weekday.
/// Non-subject periods (recess, lunch) have null subjects.
class TimetableSlot extends Equatable {
  final int id;
  final String time;
  final PeriodType type;
  final int duration;
  final String? monday;
  final String? tuesday;
  final String? wednesday;
  final String? thursday;
  final String? friday;

  const TimetableSlot({
    required this.id,
    required this.time,
    required this.type,
    required this.duration,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
  });

  /// Returns the subject for a given weekday (1=Monday … 5=Friday).
  String? subjectForWeekday(int weekday) => switch (weekday) {
        1 => monday,
        2 => tuesday,
        3 => wednesday,
        4 => thursday,
        5 => friday,
        _ => null,
      };

  /// Whether this is a break period (recess or lunch).
  bool get isBreak => type != PeriodType.subject;

  @override
  List<Object?> get props => [
        id,
        time,
        type,
        duration,
        monday,
        tuesday,
        wednesday,
        thursday,
        friday,
      ];
}
