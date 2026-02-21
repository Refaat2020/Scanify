import 'package:equatable/equatable.dart';

import '../../../../core/enums/processing_type.dart';

enum BatchJobStatus { pending, processing, completed, failed }

/// A single image within a batch job.
class BatchJobItem extends Equatable {
  final String id;
  final String imagePath;
  final BatchJobStatus status;
  final ProcessingType? detectedType; // null until detection runs
  final String? resultPath; // null until completed
  final String? errorMessage; // null unless failed

  const BatchJobItem({
    required this.id,
    required this.imagePath,
    required this.status,
    this.detectedType,
    this.resultPath,
    this.errorMessage,
  });

  bool get isPending => status == BatchJobStatus.pending;
  bool get isProcessing => status == BatchJobStatus.processing;
  bool get isCompleted => status == BatchJobStatus.completed;
  bool get isFailed => status == BatchJobStatus.failed;

  BatchJobItem copyWith({
    BatchJobStatus? status,
    ProcessingType? detectedType,
    String? resultPath,
    String? errorMessage,
  }) {
    return BatchJobItem(
      id: id,
      imagePath: imagePath,
      status: status ?? this.status,
      detectedType: detectedType ?? this.detectedType,
      resultPath: resultPath ?? this.resultPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [id, status, detectedType, resultPath];
}
