import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';

/// Usecase for clearing all registrations.
class ClearRegistryUsecase {
  final IdRegistryRepository repository;

  ClearRegistryUsecase({required this.repository});

  /// Executes the usecase to clear all registrations.
  Future<Either<Failure, Unit>> execute() async {
    return await repository.clear();
  }
}
