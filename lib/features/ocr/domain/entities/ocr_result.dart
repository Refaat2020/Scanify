import 'package:equatable/equatable.dart';

/// Full OCR output from a single image.
/// Mirrors ML Kit's block → line → element hierarchy
class OcrResult extends Equatable {
  final String imagePath;
  final String fullText; // concatenated plain text
  final List<OcrBlock> blocks; // paragraph-level blocks
  final DateTime extractedAt;

  const OcrResult({
    required this.imagePath,
    required this.fullText,
    required this.blocks,
    required this.extractedAt,
  });

  bool get isEmpty => fullText.trim().isEmpty;
  int get wordCount => fullText.trim().isEmpty
      ? 0
      : fullText.trim().split(RegExp(r'\s+')).length;
  int get blockCount => blocks.length;

  @override
  List<Object?> get props => [imagePath, fullText, extractedAt];
}

/// A paragraph-level text block
class OcrBlock extends Equatable {
  final String text;
  final List<OcrLine> lines;

  const OcrBlock({required this.text, required this.lines});

  @override
  List<Object?> get props => [text];
}

/// A single line within a block
class OcrLine extends Equatable {
  final String text;
  final List<String> elements; // individual words/tokens

  const OcrLine({required this.text, required this.elements});

  @override
  List<Object?> get props => [text];
}
