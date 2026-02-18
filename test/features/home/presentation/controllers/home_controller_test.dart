import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanify/core/enums/processing_type.dart';
import 'package:scanify/core/error/failures.dart';
import 'package:scanify/core/usecases/usecase.dart';
import 'package:scanify/features/home/domain/entities/history_item.dart';
import 'package:scanify/features/home/domain/usecases/delete_history_item.dart';
import 'package:scanify/features/home/domain/usecases/get_history.dart';
import 'package:scanify/features/home/presentation/controllers/home_controller.dart';

class MockGetHistory extends Mock implements GetHistory {}

class MockDeleteHistoryItem extends Mock implements DeleteHistoryItem {}

class FakeNoParams extends Fake implements NoParams {}

class FakeDeleteHistoryItemParams extends Fake
    implements DeleteHistoryItemParams {}

void main() {
  late HomeController controller;
  late MockGetHistory mockGetHistory;
  late MockDeleteHistoryItem mockDeleteHistoryItem;

  setUp(() {
    Get.testMode = true;
    mockGetHistory = MockGetHistory();
    mockDeleteHistoryItem = MockDeleteHistoryItem();
    controller = HomeController(
      getHistory: mockGetHistory,
      deleteHistoryItem: mockDeleteHistoryItem,
    );
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeDeleteHistoryItemParams());
  });

  tearDown(() {
    Get.reset();
  });

  final tHistoryItems = [
    HistoryItem(
      id: '1',
      processingType: ProcessingType.face,
      originalImagePath: '/path/1.jpg',
      resultPath: '/result/1.jpg',
      createdAt: DateTime(2025, 1, 15),
      fileSizeBytes: 1024000,
      facesDetected: 2,
    ),
    HistoryItem(
      id: '2',
      processingType: ProcessingType.document,
      originalImagePath: '/path/2.jpg',
      resultPath: '/result/2.pdf',
      createdAt: DateTime(2025, 1, 14),
      fileSizeBytes: 512000,
    ),
  ];

  group('loadHistory', () {
    test('should load history items successfully', () async {
      // arrange
      when(
        () => mockGetHistory(any()),
      ).thenAnswer((_) async => Right(tHistoryItems));

      // act
      await controller.loadHistory();

      // assert
      expect(controller.isLoading.value, false);
      expect(controller.hasError, false);
      expect(controller.historyItems.length, 2);
      expect(controller.historyItems, tHistoryItems);
      verify(() => mockGetHistory(any())).called(1);
    });

    test('should handle error when loading fails', () async {
      // arrange
      when(
        () => mockGetHistory(any()),
      ).thenAnswer((_) async => const Left(CacheFailure('Load failed')));

      // act
      await controller.loadHistory();

      // assert
      expect(controller.isLoading.value, false);
      expect(controller.hasError, true);
      expect(controller.errorMessage.value, 'Load failed');
      expect(controller.historyItems.isEmpty, true);
    });
  });

  group('deleteItem', () {
    test('should delete item successfully', () async {
      // arrange
      controller.historyItems.assignAll(tHistoryItems);
      when(
        () => mockDeleteHistoryItem(any()),
      ).thenAnswer((_) async => const Right(unit));

      // act
      await controller.deleteItem('1');

      // assert
      expect(controller.historyItems.length, 1);
      expect(controller.historyItems.first.id, '2');
      verify(() => mockDeleteHistoryItem(any())).called(1);
    });
  });

  group('derived getters', () {
    test('hasHistory should return true when items exist', () {
      controller.historyItems.assignAll(tHistoryItems);
      expect(controller.hasHistory, true);
    });

    test('hasHistory should return false when empty', () {
      controller.historyItems.clear();
      expect(controller.hasHistory, false);
    });

    test('hasError should return true when error exists', () {
      controller.errorMessage.value = 'Some error';
      expect(controller.hasError, true);
    });
  });
}
