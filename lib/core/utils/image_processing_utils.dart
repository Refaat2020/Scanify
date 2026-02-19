import 'package:image/image.dart' as img;

img.Image enhanceContrast(img.Image src) {
  int minVal = 255, maxVal = 0;

  for (final pixel in src) {
    final lum = pixel.r.toInt();
    if (lum < minVal) minVal = lum;
    if (lum > maxVal) maxVal = lum;
  }

  if (maxVal == minVal) return src;

  final range = maxVal - minVal;
  final result = img.Image(width: src.width, height: src.height);

  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      final pixel = src.getPixel(x, y);
      final stretched = (((pixel.r.toInt() - minVal) / range) * 255)
          .clamp(0, 255)
          .toInt();
      result.setPixelRgba(x, y, stretched, stretched, stretched, 255);
    }
  }
  return result;
}

img.Image autoCropDocument(img.Image src) {
  const threshold = 230;
  const margin = 8;

  int top = 0, bottom = src.height - 1, left = 0, right = src.width - 1;

  outer:
  for (int y = 0; y < src.height; y++) {
    for (int x = 0; x < src.width; x++) {
      if (src.getPixel(x, y).r.toInt() < threshold) {
        top = y;
        break outer;
      }
    }
  }
  outer:
  for (int y = src.height - 1; y >= 0; y--) {
    for (int x = 0; x < src.width; x++) {
      if (src.getPixel(x, y).r.toInt() < threshold) {
        bottom = y;
        break outer;
      }
    }
  }
  outer:
  for (int x = 0; x < src.width; x++) {
    for (int y = 0; y < src.height; y++) {
      if (src.getPixel(x, y).r.toInt() < threshold) {
        left = x;
        break outer;
      }
    }
  }
  outer:
  for (int x = src.width - 1; x >= 0; x--) {
    for (int y = 0; y < src.height; y++) {
      if (src.getPixel(x, y).r.toInt() < threshold) {
        right = x;
        break outer;
      }
    }
  }

  top = (top - margin).clamp(0, src.height - 1);
  bottom = (bottom + margin).clamp(0, src.height - 1);
  left = (left - margin).clamp(0, src.width - 1);
  right = (right + margin).clamp(0, src.width - 1);

  final w = right - left;
  final h = bottom - top;

  if (w <= 0 || h <= 0) return src;
  return img.copyCrop(src, x: left, y: top, width: w, height: h);
}

/// Apply unsharp mask for better text clarity
img.Image sharpenImage(img.Image src) {
  // Simple 3x3 sharpening kernel
  final sharpened = img.Image(width: src.width, height: src.height);

  for (int y = 1; y < src.height - 1; y++) {
    for (int x = 1; x < src.width - 1; x++) {
      final center = src.getPixel(x, y).r.toInt();

      // 3x3 kernel neighbors
      final neighbors = [
        src.getPixel(x - 1, y - 1).r.toInt(),
        src.getPixel(x, y - 1).r.toInt(),
        src.getPixel(x + 1, y - 1).r.toInt(),
        src.getPixel(x - 1, y).r.toInt(),
        src.getPixel(x + 1, y).r.toInt(),
        src.getPixel(x - 1, y + 1).r.toInt(),
        src.getPixel(x, y + 1).r.toInt(),
        src.getPixel(x + 1, y + 1).r.toInt(),
      ];

      final avg = neighbors.reduce((a, b) => a + b) / 8;
      final sharpValue = (center * 2 - avg).clamp(0, 255).toInt();

      sharpened.setPixelRgba(x, y, sharpValue, sharpValue, sharpValue, 255);
    }
  }

  // Copy edges from original
  for (int x = 0; x < src.width; x++) {
    final top = src.getPixel(x, 0).r.toInt();
    final bottom = src.getPixel(x, src.height - 1).r.toInt();
    sharpened.setPixelRgba(x, 0, top, top, top, 255);
    sharpened.setPixelRgba(x, src.height - 1, bottom, bottom, bottom, 255);
  }
  for (int y = 0; y < src.height; y++) {
    final left = src.getPixel(0, y).r.toInt();
    final right = src.getPixel(src.width - 1, y).r.toInt();
    sharpened.setPixelRgba(0, y, left, left, left, 255);
    sharpened.setPixelRgba(src.width - 1, y, right, right, right, 255);
  }

  return sharpened;
}
