import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/utils.dart';

/// A service to handle media selection (images, videos, files).
class MediaService {
  MediaService._();
  static final MediaService instance = MediaService._();

  final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from gallery or camera.
  /// Returns the [XFile] path wrapped for platform safety.
  FutureEither<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return runTask(() async {
      // Check permissions (not applicable on web)
      if (!kIsWeb) {
        if (source == ImageSource.camera) {
          final status = await Permission.camera.request();
          if (!status.isGranted) {
            throw Exception('Camera permission denied');
          }
        } else {
          final isMobile = defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS;
          if (isMobile) {
            final status = await Permission.photos.request();
            if (!status.isGranted && !status.isLimited) {
              throw Exception('Photos permission denied');
            }
          }
        }
      }

      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      return file;
    });
  }

  /// Pick multiple images from gallery.
  FutureEither<List<XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    return runTask(() async {
      if (!kIsWeb) {
        final isMobile = defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;
        if (isMobile) {
          final status = await Permission.photos.request();
          if (!status.isGranted && !status.isLimited) {
            throw Exception('Photos permission denied');
          }
        }
      }

      final List<XFile> files = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      return files;
    });
  }

  /// Pick a video from gallery or camera.
  FutureEither<XFile?> pickVideo({
    required ImageSource source,
    Duration? maxDuration,
  }) async {
    return runTask(() async {
      if (!kIsWeb) {
        if (source == ImageSource.camera) {
          final status = await Permission.camera.request();
          if (!status.isGranted) {
            throw Exception('Camera permission denied');
          }
        } else {
          final isMobile = defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS;
          if (isMobile) {
            final status = await Permission.photos.request();
            if (!status.isGranted && !status.isLimited) {
              throw Exception('Photos permission denied');
            }
          }
        }
      }

      final XFile? file = await _imagePicker.pickVideo(
        source: source,
        maxDuration: maxDuration,
      );

      return file;
    });
  }
}
