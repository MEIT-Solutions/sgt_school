import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/timetable_slot.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../../data/repositories/timetable_repository_impl.dart';

/// Provider for student weekly timetable data.
class TimetableProvider extends ChangeNotifier {
  final TimetableRepository _repository;

  TimetableProvider({TimetableRepository? repository})
      : _repository = repository ?? TimetableRepositoryImpl();

  Map<String, List<TimetableSlot>> _timetable = {};
  bool _isLoading = false;
  String? _error;

  Map<String, List<TimetableSlot>> get timetable => _timetable;
  List<String> get days => _timetable.keys.toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTimetable(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getWeeklyTimetable(studentId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load timetable: ${failure.message}');
      },
      (data) => _timetable = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
