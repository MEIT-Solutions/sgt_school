import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/child_provider.dart';

/// Parent's children list screen (tab).
class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({super.key});

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      context.read<ChildProvider>().loadChildren(session.user?.id ?? '');
    });
  }

  Future<void> _refresh() {
    final session = context.read<SessionProvider>();
    return context.read<ChildProvider>().loadChildren(session.user?.id ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ChildProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text('children.title'.tr()), centerTitle: true, automaticallyImplyLeading: false),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16), itemCount: provider.children.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final c = provider.children[i];
                return InkWell(
                  onTap: () => context.push('/children/${c.studentId}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                    child: Row(children: [
                      CircleAvatar(radius: 24, backgroundColor: theme.colorScheme.primaryContainer, child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(c.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('${c.classDisplay} • Roll No. ${c.rollNo}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${c.attendancePercentage}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: GridIconColors.attendance)),
                        Text('home.attendance'.tr(), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ]),
                    ]),
                  ),
                );
              },
            ),
      ),
    );
  }
}
