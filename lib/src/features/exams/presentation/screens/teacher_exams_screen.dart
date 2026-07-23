import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/exam_provider.dart';

/// Teacher exams screen showing exams with class, subject, and marks info.
class TeacherExamsScreen extends StatefulWidget {
  const TeacherExamsScreen({super.key});

  @override
  State<TeacherExamsScreen> createState() => _TeacherExamsScreenState();
}

class _TeacherExamsScreenState extends State<TeacherExamsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      final teacherId = session.user?.id ?? '';
      if (teacherId.isNotEmpty) {
        context.read<ExamProvider>().loadTeacherExams(teacherId);
      }
    });
  }

  Future<void> _refresh() {
    final session = context.read<SessionProvider>();
    final teacherId = session.user?.id ?? '';
    return context.read<ExamProvider>().loadTeacherExams(teacherId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ExamProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppTopBar(title: 'teacher.exams'.tr()),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.isLoading
          ? const AppSkeletonList(spacing: 8)
          : provider.error != null
              ? AppErrorWidget(
                  message: provider.error!,
                  onRetry: () {
                    final session = context.read<SessionProvider>();
                    final teacherId = session.user?.id ?? '';
                    if (teacherId.isNotEmpty) {
                      context.read<ExamProvider>().loadTeacherExams(teacherId);
                    }
                  },
                )
              : provider.teacherExams.isEmpty
                  ? Center(
                      child: Text(
                        'teacher.no_exams'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.teacherExams.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final exam = provider.teacherExams[index];

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
                                  color: GridIconColors.exams.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.assignment, color: GridIconColors.exams, size: 22),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.name,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (exam.className != null && exam.className!.isNotEmpty) ...[
                                          Icon(Icons.class_, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              exam.className!,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        if (exam.subjectName != null && exam.subjectName!.isNotEmpty) ...[
                                          Icon(Icons.menu_book, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              exam.subjectName!,
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Text(
                                          exam.examDatetime.toDisplayDate,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${'teacher.max_marks'.tr()}: ${exam.maxMarks}',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w600,
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
                      },
                    ),
      ),
    );
  }
}
