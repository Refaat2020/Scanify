import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

import '../../../../core/utils/image_processing_utils.dart';
import 'document_processor.dart';

class DocumentProcessorImpl implements DocumentProcessor {
  const DocumentProcessorImpl();

  static const _channel = MethodChannel('com.code/document_processor');

  @override
  Future<Uint8List> compositeDocument({required Uint8List imageBytes}) async {
    try {
      // ✅ Single call — let native handle everything
      final result = await _channel.invokeMethod<Uint8List>('processDocument', {
        'imageBytes': imageBytes,
      });

      if (result != null && result.isNotEmpty) {
        debugPrint('✅ Native processing succeeded: ${result.length} bytes');
        return result;
      } else {
        debugPrint(
          '⚠️  Native processing returned null or empty result, using fallback',
        );
      }
    } on PlatformException catch (e) {
      debugPrint('❌ Native processing failed: ${e.code} - ${e.message}');
      debugPrint('⚠️  Falling back to Dart implementation');
    } catch (e, stackTrace) {
      debugPrint('❌ Unexpected error in native processing: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('⚠️  Falling back to Dart implementation');
    }

    // ✅ Fallback to Dart implementation
    debugPrint('⚠️  Using Dart fallback processor');
    try {
      return await compute(_runDocumentProcessInIsolate, imageBytes);
    } catch (e, stackTrace) {
      debugPrint('❌ Dart fallback also failed: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Optional: Detect corners for UI preview (not used in automatic flow)
  @override
  Future<List<double>?> detectDocumentCorners({
    required Uint8List imageBytes,
  }) async {
    try {
      final result = await _channel.invokeMethod<List<Object?>>(
        'detectCorners',
        {'imageBytes': imageBytes},
      );
      return result?.map((e) => (e as num).toDouble()).toList();
    } catch (e) {
      debugPrint('Corner detection failed: $e');
      return null;
    }
  }

  /// Optional: Manual warp with user-adjusted corners
  @override
  Future<Uint8List?> perspectiveTransform({
    required Uint8List imageBytes,
    required List<double> corners,
  }) async {
    try {
      return await _channel.invokeMethod<Uint8List>('perspectiveTransform', {
        'imageBytes': imageBytes,
        'corners': corners,
      });
    } catch (e) {
      debugPrint('Perspective transform failed: $e');
      return null;
    }
  }
}

/// Dart fallback
Uint8List _runDocumentProcessInIsolate(Uint8List imageBytes) {
  if (imageBytes.isEmpty) {
    throw ArgumentError('Image bytes are empty');
  }

  final original = img.decodeImage(imageBytes);
  if (original == null) {
    throw FormatException('Failed to decode image from bytes');
  }

  final gray = img.grayscale(original);
  final enhanced = enhanceContrast(gray);
  final cropped = autoCropDocument(enhanced);
  final sharpened = sharpenImage(cropped);

  final encoded = img.encodeJpg(sharpened, quality: 95);
  if (encoded.isEmpty) {
    throw StateError('Failed to encode processed image');
  }

  return Uint8List.fromList(encoded);
}
