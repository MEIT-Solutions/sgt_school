import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import '../../domain/entities/activity_entity.dart';
import '../providers/activity_provider.dart';

/// School activities screen — flat list of all activities.
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivities();
    });
  }

  Future<void> _refresh() {
    return context.read<ActivityProvider>().loadActivities();
  }

  static const _stateColors = {
    'announced': Color(0xFF5C6BC0),
    'completed': Color(0xFF26A69A),
    'draft': Color(0xFFFFA726),
  };

  static const _stateIcons = {
    'announced': Icons.campaign,
    'completed': Icons.check_circle,
    'draft': Icons.edit_note,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppTopBar(title: 'activities.title'.tr()),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.isLoading
          ? const AppSkeletonList()
          : provider.error != null
              ? AppErrorWidget(
                  message: provider.error,
                  onRetry: () {
                    context.read<ActivityProvider>().loadActivities();
                  },
                )
              : provider.activities.isEmpty
                  ? Center(
                      child: AppEmptyState(
                        icon: Icons.event_busy,
                        title: 'activities.no_activities'.tr(),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.activities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final a = provider.activities[i];
                        final stateColor = _stateColors[a.state] ?? const Color(0xFF5C6BC0);
                        final stateIcon = _stateIcons[a.state] ?? Icons.info_outline;

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row with state badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: stateColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      stateIcon,
                                      color: stateColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      a.title,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: stateColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      a.state.toUpperCase(),
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: stateColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Class & Date info
                              Row(
                                children: [
                                  Icon(
                                    Icons.class_,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    a.className,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    a.activityDate,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),

                              // Daily activity description
                              if (a.dailyActivity.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  a.dailyActivity,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],

                              // Attachments section
                              if (a.hasAttachments) ...[
                                const SizedBox(height: 12),
                                _AttachmentsSection(activity: a),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
      ),
    );
  }
}

/// Collapsible attachments section shown on activity cards.
class _AttachmentsSection extends StatelessWidget {
  final ActivityEntity activity;
  const _AttachmentsSection({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          height: 1,
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 12),
        // Header
        Row(
          children: [
            Icon(Icons.attach_file, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              '${'activities.attachments'.tr()} (${activity.attachmentCount})',
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Exam Paper
        if (activity.examPaper != null)
          _AttachmentRow(
            icon: Icons.description_outlined,
            categoryLabel: 'activities.exam_paper'.tr(),
            attachment: activity.examPaper!,
          ),

        // Grade Report
        if (activity.gradeReport != null)
          _AttachmentRow(
            icon: Icons.assessment_outlined,
            categoryLabel: 'activities.grade_report'.tr(),
            attachment: activity.gradeReport!,
          ),

        // Documents
        ...activity.documents.map(
          (doc) => _AttachmentRow(
            icon: Icons.folder_outlined,
            categoryLabel: doc.title.isNotEmpty
                ? doc.title
                : 'activities.documents'.tr(),
            attachment: doc,
          ),
        ),
      ],
    );
  }
}

/// A single attachment row with file name and download button.
class _AttachmentRow extends StatelessWidget {
  final IconData icon;
  final String categoryLabel;
  final ActivityAttachment attachment;

  const _AttachmentRow({
    required this.icon,
    required this.categoryLabel,
    required this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final provider = context.watch<ActivityProvider>();
    final isDownloading = provider.isDownloading(attachment.fileUrl);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            // File type icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: cs.primary),
            ),
            const SizedBox(width: 10),
            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryLabel,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    attachment.fileName,
                    style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Download button / loading indicator
            if (isDownloading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    context.read<ActivityProvider>().downloadFile(
                          context,
                          attachment.fileUrl,
                          attachment.fileName,
                        );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.download_rounded,
                      size: 18,
                      color: cs.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
