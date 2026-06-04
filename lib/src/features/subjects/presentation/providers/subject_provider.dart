import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/subject_entity.dart';
import '../../domain/repositories/subject_repository.dart';
import '../../data/repositories/subject_repository_impl.dart';

/// Provider for student subjects data.
class SubjectProvider extends ChangeNotifier {
  final SubjectRepository _repository;

  SubjectProvider({SubjectRepository? repository})
      : _repository = repository ?? SubjectRepositoryImpl();

  List<SubjectEntity> _subjects = [];
  bool _isLoading = false;
  String? _error;

  List<SubjectEntity> get subjects => _subjects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSubjects(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getSubjects(studentId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load subjects: ${failure.message}');
      },
      (data) => _subjects = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
