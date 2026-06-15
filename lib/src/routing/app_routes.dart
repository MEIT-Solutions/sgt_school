/// Centralized route path constants for GoRouter.
///
/// Use these variables instead of raw strings throughout the app.
/// Example: `context.go(AppRoutes.login)` instead of `context.go('/login')`.
abstract final class AppRoutes {
  AppRoutes._();

  // Auth
  static const login = '/login';

  // Shell tabs
  static const home = '/home';
  //static const attendance = '/attendance';
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
  static const results = '/results';
  static const notices = '/notices';
  static const classDetail = '/classes/:id';
  static const childDetail = '/children/:id';
  static const assignmentDetail = '/assignments/:id';
  static const settings = '/settings';
}
