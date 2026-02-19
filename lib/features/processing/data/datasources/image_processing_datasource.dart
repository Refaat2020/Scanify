import '../models/document_processing_output.dart';
import '../models/face_processing_output.dart';

/// Low-level contract for all image processing operations.
/// The impl uses ML Kit + image package + pdf package.
abstract class ImageProcessingDataSource {
  /// Returns true if [imagePath] contains at least one face.
  Future<bool> hasFaces(String imagePath);

  /// Returns true if [imagePath] contains recognisable text regions.
  Future<bool> hasText(String imagePath);

  /// Full face pipeline — returns path to composite result image.
  Future<FaceProcessingOutput> processFaceImage(String imagePath);

  /// Full document pipeline — returns path to generated PDF.
  Future<DocumentProcessingOutput> processDocumentImage(String imagePath);
}
