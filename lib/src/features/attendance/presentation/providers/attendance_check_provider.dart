import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../data/repositories/attendance_repository_impl.dart';

/// Provider for student attendance state.
///
/// Manages:
/// - Today's check-in/out record (derived or updated from API)
/// - Monthly records for the calendar grid
/// - Monthly summary statistics
/// - Selected date record for day detail view (filtered locally)
class AttendanceCheckProvider extends ChangeNotifier {
  final AttendanceRepository _repository;

  AttendanceCheckProvider({AttendanceRepository? repository})
      : _repository = repository ?? AttendanceRepositoryImpl();

  // ── State ──

  AttendanceRecord? _todayRecord;
  List<AttendanceRecord> _monthlyRecords = [];
  AttendanceSummary? _summary;
  AttendanceRecord? _selectedDateRecord;

  bool _isLoadingToday = false;
  bool _hasTodayLoaded = false;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  bool _isLoadingMonthly = false;

  String? _checkInError;
  String? _checkOutError;
  String? _loadError;

  // ── Getters ──

  AttendanceRecord? get todayRecord => _todayRecord;
  List<AttendanceRecord> get monthlyRecords => _monthlyRecords;
  AttendanceSummary? get summary => _summary;
  AttendanceRecord? get selectedDateRecord => _selectedDateRecord;

  bool get isLoadingToday => _isLoadingToday;
  bool get hasTodayLoaded => _hasTodayLoaded;
  bool get isCheckingIn => _isCheckingIn;
  bool get isCheckingOut => _isCheckingOut;
  bool get isLoadingMonthly => _isLoadingMonthly;

  String? get checkInError => _checkInError;
  String? get checkOutError => _checkOutError;
  String? get loadError => _loadError;

  bool get hasCheckedIn => _todayRecord?.hasCheckedIn ?? false;
  bool get hasCheckedOut => _todayRecord?.hasCheckedOut ?? false;
  bool get isComplete => _todayRecord?.isComplete ?? false;

  // ── Load Attendance (Combined Summary & Monthly records) ──

  Future<void> loadAttendance(String studentId, {String? month}) async {
    final todayStr = _todayDateString();
    final isCurrentMonth = month == null || month == todayStr.substring(0, 7);

    if (isCurrentMonth) {
      _isLoadingToday = true;
    }
    _isLoadingMonthly = true;
    _loadError = null;
    notifyListeners();

    final result = await _repository.getAttendance(studentId, month: month);
    result.fold(
      (failure) {
        _loadError = failure.message;
        AppLogger.error('Failed to load attendance data: ${failure.message}');
      },
      (data) {
        _monthlyRecords = data.records;
        _summary = data.summary;
        _loadError = null;

        if (isCurrentMonth) {
          _todayRecord = _monthlyRecords
              .where((r) => r.date == todayStr)
              .firstOrNull;
          _hasTodayLoaded = true;
        }
      },
    );

    _isLoadingToday = false;
    _isLoadingMonthly = false;
    notifyListeners();
  }

  // ── Check In ──

  Future<bool> checkIn(String studentId) async {
    _isCheckingIn = true;
    _checkInError = null;
    notifyListeners();

    final result = await _repository.checkIn(studentId);
    bool success = false;

    result.fold(
      (failure) {
        _checkInError = failure.message;
        AppLogger.error('Check-in failed: ${failure.message}');
      },
      (record) {
        _todayRecord = record;
        _checkInError = null;
        success = true;
      },
    );

    _isCheckingIn = false;
    notifyListeners();

    if (success) {
      // Reload current month's attendance to refresh calendar & summary
      await loadAttendance(studentId);
    }

    return success;
  }

  // ── Check Out ──

  Future<bool> checkOut(String studentId) async {
    _isCheckingOut = true;
    _checkOutError = null;
    notifyListeners();

    final result = await _repository.checkOut(studentId);
    bool success = false;

    result.fold(
      (failure) {
        _checkOutError = failure.message;
        AppLogger.error('Check-out failed: ${failure.message}');
      },
      (record) {
        _todayRecord = record;
        _checkOutError = null;
        success = true;
      },
    );

    _isCheckingOut = false;
    notifyListeners();

    if (success) {
      // Reload current month's attendance to refresh calendar & summary
      await loadAttendance(studentId);
    }

    return success;
  }

  // ── Local filtering for calendar day tap ──

  void selectDate(String dateStr) {
    _selectedDateRecord = _monthlyRecords
        .where((r) => r.date == dateStr)
        .firstOrNull;
    notifyListeners();
  }

  void clearSelectedDate() {
    _selectedDateRecord = null;
    notifyListeners();
  }

  // ── Helper ──

  String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
