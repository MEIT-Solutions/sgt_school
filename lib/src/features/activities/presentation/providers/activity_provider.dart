import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../data/repositories/activity_repository_impl.dart';

/// Provider for school activities.
class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository;

  ActivityProvider({ActivityRepository? repository})
      : _repository = repository ?? ActivityRepositoryImpl();

  List<ActivityEntity> _activities = [];
  bool _isLoading = false;
  String? _error;

  List<ActivityEntity> get activities => _activities;
  List<ActivityEntity> get upcoming =>
      _activities.where((a) => a.isUpcoming).toList();
  List<ActivityEntity> get completed =>
      _activities.where((a) => !a.isUpcoming).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getActivities();
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load activities: ${failure.message}');
      },
      (data) => _activities = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
