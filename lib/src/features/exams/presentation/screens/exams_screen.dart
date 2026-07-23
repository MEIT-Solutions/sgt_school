import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/exam_provider.dart';
import '../../domain/entities/exam_entity.dart';

/// Exams list with Upcoming / Completed tabs.
class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      context.read<ExamProvider>().loadExams(session.user?.id ?? '');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final session = context.read<SessionProvider>();
    return context.read<ExamProvider>().loadExams(session.user?.id ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ExamProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('exams.title'.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
          indicatorColor: theme.colorScheme.onPrimary,
          tabs: [
            Tab(text: 'exams.upcoming'.tr()),
            Tab(text: 'exams.completed'.tr()),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.isLoading
            ? const AppSkeletonList(spacing: 8)
            : TabBarView(
                controller: _tabController,
                children: [
                  _ExamList(exams: provider.upcoming, showResult: false),
                  _ExamList(exams: provider.completed, showResult: true),
                ],
              ),
      ),
    );
  }
}

class _ExamList extends StatelessWidget {
  final List<ExamEntity> exams;
  final bool showResult;
  const _ExamList({required this.exams, required this.showResult});

  @override
  Widget build(BuildContext context) {
    if (exams.isEmpty) {
      return Center(
        child: AppEmptyState(
          icon: Icons.quiz_outlined,
          title: 'exams.no_exams'.tr(),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _ExamCard(exam: exams[index], showResult: showResult);
      },
    );
  }
}

class _ExamCard extends StatelessWidget {
  final ExamEntity exam;
  final bool showResult;
  const _ExamCard({required this.exam, required this.showResult});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: exam.isCompleted ? () => context.push('/exams/${exam.id}') : null,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exam.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(exam.date, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  if (exam.isCompleted) ...[
                    const SizedBox(height: 4),
                    Text(
                      'exams.view_result'.tr(),
                      style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (exam.isCompleted ? const Color(0xFF26A69A) : const Color(0xFF42A5F5)).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                exam.isCompleted ? 'exams.completed'.tr() : 'exams.upcoming'.tr(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: exam.isCompleted ? const Color(0xFF26A69A) : const Color(0xFF42A5F5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
