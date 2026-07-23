import 'package:dio/dio.dart';
import 'package:sgt_school/src/config/app_config.dart';
import 'package:sgt_school/src/utils/utils.dart';
import '../../domain/entities/exam_result_entity.dart';
import '../../domain/repositories/exam_result_repository.dart';
import '../models/exam_result_model.dart';

/// Implementation of [ExamResultRepository].
///
/// Tries API first, falls back to [DemoDataService].
class ExamResultRepositoryImpl implements ExamResultRepository {
  final Dio _dio;

  ExamResultRepositoryImpl({Dio? dio})
      : _dio = dio ?? AppConfig.dio;

  @override
  FutureEither<ExamResultSummary> getResults(String studentId) async {
    return runTask(() async {
      final response = await _dio.get('/students/$studentId/results');
      final data = response.data;
      final resultsList = (data['data'] as List)
          .map(
              (j) => ExamResultModel.fromJson(j as Map<String, dynamic>).toEntity())
          .toList();

      final totalMarks = resultsList.fold<int>(0, (sum, r) => sum + r.marks);
      final totalPossible = resultsList.fold<int>(0, (sum, r) => sum + r.total);
      final percentage =
          totalPossible > 0 ? (totalMarks / totalPossible) * 100 : 0.0;

      return ExamResultSummary(
        examId: 'EXM-ALL',
        examName: 'All Exams',
        results: resultsList,
        totalMarks: totalMarks,
        totalPossible: totalPossible,
        percentage: percentage,
        overallGrade: _computeGrade(percentage),
      );
    }, requiresNetwork: true);
  }

  String _computeGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C';
    return 'D';
  }
}
