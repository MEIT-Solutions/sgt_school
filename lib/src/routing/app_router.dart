import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:sgt_school/src/routing/global_navigator.dart';
import 'package:sgt_school/src/routing/app_routes.dart';
import 'package:sgt_school/src/routing/app_shell.dart';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import 'package:sgt_school/src/features/auth/presentation/screens/login_screen.dart';
import 'package:sgt_school/src/features/home/presentation/screens/role_home_page.dart';
import 'package:sgt_school/src/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:sgt_school/src/features/subjects/presentation/screens/subjects_screen.dart';
import 'package:sgt_school/src/features/timetable/presentation/screens/timetable_screen.dart';
import 'package:sgt_school/src/features/exams/presentation/screens/exams_screen.dart';
import 'package:sgt_school/src/features/exams/presentation/screens/exam_detail_screen.dart';
import 'package:sgt_school/src/features/fees/presentation/screens/fees_screen.dart';
import 'package:sgt_school/src/features/activities/presentation/screens/activities_screen.dart';
import 'package:sgt_school/src/features/results/presentation/screens/results_screen.dart';
import 'package:sgt_school/src/features/notices/presentation/screens/notices_screen.dart';
import 'package:sgt_school/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:sgt_school/src/features/children/presentation/screens/children_screen.dart';
import 'package:sgt_school/src/features/children/presentation/screens/child_detail_screen.dart';
import 'package:sgt_school/src/features/classes/presentation/screens/classes_screen.dart';
import 'package:sgt_school/src/features/classes/presentation/screens/class_detail_screen.dart';
import 'package:sgt_school/src/features/assignments/presentation/screens/assignment_detail_screen.dart';
import 'package:sgt_school/src/features/assignments/domain/entities/assignment_entity.dart';
import 'package:sgt_school/src/features/settings/presentation/screens/settings_screen.dart';

GoRouter buildAppRouter(SessionProvider sessionProvider) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: sessionProvider,
    redirect: (context, state) {
      final status = sessionProvider.status;
      final isOnLogin = state.uri.path == AppRoutes.login;

      // Still loading session — stay on current page (no redirect)
      if (status == SessionStatus.unknown) return null;

      // Not authenticated — force login
      if (status == SessionStatus.unauthenticated) {
        return isOnLogin ? null : AppRoutes.login;
      }

      // Authenticated — redirect away from login
      if (isOnLogin) return AppRoutes.home;

      return null;
    },
    routes: <RouteBase>[
      // Login (no shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
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
            builder: (context, state) => const RoleHomePage(),
          ),
          // Student: Attendance tab
          GoRoute(
            path: AppRoutes.attendance,
            name: 'attendance',
            builder: (context, state) => const AttendanceScreen(),
          ),
          // Student/Teacher: Classes tab
          GoRoute(
            path: AppRoutes.classes,
            name: 'classes',
            builder: (context, state) => const ClassesScreen(),
          ),
          // Profile tab
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          // Parent: Children tab
          GoRoute(
            path: AppRoutes.children,
            name: 'children',
            builder: (context, state) => const ChildrenScreen(),
          ),
        ],
      ),

      // ── Sub-routes (pushed on top of shell) ──
      GoRoute(
        path: AppRoutes.timetable,
        name: 'timetable',
        builder: (context, state) => const TimetableScreen(),
      ),
      GoRoute(
        path: AppRoutes.exams,
        name: 'exams',
        builder: (context, state) => const ExamsScreen(),
      ),
      GoRoute(
        path: '/exams/:id',
        name: 'exam-detail',
        builder: (context, state) {
          final exam = state.extra as Map<String, dynamic>? ?? {};
          return ExamDetailScreen(exam: exam);
        },
      ),
      GoRoute(
        path: AppRoutes.fees,
        name: 'fees',
        builder: (context, state) => const FeesScreen(),
      ),
      GoRoute(
        path: AppRoutes.subjects,
        name: 'subjects',
        builder: (context, state) => const SubjectsScreen(),
      ),
      GoRoute(
        path: AppRoutes.activities,
        name: 'activities',
        builder: (context, state) => const ActivitiesScreen(),
      ),
      GoRoute(
        path: AppRoutes.results,
        name: 'results',
        builder: (context, state) => const ResultsScreen(),
      ),
      GoRoute(
        path: AppRoutes.notices,
        name: 'notices',
        builder: (context, state) => const NoticesScreen(),
      ),
      GoRoute(
        path: '/children/:id',
        name: 'child-detail',
        builder: (context, state) => ChildDetailScreen(childId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/classes/:id',
        name: 'class-detail',
        builder: (context, state) => ClassDetailScreen(classId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/assignments/:id',
        name: 'assignment-detail',
        builder: (context, state) {
          final assignment = state.extra as AssignmentEntity;
          return AssignmentDetailScreen(assignment: assignment);
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// Maps the current URI path to a bottom nav index based on role.
int _indexFromLocation(String path, UserRole role) {
  switch (role) {
    case UserRole.student:
      if (path.startsWith('/attendance')) return 1;
      if (path.startsWith('/classes')) return 2;
      if (path.startsWith('/profile')) return 3;
      return 0;
    case UserRole.parent:
      if (path.startsWith('/children')) return 1;
      if (path.startsWith('/profile')) return 2;
      return 0;
    case UserRole.teacher:
      if (path.startsWith('/classes')) return 1;
      if (path.startsWith('/profile')) return 2;
      return 0;
  }
}

/// Navigates to the correct tab path when a bottom nav destination is tapped.
void _onTabChanged(BuildContext context, int index, UserRole role) {
  switch (role) {
    case UserRole.student:
      const paths = [AppRoutes.home, AppRoutes.attendance, AppRoutes.classes, AppRoutes.profile];
      context.go(paths[index]);
    case UserRole.parent:
      const paths = [AppRoutes.home, AppRoutes.children, AppRoutes.profile];
      context.go(paths[index]);
    case UserRole.teacher:
      const paths = [AppRoutes.home, AppRoutes.classes, AppRoutes.profile];
      context.go(paths[index]);
  }
}
