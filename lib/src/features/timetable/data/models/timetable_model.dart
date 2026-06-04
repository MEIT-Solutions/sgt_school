import '../../domain/entities/timetable_slot.dart';

/// DTO for [TimetableSlot] — handles JSON serialization.
class TimetableSlotModel {
  final int period;
  final String time;
  final String subject;
  final String room;
  final String teacher;

  const TimetableSlotModel({
    required this.period,
    required this.time,
    required this.subject,
    required this.room,
    required this.teacher,
  });

  factory TimetableSlotModel.fromJson(Map<String, dynamic> json) {
    return TimetableSlotModel(
      period: json['period'] as int,
      time: json['time'] as String,
      subject: json['subject'] as String,
      room: json['room'] as String,
      teacher: json['teacher'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'period': period,
        'time': time,
        'subject': subject,
        'room': room,
        'teacher': teacher,
      };

  TimetableSlot toEntity() => TimetableSlot(
        period: period,
        time: time,
        subject: subject,
        room: room,
        teacher: teacher,
      );
}
