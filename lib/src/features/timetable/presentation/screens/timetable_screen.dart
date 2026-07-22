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
  static const _dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  static const _dayAbbreviations = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final todayIndex = _todayIndex();
    _tabController = TabController(
      length: _dayNames.length,
      initialIndex: todayIndex,
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      context.read<TimetableProvider>().loadTimetable(session.user?.id ?? '');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final session = context.read<SessionProvider>();
    return context.read<TimetableProvider>().loadTimetable(session.user?.id ?? '');
  }

  int _todayIndex() {
    final wd = DateTime.now().weekday; // 1=Mon … 7=Sun
    return (wd >= 1 && wd <= 5) ? wd - 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final provider = context.watch<TimetableProvider>();

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
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor:
              theme.colorScheme.onPrimary.withValues(alpha: 0.6),
          indicatorColor: theme.colorScheme.onPrimary,
          tabs: _dayAbbreviations.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: _buildBody(provider, theme),
    );
  }

  Widget _buildBody(TimetableProvider provider, ThemeData theme) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(provider.error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.error)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: Text('common.retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    final timetable = provider.timetable;
    if (timetable == null || timetable.periods.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
            Center(
              child: AppEmptyState(
                icon: Icons.schedule,
                title: 'timetable.title'.tr(),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: Column(
        children: [
          // Header info bar
          _TimetableHeader(timetable: timetable),
          // Period list per day
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_dayNames.length, (dayIndex) {
                final weekday = dayIndex + 1; // 1=Mon … 5=Fri
                return _DayPeriodList(
                  periods: timetable.periods,
                  weekday: weekday,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays timetable metadata (name, class, teacher).
class _TimetableHeader extends StatelessWidget {
  final dynamic timetable;
  const _TimetableHeader({required this.timetable});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timetable.name,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '${timetable.className} • ${timetable.academicYear}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.person_outline, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              timetable.teacher.name,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Builds the period list for a single day.
class _DayPeriodList extends StatelessWidget {
  final List<TimetableSlot> periods;
  final int weekday;

  const _DayPeriodList({required this.periods, required this.weekday});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: periods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _PeriodCard(slot: periods[i], weekday: weekday),
    );
  }
}

/// A single period card showing time, subject, or break info.
class _PeriodCard extends StatelessWidget {
  final TimetableSlot slot;
  final int weekday;
  const _PeriodCard({required this.slot, required this.weekday});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final subject = slot.subjectForWeekday(weekday);
    final isBreak = slot.isBreak;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isBreak
            ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Period icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isBreak ? cs.tertiaryContainer : cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                isBreak
                    ? (slot.type == PeriodType.lunch
                        ? Icons.restaurant
                        : Icons.coffee)
                    : Icons.menu_book,
                size: 20,
                color: isBreak
                    ? cs.onTertiaryContainer
                    : cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.time,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                Text(
                  isBreak ? _breakLabel(slot.type) : (subject ?? '-'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontStyle: isBreak ? FontStyle.italic : null,
                    color: isBreak ? cs.onSurfaceVariant : null,
                  ),
                ),
              ],
            ),
          ),
          if (!isBreak && slot.duration > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${slot.duration} min',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _breakLabel(PeriodType type) => switch (type) {
        PeriodType.lunch => 'Lunch Break',
        PeriodType.recess => 'Recess',
        _ => 'Break',
      };
}
