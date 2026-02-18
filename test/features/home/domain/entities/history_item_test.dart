import 'package:flutter_test/flutter_test.dart';
import 'package:scanify/core/enums/processing_type.dart';
import 'package:scanify/features/home/domain/entities/history_item.dart';

void main() {
  group('HistoryItem', () {
    final tHistoryItem = HistoryItem(
      id: 'test-id',
      processingType: ProcessingType.face,
      originalImagePath: '/path/to/original.jpg',
      resultPath: '/path/to/result.jpg',
      createdAt: DateTime(2025, 1, 15, 10, 30),
      fileSizeBytes: 1024000,
      facesDetected: 3,
    );

    test('should properly initialize with all properties', () {
      expect(tHistoryItem.id, 'test-id');
      expect(tHistoryItem.processingType, ProcessingType.face);
      expect(tHistoryItem.fileSizeBytes, 1024000);
      expect(tHistoryItem.facesDetected, 3);
    });

    test('isFace should return true for face type', () {
      expect(tHistoryItem.isFace, true);
      expect(tHistoryItem.isDocument, false);
    });

    test('isDocument should return true for document type', () {
      final docItem = tHistoryItem.copyWith(
        processingType: ProcessingType.document,
        facesDetected: null,
      );
      expect(docItem.isDocument, true);
      expect(docItem.isFace, false);
    });

    test('Equatable should work correctly', () {
      final item2 = HistoryItem(
        id: 'test-id',
        processingType: ProcessingType.face,
        originalImagePath: '/path/to/original.jpg',
        resultPath: '/path/to/result.jpg',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        fileSizeBytes: 1024000,
        facesDetected: 3,
      );

      final item3 = HistoryItem(
        id: 'different-id',
        processingType: ProcessingType.face,
        originalImagePath: '/path/to/original.jpg',
        resultPath: '/path/to/result.jpg',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        fileSizeBytes: 1024000,
        facesDetected: 3,
      );

      expect(tHistoryItem, equals(item2));
      expect(tHistoryItem, isNot(equals(item3)));
    });

    test('copyWith should create modified copy', () {
      final modified = tHistoryItem.copyWith(
        processingType: ProcessingType.document,
        facesDetected: null,
      );

      expect(modified.id, tHistoryItem.id);
      expect(modified.processingType, ProcessingType.document);
      expect(modified.facesDetected, null);
      expect(modified.originalImagePath, tHistoryItem.originalImagePath);
    });
  });
}

extension on HistoryItem {
  HistoryItem copyWith({ProcessingType? processingType, int? facesDetected}) {
    return HistoryItem(
      id: id,
      processingType: processingType ?? this.processingType,
      originalImagePath: originalImagePath,
      resultPath: resultPath,
      createdAt: createdAt,
      fileSizeBytes: fileSizeBytes,
      facesDetected: facesDetected,
    );
  }
}
