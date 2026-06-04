import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:sgt_school/src/features/fees/domain/entities/fee_entity.dart';
import 'package:sgt_school/src/features/fees/domain/entities/payment_entity.dart';
import 'package:sgt_school/src/features/fees/domain/repositories/fee_repository.dart';
import 'package:sgt_school/src/features/fees/presentation/providers/fee_provider.dart';
import 'package:sgt_school/src/utils/failure.dart';
import 'package:sgt_school/src/utils/typedefs.dart';

class FakeFeeRepository implements FeeRepository {
  bool shouldFail = false;
  String failMessage = 'Mock repository error';

  final StudentFeeData feeData = const StudentFeeData(
    fees: [
      FeeEntity(
        id: '7',
        name: 'Monthy',
        amount: 2000.0,
        amountPaid: 2000.0,
        dueAmount: 0.0,
        status: FeeStatus.paid,
        dueDate: '2026-06-03',
        paymentMode: 'cash',
        paidBy: 'parents',
      )
    ],
    summary: FeeSummary(
      totalFees: 2000.0,
      totalPaid: 2000.0,
      totalDue: 0.0,
    ),
  );

  @override
  FutureEither<StudentFeeData> getFees(String studentId) async {
    if (shouldFail) return left(ServerFailure(failMessage));
    return right(feeData);
  }

  @override
  FutureEither<List<PaymentEntity>> getPaymentHistory(String studentId) async {
    return right([]);
  }
}

void main() {
  late FakeFeeRepository fakeRepository;
  late FeeProvider provider;

  setUp(() {
    fakeRepository = FakeFeeRepository();
    provider = FeeProvider(repository: fakeRepository);
  });

  group('FeeProvider loadFees', () {
    test('loads fees and summary on success', () async {
      expect(provider.isLoading, isFalse);
      expect(provider.fees, isEmpty);
      expect(provider.summary, isNull);

      final future = provider.loadFees('147');
      expect(provider.isLoading, isTrue);

      await future;

      expect(provider.isLoading, isFalse);
      expect(provider.fees, hasLength(1));
      expect(provider.fees.first.name, 'Monthy');
      expect(provider.summary, isNotNull);
      expect(provider.summary!.totalFees, 2000.0);
      expect(provider.error, isNull);
    });

    test('sets error message on failure', () async {
      fakeRepository.shouldFail = true;
      fakeRepository.failMessage = 'Network issues';

      await provider.loadFees('147');

      expect(provider.isLoading, isFalse);
      expect(provider.fees, isEmpty);
      expect(provider.summary, isNull);
      expect(provider.error, 'Network issues');
    });
  });
}
