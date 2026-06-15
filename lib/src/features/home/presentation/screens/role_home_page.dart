import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/domain/entities/user.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import 'package:sgt_school/src/features/home/presentation/screens/home_page.dart';
// import 'package:sgt_school/src/features/home/presentation/screens/parent_home_page.dart'; // temporarily disabled
import 'package:sgt_school/src/features/home/presentation/screens/teacher_home_page.dart';

/// Routes to the correct home dashboard based on the logged-in user's role.
class RoleHomePage extends StatelessWidget {
  const RoleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final role = context.watch<SessionProvider>().user?.role ?? UserRole.student;

    return switch (role) {
      UserRole.student => const StudentHomePage(),
      // UserRole.parent => const ParentHomePage(), // temporarily disabled
      UserRole.parent => const StudentHomePage(),
      UserRole.teacher => const TeacherHomePage(),
    };
  }
}
