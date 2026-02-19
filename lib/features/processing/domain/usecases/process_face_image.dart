import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/processing_result.dart';
import '../repositories/image_processing_repository.dart';

class ProcessFaceImage
    implements UseCase<ProcessingResult, ProcessFaceImageParams> {
  final ImageProcessingRepository repository;

  const ProcessFaceImage(this.repository);

  @override
  Future<Either<Failure, ProcessingResult>> call(
    ProcessFaceImageParams params,
  ) {
    return repository.processFaceImage(params.imagePath);
  }
}

class ProcessFaceImageParams {
  final String imagePath;
  const ProcessFaceImageParams({required this.imagePath});
}
