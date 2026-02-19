import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/processing_result.dart';

/// Contract for all image processing operations.
/// Both face and document pipelines are declared here —
/// the controller depends only on this abstraction.
abstract class ImageProcessingRepository {
  /// Runs the full face pipeline:
  /// detect → crop → B&W filter → composite → save
  Future<Either<Failure, ProcessingResult>> processFaceImage(String imagePath);

  /// Runs the full document pipeline:
  /// detect text → edge detection → perspective transform →
  /// contrast enhance → PDF export → save
  Future<Either<Failure, ProcessingResult>> processDocumentImage(
    String imagePath,
  );

  /// Checks if [imagePath] contains detectable faces.
  Future<Either<Failure, bool>> hasFaces(String imagePath);

  /// Checks if [imagePath] contains recognisable text regions.
  Future<Either<Failure, bool>> hasText(String imagePath);
}
