import 'imports/packages_imports.dart';

enum Flavor { dev, staging, prod }

class FlavorConfig {
  FlavorConfig._({
    required this.flavor,
    required this.baseUrl,
    required this.appName,
  });

  final Flavor flavor;
  final String baseUrl;
  final String appName;

  static late FlavorConfig current;

  /// Bootstrap the app with the given flavor.
  ///
  /// Base URL resolution order:
  ///   1. `--dart-define=API_BASE_URL=...` (CI/CD inject, compile-time)
  ///   2. `dotenv.env['API_BASE_URL']`     (local .env file, runtime)
  ///   3. Throws [StateError] if neither is found (fail-fast)
  static void load(Flavor flavor) {
    final baseUrl = _resolveBaseUrl();

    current = switch (flavor) {
      Flavor.dev => FlavorConfig._(
          flavor: Flavor.dev,
          baseUrl: baseUrl,
          appName: 'SGT International School (Dev)',
        ),
      Flavor.staging => FlavorConfig._(
          flavor: Flavor.staging,
          baseUrl: baseUrl,
          appName: 'SGT International School (Staging)',
        ),
      Flavor.prod => FlavorConfig._(
          flavor: Flavor.prod,
          baseUrl: baseUrl,
          appName: 'SGT International School',
        ),
    };
  }

  /// Resolves the API base URL from compile-time define or .env file.
  ///
  /// Priority: `--dart-define` > `flutter_dotenv` > throw.
  static String _resolveBaseUrl() {
    // 1. Compile-time (--dart-define=API_BASE_URL=...)
    const dartDefine = String.fromEnvironment('API_BASE_URL');
    if (dartDefine.isNotEmpty) return dartDefine;

    // 2. Runtime (.env via flutter_dotenv)
    final envValue = dotenv.env['API_BASE_URL'];
    if (envValue != null && envValue.isNotEmpty) return envValue;

    throw StateError(
      'API_BASE_URL not found. '
      'Provide via --dart-define=API_BASE_URL=... or .env file.',
    );
  }

  // ── Convenience getters ──────────────────────────────────────────────────

  static String get name => current.flavor.name;
  static String get currentBaseUrl => current.baseUrl;
  static String get currentAppName => current.appName;

  static bool get isDev => current.flavor == Flavor.dev;
  static bool get isStaging => current.flavor == Flavor.staging;
  static bool get isProd => current.flavor == Flavor.prod;
}
