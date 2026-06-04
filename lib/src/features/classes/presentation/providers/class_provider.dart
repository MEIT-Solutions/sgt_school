import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/class_student_entity.dart';
import '../../domain/repositories/class_repository.dart';
import '../../data/repositories/class_repository_impl.dart';

/// Provider for teacher classes and students.
class ClassProvider extends ChangeNotifier {
  final ClassRepository _repository;

  ClassProvider({ClassRepository? repository})
      : _repository = repository ?? ClassRepositoryImpl();

  List<ClassEntity> _classes = [];
  List<ClassStudentEntity> _students = [];
  bool _isLoading = false;
  String? _error;

  List<ClassEntity> get classes => _classes;
  List<ClassStudentEntity> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClasses(String teacherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getTeacherClasses(teacherId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load classes: ${failure.message}');
      },
      (data) => _classes = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStudents(String classId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getClassStudents(classId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load students: ${failure.message}');
      },
      (data) => _students = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
