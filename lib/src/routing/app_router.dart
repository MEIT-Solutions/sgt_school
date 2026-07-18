import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:sgt_school/src/routing/global_navigator.dart';
import 'package:sgt_school/src/routing/app_routes.dart';
import 'package:sgt_school/src/routing/app_shell.dart';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import 'package:sgt_school/src/features/auth/presentation/screens/login_screen.dart';
import 'package:sgt_school/src/features/auth/presentation/screens/cloud_settings_screen.dart';
import 'package:sgt_school/src/features/auth/presentation/screens/splash_screen.dart';
import 'package:sgt_school/src/features/home/presentation/screens/role_home_page.dart';
import 'package:sgt_school/src/features/subjects/presentation/screens/subjects_screen.dart';
import 'package:sgt_school/src/features/timetable/presentation/screens/timetable_screen.dart';
import 'package:sgt_school/src/features/exams/presentation/screens/exams_screen.dart';
import 'package:sgt_school/src/features/exams/presentation/screens/exam_detail_screen.dart';
import 'package:sgt_school/src/features/fees/presentation/screens/fees_screen.dart';
import 'package:sgt_school/src/features/activities/presentation/screens/activities_screen.dart';
import 'package:sgt_school/src/features/results/presentation/screens/results_screen.dart';
import 'package:sgt_school/src/features/notices/presentation/screens/notification_screen.dart';
import 'package:sgt_school/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:sgt_school/src/features/children/presentation/screens/children_screen.dart';
import 'package:sgt_school/src/features/children/presentation/screens/child_detail_screen.dart';
import 'package:sgt_school/src/features/classes/presentation/screens/class_detail_screen.dart';
import 'package:sgt_school/src/features/assignments/presentation/screens/assignment_detail_screen.dart';
import 'package:sgt_school/src/features/assignments/domain/entities/assignment_entity.dart';
import 'package:sgt_school/src/features/settings/presentation/screens/settings_screen.dart';
import 'package:sgt_school/src/features/subjects/presentation/screens/teacher_subjects_screen.dart';
import 'package:sgt_school/src/features/classes/presentation/screens/teacher_classes_screen.dart';
import 'package:sgt_school/src/features/activities/presentation/screens/teacher_activities_screen.dart';
import 'package:sgt_school/src/features/exams/presentation/screens/teacher_exams_screen.dart';
import 'package:sgt_school/src/features/classes/presentation/screens/teacher_students_screen.dart';
import 'package:sgt_school/src/features/exams/presentation/screens/teacher_exam_results_screen.dart';

