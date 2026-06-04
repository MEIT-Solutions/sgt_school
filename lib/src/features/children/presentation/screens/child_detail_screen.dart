import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:sgt_school/src/features/attendance/domain/entities/attendance_record.dart';
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
  int _present = 0;
  int _total = 0;
  List<Map<String, dynamic>> _completedExams = [];
  double _totalFees = 0;
  double _dueFees = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final attendanceRepo = AttendanceRepositoryImpl();
    final examRepo = ExamRepositoryImpl();
    final feeRepo = FeeRepositoryImpl();

    final attendanceResult = await attendanceRepo.getMonthlyRecords(widget.childId);
    attendanceResult.fold((_) {}, (records) {
      _present = records.where((r) => r.status == AttendanceStatus.present).length;
      _total = records.length;
    });

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
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppTopBar(title: 'children.child_detail'.tr()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Attendance Summary
          Text('home.attendance'.tr(), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _Stat(label: 'attendance.present'.tr(), value: '$_present', color: const Color(0xFF26A69A)),
              _Stat(label: 'attendance.total'.tr(), value: '$_total', color: const Color(0xFF42A5F5)),
              _Stat(label: '%', value: _total > 0 ? (_present / _total * 100).toStringAsFixed(0) : '0', color: const Color(0xFF5C6BC0)),
            ]),
          ),
          const SizedBox(height: 20),

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
                  Text(e['date'] as String, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ]),
                Text('${e['percentage']}% (${e['grade']})', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF26A69A))),
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
                Text('\$${_dueFees.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFFEF5350))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
      const SizedBox(height: 4),
      Text(label, style: context.theme.textTheme.labelSmall?.copyWith(color: color)),
    ]);
  }
}
