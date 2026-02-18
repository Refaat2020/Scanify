import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

class SaveHistoryItem implements UseCase<Unit, SaveHistoryItemParams> {
  final HistoryRepository repository;

  const SaveHistoryItem(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SaveHistoryItemParams params) {
    return repository.saveHistoryItem(params.item);
  }
}

class SaveHistoryItemParams {
  final HistoryItem item;
  const SaveHistoryItemParams({required this.item});
}
