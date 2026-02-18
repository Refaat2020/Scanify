import 'package:equatable/equatable.dart';

import '../../../../core/enums/processing_type.dart';

class HistoryItem extends Equatable {
  final String id;
  final ProcessingType processingType;
  final String originalImagePath;
  final String resultPath; // image path for face, PDF path for document
  final DateTime createdAt;
  final int fileSizeBytes;
  final int? facesDetected; // null for document flow

  const HistoryItem({
    required this.id,
    required this.processingType,
    required this.originalImagePath,
    required this.resultPath,
    required this.createdAt,
    required this.fileSizeBytes,
    this.facesDetected,
  });

  bool get isDocument => processingType == ProcessingType.document;
  bool get isFace => processingType == ProcessingType.face;

  @override
  List<Object?> get props => [
    id,
    processingType,
    originalImagePath,
    resultPath,
    createdAt,
    fileSizeBytes,
    facesDetected,
  ];
}
