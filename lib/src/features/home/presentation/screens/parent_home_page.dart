import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import 'package:sgt_school/src/features/children/presentation/providers/child_provider.dart';
import 'package:sgt_school/src/features/children/domain/entities/child_entity.dart';

/// Custom clipper shared with the student home page curved header.
class _ParentHeaderClipper extends CustomClipper<Path> {
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

/// Parent home dashboard showing children overview and quick stats.
class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      if (session.isAuthenticated) {
        context.read<ChildProvider>().loadChildren(session.user?.id ?? '');
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
    final childProvider = context.watch<ChildProvider>();

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'home.good_morning'.tr()
        : hour < 17
            ? 'home.good_afternoon'.tr()
            : 'home.good_evening'.tr();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () => context.read<ChildProvider>().loadChildren(session.user?.id ?? ''),
        child: CustomScrollView(
        slivers: [
          // ── Curved Header ──
          SliverToBoxAdapter(
            child: ClipPath(
              clipper: _ParentHeaderClipper(),
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
                                'home.role_parent'.tr(),
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

          // ── Children Overview ──
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'parent.my_children'.tr(),
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (childProvider.isLoading)
            const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              )),
            )
          else if (childProvider.children.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'children.title'.tr(),
                    style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final child = childProvider.children[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < childProvider.children.length - 1 ? 12 : 0),
                      child: _ChildCard(
                        child: child,
                        onTap: () => context.push('/children/${child.studentId}'),
                      ),
                    );
                  },
                  childCount: childProvider.children.length,
                ),
              ),
            ),

          // ── Quick Stats ──
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'parent.quick_stats'.tr(),
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.payment,
                          label: 'parent.fees_due'.tr(),
                          value: '—',
                          color: GridIconColors.fees,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.quiz,
                          label: 'parent.upcoming_exams'.tr(),
                          value: '—',
                          color: GridIconColors.timetable,
                        ),
                      ),
                    ],
                  ),
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

class _ChildCard extends StatelessWidget {
  final ChildEntity child;
  final VoidCallback onTap;

  const _ChildCard({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(child.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${child.classDisplay} • ${'home.roll_no'.tr()} ${child.rollNo}', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${child.attendancePercentage}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: GridIconColors.attendance)),
                Text('home.attendance'.tr(), style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
