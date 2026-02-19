import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../../../core/utils/image_processing_utils.dart';
import 'document_processor.dart';

class DocumentProcessorImpl implements DocumentProcessor {
  const DocumentProcessorImpl();

  @override
  Future<Uint8List> compositeDocument({required Uint8List imageBytes}) async {
    return compute(_runDocumentProcessInIsolate, imageBytes);
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

// ─────────────────────────────────────────────────────────────────────────────
// Image processing helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Enhance contrast using histogram stretching
// img.Image _enhanceContrast(img.Image src) {
//   int minVal = 255, maxVal = 0;
//
//   // Find min/max pixel values
//   for (final pixel in src) {
//     final lum = pixel.r.toInt();
//     if (lum < minVal) minVal = lum;
//     if (lum > maxVal) maxVal = lum;
//   }
//
//   if (maxVal == minVal) return src;
//
//   final range = maxVal - minVal;
//   final result = img.Image(width: src.width, height: src.height);
//
//   // Stretch histogram
//   for (int y = 0; y < src.height; y++) {
//     for (int x = 0; x < src.width; x++) {
//       final pixel = src.getPixel(x, y);
//       final stretched = (((pixel.r.toInt() - minVal) / range) * 255)
//           .clamp(0, 255)
//           .toInt();
//       result.setPixelRgba(x, y, stretched, stretched, stretched, 255);
//     }
//   }
//   return result;
// }
//
// /// Auto-crop white/light borders by finding content boundaries
// img.Image _autoCropDocument(img.Image src) {
//   const threshold = 230; // Pixels brighter than this are "background"
//   const margin = 10; // Keep some padding
//
//   int top = 0, bottom = src.height - 1;
//   int left = 0, right = src.width - 1;
//
//   // Find top edge (scan from top down)
//   bool foundTop = false;
//   for (int y = 0; y < src.height && !foundTop; y++) {
//     int darkPixels = 0;
//     for (int x = 0; x < src.width; x++) {
//       if (src.getPixel(x, y).r.toInt() < threshold) {
//         darkPixels++;
//       }
//     }
//     // If more than 20% of row is content (dark), this is the top
//     if (darkPixels > src.width * 0.2) {
//       top = y;
//       foundTop = true;
//     }
//   }
//
//   // Find bottom edge (scan from bottom up)
//   bool foundBottom = false;
//   for (int y = src.height - 1; y >= 0 && !foundBottom; y--) {
//     int darkPixels = 0;
//     for (int x = 0; x < src.width; x++) {
//       if (src.getPixel(x, y).r.toInt() < threshold) {
//         darkPixels++;
//       }
//     }
//     if (darkPixels > src.width * 0.2) {
//       bottom = y;
//       foundBottom = true;
//     }
//   }
//
//   // Find left edge (scan from left to right)
//   bool foundLeft = false;
//   for (int x = 0; x < src.width && !foundLeft; x++) {
//     int darkPixels = 0;
//     for (int y = 0; y < src.height; y++) {
//       if (src.getPixel(x, y).r.toInt() < threshold) {
//         darkPixels++;
//       }
//     }
//     if (darkPixels > src.height * 0.2) {
//       left = x;
//       foundLeft = true;
//     }
//   }
//
//   // Find right edge (scan from right to left)
//   bool foundRight = false;
//   for (int x = src.width - 1; x >= 0 && !foundRight; x--) {
//     int darkPixels = 0;
//     for (int y = 0; y < src.height; y++) {
//       if (src.getPixel(x, y).r.toInt() < threshold) {
//         darkPixels++;
//       }
//     }
//     if (darkPixels > src.height * 0.2) {
//       right = x;
//       foundRight = true;
//     }
//   }
//
//   // Apply margin and clamp
//   top = (top - margin).clamp(0, src.height - 1);
//   bottom = (bottom + margin).clamp(0, src.height - 1);
//   left = (left - margin).clamp(0, src.width - 1);
//   right = (right + margin).clamp(0, src.width - 1);
//
//   final w = right - left;
//   final h = bottom - top;
//
//   // Safety check
//   if (w <= 0 || h <= 0 || w < src.width * 0.3 || h < src.height * 0.3) {
//     // Crop would be too aggressive or invalid, return original
//     return src;
//   }
//
//   return img.copyCrop(src, x: left, y: top, width: w, height: h);
// }
