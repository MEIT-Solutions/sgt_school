import '../imports/imports.dart';

/// Checks internet connectivity before network-dependent operations.
class InternetConnectionService {
  InternetConnectionService();

  final InternetConnection internetConnection = InternetConnection();

  Future<bool> hasConnection() async {
    // On web, simply rely on the internet connection checker.
    // Platform.environment (dart:io) is not available on web.
    if (kIsWeb) {
      return await internetConnection.hasInternetAccess;
    }

    // On non-web platforms, skip checks during Flutter tests.
    if (kDebugMode && _isFlutterTest()) return true;

    return await internetConnection.hasInternetAccess;
  }

  /// Check if running in a Flutter test environment.
  /// Uses a compile-time constant instead of dart:io Platform.
  bool _isFlutterTest() {
    return const bool.fromEnvironment('FLUTTER_TEST');
  }
}
