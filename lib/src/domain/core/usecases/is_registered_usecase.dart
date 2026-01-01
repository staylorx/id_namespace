import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';
import '../value_objects/namespace.dart';

/// Usecase for checking if a namespace is registered.
class IsRegisteredUsecase {
  final IdRegistryRepository repository;

  IsRegisteredUsecase({required this.repository});

  Future<Either<Failure, bool>> execute({required Namespace namespace}) async {
    return await repository.isRegistered(namespace: namespace);
  }
}
