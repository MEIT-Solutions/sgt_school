import 'package:sgt_school/src/utils/utils.dart';
import '../entities/child_entity.dart';

/// Abstract contract for parent's children operations.
abstract class ChildRepository {
  /// Gets all children linked to a parent account.
  FutureEither<List<ChildEntity>> getChildren(String parentId);
}
