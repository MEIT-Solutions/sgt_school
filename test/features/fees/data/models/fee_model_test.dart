import 'package:flutter_test/flutter_test.dart';
import 'package:sgt_school/src/features/fees/data/models/fee_model.dart';
import 'package:sgt_school/src/features/fees/domain/entities/fee_entity.dart';

void main() {
  group('FeeModel parsing', () {
    test('parses from real API JSON format successfully', () {
      final json = {
        'id': 7,
        'student_name': 'Ellena',
        'fee_type': 'Monthy',
        'amount_paid': 2000.0,
        'total_paid': 2000.0,
        'due': 0.0,
        'total_due': 0.0,
        'payment_status': 'paid',
        'payment_date': '2026-06-03',
        'fees_paid_by': 'parents',
        'payment_mode': 'cash'
      };

      final model = FeeModel.fromJson(json);

      expect(model.id, '7');
      expect(model.name, 'Monthy');
      expect(model.amount, 2000.0);
      expect(model.amountPaid, 2000.0);
      expect(model.dueAmount, 0.0);
      expect(model.status, 'paid');
      expect(model.dueDate, '2026-06-03');
      expect(model.paymentMode, 'cash');
      expect(model.paidBy, 'parents');

      final entity = model.toEntity();
      expect(entity.id, '7');
      expect(entity.name, 'Monthy');
      expect(entity.amount, 2000.0);
      expect(entity.amountPaid, 2000.0);
      expect(entity.dueAmount, 0.0);
      expect(entity.status, FeeStatus.paid);
      expect(entity.dueDate, '2026-06-03');
      expect(entity.paymentMode, 'cash');
      expect(entity.paidBy, 'parents');
    });

    test('parses from mock format successfully', () {
      final json = {
        'id': 'FEE-1',
        'name': 'Tuition Fee',
        'amount': 600.00,
        'status': 'paid',
        'due_date': '2026-06-03'
      };

      final model = FeeModel.fromJson(json);

      expect(model.id, 'FEE-1');
      expect(model.name, 'Tuition Fee');
      expect(model.amount, 600.00);
      expect(model.status, 'paid');
      expect(model.dueDate, '2026-06-03');
    });
  });

  group('FeeSummaryModel parsing', () {
    test('parses from real API summary JSON successfully', () {
      final json = {
        'total_fees': 2000.0,
        'total_paid': 1500.0,
        'total_due': 500.0
      };

      final model = FeeSummaryModel.fromJson(json);

      expect(model.totalFees, 2000.0);
      expect(model.totalPaid, 1500.0);
      expect(model.totalDue, 500.0);

      final entity = model.toEntity();
      expect(entity.totalFees, 2000.0);
      expect(entity.totalPaid, 1500.0);
      expect(entity.totalDue, 500.0);
    });
  });
}
