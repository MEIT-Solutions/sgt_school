/// Centralized route path constants for GoRouter.
///
/// Use these variables instead of raw strings throughout the app.
/// Example: `context.go(AppRoutes.login)` instead of `context.go('/login')`.
abstract final class AppRoutes {
  AppRoutes._();

  // Auth
  static const splash = '/splash';
  static const login = '/login';
  static const cloudSettings = '/cloud-settings';

  // Shell tabs
  static const home = '/home';

  static const classes = '/classes';
  static const profile = '/profile';
  static const children = '/children';
  static const assignments = '/assignments';

  // Sub-routes (pushed on top of shell)
  static const timetable = '/timetable';
  static const exams = '/exams';
  static const examDetail = '/exams/:id';
  static const fees = '/fees';
  static const subjects = '/subjects';
  static const activities = '/activities';
  static const examResults = '/exam-results';
  static const notices = '/notices';
  static const classDetail = '/classes/:id';
  static const childDetail = '/children/:id';
  static const assignmentDetail = '/assignments/:id';
  static const settings = '/settings';

  // Teacher-specific sub-routes
  static const teacherSubjects = '/teacher/subjects';
  static const teacherClasses = '/teacher/classes';
  static const teacherActivities = '/teacher/activities';
  static const teacherExams = '/teacher/exams';
  static const teacherStudents = '/teacher/students';
  static const teacherExamResults = '/teacher/exam-results';
}
