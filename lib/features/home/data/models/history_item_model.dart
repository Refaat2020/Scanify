import 'package:hive_ce/hive.dart';

import '../../../../core/enums/processing_type.dart';
import '../../domain/entities/history_item.dart';

part 'history_item_model.g.dart';

@HiveType(typeId: 0)
class HistoryItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int processingTypeIndex; // store enum as int

  @HiveField(2)
  final String originalImagePath;

  @HiveField(3)
  final String resultPath;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final int fileSizeBytes;

  @HiveField(6)
  final int? facesDetected;

  HistoryItemModel({
    required this.id,
    required this.processingTypeIndex,
    required this.originalImagePath,
    required this.resultPath,
    required this.createdAt,
    required this.fileSizeBytes,
    this.facesDetected,
  });

  factory HistoryItemModel.fromEntity(HistoryItem entity) {
    return HistoryItemModel(
      id: entity.id,
      processingTypeIndex: entity.processingType.index,
      originalImagePath: entity.originalImagePath,
      resultPath: entity.resultPath,
      createdAt: entity.createdAt,
      fileSizeBytes: entity.fileSizeBytes,
      facesDetected: entity.facesDetected,
    );
  }

  HistoryItem toEntity() {
    return HistoryItem(
      id: id,
      processingType: ProcessingType.values[processingTypeIndex],
      originalImagePath: originalImagePath,
      resultPath: resultPath,
      createdAt: createdAt,
      fileSizeBytes: fileSizeBytes,
      facesDetected: facesDetected,
    );
  }
}
