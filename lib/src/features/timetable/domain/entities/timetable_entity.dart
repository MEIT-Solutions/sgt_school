import 'package:equatable/equatable.dart';
import 'timetable_slot.dart';

/// Represents a teacher reference in the timetable.
class TimetableTeacher extends Equatable {
  final int id;
  final String name;

  const TimetableTeacher({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// The complete timetable for a student, including metadata and all periods.
class TimetableEntity extends Equatable {
  final int id;
  final String name;
  final String academicYear;
  final String className;
  final TimetableTeacher teacher;
  final List<TimetableSlot> periods;

  const TimetableEntity({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.className,
    required this.teacher,
    required this.periods,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        academicYear,
        className,
        teacher,
        periods,
      ];
}
