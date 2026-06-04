import '../../imports/imports.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/session_provider.dart';
import '../../features/settings/presentation/providers/settings_provider.dart';
import '../../features/attendance/presentation/providers/attendance_check_provider.dart';
import '../../features/timetable/presentation/providers/timetable_provider.dart';
import '../../features/subjects/presentation/providers/subject_provider.dart';
import '../../features/exams/presentation/providers/exam_provider.dart';
import '../../features/results/presentation/providers/result_provider.dart';
import '../../features/fees/presentation/providers/fee_provider.dart';
import '../../features/activities/presentation/providers/activity_provider.dart';
import '../../features/notices/presentation/providers/notification_provider.dart';
import '../../features/assignments/presentation/providers/assignment_provider.dart';
import '../../features/classes/presentation/providers/class_provider.dart';
import '../../features/children/presentation/providers/child_provider.dart';

/// A wrapper to initialize the chosen State Management library.
class StateWrapper extends StatelessWidget {
  final Widget child;

  const StateWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Share a single repository instance across both providers.
    final authRepository = AuthRepositoryImpl();

    return MultiProvider(
      providers: [
        // Auth & core
        ChangeNotifierProvider(
          create: (_) => SessionProvider(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
        // Feature providers
        ChangeNotifierProvider(
          create: (_) => AttendanceCheckProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TimetableProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubjectProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExamProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ResultProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FeeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ActivityProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AssignmentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClassProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChildProvider(),
        ),
      ],
      child: child,
    );
  }
}
