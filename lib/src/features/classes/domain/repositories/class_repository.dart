import 'package:sgt_school/src/utils/utils.dart';
import '../entities/class_student_entity.dart';

/// Abstract contract for class operations (teacher feature).
abstract class ClassRepository {
  /// Gets all students in the teacher's classes.
  FutureEither<List<ClassStudentEntity>> getTeacherClasses(String teacherId);
}
