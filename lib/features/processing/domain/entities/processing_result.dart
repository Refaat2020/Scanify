import 'package:equatable/equatable.dart';

import '../../../../core/enums/processing_type.dart';

/// The output produced by either the face or document pipeline.
/// Passed from ProcessingController → ResultController via Get.arguments.
class ProcessingResult extends Equatable {
  final ProcessingType type;
  final String originalImagePath;
  final String resultPath; // composite image (face) | PDF path (document)
  final int fileSizeBytes;
  final int? facesDetected; // face flow only

  const ProcessingResult({
    required this.type,
    required this.originalImagePath,
    required this.resultPath,
    required this.fileSizeBytes,
    this.facesDetected,
  });

  bool get isFace => type == ProcessingType.face;
  bool get isDocument => type == ProcessingType.document;

  @override
  List<Object?> get props => [
    type,
    originalImagePath,
    resultPath,
    fileSizeBytes,
    facesDetected,
  ];
}
