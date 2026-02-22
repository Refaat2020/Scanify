import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/ocr_result.dart';

abstract class OcrRepository {
  /// Runs ML Kit text recognition on [imagePath] and returns
  Future<Either<Failure, OcrResult>> extractText(String imagePath);
}
