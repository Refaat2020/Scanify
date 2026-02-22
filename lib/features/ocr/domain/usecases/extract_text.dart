import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ocr_result.dart';
import '../repositories/ocr_repository.dart';

class ExtractText implements UseCase<OcrResult, ExtractTextParams> {
  final OcrRepository repository;
  const ExtractText(this.repository);

  @override
  Future<Either<Failure, OcrResult>> call(ExtractTextParams params) =>
      repository.extractText(params.imagePath);
}

class ExtractTextParams {
  final String imagePath;
  const ExtractTextParams({required this.imagePath});
}
