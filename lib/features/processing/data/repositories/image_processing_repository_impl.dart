import 'package:dartz/dartz.dart';

import '../../../../core/enums/processing_type.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/processing_result.dart';
import '../../domain/repositories/image_processing_repository.dart';
import '../datasources/image_processing_datasource.dart';

class ImageProcessingRepositoryImpl implements ImageProcessingRepository {
  final ImageProcessingDataSource dataSource;

  const ImageProcessingRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, bool>> hasFaces(String imagePath) async {
    try {
      final result = await dataSource.hasFaces(imagePath);
      return Right(result);
    } on DetectionException catch (e) {
      return Left(DetectionFailure(e.message));
    } catch (e) {
      return Left(ImageProcessingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> hasText(String imagePath) async {
    try {
      final result = await dataSource.hasText(imagePath);
      return Right(result);
    } on DetectionException catch (e) {
      return Left(DetectionFailure(e.message));
    } catch (e) {
      return Left(ImageProcessingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProcessingResult>> processFaceImage(
    String imagePath,
  ) async {
    try {
      final output = await dataSource.processFaceImage(imagePath);
      return Right(
        ProcessingResult(
          type: ProcessingType.face,
          originalImagePath: imagePath,
          resultPath: output.resultImagePath,
          fileSizeBytes: output.fileSizeBytes,
          facesDetected: output.facesDetected,
        ),
      );
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(e.message));
    } catch (e) {
      return Left(ImageProcessingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProcessingResult>> processDocumentImage(
    String imagePath,
  ) async {
    try {
      final output = await dataSource.processDocumentImage(imagePath);
      return Right(
        ProcessingResult(
          type: ProcessingType.document,
          originalImagePath: imagePath,
          resultPath: output.resultPdfPath,
          fileSizeBytes: output.fileSizeBytes,
        ),
      );
    } on ImageProcessingException catch (e) {
      return Left(ImageProcessingFailure(e.message));
    } catch (e) {
      return Left(ImageProcessingFailure(e.toString()));
    }
  }
}
