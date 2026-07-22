import '../imports/imports.dart';

/// Checks internet connectivity using [connectivity_plus].
///
/// This package checks the **network interface status** (WiFi, mobile, VPN, etc.)
/// rather than pinging external servers, so it works reliably with VPNs.
class InternetConnectionService {
  InternetConnectionService();

  final Connectivity _connectivity = Connectivity();

  Future<bool> hasConnection() async {
    // On non-web platforms, skip checks during Flutter tests.
    if (!kIsWeb && kDebugMode && _isFlutterTest()) return true;

    final results = await _connectivity.checkConnectivity();

    // Returns true if connected via any interface (wifi, mobile, vpn, ethernet, etc.)
    // Only returns false if the sole result is ConnectivityResult.none.
    return results.any((result) => result != ConnectivityResult.none);
  }

  /// Check if running in a Flutter test environment.
  bool _isFlutterTest() {
    return const bool.fromEnvironment('FLUTTER_TEST');
  }
}
