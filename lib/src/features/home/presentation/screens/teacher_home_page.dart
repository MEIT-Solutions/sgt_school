import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import 'package:sgt_school/src/features/classes/presentation/providers/class_provider.dart';
import 'package:sgt_school/src/features/assignments/presentation/providers/assignment_provider.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = context.read<SessionProvider>();
      final teacherId = session.user?.id ?? '';
      if (teacherId.isNotEmpty) {
        context.read<ClassProvider>().loadClasses(teacherId);
        context.read<AssignmentProvider>().loadAssignments(teacherId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final session = context.watch<SessionProvider>();
    final user = session.user;
    final classProvider = context.watch<ClassProvider>();
    final classes = classProvider.classes;

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'home.good_morning'.tr()
        : hour < 17
            ? 'home.good_afternoon'.tr()
            : 'home.good_evening'.tr();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
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

          // ── Quick Stats Row ──
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: _QuickStat(
                      icon: Icons.class_,
                      value: '${classes.length}',
                      label: 'teacher.my_classes'.tr(),
                      color: GridIconColors.profile,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickStat(
                      icon: Icons.people,
                      value: '${classes.fold<int>(0, (sum, c) => sum + c.studentCount)}',
                      label: 'teacher.total_students'.tr(),
                      color: GridIconColors.attendance,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickStat(
                      icon: Icons.assignment,
                      value: '${context.watch<AssignmentProvider>().active.length}',
                      label: 'teacher.active_tasks'.tr(),
                      color: GridIconColors.tasks,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── My Classes ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'teacher.my_classes'.tr(),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cls = classes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => context.push('/classes/${cls.id}'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.class_, color: colorScheme.onPrimaryContainer),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cls.displayName,
                                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${cls.subject} • ${cls.studentCount} ${'teacher.students'.tr()}',
                                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: classes.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
