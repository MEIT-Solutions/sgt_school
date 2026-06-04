import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import '../../domain/entities/class_student_entity.dart';
import '../providers/class_provider.dart';

/// Mark attendance for a class (teacher).
class MarkAttendanceScreen extends StatefulWidget {
  final String classId;
  const MarkAttendanceScreen({super.key, required this.classId});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  final Map<String, String> _statuses = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassProvider>().loadStudents(widget.classId);
    });
  }

  void _initStatuses(List<ClassStudentEntity> students) {
    if (_loaded) return;
    for (final s in students) {
      _statuses[s.id] = s.attendanceStatus ?? 'present';
    }
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final provider = context.watch<ClassProvider>();
    final students = provider.students;

    _initStatuses(students);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppTopBar(title: 'teacher.mark_attendance'.tr()),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Container(
                margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.calendar_today, size: 16, color: cs.primary),
                  const SizedBox(width: 8),
                  Text('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ]),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final s = students[i];
                    final status = _statuses[s.id] ?? 'present';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: BorderRadius.circular(10), border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5))),
                      child: Row(children: [
                        CircleAvatar(radius: 16, backgroundColor: cs.primaryContainer, child: Text(s.rollNo, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(s.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                        _StatusToggle(
                          status: status,
                          onChanged: (v) => setState(() => _statuses[s.id] = v),
                        ),
                      ]),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      context.showSuccessSnackBar('teacher.attendance_saved'.tr());
                      context.pop();
                    },
                    child: Text('teacher.save_attendance'.tr()),
                  ),
                ),
              ),
            ]),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final String status;
  final ValueChanged<String> onChanged;
  const _StatusToggle({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'present', icon: Icon(Icons.check, size: 16)),
        ButtonSegment(value: 'late', icon: Icon(Icons.schedule, size: 16)),
        ButtonSegment(value: 'absent', icon: Icon(Icons.close, size: 16)),
      ],
      selected: {status},
      onSelectionChanged: (s) => onChanged(s.first),
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
