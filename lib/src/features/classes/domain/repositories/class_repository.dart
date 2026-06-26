import 'package:sgt_school/src/utils/utils.dart';
import '../entities/class_student_entity.dart';
import '../entities/teacher_class_entity.dart';

/// Abstract contract for class operations (teacher feature).
abstract class ClassRepository {
  /// Gets all students in the teacher's classes.
  FutureEither<List<ClassStudentEntity>> getTeacherClasses(String teacherId);

  /// Gets the list of classes assigned to a teacher.
  FutureEither<List<TeacherClassEntity>> getTeacherClassList(String teacherId);

  /// Gets all students for a teacher (paginated).
  FutureEither<List<ClassStudentEntity>> getTeacherStudents(String teacherId);
}
