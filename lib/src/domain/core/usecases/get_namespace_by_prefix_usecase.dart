import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';
import '../value_objects/namespace.dart';

/// Usecase for getting namespaces by prefix.
class GetNamespaceByPrefixUsecase {
  final IdRegistryRepository repository;

  GetNamespaceByPrefixUsecase({required this.repository});

  /// Executes the usecase to get a namespace by prefix.
  Future<Either<Failure, Namespace>> execute({required String prefix}) async {
    return await repository.getNamespaceByPrefix(prefix: prefix);
  }
}
