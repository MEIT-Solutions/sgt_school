import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Triggers a browser download for the given [bytes] with [fileName].
///
/// Creates an in-memory Blob, generates an object URL, and programmatically
/// clicks a hidden anchor element to trigger the browser's native download.
Future<String> saveDownloadedFile(List<int> bytes, String fileName) async {
  final uint8List = Uint8List.fromList(bytes);
  final blob = web.Blob(
    [uint8List.toJS].toJS,
  );
  final url = web.URL.createObjectURL(blob);

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.style.display = 'none';

  web.document.body?.appendChild(anchor);
  anchor.click();

  // Clean up.
  web.document.body?.removeChild(anchor);
  web.URL.revokeObjectURL(url);

  return fileName;
}
