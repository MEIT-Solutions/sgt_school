import 'package:equatable/equatable.dart';

/// Status of a student's attendance for a given day.
enum AttendanceStatus {
  present,
  absent,
  late,
  excused;

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => AttendanceStatus.absent,
    );
  }
}

/// Represents a single attendance record for a student on a given day.
class AttendanceRecord extends Equatable {
  final String id;
  final String studentId;
  final String date; // yyyy-MM-dd
  final DateTime? timeIn;
  final DateTime? timeOut;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    this.timeIn,
    this.timeOut,
    this.status = AttendanceStatus.absent,
  });

  bool get hasCheckedIn => timeIn != null;
  bool get hasCheckedOut => timeOut != null;
  bool get isComplete => hasCheckedIn && hasCheckedOut;

  AttendanceRecord copyWith({
    String? id,
    DateTime? timeIn,
    DateTime? timeOut,
    AttendanceStatus? status,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId,
      date: date,
      timeIn: timeIn ?? this.timeIn,
      timeOut: timeOut ?? this.timeOut,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, studentId, date, timeIn, timeOut, status];
}

/// Monthly attendance summary statistics.
class AttendanceSummary extends Equatable {
  final int totalDays;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double percentage;

  const AttendanceSummary({
    required this.totalDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.percentage,
  });

  @override
  List<Object?> get props => [totalDays, present, absent, late, excused, percentage];
}
