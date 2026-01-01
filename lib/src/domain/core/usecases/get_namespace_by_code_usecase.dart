import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';
import '../value_objects/namespace.dart';

/// Usecase for getting namespaces by code.
class GetNamespaceByCodeUsecase {
  final IdRegistryRepository repository;

  GetNamespaceByCodeUsecase({required this.repository});

  Future<Either<Failure, Namespace>> execute({required String code}) async {
    return await repository.getNamespaceByCode(code: code);
  }
}
