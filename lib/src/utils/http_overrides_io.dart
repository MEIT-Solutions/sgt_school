import 'dart:io';

/// Applies [HttpOverrides] to bypass certificate checks in debug mode.
/// Only used on non-web platforms (mobile, desktop).
void applyHttpOverrides() {
  HttpOverrides.global = _DebugHttpOverrides();
}

class _DebugHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
