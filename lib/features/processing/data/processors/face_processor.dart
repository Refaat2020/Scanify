import 'dart:typed_data';

import '../models/face_rect.dart';

abstract class FaceProcessor {
  /// Takes image bytes + face rects → returns composite JPEG bytes
  /// with grayscale faces. Runs in background isolate via compute().
  Future<Uint8List> compositeFaces({
    required Uint8List imageBytes,
    required List<FaceRect> rects,
  });
}
