import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';
import '../value_objects/namespace.dart';

/// Usecase for unregistering a namespace.
class RemoveNamespaceUsecase {
  final IdRegistryRepository repository;

  RemoveNamespaceUsecase({required this.repository});

  /// Executes the usecase to remove a namespace.
  Future<Either<Failure, Unit>> execute({required Namespace namespace}) async {
    return await repository.remove(namespace: namespace);
  }
}
