import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../imports/core_imports.dart';

/// A reusable generic function to handle potential exceptions in async tasks
/// and map them to the [Either] type matching [FutureEither<T>].
///
/// Network failures are detected from actual Dio connection errors rather than
/// a pre-flight connectivity check, which avoids false negatives from
/// `connectivity_plus`.
FutureEither<T> runTask<T>(
  Future<T> Function() action, {
  @Deprecated('No longer used — network errors are caught from Dio directly')
  bool requiresNetwork = false,
}) async {
  try {
    final result = await action();
    return right(result);
  } on DioException catch (error, stackTrace) {
    // Map Dio connection / timeout errors to NetworkFailure
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      const msg =
          'No internet connection. Please check your connection and try again.';
      AppLogger.warning('Network error: ${error.type}');
      showGlobalToast(message: msg, status: 'warning');
      return left(const NetworkFailure(msg));
    }

    // Other Dio errors (4xx, 5xx, etc.)
    AppLogger.error('Task execution failed $error', [error, stackTrace]);
    final errorMessage = AppErrorHandler.format(error);
    return left(ServerFailure(errorMessage, error: error));
  } catch (error, stackTrace) {
    AppLogger.error('Task execution failed $error', [error, stackTrace]);
    final errorMessage = AppErrorHandler.format(error);
    return left(ServerFailure(errorMessage, error: error));
  }
}

