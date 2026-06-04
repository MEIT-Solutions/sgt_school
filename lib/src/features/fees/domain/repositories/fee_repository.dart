import 'package:sgt_school/src/utils/utils.dart';
import '../entities/fee_entity.dart';
import '../entities/payment_entity.dart';

/// Abstract contract for fee and payment data operations.
abstract class FeeRepository {
  /// Gets all fee line items and summary for a student.
  FutureEither<StudentFeeData> getFees(String studentId);

  /// Gets payment history for a student.
  FutureEither<List<PaymentEntity>> getPaymentHistory(String studentId);
}
