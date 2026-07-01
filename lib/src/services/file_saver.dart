/// Platform-aware file saver.
///
/// Uses conditional imports to resolve the correct implementation:
/// - `dart:io` platforms (Android, iOS, desktop) → [file_saver_io.dart]
/// - `dart:js_interop` platforms (Web) → [file_saver_web.dart]
library;

export 'file_saver_stub.dart'
    if (dart.library.io) 'file_saver_io.dart'
    if (dart.library.js_interop) 'file_saver_web.dart';
