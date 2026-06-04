import 'package:flutter_test/flutter_test.dart';
import 'package:sgt_school/src/features/results/data/models/result_model.dart';
import 'package:sgt_school/src/features/results/domain/entities/result_entity.dart';

void main() {
  group('ResultModel parsing', () {
    test('parses from real API JSON format successfully', () {
      final json = {
        'id': 7,
        'student_id': 147,
        'admission_no': 'A005',
        'exam': 'Programming Exam',
        'marks_obtained': 50,
        'grade': 'B',
        'status': 'pass'
      };

      final model = ResultModel.fromJson(json);

      expect(model.id, '7');
      expect(model.subject, 'Programming Exam');
      expect(model.marks, 50);
      expect(model.total, 100);
      expect(model.grade, 'B');
      expect(model.status, 'pass');
      expect(model.admissionNo, 'A005');

      final entity = model.toEntity();
      expect(entity.id, '7');
      expect(entity.subject, 'Programming Exam');
      expect(entity.marks, 50);
      expect(entity.total, 100);
      expect(entity.grade, 'B');
      expect(entity.status, 'pass');
      expect(entity.admissionNo, 'A005');
      expect(entity.isPass, isTrue);
      expect(entity.percentage, 50.0);
    });

    test('parses from demo/mock format successfully', () {
      final json = {
        'subject': 'Mathematics',
        'marks': 92,
        'total': 100,
        'grade': 'A+'
      };

      final model = ResultModel.fromJson(json);

      expect(model.id, '');
      expect(model.subject, 'Mathematics');
      expect(model.marks, 92);
      expect(model.total, 100);
      expect(model.grade, 'A+');
      expect(model.status, 'pass'); // Based on marks fallback >= 40
      expect(model.admissionNo, isNull);
    });
  });

  group('ResultSummaryModel parsing', () {
    test('parses successfully', () {
      final json = {
        'exam_id': 'EXM-1',
        'exam_name': 'Midterm',
        'results': [
          {
            'subject': 'Science',
            'marks': 80,
            'total': 100,
            'grade': 'A',
          }
        ],
        'total_marks': 80,
        'total_possible': 100,
        'percentage': 80.0,
        'overall_grade': 'A'
      };

      final model = ResultSummaryModel.fromJson(json);

      expect(model.examId, 'EXM-1');
      expect(model.examName, 'Midterm');
      expect(model.results, hasLength(1));
      expect(model.results.first.subject, 'Science');
      expect(model.totalMarks, 80);
      expect(model.totalPossible, 100);
      expect(model.percentage, 80.0);
      expect(model.overallGrade, 'A');

      final entity = model.toEntity();
      expect(entity.examId, 'EXM-1');
      expect(entity.results.first.subject, 'Science');
    });
  });
}
