import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/features/exams/data/repositories/exam_repository_impl.dart';
import 'package:sgt_school/src/features/fees/data/repositories/fee_repository_impl.dart';

/// Child detail screen showing overview of a specific child's data.
class ChildDetailScreen extends StatefulWidget {
  final String childId;
  const ChildDetailScreen({super.key, required this.childId});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _completedExams = [];
  double _totalFees = 0;
  double _dueFees = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final examRepo = ExamRepositoryImpl();
    final feeRepo = FeeRepositoryImpl();

    final examResult = await examRepo.getExams(widget.childId);
    examResult.fold((_) {}, (exams) {
      _completedExams = exams
          .where((e) => e.isCompleted)
          .take(2)
          .map((e) => {'name': e.name, 'date': e.date, 'percentage': e.percentage ?? 0, 'grade': e.grade ?? '-'})
          .toList();
    });

    final feeResult = await feeRepo.getFees(widget.childId);
    feeResult.fold((_) {}, (feeData) {
      _totalFees = feeData.summary.totalFees;
      _dueFees = feeData.summary.totalDue;
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppTopBar(title: 'children.child_detail'.tr()),
        body: const AppSkeletonList(itemCount: 5),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppTopBar(title: 'children.child_detail'.tr()),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Recent Exams
            Text('exams.title'.tr(), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._completedExams.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e['name'] as String, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    Text((e['date'] as String).toDisplayDate, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                  Text('${e['percentage']}% (${e['grade']})', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: GridIconColors.results)),
                ]),
              ),
            )),
            const SizedBox(height: 20),

            // Fees
            Text('fees.title'.tr(), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('fees.total_fees'.tr(), style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  Text('\$${_totalFees.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('fees.due_amount'.tr(), style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  Text('\$${_dueFees.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: GridIconColors.fees)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
