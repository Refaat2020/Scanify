import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/history_item.dart';

abstract class HistoryRepository {
  /// Returns all history items sorted by date descending.
  Future<Either<Failure, List<HistoryItem>>> getHistory();

  /// Persists a new history item after processing completes.
  Future<Either<Failure, Unit>> saveHistoryItem(HistoryItem item);

  /// Removes a single history item and its associated files.
  Future<Either<Failure, Unit>> deleteHistoryItem(String id);

  /// Clears entire history and all associated files.
  Future<Either<Failure, Unit>> clearHistory();
}
