import '../../domain/entities/payment_entity.dart';

/// DTO for [PaymentEntity].
class PaymentModel {
  final String id;
  final String date;
  final double amount;
  final String method;
  final String reference;
  final String? feeName;

  const PaymentModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.method,
    required this.reference,
    this.feeName,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String? ?? '',
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      reference: json['reference'] as String,
      feeName: json['fee_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'amount': amount,
        'method': method,
        'reference': reference,
        'fee_name': feeName,
      };

  PaymentEntity toEntity() => PaymentEntity(
        id: id,
        date: date,
        amount: amount,
        method: method,
        reference: reference,
        feeName: feeName,
      );
}
