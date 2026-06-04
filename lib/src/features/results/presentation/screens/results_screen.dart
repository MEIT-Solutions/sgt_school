import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../../domain/entities/result_entity.dart';
import '../providers/result_provider.dart';

/// Student exam results screen showing grades per subject.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      context.read<ResultProvider>().loadResults(session.user?.id ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final provider = context.watch<ResultProvider>();

    final totalExams = provider.results.length;
    final average = provider.summary?.percentage ?? 0.0;
    final overallGrade = provider.summary?.overallGrade ?? '-';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('results.title'.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? AppErrorWidget(
                  message: provider.error,
                  onRetry: () {
                    final session = context.read<SessionProvider>();
                    context
                        .read<ResultProvider>()
                        .loadResults(session.user?.id ?? '');
                  },
                )
              : provider.results.isEmpty
                  ? Center(
                      child: AppEmptyState(
                          icon: Icons.bar_chart,
                          title: 'results.no_results'.tr()))
                  : Column(
                      children: [
                        // Premium Results Summary Card
                        Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cs.primary, cs.primaryContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.analytics_outlined,
                                          color: cs.onSecondary, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'results.title'.tr(),
                                        style: tt.titleSmall?.copyWith(
                                          color: cs.onSecondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: cs.onSecondary
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${average.toStringAsFixed(1)}%',
                                      style: tt.labelSmall?.copyWith(
                                        color: cs.onSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: average / 100.0,
                                  backgroundColor:
                                      cs.onSecondary.withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    average >= 75
                                        ? const Color(0xFF4DB6AC)
                                        : const Color(0xFFFFD54F),
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _SummaryCol(
                                    label: 'results.exams_taken'.tr(),
                                    value: '$totalExams',
                                    textColor: cs.onSecondary,
                                    tt: tt,
                                  ),
                                  _SummaryCol(
                                    label: 'results.average_score'.tr(),
                                    value: '${average.toStringAsFixed(1)}%',
                                    textColor: cs.onSecondary,
                                    tt: tt,
                                  ),
                                  _SummaryCol(
                                    label: 'exams.grade'.tr(),
                                    value: overallGrade,
                                    textColor: cs.onSecondary,
                                    tt: tt,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _ResultsList(results: provider.results),
                        ),
                      ],
                    ),
    );
  }
}

class _SummaryCol extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;
  final TextTheme tt;

  const _SummaryCol({
    required this.label,
    required this.value,
    required this.textColor,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: tt.bodyLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<ResultEntity> results;
  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final r = results[i];
        final percentage = r.percentage.round();
        final pass = r.isPass;
        final statusColor =
            pass ? const Color(0xFF26A69A) : const Color(0xFFEF5350);
        final statusText = pass ? 'results.pass'.tr() : 'results.fail'.tr();

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Circular grade badge
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: _gradeColor(r.grade).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          r.grade,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _gradeColor(r.grade),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.subject,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${'results.marks_obtained'.tr()}: ${r.marks} / ${r.total}',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  statusText,
                                  style: tt.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$percentage%',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _gradeColor(r.grade),
                          ),
                        ),
                        Text(
                          'exams.percentage'.tr(),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (r.admissionNo != null && r.admissionNo!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${'profile.admission_no'.tr()}: ${r.admissionNo}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _gradeColor(String grade) {
    return switch (grade) {
      'A+' || 'A' => const Color(0xFF26A69A),
      'B+' || 'B' => const Color(0xFF42A5F5),
      'C+' || 'C' => const Color(0xFFFFA726),
      _ => const Color(0xFFEF5350),
    };
  }
}
