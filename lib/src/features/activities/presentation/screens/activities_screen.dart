import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import '../providers/activity_provider.dart';
import '../../domain/entities/activity_entity.dart';

/// School activities with All / Upcoming / Completed tabs.
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivities();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<ActivityProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('activities.title'.tr()), centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
          indicatorColor: theme.colorScheme.onPrimary,
          tabs: [Tab(text: 'activities.all'.tr()), Tab(text: 'activities.upcoming'.tr()), Tab(text: 'activities.completed'.tr())],
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _ActivityList(items: provider.activities),
                _ActivityList(items: provider.upcoming),
                _ActivityList(items: provider.completed),
              ],
            ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  final List<ActivityEntity> items;
  const _ActivityList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return Center(child: AppEmptyState(icon: Icons.event_busy, title: 'activities.no_activities'.tr()));
    final theme = context.theme;
    return ListView.separated(
      padding: const EdgeInsets.all(16), itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final a = items[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: (a.isUpcoming ? const Color(0xFF5C6BC0) : const Color(0xFF26A69A)).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.event, color: a.isUpcoming ? const Color(0xFF5C6BC0) : const Color(0xFF26A69A), size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${a.date} • ${a.location}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ])),
          ]),
        );
      },
    );
  }
}
