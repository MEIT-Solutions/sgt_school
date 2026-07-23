import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/assignment_entity.dart';

/// Assignment detail screen for teacher.
class AssignmentDetailScreen extends StatelessWidget {
  final AssignmentEntity assignment;
  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final isActive = assignment.isActive;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppTopBar(title: 'assignments.detail'.tr()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(assignment.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: (isActive ? const Color(0xFF42A5F5) : const Color(0xFF26A69A)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(isActive ? 'assignments.active'.tr() : 'assignments.completed'.tr(), style: theme.textTheme.labelSmall?.copyWith(color: isActive ? const Color(0xFF42A5F5) : const Color(0xFF26A69A), fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 16),
          _DetailRow(icon: Icons.class_, label: 'classes.title'.tr(), value: assignment.className),
          _DetailRow(icon: Icons.book, label: 'subjects.title'.tr(), value: assignment.subject),
          _DetailRow(icon: Icons.calendar_today, label: 'assignments.due'.tr(), value: assignment.dueDate.toDisplayDate),
          const SizedBox(height: 16),
          Text('assignments.description'.tr(), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(assignment.description ?? '', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 20),
          // Submission progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5))),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('assignments.submissions'.tr(), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('${assignment.submittedCount} / ${assignment.totalCount}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: assignment.submissionRate,
                  backgroundColor: cs.outlineVariant.withValues(alpha: 0.3),
                  minHeight: 8,
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const Spacer(),
        Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
