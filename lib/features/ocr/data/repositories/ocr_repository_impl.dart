import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ocr_result.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../datasources/ocr_datasource.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrDataSource dataSource;
  const OcrRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, OcrResult>> extractText(String imagePath) async {
    try {
      final result = await dataSource.extractText(imagePath);
      return Right(result);
    } on DetectionException catch (e) {
      return Left(DetectionFailure(e.message));
    } catch (e) {
      return Left(ImageProcessingFailure(e.toString()));
    }
  }
}
