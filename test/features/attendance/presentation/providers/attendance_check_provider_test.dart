import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sgt_school/src/features/attendance/domain/entities/attendance_record.dart';
import 'package:sgt_school/src/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:sgt_school/src/features/attendance/presentation/providers/attendance_check_provider.dart';
import 'package:sgt_school/src/utils/failure.dart';
import 'package:sgt_school/src/utils/typedefs.dart';

class FakeAttendanceRepository implements AttendanceRepository {
  bool shouldFail = false;
  String failMessage = 'Mock error';
  
  final String todayStr = _formatDate(DateTime.now());

  late final List<AttendanceRecord> _records = [
    AttendanceRecord(
      id: '101',
      studentId: '147',
      date: todayStr,
      timeIn: DateTime.parse('${todayStr}T08:45:00'),
      timeOut: null,
      status: AttendanceStatus.present,
    ),
    AttendanceRecord(
      id: '102',
      studentId: '147',
      date: '2026-06-01',
      timeIn: DateTime.parse('2026-06-01T08:45:00'),
      timeOut: DateTime.parse('2026-06-01T16:30:00'),
      status: AttendanceStatus.present,
    ),
  ];

  late final StudentAttendanceData data = StudentAttendanceData(
    summary: const AttendanceSummary(
      totalDays: 22,
      present: 17,
      absent: 1,
      late: 4,
      excused: 0,
      percentage: 77.27,
    ),
    records: _records,
  );

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  FutureEither<StudentAttendanceData> getAttendance(
    String studentId, {
    String? month,
  }) async {
    if (shouldFail) return left(ServerFailure(failMessage));
    return right(data);
  }

  @override
  FutureEither<AttendanceRecord> checkIn(String studentId) async {
    if (shouldFail) return left(ServerFailure(failMessage));
    final rec = AttendanceRecord(
      id: '105',
      studentId: studentId,
      date: todayStr,
      timeIn: DateTime.parse('${todayStr}T09:15:00'),
      timeOut: null,
      status: AttendanceStatus.late,
    );
    final idx = _records.indexWhere((r) => r.date == todayStr);
    if (idx != -1) {
      _records[idx] = rec;
    } else {
      _records.add(rec);
    }
    return right(rec);
  }

  @override
  FutureEither<AttendanceRecord> checkOut(String studentId) async {
    if (shouldFail) return left(ServerFailure(failMessage));
    final rec = AttendanceRecord(
      id: '105',
      studentId: studentId,
      date: todayStr,
      timeIn: DateTime.parse('${todayStr}T09:15:00'),
      timeOut: DateTime.parse('${todayStr}T16:45:00'),
      status: AttendanceStatus.late,
    );
    final idx = _records.indexWhere((r) => r.date == todayStr);
    if (idx != -1) {
      _records[idx] = rec;
    } else {
      _records.add(rec);
    }
    return right(rec);
  }
}

void main() {
  late FakeAttendanceRepository fakeRepository;
  late AttendanceCheckProvider provider;

  setUp(() {
    fakeRepository = FakeAttendanceRepository();
    provider = AttendanceCheckProvider(repository: fakeRepository);
  });

  group('AttendanceCheckProvider loadAttendance', () {
    test('loads successfully and extracts todayRecord locally if current month', () async {
      expect(provider.isLoadingMonthly, isFalse);
      expect(provider.monthlyRecords, isEmpty);
      expect(provider.summary, isNull);
      expect(provider.todayRecord, isNull);

      final future = provider.loadAttendance('147');
      expect(provider.isLoadingMonthly, isTrue);
      expect(provider.isLoadingToday, isTrue);

      await future;

      expect(provider.isLoadingMonthly, isFalse);
      expect(provider.isLoadingToday, isFalse);
      expect(provider.monthlyRecords, hasLength(2));
      expect(provider.summary, isNotNull);
      expect(provider.summary!.present, 17);
      expect(provider.todayRecord, isNotNull);
      expect(provider.todayRecord!.id, '101');
      expect(provider.todayRecord!.status, AttendanceStatus.present);
      expect(provider.loadError, isNull);
    });

    test('loads successfully and does NOT set todayRecord if loading past month', () async {
      await provider.loadAttendance('147', month: '2026-05');

      expect(provider.monthlyRecords, hasLength(2));
      expect(provider.summary, isNotNull);
      expect(provider.todayRecord, isNull); // Past month load shouldn't overwrite / set today's record
    });

    test('sets loadError on failure', () async {
      fakeRepository.shouldFail = true;
      fakeRepository.failMessage = 'Network Timeout';

      await provider.loadAttendance('147');

      expect(provider.isLoadingMonthly, isFalse);
      expect(provider.monthlyRecords, isEmpty);
      expect(provider.summary, isNull);
      expect(provider.todayRecord, isNull);
      expect(provider.loadError, 'Network Timeout');
    });
  });

  group('AttendanceCheckProvider local selection and check-in/out', () {
    test('selectDate and clearSelectedDate modify selectedDateRecord locally', () async {
      await provider.loadAttendance('147');

      provider.selectDate('2026-06-01');
      expect(provider.selectedDateRecord, isNotNull);
      expect(provider.selectedDateRecord!.date, '2026-06-01');
      expect(provider.selectedDateRecord!.id, '102');

      provider.clearSelectedDate();
      expect(provider.selectedDateRecord, isNull);
    });

    test('checkIn success updates todayRecord and reloads attendance', () async {
      expect(provider.isCheckingIn, isFalse);

      final future = provider.checkIn('147');
      expect(provider.isCheckingIn, isTrue);

      final success = await future;

      expect(success, isTrue);
      expect(provider.isCheckingIn, isFalse);
      expect(provider.todayRecord, isNotNull);
      expect(provider.todayRecord!.status, AttendanceStatus.late);
      expect(provider.checkInError, isNull);
    });

    test('checkOut success updates todayRecord and reloads attendance', () async {
      expect(provider.isCheckingOut, isFalse);

      final future = provider.checkOut('147');
      expect(provider.isCheckingOut, isTrue);

      final success = await future;

      expect(success, isTrue);
      expect(provider.isCheckingOut, isFalse);
      expect(provider.todayRecord, isNotNull);
      expect(provider.todayRecord!.timeOut, isNotNull);
      expect(provider.checkOutError, isNull);
    });

    test('checkIn failure sets checkInError and does not update todayRecord', () async {
      fakeRepository.shouldFail = true;
      fakeRepository.failMessage = 'Already checked in';

      final success = await provider.checkIn('147');

      expect(success, isFalse);
      expect(provider.todayRecord, isNull);
      expect(provider.checkInError, 'Already checked in');
    });
  });
}
