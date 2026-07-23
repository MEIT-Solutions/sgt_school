import '../imports/core_imports.dart';
import 'package:dio/dio.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';

/// Secure storage key for the persisted base URL.
const _kBaseUrlKey = 'cloud_base_url';

/// SharedPreferences key to detect fresh installs (iOS Keychain survives uninstall).
const _kHasLaunchedKey = 'has_launched_before';

class AppConfig {
  AppConfig._();
  static late final Dio dio;

  /// Default base URLs for each environment.
  static const devBaseUrl = 'https://uat.sgt-odoo.com/api/v1';
  static const prodBaseUrl = 'https://sgt-odoo.com/api/v1';

  /// The current base URL (initialised in [init]).
  static String _currentBaseUrl = prodBaseUrl;
  static String get baseUrl => _currentBaseUrl;

  /// Whether a session token existed at startup (set during [init]).
  /// Used by the router to choose the correct initial location.
  static bool hasExistingSession = false;

  static Future<void> init() async {
    await StorageService.instance.init();

    // ── Fresh-install guard (iOS Keychain survives uninstall) ──
    // SharedPreferences IS deleted on uninstall, so a missing flag means
    // this is a fresh install → clear any stale Keychain session data.
    final hasLaunched = StorageService.instance.getBool(_kHasLaunchedKey) ?? false;
    if (!hasLaunched) {
      AppLogger.info('🔑 First launch detected — clearing stale Keychain data');
      await SecureStorageService.instance.deleteAll();
      await StorageService.instance.setBool(_kHasLaunchedKey, true);
    }

    // Load persisted URL; fall back to production if nothing stored.
    _currentBaseUrl = await getStoredBaseUrl();

    // Check if user has an existing session (fast — no network call).
    hasExistingSession = await AuthLocalDatasource.instance().hasSession();

    dio = Dio(
      BaseOptions(
        baseUrl: _currentBaseUrl,
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 40),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final fullUrl = '${options.baseUrl}${options.path}';
          if (kDebugMode) {
            AppLogger.info('🌐 [DIO] REQUEST[${options.method}] => URL: $fullUrl');
            AppLogger.info('📦 [DIO] REQUEST BODY: ${options.data}');
          }
          try {
            final token = await AuthLocalDatasource.instance().getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            AppLogger.error('Failed to append token: $e');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            AppLogger.info('✅ [DIO] RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
            AppLogger.info('📥 [DIO] RESPONSE BODY: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          final fullUrl = '${e.requestOptions.baseUrl}${e.requestOptions.path}';
          if (kDebugMode) {
            AppLogger.error('❌ [DIO] ERROR[${e.response?.statusCode}] => URL: $fullUrl');
            AppLogger.error('📦 [DIO] ERROR REQUEST BODY: ${e.requestOptions.data}');
            AppLogger.error('📥 [DIO] ERROR RESPONSE BODY: ${e.response?.data}');
          }

          // ── Token Refresh on 401 ───────────────────────────────────
          if (e.response?.statusCode == 401) {
            // Don't retry if this was already a refresh request
            if (e.requestOptions.path.contains('/school/refresh')) {
              return handler.next(e);
            }

            try {
              final datasource = AuthLocalDatasource.instance();
              final refreshToken = await datasource.getRefreshToken();

              if (refreshToken == null || refreshToken.isEmpty) {
                AppLogger.warning('🔑 No refresh token — cannot refresh');
                return handler.next(e);
              }

              AppLogger.info('🔄 Attempting token refresh...');

              // Use a fresh Dio instance to avoid interceptor loops
              final refreshDio = Dio(BaseOptions(
                baseUrl: dio.options.baseUrl,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ));

              final refreshResponse = await refreshDio.post(
                '/school/refresh',
                data: {'refresh_token': refreshToken},
              );

              final refreshData = refreshResponse.data;
              if (refreshData != null && refreshData['success'] == true) {
                final newData = refreshData['data'] as Map<String, dynamic>?;
                final newToken = newData?['token'] as String?;
                final newRefreshToken = newData?['refresh_token'] as String?;

                if (newToken != null && newToken.isNotEmpty) {
                  // Save new tokens
                  await datasource.updateTokens(
                    token: newToken,
                    refreshToken: newRefreshToken,
                  );

                  AppLogger.success('🔑 Token refreshed successfully');

                  // Retry the original request with the new token
                  e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await dio.fetch(e.requestOptions);
                  return handler.resolve(retryResponse);
                }
              }

              // Refresh failed — clear session
              AppLogger.error('🔑 Token refresh failed — clearing session');
              await datasource.clearSession();
            } catch (refreshError) {
              AppLogger.error('🔑 Token refresh error: $refreshError');
              await AuthLocalDatasource.instance().clearSession();
            }
          }

          return handler.next(e);
        },
      ),
    );
  }

  /// Returns the currently stored base URL, falling back to [devBaseUrl].
  ///
  /// Also validates the URL — corrupted values are discarded.
  static Future<String> getStoredBaseUrl() async {
    final result = await SecureStorageService.instance.read(_kBaseUrlKey);
    final value = result.fold((_) => null, (v) => v);

    if (value == null || value.isEmpty) return prodBaseUrl;

    // Validate stored URL
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority || (!value.startsWith('http://') && !value.startsWith('https://'))) {
      // Corrupted URL — clean up and fall back
      AppLogger.warning('⚠️ Invalid stored URL "$value" — resetting to production');
      await SecureStorageService.instance.delete(_kBaseUrlKey);
      return prodBaseUrl;
    }

    return value;
  }

  /// Persists a new base URL and updates the Dio instance in-place.
  static Future<void> updateBaseUrl(String newUrl) async {
    await SecureStorageService.instance.write(_kBaseUrlKey, newUrl);
    _currentBaseUrl = newUrl;
    dio.options.baseUrl = newUrl;
    AppLogger.info('☁️ Base URL updated to: $newUrl');
  }
}
