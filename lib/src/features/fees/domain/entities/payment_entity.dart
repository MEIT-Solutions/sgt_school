import 'package:equatable/equatable.dart';

/// A single payment transaction.
class PaymentEntity extends Equatable {
  final String id;
  final String date;
  final double amount;
  final String method;
  final String reference;
  final String? feeName;

  const PaymentEntity({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    required this.reference,
    this.feeName,
  });

  @override
  List<Object?> get props => [id, date, amount, method, reference, feeName];
}
