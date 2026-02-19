import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/processing_result.dart';
import '../repositories/image_processing_repository.dart';

class ProcessDocumentImage
    implements UseCase<ProcessingResult, ProcessDocumentImageParams> {
  final ImageProcessingRepository repository;

  const ProcessDocumentImage(this.repository);

  @override
  Future<Either<Failure, ProcessingResult>> call(
    ProcessDocumentImageParams params,
  ) {
    return repository.processDocumentImage(params.imagePath);
  }
}

class ProcessDocumentImageParams {
  final String imagePath;
  const ProcessDocumentImageParams({required this.imagePath});
}
