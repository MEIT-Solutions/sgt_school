/// Stub for platform-specific file saving.
///
/// This file is never imported directly. It serves as the default fallback
/// for the conditional import in `file_saver.dart`.
Future<String> saveDownloadedFile(List<int> bytes, String fileName) {
  throw UnsupportedError('File saving is not supported on this platform.');
}
