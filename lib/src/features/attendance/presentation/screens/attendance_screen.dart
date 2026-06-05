import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import 'package:sgt_school/src/features/attendance/presentation/providers/attendance_check_provider.dart';
import '../../domain/entities/attendance_record.dart';

/// Monthly attendance view with swipeable calendar, confirmation dialogs
/// for check-in/out, and per-date detail loading.
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedMonth = DateTime.now();
  String? _selectedDate;
  late PageController _pageController;

  /// Reference month (today). Page 1000 = current month.
  static const int _initialPage = 1000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = context.read<SessionProvider>();
      final studentId = session.user?.id ?? '';
      if (studentId.isNotEmpty) {
        final provider = context.read<AttendanceCheckProvider>();
        provider.loadAttendance(studentId);
      }
    });
  }

  void _onPageChanged(int page) {
    final delta = page - _initialPage;
    final now = DateTime.now();
    final newMonth = DateTime(now.year, now.month + delta);

    setState(() {
      _selectedMonth = newMonth;
      _selectedDate = null;
    });

    final session = context.read<SessionProvider>();
    final studentId = session.user?.id ?? '';
    final month = '${newMonth.year}-${newMonth.month.toString().padLeft(2, '0')}';
    context.read<AttendanceCheckProvider>().loadAttendance(studentId, month: month);
    context.read<AttendanceCheckProvider>().clearSelectedDate();
  }

  void _onDateTapped(String dateStr) {
    setState(() => _selectedDate = dateStr);
    context.read<AttendanceCheckProvider>().selectDate(dateStr);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final session = context.watch<SessionProvider>();
    final provider = context.watch<AttendanceCheckProvider>();
    final records = provider.monthlyRecords;

    // Build a map: date string → record
    final recordMap = <String, AttendanceRecord>{};
    for (final r in records) {
      recordMap[r.date] = r;
    }

    // Stats
    final summary = provider.summary;
    final present = summary?.present ?? records.where((r) => r.status == AttendanceStatus.present).length;
    final absent = summary?.absent ?? records.where((r) => r.status == AttendanceStatus.absent).length;
    final late = summary?.late ?? records.where((r) => r.status == AttendanceStatus.late).length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('attendance.title'.tr()),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: _buildFab(provider, session.user?.id ?? ''),
      body: provider.loadError != null
          ? AppErrorWidget(
              message: provider.loadError,
              onRetry: () {
                final session = context.read<SessionProvider>();
                final studentId = session.user?.id ?? '';
                if (studentId.isNotEmpty) {
                  final monthStr = '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
                  context.read<AttendanceCheckProvider>().loadAttendance(studentId, month: monthStr);
                }
              },
            )
          : SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Today Status Row ──
            _TodayStatusRow(provider: provider),
            SizedBox(height: AppSpacing.md),

            // ── Summary Row ──
            Row(
              children: [
                _StatChip(
                  label: 'attendance.present'.tr(),
                  value: '$present',
                  color: cs.primary,
                ),
                SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: 'attendance.absent'.tr(),
                  value: '$absent',
                  color: cs.error,
                ),
                SizedBox(width: AppSpacing.sm),
                _StatChip(
                  label: 'attendance.late'.tr(),
                  value: '$late',
                  color: cs.tertiary,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.lg),

            // ── Month Navigation ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                Text(
                  _monthYearString(_selectedMonth),
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),

            // ── Day-of-Week Headers ──
            Row(
              children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: AppSpacing.sm),

            // ── Swipeable Calendar ──
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, page) {
                  final delta = page - _initialPage;
                  final now = DateTime.now();
                  final month = DateTime(now.year, now.month + delta);
                  return _buildCalendarGrid(month, recordMap, cs, tt);
                },
              ),
            ),

            // ── Loading indicator for monthly ──
            if (provider.isLoadingMonthly)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),

            SizedBox(height: AppSpacing.md),

            // ── Selected Day Detail ──
            if (_selectedDate != null)
              _SelectedDayDetail(
                date: _selectedDate!,
                provider: provider,
              ),

            // Extra space so FAB doesn't overlap content
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget? _buildFab(AttendanceCheckProvider provider, String studentId) {
    if (provider.isLoadingToday || !provider.hasTodayLoaded) return null;

    final record = provider.todayRecord;
    final cs = Theme.of(context).colorScheme;

    // Already completed today — show small completed indicator
    if (record != null && record.hasCheckedIn && record.hasCheckedOut) {
      return FloatingActionButton.small(
        onPressed: null,
        backgroundColor: cs.primary.withValues(alpha: 0.15),
        elevation: 0,
        child: Icon(Icons.check_circle, color: cs.primary),
      );
    }

    // Check Out state
    if (record != null && record.hasCheckedIn && !record.hasCheckedOut) {
      return FloatingActionButton.extended(
        onPressed: provider.isCheckingOut ? null : () => _showCheckOutDialog(provider, studentId),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.isCheckingOut) ...[
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary)),
              const SizedBox(width: 8),
            ],
            Text('attendance.check_out'.tr(), style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // Check In state (default)
    return FloatingActionButton.extended(
      onPressed: provider.isCheckingIn ? null : () => _showCheckInDialog(provider, studentId),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (provider.isCheckingIn) ...[
            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary)),
            const SizedBox(width: 8),
          ],
          Text('attendance.check_in'.tr(), style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _showCheckInDialog(AttendanceCheckProvider provider, String studentId) async {
    final now = DateTime.now();
    final timeStr = _formatTimeHelper(now);
    final dateStr = _formatDateHelper(now);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final confirmed = await showAppDialog<bool>(
      context: context,
      child: Builder(
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'attendance.confirm_check_in_title'.tr(),
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  dateStr,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  timeStr,
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                //SizedBox(height: AppSpacing.sm),
                // Text(
                //   'attendance.confirm_check_in_message'.tr(namedArgs: {'time': timeStr}),
                //   style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => popDialog(dialogContext, false),
                        child: Text('attendance.cancel'.tr()),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => popDialog(dialogContext, true),
                        child: Text('attendance.confirm'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.checkIn(studentId);
      if (!mounted) return;
      if (success) {
        showToast(context, message: 'attendance.checked_in_success'.tr());
      } else {
        showToast(context, message: 'attendance.check_in_failed'.tr(), status: 'error');
      }
    }
  }

  Future<void> _showCheckOutDialog(AttendanceCheckProvider provider, String studentId) async {
    final now = DateTime.now();
    final timeStr = _formatTimeHelper(now);
    final dateStr = _formatDateHelper(now);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final confirmed = await showAppDialog<bool>(
      context: context,
      child: Builder(
        builder: (dialogContext) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'attendance.confirm_check_out_title'.tr(),
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  dateStr,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  timeStr,
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                //SizedBox(height: AppSpacing.sm),
                // Text(
                //   'attendance.confirm_check_out_message'.tr(namedArgs: {'time': timeStr}),
                //   style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => popDialog(dialogContext, false),
                        child: Text('attendance.cancel'.tr()),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => popDialog(dialogContext, true),
                        child: Text('attendance.confirm'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.checkOut(studentId);
      if (!mounted) return;
      if (success) {
        showToast(context, message: 'attendance.checked_out_success'.tr());
      } else {
        showToast(context, message: 'attendance.check_out_failed'.tr(), status: 'error');
      }
    }
  }

  String _formatTimeHelper(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String _formatDateHelper(DateTime dt) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  Widget _buildCalendarGrid(
    DateTime month,
    Map<String, AttendanceRecord> recordMap,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startOffset = firstDay.weekday - 1;
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: startOffset + daysInMonth,
      itemBuilder: (context, index) {
        if (index < startOffset) return const SizedBox.shrink();
        final day = index - startOffset + 1;
        final dateStr = '${month.year}-${month.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        final record = recordMap[dateStr];
        final status = record?.status;

        Color? dotColor;
        if (status == AttendanceStatus.present) dotColor = cs.primary;
        if (status == AttendanceStatus.absent) dotColor = cs.error;
        if (status == AttendanceStatus.late) dotColor = cs.tertiary;

        final isSelected = _selectedDate == dateStr;
        final isToday = dateStr == todayStr;

        return GestureDetector(
          onTap: () => _onDateTapped(dateStr),
          child: Container(
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? cs.primaryContainer
                  : isToday
                      ? cs.surfaceContainerHighest
                      : null,
              borderRadius: BorderRadius.circular(8),
              border: isToday && !isSelected ? Border.all(color: cs.primary.withValues(alpha: 0.3)) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$day',
                  style: tt.bodySmall?.copyWith(
                    fontWeight: isSelected || isToday ? FontWeight.bold : null,
                    color: isSelected ? cs.onPrimaryContainer : null,
                  ),
                ),
                if (dotColor != null) ...[
                  const SizedBox(height: 2),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthYearString(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Today Status Row — compact time-in / time-out display
// ══════════════════════════════════════════════════════════════════════════

class _TodayStatusRow extends StatelessWidget {
  final AttendanceCheckProvider provider;

  const _TodayStatusRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final record = provider.todayRecord;

    final timeInStr = record?.timeIn != null ? _formatTime(record!.timeIn!) : '--:--';
    final timeOutStr = record?.timeOut != null ? _formatTime(record!.timeOut!) : '--:--';

    final bool completed = record != null && record.hasCheckedIn && record.hasCheckedOut;

    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: provider.isLoadingToday
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : Row(
              children: [
                // Time In
                Expanded(
                  child: Column(
                    children: [
                      Text('attendance.check_in'.tr(), style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                      SizedBox(height: AppSpacing.xs),
                      Text(timeInStr, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
                    ],
                  ),
                ),
                Container(width: 1, height: 44, color: cs.outlineVariant),
                // Time Out
                Expanded(
                  child: Column(
                    children: [
                      Text('attendance.check_out'.tr(), style: tt.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                      SizedBox(height: AppSpacing.xs),
                      Text(timeOutStr, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
                    ],
                  ),
                ),
                // Status badge
                if (completed)
                  Padding(
                    padding: EdgeInsets.only(left: AppSpacing.sm),
                    child: Icon(Icons.check_circle, color: cs.primary, size: 22),
                  ),
              ],
            ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Summary Stat Chip
// ══════════════════════════════════════════════════════════════════════════

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
            SizedBox(height: AppSpacing.xxs),
            Text(label, style: context.theme.textTheme.labelSmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Selected Day Detail (with loading state)
// ══════════════════════════════════════════════════════════════════════════

class _SelectedDayDetail extends StatelessWidget {
  final String date;
  final AttendanceCheckProvider provider;

  const _SelectedDayDetail({required this.date, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'attendance.daily_detail'.tr(),
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: AppSpacing.md),
        if (provider.selectedDateRecord != null)
          _DayDetailCard(record: provider.selectedDateRecord!)
        else
          Container(
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                'attendance.no_record'.tr(),
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Day Detail Card
// ══════════════════════════════════════════════════════════════════════════

class _DayDetailCard extends StatelessWidget {
  final AttendanceRecord record;
  const _DayDetailCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final statusName = record.status.name;
    final timeIn = record.timeIn != null ? _formatTime(record.timeIn!) : null;
    final timeOut = record.timeOut != null ? _formatTime(record.timeOut!) : null;

    final statusColor = switch (record.status) {
      AttendanceStatus.present => cs.primary,
      AttendanceStatus.absent => cs.error,
      AttendanceStatus.late => cs.tertiary,
      AttendanceStatus.excused => cs.secondary,
    };

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('attendance.status'.tr(), style: theme.textTheme.bodyMedium),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusName.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (timeIn != null) ...[
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('attendance.check_in'.tr(), style: theme.textTheme.bodyMedium),
                Text(timeIn, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          if (timeOut != null) ...[
            SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('attendance.check_out'.tr(), style: theme.textTheme.bodyMedium),
                Text(timeOut, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
