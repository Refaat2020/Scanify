import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanify/core/enums/processing_type.dart';
import 'package:scanify/core/error/failures.dart';
import 'package:scanify/core/usecases/usecase.dart';
import 'package:scanify/features/home/domain/entities/history_item.dart';
import 'package:scanify/features/home/domain/repositories/history_repository.dart';
import 'package:scanify/features/home/domain/usecases/get_history.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

void main() {
  late GetHistory usecase;
  late MockHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockHistoryRepository();
    usecase = GetHistory(mockRepository);
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

  test('should get history items from repository', () async {
    // arrange
    when(
      () => mockRepository.getHistory(),
    ).thenAnswer((_) async => Right(tHistoryItems));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, Right(tHistoryItems));
    verify(() => mockRepository.getHistory()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return CacheFailure when repository fails', () async {
    // arrange
    when(
      () => mockRepository.getHistory(),
    ).thenAnswer((_) async => const Left(CacheFailure('Cache error')));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, const Left(CacheFailure('Cache error')));
    verify(() => mockRepository.getHistory()).called(1);
  });
}
