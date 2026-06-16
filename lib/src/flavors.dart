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
  static void load(Flavor flavor) {
    current = switch (flavor) {
      Flavor.dev => FlavorConfig._(
          flavor: Flavor.dev,
          baseUrl: 'http://150.95.85.135:8070/api/v1',
          appName: 'SGT International School (Dev)',
        ),
      Flavor.staging => FlavorConfig._(
          flavor: Flavor.staging,
          baseUrl: 'http://150.95.85.135:8070/api/v1',
          appName: 'SGT International School (Staging)',
        ),
      Flavor.prod => FlavorConfig._(
          flavor: Flavor.prod,
          baseUrl: 'http://150.95.30.124:8070/api/v1',
          appName: 'SGT International School',
        ),
    };
  }

  // ── Convenience getters ──────────────────────────────────────────────────

  static String get name => current.flavor.name;
  static String get currentBaseUrl => current.baseUrl;
  static String get currentAppName => current.appName;

  static bool get isDev => current.flavor == Flavor.dev;
  static bool get isStaging => current.flavor == Flavor.staging;
  static bool get isProd => current.flavor == Flavor.prod;
}
