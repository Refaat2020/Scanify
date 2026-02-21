import 'package:dartz/dartz.dart';

import '../../../../core/enums/processing_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../processing/domain/entities/processing_result.dart';
import '../../../processing/domain/usecases/detect_content_type.dart';
import '../../../processing/domain/usecases/process_document_image.dart';
import '../../../processing/domain/usecases/process_face_image.dart';

/// Processes a single image from a batch — wraps the existing processing use cases.
/// The batch controller calls this repeatedly for each image in the queue.
class ProcessBatchImage
    implements UseCase<ProcessingResult, ProcessBatchImageParams> {
  final DetectContentType _detectContentType;
  final ProcessFaceImage _processFaceImage;
  final ProcessDocumentImage _processDocumentImage;

  const ProcessBatchImage({
    required DetectContentType detectContentType,
    required ProcessFaceImage processFaceImage,
    required ProcessDocumentImage processDocumentImage,
  }) : _detectContentType = detectContentType,
       _processFaceImage = processFaceImage,
       _processDocumentImage = processDocumentImage;

  @override
  Future<Either<Failure, ProcessingResult>> call(
    ProcessBatchImageParams params,
  ) async {
    // 1. Detect content type
    final typeResult = await _detectContentType(
      DetectContentTypeParams(imagePath: params.imagePath),
    );

    return await typeResult.fold(Left.new, (type) async {
      // 2. If unknown, default to face (user can override later)
      final effectiveType = type ?? params.forcedType ?? ProcessingType.face;

      // 3. Run appropriate pipeline
      if (effectiveType == ProcessingType.face) {
        return await _processFaceImage(
          ProcessFaceImageParams(imagePath: params.imagePath),
        );
      } else {
        return await _processDocumentImage(
          ProcessDocumentImageParams(imagePath: params.imagePath),
        );
      }
    });
  }
}

class ProcessBatchImageParams {
  final String imagePath;
  final ProcessingType? forcedType; // null = auto-detect

  const ProcessBatchImageParams({required this.imagePath, this.forcedType});
}
