import 'dart:io';

import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/utils.dart';
import '../config/app_config.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';

/// A reusable service for downloading files from authenticated API endpoints
/// and sharing them via the platform share sheet.
class FileDownloadService {
  FileDownloadService._();
  static final FileDownloadService instance = FileDownloadService._();

  /// Downloads a file from [relativeUrl] (e.g. `/api/v1/activities/6/exam-paper/download`)
  /// and opens the share sheet so the user can view/save it.
  ///
  /// Returns the local file path on success.
  FutureEither<String> downloadAndShare(
    String relativeUrl,
    String fileName,
  ) async {
    return runTask(() async {
      // Build full URL from base URL.
      // The relativeUrl already starts with /api/v1/... but our base URL
      // already contains /api/v1, so we need to strip the overlap.
      final baseUrl = AppConfig.baseUrl;
      final String fullUrl;
      if (relativeUrl.startsWith('/api/v1/')) {
        // Remove /api/v1 from the base URL and append the full relative path.
        final baseWithoutApiVersion =
            baseUrl.replaceAll(RegExp(r'/api/v1/?$'), '');
        fullUrl = '$baseWithoutApiVersion$relativeUrl';
      } else {
        fullUrl = '$baseUrl$relativeUrl';
      }

      AppLogger.info('📥 [Download] Starting download: $fullUrl');

      // Get auth token.
      final token = await AuthLocalDatasource.instance().getToken();

      // Download to a temp file.
      final tempDir = await Directory.systemTemp.createTemp('sgt_download_');
      final filePath = '${tempDir.path}/$fileName';

      final dio = Dio();
      await dio.download(
        fullUrl,
        filePath,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      AppLogger.success('✅ [Download] File saved to: $filePath');

      // Share via platform share sheet.
      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)]),
      );

      return filePath;
    });
  }
}
