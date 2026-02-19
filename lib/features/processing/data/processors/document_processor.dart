import 'dart:typed_data';

abstract class DocumentProcessor {
  /// Takes image bytes → edge detection → perspective transform →
  /// contrast enhancement → returns processed JPEG bytes.
  /// Runs in background isolate via compute().
  Future<Uint8List> compositeDocument({required Uint8List imageBytes});
}
