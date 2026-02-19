import 'package:dartz/dartz.dart';

import '../../../../core/enums/processing_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/image_processing_repository.dart';

/// Analyses the image and returns which pipeline to run.
///
/// Returns:
///   Right(ProcessingType.face)     → faces detected
///   Right(ProcessingType.document) → text detected, no faces
///   Right(null)                    → neither detected — unknown content
///   Left(Failure)                  → ML Kit error
class DetectContentType
    implements UseCase<ProcessingType?, DetectContentTypeParams> {
  final ImageProcessingRepository repository;

  const DetectContentType(this.repository);

  @override
  Future<Either<Failure, ProcessingType?>> call(
    DetectContentTypeParams params,
  ) async {
    // 1. Check for faces first — faster gate
    final facesResult = await repository.hasFaces(params.imagePath);
    if (facesResult.isLeft()) return facesResult.map((_) => null);

    final hasFaces = facesResult.getOrElse(() => false);
    if (hasFaces) return const Right(ProcessingType.face);

    // 2. No faces — check for text to confirm it's a document
    final textResult = await repository.hasText(params.imagePath);
    if (textResult.isLeft()) return textResult.map((_) => null);

    final hasText = textResult.getOrElse(() => false);
    if (hasText) return const Right(ProcessingType.document);

    // 3. Neither faces nor meaningful text — unknown content
    return const Right(null);
  }
}

class DetectContentTypeParams {
  final String imagePath;
  const DetectContentTypeParams({required this.imagePath});
}
