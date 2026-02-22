import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/ocr_result.dart';
import 'ocr_datasource.dart';

class OcrDataSourceImpl implements OcrDataSource {
  TextRecognizer? _recognizer;

  TextRecognizer get recognizer {
    _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _recognizer!;
  }

  @override
  Future<OcrResult> extractText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);

      // ML Kit runs on its own native thread — no compute() needed
      final recognised = await recognizer.processImage(inputImage);

      // Map ML Kit hierarchy → pure domain entities
      final blocks = recognised.blocks.map((block) {
        final lines = block.lines.map((line) {
          final elements = line.elements.map((e) => e.text).toList();
          return OcrLine(text: line.text, elements: elements);
        }).toList();
        return OcrBlock(text: block.text, lines: lines);
      }).toList();

      return OcrResult(
        imagePath: imagePath,
        fullText: recognised.text,
        blocks: blocks,
        extractedAt: DateTime.now(),
      );
    } catch (e) {
      throw DetectionException('OCR extraction failed: $e');
    }
  }

  Future<void> dispose() async {
    await _recognizer?.close();
    _recognizer = null;
  }
}
