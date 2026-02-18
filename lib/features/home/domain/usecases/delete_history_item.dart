import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

class DeleteHistoryItem implements UseCase<Unit, DeleteHistoryItemParams> {
  final HistoryRepository repository;

  const DeleteHistoryItem(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteHistoryItemParams params) {
    return repository.deleteHistoryItem(params.id);
  }
}

class DeleteHistoryItemParams {
  final String id;
  const DeleteHistoryItemParams({required this.id});
}
