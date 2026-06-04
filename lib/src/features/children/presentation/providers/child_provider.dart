import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/child_repository.dart';
import '../../data/repositories/child_repository_impl.dart';

/// Provider for parent's children.
class ChildProvider extends ChangeNotifier {
  final ChildRepository _repository;

  ChildProvider({ChildRepository? repository})
      : _repository = repository ?? ChildRepositoryImpl();

  List<ChildEntity> _children = [];
  bool _isLoading = false;
  String? _error;

  List<ChildEntity> get children => _children;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadChildren(String parentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getChildren(parentId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load children: ${failure.message}');
      },
      (data) => _children = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
