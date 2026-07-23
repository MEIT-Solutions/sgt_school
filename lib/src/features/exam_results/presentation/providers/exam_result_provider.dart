import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/exam_result_entity.dart';
import '../../domain/repositories/exam_result_repository.dart';
import '../../data/repositories/exam_result_repository_impl.dart';

/// Provider for student exam results.
class ExamResultProvider extends ChangeNotifier {
  final ExamResultRepository _repository;

  ExamResultProvider({ExamResultRepository? repository})
      : _repository = repository ?? ExamResultRepositoryImpl();

  ExamResultSummary? _summary;
  bool _isLoading = false;
  String? _error;

  ExamResultSummary? get summary => _summary;
  List<ExamResultEntity> get results => _summary?.results ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadResults(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getResults(studentId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load results: ${failure.message}');
      },
      (data) => _summary = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
