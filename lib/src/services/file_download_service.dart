import 'package:dio/dio.dart';
import '../utils/utils.dart';
import '../config/app_config.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import 'file_saver.dart';

/// A reusable service for downloading files from authenticated API endpoints.
///
/// Works across all platforms:
/// - **Android**: Saves to the device's public Downloads folder.
/// - **iOS**: Downloads then opens the share sheet.
/// - **Web**: Triggers a native browser download.
class FileDownloadService {
  FileDownloadService._();
  static final FileDownloadService instance = FileDownloadService._();

  /// Downloads a file from [relativeUrl] and saves it to the device.
  ///
  /// Returns the local file path (or file name on web) on success.
  FutureEither<String> downloadFile(
    String relativeUrl,
    String fileName,
  ) async {
    return runTask(() async {
      final fullUrl = _buildFullUrl(relativeUrl);

      AppLogger.info('📥 [Download] Starting download: $fullUrl');

      // Get auth token.
      final token = await AuthLocalDatasource.instance().getToken();

      // Download as bytes (works on all platforms including web).
      final dio = Dio();
      final response = await dio.get<List<int>>(
        fullUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      // Delegate to platform-specific file saver.
      final savePath = await saveDownloadedFile(response.data!, fileName);

      AppLogger.success('✅ [Download] File saved: $savePath');
      return savePath;
    });
  }

  /// Builds the full download URL from a relative API path.
  String _buildFullUrl(String relativeUrl) {
    final baseUrl = AppConfig.baseUrl;
    if (relativeUrl.startsWith('/api/v1/')) {
      // The relativeUrl contains /api/v1/ which overlaps with baseUrl.
      final baseWithoutApiVersion =
          baseUrl.replaceAll(RegExp(r'/api/v1/?$'), '');
      return '$baseWithoutApiVersion$relativeUrl';
    }
    return '$baseUrl$relativeUrl';
  }
}
