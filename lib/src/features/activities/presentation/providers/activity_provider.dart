import 'package:sgt_school/src/imports/core_imports.dart';
import '../../domain/entities/activity_entity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../data/repositories/activity_repository_impl.dart';

/// Provider for school activities.
class ActivityProvider extends ChangeNotifier {
  final ActivityRepository _repository;

  ActivityProvider({ActivityRepository? repository})
      : _repository = repository ?? ActivityRepositoryImpl();

  List<ActivityEntity> _activities = [];
  bool _isLoading = false;
  String? _error;

  /// Tracks which file URLs are currently being downloaded.
  final Set<String> _downloadingFiles = {};

  List<ActivityEntity> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Whether a specific file is currently being downloaded.
  bool isDownloading(String fileUrl) => _downloadingFiles.contains(fileUrl);

  Future<void> loadActivities() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getActivities();
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load activities: ${failure.message}');
      },
      (data) => _activities = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTeacherActivities(String teacherId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.getTeacherActivities(teacherId);
    result.fold(
      (failure) {
        _error = failure.message;
        AppLogger.error('Failed to load teacher activities: ${failure.message}');
      },
      (data) => _activities = data,
    );

    _isLoading = false;
    notifyListeners();
  }

  /// Downloads the file at [fileUrl] with the given [fileName]
  /// and opens the share sheet.
  Future<void> downloadFile(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    if (_downloadingFiles.contains(fileUrl)) return; // Already downloading.

    _downloadingFiles.add(fileUrl);
    notifyListeners();

    final result =
        await FileDownloadService.instance.downloadFile(fileUrl, fileName);

    result.fold(
      (failure) {
        AppLogger.error('Download failed: ${failure.message}');
        if (context.mounted) {
          showToast(
            context,
            message: 'activities.download_failed'.tr(),
            status: 'error',
            icon: Icons.error_outline,
          );
        }
      },
      (savePath) {
        AppLogger.success('Download complete: $savePath');
        if (context.mounted) {
          // Extract folder name for user-friendly message.
          // e.g. '/storage/emulated/0/Download/file.xlsx' → 'Download'
          // On web, savePath is just the file name.
          final parts = savePath.split('/');
          final folder = parts.length >= 2 ? parts[parts.length - 2] : '';
          final locationMsg = folder.isNotEmpty
              ? '${'activities.download_success'.tr()} ($folder)'
              : 'activities.download_success'.tr();

          showToast(
            context,
            message: locationMsg,
            status: 'success',
            icon: Icons.download_done_rounded,
          );
        }
      },
    );

    _downloadingFiles.remove(fileUrl);
    notifyListeners();
  }
}
