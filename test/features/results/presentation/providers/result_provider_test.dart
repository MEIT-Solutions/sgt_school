import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sgt_school/src/features/results/domain/entities/result_entity.dart';
import 'package:sgt_school/src/features/results/domain/repositories/result_repository.dart';
import 'package:sgt_school/src/features/results/presentation/providers/result_provider.dart';
import 'package:sgt_school/src/utils/failure.dart';
import 'package:sgt_school/src/utils/typedefs.dart';

class FakeResultRepository implements ResultRepository {
  bool shouldFail = false;
  String failMessage = 'Mock repository error';

  final ResultSummary summaryData = const ResultSummary(
    examId: 'EXM-1',
    examName: 'Midterm',
    results: [
      ResultEntity(
        id: '7',
        subject: 'Programming Exam',
        marks: 50,
        total: 100,
        grade: 'B',
        status: 'pass',
        admissionNo: 'A005',
      )
    ],
    totalMarks: 50,
    totalPossible: 100,
    percentage: 50.0,
    overallGrade: 'D',
  );

  @override
  FutureEither<ResultSummary> getResults(String studentId) async {
    if (shouldFail) return left(ServerFailure(failMessage));
    return right(summaryData);
  }
}

void main() {
  late FakeResultRepository fakeRepository;
  late ResultProvider provider;

  setUp(() {
    fakeRepository = FakeResultRepository();
    provider = ResultProvider(repository: fakeRepository);
  });

  group('ResultProvider loadResults', () {
    test('loads results and summary successfully', () async {
      expect(provider.isLoading, isFalse);
      expect(provider.results, isEmpty);
      expect(provider.summary, isNull);

      final future = provider.loadResults('147');
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.results, hasLength(1));
      expect(provider.results.first.subject, 'Programming Exam');
      expect(provider.summary, isNotNull);
      expect(provider.summary!.totalMarks, 50);
      expect(provider.error, isNull);
    });

    test('sets error message on failure', () async {
      fakeRepository.shouldFail = true;
      fakeRepository.failMessage = 'Database failure';

      await provider.loadResults('147');

      expect(provider.isLoading, isFalse);
      expect(provider.results, isEmpty);
      expect(provider.summary, isNull);
      expect(provider.error, 'Database failure');
    });
  });
}
