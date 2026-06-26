import 'package:sgt_school/src/utils/utils.dart';
import '../entities/subject_entity.dart';
import '../entities/teacher_subject_entity.dart';

/// Abstract contract for subject data operations.
abstract class SubjectRepository {
  /// Gets all subjects for a student.
  FutureEither<List<SubjectEntity>> getSubjects(String studentId);

  /// Gets all subjects for a teacher.
  FutureEither<List<TeacherSubjectEntity>> getTeacherSubjects(String teacherId);
}
