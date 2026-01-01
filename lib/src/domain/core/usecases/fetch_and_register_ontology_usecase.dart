import 'package:fpdart/fpdart.dart';

import '../../../utils/failures.dart';
import '../repositories/id_registry_repository.dart';
import '../services/fetch_content_service.dart';
import '../services/rdf_parsing_service.dart';
import '../value_objects/namespace.dart';

/// Usecase for fetching and registering an ontology from the internet.
class FetchAndRegisterOntologyUsecase {
  final FetchContentService fetchContentService;
  final RdfParsingService rdfParsingService;
  final IdRegistryRepository repository;

  FetchAndRegisterOntologyUsecase({
    required this.fetchContentService,
    required this.rdfParsingService,
    required this.repository,
  });

  Future<Either<Failure, Unit>> execute({
    required String url,
    required String prefix,
    String? description,
  }) async {
    // Step 1: Fetch content
    final contentEither = await fetchContentService.fetchContent(url);
    return await contentEither.match((failure) => Future.value(Left(failure)), (
      content,
    ) async {
      // Step 2: Parse RDF
      final rdfEither = await rdfParsingService.parseRdf(content, url);
      return await rdfEither.match((failure) => Future.value(Left(failure)), (
        rdfGraph,
      ) async {
        // Step 3: Create namespace
        final uri = Uri.parse(url);
        final namespace = Namespace(
          uri: uri,
          prefix: prefix,
          description: description,
          rdfGraph: rdfGraph,
        );

        // Step 4: Add to repository
        return await repository.add(namespace: namespace);
      });
    });
  }
}
