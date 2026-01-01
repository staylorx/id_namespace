import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';
import '../value_objects/namespace.dart';

/// Usecase for registering a namespace.
class AddNamespaceUsecase {
  final IdRegistryRepository repository;

  AddNamespaceUsecase({required this.repository});

  /// Executes the usecase to add a namespace.
  Future<Either<Failure, Unit>> execute({required Namespace namespace}) async {
    return await repository.add(namespace: namespace);
  }
}
