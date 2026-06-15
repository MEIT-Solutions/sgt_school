import 'package:sgt_school/src/imports/core_imports.dart';
import 'package:sgt_school/src/imports/packages_imports.dart';
import 'package:sgt_school/src/features/auth/presentation/providers/session_provider.dart';
import '../providers/fee_provider.dart';
import '../../domain/entities/fee_entity.dart';

String _formatCurrency(double amount) {
  final format = NumberFormat('#,###', 'en_US');
  return '${format.format(amount)} MMK';
}

/// Fee summary with details and payment history tabs.
class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = context.read<SessionProvider>();
      context.read<FeeProvider>().loadFees(session.user?.id ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final provider = context.watch<FeeProvider>();

    final total = provider.summary?.totalFees ?? 0;
    final paid = provider.summary?.totalPaid ?? 0;
    final due = provider.summary?.totalDue ?? 0;
    final progress = total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('fees.title'.tr()),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? AppErrorWidget(
                  message: provider.error,
                  onRetry: () {
                    final session = context.read<SessionProvider>();
                    context
                        .read<FeeProvider>()
                        .loadFees(session.user?.id ?? '');
                  },
                )
              : Column(
                  children: [
                    // Premium Summary Banner
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, cs.primaryContainer],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined,
                                      color: cs.onPrimary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'fees.fee_details'.tr(),
                                    style: tt.titleSmall?.copyWith(
                                      color: cs.onPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: cs.onPrimary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(progress * 100).toStringAsFixed(0)}% ${'fees.paid'.tr()}',
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor:
                                  cs.onPrimary.withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0
                                    ? const Color(0xFF4DB6AC)
                                    : const Color(0xFFFFD54F),
                              ),
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SummaryColumn(
                                label: 'fees.total_fees'.tr(),
                                amount: total,
                                textColor: cs.onPrimary,
                                tt: tt,
                              ),
                              _SummaryColumn(
                                label: 'fees.total_paid'.tr(),
                                amount: paid,
                                textColor: const Color(0xFFB2DFDB), // soft teal
                                tt: tt,
                              ),
                              _SummaryColumn(
                                label: 'fees.due_amount'.tr(),
                                amount: due,
                                textColor: const Color(0xFFFFCDD2), // soft red
                                tt: tt,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _FeeDetailsList(fees: provider.fees),
                    ),
                  ],
                ),
    );
  }
}

class _SummaryColumn extends StatelessWidget {
  final String label;
  final double amount;
  final Color textColor;
  final TextTheme tt;

  const _SummaryColumn({
    required this.label,
    required this.amount,
    required this.textColor,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: textColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: tt.bodyLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _FeeDetailsList extends StatelessWidget {
  final List<FeeEntity> fees;
  const _FeeDetailsList({required this.fees});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    if (fees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: cs.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'No fee records found',
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: fees.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final f = fees[i];

        Color statusColor;
        String statusText;
        IconData statusIcon;

        switch (f.status) {
          case FeeStatus.paid:
            statusColor = const Color(0xFF26A69A);
            statusText = 'fees.paid'.tr();
            statusIcon = Icons.check_circle_outline;
            break;
          case FeeStatus.partial:
            statusColor = const Color(0xFFFF9800);
            statusText = 'fees.partial'.tr();
            statusIcon = Icons.star_half_outlined;
            break;
          case FeeStatus.due:
          case FeeStatus.overdue:
            statusColor = const Color(0xFFEF5350);
            statusText = 'fees.due'.tr();
            statusIcon = Icons.error_outline;
            break;
        }

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        f.name,
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: tt.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _AmountItem(
                      label: 'fees.total_fees'.tr(),
                      amount: f.amount,
                      tt: tt,
                      cs: cs,
                    ),
                    _AmountItem(
                      label: 'fees.total_paid'.tr(),
                      amount: f.amountPaid,
                      tt: tt,
                      cs: cs,
                      valueColor: const Color(0xFF26A69A),
                    ),
                    _AmountItem(
                      label: 'fees.due_amount'.tr(),
                      amount: f.dueAmount,
                      tt: tt,
                      cs: cs,
                      valueColor:
                          f.dueAmount > 0 ? const Color(0xFFEF5350) : null,
                    ),
                  ],
                ),
              ),
              if ((f.dueDate != null && f.dueDate!.isNotEmpty) ||
                  (f.paymentMode != null && f.paymentMode!.isNotEmpty) ||
                  (f.paidBy != null && f.paidBy!.isNotEmpty)) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLowest,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (f.dueDate != null && f.dueDate!.isNotEmpty)
                        _MetaChip(
                          icon: Icons.calendar_today_outlined,
                          label: f.isPaid
                              ? '${'fees.payment_date'.tr()}: ${f.dueDate}'
                              : '${'fees.due'.tr()}: ${f.dueDate}',
                          tt: tt,
                          cs: cs,
                        ),
                      if (f.paymentMode != null && f.paymentMode!.isNotEmpty)
                        _MetaChip(
                          icon: Icons.payment_outlined,
                          label:
                              '${'fees.payment_mode'.tr()}: ${f.paymentMode}',
                          tt: tt,
                          cs: cs,
                        ),
                      if (f.paidBy != null && f.paidBy!.isNotEmpty)
                        _MetaChip(
                          icon: Icons.person_outline,
                          label: '${'fees.paid_by'.tr()}: ${f.paidBy}',
                          tt: tt,
                          cs: cs,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AmountItem extends StatelessWidget {
  final String label;
  final double amount;
  final TextTheme tt;
  final ColorScheme cs;
  final Color? valueColor;

  const _AmountItem({
    required this.label,
    required this.amount,
    required this.tt,
    required this.cs,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextTheme tt;
  final ColorScheme cs;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.tt,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// class _PaymentsList extends StatelessWidget {
//   final List<PaymentEntity> payments;
//   const _PaymentsList({required this.payments});
//   @override
//   Widget build(BuildContext context) {
//     final theme = context.theme;
//     return ListView.separated(
//       padding: const EdgeInsets.all(16), itemCount: payments.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 8),
//       itemBuilder: (context, i) {
//         final p = payments[i];
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
//           child: Row(children: [
//             Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF26A69A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.receipt_long, color: Color(0xFF26A69A), size: 20)),
//             const SizedBox(width: 12),
//             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(_formatCurrency(p.amount), style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 2),
//               Text('${p.method} • ${p.reference}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
//             ])),
//             Text(p.date, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
//           ]),
//         );
//       },
//     );
//   }
// }
