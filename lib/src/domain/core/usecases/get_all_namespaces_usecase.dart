import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';
import '../value_objects/namespace.dart';

/// Usecase for getting all registered namespaces.
class GetAllNamespacesUsecase {
  final IdRegistryRepository repository;

  GetAllNamespacesUsecase({required this.repository});

  /// Executes the usecase to get all registered namespaces.
  Future<Either<Failure, Set<Namespace>>> execute() async {
    return await repository.getAll();
  }
}
