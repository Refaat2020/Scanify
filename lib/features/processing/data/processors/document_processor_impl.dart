import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../../../../core/utils/image_processing_utils.dart';
import 'document_processor.dart';

class DocumentProcessorImpl implements DocumentProcessor {
  const DocumentProcessorImpl();

  static const _channel = MethodChannel('com.code/document_processor');

  /// Full native pipeline: edge detect → warp → enhance.
  /// Falls back to pure-Dart isolate if platform channel fails.
  @override
  Future<Uint8List> compositeDocument({required Uint8List imageBytes}) async {
    try {
      debugPrint('🔵 calling detectDocumentCorners');
      final corners = await detectDocumentCorners(imageBytes: imageBytes);
      debugPrint('🔵 corners: $corners');

      if (corners != null) {
        debugPrint('🔵 calling perspectiveTransform');
        final result = await perspectiveTransform(
          imageBytes: imageBytes,
          corners: corners,
        );
        debugPrint('🔵 perspectiveTransform result: ${result?.length}');
        if (result != null) return result;
      }

      debugPrint('🔵 falling back to processDocument channel');
      final result = await _channel.invokeMethod<Uint8List>('processDocument', {
        'imageBytes': imageBytes,
      });
      return result!;
    } on PlatformException catch (e) {
      debugPrint('❌ Native failed: ${e.code} ${e.message}');
      return compute(_runDocumentProcessInIsolate, imageBytes);
    }
  }

  /// Detect document corners only — useful for showing a drag-to-adjust UI
  /// before committing to the final warp.
  @override
  Future<List<double>?> detectDocumentCorners({
    required Uint8List imageBytes,
  }) async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>(
        'detectCorners',
        {'imageBytes': imageBytes},
      );
      debugPrint('detectCorners raw result: $result'); // 👈 add this first

      return result?.cast<double>();
    } on PlatformException catch (e) {
      debugPrint('Corner detection failed: ${e.message}');
      return null; // Caller falls back to compositeDocument()
    }
  }

  /// Apply perspective warp given manually confirmed or detected corners.
  @override
  Future<Uint8List?> perspectiveTransform({
    required Uint8List imageBytes,
    required List<double> corners, // [x1,y1, x2,y2, x3,y3, x4,y4]
  }) async {
    try {
      final result = await _channel.invokeMethod<Uint8List>(
        'perspectiveTransform',
        {'imageBytes': imageBytes, 'corners': corners},
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Perspective transform failed: ${e.message}');
      return null; // Caller falls back to compositeDocument()
    }
  }
}

/// Runs in background isolate — fast adaptive processing
Uint8List _runDocumentProcessInIsolate(Uint8List imageBytes) {
  // 1. Decode
  final original = img.decodeImage(imageBytes)!;

  // 2. Convert to grayscale
  final gray = img.grayscale(original);

  // 3. Enhance contrast (makes edges clearer)
  final enhanced = enhanceContrast(gray);

  // 4. Auto-crop white borders (adaptive edge detection)
  final cropped = autoCropDocument(enhanced);

  // 5. Apply sharpening for better text clarity
  final sharpened = sharpenImage(cropped);

  // 6. Encode as high-quality JPEG
  return Uint8List.fromList(img.encodeJpg(sharpened, quality: 95));
}
