import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scanify/core/error/failures.dart';
import 'package:scanify/features/home/domain/repositories/history_repository.dart';
import 'package:scanify/features/home/domain/usecases/delete_history_item.dart';

class MockHistoryRepository extends Mock implements HistoryRepository {}

void main() {
  late DeleteHistoryItem usecase;
  late MockHistoryRepository mockRepository;

  setUp(() {
    mockRepository = MockHistoryRepository();
    usecase = DeleteHistoryItem(mockRepository);
  });

  const tId = 'test-item-id';
  const tParams = DeleteHistoryItemParams(id: tId);

  test('should delete history item from repository', () async {
    // arrange
    when(
      () => mockRepository.deleteHistoryItem(any()),
    ).thenAnswer((_) async => const Right(unit));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Right(unit));
    verify(() => mockRepository.deleteHistoryItem(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return CacheFailure when deletion fails', () async {
    // arrange
    when(
      () => mockRepository.deleteHistoryItem(any()),
    ).thenAnswer((_) async => const Left(CacheFailure('Delete failed')));

    // act
    final result = await usecase(tParams);

    // assert
    expect(result, const Left(CacheFailure('Delete failed')));
    verify(() => mockRepository.deleteHistoryItem(tId)).called(1);
  });
}
