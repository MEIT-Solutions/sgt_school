import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/exam_entity.dart';
import '../../domain/entities/teacher_exam_entity.dart';
import '../../domain/entities/teacher_exam_result_entity.dart';
import '../../domain/repositories/exam_repository.dart';
import '../../data/repositories/exam_repository_impl.dart';

/// Provider for exam data (student + teacher).
class ExamProvider extends ChangeNotifier {
  final ExamRepository _repository;

  ExamProvider({ExamRepository? repository})
      : _repository = repository ?? ExamRepositoryImpl();

  List<ExamEntity> _exams = [];
  List<TeacherExamEntity> _teacherExams = [];
  List<TeacherExamResultEntity> _teacherExamResults = [];
  bool _isLoading = false;
  String? _error;

  List<ExamEntity> get exams => _exams;
  List<ExamEntity> get upcoming => _exams.where((e) => e.isUpcoming).toList();
  List<ExamEntity> get completed => _exams.where((e) => e.isCompleted).toList();
  List<TeacherExamEntity> get teacherExams => _teacherExams;
  List<TeacherExamResultEntity> get teacherExamResults => _teacherExamResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExams(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getExams(studentId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load exams: ${failure.message}');
      },
      (data) => _exams = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTeacherExams(String teacherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getTeacherExams(teacherId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load teacher exams: ${failure.message}');
      },
      (data) => _teacherExams = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTeacherExamResults(String teacherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getTeacherExamResults(teacherId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load teacher exam results: ${failure.message}');
      },
      (data) => _teacherExamResults = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
