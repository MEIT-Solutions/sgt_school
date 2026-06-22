import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import 'package:sgt_school/src/features/activities/presentation/providers/activity_provider.dart';

/// Custom clipper for the curved header
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    // Smooth wave: dips down on left, up on right
    path.quadraticBezierTo(
        size.width / 4, size.height + 10, size.width / 2, size.height - 15);
    path.quadraticBezierTo(
        size.width * 3 / 4, size.height - 40, size.width, size.height - 20);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Student home dashboard with curved greeting header, quick-access grid,
/// upcoming activities, and notification bell icon.
class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final session = context.watch<SessionProvider>();
    final user = session.user;
    final activityProvider = context.watch<ActivityProvider>();
    final previewActivities = activityProvider.activities.take(3).toList();

    // Determine time-based greeting
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
              clipper: _HeaderClipper(),
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
                        InkWell(
                          onTap: () => context.push(AppRoutes.profile),
                          child: user?.photoUrl != null &&
                                  user!.photoUrl!.isNotEmpty
                              ? CommonImage(
                                  imageUrl: user.photoUrl!,
                                  width: 80,
                                  height: 80,
                                  borderRadius: BorderRadius.circular(40),
                                  placeholder: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: colorScheme.onPrimary
                                          .withValues(alpha: 0.2),
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
                                      color: colorScheme.onPrimary
                                          .withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.person,
                                        size: 40, color: colorScheme.onPrimary),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 40,
                                  backgroundColor: colorScheme.onPrimary
                                      .withValues(alpha: 0.2),
                                  child: Icon(Icons.person,
                                      size: 40, color: colorScheme.onPrimary),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimary
                                      .withValues(alpha: 0.9),
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
                                'Class ${user?.grade ?? ''} - ${user?.section ?? ''}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimary
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${'home.roll_no'.tr()} ${user?.rollNo ?? ''}',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimary
                                      .withValues(alpha: 0.8),
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
                mainAxisSpacing: 0,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  _GridItem(
                      icon: Icons.assignment,
                      label: 'home.exams'.tr(),
                      color: GridIconColors.exams,
                      onTap: () => context.push(AppRoutes.exams)),
                  _GridItem(
                      icon: Icons.calendar_today,
                      label: 'home.timetable'.tr(),
                      color: GridIconColors.timetable,
                      onTap: () => context.push(AppRoutes.timetable)),
                  _GridItem(
                      icon: Icons.account_balance_wallet,
                      label: 'home.fees'.tr(),
                      color: GridIconColors.fees,
                      onTap: () => context.push(AppRoutes.fees)),
                  _GridItem(
                      icon: Icons.bar_chart,
                      label: 'home.results'.tr(),
                      color: GridIconColors.results,
                      onTap: () => context.push(AppRoutes.results)),
                  _GridItem(
                      icon: Icons.menu_book,
                      label: 'home.subjects'.tr(),
                      color: GridIconColors.subjects,
                      onTap: () => context.push(AppRoutes.subjects)),
                  _GridItem(
                      icon: Icons.directions_run,
                      label: 'home.activities'.tr(),
                      color: GridIconColors.activities,
                      onTap: () => context.push(AppRoutes.activities)),
                ],
              ),
            ),
          ),

          // ── Upcoming Activities ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'home.upcoming_events'.tr(),
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.activities),
                    child: Text('home.see_all'.tr()),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: activityProvider.isLoading
                ? SliverToBoxAdapter(
                    child: SkeletonWrapper(
                      isLoading: true,
                      child: Column(
                        children: List.generate(3, (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _EventCard(
                            title: BoneMock.name,
                            className: BoneMock.name,
                            activityDate: BoneMock.date,
                          ),
                        )),
                      ),
                    ),
                  )
                : previewActivities.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'activities.no_activities'.tr(),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index.isOdd) {
                              return const SizedBox(height: 8);
                            }
                            final a = previewActivities[index ~/ 2];
                            return _EventCard(
                              title: a.title,
                              className: a.className,
                              activityDate: a.activityDate,
                            );
                          },
                          childCount: previewActivities.length * 2 - 1,
                        ),
                      ),
          ),
        ],
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

class _EventCard extends StatelessWidget {
  final String title;
  final String className;
  final String activityDate;

  const _EventCard({
    required this.title,
    required this.className,
    required this.activityDate,
  });

  static const _color = Color(0xFF5C6BC0);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.campaign, color: _color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.class_, size: 12, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      className,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today, size: 12, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      activityDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
