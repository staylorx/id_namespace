import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';

/// Usecase for fetching and registering an ontology from the internet.
class FetchAndRegisterOntologyUsecase {
  final IdRegistryRepository repository;

  FetchAndRegisterOntologyUsecase({required this.repository});

  Future<Either<Failure, Unit>> execute({
    required String url,
    required String prefix,
    String? description,
  }) async {
    return await repository.fetchAndRegisterOntology(
      url: url,
      prefix: prefix,
      description: description,
    );
  }
}
