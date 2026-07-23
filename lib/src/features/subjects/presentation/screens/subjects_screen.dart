import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/subject_provider.dart';

/// Subjects list showing subject name, teacher, and colored icon.
class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      context.read<SubjectProvider>().loadSubjects(session.user?.id ?? '');
    });
  }

  Future<void> _refresh() {
    final session = context.read<SessionProvider>();
    return context.read<SubjectProvider>().loadSubjects(session.user?.id ?? '');
  }


  static const _subjectIcons = {
    'calculate': Icons.calculate,
    'science': Icons.science,
    'menu_book': Icons.menu_book,
    'history_edu': Icons.history_edu,
    'public': Icons.public,
    'computer': Icons.computer,
    'translate': Icons.translate,
    'sports_soccer': Icons.sports_soccer,
  };

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<SubjectProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppTopBar(title: 'subjects.title'.tr()),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.isLoading
            ? const AppSkeletonList(spacing: 8)
            : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subj = provider.subjects[index];
                final color = AppColors.colorForIndex(index);
                final icon = _subjectIcons[subj.icon] ?? Icons.book;

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
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(subj.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(subj.teacher, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}
