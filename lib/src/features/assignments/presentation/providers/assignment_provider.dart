import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/repositories/assignment_repository.dart';
import '../../data/repositories/assignment_repository_impl.dart';

/// Provider for teacher assignments.
class AssignmentProvider extends ChangeNotifier {
  final AssignmentRepository _repository;

  AssignmentProvider({AssignmentRepository? repository})
      : _repository = repository ?? AssignmentRepositoryImpl();

  List<AssignmentEntity> _assignments = [];
  bool _isLoading = false;
  String? _error;

  List<AssignmentEntity> get assignments => _assignments;
  List<AssignmentEntity> get active =>
      _assignments.where((a) => a.isActive).toList();
  List<AssignmentEntity> get completed =>
      _assignments.where((a) => !a.isActive).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAssignments(String teacherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getAssignments(teacherId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load assignments: ${failure.message}');
      },
      (data) => _assignments = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
