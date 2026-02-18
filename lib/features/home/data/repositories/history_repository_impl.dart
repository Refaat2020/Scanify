import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/history_item.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_datasource.dart';
import '../models/history_item_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;

  const HistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<HistoryItem>>> getHistory() async {
    try {
      final models = await localDataSource.getAllHistoryItems();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveHistoryItem(HistoryItem item) async {
    try {
      final model = HistoryItemModel.fromEntity(item);
      await localDataSource.saveHistoryItem(model);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteHistoryItem(String id) async {
    try {
      await localDataSource.deleteHistoryItem(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearHistory() async {
    try {
      await localDataSource.clearHistory();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
