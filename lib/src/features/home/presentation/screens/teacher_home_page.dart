import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';

/// Custom clipper shared with the student home page curved header.
class _TeacherHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 4, size.height + 10, size.width / 2, size.height - 15);
    path.quadraticBezierTo(size.width * 3 / 4, size.height - 40, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Teacher home dashboard showing today's schedule and class overview.
class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final session = context.watch<SessionProvider>();
    final user = session.user;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'home.good_morning'.tr()
        : hour < 17
            ? 'home.good_afternoon'.tr()
            : 'home.good_evening'.tr();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () => Future.delayed(const Duration(milliseconds: 500)),
        child: CustomScrollView(
        slivers: [
          // ── Curved Header ──
          SliverToBoxAdapter(
            child: ClipPath(
              clipper: _TeacherHeaderClipper(),
              child: Container(
                color: colorScheme.primary,
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + 16,
                  left: 24,
                  right: 24,
                  bottom: 40,
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                            ? CommonImage(
                                imageUrl: user.photoUrl!,
                                width: 80,
                                height: 80,
                                borderRadius: BorderRadius.circular(40),
                                placeholder: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                errorWidget: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onPrimary.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.person, size: 40, color: colorScheme.onPrimary),
                                ),
                              )
                            : CircleAvatar(
                                radius: 40,
                                backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
                                child: Icon(Icons.person, size: 40, color: colorScheme.onPrimary),
                              ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.name ?? '',
                                style: textTheme.headlineSmall?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${user?.subject ?? ''} • ${user?.department ?? ''}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: -8,
                      right: -12,
                      child: IconButton(
                        icon: const Icon(Icons.notifications),
                        color: colorScheme.onPrimary,
                        onPressed: () => context.push(AppRoutes.notices),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Quick Access Grid ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                mainAxisSpacing: 4,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
                children: [
                  _GridItem(
                      icon: Icons.menu_book,
                      label: 'home.subjects'.tr(),
                      color: GridIconColors.subjects,
                      onTap: () => context.push(AppRoutes.teacherSubjects)),
                  _GridItem(
                      icon: Icons.class_,
                      label: 'teacher.classes'.tr(),
                      color: GridIconColors.timetable,
                      onTap: () => context.push(AppRoutes.teacherClasses)),
                  _GridItem(
                      icon: Icons.directions_run,
                      label: 'home.activities'.tr(),
                      color: GridIconColors.activities,
                      onTap: () => context.push(AppRoutes.teacherActivities)),
                  _GridItem(
                      icon: Icons.assignment,
                      label: 'home.exams'.tr(),
                      color: GridIconColors.exams,
                      onTap: () => context.push(AppRoutes.teacherExams)),
                  _GridItem(
                      icon: Icons.people,
                      label: 'teacher.students_title'.tr(),
                      color: GridIconColors.attendance,
                      onTap: () => context.push(AppRoutes.teacherStudents)),
                  _GridItem(
                      icon: Icons.grading,
                      label: 'teacher.exam_results'.tr(),
                      color: GridIconColors.results,
                      onTap: () => context.push(AppRoutes.teacherExamResults)),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GridItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
