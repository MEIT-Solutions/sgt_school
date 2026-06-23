import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../utils/utils.dart';

/// A service to easily access platform-specific file system locations.
///
/// Note: Most path_provider APIs are not supported on web.
/// Callers should check [kIsWeb] before invoking these methods.
class PathService {
  PathService._();
  static final PathService instance = PathService._();

  /// Get the directory where the application may place data that is user-generated.
  FutureEither<String> getDocumentsDirectoryPath() async => 
      runTask(() async {
        if (kIsWeb) throw UnsupportedError('Not supported on web');
        final dir = await getApplicationDocumentsDirectory();
        return dir.path;
      });

  /// Get the directory where the application may place application-specific cache files.
  FutureEither<String> getTempDirectoryPath() async => 
      runTask(() async {
        if (kIsWeb) throw UnsupportedError('Not supported on web');
        final dir = await getTemporaryDirectory();
        return dir.path;
      });

  /// Get the directory where the application may place data that is specific to 
  /// the application and not meant to be seen by the user.
  FutureEither<String> getAppSupportDirectoryPath() async => 
      runTask(() async {
        if (kIsWeb) throw UnsupportedError('Not supported on web');
        final dir = await getApplicationSupportDirectory();
        return dir.path;
      });
}
