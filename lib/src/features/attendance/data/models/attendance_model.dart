import '../../domain/entities/attendance_record.dart';

/// DTO for [AttendanceRecord] — handles JSON serialization.
class AttendanceModel {
  final String id;
  final String studentId;
  final String date;
  final String? timeIn;
  final String? timeOut;
  final String status;

  const AttendanceModel({
    required this.id,
    required this.studentId,
    required this.date,
    this.timeIn,
    this.timeOut,
    required this.status,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    final date = json['date'] as String;
    final checkInVal = (json['check_in'] ?? json['time_in']) as String?;
    final checkOutVal = (json['check_out'] ?? json['time_out']) as String?;

    String? parseDateTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return null;
      if (timeStr.contains('T') || timeStr.contains('-')) {
        return timeStr;
      }
      return '${date}T$timeStr';
    }

    final parsedTimeIn = parseDateTime(checkInVal);
    final parsedTimeOut = parseDateTime(checkOutVal);

    return AttendanceModel(
      id: json['id']?.toString() ?? date,
      studentId: json['student_id']?.toString() ?? '',
      date: date,
      timeIn: parsedTimeIn,
      timeOut: parsedTimeOut,
      status: json['status'] as String? ?? 'absent',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'date': date,
        'time_in': timeIn,
        'time_out': timeOut,
        'status': status,
      };

  AttendanceRecord toEntity() => AttendanceRecord(
        id: id,
        studentId: studentId,
        date: date,
        timeIn: timeIn != null ? DateTime.tryParse(timeIn!) : null,
        timeOut: timeOut != null ? DateTime.tryParse(timeOut!) : null,
        status: AttendanceStatus.fromString(status),
      );
}

/// DTO for [AttendanceSummary].
class AttendanceSummaryModel {
  final int totalDays;
  final int present;
  final int absent;
  final int late;
  final int excused;
  final double percentage;

  const AttendanceSummaryModel({
    required this.totalDays,
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.percentage,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    final present = json['present'] as int? ?? 0;
    final absent = json['absent'] as int? ?? 0;
    final late = json['late'] as int? ?? 0;
    final excused = json['excused'] as int? ?? 0;

    final totalDays = json['total_days'] as int? ?? (present + absent + late + excused);
    final percentage = (json['percentage'] as num?)?.toDouble() ??
        (totalDays > 0 ? (present / totalDays) * 100.0 : 0.0);

    return AttendanceSummaryModel(
      totalDays: totalDays,
      present: present,
      absent: absent,
      late: late,
      excused: excused,
      percentage: percentage,
    );
  }

  Map<String, dynamic> toJson() => {
        'total_days': totalDays,
        'present': present,
        'absent': absent,
        'late': late,
        'excused': excused,
        'percentage': percentage,
      };

  AttendanceSummary toEntity() => AttendanceSummary(
        totalDays: totalDays,
        present: present,
        absent: absent,
        late: late,
        excused: excused,
        percentage: percentage,
      );
}
