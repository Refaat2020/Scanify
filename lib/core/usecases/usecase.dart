import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// Base class for all use cases.
/// [Type] is the return type on success.
/// [Params] is the input parameter type.
// ignore: avoid_types_as_parameter_names
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// For use cases that take no parameters.
class NoParams {}
