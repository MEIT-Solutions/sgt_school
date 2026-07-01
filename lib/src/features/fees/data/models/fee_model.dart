import '../../domain/entities/fee_entity.dart';

/// DTO for [FeeEntity].
class FeeModel {
  final String id;
  final String name;
  final String currency;
  final double amount;
  final double amountPaid;
  final double dueAmount;
  final String status;
  final String? dueDate;
  final String? paymentMode;
  final String? paidBy;

  const FeeModel({
    required this.id,
    required this.name,
    required this.currency,
    required this.amount,
    required this.amountPaid,
    required this.dueAmount,
    required this.status,
    this.dueDate,
    this.paymentMode,
    this.paidBy,
  });

  factory FeeModel.fromJson(Map<String, dynamic> json) {
    final amountPaidVal = (json['amount_paid'] as num?)?.toDouble() ?? (json['amount'] as num?)?.toDouble() ?? 0.0;
    final dueAmountVal = (json['due'] as num?)?.toDouble() ?? 0.0;
    final totalAmount = amountPaidVal > 0 || dueAmountVal > 0 ? (amountPaidVal + dueAmountVal) : ((json['amount'] as num?)?.toDouble() ?? 0.0);
    return FeeModel(
      id: json['id']?.toString() ?? '',
      name: json['fee_type']?.toString() ?? json['name']?.toString() ?? 'School Fee',
      currency: json['currency']?.toString() ?? 'MMK',
      amount: totalAmount,
      amountPaid: amountPaidVal,
      dueAmount: dueAmountVal,
      status: json['payment_status']?.toString() ?? json['status']?.toString() ?? 'due',
      dueDate: json['payment_date']?.toString() ?? json['due_date']?.toString(),
      paymentMode: json['payment_mode']?.toString(),
      paidBy: json['fees_paid_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'currency': currency,
        'amount': amount,
        'amount_paid': amountPaid,
        'due': dueAmount,
        'status': status,
        'due_date': dueDate,
        'payment_mode': paymentMode,
        'fees_paid_by': paidBy,
      };

  FeeEntity toEntity() => FeeEntity(
        id: id,
        name: name,
        currency: currency,
        amount: amount,
        amountPaid: amountPaid,
        dueAmount: dueAmount,
        status: FeeStatus.fromString(status),
        dueDate: dueDate,
        paymentMode: paymentMode,
        paidBy: paidBy,
      );
}

/// DTO for [FeeSummary].
class FeeSummaryModel {
  final double totalFees;
  final double totalPaid;
  final double totalDue;

  const FeeSummaryModel({
    required this.totalFees,
    required this.totalPaid,
    required this.totalDue,
  });

  factory FeeSummaryModel.fromJson(Map<String, dynamic> json) {
    return FeeSummaryModel(
      totalFees: (json['total_fees'] as num?)?.toDouble() ?? (json['totalFees'] as num?)?.toDouble() ?? 0.0,
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? (json['totalPaid'] as num?)?.toDouble() ?? 0.0,
      totalDue: (json['total_due'] as num?)?.toDouble() ?? (json['totalDue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  FeeSummary toEntity() => FeeSummary(
        totalFees: totalFees,
        totalPaid: totalPaid,
        totalDue: totalDue,
      );
}
