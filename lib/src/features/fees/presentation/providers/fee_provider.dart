import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/fee_entity.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/fee_repository.dart';
import '../../data/repositories/fee_repository_impl.dart';

/// Provider for student fee and payment data.
class FeeProvider extends ChangeNotifier {
  final FeeRepository _repository;

  FeeProvider({FeeRepository? repository})
      : _repository = repository ?? FeeRepositoryImpl();

  List<FeeEntity> _fees = [];
  FeeSummary? _summary;
  List<PaymentEntity> _payments = [];
  bool _isLoading = false;
  String? _error;

  List<FeeEntity> get fees => _fees;
  FeeSummary? get summary => _summary;
  List<PaymentEntity> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFees(String studentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getFees(studentId);

    result.fold(
      (failure) => _error = failure.message,
      (data) {
        _fees = data.fees;
        _summary = data.summary;
      },
    );
    _payments = [];

    _isLoading = false;
    notifyListeners();
  }
}