GoRouter buildAppRouter(SessionProvider sessionProvider) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: sessionProvider,
    redirect: (context, state) {
      final status = sessionProvider.status;
      final isOnLogin = state.uri.path == AppRoutes.login;
      final isOnSplash = state.uri.path == AppRoutes.splash;
      final isOnCloud = state.uri.path == AppRoutes.cloudSettings;
      final isOnSettings = state.uri.path == AppRoutes.settings;

      if (isOnCloud || isOnSettings) return null;

      // Still loading session — stay on (or go to) splash
      if (status == SessionStatus.unknown) {
        return isOnSplash ? null : AppRoutes.splash;
      }

      // Not authenticated — force login
      if (status == SessionStatus.unauthenticated) {
        return isOnLogin ? null : AppRoutes.login;
      }

      // Authenticated — redirect away from login/splash to home
      if (isOnLogin || isOnSplash) return AppRoutes.home;

      return null;
    },
    routes: <RouteBase>[
      // Splash (shown while session is loading)
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login (no shell — default platform transition)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: AppRoutes.cloudSettings,
        name: 'cloud-settings',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const CloudSettingsScreen()),
      ),

      // ── Shell with bottom nav ──
      ShellRoute(
        builder: (context, state, child) {
          final role = context.read<SessionProvider>().user?.role ?? UserRole.student;
          final index = _indexFromLocation(state.uri.path, role);
          return AppShell(
            currentIndex: index,
            onTabChanged: (i) => _onTabChanged(context, i, role),
            child: child,
          );
        },
        routes: [
          // Home tab
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) => _fadeTransitionPage(state, const RoleHomePage()),
          ),
          // Profile tab
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) => _fadeTransitionPage(state, const ProfileScreen()),
          ),
          // Parent: Children tab
          GoRoute(
            path: AppRoutes.children,
            name: 'children',
            pageBuilder: (context, state) => _fadeTransitionPage(state, const ChildrenScreen()),
          ),
        ],
      ),

      // ── Sub-routes (pushed on top of shell) ──
      GoRoute(
        path: AppRoutes.timetable,
        name: 'timetable',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const TimetableScreen()),
      ),
      GoRoute(
        path: AppRoutes.exams,
        name: 'exams',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const ExamsScreen()),
      ),
      GoRoute(
        path: '/exams/:id',
        name: 'exam-detail',
        pageBuilder: (context, state) {
          final exam = state.extra as Map<String, dynamic>? ?? {};
          return _pageTransitionAnimation(state, ExamDetailScreen(exam: exam));
        },
      ),
      GoRoute(
        path: AppRoutes.fees,
        name: 'fees',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const FeesScreen()),
      ),
      GoRoute(
        path: AppRoutes.subjects,
        name: 'subjects',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const SubjectsScreen()),
      ),
      GoRoute(
        path: AppRoutes.activities,
        name: 'activities',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const ActivitiesScreen()),
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const ResultsScreen()),
      ),
      GoRoute(
        path: AppRoutes.notices,
        name: 'notices',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const NotificationScreen()),
      ),
      GoRoute(
        path: '/children/:id',
        name: 'child-detail',
        pageBuilder: (context, state) => _pageTransitionAnimation(
          state,
          ChildDetailScreen(childId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/classes/:id',
        name: 'class-detail',
        pageBuilder: (context, state) => _pageTransitionAnimation(
          state,
          ClassDetailScreen(classId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/assignments/:id',
        name: 'assignment-detail',
        pageBuilder: (context, state) {
          final assignment = state.extra as AssignmentEntity;
          return _pageTransitionAnimation(
            state,
            AssignmentDetailScreen(assignment: assignment),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const SettingsScreen()),
      ),

      // ── Teacher sub-routes ──
      GoRoute(
        path: AppRoutes.teacherSubjects,
        name: 'teacher-subjects',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const TeacherSubjectsScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherClasses,
        name: 'teacher-classes',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const TeacherClassesScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherActivities,
        name: 'teacher-activities',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const TeacherActivitiesScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherExams,
        name: 'teacher-exams',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const TeacherExamsScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherStudents,
        name: 'teacher-students',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const TeacherStudentsScreen()),
      ),
      GoRoute(
        path: AppRoutes.teacherExamResults,
        name: 'teacher-exam-results',
        pageBuilder: (context, state) => _pageTransitionAnimation(state, const TeacherExamResultsScreen()),
      ),
    ],
  );
}

// ─── Transition Helpers ───────────────────────────────────────────────────

/// No animation for bottom navigation tab switches (iOS-style instant swap).
CustomTransitionPage<void> _fadeTransitionPage(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}

/// iOS-style slide-from-right for sub-routes pushed on top of the shell.
CustomTransitionPage<void> _pageTransitionAnimation(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    reverseTransitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        linearTransition: false,
        child: child,
      );
    },
  );
}

/// Maps the current URI path to a bottom nav index based on role.
int _indexFromLocation(String path, UserRole role) {
  switch (role) {
    case UserRole.student:
      // Nav: Home=0, Profile=1
      if (path.startsWith('/profile')) return 1;
      return 0;
    case UserRole.parent:
      // Nav: Home=0, Children=1, Profile=2
      if (path.startsWith('/children')) return 1;
      if (path.startsWith('/profile')) return 2;
      return 0;
    case UserRole.teacher:
      // Nav: Home=0, Profile=1
      if (path.startsWith('/profile')) return 1;
      return 0;
  }
}

/// Navigates to the correct tab path when a bottom nav destination is tapped.
void _onTabChanged(BuildContext context, int index, UserRole role) {
  switch (role) {
    case UserRole.student:
      const paths = [AppRoutes.home, AppRoutes.profile];
      context.go(paths[index]);
    case UserRole.parent:
      const paths = [AppRoutes.home, AppRoutes.children, AppRoutes.profile];
      context.go(paths[index]);
    case UserRole.teacher:
      const paths = [AppRoutes.home, AppRoutes.profile];
      context.go(paths[index]);
  }
}
