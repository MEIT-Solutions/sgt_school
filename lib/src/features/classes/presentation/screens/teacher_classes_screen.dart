import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/class_provider.dart';

/// Teacher classes screen showing class name, section, academic year, and student count.
class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({super.key});

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      final teacherId = session.user?.id ?? '';
      if (teacherId.isNotEmpty) {
        context.read<ClassProvider>().loadTeacherClassList(teacherId);
      }
    });
  }

  Future<void> _refresh() {
    final session = context.read<SessionProvider>();
    final teacherId = session.user?.id ?? '';
    return context.read<ClassProvider>().loadTeacherClassList(teacherId);
  }

  static const _classColors = [
    Color(0xFF42A5F5), Color(0xFF26A69A), Color(0xFFAB47BC),
    Color(0xFFFF7043), Color(0xFF66BB6A), Color(0xFF5C6BC0),
    Color(0xFFFFA726), Color(0xFFEF5350),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ClassProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppTopBar(title: 'teacher.classes'.tr()),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? AppErrorWidget(
                  message: provider.error!,
                  onRetry: () {
                    final session = context.read<SessionProvider>();
                    final teacherId = session.user?.id ?? '';
                    if (teacherId.isNotEmpty) {
                      context.read<ClassProvider>().loadTeacherClassList(teacherId);
                    }
                  },
                )
              : provider.teacherClasses.isEmpty
                  ? Center(
                      child: Text(
                        'teacher.no_classes'.tr(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.teacherClasses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final cls = provider.teacherClasses[index];
                        final color = _classColors[index % _classColors.length];

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
                                child: Icon(Icons.class_, color: color, size: 22),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cls.name,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (cls.section != null && cls.section!.isNotEmpty) ...[
                                          Text(
                                            cls.section!,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          cls.academicYear,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.people, color: color, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${cls.studentCount}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
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
