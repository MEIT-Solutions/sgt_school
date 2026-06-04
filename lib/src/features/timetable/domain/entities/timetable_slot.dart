import 'package:equatable/equatable.dart';

/// Represents a single period in the weekly timetable.
class TimetableSlot extends Equatable {
  final int period;
  final String time;
  final String subject;
  final String room;
  final String teacher;

  const TimetableSlot({
    required this.period,
    required this.time,
    required this.subject,
    required this.room,
    required this.teacher,
  });

  @override
  List<Object?> get props => [period, time, subject, room, teacher];
}
