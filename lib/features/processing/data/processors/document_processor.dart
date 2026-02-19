import 'dart:typed_data';

abstract class DocumentProcessor {
  Future<Uint8List> compositeDocument({required Uint8List imageBytes});

  Future<List<double>?> detectDocumentCorners({required Uint8List imageBytes});

  Future<Uint8List?> perspectiveTransform({
    required Uint8List imageBytes,
    required List<double> corners,
  });
}
