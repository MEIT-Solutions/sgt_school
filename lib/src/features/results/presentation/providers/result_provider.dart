import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/result_entity.dart';
import '../../domain/repositories/result_repository.dart';
import '../../data/repositories/result_repository_impl.dart';

/// Provider for student exam results.
class ResultProvider extends ChangeNotifier {
  final ResultRepository _repository;

  ResultProvider({ResultRepository? repository})
      : _repository = repository ?? ResultRepositoryImpl();

  ResultSummary? _summary;
  bool _isLoading = false;
  String? _error;

  ResultSummary? get summary => _summary;
  List<ResultEntity> get results => _summary?.results ?? [];
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
