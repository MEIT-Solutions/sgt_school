import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import '../providers/class_provider.dart';

/// Class detail showing student roster.
class ClassDetailScreen extends StatefulWidget {
  final String classId;
  const ClassDetailScreen({super.key, required this.classId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClassProvider>().loadStudents(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ClassProvider>();
    final students = provider.students;
    final classInfo = provider.classes.where((c) => c.id == widget.classId).firstOrNull;
    final title = classInfo != null ? classInfo.displayName : '';
    final subject = classInfo?.subject ?? '';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppTopBar(title: title),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Container(
                margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(children: [
                    Text('${students.length}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    Text('teacher.students'.tr(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ]),
                  Column(children: [
                    Text(subject, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text('subjects.title'.tr(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ]),
                ]),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: students.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final s = students[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(10), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                      child: Row(children: [
                        CircleAvatar(radius: 18, backgroundColor: theme.colorScheme.primaryContainer, child: Text(s.rollNo, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer))),
                        const SizedBox(width: 12),
                        Expanded(child: Text(s.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                      ]),
                    );
                  },
                ),
              ),
            ]),
    );
  }
}
