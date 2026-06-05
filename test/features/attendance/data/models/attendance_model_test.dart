import 'package:flutter_test/flutter_test.dart';
import 'package:sgt_school/src/features/attendance/data/models/attendance_model.dart';
import 'package:sgt_school/src/features/attendance/domain/entities/attendance_record.dart';

void main() {
  group('AttendanceModel JSON parsing', () {
    test('parses record from API with check_in and check_out time-only strings', () {
      final json = {
        'id': 105,
        'student_id': 147,
        'date': '2026-06-04',
        'check_in': '09:15:00',
        'check_out': '16:45:00',
        'status': 'late'
      };

      final model = AttendanceModel.fromJson(json);

      expect(model.id, '105');
      expect(model.studentId, '147');
      expect(model.date, '2026-06-04');
      expect(model.timeIn, '2026-06-04T09:15:00');
      expect(model.timeOut, '2026-06-04T16:45:00');
      expect(model.status, 'late');

      final entity = model.toEntity();
      expect(entity.id, '105');
      expect(entity.studentId, '147');
      expect(entity.date, '2026-06-04');
      expect(entity.timeIn, DateTime.parse('2026-06-04T09:15:00'));
      expect(entity.timeOut, DateTime.parse('2026-06-04T16:45:00'));
      expect(entity.status, AttendanceStatus.late);
    });

    test('parses record from legacy/demo formats with time_in and time_out', () {
      final json = {
        'id': 'ATT-1',
        'student_id': '147',
        'date': '2026-06-04',
        'time_in': '2026-06-04T09:15:00',
        'time_out': '2026-06-04T16:45:00',
        'status': 'present'
      };

      final model = AttendanceModel.fromJson(json);

      expect(model.id, 'ATT-1');
      expect(model.studentId, '147');
      expect(model.date, '2026-06-04');
      expect(model.timeIn, '2026-06-04T09:15:00');
      expect(model.timeOut, '2026-06-04T16:45:00');
      expect(model.status, 'present');
    });

    test('handles missing or null values gracefully', () {
      final json = {
        'date': '2026-06-04',
      };

      final model = AttendanceModel.fromJson(json);

      expect(model.id, '2026-06-04');
      expect(model.studentId, '');
      expect(model.timeIn, isNull);
      expect(model.timeOut, isNull);
      expect(model.status, 'absent');
    });
  });

  group('AttendanceSummaryModel JSON parsing', () {
    test('parses summary counts and calculates totalDays and percentage locally', () {
      final json = {
        'present': 17,
        'absent': 1,
        'late': 4
      };

      final model = AttendanceSummaryModel.fromJson(json);

      expect(model.present, 17);
      expect(model.absent, 1);
      expect(model.late, 4);
      expect(model.excused, 0);
      expect(model.totalDays, 22);
      expect(model.percentage, closeTo((17 / 22) * 100, 0.0001));

      final entity = model.toEntity();
      expect(entity.totalDays, 22);
      expect(entity.present, 17);
      expect(entity.absent, 1);
      expect(entity.late, 4);
      expect(entity.excused, 0);
      expect(entity.percentage, closeTo((17 / 22) * 100, 0.0001));
    });

    test('parses summary completely if total_days and percentage are provided', () {
      final json = {
        'present': 17,
        'absent': 1,
        'late': 4,
        'excused': 1,
        'total_days': 23,
        'percentage': 85.0
      };

      final model = AttendanceSummaryModel.fromJson(json);

      expect(model.totalDays, 23);
      expect(model.percentage, 85.0);
      expect(model.excused, 1);
    });
  });
}
