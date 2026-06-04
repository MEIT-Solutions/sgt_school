import 'package:equatable/equatable.dart';

/// Fee payment status.
enum FeeStatus {
  paid,
  due,
  overdue,
  partial;

  static FeeStatus fromString(String value) {
    return FeeStatus.values.firstWhere(
      (s) => s.name == value.toLowerCase(),
      orElse: () => FeeStatus.due,
    );
  }
}

/// A single fee line item for a student.
class FeeEntity extends Equatable {
  final String id;
  final String name;
  final double amount;
  final double amountPaid;
  final double dueAmount;
  final FeeStatus status;
  final String? dueDate;
  final String? paymentMode;
  final String? paidBy;

  const FeeEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.amountPaid,
    required this.dueAmount,
    required this.status,
    this.dueDate,
    this.paymentMode,
    this.paidBy,
  });

  bool get isPaid => status == FeeStatus.paid;
  bool get isDue => status == FeeStatus.due || status == FeeStatus.overdue;
  bool get isPartial => status == FeeStatus.partial;

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        amountPaid,
        dueAmount,
        status,
        dueDate,
        paymentMode,
        paidBy,
      ];
}

/// Aggregated fee summary.
class FeeSummary extends Equatable {
  final double totalFees;
  final double totalPaid;
  final double totalDue;

  const FeeSummary({
    required this.totalFees,
    required this.totalPaid,
    required this.totalDue,
  });

  @override
  List<Object?> get props => [totalFees, totalPaid, totalDue];
}

/// Combined fees and summary data for a student.
class StudentFeeData extends Equatable {
  final List<FeeEntity> fees;
  final FeeSummary summary;

  const StudentFeeData({
    required this.fees,
    required this.summary,
  });

  @override
  List<Object?> get props => [fees, summary];
}
