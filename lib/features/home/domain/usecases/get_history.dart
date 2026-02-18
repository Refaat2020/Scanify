import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/history_item.dart';
import '../repositories/history_repository.dart';

class GetHistory implements UseCase<List<HistoryItem>, NoParams> {
  final HistoryRepository repository;

  const GetHistory(this.repository);

  @override
  Future<Either<Failure, List<HistoryItem>>> call(NoParams params) {
    return repository.getHistory();
  }
}
