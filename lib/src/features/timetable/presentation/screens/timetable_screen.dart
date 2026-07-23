import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/timetable_provider.dart';
import '../../domain/entities/timetable_slot.dart';

/// Weekly timetable with day tabs and compact period rows.
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
        automaticallyImplyLeading: false,
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
      return SkeletonWrapper(
        isLoading: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: List.generate(7, (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: i < 6 ? 4 : 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 54,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(BoneMock.name, style: theme.textTheme.labelSmall?.copyWith(fontSize: 10)),
                            Text(BoneMock.name, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 24, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(BoneMock.name, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            )),
          ),
        ),
      );
    }

    if (provider.error != null) {
      return AppErrorWidget(
        message: provider.error,
        onRetry: _refresh,
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
          // Period list per day — fills remaining space
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_dayNames.length, (dayIndex) {
                final weekday = dayIndex + 1;
                return _DaySchedule(
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

/// Displays timetable metadata (teacher, name, class).
class _TimetableHeader extends StatelessWidget {
  final dynamic timetable;
  const _TimetableHeader({required this.timetable});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Line 1: Timetable name
          Text(
            timetable.name,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Line 2: Teacher + Class + Year
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: cs.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  timetable.teacher.name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text('•', style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ),
              Text(
                '${timetable.className} • ${timetable.academicYear}',
                style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact day schedule that fills available space evenly.
class _DaySchedule extends StatelessWidget {
  final List<TimetableSlot> periods;
  final int weekday;

  const _DaySchedule({required this.periods, required this.weekday});


  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: List.generate(periods.length, (i) {
          final slot = periods[i];
          final subject = slot.subjectForWeekday(weekday);
          final isBreak = slot.isBreak;
          final isLast = i == periods.length - 1;

          // Parse start time for display
          final timeParts = slot.time.split(' to ');
          final startTime = timeParts.isNotEmpty ? timeParts[0].trim() : '';
          final endTime = timeParts.length > 1 ? timeParts[1].trim() : '';

          // Color for subject stripe
          final accentColor = isBreak
              ? cs.outlineVariant
              : AppColors.colorForIndex(i);

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
              child: Container(
                decoration: BoxDecoration(
                  color: isBreak
                      ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
                      : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Colored left accent bar
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                    ),
                    // Time column
                    SizedBox(
                      width: 54,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            startTime,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            endTime,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 9,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider line
                    Container(
                      width: 1,
                      height: 24,
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 10),
                    // Subject name
                    Expanded(
                      child: Text(
                        isBreak ? _breakLabel(slot.type) : (subject ?? '-'),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: isBreak ? FontWeight.w400 : FontWeight.w600,
                          fontStyle: isBreak ? FontStyle.italic : null,
                          color: isBreak ? cs.onSurfaceVariant : cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Duration badge (only for subjects)
                    if (!isBreak && slot.duration > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          '${slot.duration}m',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    if (isBreak)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          slot.type == PeriodType.lunch
                              ? Icons.restaurant_rounded
                              : Icons.coffee_rounded,
                          size: 14,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _breakLabel(PeriodType type) => switch (type) {
        PeriodType.lunch => 'Lunch Break',
        PeriodType.recess => 'Recess',
        _ => 'Break',
      };
}
