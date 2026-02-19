import 'package:flutter/foundation.dart'; // compute()
import 'package:image/image.dart' as img;

import '../models/face_rect.dart';
import 'face_processor.dart';

class _FaceCompositeParams {
  final Uint8List imageBytes;
  final List<FaceRect> faceRects;
  const _FaceCompositeParams({
    required this.imageBytes,
    required this.faceRects,
  });
}

class FaceProcessorImpl implements FaceProcessor {
  const FaceProcessorImpl();

  /// Applies grayscale to detected face regions and returns final JPEG bytes.
  @override
  Future<Uint8List> compositeFaces({
    required Uint8List imageBytes,
    required List<FaceRect> rects,
  }) async {
    if (rects.isEmpty) {
      throw ArgumentError('Face rectangles list cannot be empty');
    }

    return compute(
      _runFaceCompositeInIsolate,
      _FaceCompositeParams(imageBytes: imageBytes, faceRects: rects),
    );
  }
}

// Runs in a separate isolate.
/// Decodes → copies → for each face: crop, grayscale, composite → encodes JPEG.
Uint8List _runFaceCompositeInIsolate(_FaceCompositeParams params) {
  // Decode image from bytes
  final original = img.decodeImage(params.imageBytes)!;

  // Start with a full copy as the working canvas
  img.Image composite = img.copyResize(
    original,
    width: original.width,
    height: original.height,
  );

  for (final face in params.faceRects) {
    // Crop face region
    final faceCrop = img.copyCrop(
      composite,
      x: face.x,
      y: face.y,
      width: face.w,
      height: face.h,
    );

    // Apply grayscale
    final grayFace = img.grayscale(faceCrop);

    // Paste back onto composite
    img.compositeImage(composite, grayFace, dstX: face.x, dstY: face.y);
  }

  // Encode result as JPEG bytes
  return Uint8List.fromList(img.encodeJpg(composite, quality: 90));
}
