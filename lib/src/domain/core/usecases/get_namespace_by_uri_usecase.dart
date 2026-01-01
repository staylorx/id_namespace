import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';
import '../value_objects/namespace.dart';

/// Usecase for getting namespaces by URI.
class GetNamespaceByUriUsecase {
  final IdRegistryRepository repository;

  GetNamespaceByUriUsecase({required this.repository});

  /// Executes the usecase to get a namespace by URI.
  Future<Either<Failure, Namespace>> execute({required Uri uri}) async {
    return await repository.getNamespaceByUri(uri: uri);
  }
}
