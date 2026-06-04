import 'package:sgt_school/src/utils/utils.dart';
import '../entities/class_entity.dart';
import '../entities/class_student_entity.dart';

/// Abstract contract for class operations (teacher feature).
abstract class ClassRepository {
  /// Gets all classes taught by a teacher.
  FutureEither<List<ClassEntity>> getTeacherClasses(String teacherId);

  /// Gets all students in a specific class.
  FutureEither<List<ClassStudentEntity>> getClassStudents(String classId);
}
