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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppTopBar(title: 'teacher.activities'.tr()),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.activities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final activity = provider.activities[index];

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: GridIconColors.activities.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.directions_run, color: GridIconColors.activities, size: 22),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.title,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (activity.className.isNotEmpty) ...[
                                          Icon(Icons.class_, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Text(
                                            activity.className,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                        ],
                                        Icon(Icons.calendar_today, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Text(
                                          activity.activityDate,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (activity.dailyActivity.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        activity.dailyActivity,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                        ),
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
    );
  }
}
