import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Saves downloaded bytes to the device file system.
///
/// - **Android**: Saves to the public Downloads folder.
/// - **iOS**: Saves to temp and opens the share sheet.
/// - **Desktop**: Saves to the current directory.
Future<String> saveDownloadedFile(List<int> bytes, String fileName) async {
  final savePath = await _getSavePath(fileName);
  final file = File(savePath);
  await file.writeAsBytes(bytes, flush: true);

  // On iOS, open the share sheet so the user can save to Files app.
  if (!kIsWeb && Platform.isIOS) {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(savePath)]),
    );
  }

  return savePath;
}

/// Returns the file save path based on the platform.
Future<String> _getSavePath(String fileName) async {
  if (Platform.isAndroid) {
    final downloadsDir = Directory('/storage/emulated/0/Download');
    if (await downloadsDir.exists()) {
      final baseName = fileName.contains('.')
          ? fileName.substring(0, fileName.lastIndexOf('.'))
          : fileName;
      final extension = fileName.contains('.')
          ? fileName.substring(fileName.lastIndexOf('.'))
          : '';
      final timestamp =
          DateTime.now().millisecondsSinceEpoch.toString().substring(8);

      final targetFile = File('${downloadsDir.path}/$fileName');
      if (await targetFile.exists()) {
        return '${downloadsDir.path}/${baseName}_$timestamp$extension';
      }
      return targetFile.path;
    }
  }

  // Fallback: temp directory (iOS, or if Downloads dir doesn't exist).
  final tempDir = await Directory.systemTemp.createTemp('sgt_download_');
  return '${tempDir.path}/$fileName';
}
