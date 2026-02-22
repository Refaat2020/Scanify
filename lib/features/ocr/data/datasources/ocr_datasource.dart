import '../../../ocr/domain/entities/ocr_result.dart';

abstract class OcrDataSource {
  /// Runs ML Kit text recognition and maps to [OcrResult].
  Future<OcrResult> extractText(String imagePath);
}
