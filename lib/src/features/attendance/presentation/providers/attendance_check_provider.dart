import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../data/repositories/attendance_repository_impl.dart';

/// Provider for student attendance state.
///
/// Manages:
/// - Today's check-in/out record (restored from API on app open)
/// - Monthly records for the calendar grid
/// - Selected date record for day detail view
///
/// Separate loading states ensure the button only disables during
/// its own API call, not during unrelated loads.
class AttendanceCheckProvider extends ChangeNotifier {
  final AttendanceRepository _repository;

  AttendanceCheckProvider({AttendanceRepository? repository})
      : _repository = repository ?? AttendanceRepositoryImpl();

  // ── State ──

  AttendanceRecord? _todayRecord;
  List<AttendanceRecord> _monthlyRecords = [];
  AttendanceRecord? _selectedDateRecord;

  bool _isLoadingToday = false;
  bool _hasTodayLoaded = false;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  bool _isLoadingMonthly = false;
  bool _isLoadingDate = false;

  String? _checkInError;
  String? _checkOutError;
  String? _loadError;

  // ── Getters ──

  AttendanceRecord? get todayRecord => _todayRecord;
  List<AttendanceRecord> get monthlyRecords => _monthlyRecords;
  AttendanceRecord? get selectedDateRecord => _selectedDateRecord;

  bool get isLoadingToday => _isLoadingToday;
  bool get hasTodayLoaded => _hasTodayLoaded;
  bool get isCheckingIn => _isCheckingIn;
  bool get isCheckingOut => _isCheckingOut;
  bool get isLoadingMonthly => _isLoadingMonthly;
  bool get isLoadingDate => _isLoadingDate;

  String? get checkInError => _checkInError;
  String? get checkOutError => _checkOutError;
  String? get loadError => _loadError;

  bool get hasCheckedIn => _todayRecord?.hasCheckedIn ?? false;
  bool get hasCheckedOut => _todayRecord?.hasCheckedOut ?? false;
  bool get isComplete => _todayRecord?.isComplete ?? false;

  // ── Load today's record (for state restoration on app open) ──

  Future<void> loadTodayRecord(String studentId) async {
    _isLoadingToday = true;
    _loadError = null;
    notifyListeners();

    final result = await _repository.getTodayRecord(studentId);
    result.fold(
      (failure) {
        _loadError = failure.message;
        AppLogger.error('Failed to load today record: ${failure.message}');
      },
      (record) => _todayRecord = record,
    );

    _isLoadingToday = false;
    _hasTodayLoaded = true;
    notifyListeners();
  }

  // ── Check In ──

  /// Returns `true` if check-in was successful, `false` if failed.
  /// On failure, [checkInError] is set and the button stays enabled for retry.
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
    return success;
  }

  // ── Check Out ──

  /// Returns `true` if check-out was successful, `false` if failed.
  /// On failure, [checkOutError] is set and the button stays enabled for retry.
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
    return success;
  }

  // ── Monthly Records (for calendar grid) ──

  Future<void> loadMonthlyRecords(String studentId, {String? month}) async {
    _isLoadingMonthly = true;
    _loadError = null;
    notifyListeners();

    final result =
        await _repository.getMonthlyRecords(studentId, month: month);
    result.fold(
      (failure) {
        _loadError = failure.message;
        AppLogger.error('Failed to load monthly records: ${failure.message}');
      },
      (records) => _monthlyRecords = records,
    );

    _isLoadingMonthly = false;
    notifyListeners();
  }

  // ── Record by Date (for calendar day tap) ──

  Future<void> loadRecordByDate(String studentId, String date) async {
    _isLoadingDate = true;
    _selectedDateRecord = null;
    notifyListeners();

    final result = await _repository.getRecordByDate(studentId, date);
    result.fold(
      (failure) {
        _selectedDateRecord = null;
        AppLogger.warning('No record for date $date: ${failure.message}');
      },
      (record) => _selectedDateRecord = record,
    );

    _isLoadingDate = false;
    notifyListeners();
  }

  /// Clear selected date (when user changes month, etc.)
  void clearSelectedDate() {
    _selectedDateRecord = null;
    notifyListeners();
  }
}
