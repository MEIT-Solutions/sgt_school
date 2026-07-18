import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/timetable_provider.dart';
import '../../domain/entities/timetable_slot.dart';

/// Weekly timetable with day tabs and period cards.
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      context.read<TimetableProvider>().loadTimetable(session.user?.id ?? '');
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final session = context.read<SessionProvider>();
    return context.read<TimetableProvider>().loadTimetable(session.user?.id ?? '');
  }

  int _todayIndex(List<String> days) {
    final wd = DateTime.now().weekday;
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    if (wd >= 1 && wd <= 5) {
      final i = days.indexOf(names[wd - 1]);
      if (i >= 0) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<TimetableProvider>();

    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(title: Text('timetable.title'.tr()), centerTitle: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final days = provider.days;
    if (days.isNotEmpty && !_initialized) {
      _tabController = TabController(
        length: days.length,
        initialIndex: _todayIndex(days),
        vsync: this,
      );
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('timetable.title'.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        bottom: _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: theme.colorScheme.onPrimary,
                unselectedLabelColor: theme.colorScheme.onPrimary.withValues(alpha: 0.6),
                indicatorColor: theme.colorScheme.onPrimary,
                tabs: days.map((d) => Tab(text: d.substring(0, 3))).toList(),
              ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _tabController == null
            ? ListView(
                children: [SizedBox(height: MediaQuery.sizeOf(context).height * 0.3), Center(child: AppEmptyState(icon: Icons.schedule, title: 'timetable.title'.tr()))],
              )
            : TabBarView(
                controller: _tabController,
                children: days.map((day) {
                  final periods = provider.timetable[day] ?? [];
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: periods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final p = periods[i];
                      return _PeriodCard(slot: p);
                    },
                  );
                }).toList(),
              ),
      ),
    );
  }
}

class _PeriodCard extends StatelessWidget {
  final TimetableSlot slot;
  const _PeriodCard({required this.slot});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Text('${slot.period}',
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slot.time,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(slot.subject,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('${slot.room} • ${slot.teacher}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
              ]),
        ),
      ]),
    );
  }
}
