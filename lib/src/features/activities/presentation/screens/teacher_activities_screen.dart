import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/activity_provider.dart';

/// Teacher activities screen showing activities for the logged-in teacher.
class TeacherActivitiesScreen extends StatefulWidget {
  const TeacherActivitiesScreen({super.key});

  @override
  State<TeacherActivitiesScreen> createState() => _TeacherActivitiesScreenState();
}

class _TeacherActivitiesScreenState extends State<TeacherActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      final teacherId = session.user?.id ?? '';
      if (teacherId.isNotEmpty) {
        context.read<ActivityProvider>().loadTeacherActivities(teacherId);
      }
    });
  }

  Future<void> _refresh() {
    final session = context.read<SessionProvider>();
    final teacherId = session.user?.id ?? '';
    return context.read<ActivityProvider>().loadTeacherActivities(teacherId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppTopBar(title: 'teacher.activities'.tr()),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.isLoading
          ? SkeletonWrapper(
              isLoading: true,
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: 8,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, __) => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: GridIconColors.activities.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.directions_run, color: GridIconColors.activities, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(BoneMock.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(BoneMock.subtitle, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : provider.error != null
              ? AppErrorWidget(
                  message: provider.error!,
                  onRetry: () {
                    final session = context.read<SessionProvider>();
                    final teacherId = session.user?.id ?? '';
                    if (teacherId.isNotEmpty) {
                      context.read<ActivityProvider>().loadTeacherActivities(teacherId);
                    }
                  },
                )
              : provider.activities.isEmpty
                  ? Center(
                      child: Text(
                        'teacher.no_activities'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: provider.activities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final activity = provider.activities[index];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: GridIconColors.activities.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.directions_run, color: GridIconColors.activities, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ── Date badge ──
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 12, color: theme.colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          activity.activityDate,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (activity.className.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 3,
                                            height: 3,
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.onSurfaceVariant,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            activity.className,
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    // ── Title ──
                                    Text(
                                      activity.title,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // ── Daily activity description ──
                                    if (activity.dailyActivity.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        activity.dailyActivity,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
      ),
    );
  }
}
