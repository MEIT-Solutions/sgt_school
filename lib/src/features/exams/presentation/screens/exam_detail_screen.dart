import 'package:sgt_school/src/imports/core_imports.dart';

/// Exam result detail with percentage, grade, and subject-wise marks.
class ExamDetailScreen extends StatelessWidget {
  final Map<String, dynamic> exam;
  const ExamDetailScreen({super.key, required this.exam});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final subjects = (exam['subjects'] as List<Map<String, dynamic>>?) ?? [];
    final percentage = exam['percentage'] as double?;
    final grade = exam['grade'] as String?;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppTopBar(title: 'exams.exam_result'.tr()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Header Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    exam['name'] as String? ?? '',
                    style: textTheme.titleMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exam['class'] ?? ''} • ${exam['date'] ?? ''}',
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.8)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text('exams.percentage'.tr(), style: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.7))),
                          const SizedBox(height: 4),
                          Text('${percentage?.toStringAsFixed(0) ?? '-'}%', style: textTheme.headlineMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Container(width: 1, height: 40, color: colorScheme.onPrimary.withValues(alpha: 0.3)),
                      Column(
                        children: [
                          Text('exams.grade'.tr(), style: textTheme.labelSmall?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.7))),
                          const SizedBox(height: 4),
                          Text(grade ?? '-', style: textTheme.headlineMedium?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Subject-wise marks ──
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'exams.subject_wise_marks'.tr(),
                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            ...subjects.map((subj) {
              final marks = subj['marks'] as int;
              final total = subj['total'] as int;
              final ratio = marks / total;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
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
                        child: Text(subj['name'] as String, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            backgroundColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation(
                              ratio >= 0.8 ? const Color(0xFF26A69A) : ratio >= 0.6 ? const Color(0xFFFFA726) : const Color(0xFFEF5350),
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('$marks / $total', style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
